# Chainlink provider adapter

Read this reference only after Chainlink VRF is detected or claimed. Identify the actual installed
contract version before applying version-specific conclusions.

## Authoritative evidence order

1. Repository lockfile/remappings and the resolved `@chainlink/contracts` source used by the build.
2. A tagged `chainlink-evm` source revision matching that dependency.
3. Official VRF documentation for protocol behavior and current network configuration.
4. Deployment scripts/configuration, verified deployed bytecode, and coordinator/subscription state
   when the review makes runtime claims.

Do not infer the deployed coordinator, wrapper, key hash, limits, or supported network from memory.
Import paths have changed across package releases; open the resolved file.

Official entry points:

- Security considerations: https://docs.chain.link/vrf/v2-5/security.md
- Supported networks and configuration: https://docs.chain.link/vrf/v2-5/supported-networks.md
- Subscription consumer: https://docs.chain.link/vrf/v2-5/subscription/get-a-random-number.md
- Direct funding consumer: https://docs.chain.link/vrf/v2-5/direct-funding/get-a-random-number.md
- V2 to V2.5 migration: https://docs.chain.link/vrf/v2-5/migration-from-v2.md
- Tagged EVM contract source: https://github.com/smartcontractkit/chainlink-evm/releases

## Version and funding-mode fingerprints

| Mode | Common base/API cues | Audit consequence |
|---|---|---|
| V1 | `VRFConsumerBase`, `requestRandomness`, `fulfillRandomness` | Establish legacy coordinator/key-fee semantics; do not judge it using V2.5 signatures. |
| V2 subscription | `VRFConsumerBaseV2`, positional `requestRandomWords`, `uint64 subId` | Check V2 coordinator, subscription, callback auth, and migration plan separately. |
| V2 direct funding | `VRFV2WrapperConsumerBase` | Wrapper authenticates callback; consumer funds requests upfront. |
| V2.5 subscription | `VRFConsumerBaseV2Plus`, `VRFV2PlusClient.RandomWordsRequest`, `uint256 subId` | Inspect inherited coordinator ownership/migration behavior and `extraArgs` payment mode. |
| V2.5 direct funding | `VRFV2PlusWrapperConsumerBase` | Inspect immutable wrapper binding, LINK/native price path, refunds/withdrawals, and wrapper callback auth. |

Legacy code is auditable. Migration need and compatibility are separate findings from exploitable
consumer behavior.

## Provider facts that affect consumer security

- `requestId` is the correlation key; concurrent fulfillments may arrive out of order.
- A chain rewrite can cause a request to be included under a different block hash, yielding a fresh
  random output. Confirmations raise the economic cost but no universal count is safe for all chains.
- Chainlink warns against re-requesting or canceling randomness for a specific commitment and against
  accepting outcome-affecting inputs after requesting.
- If the consumer callback reverts, the service does not call it again. Insufficient callback gas can
  therefore consume payment while leaving the consumer unfulfilled.
- Subscription consumers should preserve the base contract's raw-callback authentication. Direct
  funding consumers authenticate the configured wrapper instead.
- Subscription balance and consumer authorization are availability boundaries. Near-minimum balance
  plus concurrent consumers can delay fulfillment.

Verify these against the documentation and resolved source at review time.

## Chainlink-specific review branches

### Callback authentication and migration

- Confirm the raw external callback is inherited from or equivalent to the resolved base and compares
  `msg.sender` with the intended coordinator/wrapper.
- Treat any custom/overridden raw callback, public test hook, or exposed internal fulfillment shim as
  a spoofing hypothesis until disproved.
- In V2.5 subscription consumers, inspect who can change the coordinator and what happens to requests
  still pending at the old coordinator. A premature change can make old callbacks fail authentication.
- For proxies/clones, prove the coordinator, wrapper, owner, and subscription are initialized exactly
  once and stored where the chosen base expects them.

### Billing and availability

- Subscription: map owner/admin powers, approved consumers, concurrent spenders, balance monitoring,
  top-up process, cancellation/migration, and pending-request behavior.
- Direct funding: prove quoted/requested price, LINK/native selection, excess value/refunds, trapped
  balances, withdrawal authority, and reentrancy boundaries. Do not assume the two funding modes share
  identical APIs or callback data locations.

### Mocks and test evidence

Use the mock matching the installed dependency. Test request bookkeeping and fulfillment order through
the mock's authenticated path. Also add hostile harnesses where necessary for callback gas/revert and
post-fulfillment settlement behavior. Never use a mock-only pass as proof of live coordinator address,
subscription funding, key hash, billing, network limits, or callback delivery.
