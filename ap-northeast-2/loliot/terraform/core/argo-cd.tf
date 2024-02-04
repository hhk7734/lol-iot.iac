resource "kubernetes_namespace" "argo-cd" {
  metadata {
    name = "argo-cd"
  }
}

resource "kubernetes_secret" "argo-cd-client-secret" {
  metadata {
    name      = "argo-cd-client-secret"
    namespace = kubernetes_namespace.argo-cd.metadata[0].name
    labels = {
      "app.kubernetes.io/part-of" = "argo-cd"
    }
  }
  data = {
    "oidc.casdoor.clientSecret" = file("${local.secret_dir}/argo-cd/oidc.casdoor.clientSecret")
  }
}

resource "helm_release" "argo-cd" {
  chart       = "${local.charts_dir}/argo-cd-5.53.13.tgz"
  max_history = 3
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
          "admin.enabled"                  = "false"

          url = "https://argo-cd.loliot.net"
          "oidc.config" = yamlencode({
            name         = "casdoor"
            issuer       = "https://auth.loliot.net"
            clientID     = "08751c9654e43e77f7b6"
            clientSecret = format("$%s:oidc.casdoor.clientSecret", kubernetes_secret.argo-cd-client-secret.metadata[0].name)
          })
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


resource "kubernetes_manifest" "virtualservice-argo-cd" {
  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "VirtualService"
    metadata = {
      name      = "argo-cd"
      namespace = kubernetes_namespace.argo-cd.metadata[0].name
    }
    spec = {
      hosts    = ["argo-cd.loliot.net"]
      gateways = ["loliot/gateway"]
      http = [{
        match = [{
          uri = {
            prefix = "/"
          }
        }]
        route = [{
          destination = {
            host = "argo-cd-server"
            port = {
              number = 80
            }
          }
        }]
      }]
    }
  }
}
