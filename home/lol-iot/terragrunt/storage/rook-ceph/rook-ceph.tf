resource "kubernetes_namespace" "rook_ceph" {
  metadata {
    name = "rook-ceph"
  }
}

resource "helm_release" "rook_ceph" {
  repository  = "https://charts.rook.io/release"
  chart       = "rook-ceph"
  version     = "v1.18.2"
  max_history = 5
  name        = "rook-ceph"
  namespace   = kubernetes_namespace.rook_ceph.metadata[0].name
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
        },
        {
          key      = "loliot.net/storage"
          operator = "Equal"
          value    = "enabled"
          effect   = "NoSchedule"
        }
      ]
      rbacAggregate = {
        enableOBCs = true
      }
      csi = {
        enableRbdDriver           = true
        csiRBDProvisionerResource = <<-EOT
          - name : csi-provisioner
            resource: null
          - name : csi-resizer
            resource: null
          - name : csi-attacher
            resource: null
          - name : csi-snapshotter
            resource: null
          - name : csi-rbdplugin
            resource: null
          - name : csi-omap-generator
            resource: null
          - name : liveness-prometheus
            resource: null
          EOT
        csiRBDPluginResource      = <<-EOT
          - name : driver-registrar
            resource: null
          - name : csi-rbdplugin
            resource: null
          - name : liveness-prometheus
            resource: null
          EOT

        enableCephfsDriver           = true
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
        pluginTolerations = [
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
        provisionerTolerations = [
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
    })
  ]
}
