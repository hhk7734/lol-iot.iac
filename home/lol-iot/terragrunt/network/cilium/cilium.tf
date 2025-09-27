resource "helm_release" "cilium" {
  repository  = "https://helm.cilium.io/"
  chart       = "cilium"
  version     = "1.18.2"
  max_history = 5
  name        = "cilium"
  namespace   = "kube-system"
  timeout     = 300
  values = [jsonencode(
    {
      k8sServiceHost       = "localhost"
      k8sServicePort       = "6443"
      kubeProxyReplacement = "true"
      l2announcements = {
        enabled = true
      }
      gatewayAPI = {
        enabled = true
      }
      l7Proxy = true
      ipam = {
        mode = "cluster-pool"
        operator = {
          clusterPoolIPv4PodCIDRList = ["10.233.64.0/18"]
          clusterPoolIPv4MaskSize    = 25
        }
      }
      operator = {
        replicas = 1
      }
    }
  )]
  depends_on = [helm_release.gateway_api]
}
