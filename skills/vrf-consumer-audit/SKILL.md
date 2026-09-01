---
name: vrf-consumer-audit
description: Audit EVM contracts that request, receive, and consume verifiable randomness. Use for VRF security reviews, raffle/game/NFT randomness state machines, request-to-business binding, callback and reroll analysis, randomness mapping, or VRF-focused Foundry tests. Do not use for ordinary VRF integration or setup unless security review is also requested.
---

# VRF Consumer Audit

Audit the consumer's asynchronous application state machine, not only the provider's proof. A valid
VRF proof does not establish correct request binding, frozen inputs, unbiased consumption, callback
liveness, or fair recovery.

## Boundaries

- Apply the invariant workflow to EVM consumers. Recognize Chainlink V1, V2, and V2.5, but make
  definitive provider-specific claims only from the resolved version's source and documentation.
- Do not audit the provider's cryptography or coordinator implementation unless they are explicitly
  in scope. Do audit every trust assumption the consumer makes about them.
- Review-only requests authorize read-only inspection and running existing tests, not repository edits,
  fixes, deployments, funding, subscription changes, signing, or broadcasts. Build a disposable PoC in
  a temporary directory when useful; add project tests only when the user requests a change or tests.
- A scanner or checklist is only a surface map. Never claim safety without tracing current source and
  testing the relevant state transitions.

## Required workflow

1. Establish the exact repository/ref, scoped contracts, chain, deployed or source-only boundary,
   assets/value at risk, trusted roles, upgradeability, and intended fairness/liveness policy. Inspect
   repository rules, branch/HEAD, and dirty state before edits or tests.
2. Identify the provider, version, funding mode, resolved dependency revision, consumer base,
   coordinator/wrapper source, and deployment configuration. Prefer the package lock and resolved
   dependency source over import-path guesses. Use
   [references/provider-evidence-gate.md](references/provider-evidence-gate.md) for an unfamiliar,
   non-Chainlink, or multi-provider design. For Chainlink, read
   [references/chainlink.md](references/chainlink.md).
3. Run `scripts/scan_vrf_surface.py <scope...>` or equivalent `rg` queries. Reopen every reported
   function in source; do not treat a name match as a finding. A nonzero scanner exit, any
   `input_errors`, or zero scanned files means the requested scope was not mapped and must not be
   reported as a clean scan.
4. Reconstruct the complete flow and exceptions:

   ```text
   accept inputs -> close/snapshot -> request call [revert or provider reentry]
     -> request reverted: restore/retain a valid pre-request state
     -> request accepted: bind provider-namespaced request key -> pending
     -> fulfill(request key, words) -> consume/settle/claim -> terminal
     -> timeout/pause/cancel/refund/migrate/upgrade/recover
   ```

   Record function, caller, pre-state, post-state, external calls, affected business object, and
   whether participants, weights, prize, ordering, or accepted entropy can change. Use
   [references/audit-workpad.md](references/audit-workpad.md) when the scope has multiple commitments,
   providers, callbacks, or recovery paths.
5. Prove or falsify the invariants in [references/invariants-and-findings.md](references/invariants-and-findings.md).
   Trace all request entrypoints, callbacks, settlement/claim paths, retries, cancellations, refunds,
   config setters, coordinator migrations, proxy upgrades, and emergency actions.
6. Convert each plausible issue into an executable transition sequence. Read
   [references/test-catalog.md](references/test-catalog.md) for the relevant cases. Prefer Foundry
   example tests, fuzz tests, and stateful invariants over prose-only conclusions. Respect the review-only
   boundary above when deciding whether to run, generate temporarily, or add those tests.
7. Report each hypothesis as `confirmed`, `conditional`, `defense-in-depth`, `false positive`, or
   `unresolved`. A confirmed finding needs code evidence, reachable preconditions, violated invariant,
   user/economic impact, and a test or reproducible trace when practical.

## Fail-closed review rules

- Treat every `requestId` as `uint256` unless the actual provider interface proves otherwise. Flag
  narrowing casts or storage because truncation can break uniqueness and binding. Unless global
  uniqueness is established, bind callbacks by a composite provider/coordinator/version namespace and
  request ID or sequence. Equal numeric IDs from two providers must remain distinct request records even
  when both intentionally contribute to the same multi-source commitment.
- Never assume fulfillments arrive in request order. Test multiple in-flight requests in both orders.
- Never accept a replacement request, cancellation, or timeout redraw as harmless. For a single-source
  commitment, determine which request remains valid. For an intentional multi-source design, prove the
  source/request set and combination rule were fixed before any result became observable and no party
  can select a favorable subset.
- Freeze or snapshot every outcome-affecting input before the request. Check indirect mutation through
  transfers, weight/oracle updates, admin edits, list compaction, upgrades, and cross-contract state.
- Treat request and fulfillment transactions, callback arguments, and derived results as publicly
  observable before downstream settlement is final. Test profitable front-running, suppression,
  reordering, and cancellation paths; do not rely on callback data remaining secret within the mempool.
- Authenticate the callback against the resolved provider base. Review overrides of raw fulfillment,
  coordinator/wrapper mutability, proxy initialization, and coordinator changes with requests in flight.
- Establish callback timing from the resolved provider. If a separate-transaction guarantee is absent,
  test a provider/router that calls back synchronously before the request call returns its identifier;
  authentication alone does not prevent this request-binding reentrancy.
- Match callback behavior to verified provider delivery semantics. For a non-retrying provider such as
  current Chainlink VRF, the callback must fit its configured gas and avoid reachable reverts. For a
  retrying provider, prove idempotence, retry bounds, and eventual progress. Minimal store-and-emit
  callbacks are often safer for liveness, but deferred settlement must also be immutable, permissionless
  or reliably operated, exactly-once, and unable to select among later randomness.
- Do not label `randomWord % n` exploitable merely because a mathematical bias exists. Quantify the
  distribution delta, attacker influence, repetitions, and value impact. Prioritize mutable/zero `n`,
  wrong snapshots, truncation, duplicate selection, domain reuse, and rejection-loop liveness.
- Treat fallback randomness, provider swaps, and mixed-source designs as separate security modes. Hashing
  a weak or influenceable value with other values does not create the missing entropy, and casting an
  encoded byte string to `bytes32` may truncate rather than hash it. Prove the exact encoding, combination,
  fallback trigger, pending-request behavior, and attacker control.
- Do not prescribe a universal confirmation count, callback gas limit, timeout, or funding threshold.
  Compare the actual configuration with current provider/network bounds, measured callback gas,
  chain reorg assumptions, concurrency, and value at risk.
- Provider mocks prove consumer transitions, not oracle availability, live billing, real coordinator
  configuration, chain reorg economics, or deployed wiring. State those evidence gaps explicitly.
- Trace who can trigger paid requests and at what rate. A correctly authorized consumer contract can
  still expose a public spam path that drains its subscription/prepaid balance or fills pending state.

## Deliverable

Lead with scope and evidence level. Include:

1. provider/version/dependency/deployment map;
2. request-to-business and state-transition map;
3. findings ordered by impact, each with evidence status and exploit sequence;
4. invariant/test matrix with passed, failed, and untested cases;
5. unresolved provider, runtime, configuration, or chain assumptions;
6. smallest safe remediation direction without silently changing product policy.

For building or evolving the audit corpus itself, read
[references/distillation-plan.md](references/distillation-plan.md). Do not bake volatile addresses,
network limits, or unsupported incident claims into this skill.
