# Gate contract

Use this contract for every concrete pre-trade decision. The workflow may add fields, but it must
not weaken the invariants below.

## Required inputs

The request must resolve all fields before evaluation:

- `chain_id`, chain family, full token/mint address, token standard/program;
- quote asset and exact direction (`buy` or `sell`);
- wallet/account intended to trade;
- launch venue or DEX, pool/curve, router/program, and spender where applicable;
- exact input amount, expected output, `min_out`, slippage, transaction value, fee/gas/priority
  constraints, recipient, and deadline;
- strategy ID, policy ID/version, policy validity window, and remaining budget/exposure;
- unsigned calldata or complete Solana instruction set when the final route already exists.

Names, symbols, UI labels, estimated market cap, or an abbreviated address cannot substitute for
identity. Missing required input produces `BLOCK: missing_input`.

## Evidence producers

Collect current evidence from the owning capability:

| Evidence | Producer | Required consumer |
|---|---|---|
| Token/DApp/tx/signature/approval verdicts and simulation | installed wallet-security capability | gate, signer boundary |
| Price, pools, holders, clusters, trades, developer and bundle data | installed market-data capability | gate, strategy, monitor |
| Protocol launch/route rules | named protocol capability or current official documentation | gate, route builder |
| Contract/source/deployment evidence | chain state or owning audit skill | gate, incident review |
| Wallet budgets and allowlists | versioned user-owned policy | gate, signer boundary |

Every evidence item records provider, request/snapshot time, chain head when available, normalized
facts, raw result reference, completeness, and expiry. Provider success text is not enough: validate
that the result belongs to the exact chain/address and expected schema.

## Decision states

Individual checks use:

- `pass` — completed and satisfies the versioned policy;
- `fail` — completed and violates a universal or configured gate;
- `stale` — completed but no longer fresh;
- `unavailable` — unsupported, failed, timed out, malformed, or incomplete;
- `not_applicable` — justified by the exact venue/standard, never used to skip a difficult check.

The executable decision is binary. `PASS` requires every required check to be `pass` or a justified
`not_applicable`. Every other state produces `BLOCK`.

## Minimum artifact

Emit a serializable artifact with this logical shape:

```json
{
  "schema_version": 1,
  "decision": "PASS|BLOCK",
  "gate_id": "implementation-generated",
  "created_at": "timestamp",
  "expires_at": "policy-derived timestamp",
  "policy": { "id": "...", "version": "..." },
  "strategy_id": "...",
  "subject": {
    "chain_id": "...",
    "token_address": "...",
    "quote_address": "...",
    "direction": "buy|sell",
    "wallet_address": "..."
  },
  "intent_binding": {
    "venue": "...",
    "pool_or_curve": "...",
    "router_or_program": "...",
    "spender": "...",
    "recipient": "...",
    "amount_in": "...",
    "min_out": "...",
    "value": "...",
    "deadline": "...",
    "unsigned_intent_hash": "..."
  },
  "evidence": [],
  "checks": [],
  "reasons": [],
  "authorization": "NOT_GRANTED"
}
```

The future workflow must define canonical serialization and hashing. Until it does, do not claim
that a text artifact cryptographically binds a transaction.

## Invalidation

Invalidate `PASS` and run the full gate again if any bound field, policy version, chain head
freshness, quote, simulation result, pool reserve, contract authority, tax, route, allowance,
recipient, amount, `min_out`, value, deadline, calldata/instruction, or wallet changes.

The execution consumer must compare the final unsigned intent with the artifact immediately before
requesting a signature. A signer must reject absent, expired, `BLOCK`, mismatched, or already-used
gate artifacts. Replay protection and one-time consumption belong in the future workflow design.

## Retry and fallback

No fallback may turn missing evidence into `PASS`. Retry limits, backoff, alternate providers, and
maximum decision latency are product-policy values. If no versioned retry policy exists, do not
retry automatically. A provider disagreement is contradictory evidence and produces `BLOCK` until
resolved by a named authoritative source.

## Consumers and stopping conditions

Expected consumers are candidate discovery, risk gate, route builder, execution planner, wallet
signer, position monitor, audit log, and incident review. Only the signer/execution workflow may
mutate chain state, and only after its own authorization contract is satisfied.

The gate stops after emitting one artifact. It must not chase a candidate indefinitely, loosen a
policy to obtain `PASS`, try a smaller live transaction as a test, or proceed to execution.
