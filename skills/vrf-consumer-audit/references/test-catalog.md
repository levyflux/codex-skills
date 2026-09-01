# VRF consumer test catalog

Select only cases relevant to the implementation. Tests should assert state and economic properties,
not scanner text or finding wording.

## Binding and concurrency

1. Force the provider request call to revert before returning an ID; prove the consumer does not remain
   falsely pending, lose a commitment, or impose an attacker-repeatable recovery delay.
2. Create two business objects and requests; fulfill in both orders and compare per-object outcomes.
3. Attempt a second request for one pending single-source object through every public/admin/automation
   entrypoint. For a multi-source object, try changing membership or the combination threshold after one
   component becomes visible.
4. Retry, then fulfill old/new IDs in both orders; prove only the policy-approved entropy can affect
   terminal state and no beneficiary can choose between them.
5. Exercise object ID zero/default mapping, deleted/reused objects, and unknown request IDs.
6. Use request IDs that differ above a stored integer width to expose truncation/collision.
7. Return the same numeric request ID from two provider/coordinator namespaces and prove callbacks cannot
   cross-bind, including during provider migration.
8. Use a hostile provider/router that synchronously calls back before returning the request identifier;
   prove the request path rejects or safely binds it, or cite resolved provider evidence that makes this
   transition impossible.
9. Fulfill after cancel, refund, pause, expiry, coordinator migration, or proxy upgrade.

## Input freeze and snapshot integrity

1. After requesting, try enter/bet/deposit/mint/withdraw/transfer and every weight/prize/config update.
2. Mutate outcome inputs indirectly in another contract or through token transfers.
3. Request with snapshot size `n`, then change the live array and prove mapping still uses the matching
   snapshot for both bounds and element lookup.
4. Race automation/operator checks with user input around the close/request boundary.
5. Observe the fulfillment transaction/result before inclusion, then front-run every still-open input,
   cancel, source-swap, settlement, transfer, and claim path that could change who benefits.

## Callback authentication and liveness

1. Call the raw callback from an attacker and from stale/alternate coordinator or wrapper addresses.
2. Reach every pending state and fulfill with expected, empty, short, and extra word arrays as permitted
   by the actual provider boundary.
3. Grow dynamic collections to their maximum reachable size; measure callback gas and compare with the
   configured limit and current provider/network maximum.
4. Use a reverting/reentrant ERC-721 receiver, ETH receiver, ERC-20, downstream hook, or external oracle.
5. Force downstream settlement failure and prove retry/claim recovery preserves the same stored entropy.

## Randomness consumption

1. Bound `n` at zero, one, maximum, and around type-width boundaries.
2. For multi-winner draws, assert uniqueness when policy says without replacement; assert exact count
   and no array/index corruption.
3. Re-run mapping with identical committed inputs/words and assert determinism.
4. Check each derived random value is domain-separated by purpose and index.
5. Compare `bytes32(abi.encode(...))`, `bytes32(abi.encodePacked(...))`, and `keccak256(...)` against the
   intended input set; prove no word, object ID, or domain tag is silently truncated or ignored.
6. Exercise every fallback/provider-swap trigger with an old request pending and after one component
   output is observable; prove no stale callback, favorable subset, or weaker source can settle the object.
7. When alleging distribution bias, implement a mathematical proof or statistically powered test with
   a justified sample size; do not use a flaky small-sample histogram as finding proof.

## Settlement, value, and governance

1. Call settle/claim twice, reenter it, and interleave two users/rounds.
2. Make one winner unable or unwilling to receive; prove unrelated claims and terminal progress survive.
3. Exhaust subscription/consumer funds or direct-funding balance in a local harness; verify documented
   failure and recovery paths without issuing a replacement draw.
4. Spam every public/permissionless request path and interleave callers; prove authorization, rate/cost
   accounting, pending-state bounds, and one user's request cannot drain or starve unrelated commitments.
5. Change confirmations, gas, key hash, subscription, coordinator/wrapper, owner, or implementation
   while one or more requests are pending.
6. For proxies/clones, test zero/uninitialized provider state, repeated initialization, owner/coordinator
   takeover, storage preservation, and callbacks spanning an upgrade.
7. Fuzz arbitrary allowed transition sequences and assert: no double terminal effect, no accepted entropy
   replacement, no cross-object result, and terminal accounting conservation.

## Evidence layers

- Unit/mock: consumer state transitions and provider-authenticated callback path.
- Stateful fuzz/invariant: interleavings, reentrancy, concurrency, and accounting properties.
- Fork/read-only deployment checks: resolved addresses, bytecode, owner/config/subscription state.
- Testnet/runtime: callback delivery, gas, billing, and operational recovery; required before release
  claims but never authorized by a review-only request.
- Chain-economic analysis: confirmations/reorg and MEV claims; cannot be proven by a local mock.
