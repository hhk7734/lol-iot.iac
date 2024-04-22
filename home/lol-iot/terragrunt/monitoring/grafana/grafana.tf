resource "helm_release" "grafana" {
  repository  = "https://hhk7734.github.io/helm-charts/"
  chart       = "grafana"
  version     = "7.3.7"
  max_history = 5
  name        = "grafana"
  namespace   = "monitoring"
  timeout     = 300
  values = [jsonencode(
    {
      datasources = {
        "datasources.yaml" = {
          apiVersion        = 1
          deleteDatasources = []
          datasources = [
            {
              name      = "prometheus"
              type      = "prometheus"
              isDefault = true
              url       = "http://prometheus-operated.monitoring.svc.cluster.local:9090"
              uid       = "194258a3-be9e-407a-a922-f47535e102d3"
            },
            {
              name      = "loki"
              type      = "loki"
              isDefault = false
              url       = "http://loki-query-frontend.monitoring.svc.cluster.local:3100"
              uid       = "467772c5-1416-4599-967a-844d3afc17f5"
            }
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
    }
  )]
  wait = true
}
