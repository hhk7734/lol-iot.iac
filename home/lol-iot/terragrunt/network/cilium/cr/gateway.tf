resource "kubernetes_manifest" "gateway" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "Gateway"
    metadata = {
      name      = "gateway"
      namespace = "kube-system"
    }
    spec = {
      gatewayClassName = "cilium"
      listeners = [
        {
          name     = "http"
          protocol = "HTTP"
          port     = 80
          allowedRoutes = {
            namespaces = {
              from = "All"
            }
          }
        },
        {
          name     = "https"
          protocol = "HTTPS"
          hostname = "*.lol-iot.loliot.net"
          port     = 443
          tls = {
            mode = "Terminate"
            certificateRefs = [{
              name = kubernetes_manifest.certificate_lol_iot.manifest.spec.secretName
            }]
          },
          allowedRoutes = {
            namespaces = {
              from = "All"
            }
          }
        },
      ]
    }
  }
}
