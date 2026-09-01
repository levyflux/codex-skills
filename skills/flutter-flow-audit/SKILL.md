---
name: flutter-flow-audit
description: Audit a Flutter user flow across routes, screens, state owners, services, SDK callbacks, async boundaries, and lifecycle cleanup. Use for read-only diagnosis of cross-screen state bugs, stale UI, duplicated subscriptions, navigation races, reconnect behavior, or business-flow regressions; do not use static inspection alone as runtime proof.
---

# Flutter Flow Audit

Build a source-backed state-and-event model for one user flow, then classify mismatches without assuming every suspicious pattern is a defect.

Read [invariants-and-transitions.md](references/invariants-and-transitions.md) while constructing the model.

## Audit workflow

1. Establish the user-visible entry point, expected outcome, supported platforms, and authoritative behavior source.
2. Trace routing forward from the entry and backward from the affected screen.
3. Identify state owners: widgets, controllers, providers, BLoCs, repositories, services, SDKs, storage, and platform channels.
4. Enumerate events and async boundaries: initialization, callbacks, streams, timers, retries, navigation, app lifecycle, reconnect, and disposal.
5. Write the expected state machine and invariants before labeling findings.
6. Check every transition's producer, consumer, ordering, idempotency, cancellation, error path, and ownership.
7. Classify each item as confirmed defect, specification ambiguity, change request, accepted behavior, false positive, or unresolved.
8. Recommend the smallest fix and the test or runtime probe that would prove it. Implement only when the user asks and intended behavior is unambiguous.

## High-value checks

- multiple instances of the same logical state owner;
- subscriptions installed more than once or disposed by the wrong owner;
- callbacks that outlive a widget, controller, account, or route;
- `setState` or notifier updates after disposal;
- stale async results overwriting newer state;
- navigation executed before persistence or cleanup completes;
- loading, empty, error, disconnected, reconnecting, and retry states;
- state derived independently in multiple screens;
- platform-specific paths with different lifecycle behavior;
- error handling that logs but leaves the UI in an impossible state.

## Output contract

Provide a compact flow map, state-owner table, transition ledger, classified findings with source evidence, missing runtime evidence, and proposed validation. Distinguish static inference, test evidence, emulator/device evidence, and production evidence.
