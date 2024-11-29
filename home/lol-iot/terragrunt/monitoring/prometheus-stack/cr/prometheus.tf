resource "kubernetes_service_account" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = var.prometheus_stack_namespace
  }
}

resource "kubernetes_cluster_role" "prometheus" {
  metadata {
    name = "prometheus"
  }
  rule {
    api_groups = [""]
    resources  = ["nodes", "nodes/metrics", "services", "endpoints", "pods"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = [""]
    resources  = ["configmaps"]
    verbs      = ["get"]
  }
  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    non_resource_urls = ["/metrics"]
    verbs             = ["get"]
  }
}

resource "kubernetes_cluster_role_binding" "prometheus" {
  metadata {
    name = "prometheus"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.prometheus.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.prometheus.metadata[0].name
    namespace = kubernetes_service_account.prometheus.metadata[0].namespace
  }
}

resource "kubernetes_manifest" "prometheus_prometheus" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "Prometheus"
    metadata = {
      name      = "prometheus"
      namespace = var.prometheus_stack_namespace
    }
    spec = {
      serviceAccountName = kubernetes_service_account.prometheus.metadata[0].name
      initContainers = [
        {
          name    = "prometheus-permission"
          image   = "busybox"
          command = ["/bin/chmod", "-R", "777", "/prometheus"]
          volumeMounts = [
            {
              name      = "prometheus-prometheus-db"
              mountPath = "/prometheus"
            }
          ]
        }
      ]
      storage = {
        volumeClaimTemplate = {
          spec = {
            accessModes = ["ReadWriteOnce"]
            resources = {
              requests = {
                storage = "10Gi"
              }
            }
            storageClassName = "ceph-filesystem"
          }
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
      serviceMonitorNamespaceSelector = {}
      serviceMonitorSelector = {
        matchLabels = {
          "loliot.net/prometheus" = "prometheus"
        }
      }
    }
  }
  wait {
    condition {
      type   = "Available"
      status = "True"
    }
  }
}
