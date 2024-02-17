resource "kubernetes_namespace" "storage" {
  metadata {
    name = "storage"
  }
}

resource "helm_release" "local-path-provisioner" {
  chart       = "${local.charts_dir}/local-path-provisioner-0.0.25.tgz"
  max_history = 3
  name        = "local-path-provisioner"
  namespace   = kubernetes_namespace.storage.metadata[0].name
  timeout     = 300
  values = [jsonencode(
    {
      storageClass = {
        defaultClass = true
      }
      affinity    = { nodeAffinity = local.control_plane_node_affinity }
      tolerations = [local.master_toleration]
    }
  )]
  wait = true
}

resource "helm_release" "postgresql" {
  chart       = "${local.charts_dir}/postgresql-13.4.2.tgz"
  max_history = 3
  name        = "postgresql"
  namespace   = kubernetes_namespace.storage.metadata[0].name
  timeout     = 300
  values = [jsonencode(
    {
      commonLabels = {}
      global = {
        storageClass = "local-path"
      }
      primary = {
        persistence = {
          size = "5Gi"
        }
        resources = {
          requests = {
            cpu    = "10m"
            memory = "256Mi"
          }
        }
        affinity    = { nodeAffinity = local.control_plane_node_affinity }
        tolerations = [local.master_toleration]
      }
    }
  )]
  wait       = true
  depends_on = [helm_release.local-path-provisioner]
}

resource "kubernetes_namespace" "rook-ceph" {
  metadata {
    name = "rook-ceph"
  }
}

resource "helm_release" "rook-ceph" {
  chart       = "${local.charts_dir}/rook-ceph-v1.13.4.tgz"
  max_history = 3
  name        = "rook-ceph"
  namespace   = kubernetes_namespace.rook-ceph.metadata[0].name
  timeout     = 300
  values = [
    jsonencode({})
  ]
  wait = true
}
