---
name: prd-delivery-lifecycle
description: Drive a product requirement from evidence-backed definition through implementation, verification, acceptance, and release readiness. Use for multi-step feature delivery, PRD authoring, requirement changes, feedback rounds, traceability, or cross-component work where decisions and evidence must remain coherent.
---

# PRD Delivery Lifecycle

Maintain one versioned delivery model across three connected loops:

1. **Define and authorize** — establish the problem, scope, decisions, contracts, risks, and acceptance evidence.
2. **Build and prove** — implement vertical slices with tests and layer-appropriate validation.
3. **Accept and prepare release** — reconcile feedback, close evidence gaps, and identify remaining authority gates.

Read [evidence-contract.md](references/evidence-contract.md) for evidence layers and [state-machine.md](references/state-machine.md) for feedback and invalidation rules.

## Start from authoritative evidence

Before editing:

- identify the requirement owner and authoritative source;
- separate facts, assumptions, policy choices, and unresolved questions;
- enumerate producers, consumers, states, failure paths, and compatibility surfaces;
- define explicit non-goals and authority boundaries;
- state which evidence will prove each acceptance criterion.

Reuse the repository's existing product-spec location. If none exists, create the smallest coherent feature record containing source, review, decisions, implementation plan, verification, and release notes.

## Maintain the trace graph

Keep durable identifiers and links for:

```text
REQ -> DEC -> CONTRACT -> TEST -> SLICE -> VERIFY -> RELEASE
```

Every implementation slice must trace back to a requirement and forward to verification. Every changed decision must identify which downstream nodes are stale.

## Execute in vertical slices

For each slice:

1. choose one user-observable or contract-observable outcome;
2. add or identify the failing test or reproducible evidence;
3. implement the smallest coherent change;
4. run targeted checks, then broader checks proportional to risk;
5. update trace links, evidence, and unresolved risks;
6. request acceptance only when the required evidence layer exists.

Do not equate static analysis with runtime behavior, a passing test with deployment, or deployment with user acceptance.

## Process feedback

Convert each feedback item into a packet containing the claim, evidence, impacted identifiers, classification, decision owner, and disposition. Invalidate only the affected downstream graph, then rerun the required checks. Never silently rewrite the requirement history.

## Completion contract

Report:

- behavior before and after;
- requirement-to-evidence trace status;
- changed components and their responsibilities;
- validation by layer and its limitations;
- unresolved decisions, risks, migrations, rollout, and rollback needs;
- exact authority still required for commit, push, merge, deploy, or release.
