resource "helm_release" "gateway_api" {
  repository  = "https://hhk7734.github.io/helm-charts/"
  chart       = "gateway-api"
  version     = "1.1.0"
  max_history = 5
  name        = "gateway-api"
  namespace   = "kube-system"
  timeout     = 300
  set {
    name  = "experimental"
    value = true
  }
}
