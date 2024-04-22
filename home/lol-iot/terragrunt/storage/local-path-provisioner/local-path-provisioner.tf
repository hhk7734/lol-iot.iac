resource "kubernetes_namespace" "local-path-provisioner" {
  metadata {
    name = "local-path-provisioner"
  }
}

resource "helm_release" "local-path-provisioner" {
  repository  = "https://hhk7734.github.io/helm-charts/"
  chart       = "local-path-provisioner"
  version     = "0.0.26"
  max_history = 5
  name        = "local-path-provisioner"
  namespace   = kubernetes_namespace.local-path-provisioner.metadata[0].name
  timeout     = 300
  values      = []
  wait        = true
}
