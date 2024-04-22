resource "kubernetes_namespace" "argo-cd" {
  metadata {
    name = "argo-cd"
  }
}

resource "helm_release" "argo-cd" {
  repository  = "https://hhk7734.github.io/helm-charts/"
  chart       = "argo-cd"
  version     = "5.53.13"
  max_history = 5
  name        = "argo-cd"
  namespace   = kubernetes_namespace.argo-cd.metadata[0].name
  timeout     = 300
  values = [
    jsonencode({
      fullnameOverride : "argo-cd"
      configs = {
        cm = {
          "server.rbac.log.enforce.enable" = "true"
          "exec.enabled"                   = "true"
          # TODO: casdoor
          "admin.enabled" = "true"
        }
        rbac = {
          "policy.csv" : <<-EOT
            g, loliot/argo-cd-admin, role:admin
            EOT
        }
      }
      dex = {
        enabled = false
      }
      server = {
        extraArgs = [
          "--insecure"
        ]
      }
      applicationSet = {
        enabled = false
      }
      notifications = {
        enabled = false
      }
    })
  ]
  wait = true
}
