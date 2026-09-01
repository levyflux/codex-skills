# Evidence contract

Choose evidence according to the claim being made. A lower layer cannot prove a higher one.

| Layer | Typical evidence | Proves | Does not prove |
| --- | --- | --- | --- |
| Source | current files, diff, generated artifacts | implementation shape | compilation or behavior |
| Static | typecheck, lint, schema validation | selected structural rules | runtime integration |
| Test | unit, integration, contract, migration tests | covered deterministic behavior | deployment or uncovered paths |
| Runtime | local or test-environment probes, logs, health checks | behavior in the observed environment | production correctness |
| User-visible | browser, device, accessibility, workflow acceptance | observed interaction and presentation | all users or environments |
| Data/external | database query, API response, queue state, provider receipt | exact observed external state | future stability |
| Release | artifact identity, migration order, rollout and rollback checks | release readiness for the named target | authorization to release |

## Acceptance record

For each acceptance criterion, record:

- stable criterion identifier;
- authoritative source or decision;
- implementation slice;
- test or probe command;
- exact result and timestamp when freshness matters;
- environment or external target;
- limitation and remaining gap;
- decision owner when evidence is insufficient.

Use `PASS`, `FAIL`, `NOT RUN`, or `BLOCKED` only with the relevant layer and scope. Avoid a single global “verified” label.
