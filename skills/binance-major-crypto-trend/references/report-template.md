# Full Report Template

Use the user's language. Keep the first screen decision-focused and put supporting detail below it.

## Snapshot

State:

- report time in UTC and user-local timezone;
- assets, venue, quote currency, horizons, and data cutoff;
- one-line market regime and the next material scheduled event.

Show only the requested horizon columns. A default full report uses:

| Asset | Current price/time | 4–24h | 2–14d | 1–3m | Conditional posture | Confidence / completeness |
|---|---|---|---|---|---|---|
| BTC | ... | direction | direction | direction | trigger + invalidation | ... |
| ETH | ... | direction | direction | direction | trigger + invalidation | ... |
| BNB | ... | direction | direction | direction | trigger + invalidation | ... |

If a verdict is vetoed, write `wait—event risk`, `wait—stale data`, or the actual reason rather than
burying it below the table.

## Market regime

Summarize liquidity, cross-asset risk appetite, crypto breadth/dominance, volatility, leverage, ETF
or stablecoin flows, and the event calendar. Identify what changed since the comparison point if the
user asked for an update.

## Asset evidence cards

For each asset include only decision-relevant facts:

1. spot structure, volume, support/resistance, and relative pair;
2. derivatives: funding, OI/price combination, basis/liquidation or options when relevant;
3. flows/on-chain/fundamental catalyst;
4. verified news and event risk;
5. X pulse: window, usable sample/coverage, attention, sentiment, narrative, credibility,
   coordination risk, and price/social divergence;
6. dimension score table with the raw fact behind each non-zero score;
7. base/bull/bear scenario, trigger, invalidation, and what would change the conclusion.

## Cross-asset ranking

Rank BTC, ETH, and BNB for the requested horizon by evidence-supported relative strength. Explain
whether the ranking reflects genuine asset-specific strength or merely higher beta to BTC. Do not
rank an asset with materially poorer data as if confidence were equal. The valid conclusion may be
`none qualify`; relative first place does not itself mean the asset is buyable.

## Risk and execution context

State the dominant failure modes: macro gap risk, liquidation cascade, crowded positioning,
exchange/regulatory incident, exploit, headline reversal, thin depth, or social manipulation. If a
concrete trade plan was requested, include current spread/slippage context, invalidation mechanics,
and the user's loss budget; otherwise keep it as a conditional posture rather than personalized
position sizing.

## Evidence ledger

List source, observation, source timestamp, retrieval timestamp, evidence tier, and affected
conclusion. Group multiple observations from the same origin. Close with missing/stale data and what
was not verified.

End with one sentence: this is a timestamped conditional assessment, not a guarantee or a substitute
for the user's risk limits.
