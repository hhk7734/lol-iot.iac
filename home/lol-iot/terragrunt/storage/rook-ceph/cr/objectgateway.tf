resource "kubernetes_manifest" "cephobjectstore_object_store" {
  manifest = {
    apiVersion = "ceph.rook.io/v1"
    kind       = "CephObjectStore"
    metadata = {
      name      = "object-store"
      namespace = var.rook_ceph_namespace
    }
    spec = {
      metadataPool = {
        replicated = {
          size = 2
        }
      }
      dataPool = {
        replicated = {
          size = 2
        }
      }
      gateway = {
        port      = 80
        instances = 1
        placement = {
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
        }
      }
    }
  }
}
resource "kubernetes_storage_class_v1" "object_store" {
  metadata {
    name = "object-store"
  }
  storage_provisioner = "${var.rook_ceph_namespace}.ceph.rook.io/bucket"
  volume_binding_mode = "Immediate"
  reclaim_policy      = "Delete"
  parameters = {
    objectStoreName      = kubernetes_manifest.cephobjectstore_object_store.manifest.metadata.name
    objectStoreNamespace = kubernetes_manifest.cephobjectstore_object_store.manifest.metadata.namespace
  }
}
