---
type: guide
title: Quickstart
description: Entry page for the ClickStack-helm-charts OpenWiki - what BEWATEC's fork of the upstream ClickStack Helm charts changes, how the platform consumes it on mgmt-core (pinned Git commit, no BEWATEC CI or chart repository), which page answers which question, and how to get to the platform-infra wiki.
tags: [quickstart, navigation, clickstack, hyperdx, helm, fork]
verified:
  - by: openwiki/0.9.0
    at: 2026-11-21T19:46:29.038Z
sources:
  - id: openwiki-source-8037e2358a2c4f9b2c722a11
    resource: repo://AGENTS.md
  - id: openwiki-source-a47df811c109c84e6152518a
    resource: repo://charts/clickstack-operators/Chart.yaml
  - id: openwiki-source-c35a237e165949dfd34bd962
    resource: repo://charts/clickstack/Chart.yaml
  - id: openwiki-source-23775c3de52f3ab95a13cb8b
    resource: repo://README.md
generated: { by: "claude-code", at: "2026-11-21T19:46:29.038Z" }
---

# Quickstart

`BEWATEC-Berlin/ClickStack-helm-charts` is a fork of
[`ClickHouse/ClickStack-helm-charts`](https://github.com/ClickHouse/ClickStack-helm-charts)
(git remote `upstream`). It holds two Helm charts: `charts/clickstack`
(HyperDX, ClickHouse and MongoDB custom resources, bundled OTel collector) and
`charts/clickstack-operators` (the MongoDB and ClickHouse operators).

The fork exists for one change: letting `charts/clickstack` read its built-in
credentials (the HyperDX shared Secret and config keys, the MongoDB user
password and the ClickHouse `app` and `otelcollector` passwords) from Secrets
that something else manages, instead of rendering them from Helm values.
Custom ClickHouse users and other values are still rendered as supplied. That is two commits on top of upstream release `f114951`;
everything else is upstream code. This wiki documents that layer and only as
much of the upstream chart as is needed to understand it.

The platform consumes the fork in one place: Argo CD Application
`mgmt-core-clickstack-control-plane` in
[platform-infra](https://github.com/BEWATEC-Berlin/platform-infra) renders
`charts/clickstack` from this Git repository at a pinned commit into namespace
`clickstack` on the `mgmt-core` cluster. There is no BEWATEC pipeline, image
or Helm repository for the fork; the upstream GitHub workflows have not run on
it.

## Which page answers what

| Question | Page |
| --- | --- |
| What did BEWATEC change, which values exist, what fails at render time, what must the external Secrets contain? | [External Secret Mode](fork/external-secret-mode.md) |
| How is the upstream chart laid out, what are the rendered object names, which upstream CI and release tooling applies? | [Chart Structure and Upstream Tooling](chart/chart-structure.md) |
| Which Argo CD Application, revision, release name, namespace, Secrets, 1Password items and hostnames does the platform use? What depends on the chart's ConfigMap? | [Platform Touchpoints](platform/platform-touchpoints.md) |

## Common tasks

- **Change chart behaviour for the platform**: change templates here, add
  tests under `charts/clickstack/tests/`, run `helm unittest charts/clickstack`
  locally (no CI runs it), merge to this fork's `main`, then move
  `targetRevision` in platform-infra. Check
  [Platform Touchpoints](platform/platform-touchpoints.md#platform-components-that-depend-on-chart-output)
  first: the OTel router, Kyverno policies and platform Secret templates
  depend on rendered names and ConfigMap keys.
- **Rotate or add a credential**: the chart only references Secrets. In
  platform-infra, ExternalSecrets produce the HyperDX, MongoDB and ClickHouse
  user credentials, while `ObjectStorageAccess/clickstack-clickhouse-s3`
  publishes the ClickHouse S3 credentials. See
  [Platform Touchpoints](platform/platform-touchpoints.md#secrets).
- **Pull in a new upstream release**: merge `upstream/main` and re-check the
  files the fork touches (`_helpers.tpl`, `hyperdx/*`, `mongodb/*`,
  `clickhouse/cluster.yaml`, `values.yaml`), listed on
  [External Secret Mode](fork/external-secret-mode.md).

## Platform side

The platform-infra wiki covers the rest of ClickStack (router, collectors,
agents) and the platform concepts used here:
[Observability stack](https://github.com/BEWATEC-Berlin/platform-infra/blob/main/openwiki/observability/observability-stack.md),
[Fleet add-ons](https://github.com/BEWATEC-Berlin/platform-infra/blob/main/openwiki/gitops/fleet-addons.md),
[Secrets and External Secrets](https://github.com/BEWATEC-Berlin/platform-infra/blob/main/openwiki/identity/secrets-and-external-secrets.md).
