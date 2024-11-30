resource "kubernetes_namespace" "auth" {
  metadata {
    name = "auth"
  }
}

resource "helm_release" "cert-manager" {
  repository  = "https://hhk7734.github.io/helm-charts/"
  chart       = "cert-manager"
  version     = "v1.13.3"
  max_history = 3
  name        = "cert-manager"
  namespace   = kubernetes_namespace.auth.metadata[0].name
  timeout     = 300
  values = [jsonencode(
    {
      global = {
        commonLabels = {}
      }
      installCRDs               = true
      enableCertificateOwnerRef = true
      resources = {
        requests = {
          cpu    = "10m"
          memory = "32Mi"
        }
      }
      affinity    = { nodeAffinity = local.control_plane_node_affinity }
      tolerations = [local.master_toleration]
      cainjector = {
        affinity    = { nodeAffinity = local.control_plane_node_affinity }
        tolerations = [local.master_toleration]
      }
      startupapicheck = {
        affinity    = { nodeAffinity = local.control_plane_node_affinity }
        tolerations = [local.master_toleration]
      }
      webhook = {
        affinity    = { nodeAffinity = local.control_plane_node_affinity }
        tolerations = [local.master_toleration]
      }
    }
  )]
  wait = true
}
