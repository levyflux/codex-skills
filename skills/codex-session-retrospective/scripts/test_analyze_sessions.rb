#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "fileutils"
require "minitest/autorun"
require "stringio"
require "tmpdir"

require_relative "analyze_sessions"

class CodexSessionRetrospectiveTest < Minitest::Test
  def setup
    @temporary = Dir.mktmpdir("codex-session-retrospective")
    @sessions_root = File.join(@temporary, "sessions")
    @workspace = File.join(@temporary, "workspace")
    Dir.mkdir(@sessions_root)
    Dir.mkdir(@workspace)
  end

  def teardown
    FileUtils.remove_entry(@temporary)
  end

  def test_detects_missing_controls_without_emitting_prompts
    write_session(
      "missing-controls",
      cwd: @workspace,
      events: [
        session_message("user", "# AGENTS.md instructions synthetic"),
        session_message("user", "修复页面并部署，secret-token-123"),
        { "type" => "event_msg", "payload" => { "type" => "context_compacted" } },
        function_call("functions.exec", "await tools.apply_patch('patch'); await tools.exec_command({cmd: 'git push origin main'})"),
        tool_output("Script failed\nProcess exited with code 1"),
        session_message("assistant", "测试通过并提交。", phase: "final_answer")
      ]
    )

    report = analyzer.analyze
    session = report.fetch("sessions").first

    assert_equal 1, report.dig("summary", "sessions")
    assert_equal 1, session.fetch("user_turns")
    assert_includes session.fetch("findings"), "missing_handoff"
    assert_includes session.fetch("findings"), "external_without_runtime_evidence"
    assert_includes session.fetch("findings"), "visible_scope_without_visible_evidence"
    assert_equal 1, session.fetch("tool_calls")
    assert_equal 1, session.fetch("tool_failures")
    refute_includes JSON.generate(report), "secret-token-123"
  end

  def test_recognizes_controls_and_three_evidence_classes
    write_session(
      "compliant",
      cwd: @workspace,
      events: [
        session_message("user", "Flutter 页面修复并发测试"),
        { "type" => "event_msg", "payload" => { "type" => "context_compacted" } },
        function_call(
          "functions.exec",
          "ruby scripts/capture_handoff.rb --repository app; " \
          "tools.apply_patch('patch'); git push origin alpha"
        ),
        session_message("assistant", "测试 PASS，运行日志正常，真机页面显示正确。", phase: "final_answer")
      ]
    )

    session = analyzer.analyze.fetch("sessions").first

    assert_empty session.fetch("findings")
    assert session.dig("controls", "handoff")
    assert session.dig("evidence_signals", "implementation")
    assert session.dig("evidence_signals", "runtime")
    assert session.dig("evidence_signals", "user_visible")
  end

  def test_aggregates_evidence_across_multiple_final_answers
    write_session(
      "multiple-finals",
      cwd: @workspace,
      events: [
        session_message("user", "修复 Flutter 页面"),
        function_call(
          "functions.exec",
          "tools.apply_patch('patch')"
        ),
        session_message("assistant", "测试通过，线上页面正常显示。", phase: "final_answer"),
        session_message("user", "再检查 RPC 节点"),
        session_message("assistant", "节点实测健康。", phase: "final_answer")
      ]
    )

    session = analyzer.analyze.fetch("sessions").first

    assert_equal 2, session.fetch("assistant_final_answers")
    assert session.dig("evidence_signals", "user_visible")
    refute_includes session.fetch("findings"), "visible_scope_without_visible_evidence"
  end

  def test_filters_other_workspaces_and_active_session
    write_session("outside", cwd: File.join(@temporary, "other"), events: [session_message("user", "real request")])
    write_session("active", cwd: @workspace, events: [session_message("user", "real request")])

    report = CodexSessionRetrospective::Analyzer.new(
      workspace: @workspace,
      sessions_root: @sessions_root,
      since_time: Time.at(0),
      current_session_id: "active",
      now: Time.utc(2026, 8, 2)
    ).analyze

    assert_equal 0, report.dig("summary", "sessions")
  end

  def test_cli_strict_returns_one_for_findings
    write_session(
      "strict",
      cwd: @workspace,
      events: [session_message("user", "real request")]
    )
    output = StringIO.new
    error = StringIO.new
    cli = CodexSessionRetrospective::CLI.new(
      ["--workspace", @workspace, "--sessions-root", @sessions_root, "--since", "2026-01-01", "--strict"],
      out: output,
      err: error,
      now: Time.utc(2026, 8, 2)
    )

    assert_equal 1, cli.run
    assert_empty error.string
    assert_includes output.string, "missing_final_answer"
  end

  def test_cli_writes_prompt_safe_scorecard_files
    write_session(
      "scorecard",
      cwd: @workspace,
      events: [
        session_message("user", "还是没有修好 private-value-456"),
        function_call("functions.exec", "echo diagnostic"),
        tool_output("Script completed\nOutput: ok"),
        session_message("assistant", "检查完成。", phase: "final_answer")
      ]
    )
    output_dir = File.join(@temporary, "report")
    output = StringIO.new
    cli = CodexSessionRetrospective::CLI.new(
      ["--workspace", @workspace, "--sessions-root", @sessions_root, "--since", "2026-01-01", "--output-dir", output_dir, "--json"],
      out: output,
      now: Time.utc(2026, 8, 2)
    )

    assert_equal 0, cli.run
    report = JSON.parse(File.read(File.join(output_dir, "harness-scorecard.json")))
    markdown = File.read(File.join(output_dir, "harness-scorecard.md"))
    assert_equal 1, report.dig("summary", "tool_calls")
    assert_equal 0, report.dig("summary", "tool_failures")
    assert_equal 1, report.dig("summary", "repeat_repair_signal_sessions")
    refute_includes JSON.generate(report), "private-value-456"
    refute_includes markdown, "private-value-456"
  end

  private

  def analyzer
    CodexSessionRetrospective::Analyzer.new(
      workspace: @workspace,
      sessions_root: @sessions_root,
      since_time: Time.at(0),
      now: Time.utc(2026, 8, 2)
    )
  end

  def write_session(id, cwd:, events:)
    path = File.join(@sessions_root, "#{id}.jsonl")
    meta = {
      "timestamp" => "2026-07-30T00:00:00Z",
      "type" => "session_meta",
      "payload" => {
        "session_id" => id,
        "timestamp" => "2026-07-30T00:00:00Z",
        "cwd" => cwd,
        "originator" => "codex-tui"
      }
    }
    File.open(path, "w") do |file|
      ([meta] + events).each { |event| file.puts(JSON.generate(event)) }
    end
  end

  def session_message(role, text, phase: nil)
    payload = {
      "type" => "message",
      "role" => role,
      "content" => [{ "type" => "input_text", "text" => text }]
    }
    payload["phase"] = phase if phase
    { "type" => "response_item", "payload" => payload }
  end

  def function_call(name, arguments)
    {
      "type" => "response_item",
      "payload" => { "type" => "function_call", "name" => name, "arguments" => arguments }
    }
  end

  def tool_output(output)
    {
      "type" => "response_item",
      "payload" => { "type" => "custom_tool_call_output", "output" => output }
    }
  end
end
