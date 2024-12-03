resource "kubernetes_manifest" "objectbucketclaim_loki" {
  manifest = {
    apiVersion = "objectbucket.io/v1alpha1"
    kind       = "ObjectBucketClaim"
    metadata = {
      name      = "loki"
      namespace = kubernetes_namespace.loki.metadata[0].name
    }
    spec = {
      bucketName       = "loki"
      storageClassName = "object-store"
    }
  }
  wait {
    fields = {
      "status.phase" = "Bound"
    }
  }
}
