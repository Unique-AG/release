{{- define "common.fullname" -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "common.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* 🚨 ‼️ Changing the immutableLabels will lead to downtime when deploying as selector labels can only be updated manually or with downtime ‼️ 🚨 */}}
{{/* These labels never change and are also used as matchLabels for selectors */}}
{{- define "common.immutableLabels" -}}
app.kubernetes.io/name: {{ include "common.fullname" . }}
app.kubernetes.io/managed-by: helm
{{- end }}


{{/* These labels are shared between all components (or shared resources) and have no component awareness */}}
{{- define "common.mutableLabels" -}}
{{- include "common.immutableLabels" . }}
helm.sh/chart: {{ include "common.chart" . }}
{{- end }}

{{/* These labels identify all resources that belong to our main deployment, called "server" */}}
{{- define "common.labels" -}}
{{- include "common.mutableLabels" . }}
{{- end }}
