resource "helm_release" "cilium" {
  chart       = "${local.charts_dir}/cilium-1.14.6.tgz"
  max_history = 3
  name        = "cilium"
  namespace   = "kube-system"
  timeout     = 300
  values = [jsonencode(
    {
      k8sServiceHost = "10.255.240.2"
      k8sServicePort = "6443"
      cluster = {
        name = "ap-northeast-2-loliot-net"
      }
      ipam = {
        mode = "cluster-pool"
        operator = {
          clusterPoolIPv4MaskSize = 25
          clusterPoolIPv4PodCIDRList = [
            "10.244.0.0/16",
          ]
        }
      },
      kubeProxyReplacement = "true"
      operator = {
        replicas = 1
      }
    }
  )]
  wait = true
}

resource "kubernetes_manifest" "cilium-loadbalancer-ip-pool" {
  manifest = {
    apiVersion = "cilium.io/v2alpha1"
    kind       = "CiliumLoadBalancerIPPool"
    metadata = {
      name = "cilium-loadbalancer-ip-pool"
    }
    spec = {
      cidrs = [{
        cidr = "172.26.0.0/20"
      }]
    }
  }
  depends_on = [helm_release.cilium]
}
