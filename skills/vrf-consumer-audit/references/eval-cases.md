# Behavioral evaluation cases

Use these to evaluate audit decisions, not exact wording. Keep project/root-cause holdouts separate from
the reference cases used to write the skill.

## Positive cases

1. **Underfunded redraw** — A host controls subscription funding and can replace the current request after
   a timeout. Expected: trace selective acceptance of old/new outputs; do not rely on ordinary callback
   latency; calibrate severity from host role, value, and ordering feasibility.
2. **Request call caught after pending write** — `try requestRandomness` catches failure after setting
   `drawing=true`. Expected: identify request-initiation failure atomicity and attacker-repeatable delay.
3. **Out-of-order rounds** — Two rounds share `lastRequestId`. Expected: map both fulfillment orders and
   demonstrate cross-round corruption or unresolved binding, not merely say “use a mapping.”
4. **Intentional 2-of-3 sources** — Provider membership and combination rule are committed before any
   request; all callbacks bind to the same object. Expected: do not flag multiple requests by itself;
   test subset selection, withholding, and order independence.
5. **Mutable threshold after one output** — Admin can lower 2-of-3 to 1-of-3 after seeing a fulfillment.
   Expected: identify favorable-subset selection under I2/I9.
6. **Non-retrying callback transfer** — Chainlink callback pushes ETH to a reverting winner. Expected:
   prove callback loss/liveness from the resolved provider semantics and isolate payout from fulfillment.
7. **Retrying provider duplicate delivery** — A provider version retries failed callbacks. Expected: do
   not import Chainlink's no-retry rule; test callback idempotence and duplicate terminal effects.
8. **Encoded bytes cast** — Intended token hash is `bytes32(abi.encodePacked(words, tokenId))`. Expected:
   prove tail truncation with equal first words; distinguish intent from valid direct use of word zero.
9. **Weak fallback** — On timeout, the contract replaces VRF with `block.prevrandao` and accepts the first
   available result. Expected: audit the fallback as a separate security mode and selection channel.
10. **Proxy migration in flight** — Upgrade changes coordinator/auth state while old requests are pending.
    Expected: test initialization, old callback authentication, storage, and terminal recovery.
11. **Modulo near-miss** — A 256-bit word selects one of ten immutable entries with `% 10`. Expected: do
    not report material bias without quantitative impact; still check zero/live bounds and attacker retries.
12. **Multi-provider callback argument** — Callback includes a provider address and sequence number.
    Expected: bind both to the original commitment, collide equal sequence numbers across providers, and
    verify the provider-specific auth/base contract.
13. **Synchronous hostile router callback** — A mutable provider calls the authenticated callback before
    `request()` returns its ID. Expected: identify pre-binding reentrancy or establish exact provider
    evidence that rules the transition out; do not assume every oracle callback is asynchronous.

## Trigger negatives

1. “Generate a Chainlink VRF V2.5 subscription consumer.” Expected: ordinary integration is outside this
   skill unless security review is also requested.
2. “Explain elliptic-curve VRF proof construction.” Expected: provider cryptography is outside consumer
   audit scope.
3. “Audit a Solana Switchboard VRF program.” Expected: this EVM-specific skill should not claim coverage.
4. “Is `block.prevrandao` random?” with no consumer audit/code context. Expected: answer from the relevant
   EVM randomness specification rather than forcing the full VRF consumer workflow.

## Scoring dimensions

- correct trigger and provider/version routing;
- complete request→callback→consume/recovery trace;
- root cause and violated invariant, not keyword matching;
- false-positive control on multi-source and modulo near-misses;
- provider-specific callback/retry accuracy;
- evidence status and severity calibration;
- no invented addresses, thresholds, timing, or deployment facts;
- no repository write during review-only evaluation.
