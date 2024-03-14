resource "kubernetes_namespace" "local-path-provisioner" {
  metadata {
    name = "local-path-provisioner"
  }
}

resource "helm_release" "local-path-provisioner" {
  chart       = "${local.charts_dir}/local-path-provisioner-0.0.26.tgz"
  max_history = 5
  name        = "local-path-provisioner"
  namespace   = kubernetes_namespace.local-path-provisioner.metadata[0].name
  timeout     = 300
  values = [jsonencode(
    {
      affinity = {
        nodeAffinity = {
          requiredDuringSchedulingIgnoredDuringExecution = {
            nodeSelectorTerms = [
              {
                matchExpressions = [
                  {
                    key      = "kubernetes.io/hostname"
                    operator = "In"
                    values   = ["ip-192-168-0-18"]
                  }
                ]
              }
            ]
          }

        }
      }
      tolerations = [{
        key      = "loliot.net/storage"
        operator = "Exists"
      }]
    }
  )]
  wait = true
}
