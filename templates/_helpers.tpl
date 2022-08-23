{{/*
Expand the name of the chart.
*/}}
{{- define "kafka.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "kafka.fullname" -}}
{{- $name := .Chart.Name }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "kafka.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "kafka.labels" -}}
helm.sh/chart: {{ include "kafka.chart" . }}
{{ include "kafka.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "kafka.selectorLabels" -}}
app.kubernetes.io/name: {{ include "kafka.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Kafka advertised hostname, which is the service address
*/}}
{{- define "kafka.advertisedHostName" -}}
{{- printf "_{HOSTNAME_COMMAND}.%s.%s" (include "kafka.fullname" .) .Release.Namespace }}
{{- end }}

{{/*
Advertised listener addresses, each consisting of a listener ID, hostname and port. If an external hostname is provided,
a second advertised listener is created.
*/}}
{{- define "kafka.advertisedListeners" -}}
{{- if .Values.externalListener.enabled }}
{{- printf "INTERNAL://%s:%d,EXTERNAL://%s:%d" (include "kafka.advertisedHostName" .) (.Values.port | int) (include "kafka.advertisedHostName" .) (.Values.externalListener.nodePort | int) }}
{{- else }}
{{- printf "INTERNAL://%s:%d" (include "kafka.advertisedHostName" .) (.Values.port | int) }}
{{- end }}
{{- end }}

{{/*
Listener addresses, each consisting of a listener ID, hostname and port. If an external hostname is provided,
a second advertised listener is created.
*/}}
{{- define "kafka.listeners" -}}
{{- if .Values.externalListener.enabled }}
{{- printf "INTERNAL://:%d,EXTERNAL://:%d" (.Values.port | int) (.Values.externalListener.containerPort | int) }}
{{- else }}
{{- printf "INTERNAL://:%d" (.Values.port | int) }}
{{- end }}
{{- end }}

{{/*
Maps listener IDs to protocols
*/}}
{{- define "kafka.listenerSecurityProtocolMap" -}}
{{- if .Values.externalListener.enabled -}}
INTERNAL:SSL,EXTERNAL:SSL
{{- else -}}
INTERNAL:SSL
{{- end }}
{{- end }}

{{/*
List of topics to create on initialisation
*/}}
{{- define "kafka.createTopics" -}}
{{- range .Values.createTopics }}
{{- printf "%s:%d:%d," .name (.partitions | int) (.replicas | int) }}
{{- end }}
{{- end }}