resource "kubernetes_namespace" "storage" {
  metadata {
    name = "storage"
  }
}

resource "helm_release" "local-path-provisioner" {
  chart       = "${local.charts_dir}/local-path-provisioner-0.0.25.tgz"
  max_history = 3
  name        = "local-path-provisioner"
  namespace   = kubernetes_namespace.storage.metadata[0].name
  timeout     = 300
  values = [jsonencode(
    {
      storageClass = {
        defaultClass = true
      }
      affinity    = { nodeAffinity = local.control_plane_node_affinity }
      tolerations = [local.master_toleration]
    }
  )]
  wait = true
}

resource "helm_release" "postgresql" {
  chart       = "${local.charts_dir}/postgresql-13.4.2.tgz"
  max_history = 3
  name        = "postgresql"
  namespace   = kubernetes_namespace.storage.metadata[0].name
  timeout     = 300
  values = [jsonencode(
    {
      commonLabels = {}
      global = {
        storageClass = "local-path"
      }
      primary = {
        persistence = {
          size = "5Gi"
        }
        resources = {
          requests = {
            cpu    = "10m"
            memory = "256Mi"
          }
        }
        affinity    = { nodeAffinity = local.control_plane_node_affinity }
        tolerations = [local.master_toleration]
      }
    }
  )]
  wait       = true
  depends_on = [helm_release.local-path-provisioner]
}

resource "kubernetes_namespace" "rook-ceph" {
  metadata {
    name = "rook-ceph"
  }
}

resource "helm_release" "rook-ceph" {
  chart       = "${local.charts_dir}/rook-ceph-v1.13.4.tgz"
  max_history = 3
  name        = "rook-ceph"
  namespace   = kubernetes_namespace.rook-ceph.metadata[0].name
  timeout     = 300
  values = [
    jsonencode({
      csi = {
        enableRbdDriver              = false
        csiCephFSProvisionerResource = <<-EOT
            - name : csi-provisioner
              resource: null
            - name : csi-resizer
              resource: null
            - name : csi-attacher
              resource: null
            - name : csi-snapshotter
              resource: null
            - name : csi-cephfsplugin
              resource: null
            - name : liveness-prometheus
              resource: null
          EOT
        csiCephFSPluginResource      = <<-EOT
            - name : driver-registrar
              resource: null
            - name : csi-cephfsplugin
              resource: null
            - name : liveness-prometheus
              resource: null
          EOT
        kubeletDirPath               = "/var/lib/k0s/kubelet"
      }
    })
  ]
  wait = true
}

resource "helm_release" "rook-ceph-cluster" {
  chart       = "${local.charts_dir}/rook-ceph-cluster-v1.13.4.tgz"
  max_history = 3
  name        = "rook-ceph-cluster"
  namespace   = kubernetes_namespace.rook-ceph.metadata[0].name
  timeout     = 300
  values = [jsonencode(
    {
      operatorNamespace = kubernetes_namespace.rook-ceph.metadata[0].name
      cephClusterSpec = {
        mon = {
          count = 1
        }
        mgr = {
          count = 1
        }
        dashboard = {
          enabled = true
          ssl     = false
        }
        logCollector = {
          enabled = false
        }
        resources = {
          mgr = {
            requests = null
            limits   = null
          },
          mon = {
            requests = null
            limits   = null
          },
          osd = {
            requests = null
            limits   = null
          }
        }
        storage = {
          useAllNodes   = false
          useAllDevices = false
          nodes = [
            {
              name = "ip-10-255-240-4"
              devices = [
                {
                  name = "/dev/vg1/lv1"
                }
              ]
            }
          ]
        }
      }
      cephBlockPools = []
      cephFileSystems = [
        {
          name = "ceph-filesystem"
          spec = {
            metadataPool = {
              replicated = {
                size = 1
              }
            }
            dataPools = [
              {
                failureDomain = "host"
                replicated = {
                  size = 1
                }
                name = "data0"
              }
            ]
            metadataServer = {
              activeCount   = 1
              activeStandby = true
              resources = {
                requests = null
                limits   = null
              }
            }
          }
          storageClass = {
            enabled              = true
            isDefault            = false
            name                 = "ceph-filesystem"
            pool                 = "data0"
            reclaimPolicy        = "Delete"
            allowVolumeExpansion = true
            volumeBindingMode    = "Immediate"
            mountOptions         = []
            parameters = {
              "csi.storage.k8s.io/provisioner-secret-name"            = "rook-csi-cephfs-provisioner"
              "csi.storage.k8s.io/provisioner-secret-namespace"       = "{{ .Release.Namespace }}"
              "csi.storage.k8s.io/controller-expand-secret-name"      = "rook-csi-cephfs-provisioner"
              "csi.storage.k8s.io/controller-expand-secret-namespace" = "{{ .Release.Namespace }}"
              "csi.storage.k8s.io/node-stage-secret-name"             = "rook-csi-cephfs-node"
              "csi.storage.k8s.io/node-stage-secret-namespace"        = "{{ .Release.Namespace }}"
              "csi.storage.k8s.io/fstype"                             = "ext4"
            }
          }
        }
      ]
      cephObjectStores = []
    }
  )]
  wait       = true
  depends_on = [helm_release.rook-ceph]
}
