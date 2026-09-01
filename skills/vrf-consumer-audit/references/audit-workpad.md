# Audit workpad

Use this as working evidence for a multi-object/provider VRF review. Omit inapplicable fields; never fill
unknown values from memory. The final report should summarize conclusions rather than dump this worksheet.

```yaml
scope:
  repository_ref: ""
  contracts: []
  chain_and_deployment: "source-only | fork | deployed"
  assets_and_value_at_risk: []
  fairness_and_liveness_policy: []
  explicit_non_goals: []

provider:
  name_version_mode: ""
  resolved_dependency: ""
  coordinator_or_wrapper: ""
  request_id_type_namespace_and_scope: ""
  callback_auth_boundary: ""
  callback_timing_and_reentrancy: ""
  delivery_retry_semantics: ""
  live_configuration_evidence: []
  unknowns: []

business_commitments:
  - id: "round | mint | order | batch"
    outcome_inputs: []
    freeze_or_snapshot_proof: []
    accepted_request_cardinality: ""
    accepted_source_membership: []
    entropy_combination_rule: ""
    terminal_effects: []

request_surfaces:
  - function: "file:line"
    caller: ""
    pre_state: ""
    request_call_failure_state: ""
    returned_id_binding: ""
    post_state: ""
    payment_and_external_calls: []

callback_surfaces:
  - function: "file:line"
    provider_caller_check: ""
    request_to_commitment_lookup: ""
    accepted_states: []
    max_work_and_gas_evidence: []
    external_calls_and_revert_branches: []
    duplicate_late_unknown_callback_behavior: ""

consumption:
  randomness_inputs_and_actors: []
  encoding_hash_cast_steps: []
  bounds_and_snapshots: []
  multi_draw_uniqueness_policy: ""
  settlement_or_claim_path: []
  exactly_once_guards: []

exception_paths:
  retry_cancel_timeout_refund: []
  pause_upgrade_migration_source_swap: []
  underfunding_callback_failure_recipient_failure: []
  stale_callback_after_next_commitment: ""

hypotheses:
  - title: ""
    evidence_status: "confirmed | conditional | defense-in-depth | false positive | unresolved"
    violated_invariants: []
    reachable_transition_trace: []
    impact_and_attacker_control: ""
    code_test_runtime_evidence: []
    missing_evidence: []

validation:
  existing_tests_run: []
  disposable_poc: []
  project_tests_added_with_authorization: []
  untested_invariants: []
```
