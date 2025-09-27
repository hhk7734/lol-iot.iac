resource "helm_release" "metrics_server" {
  repository  = "https://kubernetes-sigs.github.io/metrics-server/"
  chart       = "metrics-server"
  version     = "3.12.2"
  max_history = 5
  name        = "metrics-server"
  namespace   = "kube-system"
  timeout     = 300
  values = [jsonencode(
    {
      args = [
        "--kubelet-insecure-tls"
      ]
      tolerations = [{ operator = "Exists" }]
    }
  )]
  wait = true
}
