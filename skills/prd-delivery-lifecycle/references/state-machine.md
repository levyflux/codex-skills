# Requirement and feedback state machine

## Requirement states

```text
draft -> reviewed -> authorized -> implementing -> verifying -> accepted -> release-ready
```

Any state may move to `blocked` when a required decision, authority, dependency, or evidence layer is missing. `superseded` preserves history when a newer requirement replaces the current one.

## Feedback classification

Classify every reported issue as one of:

- `confirmed defect` — authoritative expected behavior and current mismatch are both established;
- `specification ambiguity` — plausible intended behaviors cannot be distinguished;
- `change request` — current behavior matches the accepted requirement but a different outcome is desired;
- `accepted behavior` — surprising but explicitly intended;
- `false positive` — the claimed mismatch is disproven;
- `unresolved` — evidence is insufficient.

Only a confirmed defect with unambiguous intended behavior proceeds directly to implementation.

## Selective invalidation

When a node changes, invalidate its affected descendants:

```text
REQ -> DEC -> CONTRACT -> TEST -> SLICE -> VERIFY -> RELEASE
```

Examples:

- wording-only clarification may invalidate no implementation nodes;
- contract change invalidates related tests, slices, verification, and release evidence;
- test correction invalidates verification but not necessarily the requirement or decision;
- deployment-target change invalidates runtime and release evidence even when source is unchanged.

Record the reason, impacted identifiers, decision owner, and checks required to restore each invalidated node.
