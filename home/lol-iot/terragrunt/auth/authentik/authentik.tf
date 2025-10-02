resource "kubernetes_namespace_v1" "authentik" {
  metadata {
    name = "authentik"
  }
}

resource "random_password" "authentik_secret_key" {
  length  = 50
  special = false
}

resource "helm_release" "authentik" {
  repository  = "https://charts.goauthentik.io"
  chart       = "authentik"
  version     = "2025.8.4"
  max_history = 3
  name        = "authentik"
  namespace   = kubernetes_namespace_v1.authentik.metadata[0].name
  timeout     = 300
  values = [jsonencode({
    fullnameOverride = "authentik"
    authentik = {
      secret_key = random_password.authentik_secret_key.result
      postgresql = {
        password = "authentik"
        host     = "postgres-0.postgres-hl.postgres.svc.cluster.local"
      }
      redis = {
        host = "redis-0.redis-hl.authentik.svc.cluster.local"
      }
    }
    server = {
      route = {
        main = {
          enabled = true
          parentRefs = [{
            name      = "gateway"
            namespace = "kube-system"
          }]
          hostnames = ["auth.lol-iot.loliot.net"]
        }
      }
    }
  })]
  depends_on = [kubernetes_stateful_set_v1.redis]
}
