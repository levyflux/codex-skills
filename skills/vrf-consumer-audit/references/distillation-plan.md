# Data distillation plan

The goal is not to collect the most VRF text. It is to produce versioned claims, root-cause cases,
paired code fixtures, and holdout evaluations that change audit decisions without importing folklore.

## Corpus layers

### A. Protocol truth

Collect official specifications/docs, tagged contract source, interfaces, mocks, release/migration notes,
and supported-network configuration. Extract one atomic claim per record with:

```yaml
claim_id: chainlink-v2_5-callback-no-retry
provider: chainlink
version_range: "resolved from tagged source/docs"
mode: subscription
claim: "consumer callback is not automatically retried after revert"
source_url: "official URL"
source_revision: "tag or commit when available"
accessed_at: "ISO-8601"
evidence_excerpt_hash: "sha256 of retained source excerpt"
audit_consequence: "prove callback is non-reverting or has a same-entropy recovery path"
invalidation_trigger: "provider release, interface change, or docs change"
```

Keep current addresses, key hashes, gas ceilings, premiums, and network limits as live lookups, not
embedded durable knowledge.

### B. Real finding and incident cases

Prefer primary audit reports, contest findings with code commits, verified exploit transactions, and
project/provider postmortems. A case is admissible only when vulnerable code/revision, causal path, and
impact can be reconstructed. Store license/provenance and redact secrets.

```yaml
case_id: vrf-request-overwrite-001
source_kind: audit-report
provider_version: "..."
application: raffle
code_revision: "..."
root_cause: request-business binding overwrite
preconditions: []
attacker_control: []
transition_trace: []
violated_invariants: [I1, I3]
impact: "..."
finding_status: confirmed
proof_artifact: "test path or transaction"
fix_pattern: "..."
negative_control: "paired secure fixture"
license_and_source: "..."
```

Deduplicate by root cause and transition trace, not title. Ten reports repeating the same global
`lastRequestId` bug are one family, not ten independent lessons.

### C. Paired executable fixtures

For every promoted root-cause family, create a minimal vulnerable Foundry fixture, an attack/regression
test, and a minimally fixed counterpart. Include realistic near-miss controls that contain suspicious
keywords but preserve the invariant. Pin compiler/provider dependency and record expected finding,
severity inputs, and evidence status.

Synthetic fixtures teach reachability; they must not be presented as real incidents. Real cases should
retain enough surrounding state and authority context to prevent oversimplified pattern matching.

### D. Operational and economic cases

Add callback-gas measurements, concurrency/funding failure simulations, coordinator migration with
in-flight requests, chain/finality assumptions, and deployment/config snapshots. Keep snapshots dated
and separate source/static evidence from live runtime evidence.

### E. Trigger and reporting evaluations

Include positive prompts (security review, VRF-specific tests, reroll diagnosis) and hard negatives
(ordinary integration, generic PRNG explanation, non-EVM provider without docs). Evaluate whether the
skill requests missing policy/config evidence instead of inventing values.

Start from [eval-cases.md](eval-cases.md), then keep new project/root-cause families in a holdout set until
after the corresponding Skill change is proposed.

## Coverage seed

Start with at least one vulnerable/fixed/near-miss triplet for each family:

1. global request ID overwrite and cross-round callback;
2. request ID truncation/default-sentinel alias;
3. out-of-order concurrent fulfillment;
4. retry/cancel/selective reroll and late callback;
5. post-request participant/weight/prize mutation;
6. callback external-call, gas, loop, and receiver-hook failure;
7. deferred settlement manipulation, double consumption, and blocked recipient;
8. wrong/live bound, zero bound, duplicate winners, entropy-domain reuse, and quantified modulo bias;
9. coordinator/wrapper spoofing, migration, proxy initialization, and pending-request upgrade;
10. subscription/direct-funding availability, authorization, and recovery;
11. cross-provider request-ID collision and pre-binding synchronous callback/reentrancy.

Do not set a final corpus size before measuring marginal coverage. A practical first evaluation can use
20–30 root-cause fixtures plus secure controls, then expand only where holdout failures reveal a distinct
decision gap.

The initial primary-source examples in [case-seeds.md](case-seeds.md) demonstrate the required level of
context and caveat. They are seeds, not a representative or complete vulnerability dataset.

## Distillation pipeline

1. **Acquire** sources with revision, date, license, and stable URL.
2. **Normalize** provider/version/mode, business commitment, roles, assets, and state transitions.
3. **Verify** every causal claim against code, test, trace, or primary report; quarantine blog-only lore.
4. **Cluster** by violated invariant and transition trace; retain the clearest representative plus variants
   that change exploitability.
5. **Distill** an audit question, proof recipe, secure counterexample, and explicit non-finding condition.
6. **Execute** paired fixtures and retain test output/toolchain revision.
7. **Split** train/reference and holdout sets by project and root-cause family, not random files, to avoid
   near-duplicate leakage.
8. **Evaluate** trigger precision, provider/version accuracy, root-cause recall, false positives on secure
   controls, evidence completeness, severity calibration, and unsupported-claim rate.
9. **Promote** only rules that improve holdout decisions. Put provider-specific facts in adapters and keep
   the main skill invariant-focused.
10. **Refresh** volatile protocol/config claims on release triggers; retire stale cards instead of stacking
    contradictory rules.

## Quality gates

- No finding card without source provenance and a reconstructable violated invariant.
- No severity label without value, control, reachability, blast radius, and recovery inputs.
- No regex-only expected answer; evals score behavior and evidence.
- Every vulnerability family has a secure near-miss to measure false positives.
- Every provider claim has a version/mode scope and invalidation trigger.
- Generated tests compile and demonstrate the vulnerable behavior before the fix and fail to reproduce it
  after the fix.
- Human review is required before promoting incident-derived rules or changing automatic trigger scope.
