# Source and Collection Playbook

Use this playbook for a current market assessment. The objective is not to collect every available
metric; it is to obtain independent, timely evidence for the decision-driving layers.

## Source priority

Prefer sources in this order:

1. Binance public market data and status/announcement pages; central banks, statistics agencies,
   regulators, fund issuers, protocol foundations, chain explorers, and original project channels.
2. Transparent institutional or specialist datasets with a stated methodology, such as ETF-flow,
   derivatives, stablecoin, or on-chain providers.
3. Reputable financial and crypto newsrooms that link to the original event.
4. X posts, aggregators, influencer commentary, and anonymous claims.

Use the original source for factual events whenever possible. Two articles quoting the same filing or
post are one origin. Keep source URLs next to the claims they support.

## Minimum evidence by layer

### Market regime and macro

Collect the latest available values, trend, and scheduled releases relevant to the requested
horizon:

- Federal Reserve policy expectations and major central-bank surprises;
- US inflation, labor, and growth releases;
- US dollar, Treasury nominal/real yields, global liquidity proxies, and broad financial conditions;
- Nasdaq/S&P risk tone, volatility, gold, and oil when they are actually explanatory;
- crypto-wide capitalization, BTC dominance, stablecoin supply/flows, and material ETF flows;
- regulatory, custody, exchange, stablecoin, exploit, or geopolitical events with market impact.

Do not infer causation from same-day correlation alone. Distinguish the release timestamp from the
article timestamp and state whether the market has already reacted.

### Binance spot and market structure

For each asset, collect or calculate from current candles and order-book data where available:

- last price, 24-hour change, volume, high/low, and timestamp;
- 15m/1h/4h/1d/1w structure as appropriate to the requested horizons;
- swing highs/lows, support/resistance, breakout/retest state, volume confirmation, and ATR or
  another explicit volatility measure;
- volume-weighted reference levels and moving averages only when they clarify structure;
- spread, depth, imbalance, and likely slippage when discussing a concrete entry or exit;
- BTCUSDT, ETHUSDT, BNBUSDT plus ETHBTC and BNBBTC for relative strength.

Indicators derived from the same OHLCV series are correlated evidence, not independent votes. A
cluster of RSI, MACD, and moving-average signals must not masquerade as three separate confirmations.

### Derivatives and leverage

Use Binance derivatives data first and a second transparent provider when material:

- perpetual funding level and trajectory;
- open interest level and change, interpreted jointly with price;
- futures basis/term structure where available;
- taker buy/sell activity, long/short ratios, and liquidation concentrations;
- options implied volatility, skew, and major expiry positioning when reliable data is accessible.

Interpret common combinations explicitly:

- price up + OI up: new leveraged risk; bullish only if funding/crowding and spot demand permit;
- price up + OI down: short covering or deleveraging; continuation needs spot confirmation;
- price down + OI up: new shorts or trapped longs; liquidation risk rises;
- price down + OI down: long liquidation/de-risking; watch for exhaustion, not an automatic bottom.

Do not equate exchange-published account ratios with market-wide position size.

### Flows, on-chain, and asset fundamentals

Use only metrics whose definition and update frequency are understood. Prefer trend and context over
isolated large-transfer alerts.

- BTC: spot ETF flows, exchange netflows, long-term-holder/miner behavior, realized-profit or cost-
  basis context, network activity, and BTC dominance.
- ETH: spot ETF flows, staking deposits/exits and queue, issuance/burn, fees and activity, L2 context,
  protocol upgrades, and ETH/BTC strength.
- BNB: Binance operational/regulatory events, BNB burn mechanics and confirmed burns, Launchpool or
  ecosystem catalysts, BNB Chain activity/fees/TVL/stablecoin flows, security incidents, and BNB/BTC
  strength.

Exchange inflows or whale transfers are ambiguous without address classification, destination,
subsequent behavior, and historical context. Mark unsupported attribution as unknown.

## X collection and interpretation

Use a permitted signed-in browser session when necessary; otherwise use public search/indexed pages.
Do not bypass access controls. State whether coverage is direct, search-indexed, sampled, or absent.

### Query design

For each asset and observation window, query names, tickers, cashtags, common narratives, and the
specific catalyst under investigation. Include negative and neutral terms so the collection is not
confirmation-biased. Examine at least:

- official exchange/project/regulator/issuer accounts;
- domain specialists, researchers, on-chain analysts, and reputable reporters;
- broad trader and retail discussion;
- counter-narratives, corrections, and scam/impersonation warnings.

Use recent chronological results where possible, not only algorithmic top posts. Compare a short
window (hours/one day) with a longer baseline (several days or weeks). Report the inspected window,
approximate usable sample, and access limitations; do not claim population-level sentiment from a
small convenience sample.

### Social dimensions

Evaluate separately:

- attention level and acceleration relative to baseline;
- sentiment direction and intensity;
- breadth across independent communities/accounts;
- source credibility and proximity to the claimed event;
- dominant narratives and whether they are new, recycled, or already priced;
- engagement quality and evidence of disagreement;
- likely coordination: duplicated wording, synchronized timestamps, repetitive hashtags, newly
  created accounts, low-quality followers, or engagement detached from substantive replies;
- price/social divergence, such as euphoric attention with weakening spot demand.

Reposts, quote-post chains, translations, screenshots, and news accounts repeating one origin count
as one narrative lineage. Label rumors as unconfirmed, locate the earliest available origin, seek an
official confirmation or contradiction, and prevent rumor-only evidence from becoming a trade call.

Assign a non-zero X score only when the report discloses the time window, approximate deduplicated
usable sample, access/coverage type, and evidence from multiple independent source classes. Search
snippets, algorithmic top posts, or a very small convenience sample may establish that a narrative
exists, but cannot establish broad sentiment, breadth, or attention acceleration; mark those
properties `unknown` and keep the X contribution weak or `N/A`. Do not invent a universal minimum
post count, because representativeness depends on the query, horizon, and access mode.

## Freshness guide

These are maximum expectations for a live verdict, not promises that a source updates this often:

| Evidence | Target freshness |
|---|---:|
| Price, candles, spread, order book | 5 minutes or less |
| Funding, open interest, basis | 15 minutes or less |
| Liquidations and fast social/news pulse | 1 hour or less |
| ETF/fund flows, exchange flows, on-chain aggregates | latest completed reporting period |
| DXY, yields, equity indexes, volatility | current market session, or latest close when shut |
| Macro releases and official events | latest release, with exact release time |
| Event calendar | rechecked on the report date |

Always state UTC plus the user's local time for the report snapshot. If a category cannot meet the
relevant freshness expectation, mark it stale and lower data completeness; do not silently reuse an
old value.

## Collection stop condition

Stop gathering when each decision-driving layer has a timely primary or best-available source, the
next material event is known, the main bull and bear explanations have been tested, and additional
sources repeat existing origins. More headlines do not automatically improve confidence.
