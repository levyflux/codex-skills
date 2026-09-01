---
name: binance-major-crypto-trend
description: Analyze BTC, ETH, BNB, and other liquid Binance-listed major cryptocurrencies using current macro, spot, derivatives, flows, on-chain, news, event, and X sentiment evidence. Use for trend, up/down probability, buy/hold/reduce/wait posture, relative-strength comparison, or recurring market brief requests; this skill is analysis-only and never places trades.
---

# Binance Major Crypto Trend

Produce a current, multi-horizon market judgment without turning one indicator, viral post, or
headline into a trade call. Default to BTC, ETH, and BNB quoted in USDT when the user does not name
assets. This skill is read-only: never log into an exchange, place or cancel an order, sign a
transaction, change an account, or claim that monitoring will continue unless the user explicitly
requests a supported automation.

## Load the relevant guidance

- Read [references/source-playbook.md](references/source-playbook.md) for every current market
  assessment. It defines source priority, freshness, X collection, and asset-specific evidence.
- Read [references/analysis-framework.md](references/analysis-framework.md) when producing an
  up/down judgment, trading posture, score, scenario, entry/invalidation plan, or cross-asset rank.
- Read [references/report-template.md](references/report-template.md) for a full brief or recurring
  report. A narrow conceptual question does not need the full template.

## Establish the request

Infer reasonable defaults instead of blocking:

- assets: BTC, ETH, BNB;
- venue: Binance spot plus Binance USD-M perpetuals as positioning evidence;
- horizons: short 4–24 hours, swing 2–14 days, medium 1–3 months;
- quote and timezone: USDT and the user's local timezone, while retaining UTC source timestamps;
- output: direction, confidence, conditional posture, triggers, invalidation, and risks.

State any meaningful assumption. Ask only when the user wants personalized sizing or an exact plan
and account size, current position, maximum acceptable loss, leverage constraints, or horizon would
materially change the answer.

## Current-data requirement

Browse or query current sources for every live verdict. Record the observation time and source time
where available. A remembered price, stale screenshot, search-result snippet, or model knowledge is
not current market evidence.

If either current core spot price/volume or current derivatives data is missing or stale, do not
emit a current short/swing buy/sell or up/down verdict. Give the available structural analysis,
label the missing layer, and state what data would unlock a verdict. When X access is partial,
continue with a market assessment but label social coverage and lower only the confidence
attributable to that layer.

## Evidence contract

Classify material claims as:

1. **Verified fact** — current exchange/API data, official release, regulator filing, protocol or
   chain state, or a directly inspected public statement.
2. **Supported inference** — multiple independent, timely observations favor one explanation.
3. **Weak signal** — plausible but noisy, single-source, socially amplified, or historically
   unstable.
4. **Unknown** — missing, stale, inaccessible, or unable to distinguish alternatives.

Name the evidence layer. Market price, positioning, macro, on-chain, news, and social evidence are
not interchangeable. Mirrored articles, reposts, translated copies, and accounts repeating the same
origin are one source, not independent confirmation.

## Required analytical posture

- Determine the market regime before judging individual assets.
- Analyze spot price/volume separately from leveraged positioning. Rising price with rising open
  interest and positive funding is different from rising price led by spot demand.
- Use multiple timeframes; do not let a 15-minute move define a 1–3 month view.
- Compare ETH/BTC and BNB/BTC as well as USDT pairs so a nominal rise is not mistaken for relative
  strength.
- Treat X as a narrative, attention, and reflexivity signal—not proof of facts or a standalone
  trading trigger. Separate credible sources, broad organic discussion, retail emotion, and likely
  coordinated amplification.
- Separate direction from confidence and confidence from data completeness.
- Give bull, base, and bear paths with observable triggers. Every actionable posture needs a
  falsification or invalidation condition.
- Never promise returns or present a probability with false precision. Prefer calibrated ranges or
  qualitative likelihoods tied to evidence.
- Do not use universal leverage, stop-loss, take-profit, or allocation values. Derive levels from
  current structure and volatility. Without a user loss budget, show the sizing formula rather than
  inventing a position size.

## Decision boundary

Translate evidence into both a directional label and a conditional posture:

- direction: strong up, up, range/unclear, down, or strong down;
- posture: buy-on-confirmation, buy-on-pullback, hold, wait, reduce, exit, or hedge candidate.

`Event-risk only` means no new directional position for the affected horizon before the event; wait
for post-event spot confirmation plus one independent evidence layer. Apply this veto per horizon: a
4–24 hour event does not automatically veto the 2–14 day or 1–3 month view unless its consequences
can plausibly dominate those horizons.

Do not issue an unconditional imperative. A posture must specify horizon, trigger, invalidation,
and the evidence that would change it. If the user already holds an asset, distinguish hold/reduce/
exit analysis from a fresh entry; ignore the purchase price as a reason to hold.

Force the posture to `wait` or `event-risk only` when a decisive claim is unverified, a binary event
is imminent, required data is stale, or major evidence layers conflict without a defensible tie
breaker. Social enthusiasm alone can never upgrade an asset to a buy.

## Delivery

Lead with the timestamped verdict table, then explain the few facts that actually drive it. Include:

- market regime and next known risk events;
- per-asset direction and confidence for each requested horizon;
- conditional posture, trigger, invalidation, and upside/downside scenario levels when supported;
- spot-versus-derivatives diagnosis and relative-strength comparison;
- macro, flow/on-chain, news, and X findings with confidence labels;
- data coverage, freshness, conflicting evidence, and source links;
- a concise risk note stating that the result is a conditional market assessment, not guaranteed
  personalized financial advice.

If the user asks for continuous monitoring, define the assets, cadence, alert conditions, timezone,
and delivery scope, then use the supported automation mechanism. Do not imply future monitoring from
a one-time report.
