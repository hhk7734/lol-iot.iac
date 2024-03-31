resource "helm_release" "vector" {
  chart       = "${local.charts_dir}/vector-0.32.0.tgz"
  max_history = 5
  name        = "vector"
  namespace   = var.monitoring_namespace
  timeout     = 300
  values = [jsonencode(
    {
      role = "Agent"
      tolerations = [
        {
          key      = "loliot.net/storage"
          operator = "Exists"
        }
      ]
      customConfig = {
        api = {
          enabled    = true
          address    = "127.0.0.1:8686"
          playground = false
        }
        sources = {
          kubernetes_logs = {
            type                        = "kubernetes_logs"
            include_paths_glob_patterns = ["# TODO"]
          }
        }
        sinks = {
          loki = {
            inputs   = ["kubernetes_logs"]
            type     = "loki"
            endpoint = "http://loki-distributor:3100"
            encoding = {
              codec = "json"
            }
            labels = {
              job = "vector"
            }
          }
        }
      }
      defaultVolumeMounts = [
        {
          name      = "var-log"
          mountPath = "/var/log/"
          readOnly  = true
        },
        {
          name      = "var-lib"
          mountPath = "/var/lib"
        },
        {
          name      = "procfs"
          mountPath = "/host/proc"
          readOnly  = true
        },
        {
          name      = "sysfs"
          mountPath = "/host/sys"
          readOnly  = true
        }
      ]
    }
  )]
  depends_on = [helm_release.loki-distributed]
}
