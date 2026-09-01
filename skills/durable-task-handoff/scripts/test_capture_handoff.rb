#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "minitest/autorun"
require "stringio"
require "tmpdir"

require_relative "capture_handoff"

class DurableTaskHandoffTest < Minitest::Test
  def setup
    @temporary = Dir.mktmpdir("durable-task-handoff")
    @repository = File.join(@temporary, "repository")
    FileUtils.mkdir_p(@repository)
    git("init", "-q")
    git("config", "user.email", "test@example.com")
    git("config", "user.name", "Test User")
    File.write(File.join(@repository, "README.md"), "initial\n")
    git("add", "README.md")
    git("commit", "-qm", "initial")
  end

  def teardown
    FileUtils.remove_entry(@temporary)
  end

  def test_builds_clean_repository_snapshot
    payload = builder.build(
      objective: "Ship recovery flow",
      trigger: "phase-boundary",
      next_step: "Implement the client",
      repositories: [@repository],
      completed: ["API tests pass"],
      verification: ["unit: PASS"],
      constraints: ["No deployment"]
    )

    state = payload.fetch("repositories").first
    assert_equal "Ship recovery flow", payload.fetch("objective")
    assert_equal "phase-boundary", payload.fetch("trigger")
    assert_equal 40, state.fetch("head").length
    refute state.fetch("dirty")
    refute state.fetch("detached")
    assert_equal [], state.fetch("status_porcelain")
  end

  def test_records_dirty_files_without_source_contents
    File.write(File.join(@repository, "README.md"), "secret-value-should-not-appear\n")
    payload = builder.build(
      objective: "Continue work",
      trigger: "manual",
      next_step: "Review the diff",
      repositories: [@repository]
    )

    encoded = JSON.generate(payload)
    assert payload.dig("repositories", 0, "dirty")
    assert_includes encoded, "README.md"
    refute_includes encoded, "secret-value-should-not-appear"
  end

  def test_rejects_duplicate_repository_roots
    error = assert_raises(DurableTaskHandoff::Error) do
      builder.build(
        objective: "Continue work",
        trigger: "manual",
        next_step: "Review",
        repositories: [@repository, File.join(@repository, ".")]
      )
    end
    assert_includes error.message, "duplicate repositories"
  end

  def test_cli_writes_atomic_json_artifact
    output = StringIO.new
    error = StringIO.new
    output_dir = File.join(@temporary, "handoffs")
    status = run_cli(
      ["--objective", "Continue work", "--trigger", "task-transfer", "--repository", @repository,
       "--next-step", "Run integration tests", "--output-dir", output_dir],
      out: output,
      err: error,
      clock: -> { Time.utc(2026, 9, 1, 2, 3, 4) }
    )

    assert_equal 0, status
    assert_empty error.string
    result = JSON.parse(output.string)
    assert_equal "ok", result.fetch("status")
    artifact = JSON.parse(File.read(result.fetch("output")))
    assert_equal "task-transfer", artifact.fetch("trigger")
  end

  private

  def builder
    DurableTaskHandoff.new(clock: -> { Time.utc(2026, 9, 1) })
  end

  def git(*arguments)
    assert system("git", "-C", @repository, *arguments), "git #{arguments.join(' ')} failed"
  end
end
