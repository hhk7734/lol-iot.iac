resource "kubernetes_namespace" "grafana" {
  metadata {
    name = "grafana"
  }
}

resource "kubernetes_secret_v1" "grafana_env" {
  metadata {
    name      = "grafana-env"
    namespace = kubernetes_namespace.grafana.metadata[0].name
  }
  data = {
    OIDC_CLIENT_SECRET = rsadecrypt("zE6aDygn46Fo6P1ax1F6cE6VkYr7Dn4Ltr1KgUAjQB7k4iO/VfMfannZM5K+udF7QHtAJQ8znAfYMFepUGmtwIAyJiokgZQHUMeBHXG9FwR37dmlah6iFclNpGhcXwAxJrDB7Hp7Vphaa4kRtscphkm5o0ejaUUlDaPexil9TlYJcXmsyLA/wDvaeMyw/BLvKIPxiJ9VouSiwpJCG5230bODEppdmJ0zFJAE+rDeHje5tE4aVM0Eys2kdaALyFXFNqPHovcJEfV5l6Dk6dPrtg3HhSO4BcEcsNO1ZhzyMb2VCxNQQR8l31we20kL8OgSDJVqka8jnQnh+Gwk7mWj+C/IBykwKMI2pD9KSEUDGz0YKgHLxZjDtrrJNAcUkKlcH/C4FYeOa1twtzjxv7YnjOLyGzB2LqpqJx0LaWMtSO+1cXJqvb59ELaRvho5P1X9j3aPXGBpcn+XH0U/hnA428P3lUjjQUo1iSPpkhBMOzsUL23hfCn4FR5YwQnAcb9aKE2iy+46X0iO13KGxCPZxP5KrSI0fmj23/NmsdBCaiF+GKiyK17PsUQnXT8/dkABB1Kx0BQmGQhGw+bDPU0RCqK3+aoziv4krCc0kBT/kOgjjpVYH1eoWVoNpvWeTe5X/1nELlNQl3SE3pBqw7SGrHtXKRXgzmJEQjikVNZ8IOA=", local.private_pem)
  }
}

resource "helm_release" "grafana" {
  repository  = "https://hhk7734.github.io/helm-charts/"
  chart       = "grafana"
  version     = "8.6.4"
  max_history = 5
  name        = "grafana"
  namespace   = kubernetes_namespace.grafana.metadata[0].name
  timeout     = 300
  values = [jsonencode({
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
    datasources = {
      "datasources.yaml" = {
        apiVersion        = 1
        deleteDatasources = []
        datasources = [
          {
            name      = "prometheus"
            type      = "prometheus"
            isDefault = true
            url       = "http://prometheus-operated.prometheus-stack.svc.cluster.local:9090"
            uid       = "194258a3-be9e-407a-a922-f47535e102d3"
          },
          # {
          #   name      = "loki"
          #   type      = "loki"
          #   isDefault = false
          #   url       = "http://loki-query-frontend.monitoring.svc.cluster.local:3100"
          #   uid       = "467772c5-1416-4599-967a-844d3afc17f5"
          # }
        ]
      }
    }
    dashboardProviders = {
      "dashboardproviders.yaml" = {
        apiVersion = 1
        providers = [
          {
            name           = "kubernetes"
            folder         = "kubernetes"
            type           = "file"
            allowUiUpdates = true
            options = {
              path = "/var/lib/grafana/dashboards/kubernetes"
            }
          }
        ]
      }
    }
    dashboards = {
      kubernetes = {
        deployment-statefulset-daemonset = {
          url = "https://raw.githubusercontent.com/hhk7734/grafana-dashboard/main/kubernetes/Deployment_StatefulSet_DaemonSet.json"
          datasource = [
            {
              name  = "DS_PROMETHEUS"
              value = "194258a3-be9e-407a-a922-f47535e102d3"
            }
          ]
        }
      }
    }
    envFromSecret = kubernetes_secret_v1.grafana_env.metadata[0].name
    "grafana.ini" = {
      server = {
        root_url = "https://grafana.lol-iot.loliot.net"
      }
      "auth.generic_oauth" = {
        enabled             = true
        name                = "Casdoor"
        client_id           = "f33f76797b6a86b07ae5"
        client_secret       = "$${OIDC_CLIENT_SECRET}"
        scopes              = "openid profile email groups"
        auth_url            = "https://casdoor.lol-iot.loliot.net/login/oauth/authorize"
        token_url           = "https://casdoor.lol-iot.loliot.net/api/login/oauth/access_token"
        api_url             = "https://casdoor.lol-iot.loliot.net/api/userinfo"
        role_attribute_path = "contains(groups[*], 'lol-iot/devops') && 'GrafanaAdmin' || 'Viewer'"
        allow_sign_up       = true
        auto_login          = true
        use_refresh_token   = true
      }
    }
  })]
}

resource "kubernetes_manifest" "httproute_grafana" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"
    metadata = {
      name      = "grafana"
      namespace = kubernetes_namespace.grafana.metadata[0].name
    }
    spec = {
      parentRefs = [{
        name      = "gateway"
        namespace = "kube-system"
      }]
      hostnames = ["grafana.lol-iot.loliot.net"]
      rules = [{
        matches = [{
          path = {
            type  = "PathPrefix"
            value = "/"
          }
        }]
        backendRefs = [{
          name = "grafana"
          port = 80
        }]
      }]
    }
  }
}
