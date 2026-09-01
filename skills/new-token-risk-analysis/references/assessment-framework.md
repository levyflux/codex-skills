# New-token assessment framework

Use this reference for a specific token, a launchpad watchlist, or a holder deciding whether the
remaining position still has a defensible thesis.

## 1. Establish identity and freshness

- Record chain, full contract or mint address, launch venue, token standard, and observation time.
- Resolve duplicate symbols by address. If identity is uncertain, stop before mixing data from
  different tokens.
- State whether values are current chain reads, indexed snapshots, official documentation, local
  source, or inference.

## 2. Contract and transaction gates

Check the risks relevant to the chain and token standard:

- mint, freeze, blacklist, pause, transfer-hook, permanent-delegate, or arbitrary seizure powers;
- mutable buy/sell taxes, trading switches, max-wallet/max-transaction logic, allowlists, and
  transfer exemptions;
- owner, proxy, upgrade, implementation, timelock, and initialization boundaries;
- buy and sell feasibility, actual received amounts, dynamic taxes, and simulation reverts;
- source verification versus deployed bytecode. Verified source alone does not establish that a
  proxy currently points to it.

A scanner label is evidence from one detector. Preserve its verdict and triggered labels, but do
not convert `no label` into an assurance that malicious logic is absent.

## 3. Liquidity and exit capacity

Identify every material pool and distinguish internal bonding-curve liquidity from external DEX
liquidity. Check:

- quote asset, reserves, pool version, fee, and whether liquidity is concentrated in one pool;
- LP ownership, locker/burn destination, locked share, duration, and any withdrawal or upgrade path;
- expected price impact and slippage for the user's position, including taxes and likely competing
  sellers;
- whether the curve can stall permanently and whether graduation changes the venue or merely the
  interface.

Locked LP primarily prevents the LP owner from redeeming principal. It does not stop holders from
selling tokens into the pool and withdrawing the quote side through ordinary swaps.

## 4. Supply and control

Start from total supply, circulating supply, curve/LP reserve, and team/creator allocations. Then:

- remove protocol-controlled and provably inert addresses when calculating economic concentration;
- inspect top 10, top 50/100, and available top-holder clusters;
- measure creator, deployer, bundle, sniper, insider, and fresh-wallet exposure;
- identify vesting, claim schedules, unlocks, and whether transferability defeats per-wallet caps;
- distinguish many addresses from many independently funded participants.

Report both total-supply concentration and concentration of the actually circulating supply when
possible. A wallet holding 3% of total supply can control a much larger share of the freely traded
inventory.

## 5. Developer and launch behavior

Check creator launch history, prior rugs, repeated metadata, related tokens, launch-time bundles,
initial funding, creator sells, and whether the creator retains an economically meaningful stake.
Treat paid promotion, verification badges, and social links as informational rather than safety
evidence.

## 6. Trading quality

Review the trade sequence rather than aggregate volume alone:

- unique funded buyers versus repeated wallets;
- quote-asset net inflow versus round-trip volume;
- buy/sell size distribution and synchronized bursts;
- wash-trading indicators, self-crossing clusters, and patterned addresses;
- large holder exits, price response, and recovery without coordinated support;
- market-cap claims relative to executable liquidity.

High volume with little net reserve change may be manufactured activity. A large holder count with
many new or commonly funded addresses may be a distribution illusion.

## 7. Value source and catalysts

Separate speculative attention from an external value source. Look for current, verifiable evidence
of at least one of:

- required token use in a functioning product;
- protocol fees or cash flows with a credible path to token holders;
- staking or security demand;
- governance over economically meaningful assets;
- durable brand/community demand that persists beyond the launch event.

Graduation, locked LP, a trending rank, an old social post, or a future roadmap is not by itself a
value source. For a recovery thesis, require a concrete catalyst and observable evidence that it is
not already exhausted.

## 8. Conclusion bands

Do not compute a hidden score. Choose the narrowest supported conclusion:

- **Critical issue found** — transaction blocking, confiscation/mint risk, removable liquidity,
  confirmed creator/bundle control, or another direct loss path.
- **High observable risk** — severe exit, concentration, manipulation, or value-source weakness
  even if the contract is sellable.
- **Watch only** — no direct blocker, but data is too young, thin, concentrated, or incomplete for
  a defensible risk conclusion.
- **No critical issue found in completed checks** — only when every named gate was actually checked;
  this is not `safe` and says nothing about price.

List the facts that would change the conclusion, such as materially broader independent funding,
natural two-sided trading over time, increased executable liquidity, completed vesting, or a verified
product/cash-flow milestone. Avoid inventing universal numeric thresholds; use upstream risk-policy
thresholds and position-relative calculations where available.

## Compact output shape

1. Outcome and confidence.
2. Asset identity and snapshot time.
3. Decisive evidence table: finding, layer, status, implication.
4. Exit and concentration summary.
5. Contract and launch-mechanism summary.
6. Manipulation evidence and alternatives.
7. Value source/catalyst assessment.
8. Unknowns and what would change the conclusion.
