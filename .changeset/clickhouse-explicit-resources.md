---
"helm-charts": patch
---

fix(clickhouse): harden ClickHouse defaults for clickhouse-operator v0.0.6

Two operator-default changes in v0.0.6 broke the single-replica ClickHouse
deployment; the chart now overrides both:

- Explicit `containerTemplate.resources` (2Gi memory, 500m CPU request). The
  operator otherwise applies a 512Mi default (request == limit as of v0.0.6),
  which is too low for the full ClickStack schema and OOMKills the server
  (exit 137) under ingestion plus background merges.

- `settings.enableDatabaseSync: false`. The operator now defaults this to true,
  which creates the `default` database with the Replicated (DatabaseReplicated)
  engine so table metadata lives in Keeper. That feature targets multi-replica
  clusters; in a single-replica deployment a transient Keeper hiccup during
  startup desyncs the Replicated database and silently drops all seeded tables,
  which never come back. Keeping `default` Atomic stores tables on the
  persistent data volume so they survive restarts.
