resource "helm_release" "prometheus-stack" {
  chart       = "${local.charts_dir}/kube-prometheus-stack-57.0.1.tgz"
  max_history = 5
  name        = "prometheus-stack"
  namespace   = "monitoring"
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
      kubernetesServiceMonitors = { enabled = false }
      kubeApiServer             = { enabled = false }
      kubelet                   = { enabled = false }
      kubeControllerManager     = { enabled = false }
      coreDns                   = { enabled = false }
      kubeDns                   = { enabled = false }
      kubeEtcd                  = { enabled = false }
      kubeScheduler             = { enabled = false }
      kubeProxy                 = { enabled = false }
      kubeStateMetrics          = { enabled = false }
      nodeExporter              = { enabled = false }
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
