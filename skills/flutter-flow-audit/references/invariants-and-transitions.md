# Invariants and transitions

## State-owner inventory

For every mutable value, record:

| Field | Question |
| --- | --- |
| Owner | Which object has authority to change it? |
| Lifetime | App, account, route, widget, request, or callback? |
| Producers | Which callbacks, commands, streams, or stores write it? |
| Consumers | Which widgets, services, or decisions read it? |
| Reset | What event clears or replaces it? |
| Failure | What state remains after timeout, cancellation, or error? |

Framework names do not establish ownership. Provider, Riverpod, BLoC, GetX, inherited widgets, and local `State` can all be correct or incorrect depending on lifetime and authority.

## Transition ledger

Model each meaningful event:

```text
current state + event + guard -> effect -> next state
```

Check these properties:

- **single authority** — one logical owner decides the transition;
- **ordering** — stale work cannot overwrite newer intent;
- **idempotency** — duplicate events do not duplicate durable effects;
- **cancellation** — disposed or superseded work stops safely;
- **observability** — failure reaches a debuggable state;
- **recovery** — retry or reconnect has a valid path;
- **platform parity** — divergence is explicit and tested.

## Common failure branches

- route exits during an in-flight request;
- app backgrounds while a timer or stream remains active;
- account, room, document, or item identity changes before a callback returns;
- reconnect emits both cached and live state;
- a service singleton retains a screen-scoped listener;
- success updates durable state but navigation fails, or navigation succeeds before persistence;
- error clears loading but leaves derived controls enabled with stale data.

Static source can establish reachability and ownership concerns. A widget test, integration test, emulator/device run, or instrumented runtime trace is still needed to prove timing-dependent behavior.
