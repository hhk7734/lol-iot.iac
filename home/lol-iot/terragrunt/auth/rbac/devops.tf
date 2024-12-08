resource "kubernetes_cluster_role_binding" "devops" {
  metadata {
    name = "devops"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Group"
    name      = "lol-iot/devops"
  }
}
