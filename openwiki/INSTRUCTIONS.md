# OpenWiki brief for ClickStack-helm-charts (BEWATEC fork)

This repository is BEWATEC's fork of the upstream ClickStack Helm charts
(`ClickHouse/ClickStack-helm-charts`, remote `upstream`). The platform deploys
`charts/clickstack` from this fork, pinned to a commit, as the central
ClickStack control plane (HyperDX, ClickHouse, MongoDB, bundled OTel
collector) on the `mgmt-core` cluster. Readers are platform engineers,
application engineers, and their coding agents.

Document the BEWATEC layer, not the whole upstream chart:

- the fork's commits on top of upstream release `f114951` ("Release ClickStack
  Helm Charts (#229)"): externally managed Secret support for HyperDX,
  MongoDB and ClickHouse (`hyperdx.existingSecret`, `hyperdx.configSecretRefs`,
  `mongodb.existingPasswordSecret`, `clickhouse.existingUserPasswordSecret`),
  the ClickHouse `from_env` password rendering, the render-time validations
  in `_helpers.tpl`, the unit tests that cover them, and the pending
  changesets in `.changeset/`;
- just enough of the upstream chart structure (templates, naming helpers,
  values layout, operator dependency chart) to explain those changes and the
  object names the platform relies on;
- how the fork reaches the platform: there is no BEWATEC CI, image or Helm
  repository for it; platform-infra pins a commit of this Git repository in an
  Argo CD Application.

The GitHub workflows, Changesets release flow, Kodiak config, examples and
integration tests are upstream's. Mention them only to say whether they apply
to the fork. Keep the wiki to a handful of pages.

Ground every statement in the templates, `values.yaml`, `Chart.yaml`, and
`tests/`. `README.md`, `AGENTS.md`, `docs/` and value comments lag the code
and are written for upstream; when one disagrees with a template, describe
what the template does and name the doc that disagrees.

The page `platform/platform-touchpoints.md` is required. It is the cross-repo
contract with the platform-infra wiki. For each cluster (mgmt-core,
integration, staging, production, mgmt-cicd) state whether this chart runs
there and list the exact identifiers the platform uses for it, spelled
exactly as in the manifests: Argo CD Application, ApplicationSet and
AppProject names, pinned `targetRevision`, release name and
`fullnameOverride`, namespace, the rendered object names (Service, ClickHouse,
Keeper, MongoDB), the externally managed Secrets and the keys the chart reads
from them, the ExternalSecrets and 1Password items that produce them (names
only), and hostnames. Identifiers defined in platform-infra must name the
platform-infra path as an absolute GitHub URL under
`https://github.com/BEWATEC-Berlin/platform-infra/blob/main/`; never cite
them as `repo://` claims. Link platform concepts to existing platform-infra
wiki pages under
`https://github.com/BEWATEC-Berlin/platform-infra/blob/main/openwiki/`.

Never reproduce secret values, tokens, passwords, or credential-bearing values.
The chart's default `hyperdx.secrets` values are upstream development defaults;
do not copy them. Naming a Secret, Secret key, ExternalSecret, SecretStore or
1Password item is fine.
