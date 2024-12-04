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
          name     = "kube-apiserver"
          protocol = "TLS"
          hostname = "lol-iot.loliot.net"
          port     = 443
          tls = {
            mode = "Passthrough"
          }
          allowedRoutes = {
            namespaces = {
              from = "All"
            }
          }
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "tlsroute_kube_apiserver" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1alpha2"
    kind       = "TLSRoute"
    metadata = {
      name      = "kube-apiserver"
      namespace = "default"
    }
    spec = {
      parentRefs = [{
        name        = kubernetes_manifest.gateway.manifest.metadata.name
        namespace   = kubernetes_manifest.gateway.manifest.metadata.namespace
        sectionName = "kube-apiserver"
      }]
      hostnames : ["lol-iot.loliot.net"]
      rules = [{
        backendRefs = [{
          name = "kubernetes"
          port = 443
        }]
      }]
    }
  }
}
