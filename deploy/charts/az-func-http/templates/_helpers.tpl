{{/*
Ensure path volume is right "/" prefix format
*/}}
{{- define "az-func-http.ensure-path" -}}
  {{- if not (hasPrefix "/" .Values.volumeAzStorage.mountPath) -}}
    {{ printf "%s%s" "/" .Values.volumeAzStorage.mountPath }}
  {{- else -}}
    {{ .Values.volumeAzStorage.mountPath }}
  {{- end -}}
{{- end }}

{{/*
Expand the name of the chart.
*/}}
{{- define "az-func-http.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "az-func-http.fullname" -}}
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
{{- define "az-func-http.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Healthcheck services label
*/}}
{{- define "az-func-http.healthcheck-servicesLabel" -}}
{{ .Values.healthchecks.servicesLabel }}: "true"
{{- end }}

{{/*
Common labels
*/}}
{{- define "az-func-http.labels" -}}
helm.sh/chart: {{ include "az-func-http.chart" . }}
{{ include "az-func-http.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "az-func-http.selectorLabels" -}}
app.kubernetes.io/name: {{ include "az-func-http.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "az-func-http.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "az-func-http.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
