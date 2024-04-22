resource "helm_release" "prometheus-stack" {
  repository  = "https://hhk7734.github.io/helm-charts/"
  chart       = "kube-prometheus-stack"
  version     = "57.0.1"
  max_history = 5
  name        = "prometheus-stack"
  namespace   = var.monitoring_namespace
  timeout     = 300
  values = [jsonencode(
    {
      fullnameOverride = "prometheus-stack"
      defaultRules = {
        create = false
      }
      windowsMonitoring         = { enabled = false }
      alertmanager              = { enabled = false }
      grafana                   = { enabled = false }
      kubernetesServiceMonitors = { enabled = true }
      kubeApiServer             = { enabled = false }
      kubelet = {
        enabled = true
        serviceMonitor = {
          additionalLabels = {
            "loliot.net/prometheus" = "monitoring"
          }
          cAdvisorMetricRelabelings = [
            {
              sourceLabels = ["__name__"]
              action       = "drop"
              regex        = "container_cpu_(cfs_throttled_seconds_total|load_average_10s|system_seconds_total|user_seconds_total)"
            },
            {
              sourceLabels = ["__name__"]
              action       = "drop"
              regex        = "container_fs_(io_current|io_time_seconds_total|io_time_weighted_seconds_total|reads_merged_total|sector_reads_total|sector_writes_total|writes_merged_total)"
            },
            {
              sourceLabels = ["__name__"]
              action       = "drop"
              regex        = "container_(file_descriptors|tasks_state|threads_max)"
            },
            {
              sourceLabels = ["__name__"]
              action       = "drop"
              regex        = "container_spec.*"
            },
            {
              sourceLabels = ["id", "pod"]
              action       = "drop"
              regex        = ".+;"
            }
          ]
        }
      }
      kubeControllerManager = { enabled = false }
      coreDns               = { enabled = false }
      kubeDns               = { enabled = false }
      kubeEtcd              = { enabled = false }
      kubeScheduler         = { enabled = false }
      kubeProxy             = { enabled = false }
      kubeStateMetrics      = { enabled = true }
      kube-state-metrics = {
        prometheus = {
          monitor = {
            enabled = true
            additionalLabels = {
              "loliot.net/prometheus" = "monitoring"
            }
          }
        }
        collectors = [
          "daemonsets",
          "deployments",
          "nodes",
          "pods",
          "statefulsets"
        ]
      }
      nodeExporter = { enabled = false }
      prometheusOperator = {
        enabled = true
        tls = {
          enabled = false
        }
        serviceMonitor = {
          selfMonitor = false
        }
      }
      prometheus  = { enabled = false }
      thanosRuler = { enabled = false }
    }
  )]
  wait = true
}
