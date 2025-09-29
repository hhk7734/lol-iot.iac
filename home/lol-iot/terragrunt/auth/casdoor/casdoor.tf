resource "kubernetes_namespace" "casdoor" {
  metadata {
    name = "casdoor"
  }
}

resource "helm_release" "casdoor" {
  chart       = "oci://registry-1.docker.io/casbin/casdoor-helm-charts"
  version     = "v2.70.0"
  max_history = 3
  name        = "casdoor"
  namespace   = kubernetes_namespace.casdoor.metadata[0].name
  timeout     = 300
  values = [jsonencode({
    fullnameOverride = "casdoor"
    database = {
      driver   = "postgres"
      user     = "casdoor"
      password = "casdoor"
      host     = "postgres-0.postgres-hl.postgres.svc.cluster.local"
    }
  })]
}

resource "kubernetes_manifest" "httproute_casdoor" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"
    metadata = {
      name      = "casdoor"
      namespace = kubernetes_namespace.casdoor.metadata[0].name
    }
    spec = {
      parentRefs = [{
        name      = "gateway"
        namespace = "kube-system"
      }]
      hostnames = ["casdoor.lol-iot.loliot.net"]
      rules = [{
        matches = [{
          path = {
            type  = "PathPrefix"
            value = "/"
          }
        }]
        backendRefs = [{
          name = "casdoor"
          port = 8000
        }]
      }]
    }
  }
}
