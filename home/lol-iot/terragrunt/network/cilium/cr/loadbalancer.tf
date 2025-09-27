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
      blocks = [
        {
          start = "172.31.254.210"
          end   = "172.31.254.250"
        }
      ]
    }
  }
}
