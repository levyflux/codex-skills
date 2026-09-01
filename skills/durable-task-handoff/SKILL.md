---
name: durable-task-handoff
description: Capture a durable, prompt-safe checkpoint for a long-running coding task, including objective, completed work, repository Git state, validation, constraints, and exact next step. Use after context compaction, at a phase boundary, before a task transfer, or when work must resume reliably later.
---

# Durable Task Handoff

Preserve enough verified state for another session or maintainer to continue without reconstructing the task from chat history.

## Boundaries

- Do not put credentials, tokens, private prompt text, or raw command output in a handoff.
- Inspect repositories read-only. A handoff never commits, pushes, merges, deploys, or changes branches.
- Record uncertainty explicitly. Do not turn an assumption into a completed fact.
- Prefer repository-relative changed-file descriptions over copied source code.

## Capture a checkpoint

Requires Ruby 2.6 or newer and only the standard library.

```bash
ruby scripts/capture_handoff.rb \
  --objective "Finish the account recovery flow" \
  --trigger phase-boundary \
  --repository ./web \
  --repository ./api \
  --completed "API contract and targeted tests are complete" \
  --verification "api recovery tests: PASS" \
  --constraint "Do not deploy without explicit authorization" \
  --next-step "Wire the web form to the verified API contract"
```

The script writes an atomic JSON artifact under `.codex/checkpoints/handoffs/` by default and prints its path. Use `--output-dir` to choose another durable location.

## Required handoff content

1. State the current objective and why the checkpoint exists.
2. Describe completed work and unresolved decisions.
3. Include each repository's root, branch or detached state, HEAD, upstream, and dirty-file list.
4. Record fresh validation with exact scope and result.
5. State authorization and safety constraints.
6. Give one concrete next step that can be executed without rediscovery.

After resuming, re-check current repository state before acting; the artifact is a snapshot, not a lock.
