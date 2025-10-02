resource "helm_release" "gateway_api" {
  repository  = "https://lol-iot.github.io/helm-charts/"
  chart       = "gateway-api"
  version     = "1.3.0"
  max_history = 5
  name        = "gateway-api"
  namespace   = "kube-system"
  timeout     = 300
  set = [
    {
      name  = "experimental"
      value = true
    }
  ]
}
