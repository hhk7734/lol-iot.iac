resource "kubernetes_service_account" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = kubernetes_namespace.rook_ceph.metadata[0].name
  }
}

resource "kubernetes_cluster_role" "rook_ceph_prometheus" {
  metadata {
    name = "rook-ceph-prometheus"
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

resource "kubernetes_cluster_role_binding" "rook_ceph_prometheus" {
  metadata {
    name = "rook-ceph-prometheus"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.rook_ceph_prometheus.metadata[0].name
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
      namespace = kubernetes_namespace.rook_ceph.metadata[0].name
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
                    values   = ["ip-192-168-0-19"]
                  }
                ]
              }
            ]
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

resource "kubernetes_manifest" "servicemonitor_mgr" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "mgr"
      namespace = kubernetes_namespace.rook_ceph.metadata[0].name
      labels = {
        "loliot.net/prometheus" = "rook-ceph"
      }
    }
    spec = {
      namespaceSelector = {
        matchNames = [kubernetes_namespace.rook_ceph.metadata[0].name]
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
          interval = "15s"
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "servicemonitor_exporter" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "exporter"
      namespace = kubernetes_namespace.rook_ceph.metadata[0].name
      labels = {
        "loliot.net/prometheus" = "rook-ceph"
      }
    }
    spec = {
      namespaceSelector = {
        matchNames = [kubernetes_namespace.rook_ceph.metadata[0].name]
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
          interval = "15s"
        }
      ]
    }
  }
}
