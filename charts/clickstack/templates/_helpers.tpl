{{/*
Expand the name of the chart.
*/}}
{{- define "clickstack.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "clickstack.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
HyperDX app resource name. When fullnameOverride is set the user expects full
control over naming, so the -app suffix is omitted. Without the override the
suffix is kept for backward compatibility.
*/}}
{{- define "clickstack.hyperdx.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-app" (include "clickstack.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "clickstack.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "clickstack.labels" -}}
helm.sh/chart: {{ include "clickstack.chart" . }}
{{ include "clickstack.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "clickstack.selectorLabels" -}}
app.kubernetes.io/name: {{ include "clickstack.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
MongoDB CR name
*/}}
{{- define "clickstack.mongodb.fullname" -}}
{{- printf "%s-mongodb" (include "clickstack.fullname" .) -}}
{{- end }}

{{/*
MongoDB headless service name (created by the MCK operator as {cr-name}-svc)
*/}}
{{- define "clickstack.mongodb.svc" -}}
{{- printf "%s-svc" (include "clickstack.mongodb.fullname" .) -}}
{{- end }}

{{/*
OTEL Collector fullname (matches subchart with alias otel-collector)
*/}}
{{- define "clickstack.otel.fullname" -}}
{{- printf "%s-otel-collector" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/*
ClickHouse cluster CR name
*/}}
{{- define "clickstack.clickhouse.fullname" -}}
{{- printf "%s-clickhouse" (include "clickstack.fullname" .) -}}
{{- end }}

{{/*
ClickHouse Keeper CR name
*/}}
{{- define "clickstack.clickhouse.keeper" -}}
{{- printf "%s-keeper" (include "clickstack.fullname" .) -}}
{{- end }}

{{/*
ClickHouse headless service name. The operator creates a headless service named {CR}-clickhouse-headless.
*/}}
{{- define "clickstack.clickhouse.svc" -}}
{{- printf "%s-clickhouse-headless" (include "clickstack.clickhouse.fullname" .) -}}
{{- end }}

{{/*
Shared HyperDX Secret name. Defaults to the chart-created clickstack-secret,
or uses hyperdx.existingSecret.name when provided.
*/}}
{{- define "clickstack.hyperdx.secretName" -}}
{{- default "clickstack-secret" .Values.hyperdx.existingSecret.name -}}
{{- end }}

{{/*
Whether HyperDX workloads should reference a shared Secret.
*/}}
{{- define "clickstack.hyperdx.hasSecret" -}}
{{- if or (ne .Values.hyperdx.secrets nil) .Values.hyperdx.existingSecret.name -}}
true
{{- end -}}
{{- end }}

{{/*
Render env entries for config keys supplied by externally managed Secrets.
*/}}
{{- define "clickstack.hyperdx.configSecretEnv" -}}
{{- range $name, $ref := (.Values.hyperdx.configSecretRefs | default dict) }}
- name: {{ $name }}
  valueFrom:
    secretKeyRef:
      name: {{ required (printf "hyperdx.configSecretRefs.%s.name is required" $name) $ref.name | quote }}
      key: {{ default $name $ref.key | quote }}
      optional: {{ default false $ref.optional }}
{{- end }}
{{- end }}

{{/*
Render DEFAULT_CONNECTIONS and DEFAULT_SOURCES env entries.
*/}}
{{- define "clickstack.hyperdx.defaultConfigEnv" -}}
{{- if .Values.hyperdx.deployment.useExistingConfigSecret }}
- name: DEFAULT_CONNECTIONS
  valueFrom:
    secretKeyRef:
      name: {{ .Values.hyperdx.deployment.existingConfigSecret | quote }}
      key: {{ .Values.hyperdx.deployment.existingConfigConnectionsKey | quote }}
      optional: false
- name: DEFAULT_SOURCES
  valueFrom:
    secretKeyRef:
      name: {{ .Values.hyperdx.deployment.existingConfigSecret | quote }}
      key: {{ .Values.hyperdx.deployment.existingConfigSourcesKey | quote }}
      optional: false
{{- else }}
{{- if and .Values.hyperdx.deployment.defaultConnections (ne .Values.hyperdx.secrets nil) }}
- name: DEFAULT_CONNECTIONS
  value: {{ tpl .Values.hyperdx.deployment.defaultConnections . | quote }}
{{- end }}
{{- if .Values.hyperdx.deployment.defaultSources }}
- name: DEFAULT_SOURCES
  value: {{ tpl .Values.hyperdx.deployment.defaultSources . | quote }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Validate that existing shared Secret mode does not render the default Mongo URI
from hyperdx.secrets into clickstack-config.
*/}}
{{- define "clickstack.validateHyperdxConfigSecretRefs" -}}
{{- $configSecretRefs := .Values.hyperdx.configSecretRefs | default dict -}}
{{- $mongoURI := get (.Values.hyperdx.config | default dict) "MONGO_URI" | default "" -}}
{{- if and .Values.hyperdx.existingSecret.name (contains ".Values.hyperdx.secrets" (toString $mongoURI)) (not (hasKey $configSecretRefs "MONGO_URI")) -}}
{{- fail "hyperdx.configSecretRefs.MONGO_URI is required when hyperdx.existingSecret.name is set and hyperdx.config.MONGO_URI uses hyperdx.secrets" -}}
{{- end -}}
{{- end }}

{{/*
Validate that existing shared Secret mode does not render DEFAULT_CONNECTIONS
from hyperdx.secrets into HyperDX workloads.
*/}}
{{- define "clickstack.validateHyperdxDefaultConnections" -}}
{{- $defaultConnections := .Values.hyperdx.deployment.defaultConnections | default "" -}}
{{- if and .Values.hyperdx.existingSecret.name (contains ".Values.hyperdx.secrets" (toString $defaultConnections)) (not .Values.hyperdx.deployment.useExistingConfigSecret) -}}
{{- fail "hyperdx.deployment.useExistingConfigSecret is required when hyperdx.existingSecret.name is set and hyperdx.deployment.defaultConnections uses hyperdx.secrets" -}}
{{- end -}}
{{- end }}

{{/*
Validate MongoDB password bridge externalization in existing shared Secret mode.
*/}}
{{- define "clickstack.validateMongoDBExistingSecret" -}}
{{- if and .Values.hyperdx.existingSecret.name .Values.mongodb.enabled (not .Values.mongodb.existingPasswordSecret.name) -}}
{{- fail "mongodb.existingPasswordSecret.name is required when hyperdx.existingSecret.name is set and mongodb is enabled" -}}
{{- end -}}
{{- end }}

{{/*
Validate ClickHouse user password externalization in existing shared Secret mode.
*/}}
{{- define "clickstack.validateClickHouseExistingSecret" -}}
{{- if and .Values.hyperdx.existingSecret.name .Values.clickhouse.enabled (not .Values.clickhouse.existingUserPasswordSecret.name) -}}
{{- fail "clickhouse.existingUserPasswordSecret.name is required when hyperdx.existingSecret.name is set and clickhouse is enabled" -}}
{{- end -}}
{{- end }}
