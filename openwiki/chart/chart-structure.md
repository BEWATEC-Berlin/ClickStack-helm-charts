---
type: reference
title: Chart Structure and Upstream Tooling
description: The upstream ClickStack chart as far as the BEWATEC layer needs it - the two charts, the clickstack templates and naming helpers that decide rendered object names, the values layout, the otel-collector subchart and the operators chart - and which upstream CI, release, changeset and test tooling applies to the fork.
tags: [helm, clickstack, hyperdx, clickhouse, mongodb, otel-collector, operators, changesets, ci, upstream]
verified:
  - by: openwiki/0.9.0
    at: 2026-11-21T19:46:29.038Z
sources:
  - id: openwiki-source-df5f4075d57b334d00e8b010
    resource: repo://.github/workflows/chart-test.yml
  - id: openwiki-source-992e09e92e2553971591e160
    resource: repo://.github/workflows/helm-test.yaml
  - id: openwiki-source-4d1d392666be6dfdd7a91a2e
    resource: repo://.github/workflows/release.yml
  - id: openwiki-source-8037e2358a2c4f9b2c722a11
    resource: repo://AGENTS.md
  - id: openwiki-source-41335b1faee3731a44b80ef5
    resource: repo://charts/clickstack-operators/Chart.lock
  - id: openwiki-source-a47df811c109c84e6152518a
    resource: repo://charts/clickstack-operators/Chart.yaml
  - id: openwiki-source-f78f1390ac16522f58307f7d
    resource: repo://charts/clickstack-operators/values.yaml
  - id: openwiki-source-a3eda30c6b73c168619e6c7e
    resource: repo://charts/clickstack/Chart.lock
  - id: openwiki-source-c35a237e165949dfd34bd962
    resource: repo://charts/clickstack/Chart.yaml
  - id: openwiki-source-6013b7840087de9a1e0868a0
    resource: repo://charts/clickstack/templates/_helpers.tpl
  - id: openwiki-source-518ea34770fca60bae17acc5
    resource: repo://charts/clickstack/templates/clickhouse/cluster.yaml
  - id: openwiki-source-5f5a0eeace745c82ee59f6e1
    resource: repo://charts/clickstack/templates/clickhouse/keeper.yaml
  - id: openwiki-source-9b3ae362d813adee0b2d07c9
    resource: repo://charts/clickstack/templates/hyperdx/configmap.yaml
  - id: openwiki-source-e4651705f1e02021a9b29605
    resource: repo://charts/clickstack/templates/hyperdx/cronjob-check-alerts.yaml
  - id: openwiki-source-51fcf74366bbe35271ffccb0
    resource: repo://charts/clickstack/templates/mongodb/community.yaml
  - id: openwiki-source-99fcbe3662bb9d76cf8bbdda
    resource: repo://charts/clickstack/values.yaml
  - id: openwiki-source-5b54a58d1b51cd490b0e7162
    resource: repo://package.json
  - id: openwiki-source-1283d52a87fb445416109c7c
    resource: repo://scripts/update-chart-versions.js
generated: { by: "claude-code", at: "2026-11-21T19:46:29.038Z" }
---

# Chart Structure and Upstream Tooling

Everything on this page is upstream code, unchanged by the fork, except where
it says so. The fork's own changes are on
[External Secret Mode](../fork/external-secret-mode.md).

## Two charts

| Chart | Path | Version | What it installs |
| --- | --- | --- | --- |
| `clickstack` | `charts/clickstack` | `3.0.1`, `appVersion` `2.29.0` | HyperDX Deployment, Service, ConfigMap, Secret and optional CronJob; `MongoDBCommunity`, `ClickHouseCluster` and `KeeperCluster` custom resources; the OpenTelemetry Collector subchart |
| `clickstack-operators` | `charts/clickstack-operators` | `1.0.0` | The operators and CRDs the first chart's custom resources need: `mongodb-kubernetes` `~1.7.0` (alias `mongodb-operator`, watching only `mongodbcommunity`) and `clickhouse-operator-helm` `~0.0.2` from `oci://ghcr.io/clickhouse` (alias `clickhouse-operator`, webhook and cert-manager off, CRDs on) |

`clickstack` has one dependency, `opentelemetry-collector` `~0.146.0` from
the OpenTelemetry Helm repository, aliased `otel-collector` and gated by
`otel-collector.enabled`. The tracked `charts/clickstack/Chart.lock` pins it
to `0.146.1`; `charts/clickstack-operators/Chart.lock` pins
`mongodb-kubernetes` `1.7.0` and `clickhouse-operator-helm` `0.0.2`.
`helm dependency build` resolves these locked versions, so a lock-only change
changes the subchart that renders. Upstream's `README.md` installs the operators chart
first and the main chart second; the main chart does not depend on the
operators chart.

The fork changes only `charts/clickstack`. The platform installs the operators
chart from upstream's published Helm repository, not from this fork (see
[Platform Touchpoints](../platform/platform-touchpoints.md)).

## Templates

`charts/clickstack/templates/` is grouped by component:

- `hyperdx/`: `configmap.yaml`, `secret.yaml`, `deployment.yaml`,
  `service.yaml`, `cronjob-check-alerts.yaml`, plus optional `ingress.yaml`,
  `hpa.yaml`, `pdb.yaml`, `networkpolicy.yaml`, `serviceaccount.yaml`;
- `mongodb/`: `community.yaml` (the `MongoDBCommunity` CR) and
  `password-secret.yaml` (bridges the shared Secret's `MONGODB_PASSWORD` to the
  `password` key the operator reads);
- `clickhouse/`: `cluster.yaml` (`ClickHouseCluster`) and `keeper.yaml`
  (`KeeperCluster`);
- `additional-manifests.yaml`: renders arbitrary objects from
  `additionalManifests` through `tpl` (see `docs/ADDITIONAL-MANIFESTS.md`).

The custom resources are thin: `mongodb.spec`, `clickhouse.cluster.spec` and
`clickhouse.keeper.spec` are rendered almost verbatim into the CR `spec`
through `tpl (toYaml ...)`, so any operator field can be set from values. The
fork inserts a pre-processing step for `mongodb.spec` and
`clickhouse.cluster.spec` before that render.

## Rendered names

Names come from `_helpers.tpl`:

| Object | Helper | Name |
| --- | --- | --- |
| Base name | `clickstack.fullname` | `fullnameOverride` if set, otherwise `<release>-clickstack` (or the release name when it already contains the chart name) |
| HyperDX Deployment and Service | `clickstack.hyperdx.fullname` | `fullnameOverride` exactly when set; otherwise `<fullname>-app` |
| `MongoDBCommunity` | `clickstack.mongodb.fullname` | `<fullname>-mongodb`; Service `<fullname>-mongodb-svc` |
| MongoDB password bridge Secret | values `mongodb.spec.users[0].passwordSecretRef.name` | `<fullname>-mongodb-password` |
| `ClickHouseCluster` | `clickstack.clickhouse.fullname` | `<fullname>-clickhouse`; headless Service `<fullname>-clickhouse-clickhouse-headless` (created by the operator) |
| `KeeperCluster` | `clickstack.clickhouse.keeper` | `<fullname>-keeper` |
| OTel collector Service | `clickstack.otel.fullname` | `<release>-otel-collector` (release name, not `fullname`) |
| CronJob | template | `<fullname>-check-alerts` |
| ConfigMap | literal | `clickstack-config` |
| Shared Secret | literal upstream; `clickstack.hyperdx.secretName` in the fork | `clickstack-secret` |

The ConfigMap and Secret names do not include the release name, so two
releases of this chart cannot share a namespace.

## Values layout

Top-level keys in `charts/clickstack/values.yaml`: `global`, `hyperdx`,
`mongodb`, `clickhouse`, `additionalManifests`, `otel-collector`.

- `hyperdx.config` becomes the `clickstack-config` ConfigMap. Every value goes
  through `tpl`, so the defaults compute in-cluster endpoints (`MONGO_URI`,
  `CLICKHOUSE_ENDPOINT`, `OTEL_EXPORTER_OTLP_ENDPOINT`, `OPAMP_SERVER_URL`)
  from the naming helpers. The default `MONGO_URI` embeds
  `hyperdx.secrets.MONGODB_PASSWORD`, which puts a credential into a ConfigMap;
  the fork's `configSecretRefs` exists to avoid that.
- `hyperdx.secrets` becomes `clickstack-secret`. It holds `HYPERDX_API_KEY`,
  `CLICKHOUSE_PASSWORD`, `CLICKHOUSE_APP_PASSWORD` and `MONGODB_PASSWORD`, with
  upstream development defaults. Setting it to `null` skips the Secret, which
  upstream only allows when MongoDB, ClickHouse and the collector are all
  disabled.
- `hyperdx.deployment` holds the Deployment spec plus `defaultConnections` and
  `defaultSources` (JSON rendered into `DEFAULT_CONNECTIONS` and
  `DEFAULT_SOURCES`), or `useExistingConfigSecret` with
  `existingConfigSecret`, `existingConfigConnectionsKey` and
  `existingConfigSourcesKey` to read them from a Secret.
- `hyperdx.tasks.enabled` (default `false`) adds the `check-alerts` CronJob.
- `clickhouse.cluster.spec.settings.extraUsersConfig.users` defines the `app`
  and `otelcollector` ClickHouse users, with passwords templated from
  `hyperdx.secrets`.
- `otel-collector.extraEnvsFrom` mounts `clickstack-config` and
  `clickstack-secret` into the collector; the image is
  `docker.clickhouse.com/clickhouse/clickstack-otel-collector`.

## Upstream tooling and whether it applies to the fork

| Tooling | Files | Status in the fork |
| --- | --- | --- |
| Unit tests | `charts/clickstack/tests/*_test.yaml` (helm-unittest) | Present and extended by the fork; run locally with `helm unittest charts/clickstack` |
| Helm Chart Tests | `.github/workflows/helm-test.yaml` | Upstream workflow: builds dependencies, renders `examples/alb-ingress` and `examples/api-only`, runs helm-unittest on PRs to `main` and on pushes to `main` that change `charts/**` |
| Integration tests | `.github/workflows/chart-test.yml`, `integration-tests/{api-only,full-stack}` | Upstream workflow: Kind cluster per suite, push, PR and nightly |
| Release | `.github/workflows/release.yml`, `.changeset/`, `package.json`, `scripts/update-chart-versions.js` | Upstream flow: triggered when either `Helm Chart Tests` or `Helm Chart Integration Test` completes on `main`; the job checks only that triggering run's conclusion, so one successful run can start a release while the other workflow is pending or failed. Changesets then opens a release PR or `helm/chart-releaser-action` publishes to the GitHub Pages Helm repository |
| Version bump | `.github/workflows/update-app-version.yml` | Upstream manual workflow |
| Review automation | `.github/workflows/deep-review.yml`, `external-contributor-alerts.yml`, `.kodiak.toml` | Upstream only |

On 2026-11-21 the fork's GitHub Actions history listed only Dependabot runs,
so none of these workflows has run against the fork's commits, and the fork
publishes no chart package: the platform consumes it as a Git source at a
pinned commit. The two changesets in `.changeset/` are therefore unreleased,
and `Chart.yaml` still carries upstream's `3.0.1`. One of them names a package
that does not exist in this workspace (see
[External Secret Mode](../fork/external-secret-mode.md#changesets)).

`AGENTS.md` (branch prefix `warren/`, `[HDX-…]` PR titles, Linear tickets,
Kodiak auto-merge) and `Chart.yaml` `sources`/`annotations` (pointing at
`hyperdxio/helm-charts`) describe upstream conventions, not how the fork is
maintained.
