---
name: release-sql-gate
description: Produce a deterministic manifest for SQL files changed between two Git refs, including exact order, SHA-256 hashes, and risk flags. Use before a release, deployment, migration handoff, or database runbook review; it inventories and validates SQL but never connects to a database or executes statements.
---

# Release SQL Gate

Turn a Git diff into a reviewable, immutable SQL release manifest without executing database changes.

## Boundaries

- The helper is read-only with respect to Git and databases.
- It never connects to a database, applies SQL, deploys, commits, or pushes.
- Risk flags are lexical review cues, not a SQL parser or safety proof.
- The operator must still verify engine compatibility, transaction behavior, backup/rollback, permissions, locks, data volume, and environment-specific order.

## Generate a manifest

Requires Ruby 2.6 or newer and only the standard library.

```bash
ruby scripts/release_sql_manifest.rb \
  --repository /path/to/repository \
  --base origin/main \
  --head HEAD \
  --output release-sql-manifest.json
```

If more than one SQL file is present, provide an exact order file containing one repository-relative path per line:

```bash
ruby scripts/release_sql_manifest.rb \
  --repository . \
  --base origin/main \
  --head HEAD \
  --order-file sql-order.txt
```

The command fails closed when refs are invalid, a changed SQL file is absent from the selected tree, order entries are missing or duplicated, or the order file does not exactly match the diff.

## Review the output

1. Confirm repository root and resolved base/head SHAs.
2. Confirm the three-dot diff is the intended release comparison.
3. Review every SQL path, byte count, SHA-256, and risk flag.
4. Verify the declared order and its aggregate hash.
5. Add engine-specific dry-run, migration, rollback, and runtime evidence outside this manifest.
6. Bind release authorization to the exact manifest and head SHA.

Report `PASS`, `FAIL`, or `BLOCKED` with the exact comparison, manifest path or digest, and remaining database evidence gaps.
