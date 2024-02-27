import pulumi_kubernetes as k8s

from lol_iot_iac.monitoring import variable

k8s.helm.v3.Release(
    "metrics-server",
    name="metrics-server",
    chart=str(variable.chart_dir / "metrics-server-3.12.0.tgz"),
    namespace="kube-system",
    max_history=5,
    values={
        "args": [
            "--kubelet-insecure-tls",
        ]
    },
)