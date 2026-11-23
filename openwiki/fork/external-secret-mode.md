---
type: concept
title: External Secret Mode (BEWATEC changes)
description: The BEWATEC fork's only functional change to the upstream ClickStack chart - values that point HyperDX, MongoDB and ClickHouse at externally managed Secrets (hyperdx.existingSecret, hyperdx.configSecretRefs, mongodb.existingPasswordSecret, clickhouse.existingUserPasswordSecret), ClickHouse from_env password rendering, the render-time validations, their unit tests, the pending changesets, and known gaps.
tags: [fork, bewatec, secrets, external-secrets, hyperdx, mongodb, clickhouse, from_env, helm-unittest, changesets]
verified:
  - by: openwiki/0.9.0
    at: 2026-11-21T19:46:29.038Z
sources:
  - id: openwiki-source-0ca65f55df81ef64ea4c0506
    resource: repo://.changeset/clickhouse-secret-env-passwords.md
  - id: openwiki-source-17157cb86a38d71871e277a1
    resource: repo://.changeset/managed-secret-refs.md
  - id: openwiki-source-6013b7840087de9a1e0868a0
    resource: repo://charts/clickstack/templates/_helpers.tpl
  - id: openwiki-source-518ea34770fca60bae17acc5
    resource: repo://charts/clickstack/templates/clickhouse/cluster.yaml
  - id: openwiki-source-9b3ae362d813adee0b2d07c9
    resource: repo://charts/clickstack/templates/hyperdx/configmap.yaml
  - id: openwiki-source-e4651705f1e02021a9b29605
    resource: repo://charts/clickstack/templates/hyperdx/cronjob-check-alerts.yaml
  - id: openwiki-source-63b715d6747d4bb48b81a05c
    resource: repo://charts/clickstack/templates/hyperdx/deployment.yaml
  - id: openwiki-source-585124bf4c95b3a1b54a45d2
    resource: repo://charts/clickstack/templates/hyperdx/secret.yaml
  - id: openwiki-source-51fcf74366bbe35271ffccb0
    resource: repo://charts/clickstack/templates/mongodb/community.yaml
  - id: openwiki-source-d5f85d3d59f0af006e3d6845
    resource: repo://charts/clickstack/templates/mongodb/password-secret.yaml
  - id: openwiki-source-07c36479c0d2bec2a8a71a5c
    resource: repo://charts/clickstack/tests/clickhouse-users_test.yaml
  - id: openwiki-source-ceaa1ce7b92da7446e9b7300
    resource: repo://charts/clickstack/tests/external-secrets_test.yaml
  - id: openwiki-source-99fcbe3662bb9d76cf8bbdda
    resource: repo://charts/clickstack/values.yaml
  - id: openwiki-source-5b54a58d1b51cd490b0e7162
    resource: repo://package.json
generated: { by: "claude-code", at: "2026-11-21T19:46:29.038Z" }
---

# External Secret Mode (BEWATEC changes)

The fork adds two commits to upstream release `f114951` ("Release ClickStack
Helm Charts (#229)"):

| Commit | Subject | Scope |
| --- | --- | --- |
| `4444762` | `feat: support external ClickStack secrets` | New values, helpers and validations; HyperDX, MongoDB and ClickHouse wiring; tests; changeset `managed-secret-refs.md`. Its message cites `BEWATEC-Berlin/platform-infra#147`. |
| `5754197` | `fix: render external ClickHouse passwords from env (#2)` | Replaces the ClickHouse password handling with `from_env` substitution and container env injection; changeset `clickhouse-secret-env-passwords.md`. |

`5754197` is the fork's `main` and the revision platform-infra pins (see
[Platform Touchpoints](../platform/platform-touchpoints.md)).

## Why

Upstream renders every credential from `hyperdx.secrets` in Helm values: into
the `clickstack-secret` Secret, into the `clickstack-config` ConfigMap (the
default `MONGO_URI` contains the MongoDB password), into the MongoDB password
bridge Secret, into `DEFAULT_CONNECTIONS`, and into the `ClickHouseCluster`
user definitions. Setting `hyperdx.secrets: null` is rejected while MongoDB,
ClickHouse or the collector is enabled. The fork lets every one of those
consumers read a Secret that something else (on the platform, External
Secrets) owns, so no credential has to pass through Helm values or Argo CD.
Background on the chart layout is on
[Chart Structure](../chart/chart-structure.md).

## New values

All default to empty, so a release that sets none of them renders as
upstream, with one exception: with `hyperdx.tasks.enabled: true` the
`check-alerts` CronJob now gets `DEFAULT_CONNECTIONS` and `DEFAULT_SOURCES`
from the populated chart defaults (`hyperdx.deployment.defaultConnections`
includes the default ClickHouse connection's password), which upstream's
CronJob omitted. See the paragraph after the table.

| Value | Effect |
| --- | --- |
| `hyperdx.existingSecret.name` | The chart stops creating its shared Secret. The HyperDX Deployment and the `check-alerts` CronJob `envFrom` this Secret instead (helper `clickstack.hyperdx.secretName`, default `clickstack-secret`). Also allows `hyperdx.secrets: null` with MongoDB, ClickHouse and the collector enabled. |
| `hyperdx.configSecretRefs` | Map of `hyperdx.config` key to `{name, key, optional}`. Each listed key is left out of `clickstack-config` and added to the HyperDX Deployment and CronJob as an `env` entry with `valueFrom.secretKeyRef` (`key` defaults to the map key, `optional` to `false`, `name` is required). Not applied to the OTel collector. |
| `mongodb.existingPasswordSecret.name` | The chart stops creating `<fullname>-mongodb-password` and sets `passwordSecretRef.name` of the first entry in `mongodb.spec.users` to this Secret. Only `name` is changed. |
| `clickhouse.existingUserPasswordSecret.name`, `.appPasswordKey` (default `CLICKHOUSE_APP_PASSWORD`), `.otelCollectorPasswordKey` (default `CLICKHOUSE_PASSWORD`) | Rewrites the ClickHouse user passwords to read from container environment variables, and injects those variables from this Secret. |

The existing upstream `hyperdx.deployment.useExistingConfigSecret` (read
`DEFAULT_CONNECTIONS` and `DEFAULT_SOURCES` from a Secret) is unchanged; the
fork moves its rendering into the helper `clickstack.hyperdx.defaultConfigEnv`
so the Deployment and the CronJob share it. Before the fork, the CronJob did
not render `DEFAULT_CONNECTIONS` or `DEFAULT_SOURCES` at all.

## ClickHouse `from_env` passwords

`templates/clickhouse/cluster.yaml` deep-copies `clickhouse.cluster.spec`
before rendering. When `existingUserPasswordSecret.name` is set, for each of
the two default users that is still present in
`settings.extraUsersConfig.users`:

- `app`: `password` becomes `{"@from_env": "CLICKHOUSE_APP_PASSWORD"}` and
  `containerTemplate.env` gains `CLICKHOUSE_APP_PASSWORD` from
  `secretKeyRef {name: <existingUserPasswordSecret.name>, key: <appPasswordKey>}`;
- `otelcollector`: `password` becomes `{"@from_env": "CLICKHOUSE_PASSWORD"}`
  and `containerTemplate.env` gains `CLICKHOUSE_PASSWORD` from the same Secret
  with `otelCollectorPasswordKey`.

The ClickHouse server then substitutes the variable at start-up, so the
password never appears in the `ClickHouseCluster` CR. Users removed from
values (`app: null`) are not recreated and get no env entry; other users are
left as written, so a literal password on any custom ClickHouse user is
rendered into the `ClickHouseCluster` CR as supplied, even in external mode. Existing `containerTemplate.env` entries are kept and the new
ones appended. The env variable names are fixed; only the Secret keys are
configurable.

The first fork commit wrote a Kubernetes-style `valueFrom.secretKeyRef` map
into the ClickHouse user's `password` field, which ClickHouse does not
resolve; `5754197` replaced it with the `from_env` form, the only one in the
current template.

## Validations

The fork adds targeted render-time checks for the built-in credential paths.
They are not general leak protection: the `.Values.hyperdx.secrets` checks
look only at `hyperdx.config.MONGO_URI` and
`hyperdx.deployment.defaultConnections`, and the others cover only the
component-specific conditions below. Each check is a helper in
`_helpers.tpl` (or inline) called from the template named:

| Condition (all with `hyperdx.existingSecret.name` set) | Fails in | Message names |
| --- | --- | --- |
| `hyperdx.config.MONGO_URI` still references `.Values.hyperdx.secrets` and `configSecretRefs` has no `MONGO_URI` | `hyperdx/configmap.yaml` (`clickstack.validateHyperdxConfigSecretRefs`) | `hyperdx.configSecretRefs.MONGO_URI is required ...` |
| `hyperdx.deployment.defaultConnections` references `.Values.hyperdx.secrets` and `useExistingConfigSecret` is false | `hyperdx/deployment.yaml`, `hyperdx/cronjob-check-alerts.yaml` (`clickstack.validateHyperdxDefaultConnections`) | `hyperdx.deployment.useExistingConfigSecret is required ...` |
| MongoDB enabled without `mongodb.existingPasswordSecret.name` | `mongodb/community.yaml`, `mongodb/password-secret.yaml` (`clickstack.validateMongoDBExistingSecret`) | `mongodb.existingPasswordSecret.name is required ...` |
| ClickHouse enabled without `clickhouse.existingUserPasswordSecret.name` | `clickhouse/cluster.yaml` (`clickstack.validateClickHouseExistingSecret`) | `clickhouse.existingUserPasswordSecret.name is required ...` |
| Secret name is not `clickstack-secret`, collector enabled, and no `otel-collector.extraEnvsFrom` entry has that exact `secretRef.name` | `hyperdx/secret.yaml` (inline) | `otel-collector.extraEnvsFrom must reference hyperdx.existingSecret.name ...` |

`cluster.yaml` also fails if `containerTemplate.env` already defines
`CLICKHOUSE_APP_PASSWORD` or `CLICKHOUSE_PASSWORD` for a managed user, since
the chart would add a duplicate. That check applies whenever
`existingUserPasswordSecret.name` is set, with or without
`hyperdx.existingSecret`.

The collector check exists because the otel-collector subchart's
`extraEnvsFrom` is a plain list the parent chart cannot rewrite; when the
external Secret keeps the name `clickstack-secret`, the subchart default
already matches and no override is needed.

## What the external Secrets must contain

The chart only references these Secrets; it never checks their keys.

- Shared Secret (`hyperdx.existingSecret.name`): the keys upstream puts in
  `clickstack-secret`, consumed through `envFrom` by HyperDX and (via
  `extraEnvsFrom`) the collector: `HYPERDX_API_KEY`, `CLICKHOUSE_PASSWORD`,
  `CLICKHOUSE_APP_PASSWORD`, `MONGODB_PASSWORD`.
- MongoDB password Secret: key `password`.
- ClickHouse user Secret: the keys named by `appPasswordKey` and
  `otelCollectorPasswordKey`. It may be the shared Secret, which is what the
  platform does.
- Every Secret named in `configSecretRefs`, and `existingConfigSecret` with
  the two configured keys when `useExistingConfigSecret` is on.

## Tests

The fork adds `tests/external-secrets_test.yaml` (suite "Test External Secret
Mode"): one shared values block with every external option set, asserting
that neither chart Secret renders, `MONGO_URI` leaves the ConfigMap, the
Deployment and CronJob reference the external Secrets, the `MongoDBCommunity`
user points at the external password Secret, and the ClickHouse users use
`@from_env` with matching env entries. It also extends
`clickhouse-users_test.yaml`, `secrets_test.yaml`,
`hyperdx-deployment_test.yaml`, `mongodb-deployment_test.yaml`,
`task-checkAlerts_test.yaml` and `app-configmap_test.yaml` with one case per
validation and per default-off path. These run with `helm unittest
charts/clickstack`; the fork has no CI that runs them (see
[Chart Structure](../chart/chart-structure.md#upstream-tooling-and-whether-it-applies-to-the-fork)).

## Changesets

Two unreleased changesets describe the change:

- `.changeset/managed-secret-refs.md`: `"helm-charts": patch`.
- `.changeset/clickhouse-secret-env-passwords.md`: `"@hyperdx/clickstack": patch`.
  The workspace package is `helm-charts` (`package.json`) and every upstream
  changeset uses that name, so `changeset version` would reject this file as
  naming an unknown package.

## Gaps and stale comments

- `values.yaml`, comment above `hyperdx.secrets`: still says `null` requires
  MongoDB, ClickHouse and the collector to be disabled. With
  `hyperdx.existingSecret.name` set that is no longer true
  (`templates/hyperdx/secret.yaml`).
- `values.yaml`, comment on `mongodb.existingPasswordSecret`: says the Secret
  must contain `password` "because MongoDBCommunity passwordSecretRef only
  selects the Secret name". The template only overwrites `name`; any `key` set
  on the user's `passwordSecretRef` in `mongodb.spec` is left in place.
- Only `mongodb.spec.users[0]` is rewritten; additional MongoDB users keep
  their own `passwordSecretRef`.
- `configSecretRefs` covers the HyperDX workloads only. A key moved out of
  `clickstack-config` disappears from the collector's environment too, since
  the collector reads that ConfigMap through `extraEnvsFrom`.
- The `password-secret.yaml` header comment still describes only the bridge
  from `clickstack-secret`.
