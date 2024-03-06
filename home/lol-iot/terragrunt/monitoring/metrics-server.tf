resource "helm_release" "metrics-server" {
  chart       = "${local.charts_dir}/metrics-server-3.12.0.tgz"
  max_history = 5
  name        = "metrics-server"
  namespace   = "kube-system"
  timeout     = 300
  values = [jsonencode(
    {
      args = [
        "--kubelet-insecure-tls"
      ]
      tolerations = [
        {
          key      = "node-role.kubernetes.io/control-plane"
          operator = "Exists"
        }
      ]
    }
  )]
  wait = true
}
