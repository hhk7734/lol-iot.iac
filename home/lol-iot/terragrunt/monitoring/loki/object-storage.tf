resource "kubernetes_manifest" "loki-bucket" {
  manifest = {
    apiVersion = "objectbucket.io/v1alpha1"
    kind       = "ObjectBucketClaim"
    metadata = {
      name      = "loki-bucket"
      namespace = var.monitoring_namespace
    }
    spec = {
      bucketName       = "loki"
      storageClassName = "ceph-bucket"
    }
  }
  wait {
    fields = {
      "status.phase" = "Bound"
    }
  }
}
