#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "open3"
require "optparse"
require "pathname"
require "tempfile"
require "time"

class DurableTaskHandoff
  class Error < StandardError; end

  VALID_TRIGGERS = %w[context-compaction phase-boundary task-transfer pause manual].freeze

  def initialize(clock: -> { Time.now.utc })
    @clock = clock
  end

  def build(objective:, trigger:, next_step:, repositories:, completed: [], verification: [], constraints: [])
    raise Error, "objective must not be empty" if objective.to_s.strip.empty?
    raise Error, "next step must not be empty" if next_step.to_s.strip.empty?
    raise Error, "invalid trigger: #{trigger}" unless VALID_TRIGGERS.include?(trigger)
    raise Error, "at least one repository is required" if repositories.empty?

    states = repositories.map { |path| repository_state(path) }
    duplicate_roots = states.group_by { |state| state.fetch("root") }.select { |_root, entries| entries.length > 1 }.keys
    raise Error, "duplicate repositories resolve to: #{duplicate_roots.join(', ')}" unless duplicate_roots.empty?

    {
      "schema_version" => 1,
      "generated_at" => @clock.call.utc.iso8601,
      "trigger" => trigger,
      "objective" => objective.strip,
      "completed" => clean_list(completed),
      "verification" => clean_list(verification),
      "constraints" => clean_list(constraints),
      "next_step" => next_step.strip,
      "repositories" => states,
      "resume_rule" => "Re-check repository state before acting; this artifact is a snapshot, not a lock."
    }
  end

  private

  def clean_list(values)
    values.map(&:strip).reject(&:empty?)
  end

  def repository_state(path)
    input = Pathname.new(path).expand_path
    raise Error, "repository is not a directory: #{input}" unless input.directory?

    root = git(input, "rev-parse", "--show-toplevel").strip
    raise Error, "not a Git work tree: #{input}" if root.empty?

    branch = git_optional(input, "symbolic-ref", "--quiet", "--short", "HEAD")&.strip
    upstream = git_optional(input, "rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{upstream}")&.strip
    status = git(input, "status", "--porcelain=v1", "-z")

    {
      "input" => input.to_s,
      "root" => Pathname.new(root).realpath.to_s,
      "head" => git(input, "rev-parse", "HEAD").strip,
      "branch" => branch.to_s.empty? ? nil : branch,
      "detached" => branch.to_s.empty?,
      "upstream" => upstream.to_s.empty? ? nil : upstream,
      "dirty" => !status.empty?,
      "status_porcelain" => status.split("\0").reject(&:empty?)
    }
  rescue Errno::ENOENT, Errno::EACCES => e
    raise Error, "cannot inspect repository #{input}: #{e.message}"
  end

  def git(path, *arguments)
    output, error, status = Open3.capture3("git", "-C", path.to_s, *arguments)
    raise Error, "git #{arguments.join(' ')} failed for #{path}: #{error.lines.first.to_s.strip}" unless status.success?

    output
  end

  def git_optional(path, *arguments)
    output, = Open3.capture3("git", "-C", path.to_s, *arguments)
    output
  end
end

def run_cli(arguments, out: $stdout, err: $stderr, clock: -> { Time.now.utc })
  options = { repositories: [], completed: [], verification: [], constraints: [], output_dir: ".codex/checkpoints/handoffs" }
  parser = OptionParser.new do |opts|
    opts.banner = "Usage: capture_handoff.rb --objective TEXT --trigger TYPE --repository PATH --next-step TEXT [options]"
    opts.on("--objective TEXT") { |value| options[:objective] = value }
    opts.on("--trigger TYPE", DurableTaskHandoff::VALID_TRIGGERS) { |value| options[:trigger] = value }
    opts.on("--repository PATH", "Repeat for each Git repository") { |value| options[:repositories] << value }
    opts.on("--completed TEXT", "Repeat for completed work") { |value| options[:completed] << value }
    opts.on("--verification TEXT", "Repeat for validation evidence") { |value| options[:verification] << value }
    opts.on("--constraint TEXT", "Repeat for safety or authority constraints") { |value| options[:constraints] << value }
    opts.on("--next-step TEXT") { |value| options[:next_step] = value }
    opts.on("--output-dir PATH") { |value| options[:output_dir] = value }
    opts.on("-h", "--help") { out.puts(opts); return 0 }
  end

  parser.parse!(arguments)
  payload = DurableTaskHandoff.new(clock: clock).build(**options.slice(:objective, :trigger, :next_step, :repositories, :completed, :verification, :constraints))
  directory = Pathname.new(options.fetch(:output_dir)).expand_path
  directory.mkpath
  timestamp = Time.parse(payload.fetch("generated_at")).utc.strftime("%Y%m%dT%H%M%SZ")
  output = directory.join("handoff-#{timestamp}-#{Process.pid}.json")
  Tempfile.create([".handoff-", ".json"], directory.to_s) do |temporary|
    temporary.write(JSON.pretty_generate(payload) + "\n")
    temporary.flush
    temporary.fsync
    File.rename(temporary.path, output)
  end
  out.puts(JSON.generate({ "status" => "ok", "output" => output.to_s, "repositories" => payload.fetch("repositories").length }))
  0
rescue OptionParser::ParseError, DurableTaskHandoff::Error, SystemCallError, ArgumentError => e
  err.puts(e.message)
  2
end

exit(run_cli(ARGV)) if $PROGRAM_NAME == __FILE__
