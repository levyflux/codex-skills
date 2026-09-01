# Contributing

Contributions are welcome when they improve a repeatable workflow rather than add generic prompting.

## Skill quality bar

- Keep `name` and `description` concise and discriminating.
- Put the shared workflow in `SKILL.md`; move conditional detail into linked references.
- Add scripts only when deterministic behavior or repeated mechanics justify them.
- Preserve user intent and authorization boundaries. A skill must not imply permission to deploy,
  trade, sign, broadcast, or mutate an external system.
- Do not embed secrets, private URLs, local absolute paths, volatile addresses, or invented product
  thresholds.
- Separate source/static, test, runtime, browser, deployment, and external-system evidence.

## Validation

Run Codex's `quick_validate.py` against every changed skill. Run any tests stored with the skill, and
state what the checks do and do not prove in the pull request.
