# Multi-Horizon Analysis Framework

Use this framework to turn current evidence into a transparent, conditional judgment. Do not use a
score when the underlying evidence is too stale or incomplete to justify one.

## 1. Classify the regime first

Describe the joint state of:

- liquidity: easing, neutral, or tightening;
- risk appetite: risk-on, mixed, or risk-off;
- crypto breadth: broad participation, BTC-led, narrow alt rotation, or broad deterioration;
- volatility: compression, orderly trend, expansion, or disorderly liquidation;
- leverage: clean, building, crowded, or deleveraging;
- event risk: ordinary, elevated, or binary/imminent.

This classification constrains individual-asset conviction. For example, a bullish chart in a
tightening, risk-off, crowded-leverage regime may remain a tactical rather than medium-term buy.

## 2. Score independent dimensions

Score each dimension from -2 to +2 and show the raw fact that justifies the score:

- `+2` strongly bullish and independently supported;
- `+1` moderately bullish;
- `0` neutral or balanced;
- `-1` moderately bearish;
- `-2` strongly bearish and independently supported.

Use `N/A` for unknown. Unknown evidence is excluded from both the weighted numerator and the
supported-weight denominator; it is never a neutral observation.

Use these default weights only when the user has not specified a different horizon:

| Dimension | Short 4–24h | Swing 2–14d | Medium 1–3m |
|---|---:|---:|---:|
| Macro/liquidity | 10% | 15% | 25% |
| Cross-asset/crypto regime | 10% | 15% | 15% |
| Spot structure and volume | 25% | 25% | 15% |
| Derivatives positioning | 20% | 15% | 5% |
| Flows/on-chain/fundamentals | 10% | 15% | 25% |
| Verified events/news | 10% | 10% | 10% |
| X attention/sentiment | 15% | 5% | 5% |

Calculate the weighted mean on the -2 to +2 scale, but present it as an audit aid rather than a
forecast probability:

- `>= +1.0`: strong up bias;
- `+0.35 to +0.99`: up bias;
- `-0.34 to +0.34`: range/unclear;
- `-0.99 to -0.35`: down bias;
- `<= -1.0`: strong down bias.

If a dimension is unknown, do not quietly score it neutral. Mark it `N/A`, renormalize only when
at least 70% of the horizon's weight is supported by fresh evidence, and lower confidence. Never let
X evidence alone move the final label across two bands.

## 3. Apply confirmation and veto rules

An actionable bullish posture normally requires at least two independent confirmations, including
one from spot price/volume or flows. An actionable bearish posture similarly needs actual price/flow
deterioration or a verified adverse catalyst; crowded positive sentiment alone is not a short signal.

Override the numeric label to `wait` or `event-risk only` when any of these applies:

- current spot or derivatives data is missing/stale;
- a central factual claim is an unconfirmed rumor;
- a major binary release, court/regulatory decision, upgrade, exchange incident, or macro event is
  close enough to dominate the requested horizon;
- exchange/API sources disagree materially and the discrepancy is unresolved;
- strong evidence layers point in opposite directions and the user's horizon does not break the tie;
- the proposed trade has no defensible invalidation or acceptable exit liquidity.

The score describes direction. The veto controls actionability.

## 4. Diagnose divergences

Explicitly inspect these high-value conflicts:

- price vs spot volume;
- price vs open interest/funding;
- price vs exchange/ETF flows;
- BTC strength vs ETH/BTC and BNB/BTC;
- social excitement vs verified news and spot demand;
- macro risk appetite vs crypto-specific catalysts;
- breakout price vs order-book depth and follow-through.

State the leading interpretation and at least one plausible alternative. A divergence is a question
to resolve, not automatically a reversal signal.

## 5. Build scenarios and a posture

For each horizon, provide:

- **Base case:** the currently best-supported path and observable confirmation.
- **Bull case:** the trigger that upgrades direction and the next meaningful structure/volatility
  objective.
- **Bear case:** the invalidation or downside trigger and the next meaningful risk area.

Map scenarios to a conditional posture:

- `buy-on-confirmation`: price and independent evidence confirm a breakout or reversal;
- `buy-on-pullback`: the higher-timeframe thesis remains intact and a defined support/retest holds;
- `hold`: thesis remains intact but fresh risk/reward is not attractive enough for new entry;
- `wait`: evidence is neutral, incomplete, event-dominated, or conflicted;
- `reduce`: downside risk or crowding rose while the thesis weakened;
- `exit`: the user's stated thesis or a clearly defined structural invalidation has failed;
- `hedge candidate`: downside event risk is meaningful, but specify that hedging cost and user
  constraints are unknown unless supplied.

Do not invent price levels. Derive them from the current market structure, volatility, liquidity,
and requested timeframe, then timestamp them.

## 6. Confidence and completeness

Report both:

- **Confidence:** high, medium, low—how strongly the available independent evidence supports the
  directional conclusion.
- **Data completeness:** percentage of configured horizon weight supported by timely evidence, plus
  named missing layers.

High confidence requires fresh core data, multiple independent confirmations, no unresolved central
contradiction, and no imminent binary veto. A strong score with incomplete data is not high
confidence.

If numeric probabilities are requested, give a range and explain that it is a calibrated judgment,
not a statistically estimated probability unless a tested model and its out-of-sample record are
actually available.

## 7. Position sizing when requested

Require the user's capital base, maximum loss for the idea, current position, entry basis, and
leverage constraints. Use:

`position size = maximum idea loss / (entry price - invalidation price)`

Adjust for fees, slippage, funding, and gaps. A stop order is not guaranteed execution at the stop
price. Never substitute a universal allocation or leverage recommendation for missing user inputs.
