resource "kubernetes_namespace" "auth" {
  metadata {
    name = "auth"
    labels = {
      "app.kubernetes.io/managed-by" = "pulumi"
      "loliot.net/stack"             = "ap-northeast-2.loliot-net.auth"
    }
  }
}

resource "helm_release" "cert-manager" {
  chart       = "${local.charts_dir}/cert-manager-v1.13.3.tgz"
  max_history = 3
  name        = "cert-manager"
  namespace   = kubernetes_namespace.auth.metadata[0].name
  timeout     = 300
  values = [jsonencode(
    {
      global = {
        commonLabels = {
          "loliot.net/stack" = "ap-northeast-2.loliot-net.auth"
        }
      }
      installCRDs               = true
      enableCertificateOwnerRef = true
      resources = {
        requests = {
          cpu    = "10m"
          memory = "32Mi"
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
      cainjector = {
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
      startupapicheck = {
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
      webhook = {
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
  wait = true
}

resource "helm_release" "casdoor" {
  chart       = "${local.charts_dir}/casdoor-helm-charts-v1.514.0.tgz"
  max_history = 3
  name        = "casdoor"
  namespace   = kubernetes_namespace.auth.metadata[0].name
  timeout     = 300
  values = [jsonencode(
    {
      fullnameOverride = "casdoor"
      config           = <<-EOT
                            appname = casdoor
                            httpport = {{ .Values.service.port }}
                            runmode = dev
                            SessionOn = true
                            copyrequestbody = true
                            driverName = postgres
                            dataSourceName = "user=casdoor password=casdoor host=postgresql.storage.svc.cluster.local port=5432 sslmode=disable dbname=casdoor"
                            dbName =
                            redisEndpoint =
                            defaultStorageProvider =
                            isCloudIntranet = false
                            authState = "casdoor"
                            socks5Proxy = ""
                            verificationCodeTimeout = 10
                            initScore = 0
                            logPostOnly = true
                            origin =
                            enableGzip = true
                        EOT
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
