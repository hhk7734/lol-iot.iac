resource "helm_release" "cilium" {
  repository  = "https://hhk7734.github.io/helm-charts/"
  chart       = "cilium"
  version     = "1.14.6"
  max_history = 5
  name        = "cilium"
  namespace   = "kube-system"
  timeout     = 300
  values = [jsonencode(
    {
      k8sServiceHost = "localhost"
      k8sServicePort = "6443"
      cluster = {
        name = "home-lol-iot"
      }
      l2announcements = {
        enabled = true
      }
      gatewayAPI = {
        enabled = true
      }
      ipam = {
        mode = "cluster-pool"
        operator = {
          clusterPoolIPv4MaskSize = 25
          clusterPoolIPv4PodCIDRList = [
            "10.233.64.0/18",
          ]
        }
      },
      kubeProxyReplacement = "true"
      nodePort = {
        enabled = true
      }
      operator = {
        replicas = 1
      }
    }
  )]
}
