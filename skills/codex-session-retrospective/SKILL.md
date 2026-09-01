---
name: codex-session-retrospective
description: Review recent Codex session logs for repeated repair loops, missing handoffs, weak validation, and evidence gaps. Use for weekly agent-workflow retrospectives, prompt or instruction improvement, and privacy-preserving scorecards across one workspace; do not use it as proof that product behavior is correct.
---

# Codex Session Retrospective

Turn recent Codex session history into a prompt-safe workflow scorecard and a small set of durable improvements.

## Boundaries

- Treat the analyzer's classifications as heuristics, not product or runtime proof.
- Never emit user prompts, tool arguments, secrets, or source snippets in the scorecard.
- The report retains workspace and session-file metadata for investigation; review it before sharing.
- Keep review read-only unless the user separately authorizes instruction, skill, or repository changes.
- Compare representative findings with current Git, test, runtime, or deployment evidence before recommending a change.

## Run the analyzer

Requires Ruby 2.6 or newer and only the standard library.

```bash
ruby scripts/analyze_sessions.rb --workspace "$PWD" --days 7 --json
```

Useful options:

- `--since YYYY-MM-DD` selects a fixed local start date.
- `--sessions-root PATH` overrides `~/.codex/sessions`.
- `--output-dir PATH` writes prompt-safe JSON and Markdown scorecards.
- `--strict` exits with status 1 when heuristic findings exist.
- `--include-current` includes the active `CODEX_THREAD_ID`; omit it for stable reviews.

## Review workflow

1. Fix the workspace, time window, and timezone before comparing review periods.
2. Run the analyzer and record parse errors, excluded current-session behavior, and sampling limits.
3. Inspect representative sessions for the highest-frequency findings without copying prompt text into durable artifacts.
4. Cross-check repository state, final answers, tests, runtime evidence, and external target evidence as applicable.
5. Separate workflow friction from product defects and from harmless variance.
6. Recommend the smallest durable intervention: clarify instructions, improve a reusable skill, add a deterministic helper, or leave the system unchanged.
7. Re-run the same fixed-window scorecard after changes and report what the comparison does and does not prove.

## Output contract

Report:

- exact time window and workspace;
- session, turn, compaction, tool-call, and tool-failure counts;
- repeat-repair cues and evidence-gap findings;
- representative evidence checked outside the heuristic scorecard;
- changes made, if authorized;
- remaining gaps and the next review condition.
