# Launchpad mechanics and manipulation

Use this reference for conceptual explanations and for interpreting launchpad-specific risk signals.

## Bonding curve and graduation

Before graduation, buyers and sellers trade against an internal bonding curve. `Progress` usually
measures how close the curve is to its configured completion condition; it is not a quality score.
When the condition is met, the platform may create an external DEX pool with the collected quote
asset and reserved project tokens.

Graduation establishes a new trading venue. It does not certify the creator, guarantee continued
liquidity, or prevent concentrated holders from selling. If the curve never reaches its completion
condition, the token may never graduate.

## LP and locked liquidity

An LP position represents ownership of assets supplied to an AMM pool. Locking or burning the LP
credential can prevent its owner from redeeming the underlying principal. Traders can still swap
against the pool, so the reserve composition and price continue changing.

Therefore:

- locked LP reduces direct liquidity-removal risk;
- it does not prevent whale sells, transfer taxes, blacklist powers, upgrade risk, or price collapse;
- permanent lock claims must be verified against the actual locker, position owner, withdrawal
  paths, upgrade boundary, and locked share;
- fee collection must be distinguished from principal withdrawal.

## Anti-snipe versus anti-dump

Anti-snipe mechanisms commonly impose an early-buy surcharge, launch-time cap, allowlist, batch
auction, or delayed claim. They address acquisition timing and initial concentration.

Anti-dump mechanisms operate on exits: vesting, sell tax, max transaction, cooldown, cumulative
sell budget, or a price circuit breaker. They can delay selling but create tradeoffs:

- per-address limits are bypassed through multiple wallets once tokens are transferable;
- high or mutable sell taxes can become a honeypot;
- sell pauses and circuit breakers can trap ordinary holders and cause denial of service;
- restrictions may push trading into unrecognized pools;
- eventual unlocks defer rather than remove supply pressure.

The strongest structural mitigation is usually to prevent concentrated transferable inventory from
forming: capped allocation combined with non-transferable claims or vesting, fair batch allocation,
and transparent team unlocks. On-chain contracts cannot know that thousands of unrelated addresses
share one human controller without an external identity or sybil-resistance system.

## Multi-wallet manipulation lifecycle

Describe attacker behavior only at a defensive level. Do not provide instructions for hiding links
or defeating detectors.

Typical observable stages:

1. **Wallet preparation** — many fresh or similarly aged addresses with little unrelated history.
2. **Funding** — a common funder, intermediary, fee payer, bridge route, or patterned exchange
   withdrawals supplies gas and quote assets.
3. **Acquisition** — synchronized buys, shared bundles, repeated sizes, matching slippage/priority
   settings, or direct creator distribution.
4. **Activity manufacturing** — related wallets trade repeatedly, increasing gross volume and holder
   count with limited net quote inflow.
5. **Exit** — coordinated sells, inventory rotation, common sweepers, or profit consolidation.

### Evidence strength

**Stronger links** include direct common funding, the same fee payer, the same launch bundle, creator
distribution, direct transfers between wallets, or a common consolidation destination.

**Behavioral signals** include synchronized timing, similar amounts and transaction construction,
fresh-wallet concentration, single-token histories, coordinated inactivity, or matched exits.

**Weak standalone signals** include a common exchange source, use of a popular router, similar round
amounts, or participation in a highly popular launch. These have benign alternatives and should not
be presented as proof.

Solana analysis may additionally observe shared token-account funding, rent/fee payment, instruction
ordering, Jito bundle/tip relationships, and slot-level synchronization. EVM analysis may observe gas
funding, batch/relayer use, direct transfer graphs, repeated calldata/routes, and common sweepers.

## Detection limits

A sophisticated controller can reduce observable links by using independently funded wallets,
random timing and amounts, distinct routes, long-lived behavior, and no direct consolidation. Public
chain data may then be unable to prove common control. Device, IP, account, exchange, or private RPC
records are outside the ordinary investor's evidence set.

Consequently:

- holder count and top-10 concentration can be manufactured;
- `no bundle` and `no detected cluster` mean only that the detector found no qualifying evidence;
- cluster results are probabilistic and can have both false positives and false negatives;
- time and diverse external funding improve confidence but never establish identity with certainty.

## Practical risk controls

- Require the exact contract address and current data.
- Inspect top-holder clusters and funding sources, not holder count alone.
- Compare gross volume with net quote inflow and reserve change.
- Check launch bundles, creator history, large-holder exits, and circulating-supply concentration.
- Wait for independently funded, naturally timed two-sided activity when the evidence is immature.
- Treat a position as capable of total loss; low liquidity can make a stop order ineffective.
- Avoid increasing exposure solely because price has fallen or because LP is locked.

When a hard link or several independent behavioral anomalies point to common control, describe the
asset as high observable manipulation risk. When evidence is absent, retain the unknown instead of
upgrading the conclusion to safe.
