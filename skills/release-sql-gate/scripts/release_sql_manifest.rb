#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "json"
require "open3"
require "optparse"
require "pathname"
require "tempfile"
require "time"

class ReleaseSqlManifest
  class Error < StandardError; end

  RISK_PATTERNS = {
    "ddl" => /\b(?:CREATE|ALTER|DROP|TRUNCATE|RENAME)\b/i,
    "create" => /\bCREATE\s+(?:OR\s+REPLACE\s+)?(?:TEMPORARY\s+)?(?:DATABASE|SCHEMA|TABLE|(?:UNIQUE\s+)?INDEX|VIEW|PROCEDURE|FUNCTION|TRIGGER|EVENT)\b/i,
    "dml" => /\b(?:INSERT|UPDATE|DELETE|REPLACE)\b/i,
    "destructive" => /\b(?:DROP\s+(?:TEMPORARY\s+)?(?:DATABASE|SCHEMA|TABLE|VIEW|INDEX|PROCEDURE|FUNCTION|TRIGGER|EVENT|COLUMN)|TRUNCATE\s+TABLE)\b/i,
    "alter" => /\bALTER\s+(?:DATABASE|SCHEMA|TABLE|VIEW|PROCEDURE|FUNCTION|EVENT)\b/i,
    "rename" => /\bRENAME\s+TABLE\b/i,
    "backfill" => /\b(?:UPDATE|INSERT\s+INTO\b.+\bSELECT|DELETE\s+FROM)\b/im,
    "transaction_control" => /\b(?:START\s+TRANSACTION|BEGIN|COMMIT|ROLLBACK)\b/i,
    "dynamic_sql" => /\b(?:PREPARE|EXECUTE\s+IMMEDIATE)\b/i,
    "account_or_privilege" => /\b(?:(?:CREATE|ALTER|DROP)\s+USER|GRANT|REVOKE)\b/i,
    "operational" => /\b(?:SET\s+GLOBAL|LOAD\s+DATA|LOCK\s+TABLES|UNLOCK\s+TABLES)\b/i
  }.freeze

  def initialize(repository:, base_ref:, head_ref:, order_file: nil, clock: -> { Time.now.utc })
    @repository = Pathname.new(repository).expand_path
    @base_ref = base_ref
    @head_ref = head_ref
    @order_file = order_file && Pathname.new(order_file).expand_path
    @clock = clock
  end

  def build
    validate_repository!
    base_sha = resolve_commit(@base_ref)
    head_sha = resolve_commit(@head_ref)
    discovered = sql_diff(base_sha, head_sha).sort
    ordered, ordering = resolve_order(discovered)
    files = ordered.each_with_index.map { |path, index| file_entry(head_sha, path, index + 1) }

    {
      "schema_version" => 1,
      "generated_at" => @clock.call.utc.iso8601,
      "repository" => @repository.realpath.to_s,
      "base" => { "ref" => @base_ref, "sha" => base_sha },
      "head" => { "ref" => @head_ref, "sha" => head_sha },
      "inventory_method" => "git diff --name-only --diff-filter=ACMR <base>...<head>",
      "sql_count" => discovered.length,
      "completeness" => {
        "status" => "PASS",
        "discovered_paths" => discovered,
        "missing_from_order" => ordering.fetch("missing"),
        "unexpected_in_order" => ordering.fetch("unexpected")
      },
      "ordering" => ordering.slice("status", "source"),
      "ordered_sql_sha256" => ordered_sql_sha256(files),
      "files" => files,
      "execution_gate" => {
        "status" => "NOT_RUN",
        "reason" => "Dependency review, target resolution, prechecks, and explicit write authorization are external gates."
      }
    }
  end

  private

  def validate_repository!
    raise Error, "repository is not a directory: #{@repository}" unless @repository.directory?
    inside = git("rev-parse", "--is-inside-work-tree").strip
    raise Error, "not a Git work tree: #{@repository}" unless inside == "true"
  end

  def resolve_commit(ref)
    sha = git("rev-parse", "--verify", "#{ref}^{commit}").strip
    raise Error, "cannot resolve commit: #{ref}" unless sha.match?(/\A[0-9a-f]{40}\z/)
    sha
  end

  def sql_diff(base_sha, head_sha)
    output = git("diff", "--name-only", "-z", "--diff-filter=ACMR", "#{base_sha}...#{head_sha}")
    output.split("\0").reject(&:empty?).select { |path| path.downcase.end_with?(".sql") }.uniq
  end

  def resolve_order(discovered)
    return [discovered, { "status" => "NOT_PROVIDED", "source" => nil, "missing" => [], "unexpected" => [] }] unless @order_file
    raise Error, "order file does not exist: #{@order_file}" unless @order_file.file?

    ordered = @order_file.readlines(chomp: true).map(&:strip)
                         .reject { |line| line.empty? || line.start_with?("#") }
    duplicates = ordered.each_with_object(Hash.new(0)) { |path, counts| counts[path] += 1 }
                        .select { |_path, count| count > 1 }.keys
    raise Error, "order file contains duplicates: #{duplicates.join(', ')}" unless duplicates.empty?

    missing = discovered - ordered
    unexpected = ordered - discovered
    unless missing.empty? && unexpected.empty?
      raise Error, "order file does not match SQL inventory; missing=#{missing.inspect} unexpected=#{unexpected.inspect}"
    end

    [ordered, {
      "status" => "PROVIDED_REVIEW_REQUIRED",
      "source" => @order_file.realpath.to_s,
      "missing" => missing,
      "unexpected" => unexpected
    }]
  end

  def file_entry(head_sha, path, order)
    content = git("show", "#{head_sha}:#{path}")
    executable = strip_comments_and_literals(content)
    flags = RISK_PATTERNS.map { |name, pattern| name if executable.match?(pattern) }.compact
    {
      "order" => order,
      "path" => path,
      "sha256" => Digest::SHA256.hexdigest(content),
      "bytes" => content.bytesize,
      "risk_flags" => flags,
      "rerun_review_required" => flags.any? { |flag| %w[create alter rename backfill destructive dml dynamic_sql account_or_privilege operational].include?(flag) }
    }
  end

  def ordered_sql_sha256(files)
    canonical = files.map do |file|
      [file.fetch("order"), file.fetch("path"), file.fetch("sha256")].join("\0")
    end.join("\0")
    Digest::SHA256.hexdigest(canonical)
  end

  def strip_comments_and_literals(content)
    content = content.gsub(%r{/\*!\d*\s*(.*?)\*/}m, '\\1')
    result = +""
    index = 0
    state = :normal
    quote = nil

    while index < content.length
      char = content[index]
      following = content[index + 1]

      case state
      when :normal
        if char == "-" && following == "-"
          state = :line_comment
          result << "  "
          index += 1
        elsif char == "#"
          state = :line_comment
          result << " "
        elsif char == "/" && following == "*"
          state = :block_comment
          result << "  "
          index += 1
        elsif ["'", '"', "`"].include?(char)
          state = :quoted
          quote = char
          result << " "
        else
          result << char
        end
      when :line_comment
        if char == "\n"
          state = :normal
          result << "\n"
        else
          result << " "
        end
      when :block_comment
        if char == "*" && following == "/"
          state = :normal
          result << "  "
          index += 1
        else
          result << (char == "\n" ? "\n" : " ")
        end
      when :quoted
        if char == "\\" && following
          result << "  "
          index += 1
        elsif char == quote && following == quote
          result << "  "
          index += 1
        elsif char == quote
          state = :normal
          quote = nil
          result << " "
        else
          result << (char == "\n" ? "\n" : " ")
        end
      end

      index += 1
    end

    result
  end

  def git(*arguments)
    output, error, status = Open3.capture3("git", "-C", @repository.to_s, *arguments)
    raise Error, "git #{arguments.join(' ')} failed: #{error.lines.first.to_s.strip}" unless status.success?
    output
  end
end

def run_cli(arguments)
  options = {}
  parser = OptionParser.new do |opts|
    opts.banner = "Usage: release_sql_manifest.rb --repository PATH --base REF --head REF --output FILE [--order-file FILE]"
    opts.on("--repository PATH") { |value| options[:repository] = value }
    opts.on("--base REF") { |value| options[:base_ref] = value }
    opts.on("--head REF") { |value| options[:head_ref] = value }
    opts.on("--order-file FILE") { |value| options[:order_file] = value }
    opts.on("--output FILE") { |value| options[:output] = value }
    opts.on("-h", "--help") { puts opts; return 0 }
  end

  begin
    parser.parse!(arguments)
    required = %i[repository base_ref head_ref output]
    missing = required.select { |key| options[key].to_s.empty? }
    raise OptionParser::MissingArgument, missing.map { |key| "--#{key.to_s.tr('_', '-')}" }.join(", ") unless missing.empty?

    payload = ReleaseSqlManifest.new(**options.slice(:repository, :base_ref, :head_ref, :order_file)).build
    output = Pathname.new(options.fetch(:output)).expand_path
    output.dirname.mkpath
    Tempfile.create([".sql-manifest-", ".json"], output.dirname.to_s) do |temporary|
      temporary.write(JSON.pretty_generate(payload) + "\n")
      temporary.flush
      temporary.fsync
      File.rename(temporary.path, output)
    end
    puts JSON.generate({
      "status" => "ok",
      "output" => output.to_s,
      "manifest_sha256" => Digest::SHA256.file(output).hexdigest,
      "ordered_sql_sha256" => payload.fetch("ordered_sql_sha256"),
      "sql_count" => payload.fetch("sql_count"),
      "ordering" => payload.dig("ordering", "status")
    })
    0
  rescue OptionParser::ParseError, ReleaseSqlManifest::Error, SystemCallError => e
    warn e.message
    2
  end
end

exit(run_cli(ARGV)) if $PROGRAM_NAME == __FILE__
