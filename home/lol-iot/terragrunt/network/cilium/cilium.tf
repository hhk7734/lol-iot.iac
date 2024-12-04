resource "helm_release" "cilium" {
  repository  = "https://hhk7734.github.io/helm-charts/"
  chart       = "cilium"
  version     = "1.16.4"
  max_history = 5
  name        = "cilium"
  namespace   = "kube-system"
  timeout     = 300
  values = [jsonencode(
    {
      k8sServiceHost = "localhost"
      k8sServicePort = "6443"
      l2announcements = {
        enabled = true
      }
      gatewayAPI = {
        enabled = true
      }
      kubeProxyReplacement = "true"
      operator = {
        replicas = 1
      }
    }
  )]
  depends_on = [helm_release.gateway_api]
}
