#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "fileutils"
require "json"
require "optparse"
require "pathname"
require "time"

module CodexSessionRetrospective
  SCHEMA_VERSION = 2
  SYNTHETIC_USER_PREFIXES = [
    "# AGENTS.md instructions",
    "<environment_context>"
  ].freeze

  FINDING_TEXT = {
    "missing_handoff" => "Run a durable handoff immediately after the first context compaction.",
    "missing_final_answer" => "End substantive work with a self-contained final answer.",
    "missing_implementation_evidence" => "Report fresh implementation checks for changed code.",
    "external_without_runtime_evidence" => "Verify the exact external target and report runtime evidence.",
    "visible_scope_without_visible_evidence" => "Verify the actual user-visible behavior, not only code or CI."
  }.freeze

  class Analyzer
    attr_reader :parse_errors

    def initialize(workspace:, sessions_root:, since_time:, current_session_id: nil, include_current: false, now: Time.now)
      @workspace = Pathname.new(workspace).expand_path.cleanpath.to_s
      @sessions_root = Pathname.new(sessions_root).expand_path
      @since_time = since_time
      @current_session_id = current_session_id.to_s
      @include_current = include_current
      @now = now
      @parse_errors = 0
    end

    def analyze
      sessions = session_files.map { |path| parse_session(path) }.compact
      sessions.sort_by! { |session| session.fetch("started_at") }
      findings = sessions.flat_map do |session|
        session.fetch("findings").map do |code|
          {
            "session_id" => session.fetch("session_id"),
            "started_at" => session.fetch("started_at"),
            "code" => code,
            "recommendation" => FINDING_TEXT.fetch(code)
          }
        end
      end

      {
        "schema_version" => SCHEMA_VERSION,
        "generated_at" => @now.utc.iso8601,
        "workspace" => @workspace,
        "sessions_root" => @sessions_root.to_s,
        "since" => @since_time.utc.iso8601,
        "sampling" => {
          "synthetic_user_messages_excluded" => true,
          "active_session_excluded" => !@include_current,
          "prompt_text_emitted" => false,
          "classifications_are_heuristic" => true
        },
        "summary" => summarize(sessions, findings),
        "findings" => findings,
        "sessions" => sessions
      }
    end

    private

    def session_files
      return [] unless @sessions_root.directory?

      Dir.glob(@sessions_root.join("**/*.jsonl").to_s).sort
    end

    def parse_session(path)
      session = empty_session(path)
      File.foreach(path) do |line|
        item = JSON.parse(line)
        consume(item, session)
      rescue JSON::ParserError
        @parse_errors += 1
      end

      return unless substantive_session?(session)

      classify!(session)
      session.delete("call_fragments")
      session.delete("user_texts")
      session.delete("final_text")
      session
    rescue Errno::ENOENT, Errno::EACCES
      @parse_errors += 1
      nil
    end

    def empty_session(path)
      {
        "source_file" => path.to_s,
        "session_id" => nil,
        "started_at" => nil,
        "cwd" => nil,
        "originator" => nil,
        "user_turns" => 0,
        "assistant_final_answers" => 0,
        "compactions" => 0,
        "tool_calls" => 0,
        "tool_failures" => 0,
        "call_fragments" => [],
        "user_texts" => [],
        "final_text" => ""
      }
    end

    def consume(item, session)
      payload = item["payload"] || {}
      case item["type"]
      when "session_meta"
        session["session_id"] = payload["session_id"] || payload["id"]
        session["started_at"] = payload["timestamp"] || item["timestamp"]
        session["cwd"] = payload["cwd"]
        session["originator"] = payload["originator"]
      when "event_msg"
        session["compactions"] += 1 if payload["type"].to_s.include?("compact")
      when "response_item"
        consume_response(payload, session)
      end
    end

    def consume_response(payload, session)
      case payload["type"]
      when "message"
        text = content_text(payload["content"])
        if payload["role"] == "user" && substantive_user_text?(text)
          session["user_turns"] += 1
          session["user_texts"] << text
        elsif payload["role"] == "assistant" && payload["phase"] == "final_answer"
          session["assistant_final_answers"] += 1
          session["final_text"] = [session["final_text"], text].reject(&:empty?).join(" ")
        end
      when "function_call", "custom_tool_call"
        session["tool_calls"] += 1
        session["call_fragments"] << payload["name"].to_s
        session["call_fragments"] << (payload["arguments"] || payload["input"]).to_s
      when "custom_tool_call_output", "function_call_output"
        session["tool_failures"] += 1 if failed_tool_output?(payload)
      end
    end

    def failed_tool_output?(payload)
      return true if payload["is_error"] == true || payload["isError"] == true

      output = nested_text(payload["output"])
      output.match?(/\A\s*(?:Script failed|Process exited with code [1-9]\d*|Tool call failed|Error executing)/i)
    end

    def nested_text(value)
      case value
      when Hash
        value.values.map { |entry| nested_text(entry) }.join(" ")
      when Array
        value.map { |entry| nested_text(entry) }.join(" ")
      else
        value.to_s
      end
    end

    def content_text(content)
      Array(content).map do |part|
        part.is_a?(Hash) ? (part["text"] || part["input_text"] || part["output_text"] || "") : part.to_s
      end.join(" ").gsub(/\s+/, " ").strip
    end

    def substantive_user_text?(text)
      !text.empty? && SYNTHETIC_USER_PREFIXES.none? { |prefix| text.start_with?(prefix) }
    end

    def substantive_session?(session)
      return false if session["session_id"].to_s.empty? || session["started_at"].to_s.empty?
      return false unless within_workspace?(session["cwd"])
      return false if session["user_turns"].zero?
      return false unless Time.parse(session["started_at"]) >= @since_time
      return false if !@include_current && session["session_id"] == @current_session_id

      true
    rescue ArgumentError
      @parse_errors += 1
      false
    end

    def within_workspace?(cwd)
      value = Pathname.new(cwd.to_s).expand_path.cleanpath.to_s
      value == @workspace || value.start_with?("#{@workspace}/")
    end

    def classify!(session)
      calls = session.fetch("call_fragments").join("\n")
      user_text = session.fetch("user_texts").join("\n")
      final = session.fetch("final_text")

      controls = {
        "handoff" => calls.match?(/capture_handoff\.rb|task[-_]handoff|handoff.{0,80}(?:artifact|checkpoint)/im)
      }
      activity = {
        "source_write" => calls.match?(/(?:tools\.)?apply_patch|\bdart\s+format\b|\bprettier\b.{0,40}--write|\brubocop\b.{0,20}-A/m),
        "git_write" => calls.match?(/\bgit\s+(?:commit|push|merge|cherry-pick|rebase|tag)\b/m),
        "build_or_test" => calls.match?(/\bflutter\s+(?:analyze|test|build|run)\b|\bmvn(?:w)?\b|\bgradle(?:w)?\b|\bnpm\b.{0,60}\b(?:test|build|lint)\b/m),
        "external_action" => calls.match?(/\bgit\s+push\b|\bgh\s+workflow\s+run\b|\bdeploy\b|\bupload\b|\bxcrun\b.{0,80}\b(?:upload|altool|notarytool)\b|\b(?:ALTER|INSERT|UPDATE|DELETE|DROP|TRUNCATE)\b/m),
        "user_visible_scope" => user_text.match?(/Flutter|iOS|Android|Electron|Windows|UI|页面|界面|视频|直播间|下载|按钮|前端|用户可见/i)
      }
      evidence = {
        "implementation" => final.match?(/PASS|通过|test|测试|lint|analy[sz]e|build|构建|commit|提交|SHA|diff/i),
        "runtime" => final.match?(/部署|deployed|runtime|运行|健康|health|日志|log|API|数据库|database|DB|image|镜像|TestFlight|实测|\bTEST\b|PREONLINE/i),
        "user_visible" => final.match?(/用户可见|页面|界面|截图|真机|模拟器|按钮|下载|播放|显示|行为验证|business probe/i),
        "gap_disclosed" => final.match?(/未执行|未验证|缺口|尚未|仍需|NOT RUN|FAIL|pending|风险|无法/i)
      }
      session["repeat_repair_signal"] = user_text.match?(/刚改过|还是|仍然|又不行|又失败|还在|没有修好|没修好|测试说/i)

      findings = []
      findings << "missing_handoff" if session["compactions"].positive? && !controls["handoff"]
      findings << "missing_final_answer" if session["assistant_final_answers"].zero?
      findings << "missing_implementation_evidence" if activity["source_write"] && !evidence["implementation"]
      findings << "external_without_runtime_evidence" if activity["external_action"] && !evidence["runtime"]
      if activity["source_write"] && activity["user_visible_scope"] && !evidence["user_visible"]
        findings << "visible_scope_without_visible_evidence"
      end

      session["controls"] = controls
      session["activity"] = activity
      session["evidence_signals"] = evidence
      session["findings"] = findings
    end

    def summarize(sessions, findings)
      compacted = sessions.select { |session| session["compactions"].positive? }
      external = sessions.select { |session| session.dig("activity", "external_action") }
      visible = sessions.select { |session| session.dig("activity", "user_visible_scope") && session.dig("activity", "source_write") }

      {
        "sessions" => sessions.length,
        "user_turns" => sessions.sum { |session| session["user_turns"] },
        "assistant_final_answers" => sessions.sum { |session| session["assistant_final_answers"] },
        "compactions" => sessions.sum { |session| session["compactions"] },
        "tool_calls" => sessions.sum { |session| session["tool_calls"] },
        "tool_failures" => sessions.sum { |session| session["tool_failures"] },
        "repeat_repair_signal_sessions" => sessions.count { |session| session["repeat_repair_signal"] },
        "parse_errors" => @parse_errors,
        "findings" => findings.length,
        "compacted_sessions" => compacted.length,
        "compacted_with_handoff" => compacted.count { |session| session.dig("controls", "handoff") },
        "external_action_sessions" => external.length,
        "external_with_runtime_evidence" => external.count { |session| session.dig("evidence_signals", "runtime") },
        "visible_write_sessions" => visible.length,
        "visible_with_visible_evidence" => visible.count { |session| session.dig("evidence_signals", "user_visible") }
      }
    end
  end

  class CLI
    def initialize(argv, out: $stdout, err: $stderr, now: Time.now)
      @argv = argv
      @out = out
      @err = err
      @now = now
      @options = {
        workspace: Dir.pwd,
        sessions_root: ENV.fetch("CODEX_SESSIONS_ROOT", File.expand_path("~/.codex/sessions")),
        days: 7,
        json: false,
        strict: false,
        include_current: false,
        output_dir: nil
      }
    end

    def run
      parser.parse!(@argv)
      return print_help if @options[:help]

      report = Analyzer.new(
        workspace: @options[:workspace],
        sessions_root: @options[:sessions_root],
        since_time: since_time,
        current_session_id: ENV["CODEX_THREAD_ID"],
        include_current: @options[:include_current],
        now: @now
      ).analyze
      write_report(report, @options[:output_dir]) if @options[:output_dir]
      @options[:json] ? @out.puts(JSON.pretty_generate(report)) : print_text(report)
      @options[:strict] && report.dig("summary", "findings").positive? ? 1 : 0
    rescue OptionParser::ParseError, ArgumentError => e
      @err.puts(e.message)
      @err.puts(parser)
      2
    end

    private

    def parser
      @parser ||= OptionParser.new do |options|
        options.banner = "Usage: #{File.basename($PROGRAM_NAME)} [options]"
        options.on("--workspace PATH", "Workspace root to match against session cwd") { |value| @options[:workspace] = value }
        options.on("--sessions-root PATH", "Codex sessions directory") { |value| @options[:sessions_root] = value }
        options.on("--days N", Integer, "Look back N rolling days (default: 7)") { |value| @options[:days] = value }
        options.on("--since DATE", "Use a local YYYY-MM-DD start date") { |value| @options[:since] = value }
        options.on("--include-current", "Include CODEX_THREAD_ID in the report") { @options[:include_current] = true }
        options.on("--output-dir PATH", "Write harness-scorecard.json and .md without prompt text") { |value| @options[:output_dir] = value }
        options.on("--json", "Emit JSON") { @options[:json] = true }
        options.on("--strict", "Exit 1 when findings exist") { @options[:strict] = true }
        options.on("-h", "--help", "Show this help") { @options[:help] = true }
      end
    end

    def since_time
      if @options[:since]
        date = Date.iso8601(@options[:since])
        Time.new(date.year, date.month, date.day, 0, 0, 0, @now.getlocal.utc_offset)
      else
        raise ArgumentError, "--days must be positive" unless @options[:days].positive?

        @now - (@options[:days] * 86_400)
      end
    rescue Date::Error
      raise ArgumentError, "--since must use YYYY-MM-DD"
    end

    def print_help
      @out.puts(parser)
      0
    end

    def write_report(report, output_dir)
      directory = Pathname.new(output_dir).expand_path
      FileUtils.mkdir_p(directory)
      write_atomic(directory / "harness-scorecard.json", JSON.pretty_generate(report) + "\n")
      write_atomic(directory / "harness-scorecard.md", markdown_report(report))
    end

    def write_atomic(path, content)
      temporary = Pathname.new("#{path}.tmp-#{Process.pid}")
      temporary.write(content)
      File.rename(temporary, path)
    ensure
      temporary.delete if defined?(temporary) && temporary.exist?
    end

    def markdown_report(report)
      summary = report.fetch("summary")
      <<~MARKDOWN
        # Codex session retrospective scorecard

        Generated: #{report.fetch('generated_at')}
        Window starts: #{report.fetch('since')}
        Prompt text emitted: no

        | Signal | Count |
        |---|---:|
        | Substantive sessions | #{summary.fetch('sessions')} |
        | User turns | #{summary.fetch('user_turns')} |
        | Assistant final answers | #{summary.fetch('assistant_final_answers')} |
        | Context compactions | #{summary.fetch('compactions')} |
        | Tool calls | #{summary.fetch('tool_calls')} |
        | Tool failures | #{summary.fetch('tool_failures')} |
        | Repeat-repair cue sessions | #{summary.fetch('repeat_repair_signal_sessions')} |
        | Findings | #{summary.fetch('findings')} |

        These are workflow signals, not proof that a product outcome was correct. Compare the same
        fixed time window across review periods and inspect representative evidence before acting.
      MARKDOWN
    end

    def print_text(report)
      summary = report.fetch("summary")
      @out.puts("Codex session retrospective")
      @out.puts("Since: #{report.fetch('since')}")
      @out.puts("Sessions: #{summary.fetch('sessions')}; user turns: #{summary.fetch('user_turns')}; compactions: #{summary.fetch('compactions')}")
      @out.puts("Tool calls: #{summary.fetch('tool_calls')}; failures: #{summary.fetch('tool_failures')}; repeat-repair signals: #{summary.fetch('repeat_repair_signal_sessions')}")
      @out.puts("Handoff: #{summary.fetch('compacted_with_handoff')}/#{summary.fetch('compacted_sessions')} compacted sessions")
      @out.puts("Runtime evidence: #{summary.fetch('external_with_runtime_evidence')}/#{summary.fetch('external_action_sessions')} external-action sessions")
      @out.puts("User-visible evidence: #{summary.fetch('visible_with_visible_evidence')}/#{summary.fetch('visible_write_sessions')} visible-write sessions")
      @out.puts("Findings: #{summary.fetch('findings')}; parse errors: #{summary.fetch('parse_errors')}")
      report.fetch("findings").each do |finding|
        @out.puts("- #{finding.fetch('started_at')} #{finding.fetch('session_id')} #{finding.fetch('code')}")
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  exit CodexSessionRetrospective::CLI.new(ARGV).run
end
