resource "kubernetes_namespace" "postgres" {
  metadata {
    name = "postgres"
  }
}

resource "helm_release" "postgres" {
  repository  = "https://hhk7734.github.io/helm-charts/"
  chart       = "postgresql"
  version     = "16.2.3"
  max_history = 3
  name        = "postgres"
  namespace   = kubernetes_namespace.postgres.metadata[0].name
  timeout     = 300
  values = [jsonencode({
    fullnameOverride = "postgres"
    global = {
      storageClass = "ceph-filesystem"
    }
    auth = {
      postgresPassword = "postgres"
    }
    primary = {
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
      persistence = {
        size = "5Gi"
      }
    }
  })]
}
