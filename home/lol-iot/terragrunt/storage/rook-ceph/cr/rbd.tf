resource "kubernetes_manifest" "cephblockpool_ceph_block" {
  manifest = {
    apiVersion = "ceph.rook.io/v1"
    kind       = "CephBlockPool"
    metadata = {
      name      = "ceph-block"
      namespace = var.rook_ceph_namespace
    }
    spec = {
      failureDomain = "host"
      replicated = {
        size = 2
      }
    }
  }
}

resource "kubernetes_storage_class_v1" "ceph_block" {
  metadata {
    name = "ceph-block"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }
  storage_provisioner    = "${var.rook_ceph_namespace}.rbd.csi.ceph.com"
  volume_binding_mode    = "Immediate"
  reclaim_policy         = "Delete"
  allow_volume_expansion = true
  parameters = {
    clusterID                                               = var.rook_ceph_namespace
    pool                                                    = kubernetes_manifest.cephblockpool_ceph_block.manifest.metadata.name
    imageFormat                                             = "2"
    imageFeatures                                           = "layering"
    "csi.storage.k8s.io/provisioner-secret-name"            = "rook-csi-rbd-provisioner"
    "csi.storage.k8s.io/provisioner-secret-namespace"       = var.rook_ceph_namespace
    "csi.storage.k8s.io/controller-expand-secret-name"      = "rook-csi-rbd-provisioner"
    "csi.storage.k8s.io/controller-expand-secret-namespace" = var.rook_ceph_namespace
    "csi.storage.k8s.io/node-stage-secret-name"             = "rook-csi-rbd-node"
    "csi.storage.k8s.io/node-stage-secret-namespace"        = var.rook_ceph_namespace
    "csi.storage.k8s.io/fstype"                             = "ext4"
  }
}
