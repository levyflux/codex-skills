# Codex Skills

A curated collection of reusable agent skills developed from real product delivery, agent-workflow,
market-analysis, and smart-contract work. The collection focuses on evidence quality, explicit
boundaries, and observable validation rather than generic prompt templates.

These skills follow the open Agent Skills directory format used by Codex: each skill has a required
`SKILL.md` plus optional `references/`, `scripts/`, and `agents/openai.yaml` resources.

## Included skills

| Skill | Purpose | Side-effect boundary |
| --- | --- | --- |
| [`ui-expert`](skills/ui-expert/) | General product-design, UI implementation, accessibility, responsiveness, and browser validation | May edit the requested project; does not deploy by implication |
| [`polish-ui`](skills/polish-ui/) | Reference-driven art direction and screenshot-based visual refinement | May edit the requested UI; does not invent product policy |
| [`binance-major-crypto-trend`](skills/binance-major-crypto-trend/) | Current multi-horizon analysis of liquid Binance-listed major crypto assets | Analysis only; never trades |
| [`new-token-risk-analysis`](skills/new-token-risk-analysis/) | Evidence-backed risk analysis for launchpad, meme, and newly launched tokens | Read only; never trades |
| [`auto-token-trade-safety-gate`](skills/auto-token-trade-safety-gate/) | Fail-closed admission gate for a fully specified automated token trade | Emits `PASS` or `BLOCK`; never signs or broadcasts |
| [`vrf-consumer-audit`](skills/vrf-consumer-audit/) | Security review of EVM VRF consumer state machines | Review only unless fixes or tests are explicitly requested |
| [`codex-session-retrospective`](skills/codex-session-retrospective/) | Prompt-text-free review of recent Codex sessions and workflow evidence gaps | Read only unless instruction or skill changes are separately authorized |
| [`durable-task-handoff`](skills/durable-task-handoff/) | Atomic, prompt-safe checkpoints for reliable multi-repository task resumption | Inspects Git state only; never commits, pushes, or changes branches |
| [`prd-delivery-lifecycle`](skills/prd-delivery-lifecycle/) | Traceable requirement definition, implementation, acceptance, and release readiness | Does not imply commit, merge, deploy, or release authority |
| [`flutter-flow-audit`](skills/flutter-flow-audit/) | Cross-screen Flutter state, lifecycle, async, and callback auditing | Static audit by default; runtime behavior requires separate evidence |
| [`release-sql-gate`](skills/release-sql-gate/) | Deterministic changed-SQL inventory, ordering, hashing, and risk flags | Never connects to a database or executes SQL |

`ui-expert` owns ordinary UI implementation. Use `polish-ui` when the request specifically calls for
art direction, visual distinctiveness, reference matching, or an intensive visual-polish pass.

## Install

Ask Codex's built-in installer to install one skill from this repository, for example:

```text
$skill-installer install https://github.com/levyflux/codex-skills/tree/main/skills/ui-expert
```

Or clone the repository and copy selected skill folders into your user skill directory:

```bash
git clone https://github.com/levyflux/codex-skills.git
mkdir -p "$HOME/.agents/skills"
cp -R codex-skills/skills/ui-expert "$HOME/.agents/skills/"
```

Codex detects local skill changes automatically. Restart Codex if a newly installed skill does not
appear. Invoke a skill explicitly with `$skill-name`, or let Codex select it from the `description`.

## Requirements and optional providers

Most skills are instruction-only and adapt to the tools available in the host environment. The VRF
audit includes a Python standard-library scanner and regression test. Session retrospective, task
handoff, and SQL release gate helpers use Ruby 2.6 or newer with only the standard library.

The crypto skills do not require a particular vendor. They may use an installed market-data,
wallet-security, browser, chain-RPC, or protocol capability when available. Missing, stale, or
contradictory evidence remains a reported gap; the automated trade gate fails closed.

## Validation

Before release, every skill is checked with Codex's `quick_validate.py`. Scripted resources also run
their own regression tests. These checks validate structure and deterministic helpers; they do not
replace current market, chain, runtime, browser, or deployment evidence required by an actual task.

## Scope and provenance

This repository contains only general-purpose skills curated by LevyFlux with Codex. It includes
methods generalized from real workflows while excluding private product-specific instructions,
machine-installed third-party skill catalogs, credentials, local paths, deployment values, and
product-specific policy.

Contributions should keep each skill focused, preserve authorization boundaries, avoid invented
thresholds or policy, and distinguish static evidence from runtime or external-system evidence.

## License

[MIT](LICENSE) © 2026 LevyFlux
