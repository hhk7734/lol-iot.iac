resource "kubernetes_service_account" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = kubernetes_namespace.rook-ceph.metadata[0].name
  }
}

resource "kubernetes_cluster_role_binding" "prometheus" {
  metadata {
    name = "rook-ceph-prometheus"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "prometheus"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.prometheus.metadata[0].name
    namespace = kubernetes_service_account.prometheus.metadata[0].namespace
  }
}

resource "kubernetes_manifest" "prometheus" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "Prometheus"
    metadata = {
      name      = "prometheus"
      namespace = kubernetes_namespace.rook-ceph.metadata[0].name
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
                storage = "1Gi"
              }
            }
            storageClassName = "local-path"
          }
        }
      }
      affinity = {
        nodeAffinity = {
          requiredDuringSchedulingIgnoredDuringExecution = {
            nodeSelectorTerms = [
              {
                matchExpressions = [
                  {
                    key      = "kubernetes.io/hostname"
                    operator = "In"
                    values   = ["ip-192-168-0-18"]
                  }
                ]
              }
            ]
          }
        }
      }
      tolerations = [
        {
          key      = "loliot.net/storage"
          operator = "Exists"
        }
      ]
      serviceMonitorSelector = {
        matchLabels = {
          "loliot.net/prometheus" = "rook-ceph"
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

resource "kubernetes_manifest" "rook-ceph-mgr" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "rook-ceph-mgr"
      namespace = kubernetes_namespace.rook-ceph.metadata[0].name
      labels = {
        "loliot.net/prometheus" = "rook-ceph"
      }
    }
    spec = {
      namespaceSelector = {
        matchNames = [kubernetes_namespace.rook-ceph.metadata[0].name]
      }
      selector = {
        matchLabels = {
          "app"          = "rook-ceph-mgr"
          "rook_cluster" = "rook-ceph"
        }
      }
      endpoints = [
        {
          port     = "http-metrics"
          path     = "/metrics"
          interval = "10s"
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "rook-ceph-exporter" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "rook-ceph-exporter"
      namespace = kubernetes_namespace.rook-ceph.metadata[0].name
      labels = {
        "loliot.net/prometheus" = "rook-ceph"
      }
    }
    spec = {
      namespaceSelector = {
        matchNames = [kubernetes_namespace.rook-ceph.metadata[0].name]
      }
      selector = {
        matchLabels = {
          "app"          = "rook-ceph-exporter"
          "rook_cluster" = "rook-ceph"
        }
      }
      endpoints = [
        {
          port     = "ceph-exporter-http-metrics"
          path     = "/metrics"
          interval = "10s"
        }
      ]
    }
  }
}
