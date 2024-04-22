resource "helm_release" "metrics-server" {
  repository  = "https://hhk7734.github.io/helm-charts/"
  chart       = "metrics-server"
  version     = "3.12.0"
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
