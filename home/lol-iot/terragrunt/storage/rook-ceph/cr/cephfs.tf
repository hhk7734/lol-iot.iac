resource "kubernetes_manifest" "cephfilesystem_ceph_filesystem" {
  manifest = {
    apiVersion = "ceph.rook.io/v1"
    kind       = "CephFilesystem"
    metadata = {
      name      = "ceph-filesystem"
      namespace = var.rook_ceph_namespace
    }
    spec = {
      metadataPool = {
        replicated = { size = 2 }
      }
      dataPools = [{
        name       = "data0"
        replicated = { size = 2 }
      }]
      metadataServer = {
        activeCount   = 1
        activeStandby = true
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

  field_manager {
    force_conflicts = true
  }
}

resource "kubernetes_manifest" "cephfilesystemsubvolumegroup_ceph_filesystem" {
  manifest = {
    apiVersion = "ceph.rook.io/v1"
    kind       = "CephFilesystemSubVolumeGroup"
    metadata = {
      name      = "ceph-filesystem"
      namespace = var.rook_ceph_namespace
    }
    spec = {
      name           = "csi"
      filesystemName = kubernetes_manifest.cephfilesystem_ceph_filesystem.manifest.metadata.name
      pinning        = { distributed = 1 }
    }
  }
}

resource "kubernetes_storage_class_v1" "ceph_filesystem" {
  metadata {
    name = "ceph-filesystem"
  }
  storage_provisioner    = "${var.rook_ceph_namespace}.cephfs.csi.ceph.com"
  volume_binding_mode    = "Immediate"
  reclaim_policy         = "Delete"
  allow_volume_expansion = true
  parameters = {
    clusterID                   = var.rook_ceph_namespace
    fsName                      = kubernetes_manifest.cephfilesystem_ceph_filesystem.manifest.metadata.name
    pool                        = "${kubernetes_manifest.cephfilesystem_ceph_filesystem.manifest.metadata.name}-${kubernetes_manifest.cephfilesystem_ceph_filesystem.manifest.spec.dataPools[0].name}"
    "csi.storage.k8s.io/fstype" = "ext4"
    "csi.storage.k8s.io/provisioner-secret-name" : "rook-csi-cephfs-provisioner"
    "csi.storage.k8s.io/provisioner-secret-namespace" : var.rook_ceph_namespace
    "csi.storage.k8s.io/controller-expand-secret-name" : "rook-csi-cephfs-provisioner"
    "csi.storage.k8s.io/controller-expand-secret-namespace" : var.rook_ceph_namespace
    "csi.storage.k8s.io/controller-publish-secret-name" : "rook-csi-cephfs-provisioner"
    "csi.storage.k8s.io/controller-publish-secret-namespace" : var.rook_ceph_namespace
    "csi.storage.k8s.io/node-stage-secret-name" : "rook-csi-cephfs-node"
    "csi.storage.k8s.io/node-stage-secret-namespace" : var.rook_ceph_namespace
  }
}
