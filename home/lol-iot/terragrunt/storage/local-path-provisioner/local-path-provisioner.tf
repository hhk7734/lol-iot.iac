resource "helm_release" "local_path_provisioner" {
  repository  = "https://hhk7734.github.io/helm-charts/"
  chart       = "local-path-provisioner"
  version     = "0.0.30"
  max_history = 5
  name        = "local-path-provisioner"
  namespace   = "kube-system"
  timeout     = 300
  values = [jsonencode({
    tolerations = [
      {
        key      = "node-role.kubernetes.io/control-plane"
        operator = "Exists"
      },
      {
        key      = "loliot.net/storage"
        operator = "Equal"
        value    = "enabled"
        effect   = "NoSchedule"
      }
    ]
  })]
}
