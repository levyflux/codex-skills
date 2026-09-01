#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "minitest/autorun"
require "tmpdir"

require_relative "release_sql_manifest"

class ReleaseSqlManifestTest < Minitest::Test
  def setup
    @temporary = Dir.mktmpdir("release-sql-gate")
    @repository = File.join(@temporary, "repository")
    FileUtils.mkdir_p(@repository)
    git("init", "-q")
    git("config", "user.email", "test@example.com")
    git("config", "user.name", "Test User")
    File.write(File.join(@repository, "README.md"), "initial\n")
    git("add", "README.md")
    git("commit", "-qm", "base")
    @base = git_output("rev-parse", "HEAD").strip
    FileUtils.mkdir_p(File.join(@repository, "migrations"))
    File.write(File.join(@repository, "migrations", "001_create.sql"), "CREATE TABLE widgets (id BIGINT);\n")
    File.write(File.join(@repository, "migrations", "002_data.sql"), "--DROP TABLE ignored;\nINSERT INTO widgets VALUES (1);\n")
    File.write(File.join(@repository, "notes.txt"), "not sql\n")
    git("add", ".")
    git("commit", "-qm", "add sql")
    @head = git_output("rev-parse", "HEAD").strip
  end

  def teardown
    FileUtils.remove_entry(@temporary)
  end

  def test_inventories_changed_sql_with_hashes_and_risk_flags
    payload = manifest.build

    assert_equal 2, payload.fetch("sql_count")
    assert_equal "PASS", payload.dig("completeness", "status")
    assert_equal "NOT_PROVIDED", payload.dig("ordering", "status")
    assert_equal %w[migrations/001_create.sql migrations/002_data.sql], payload.fetch("files").map { |file| file.fetch("path") }
    assert_includes payload.dig("files", 0, "risk_flags"), "create"
    assert_includes payload.dig("files", 1, "risk_flags"), "dml"
    refute_includes payload.dig("files", 1, "risk_flags"), "destructive"
    assert_equal Digest::SHA256.hexdigest("CREATE TABLE widgets (id BIGINT);\n"), payload.dig("files", 0, "sha256")
    assert_equal "NOT_RUN", payload.dig("execution_gate", "status")
  end

  def test_applies_exact_order_file
    order_file = File.join(@temporary, "order.txt")
    File.write(order_file, "migrations/002_data.sql\nmigrations/001_create.sql\n")
    payload = ReleaseSqlManifest.new(
      repository: @repository,
      base_ref: @base,
      head_ref: @head,
      order_file: order_file,
      clock: -> { Time.utc(2026, 9, 1) }
    ).build

    assert_equal "PROVIDED_REVIEW_REQUIRED", payload.dig("ordering", "status")
    assert_equal %w[migrations/002_data.sql migrations/001_create.sql], payload.fetch("files").map { |file| file.fetch("path") }
    assert_match(/\A[0-9a-f]{64}\z/, payload.fetch("ordered_sql_sha256"))
  end

  def test_rejects_incomplete_order_file
    order_file = File.join(@temporary, "order.txt")
    File.write(order_file, "migrations/001_create.sql\n")

    error = assert_raises(ReleaseSqlManifest::Error) do
      ReleaseSqlManifest.new(repository: @repository, base_ref: @base, head_ref: @head, order_file: order_file).build
    end
    assert_includes error.message, "does not match SQL inventory"
  end

  def test_rejects_invalid_ref
    error = assert_raises(ReleaseSqlManifest::Error) do
      ReleaseSqlManifest.new(repository: @repository, base_ref: "missing-ref", head_ref: @head).build
    end
    assert_includes error.message, "failed"
  end

  private

  def manifest
    ReleaseSqlManifest.new(
      repository: @repository,
      base_ref: @base,
      head_ref: @head,
      clock: -> { Time.utc(2026, 9, 1) }
    )
  end

  def git(*arguments)
    assert system("git", "-C", @repository, *arguments), "git #{arguments.join(' ')} failed"
  end

  def git_output(*arguments)
    IO.popen(["git", "-C", @repository, *arguments], &:read)
  end
end
