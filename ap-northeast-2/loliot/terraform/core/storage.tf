import {
  to = kubernetes_namespace.storage
  id = "storage"
}

import {
  to = helm_release.postgresql
  id = "storage/postgresql"
}

resource "kubernetes_namespace" "storage" {
  metadata {
    name = "storage"
    labels = {
      "app.kubernetes.io/managed-by" = "pulumi"
      "loliot.net/stack"             = "ap-northeast-2.loliot-net.storage"
    }
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
      affinity = {
        nodeAffinity = local.control_plane_node_affinity
      }
      tolerations = [
        {
          effect   = "NoSchedule"
          key      = "node-role.kubernetes.io/master"
          operator = "Exists"
        },
      ]
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
        affinity = {
          nodeAffinity = local.control_plane_node_affinity
        }
        tolerations = [
          {
            effect   = "NoSchedule"
            key      = "node-role.kubernetes.io/master"
            operator = "Exists"
          },
        ]
      }
    }
  )]
  wait       = true
  depends_on = [helm_release.local-path-provisioner]
}
