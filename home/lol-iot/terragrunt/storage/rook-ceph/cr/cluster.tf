resource "kubernetes_manifest" "cephcluster_rook_ceph" {
  manifest = {
    apiVersion = "ceph.rook.io/v1"
    kind       = "CephCluster"
    metadata = {
      name      = "rook-ceph"
      namespace = var.rook_ceph_namespace
    }
    spec = {
      cephVersion = {
        image = "quay.io/ceph/ceph:v19.2.3"
      }
      cleanupPolicy = {
        allowUninstallWithVolumes = false
        confirmation              = ""
        sanitizeDisks = {
          dataSource = "zero"
          iteration  = 1
          method     = "quick"
        }
      }
      dashboard = {
        enabled = true
      }
      dataDirHostPath = "/var/lib/rook"
      disruptionManagement = {
        managePodBudgets      = true
        osdMaintenanceTimeout = 30
        pgHealthCheckTimeout  = 0
      }
      logCollector = {
        enabled = false
      }
      mgr = {
        count = 2
      }
      mon = {
        count = 3
      }
      network = {
        hostNetwork = true
      }
      placement = {
        all = {
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
      priorityClassNames = {
        mgr = "system-cluster-critical"
        mon = "system-node-critical"
        osd = "system-node-critical"
      }
      resources = {
        cleanup = {
          limits = {
            memory = "1Gi"
          }
          requests = {
            memory = "100Mi"
          }
        }
        crashcollector = {
          limits = {
            memory = "60Mi"
          }
          requests = {
            memory = "60Mi"
          }
        }
        exporter = {
          limits = {
            memory = "128Mi"
          }
          requests = {
            memory = "50Mi"
          }
        }
        mgr = {
          limits = {
            memory = "1Gi"
          }
          requests = {
            memory = "512Mi"
          }
        }
        "mgr-sidecar" = {
          limits = {
            memory = "100Mi"
          }
          requests = {
            memory = "40Mi"
          }
        }
        mon = {
          limits = {
            memory = "2Gi"
          }
          requests = {
            memory = "1Gi"
          }
        }
        osd = {
          limits = {
            memory = "4Gi"
          }
          requests = {
            memory = "4Gi"
          }
        }
        prepareosd = {
          requests = {
            memory = "50Mi"
          }
        }
      }
      storage = {
        useAllDevices = false
        useAllNodes   = false
        nodes = [
          {
            name    = "ip-172-31-254-2"
            devices = [{ name = "/dev/vg0/lvol0" }]
          },
          {
            name    = "ip-172-31-254-3"
            devices = [{ name = "/dev/vg0/lvol0" }]
          },
          {
            name    = "ip-172-31-254-4"
            devices = [{ name = "/dev/vg0/lvol0" }]
          }
        ]
      }
      monitoring = {
        enabled = false
      }
    }
  }

  field_manager {
    force_conflicts = true
  }

  lifecycle {
    prevent_destroy = true
  }
}
