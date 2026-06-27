# clickstack

![Version: 3.0.0](https://img.shields.io/badge/Version-3.0.0-informational?style=flat)
![Build Status](https://github.com/ClickHouse/ClickStack-helm-charts/actions/workflows/helm-test.yaml/badge.svg)

A Helm chart for ClickStack - Full-stack observability with ClickHouse, OpenTelemetry, and HyperDX

**Homepage:** <https://clickhouse.com/docs/use-cases/observability/clickstack>

## Source Code

* <https://github.com/hyperdxio/hyperdx>
* <https://github.com/hyperdxio/helm-charts>

## Prerequisites

Install the [clickstack-operators](../clickstack-operators) chart first so MongoDB and ClickHouse CRDs are available.

## Quick Start

```bash
helm repo add clickstack https://clickhouse.github.io/ClickStack-helm-charts
helm repo update
helm install my-clickstack clickstack/clickstack
```

See the [ClickStack Helm documentation](https://clickhouse.com/docs/use-cases/observability/clickstack/deployment/helm) for cloud-specific guides, ingress setup, and troubleshooting.

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://open-telemetry.github.io/opentelemetry-helm-charts | otel-collector(opentelemetry-collector) | ~0.146.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| additionalManifests | list | `[]` |  |
| clickhouse.cluster.spec.containerTemplate.image.repository | string | `"clickhouse/clickhouse-server"` |  |
| clickhouse.cluster.spec.containerTemplate.image.tag | string | `"25.7-alpine"` |  |
| clickhouse.cluster.spec.dataVolumeClaimSpec.accessModes[0] | string | `"ReadWriteOnce"` |  |
| clickhouse.cluster.spec.dataVolumeClaimSpec.resources.requests.storage | string | `"10Gi"` |  |
| clickhouse.cluster.spec.keeperClusterRef.name | string | `"{{ include \"clickstack.clickhouse.keeper\" . }}"` |  |
| clickhouse.cluster.spec.replicas | int | `1` |  |
| clickhouse.cluster.spec.settings.extraConfig.keep_alive_timeout | int | `64` |  |
| clickhouse.cluster.spec.settings.extraConfig.max_concurrent_queries | int | `100` |  |
| clickhouse.cluster.spec.settings.extraConfig.max_connections | int | `4096` |  |
| clickhouse.cluster.spec.settings.extraUsersConfig.users.app.grants[0].query | string | `"GRANT SHOW ON *.*, SELECT ON system.*, SELECT ON default.*"` |  |
| clickhouse.cluster.spec.settings.extraUsersConfig.users.app.password | string | `"{{ .Values.hyperdx.secrets.CLICKHOUSE_APP_PASSWORD }}"` |  |
| clickhouse.cluster.spec.settings.extraUsersConfig.users.app.profile | string | `"default"` |  |
| clickhouse.cluster.spec.settings.extraUsersConfig.users.otelcollector.grants[0].query | string | `"GRANT SELECT,INSERT,CREATE,SHOW ON default.*"` |  |
| clickhouse.cluster.spec.settings.extraUsersConfig.users.otelcollector.password | string | `"{{ .Values.hyperdx.secrets.CLICKHOUSE_PASSWORD }}"` |  |
| clickhouse.cluster.spec.settings.extraUsersConfig.users.otelcollector.profile | string | `"default"` |  |
| clickhouse.cluster.spec.shards | int | `1` |  |
| clickhouse.enabled | bool | `true` |  |
| clickhouse.keeper.spec.dataVolumeClaimSpec.accessModes[0] | string | `"ReadWriteOnce"` |  |
| clickhouse.keeper.spec.dataVolumeClaimSpec.resources.requests.storage | string | `"5Gi"` |  |
| clickhouse.keeper.spec.replicas | int | `1` |  |
| clickhouse.nativePort | int | `9000` |  |
| clickhouse.port | int | `8123` |  |
| clickhouse.prometheus.enabled | bool | `true` |  |
| clickhouse.prometheus.port | int | `9363` |  |
| global.imagePullSecrets | list | `[]` |  |
| global.imageRegistry | string | `""` |  |
| hyperdx.autoscaling.enabled | bool | `false` |  |
| hyperdx.autoscaling.spec | object | `{}` |  |
| hyperdx.config.API_PORT | string | `"8000"` |  |
| hyperdx.config.APP_PORT | string | `"3000"` |  |
| hyperdx.config.CLICKHOUSE_ENDPOINT | string | `"tcp://{{ include \"clickstack.clickhouse.svc\" . }}:{{ .Values.clickhouse.nativePort }}?dial_timeout=10s"` |  |
| hyperdx.config.CLICKHOUSE_PROMETHEUS_METRICS_ENDPOINT | string | `"{{ include \"clickstack.clickhouse.svc\" . }}:{{ .Values.clickhouse.prometheus.port }}"` |  |
| hyperdx.config.CLICKHOUSE_SERVER_ENDPOINT | string | `"{{ include \"clickstack.clickhouse.svc\" . }}:{{ .Values.clickhouse.nativePort }}"` |  |
| hyperdx.config.CLICKHOUSE_USER | string | `"otelcollector"` |  |
| hyperdx.config.FRONTEND_URL | string | `"http://localhost:3000"` |  |
| hyperdx.config.HYPERDX_API_PORT | string | `"8000"` |  |
| hyperdx.config.HYPERDX_APP_PORT | string | `"3000"` |  |
| hyperdx.config.HYPERDX_LOG_LEVEL | string | `"info"` |  |
| hyperdx.config.HYPERDX_OTEL_EXPORTER_CLICKHOUSE_DATABASE | string | `"default"` |  |
| hyperdx.config.MONGO_URI | string | `"mongodb://hyperdx:{{ .Values.hyperdx.secrets.MONGODB_PASSWORD }}@{{ include \"clickstack.mongodb.svc\" . }}:27017/hyperdx?authSource=hyperdx"` |  |
| hyperdx.config.OPAMP_PORT | string | `"4320"` |  |
| hyperdx.config.OPAMP_SERVER_URL | string | `"http://{{ include \"clickstack.hyperdx.fullname\" . }}:{{ .Values.hyperdx.ports.opamp }}"` |  |
| hyperdx.config.OTEL_EXPORTER_OTLP_ENDPOINT | string | `"http://{{ include \"clickstack.otel.fullname\" . }}:4318"` |  |
| hyperdx.config.OTEL_SERVICE_NAME | string | `"hdx-oss-api"` |  |
| hyperdx.config.RUN_SCHEDULED_TASKS_EXTERNALLY | string | `"false"` |  |
| hyperdx.config.USAGE_STATS_ENABLED | string | `"true"` |  |
| hyperdx.deployment.annotations | object | `{}` |  |
| hyperdx.deployment.defaultConnections | string | `"[\n  {\n    \"name\": \"Local ClickHouse\",\n    \"host\": \"http://{{ include \"clickstack.clickhouse.svc\" . }}:8123\",\n    \"port\": 8123,\n    \"username\": \"app\",\n    \"password\": \"{{ .Values.hyperdx.secrets.CLICKHOUSE_APP_PASSWORD }}\"\n  }\n]\n"` |  |
| hyperdx.deployment.defaultSources | string | `"[\n  {\n    \"from\": {\n      \"databaseName\": \"default\",\n      \"tableName\": \"otel_logs\"\n    },\n    \"kind\": \"log\",\n    \"timestampValueExpression\": \"Timestamp\",\n    \"name\": \"Logs\",\n    \"displayedTimestampValueExpression\": \"Timestamp\",\n    \"implicitColumnExpression\": \"Body\",\n    \"serviceNameExpression\": \"ServiceName\",\n    \"bodyExpression\": \"Body\",\n    \"eventAttributesExpression\": \"LogAttributes\",\n    \"resourceAttributesExpression\": \"ResourceAttributes\",\n    \"defaultTableSelectExpression\": \"Timestamp,ServiceName,SeverityText,Body\",\n    \"severityTextExpression\": \"SeverityText\",\n    \"traceIdExpression\": \"TraceId\",\n    \"spanIdExpression\": \"SpanId\",\n    \"connection\": \"Local ClickHouse\",\n    \"traceSourceId\": \"Traces\",\n    \"sessionSourceId\": \"Sessions\",\n    \"metricSourceId\": \"Metrics\"\n  },\n  {\n    \"from\": {\n      \"databaseName\": \"default\",\n      \"tableName\": \"otel_traces\"\n    },\n    \"kind\": \"trace\",\n    \"timestampValueExpression\": \"Timestamp\",\n    \"name\": \"Traces\",\n    \"displayedTimestampValueExpression\": \"Timestamp\",\n    \"implicitColumnExpression\": \"SpanName\",\n    \"serviceNameExpression\": \"ServiceName\",\n    \"bodyExpression\": \"SpanName\",\n    \"eventAttributesExpression\": \"SpanAttributes\",\n    \"resourceAttributesExpression\": \"ResourceAttributes\",\n    \"defaultTableSelectExpression\": \"Timestamp,ServiceName,StatusCode,round(Duration/1e6),SpanName\",\n    \"traceIdExpression\": \"TraceId\",\n    \"spanIdExpression\": \"SpanId\",\n    \"durationExpression\": \"Duration\",\n    \"durationPrecision\": 9,\n    \"parentSpanIdExpression\": \"ParentSpanId\",\n    \"spanNameExpression\": \"SpanName\",\n    \"spanKindExpression\": \"SpanKind\",\n    \"statusCodeExpression\": \"StatusCode\",\n    \"statusMessageExpression\": \"StatusMessage\",\n    \"connection\": \"Local ClickHouse\",\n    \"logSourceId\": \"Logs\",\n    \"sessionSourceId\": \"Sessions\",\n    \"metricSourceId\": \"Metrics\"\n  },\n  {\n    \"from\": {\n      \"databaseName\": \"default\",\n      \"tableName\": \"\"\n    },\n    \"kind\": \"metric\",\n    \"timestampValueExpression\": \"TimeUnix\",\n    \"name\": \"Metrics\",\n    \"resourceAttributesExpression\": \"ResourceAttributes\",\n    \"metricTables\": {\n      \"gauge\": \"otel_metrics_gauge\",\n      \"histogram\": \"otel_metrics_histogram\",\n      \"sum\": \"otel_metrics_sum\",\n      \"_id\": \"682586a8b1f81924e628e808\",\n      \"id\": \"682586a8b1f81924e628e808\"\n    },\n    \"connection\": \"Local ClickHouse\",\n    \"logSourceId\": \"Logs\",\n    \"traceSourceId\": \"Traces\",\n    \"sessionSourceId\": \"Sessions\"\n  },\n  {\n    \"from\": {\n      \"databaseName\": \"default\",\n      \"tableName\": \"hyperdx_sessions\"\n    },\n    \"kind\": \"session\",\n    \"timestampValueExpression\": \"TimestampTime\",\n    \"name\": \"Sessions\",\n    \"displayedTimestampValueExpression\": \"Timestamp\",\n    \"implicitColumnExpression\": \"Body\",\n    \"serviceNameExpression\": \"ServiceName\",\n    \"bodyExpression\": \"Body\",\n    \"eventAttributesExpression\": \"LogAttributes\",\n    \"resourceAttributesExpression\": \"ResourceAttributes\",\n    \"defaultTableSelectExpression\": \"Timestamp,ServiceName,SeverityText,Body\",\n    \"severityTextExpression\": \"SeverityText\",\n    \"traceIdExpression\": \"TraceId\",\n    \"spanIdExpression\": \"SpanId\",\n    \"connection\": \"Local ClickHouse\",\n    \"logSourceId\": \"Logs\",\n    \"traceSourceId\": \"Traces\",\n    \"metricSourceId\": \"Metrics\"\n  }\n]\n"` |  |
| hyperdx.deployment.env | list | `[]` |  |
| hyperdx.deployment.existingConfigConnectionsKey | string | `"connections.json"` |  |
| hyperdx.deployment.existingConfigSecret | string | `""` |  |
| hyperdx.deployment.existingConfigSourcesKey | string | `"sources.json"` |  |
| hyperdx.deployment.image.pullPolicy | string | `"IfNotPresent"` |  |
| hyperdx.deployment.image.repository | string | `"docker.hyperdx.io/hyperdx/hyperdx"` |  |
| hyperdx.deployment.image.tag | string | `nil` |  |
| hyperdx.deployment.initContainers | list | `[]` |  |
| hyperdx.deployment.labels | object | `{}` |  |
| hyperdx.deployment.livenessProbe.enabled | bool | `true` |  |
| hyperdx.deployment.livenessProbe.failureThreshold | int | `3` |  |
| hyperdx.deployment.livenessProbe.initialDelaySeconds | int | `10` |  |
| hyperdx.deployment.livenessProbe.periodSeconds | int | `30` |  |
| hyperdx.deployment.livenessProbe.timeoutSeconds | int | `5` |  |
| hyperdx.deployment.nodeSelector | object | `{}` |  |
| hyperdx.deployment.priorityClassName | string | `""` |  |
| hyperdx.deployment.readinessProbe.enabled | bool | `true` |  |
| hyperdx.deployment.readinessProbe.failureThreshold | int | `3` |  |
| hyperdx.deployment.readinessProbe.initialDelaySeconds | int | `1` |  |
| hyperdx.deployment.readinessProbe.periodSeconds | int | `10` |  |
| hyperdx.deployment.readinessProbe.timeoutSeconds | int | `5` |  |
| hyperdx.deployment.replicas | int | `1` |  |
| hyperdx.deployment.resources | object | `{}` |  |
| hyperdx.deployment.tolerations | list | `[]` |  |
| hyperdx.deployment.topologySpreadConstraints | list | `[]` |  |
| hyperdx.deployment.useExistingConfigSecret | bool | `false` |  |
| hyperdx.deployment.volumeMounts | list | `[]` |  |
| hyperdx.deployment.volumes | list | `[]` |  |
| hyperdx.deployment.waitForMongodb.image | string | `"busybox@sha256:1fcf5df59121b92d61e066df1788e8df0cc35623f5d62d9679a41e163b6a0cdb"` |  |
| hyperdx.deployment.waitForMongodb.pullPolicy | string | `"IfNotPresent"` |  |
| hyperdx.ingress.additionalIngresses | list | `[]` |  |
| hyperdx.ingress.annotations | object | `{}` |  |
| hyperdx.ingress.enabled | bool | `false` |  |
| hyperdx.ingress.spec | object | `{}` |  |
| hyperdx.networkPolicy.enabled | bool | `false` |  |
| hyperdx.networkPolicy.spec | object | `{}` |  |
| hyperdx.podDisruptionBudget.enabled | bool | `false` |  |
| hyperdx.ports.api | int | `8000` |  |
| hyperdx.ports.app | int | `3000` |  |
| hyperdx.ports.opamp | int | `4320` |  |
| hyperdx.secrets.CLICKHOUSE_APP_PASSWORD | string | `"hyperdx"` |  |
| hyperdx.secrets.CLICKHOUSE_PASSWORD | string | `"otelcollectorpass"` |  |
| hyperdx.secrets.HYPERDX_API_KEY | string | `"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"` |  |
| hyperdx.secrets.MONGODB_PASSWORD | string | `"hyperdx"` |  |
| hyperdx.service.annotations | object | `{}` |  |
| hyperdx.service.apiPort.enabled | bool | `false` |  |
| hyperdx.service.type | string | `"ClusterIP"` |  |
| hyperdx.serviceAccount.annotations | object | `{}` |  |
| hyperdx.serviceAccount.create | bool | `false` |  |
| hyperdx.serviceAccount.name | string | `""` |  |
| hyperdx.tasks.checkAlerts.additionalArgs | object | `{}` |  |
| hyperdx.tasks.checkAlerts.resources.limits.cpu | string | `"200m"` |  |
| hyperdx.tasks.checkAlerts.resources.limits.memory | string | `"256Mi"` |  |
| hyperdx.tasks.checkAlerts.resources.requests.cpu | string | `"100m"` |  |
| hyperdx.tasks.checkAlerts.resources.requests.memory | string | `"128Mi"` |  |
| hyperdx.tasks.checkAlerts.schedule | string | `"*/1 * * * *"` |  |
| hyperdx.tasks.enabled | bool | `false` |  |
| mongodb.enabled | bool | `true` |  |
| mongodb.spec.additionalMongodConfig."storage.wiredTiger.engineConfig.journalCompressor" | string | `"zlib"` |  |
| mongodb.spec.members | int | `1` |  |
| mongodb.spec.security.authentication.modes[0] | string | `"SCRAM"` |  |
| mongodb.spec.type | string | `"ReplicaSet"` |  |
| mongodb.spec.users[0].db | string | `"hyperdx"` |  |
| mongodb.spec.users[0].name | string | `"hyperdx"` |  |
| mongodb.spec.users[0].passwordSecretRef.name | string | `"{{ include \"clickstack.mongodb.fullname\" . }}-password"` |  |
| mongodb.spec.users[0].roles[0].db | string | `"hyperdx"` |  |
| mongodb.spec.users[0].roles[0].name | string | `"dbOwner"` |  |
| mongodb.spec.users[0].roles[1].db | string | `"admin"` |  |
| mongodb.spec.users[0].roles[1].name | string | `"clusterMonitor"` |  |
| mongodb.spec.users[0].scramCredentialsSecretName | string | `"{{ include \"clickstack.mongodb.fullname\" . }}-scram"` |  |
| mongodb.spec.version | string | `"5.0.32"` |  |
| otel-collector.enabled | bool | `true` |  |
| otel-collector.extraEnvsFrom[0].configMapRef.name | string | `"clickstack-config"` |  |
| otel-collector.extraEnvsFrom[1].secretRef.name | string | `"clickstack-secret"` |  |
| otel-collector.image.repository | string | `"docker.clickhouse.com/clickhouse/clickstack-otel-collector"` |  |
| otel-collector.image.tag | string | `"2.19.0"` |  |
| otel-collector.mode | string | `"deployment"` |  |
| otel-collector.ports.fluentd.containerPort | int | `24225` |  |
| otel-collector.ports.fluentd.enabled | bool | `true` |  |
| otel-collector.ports.fluentd.protocol | string | `"TCP"` |  |
| otel-collector.ports.fluentd.servicePort | int | `24225` |  |
| otel-collector.ports.health-check.containerPort | int | `13133` |  |
| otel-collector.ports.health-check.enabled | bool | `true` |  |
| otel-collector.ports.health-check.protocol | string | `"TCP"` |  |
| otel-collector.ports.health-check.servicePort | int | `13133` |  |
| otel-collector.ports.jaeger-compact.enabled | bool | `false` |  |
| otel-collector.ports.jaeger-grpc.enabled | bool | `false` |  |
| otel-collector.ports.jaeger-thrift.enabled | bool | `false` |  |
| otel-collector.ports.metrics.containerPort | int | `8888` |  |
| otel-collector.ports.metrics.enabled | bool | `true` |  |
| otel-collector.ports.metrics.protocol | string | `"TCP"` |  |
| otel-collector.ports.metrics.servicePort | int | `8888` |  |
| otel-collector.ports.otlp-http.containerPort | int | `4318` |  |
| otel-collector.ports.otlp-http.enabled | bool | `true` |  |
| otel-collector.ports.otlp-http.protocol | string | `"TCP"` |  |
| otel-collector.ports.otlp-http.servicePort | int | `4318` |  |
| otel-collector.ports.otlp.appProtocol | string | `"grpc"` |  |
| otel-collector.ports.otlp.containerPort | int | `4317` |  |
| otel-collector.ports.otlp.enabled | bool | `true` |  |
| otel-collector.ports.otlp.protocol | string | `"TCP"` |  |
| otel-collector.ports.otlp.servicePort | int | `4317` |  |
| otel-collector.ports.zipkin.enabled | bool | `false` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
