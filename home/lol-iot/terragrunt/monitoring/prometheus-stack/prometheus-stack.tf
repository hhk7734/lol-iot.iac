resource "kubernetes_namespace" "prometheus_stack" {
  metadata {
    name = "prometheus-stack"
  }
}

resource "helm_release" "prometheus_stack" {
  repository  = "https://hhk7734.github.io/helm-charts/"
  chart       = "kube-prometheus-stack"
  version     = "66.3.0"
  max_history = 5
  name        = "prometheus-stack"
  namespace   = kubernetes_namespace.prometheus_stack.metadata[0].name
  timeout     = 300
  values = [jsonencode({
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
      admissionWebhooks = {
        patch = {
          tolerations = [
            {
              key      = "node-role.kubernetes.io/control-plane"
              operator = "Exists"
            },
            {
              key      = "loliot.net/storage"
              operator = "Equal"
              value    = "enabled"
              effect   = "NoSchedule"
            }
          ]
        }
      }
      tolerations = [
        {
          key      = "node-role.kubernetes.io/control-plane"
          operator = "Exists"
        },
        {
          key      = "loliot.net/storage"
          operator = "Equal"
          value    = "enabled"
          effect   = "NoSchedule"
        }
      ]
    }
    prometheus  = { enabled = false }
    thanosRuler = { enabled = false }
  })]
}
