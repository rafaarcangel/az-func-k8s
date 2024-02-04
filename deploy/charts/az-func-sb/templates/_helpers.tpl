{{/*
Ensure path volume is right "/" prefix format
*/}}
{{- define "az-func-sb.ensure-path" -}}
  {{- if not (hasPrefix "/" .Values.volumeAzStorage.mountPath) -}}
    {{ printf "%s%s" "/" .Values.volumeAzStorage.mountPath }}
  {{- else -}}
    {{ .Values.volumeAzStorage.mountPath }}
  {{- end -}}
{{- end }}

{{/*
Expand the name of the chart.
*/}}
{{- define "az-func-sb.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "az-func-sb.fullname" -}}
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
Create chart name and version as used by the chart label.
*/}}
{{- define "az-func-sb.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Healthcheck services label
*/}}
{{- define "az-func-sb.healthcheck-servicesLabel" -}}
{{ .Values.healthchecks.servicesLabel }}: "true"
{{- end }}

{{/*
Common labels
*/}}
{{- define "az-func-sb.labels" -}}
helm.sh/chart: {{ include "az-func-sb.chart" . }}
{{ include "az-func-sb.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "az-func-sb.selectorLabels" -}}
app.kubernetes.io/name: {{ include "az-func-sb.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "az-func-sb.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "az-func-sb.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
