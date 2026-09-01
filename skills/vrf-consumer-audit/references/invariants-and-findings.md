# Invariants and finding proof

## Threat actors to enumerate

- participant, beneficiary, winner, or recipient with controllable callback behavior;
- requester, round creator, operator, automation caller, or keeper controlling transaction timing;
- owner, subscription owner, config admin, pauser, upgrader, or coordinator-migration authority;
- coordinator/wrapper/provider and any separate randomness-source adapter;
- validator, sequencer, builder, searcher, or ordering actor able to reorder requests, fulfillments, and retries;
- mutable token/NFT/oracle contracts and other external dependencies used after the request.

State which are trusted, economically aligned, or adversarial. Do not collapse an untrusted raffle host
into a harmless “centralization risk” when the product promises fair outcomes against that host.

## Core invariants

Adapt these to the product's stated rules; do not invent a fairness or timeout policy.

### I1 — Request provenance and exact binding

- Request initiation is failure-atomic: either the provider accepts a request and its full-width ID is
  bound before the commitment becomes pending, or a revert/caught failure leaves a valid recoverable
  pre-request state.
- Every accepted callback maps one full-width, provider-namespaced request key to one immutable business
  commitment (round, mint, order, batch, or user action). Unless the provider proves global uniqueness,
  the key includes the provider/coordinator/version identity plus its request ID or sequence. The same
  numeric ID from two providers or generations cannot alias one request record or overwrite another. If
  a commitment intentionally uses multiple requests, their cardinality, membership, roles, and
  combination rule are immutable before any result is visible.
- The mapping has an explicit existence/pending marker; zero/default values cannot alias a valid object.
- No global `lastRequestId`, narrowing cast, overwrite, or recycled object ID can redirect a callback.
- Provider-call reentrancy cannot deliver a callback before the consumer has created the binding. Either
  the resolved provider guarantees a later transaction or the request path safely handles synchronous
  callback/reentry without guessing the identifier.

### I2 — Fixed accepted entropy set per commitment

- A single-source commitment cannot have two simultaneously acceptable requests.
- A multi-source/threshold commitment cannot add, remove, replace, reorder, or selectively ignore a
  source after any component output or fulfillment transaction becomes observable.
- Retry, cancellation, timeout, pause, migration, and upgrade paths cannot let a beneficiary or trusted
  role select which random output is consumed.
- Late callbacks have an explicit behavior that preserves safety and does not strand unrelated funds.

### I3 — Order independence

For any valid requests A and B, consuming fulfillments in order A→B or B→A produces equivalent
per-commitment outcomes, except for explicitly irrelevant metadata such as event ordering.

### I4 — Frozen outcome inputs

Participant set, weights, token supply/index, prize/value, odds, and all external state used by mapping
are committed before the request or read from an immutable snapshot. Transfers and admin/config actions
must not create a hidden post-request mutation path.

### I5 — Authenticated, bounded callback with correct delivery semantics

Only the resolved coordinator/wrapper can reach fulfillment. Authentication also remains sound across
provider changes and cannot turn an admin-selected router into an unexamined reentrancy boundary.
Callback work is bounded for every
reachable pending state and provider-valid word array. For a non-retrying provider it does not revert;
for a retrying provider it is idempotent, cannot duplicate terminal effects, and has a verified retry and
termination model. Check external calls, array growth, duplicate state, recipient hooks, token behavior,
arithmetic, and configured gas.

### I6 — Deterministic and total consumption

- The same committed inputs and random words always yield the same result.
- Empty sets, zero bounds, requested/returned word counts, index bounds, and casts are handled.
- Multi-winner selection matches the intended with- or without-replacement policy.
- Derived words use explicit domain separation and cannot accidentally reuse entropy across roles.
- Encoding and type conversions preserve the intended inputs. In particular, distinguish a cryptographic
  hash from truncating `abi.encode*` output with a fixed-width cast.
- A fallback or provider/source swap has its own stated security model and cannot consume a stale output
  from the prior mode or silently reduce the commitment to an influenceable block/user value.

### I7 — Exactly-once terminal effects

Settlement/claim cannot pay, mint, unlock, refund, or mark a commitment twice. Reentrancy, partial
failure, and permissionless callers cannot produce a half-terminal state. A malicious winner should
not block unrelated users; prefer pull/claim isolation when product behavior permits.

### I8 — Recoverable liveness without reroll

An unavailable provider, unfunded subscription, reverted callback, failed downstream transfer, pause,
or abandoned operator has a documented terminal/recovery path. Recovery does not replace already-bound
entropy unless the product explicitly accepts and mitigates that trust tradeoff.

### I9 — Configuration and governance cannot rewrite fairness

Coordinator/wrapper, confirmations, gas limit, key hash, subscription, fee mode, settlement code, and
privileged roles have bounded update timing. Changes cannot retroactively alter pending commitments.

## Evidence calibration

Classify each item:

- `confirmed`: reachable exploit/failure trace and violated invariant are established from current code;
- `conditional`: code path exists, but impact depends on a stated external/config/product condition;
- `defense-in-depth`: hardening improves resilience without a demonstrated harmful state transition;
- `false positive`: the signal is neutralized by a cited guard or unreachable precondition;
- `unresolved`: required source, deployment, configuration, or policy evidence is missing.

Do not assign severity from a keyword. Severity follows affected value, attacker control, probability,
blast radius, recoverability, and privilege assumptions.

## Special proof standards

### Modulo bias

For a uniform `b`-bit word and bound `n`, let `q = floor(2^b / n)` and `r = 2^b mod n`.
`r` residues occur `q+1` times and the rest occur `q` times. Report the actual probability delta,
number of repeated draws, attacker influence, and value impact. With a 256-bit word and ordinary small
`n`, the bias is often negligible; if `n > 2^b`, some residues are unreachable. Zero/mutable bounds or
selection logic may still be critical.

### Confirmations

A literal count is not intrinsically safe or unsafe. Establish current provider bounds, chain finality
and reorg model, request inclusion/value at risk, latency requirement, and who controls request timing.
Without those facts, record an unresolved configuration risk rather than inventing a threshold.

### Callback complexity

External calls, loops, minting, and transfers are risk signals, not automatic vulnerabilities. Confirm
the maximum work, recipient/token behavior, error handling, configured gas, and recovery. Conversely,
a store-only callback is not automatically safe if later settlement can be manipulated or never called.

### Entropy mixing and fallback

List every input to the final randomness transformation and the actor who can choose, withhold, reorder,
or observe it. Hashing correlated or predictable inputs improves representation, not entropy. When a
strong source is combined with a weak one, prove the weak party cannot abort or select among completed
strong-source outputs. For commit-reveal or user/provider combinations, test last-revealer abort and
fallback selection after other contributions become visible. When fallback changes the provider or
algorithm, re-run I1–I9 for that mode.

## Finding skeleton

```text
Title / severity / evidence status
Affected commitment and invariant
Code path with file:line anchors
Preconditions and attacker/trusted role
Transition sequence (request -> fulfill -> consume/recover)
Observed final state and user/economic impact
Test or reproducible trace
Why existing guards fail
Smallest remediation direction and tradeoff
Evidence gaps
```
