resource "kubernetes_manifest" "cilium-l2-announcement-policy" {
  manifest = {
    apiVersion = "cilium.io/v2alpha1"
    kind       = "CiliumL2AnnouncementPolicy"
    metadata = {
      name = "cilium-l2-announcement-policy"
    }
    spec = {
      externalIPs     = true
      loadBalancerIPs = true
    }
  }
}

resource "kubernetes_manifest" "cilium-loadbalancer-ip-pool" {
  manifest = {
    apiVersion = "cilium.io/v2alpha1"
    kind       = "CiliumLoadBalancerIPPool"
    metadata = {
      name = "cilium-loadbalancer-ip-pool"
    }
    spec = {
      cidrs = [
        {
          cidr = "192.168.0.208/28" # 192.168.0.208 ~ 192.168.0.223
        },
        {
          cidr = "192.168.0.224/28" # 192.168.0.224 ~ 192.168.0.239
        }
      ]
    }
  }
}
