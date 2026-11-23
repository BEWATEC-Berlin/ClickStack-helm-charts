---
type: reference
title: Platform Touchpoints
description: The cross-repo contract between this ClickStack chart fork and platform-infra - per cluster whether the chart runs, the Argo CD Applications, AppProject, fleet parent ApplicationSet, pinned targetRevision, release name, fullnameOverride, namespace, rendered object names, external Secrets and the keys the chart reads, the ExternalSecrets, PushSecrets and 1Password items that produce them (names only), hostnames, and the platform components that depend on the chart's ConfigMap and Secret.
tags: [platform-infra, clickstack, hyperdx, argocd, fleet, mgmt-core, external-secrets, 1password, observability, cross-repo]
verified:
  - by: openwiki/0.9.0
    at: 2026-11-21T19:46:29.038Z
sources:
  - id: openwiki-source-6013b7840087de9a1e0868a0
    resource: repo://charts/clickstack/templates/_helpers.tpl
  - id: openwiki-source-9b3ae362d813adee0b2d07c9
    resource: repo://charts/clickstack/templates/hyperdx/configmap.yaml
  - id: openwiki-source-63b715d6747d4bb48b81a05c
    resource: repo://charts/clickstack/templates/hyperdx/deployment.yaml
  - id: openwiki-source-585124bf4c95b3a1b54a45d2
    resource: repo://charts/clickstack/templates/hyperdx/secret.yaml
  - id: openwiki-source-1ac99c07840fcb269ba6f77b
    resource: repo://charts/clickstack/templates/hyperdx/service.yaml
  - id: openwiki-source-99fcbe3662bb9d76cf8bbdda
    resource: repo://charts/clickstack/values.yaml
generated: { by: "claude-code", at: "2026-11-21T19:46:29.038Z" }
---

# Platform Touchpoints

This page lists the names under which the platform knows this chart, spelled
exactly as in the manifests, so a search for any of them finds both this wiki
and the
[platform-infra wiki](https://github.com/BEWATEC-Berlin/platform-infra/blob/main/openwiki/index.md).
All platform-side identifiers are defined in **platform-infra** (`main`), not
here; change them there. This repository has no deploy manifests, no image and
no CI of its own: the platform renders `charts/clickstack` straight from a
pinned commit of this Git repository. State described here is Git state, not
observed cluster state.

The platform's view of ClickStack as a whole (router, collectors, agents,
signal paths) is on the platform-infra wiki page
[Observability stack](https://github.com/BEWATEC-Berlin/platform-infra/blob/main/openwiki/observability/observability-stack.md).

## Per cluster

| Cluster | Uses this fork? | What runs there |
| --- | --- | --- |
| `mgmt-core` | yes | Argo CD Application `mgmt-core-clickstack-control-plane` renders `charts/clickstack` from this repository into namespace `clickstack` |
| `integration`, `staging`, `mgmt-cicd` | no | Argo CD Applications `integration-clickstack`, `staging-clickstack` and `mgmt-cicd-clickstack` (base [`addons/clickstack/application.yaml`](https://github.com/BEWATEC-Berlin/platform-infra/blob/main/k8s/control-plane/argocd/fleet/addons/clickstack/application.yaml), prefixed by the [integration](https://github.com/BEWATEC-Berlin/platform-infra/blob/main/k8s/control-plane/argocd/fleet/clusters/integration/kustomization.yaml), [staging](https://github.com/BEWATEC-Berlin/platform-infra/blob/main/k8s/control-plane/argocd/fleet/clusters/staging/observability/kustomization.yaml) and [mgmt-cicd](https://github.com/BEWATEC-Berlin/platform-infra/blob/main/k8s/control-plane/argocd/fleet/clusters/mgmt-cicd/kustomization.yaml) fleet overlays) render `k8s/clusters/<cluster>/clickstack`, which installs only the ClickStack agents catalog (`k8s/catalog/observability/clickstack-agents`) shipping telemetry to `mgmt-core` |
| `production` | no | No Application references this repository |

## mgmt-core Application

| Field | Value | Defined in (platform-infra) |
| --- | --- | --- |
| Base Application | `clickstack-control-plane` (namespace `argocd`, sync wave `9`, label `connectedcare.io/fleet-component: clickstack-control-plane`) | [`k8s/control-plane/argocd/fleet/addons/clickstack-control-plane/application.yaml`](https://github.com/BEWATEC-Berlin/platform-infra/blob/main/k8s/control-plane/argocd/fleet/addons/clickstack-control-plane/application.yaml) |
| Rendered Application name | `mgmt-core-clickstack-control-plane` (kustomize `namePrefix: mgmt-core-`) | [`k8s/control-plane/argocd/fleet/clusters/mgmt-core/kustomization.yaml`](https://github.com/BEWATEC-Berlin/platform-infra/blob/main/k8s/control-plane/argocd/fleet/clusters/mgmt-core/kustomization.yaml) |
| Cluster patch | destination `mgmt-core`, namespace `clickstack`; `Replace=true`; Helm parameters pinning the ClickHouse image tag `25.7-alpine@sha256:…`, S3 env from Secret `clickstack-clickhouse-s3-credentials`, merge-tree and node-selector settings | [`k8s/control-plane/argocd/fleet/clusters/mgmt-core/clickstack-control-plane.patch.yaml`](https://github.com/BEWATEC-Berlin/platform-infra/blob/main/k8s/control-plane/argocd/fleet/clusters/mgmt-core/clickstack-control-plane.patch.yaml) |
| Fleet parent ApplicationSet | `fleet-cluster-parents-mgmt-core-canary` | [`k8s/control-plane/argocd/fleet/mgmt-core-parent-applicationset.yaml`](https://github.com/BEWATEC-Berlin/platform-infra/blob/main/k8s/control-plane/argocd/fleet/mgmt-core-parent-applicationset.yaml) |
| Fleet parent Application | `mgmt-core-fleet` (generated by the ApplicationSet from `fleetParentApplicationName`; renders the `k8s/control-plane/argocd/fleet/clusters/mgmt-core` overlay that contains `mgmt-core-clickstack-control-plane`) | [`k8s/control-plane/argocd/fleet/clusters/mgmt-core/fleet-cluster.yaml`](https://github.com/BEWATEC-Berlin/platform-infra/blob/main/k8s/control-plane/argocd/fleet/clusters/mgmt-core/fleet-cluster.yaml) |
| AppProject | `observability`, whose `sourceRepos` list `https://github.com/BEWATEC-Berlin/ClickStack-helm-charts.git` and upstream `https://clickhouse.github.io/ClickStack-helm-charts` | [`k8s/control-plane/argocd/projects/projects.yaml`](https://github.com/BEWATEC-Berlin/platform-infra/blob/main/k8s/control-plane/argocd/projects/projects.yaml) |
| Source | `repoURL: https://github.com/BEWATEC-Berlin/ClickStack-helm-charts.git`, `path: charts/clickstack`, `targetRevision: 5754197e9f6491a60429c73550d68bfe545a5d29` | base Application |
| Helm release | `releaseName: clickstack`, `fullnameOverride: cs` | base Application |
| Retired | ApplicationSet `observability-clickstack-control-plane` | [addon README](https://github.com/BEWATEC-Berlin/platform-infra/blob/main/k8s/control-plane/argocd/fleet/addons/clickstack-control-plane/README.md) |

The pinned revision is the head of this fork's `main`, carrying the
[External Secret Mode](../fork/external-secret-mode.md) commits. Moving the
pin is a platform-infra change. How fleet add-ons and cluster patches compose
is on
[Fleet add-ons](https://github.com/BEWATEC-Berlin/platform-infra/blob/main/openwiki/gitops/fleet-addons.md).

The companion Application `mgmt-core-clickstack-operators`
([`addons/clickstack-operators/application.yaml`](https://github.com/BEWATEC-Berlin/platform-infra/blob/main/k8s/control-plane/argocd/fleet/addons/clickstack-operators/application.yaml))
installs `clickstack-operators` `1.1.1` from upstream's Helm repository
`https://clickhouse.github.io/ClickStack-helm-charts`, not this fork's
`charts/clickstack-operators` (`1.0.0`).

## Rendered names on mgmt-core

With release `clickstack` and `fullnameOverride: cs`, the chart's helpers
([Chart Structure](../chart/chart-structure.md#rendered-names)) give:

| Object | Name |
| --- | --- |
| HyperDX Deployment and Service | `cs` (Service port `3000` is the HTTPRoute backend) |
| `ClickHouseCluster` | `cs-clickhouse`; Service `cs-clickhouse-clickhouse-headless` |
| `KeeperCluster` | `cs-keeper` |
| `MongoDBCommunity` | `cs-mongodb`; Service `cs-mongodb-svc` |
| OTel collector (bundled subchart) | `clickstack-otel-collector` |
| ConfigMap | `clickstack-config` |
| Shared Secret | `clickstack-secret` (referenced, not created) |

`cs-mongodb-svc` and `cs-clickhouse-clickhouse-headless` are hard-coded in
the platform's `clickstack-config-secret` template, and `cs-clickhouse` names
appear in the mgmt-core S3 preparation and Kyverno policies, so changing
`fullnameOverride` or the naming helpers breaks those.

## Values the platform sets

From the base Application, relevant to the fork:

- `hyperdx.secrets: null`, `hyperdx.existingSecret.name: clickstack-secret`;
- `hyperdx.configSecretRefs.MONGO_URI` → Secret `clickstack-config-secret`,
  key `MONGO_URI`;
- `hyperdx.deployment.useExistingConfigSecret: true`,
  `existingConfigSecret: clickstack-config-secret`, keys `DEFAULT_CONNECTIONS`
  and `DEFAULT_SOURCES`;
- `mongodb.existingPasswordSecret.name: clickstack-mongodb-password`;
- `clickhouse.existingUserPasswordSecret`: name `clickstack-secret`,
  `appPasswordKey: CLICKHOUSE_APP_PASSWORD`,
  `otelCollectorPasswordKey: CLICKHOUSE_PASSWORD`;
- `otel-collector.extraEnvsFrom`: ConfigMap `clickstack-config` and Secret
  `clickstack-secret` (the external Secret keeps the default name, so the
  fork's collector check passes);
- `hyperdx.ingress.enabled: false`, `FRONTEND_URL`
  `https://hyperdx.mgmt-core.connectedcare.io`, `USAGE_STATS_ENABLED`
  `"false"`, collector `HYPERDX_OTEL_EXPORTER_TABLES_TTL` `168h`, and storage
  class `hcloud-volumes` for MongoDB (10Gi), Keeper (5Gi) and ClickHouse
  (300Gi).

The Application ignores `/data` and `/type` drift on Secret
`clickstack-secret` in namespace `clickstack`.

## Secrets

Names only. All live in namespace `clickstack` on mgmt-core, but they have
two different producers.

**External Secrets.** The **platform-infra** catalog
[`k8s/catalog/observability/clickstack-control-plane/`](https://github.com/BEWATEC-Berlin/platform-infra/blob/main/k8s/catalog/observability/clickstack-control-plane/kustomization.yaml),
deployed by Application `mgmt-core-clickstack` (path
`k8s/clusters/mgmt-core/clickstack`), produces the first three Secrets:

| Secret read by the chart | Keys the chart reads | Produced by | 1Password items |
| --- | --- | --- | --- |
| `clickstack-secret` | `envFrom` for HyperDX and collector (keys `HYPERDX_API_KEY`, `CLICKHOUSE_PASSWORD`, `CLICKHOUSE_APP_PASSWORD`, `MONGODB_PASSWORD`); `CLICKHOUSE_APP_PASSWORD`, `CLICKHOUSE_PASSWORD` for ClickHouse users | ExternalSecret [`clickstack-internal-credentials`](https://github.com/BEWATEC-Berlin/platform-infra/blob/main/k8s/catalog/observability/clickstack-control-plane/clickstack-internal-credentials-externalsecret.yaml) (`ClusterSecretStore/onepassword`) | `mgmt-core-clickstack-api-key` (`HYPERDX_API_KEY`), `mgmt-core-clickstack-control-plane-credentials` (the other three) |
| `clickstack-config-secret` | `MONGO_URI`, `DEFAULT_CONNECTIONS`, `DEFAULT_SOURCES` | ExternalSecret `clickstack-config` (`ClusterSecretStore/onepassword`) | `mgmt-core-clickstack-control-plane-credentials` |
| `clickstack-mongodb-password` | `password` | ExternalSecret `clickstack-mongodb-password` (`ClusterSecretStore/onepassword`) | `mgmt-core-clickstack-control-plane-credentials` |

**Object storage.** `clickstack-clickhouse-s3-credentials` (keys
`access_key`, `secret_key`, set by the cluster patch's Helm parameters, not by
chart values; no 1Password item) is not in that catalog. It is published by
[`ObjectStorageAccess/clickstack-clickhouse-s3`](https://github.com/BEWATEC-Berlin/platform-infra/blob/main/k8s/clusters/mgmt-core/observability-s3-preparation/objectstorageaccesses.yaml)
(target `ClickHouseCluster/cs-clickhouse`, access plane
`platform-objectstorage/deltaglider-mgmt-core-observability`, bucket
`cc-mgmt-core-clickstack-clickhouse`, `runtimeActivation.secretPublication`
enabled). The bucket is claimed by
[`ObjectStorageBucket/cc-mgmt-core-clickstack-clickhouse`](https://github.com/BEWATEC-Berlin/platform-infra/blob/main/k8s/clusters/mgmt-core/observability-s3-preparation/objectstoragebuckets.yaml)
in namespace `platform-objectstorage`. Both come from
`k8s/clusters/mgmt-core/observability-s3-preparation`, a source of the
manually synced Application `mgmt-core-deltaglider-operator`
([`fleet/clusters/mgmt-core/deltaglider-operator.yaml`](https://github.com/BEWATEC-Berlin/platform-infra/blob/main/k8s/control-plane/argocd/fleet/clusters/mgmt-core/deltaglider-operator.yaml)),
so look there, not in the catalog, when this Secret is missing or stale.

### Generated API keys

The catalog also generates two keys in-cluster. Each chain uses one name for
the `Password` generator, the ExternalSecret, its target Kubernetes Secret and
the PushSecret; only the 1Password item differs:

| Name (`Password`, ExternalSecret, Secret, PushSecret) | Secret key | 1Password item (`ClusterSecretStore/onepassword-write`) |
| --- | --- | --- |
| [`clickstack-api-key`](https://github.com/BEWATEC-Berlin/platform-infra/blob/main/k8s/catalog/observability/clickstack-control-plane/api-key-externalsecret.yaml) ([PushSecret](https://github.com/BEWATEC-Berlin/platform-infra/blob/main/k8s/catalog/observability/clickstack-control-plane/api-key-pushsecret.yaml)) | `api-key` | `mgmt-core-clickstack-api-key`, property `api-key` |
| [`clickstack-browser-ingest-key`](https://github.com/BEWATEC-Berlin/platform-infra/blob/main/k8s/catalog/observability/clickstack-control-plane/browser-ingest-key-externalsecret.yaml) ([PushSecret](https://github.com/BEWATEC-Berlin/platform-infra/blob/main/k8s/catalog/observability/clickstack-control-plane/browser-ingest-key-pushsecret.yaml)) | `api-key` | `mgmt-core-clickstack-browser-ingest-key`, property `api-key` |

Both ExternalSecrets use `refreshPolicy: CreatedOnce`. Consumers of these
keys, to trace a rotation end to end:

- `clickstack-secret/HYPERDX_API_KEY` reads the 1Password item
  `mgmt-core-clickstack-api-key` back through `clickstack-internal-credentials`.
- The OTel router `mgmt-core-clickstack-otel-router` reads
  `clickstack-api-key/api-key`
  ([application.yaml](https://github.com/BEWATEC-Berlin/platform-infra/blob/main/k8s/control-plane/argocd/fleet/addons/clickstack-otel-router/application.yaml)).
- The browser gateway `mgmt-core-clickstack-otel-browser-gateway`
  ([application.yaml](https://github.com/BEWATEC-Berlin/platform-infra/blob/main/k8s/control-plane/argocd/fleet/addons/clickstack-otel-browser-gateway/application.yaml),
  added in the [mgmt-core fleet overlay](https://github.com/BEWATEC-Berlin/platform-infra/blob/main/k8s/control-plane/argocd/fleet/clusters/mgmt-core/kustomization.yaml))
  authenticates browsers with `clickstack-browser-ingest-key/api-key` and
  forwards to the router with `clickstack-api-key/api-key`. Its documented
  client is `bdm-frontend`'s `@hyperdx/browser`
  ([README](https://github.com/BEWATEC-Berlin/platform-infra/blob/main/k8s/clusters/mgmt-core/clickstack/README.md)).
- The agents on integration, staging and mgmt-cicd pull
  `mgmt-core-clickstack-api-key/api-key` through their local ExternalSecret
  `clickstack-api-key`
  ([integration](https://github.com/BEWATEC-Berlin/platform-infra/blob/main/k8s/clusters/integration/clickstack/patch-clickstack-api-key-externalsecret.yaml),
  [staging](https://github.com/BEWATEC-Berlin/platform-infra/blob/main/k8s/clusters/staging/clickstack/patch-clickstack-api-key-externalsecret.yaml),
  [mgmt-cicd](https://github.com/BEWATEC-Berlin/platform-infra/blob/main/k8s/clusters/mgmt-cicd/clickstack/patch-clickstack-api-key-externalsecret.yaml)).

See
[Secrets and External Secrets](https://github.com/BEWATEC-Berlin/platform-infra/blob/main/openwiki/identity/secrets-and-external-secrets.md).

## Hostnames and exposure

The chart's own Ingress is disabled. HTTPRoutes in
[`k8s/clusters/mgmt-core/clickstack/`](https://github.com/BEWATEC-Berlin/platform-infra/blob/main/k8s/clusters/mgmt-core/clickstack/kustomization.yaml),
all on Gateway `gateway-system/gateway` section `https`:

| HTTPRoute | Hostname | Backend |
| --- | --- | --- |
| `hyperdx` | `hyperdx.mgmt-core.connectedcare.io` | Service `cs:3000` (this chart) |
| `clickstack-otel` | `clickstack-otel.mgmt-core.connectedcare.io` | `clickstack-otel-router` (not this chart) |
| `clickstack-otel-browser` | `clickstack-otel-browser.mgmt-core.connectedcare.io` | `clickstack-otel-browser-gateway` (not this chart) |

See
[Gateways, DNS and certificates](https://github.com/BEWATEC-Berlin/platform-infra/blob/main/openwiki/networking/gateways-dns-and-certificates.md).

## Platform components that depend on chart output

- **OTel router** (`mgmt-core-clickstack-otel-router`, upstream
  `opentelemetry-collector` chart): its ClickHouse exporter reads
  `CLICKHOUSE_ENDPOINT`, `CLICKHOUSE_USER` and
  `HYPERDX_OTEL_EXPORTER_CLICKHOUSE_DATABASE` from this chart's ConfigMap
  `clickstack-config`, and `CLICKHOUSE_PASSWORD` from `clickstack-secret`
  ([`addons/clickstack-otel-router/application.yaml`](https://github.com/BEWATEC-Berlin/platform-infra/blob/main/k8s/control-plane/argocd/fleet/addons/clickstack-otel-router/application.yaml)).
  Moving `CLICKHOUSE_ENDPOINT`, `CLICKHOUSE_USER` or
  `HYPERDX_OTEL_EXPORTER_CLICKHOUSE_DATABASE` into `hyperdx.configSecretRefs`
  would remove it from the ConfigMap and break the router.
  `CLICKHOUSE_PASSWORD` is unaffected: the router reads it from
  `clickstack-secret`, which `configSecretRefs` does not change.
- **Security**: `CiliumNetworkPolicy/clickstack` in namespace `clickstack`
  ([`platform-network-policies/clickstack.yaml`](https://github.com/BEWATEC-Berlin/platform-infra/blob/main/k8s/catalog/security/platform-network-policies/clickstack.yaml))
  and Kyverno policies
  [`default-clickstack-hyperdx-restricted-runtime.yaml`](https://github.com/BEWATEC-Berlin/platform-infra/blob/main/k8s/catalog/security/kyverno-policies/base/default-clickstack-hyperdx-restricted-runtime.yaml)
  and
  [`default-clickstack-stateful-restricted-runtime.yaml`](https://github.com/BEWATEC-Berlin/platform-infra/blob/main/k8s/catalog/security/kyverno-policies/base/default-clickstack-stateful-restricted-runtime.yaml),
  scoped to namespace `clickstack`. Both are Kyverno `MutatingPolicy`
  objects with `failurePolicy: Fail`: they fill in security settings at
  admission, not through Helm values.
  - The HyperDX policy matches Deployments, ReplicaSets and Pods whose name
    (or `generateName`) matches `^cs(-.*)?$`, so it depends on
    `fullnameOverride: cs`. This chart renders the `wait-for-mongodb` init
    container and the `app` container without a `securityContext`
    (`templates/hyperdx/deployment.yaml`); the policy adds a restricted
    context to each (UID `65534` and `1000`) and default resources to
    `wait-for-mongodb`, only for fields that are absent.
  - The stateful policy matches StatefulSets and Pods whose name starts with
    `cs-clickhouse-clickhouse-0-0` or `cs-keeper-keeper-0` and replaces the
    first container's whole `securityContext` (UID `101`), because the
    ClickHouse operator does not project the CR's `containerTemplate`
    security context into the StatefulSet and adds capabilities.

  A renamed workload silently loses these mutations and runs with the
  chart's or operator's own context ([namespace](https://github.com/BEWATEC-Berlin/platform-infra/blob/main/k8s/catalog/observability/clickstack-control-plane/namespace.yaml) `clickstack` enforces Pod
  Security `privileged`, auditing and warning at `baseline`); with
  `failurePolicy: Fail`, a Kyverno outage blocks admission of matching
  objects. See
  [Security baseline](https://github.com/BEWATEC-Berlin/platform-infra/blob/main/openwiki/security/security-baseline.md).
- **Planned S3 tiering**: the ClickHouse S3 settings and the chart pin are
  discussed in platform-infra
  [`docs/architecture/observability-s3-tiering.md`](https://github.com/BEWATEC-Berlin/platform-infra/blob/main/docs/architecture/observability-s3-tiering.md).

## Other ConnectedCare services

No BEWATEC application calls this chart's components directly. Application
telemetry reaches ClickStack through the platform's collectors and the OTel
router above, all defined in
[platform-infra](https://github.com/BEWATEC-Berlin/platform-infra). The chart
has no Keycloak client, MQTT topic, shared database or library dependency on
any other BEWATEC repository. Its upstream is
[`ClickHouse/ClickStack-helm-charts`](https://github.com/ClickHouse/ClickStack-helm-charts).
