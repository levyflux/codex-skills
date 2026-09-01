---
name: auto-token-trade-safety-gate
description: Apply a deterministic, fail-closed pre-trade gate to proposed automated new-token buys, snipes, swaps, and launchpad entries. Use before any bot or workflow may hand an exact EVM or Solana trade to a wallet; it gathers current security, simulation, liquidity, cluster, route, and policy evidence and returns PASS or BLOCK, but never signs or broadcasts.
---

# Auto Token Trade Safety Gate

Protect an automated trading workflow from known contract, liquidity, manipulation, route, and
wallet traps. This gate reduces observable risk; it does not predict price, establish positive
expected value, guarantee profit, or prove that an unflagged token is safe.

## Boundary

- This skill is **read-only**. It must not approve, sign, send, swap, snipe, broadcast, or pass
  `--force`.
- A `PASS` authorizes only the next workflow stage to request execution. It is not transaction
  authorization and does not replace the wallet or signer workflow's confirmation requirements.
- The user's future goal of automated profit is not standing authorization for any transaction,
  wallet policy, budget, or threshold.
- Do not expose credentials, private keys, session material, raw signed transactions, or secrets in
  gate evidence or audit artifacts.

## Load the relevant contract

- For every concrete gate decision, read
  [references/gate-contract.md](references/gate-contract.md).
- Read [references/chain-checks.md](references/chain-checks.md) for the candidate's exact chain and
  token standard; do not load irrelevant chain sections.
- Read [references/policy-and-audit.md](references/policy-and-audit.md) when defining the automation
  policy, integrating the gate into a workflow, or designing post-trade monitoring.

## Evidence providers

Use available skills and tools as evidence providers rather than copying their command catalogs:

- `new-token-risk-analysis` for the full risk frame and evidence calibration.
- An installed market-data capability for current liquidity, holders, clusters, trades, developer
  history, bundles, snipers, and launch state.
- An installed wallet-security capability for token, DApp, transaction, signature, approval, quote,
  and simulation security. Preserve any provider-classified verdicts.
- A named protocol capability or current official documentation for protocol-native rules and exact
  route construction.
- Current chain state, verified deployed source, and an owning contract-audit workflow for contract,
  proxy, deployment, or invariant claims.

When a named provider is unavailable, use another authoritative source only if it supplies the same
identity, freshness, and schema guarantees. Otherwise record the evidence as unavailable and `BLOCK`.

Run standalone security and market checks before entering an execution flow. The generic wallet
workflow may allow a time-sensitive swap to continue after a scan failure; this autonomous gate is
stricter: **unavailable or incomplete security evidence is `BLOCK`**.

## Decision model

Return exactly one executable decision:

- `PASS` — every required check completed, all evidence is fresh under an explicit policy, all
  upstream actions are acceptable for unattended execution, and the artifact is bound to one exact
  proposed transaction.
- `BLOCK` — any failure, warning, ambiguity, unsupported feature, stale or contradictory result,
  missing policy, or changed transaction parameter. Include machine-readable reasons.

There is no autonomous `WARN`, `PAUSE`, `REVIEW`, or manual-override state. For an unattended trade:

- token-scan `warn`, `pause`, or `block` => `BLOCK`;
- transaction/signature scan `warn` or `block` => `BLOCK`;
- quote/route action other than `ok` => `BLOCK`;
- scanner/API failure, unsupported chain, missing result, or unrecognized schema => `BLOCK`;
- a top-level verdict that conflicts with any per-token result, address identity, or native-token
  classification => invalid evidence => `BLOCK`.

Do not recompute an upstream security verdict from raw labels. Validate identity and schema, retain
the upstream verdict, and reject contradictory output.

## Required flow

1. **Bind identity** — exact chain ID, full token/mint address, token program/standard, quote asset,
   venue, pool, router/program, wallet, direction, amount, slippage, minimum output, value, deadline,
   and policy version. A name or symbol is insufficient.
2. **Collect fresh evidence** — chain head, token and DApp scans, contract permissions, liquidity,
   curve/LP state, holders and clusters, bundles, developer history, trades, quote, and simulations.
3. **Prove entry and exit** — simulate the exact buy route and establish a supported sell path under
   the same current state. If the tool cannot model the sell path without first spending funds,
   `BLOCK`; never use a live purchase as the safety test.
4. **Evaluate executable liquidity** — measure price impact, tax, and slippage for the proposed size,
   not just pool TVL. Internal curve liquidity and external DEX liquidity are different venues.
5. **Evaluate control and manipulation** — inspect circulating-supply concentration, top-holder
   clusters, common funding, bundles, creator holdings/history, wash trading, and net quote inflow.
6. **Validate wallet and route** — allowlisted venue/router/program/spender, exact recipient,
   bounded approval, gas/priority constraints, calldata/instruction semantics, transaction scan, and
   successful final simulation.
7. **Apply explicit policy** — budget, exposure, liquidity, concentration, age, slippage, loss,
   concurrency, data freshness, and retry constraints must come from a versioned policy. Missing
   product-policy values are `BLOCK`, not invitations to invent defaults.
8. **Emit and bind the artifact** — record every check and bind `PASS` to the exact unsigned
   transaction intent. Any later change invalidates the artifact and requires a full re-gate.

## Universal blockers

Block regardless of strategy thresholds when any of these applies:

- chain/address/token-program mismatch, empty code/account, spoofed symbol resolution, or ambiguous
  asset identity;
- detected honeypot, blocked sell, arbitrary seizure, or an unbounded/mutable critical authority
  outside the explicit policy;
- exact buy or sell path cannot be simulated successfully, or actual token/quote deltas cannot be
  established;
- scan or simulation failure, stale/partial data, contradictory verdicts, or a required provider is
  unavailable;
- route, router/program, spender, recipient, fee payer, value, calldata/instructions, deadline, or
  quote changed after gating;
- unlimited approval, arbitrary call target/recipient, unbounded calldata, or a signer request that
  is not the gated intent;
- policy missing, expired, exceeded, or not bound to the candidate wallet and strategy;
- the candidate requires ignoring a security warning or treating missing evidence as safe.

LP lock, graduation, renounced authorities, high holder count, low top-10 concentration, or a
scanner `safe` result may mitigate individual risks but cannot independently produce `PASS`.

## Output

Lead with `PASS` or `BLOCK`. Return a structured gate artifact plus a concise user-facing summary:

- asset and exact transaction identity;
- policy ID/version and evidence timestamps/chain heads;
- each required check with `pass`, `fail`, `stale`, `unavailable`, or `not_applicable`;
- decisive reasons and unresolved evidence;
- executable entry/exit deltas, fees, taxes, slippage, and liquidity findings;
- artifact expiry and every field whose change requires re-gating;
- explicit statement that `PASS` is not transaction authorization.

Never hide failed checks behind an aggregate score. Retain raw provider references and normalized
facts without storing secrets.
