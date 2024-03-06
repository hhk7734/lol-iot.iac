resource "kubernetes_manifest" "cilium-loadbalancer-ip-pool" {
  manifest = {
    apiVersion = "cilium.io/v2alpha1"
    kind       = "CiliumLoadBalancerIPPool"
    metadata = {
      name = "cilium-loadbalancer-ip-pool"
    }
    spec = {
      cidrs = [{
        cidr = "192.168.0.0/24"
      }]
    }
  }
}
