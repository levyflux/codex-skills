# Chain-specific checks

Read only the section matching the exact chain family, plus the common market checks.

## EVM tokens

Verify current deployed state, not only published source:

- code exists at the exact address; detect proxy, implementation, beacon, diamond, initialization,
  owner/admin, timelock, and upgrade paths;
- supply controls: mint, burn-from, rebase/reflection, balance rewrite, arbitrary transfer/seizure;
- transfer controls: blacklist/whitelist, trading enable, pause, cooldown, max wallet/transaction,
  sell-only restrictions, exemptions, and block/time/caller-dependent branches;
- tax controls: buy/sell/transfer rates, fee-on-transfer behavior, mutable bounds, recipients, and
  privileged tax exemptions;
- pool and liquidity: actual pairs/pools, quote reserves, LP owner/locker/burn path, lock share and
  duration, locker upgrade/withdraw paths, concentrated-liquidity position ownership;
- exact route: allowlisted router and spender, recipient, value, calldata semantics, fee tier/path,
  Permit2/ERC-20 approval amount and expiry, balance deltas, `min_out`, and deadline;
- simulations cover the exact buy and a supported sell path. A generic `eth_call` success without
  token/quote balance-delta verification is insufficient.

Treat unverified source or unresolved proxy implementation as configurable policy risks; if the
policy does not explicitly allow and bound them, `BLOCK`.

## Solana tokens

Verify the exact mint, program IDs, accounts, and current authorities:

- mint authority, freeze authority, supply, decimals, and whether authorities are revoked or held
  by programs/multisigs;
- Token-2022 extensions as applicable: transfer-fee configuration and withdraw authority, transfer
  hook, permanent delegate, default account state, non-transferable behavior, confidential-transfer
  controls, metadata/group pointers, and pause or other program extensions;
- launchpad/bonding-curve program identity, program upgrade authority, pool/curve accounts, vaults,
  token accounts, fee recipients, migration/graduation path, and reserved supply;
- shared fee payer, account creation funding, launch bundles/Jito relationships, creator transfers,
  common funding, and slot-level synchronized buyers;
- exact instructions: program allowlist, account metas and writable/signing privileges, fee payer,
  compute/priority fee, Jito tip if used, token accounts, recipient, amount limits, recent blockhash
  validity, and expected balance deltas;
- simulations cover the exact buy and a supported sell path. Simulation must detect transfer-hook,
  fee, frozen/default-state, missing-account, or program restriction failures.

A scanner result that marks a supplied mint address as native, skips it unexpectedly, or conflicts
with mint/program evidence is invalid and produces `BLOCK`.

## Common market and launch checks

For either family:

- distinguish internal bonding-curve liquidity from graduated external DEX liquidity;
- verify LP/curve custody and exit capacity relative to the exact amount;
- exclude protocol, curve, LP, locker, burn, router, bridge, and vault addresses when measuring
  circulating concentration where possible;
- inspect top-holder clusters beyond top 10, common funding, bundles/snipers, creator/developer
  history, fresh-wallet share, wash activity, net quote inflow, and coordinated exits;
- check whether graduation can stall and whether locked LP only prevents redemption rather than
  ordinary whale selling;
- use current reserves and executable quotes, not market cap or quoted TVL, to assess exit impact.

Cluster absence is not proof of independent control. Scanner labels, verified metadata, community
badges, holder count, and social activity cannot independently produce `PASS`.
