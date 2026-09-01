# Initial primary-source case seeds

Use these only as historical examples of root-cause extraction. Reopen the report and scoped source
before relying on exact code or severity. Contest severity is contextual and does not transfer to a new
project.

## Selective redraw through an underfunded subscription

- Source: [Code4rena Forgeries report, H-02](https://code4rena.com/reports/2022-12-forgeries#h-02-draw-organizer-can-rig-the-draw-to-favor-certain-participants-such-as-their-own-account)
- Scoped repository seed: [code-423n4/2022-12-forgeries](https://github.com/code-423n4/2022-12-forgeries),
  observed `main` snapshot SHA `42e2996aaec205a93685bfb32d47eca79941e2bf` on 2026-08-26.
- Provider/mode: historical Chainlink VRF V2 subscription consumer.
- Root cause: redraw overwrote the single accepted request ID while the old request could still be
  fulfilled. Subscription underfunding made response timing controllable enough for the organizer to
  decide whether to let the old fulfillment land or replace it.
- Violated invariants: I1, I2, I8.
- Proof shape: request A while underfunded; wait until redraw is enabled; fund; observe/anticipate A's
  fulfillment; accept it if favorable or issue B so A fails the current-ID check.
- Distilled lesson: model funding and delayed delivery together with retry semantics. A time-based redraw
  is not safe merely because ordinary fulfillments are usually faster.
- Caveat: the report's final severity was reduced to Medium after judging attack difficulty and third-party
  mitigation. Preserve that context rather than relabeling it universally.

## Request failure caught after entering the pending state

- Source: [Code4rena Wenwin report, M-02](https://code4rena.com/reports/2023-03-wenwin#m-02-an-attacker-can-leave-the-protocol-in-a-drawing-state-for-extended-period-of-time)
- Scoped source cited by the report: commit `91b89482aaedf8b8feb73c771d11c257eed997e8`.
- Provider/mode: historical Chainlink VRF V2 direct funding through a wrapper.
- Root cause: the controller wrote `lastRequestFulfilled = false` before calling the source, then caught a
  failed request without restoring state. An attacker could intentionally supply insufficient gas and
  repeatedly force the retry delay.
- Violated invariants: I8 and the request-side half of I5.
- Proof shape: close draw; call request with gas that reaches the state write but makes the external request
  fail; observe caught failure and locked drawing state; repeat after retry delay.
- Distilled lesson: audit request initiation as a state transition with failure atomicity. Callback-only
  review misses liveness failures before a request ID even exists.

## Confirmation policy versus reorg value at risk

- Source: [Code4rena PoolTogether report, H-02](https://code4rena.com/reports/2021-10-pooltogether#h-02-miners-can-re-roll-the-vrf-output-to-game-the-protocol)
- Provider/mode: historical first-generation Chainlink VRF integration.
- Root cause claim: a request with inadequate confirmation/economic separation could be re-included under
  a different block hash by a sufficiently capable miner/operator coalition, producing a fresh output.
- Violated invariant: I9, contingent on chain and attacker economics.
- Proof shape: compare value at risk with the cost/probability of rewriting the request's inclusion block;
  do not simulate this as a local callback-order bug.
- Distilled lesson: confirmation review is chain-economic and version-specific. A numeric recommendation
  from a 2021 report is not a current universal threshold.
- Caveat: sponsor and judge discussion acknowledged the vector but debated feasibility and severity. Use
  this as a calibration case for `conditional` evidence, not as proof that every low literal is exploitable.

## Fixed-width cast silently discards intended entropy inputs

- Source: [Code4rena NextGen report, finding 02](https://code4rena.com/reports/2023-10-nextgen#02-fulfillrandomwords-sets-the-token-hash-as-the-first-fulfilled-random-number-instead-of-calculating-a-hash)
- Scoped repository seed: [code-423n4/2023-10-nextgen](https://github.com/code-423n4/2023-10-nextgen),
  observed `main` snapshot SHA `7f7939669f5fd1e041face34dd97009f99ec678f` on 2026-08-26.
- Provider/mode: historical Chainlink VRF V2 subscription consumer.
- Root cause: `bytes32(abi.encodePacked(randomWords, tokenId))` retained only the first 32 encoded bytes;
  it did not hash all encoded inputs. Later words and the intended object/domain binding were ignored.
- Violated invariant: I6.
- Proof shape: supply two different encoded tails with the same first word and show that the stored
  `bytes32` value is identical; compare with `keccak256` only if a digest is the intended product behavior.
- Distilled lesson: trace Solidity representation semantics independently from entropy quality. More
  encoded inputs do not affect a fixed-width cast merely because they appear in `abi.encodePacked`.
- Caveat: using the first VRF word directly can be valid when the specification wants exactly that word.
  The finding depends on the contract's explicit intent to bind additional words/token ID into a hash.
