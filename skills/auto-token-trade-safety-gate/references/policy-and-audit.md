# Policy, wallet boundary, and audit

Use this reference when converting the gate into a production workflow. A Skill guides decisions;
executable code and wallet policy must make the safety boundary non-bypassable.

## Fixed safety invariants

These do not become configurable merely to increase trade count:

- only exact chain/address identity; no symbol-only trading;
- missing, stale, contradictory, unsupported, or failed required evidence means `BLOCK`;
- exact buy and supported sell-path simulation before entry;
- no arbitrary targets/recipients, unbounded calldata, unlimited approvals, or secret exposure;
- final unsigned intent must match an unexpired one-time gate artifact;
- `PASS` never implies transaction authorization or profitability.

## Product-policy values

The user or owned product specification must define and version values such as:

- allowed chains, launchpads, DEXes, routers/programs, pools, spenders, quote assets, and token
  standards;
- per-trade, per-token, per-strategy, daily, and total wallet exposure;
- maximum realized/unrealized loss, drawdown, concurrent positions, and loss streak;
- minimum executable liquidity and age; maximum slippage, price impact, tax, gas/priority fee,
  holder/cluster concentration, bundle/sniper exposure, creator exposure, and wash indicators;
- authority/proxy/source policies, LP-lock requirements, graduation stage, and developer-history
  exclusions;
- data freshness by provider, acceptable block lag, quote/simulation TTL, retry/backoff limits, and
  decision latency;
- exit, take-profit, stop, timeout, monitoring, and emergency shutdown rules.

Do not invent these values inside the Skill. If a required value is absent, `BLOCK: policy_missing`.

## Wallet and signer controls

Production automation should use a dedicated wallet or constrained account, not the user's main
wallet. Enforce outside the model:

- bounded balances and spend limits;
- chain, target, router/program, spender, and recipient allowlists;
- exact or narrowly bounded approvals with cleanup; no blanket Permit2/ERC-20 allowance;
- prohibition on wallet export and arbitrary contract calls;
- nonce/replay control, one-time gate consumption, and separation of discovery, gating, and signing;
- manual kill switch and automatic circuit breakers that the strategy cannot disable;
- no credentials in prompts, logs, gate artifacts, analytics, or model-visible output.

## External-action contract

Before a future workflow can execute, separately establish:

- exact wallet/account and funding boundary;
- allowed chains, venues, actions, tokens, amounts, and time window;
- confirmation model supported by the wallet execution skill;
- side effects such as approvals, gas, taxes, MEV exposure, and monitoring;
- explicit exclusions and rollback/recovery limits.

Authorization for skill creation, research, one candidate, or one transaction does not transfer to
another candidate or unattended operation. The gate artifact always carries
`authorization: NOT_GRANTED`.

## Audit evidence

Persist for every candidate, including rejected ones:

- policy and strategy version;
- exact identity and intent binding;
- evidence providers, timestamps, chain heads, freshness, raw-result references, and normalized
  facts;
- every check status and reason;
- final decision and artifact expiry;
- execution request, confirmation, tx hash, receipt, actual balance deltas, fees, slippage, and
  post-trade monitoring when a separate workflow later executes.

Audit data must be append-only or tamper-evident at the workflow level and must never contain keys,
seeds, session credentials, or raw signed transactions.

## Runtime and user-visible evidence

Skill validation proves only that instructions are well formed. Production readiness later requires:

- deterministic unit tests for every decision branch and malformed provider result;
- recorded fixtures for EVM and Solana honeypots, mutable taxes, proxies, Token-2022 extensions,
  low liquidity, clusters, bundles, and stale/contradictory scans;
- fork or chain simulation proving exact entry and exit deltas;
- signer tests proving mismatched/expired/replayed artifacts cannot execute;
- sandbox or paper-trading runs proving no transaction is sent on any `BLOCK` path;
- user-visible reports that match the machine artifact and do not hide failed checks.

No live capital should be used as the validation mechanism. Security gating can reduce avoidable
losses, but strategy profitability requires a separate evidence-backed backtest, paper-trading, and
live-risk evaluation.
