# Files

- [External Secret Mode (BEWATEC changes)](external-secret-mode.md) - The BEWATEC fork's only functional change to the upstream ClickStack chart - values that point HyperDX, MongoDB and ClickHouse at externally managed Secrets (hyperdx.existingSecret, hyperdx.configSecretRefs, mongodb.existingPasswordSecret, clickhouse.existingUserPasswordSecret), ClickHouse from_env password rendering, the render-time validations, their unit tests, the pending changesets, and known gaps.
