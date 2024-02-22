import pulumi
import pulumi_kubernetes as k8s
import yaml

from home_loliot.core import variable

cilium = k8s.helm.v3.Release(
    "cilium",
    name="cilium",
    chart=str(variable.chart_dir / "cilium-1.14.6.tgz"),
    namespace="kube-system",
    max_history=5,
    values=yaml.safe_load(
        """
        k8sServiceHost: "192.168.11.101"
        k8sServicePort: "6443"
        cluster:
          name: "home-loliot"
        ipam:
          mode: "cluster-pool"
          operator:
            clusterPoolIPv4MaskSize: 25
            clusterPoolIPv4PodCIDRList:
              - "10.233.64.0/18"
        operator:
          replicas: 1
        """
    )
)

k8s.apiextensions.CustomResource(
    "cilium-loadbalancer-ip-pool",
    api_version="cilium.io/v2alpha1",
    kind="CiliumLoadBalancerIPPool",
    metadata=k8s.meta.v1.ObjectMetaArgs(
        name="cilium-loadbalancer-ip-pool"
    ),
    spec=yaml.safe_load(
        """
        cidrs:
          - cidr: "192.168.11.0/24"
        """
    ),
    opts=pulumi.ResourceOptions(
        depends_on=[cilium]
    )
)