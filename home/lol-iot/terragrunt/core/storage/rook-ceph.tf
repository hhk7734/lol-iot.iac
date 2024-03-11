resource "kubernetes_namespace" "rook-ceph" {
  metadata {
    name = "rook-ceph"
  }
}

resource "helm_release" "rook-ceph" {
  chart       = "${local.charts_dir}/rook-ceph-v1.13.4.tgz"
  max_history = 5
  name        = "rook-ceph"
  namespace   = kubernetes_namespace.rook-ceph.metadata[0].name
  timeout     = 300
  values = [
    jsonencode({
      resources = {
        requests = {
          cpu    = "200m"
          memory = "128Mi"
        }
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }
      tolerations = [
        {
          key      = "node-role.kubernetes.io/control-plane"
          operator = "Exists"
        }
      ]
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
        provisionerTolerations = [
          {
            key      = "node-role.kubernetes.io/control-plane"
            operator = "Exists"
          },
          {
            key      = "loliot.net/storage"
            operator = "Exists"
          }
        ]
        kubeletDirPath = "/var/lib/kubelet"
      }
      enableDiscoveryDaemon = true
      discover = {
        tolerations = [
          {
            key      = "loliot.net/storage"
            operator = "Exists"
          }
        ]
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
          modules = [
            {
              name    = "rook"
              enabled = true
            }
          ]
        }
        dashboard = {
          enabled = true
          ssl     = false
        }
        logCollector = {
          enabled = false
        }
        placement = {
          all = {
            tolerations = [
              {
                key      = "loliot.net/storage"
                operator = "Exists"
              }
            ]
          }
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
              name = "ip-192-168-0-16"
              devices = [
                {
                  name = "/dev/sda"
                }
              ]
            },
            {
              name = "ip-192-168-0-11"
              devices = [
                {
                  name = "/dev/sda"
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
              placement = {
                tolerations = [
                  {
                    key      = "loliot.net/storage"
                    operator = "Exists"
                  }
                ]
              }
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
