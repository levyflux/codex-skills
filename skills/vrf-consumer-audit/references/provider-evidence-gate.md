# Provider evidence gate

Use this for an unfamiliar or non-Chainlink EVM randomness provider before making provider-specific
findings. Official docs are discovery evidence; resolve the exact interface/base implementation used by
the build and, for runtime claims, the deployed contract/configuration.

## Evidence card

```yaml
provider: ""
product_and_version: ""
funding_mode: "subscription | prepaid | per-request | other"
resolved_dependency: "package + tag/commit"
request_entrypoint: ""
request_identifier: "type, uniqueness, namespace, and collision behavior across providers/versions"
request_commitment: "seed, caller, business object, provider, callback selector"
callback_entrypoint: ""
callback_authentication: "caller/proof/base-contract boundary"
callback_arguments: "identifier, provider, words, metadata"
callback_timing_and_reentrancy: "separate transaction guarantee or synchronous callback possibility"
delivery_semantics: "at-most-once | retrying | permissionless replay | unknown"
retry_semantics: "failure classes, bounds, fees, idempotence requirements"
cancellation_and_expiry: ""
pending_request_migration: "provider/config/upgrade behavior"
confirmations_or_finality: ""
gas_and_payment_failure: ""
allowlist_and_admin_roles: ""
client_seed_or_user_entropy: "who chooses, when committed, replay/grinding limits"
live_evidence_required: []
unknowns: []
```

Stop provider-specific conclusions when callback authentication, request-ID namespace, callback timing,
or delivery/retry semantics remain unknown. Continue reviewing provider-independent application
invariants and label the provider dependency `unresolved`.

Label the mechanism accurately. The application invariants also help with commit-reveal randomness such
as Pyth Entropy, but that does not make every verifiable randomness service a cryptographic VRF. Do not
transfer proof, unpredictability, or trust claims between mechanisms.

## Why the adapter must be versioned

Provider semantics materially differ:

- Current Chainlink VRF V2.5 documentation says a reverted consumer callback is not automatically called
  again. Use [chainlink.md](chainlink.md) and verify the resolved release.
- Supra dVRF 3.0 documentation describes bounded automatic retry for some callback failures. Verify the
  deployed version and exact failure classes instead of importing Chainlink's at-most-once assumption.
- Pyth Entropy exposes a sequence number and provider address to its callback, supports multiple provider
  choices, and documents that callback occurs in a separate provider-submitted transaction. Preserve the
  provider namespace when correlating requests. Verify the SDK/base contract and callback status before
  deciding idempotence or liveness.

Official live references:

- Chainlink VRF security: https://docs.chain.link/vrf/v2-5/security.md
- Supra EVM request/callback: https://docs.supra.com/dvrf/build-third-party-evm-networks/request-random-numbers
- Supra dVRF 3.0 migration/retry: https://docs.supra.com/dvrf/build-third-party-evm-networks/migration-to-dvrf-3.0
- Pyth Entropy EVM callback: https://docs.pyth.network/entropy/generate-random-numbers-evm
- Pyth callback debugging: https://docs.pyth.network/entropy/debug-callback-failures
- EVM `PREVRANDAO` security model: https://eips.ethereum.org/EIPS/eip-4399

These links are volatile inputs, not frozen configuration. Record access date and source revision when
promoting a provider claim into a reusable case card.
