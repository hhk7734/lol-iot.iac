resource "kubernetes_manifest" "ciliuml2announcementpolicy" {
  manifest = {
    apiVersion = "cilium.io/v2alpha1"
    kind       = "CiliumL2AnnouncementPolicy"
    metadata = {
      name = "cilium-l2-announcement-policy"
    }
    spec = {
      loadBalancerIPs = true
    }
  }
}

resource "kubernetes_manifest" "ciliumloadbalancerippool" {
  manifest = {
    apiVersion = "cilium.io/v2alpha1"
    kind       = "CiliumLoadBalancerIPPool"
    metadata = {
      name = "cilium-loadbalancer-ip-pool"
    }
    spec = {
      cidrs = [
        {
          cidr = "192.168.0.2/32"
        }
      ]
    }
  }
}
