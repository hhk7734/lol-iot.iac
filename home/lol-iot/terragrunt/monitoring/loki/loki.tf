resource "helm_release" "loki-distributed" {
  chart       = "${local.charts_dir}/loki-distributed-0.78.4.tgz"
  max_history = 5
  name        = "loki-distributed"
  namespace   = var.monitoring_namespace
  timeout     = 300
  values = [jsonencode(
    {
      fullnameOverride = "loki"
      loki = {
        schemaConfig = {
          configs = [
            {
              from         = "2024-03-31"
              store        = "boltdb-shipper"
              object_store = "s3"
              schema       = "v12"
              index = {
                prefix = "loki_index_"
                period = "24h"
              }
            }
          ]
        }
        storageConfig = {
          aws = {
            endpoint          = "http://$${BUCKET_HOST}:$${BUCKET_PORT}"
            region            = "$${BUCKET_REGION}"
            bucketnames       = "$${BUCKET_NAME}"
            access_key_id     = "$${AWS_ACCESS_KEY_ID}"
            secret_access_key = "$${AWS_SECRET_ACCESS_KEY}"
          }
          boltdb_shipper = {
            shared_store           = "s3"
            active_index_directory = "/var/loki/index"
            cache_location         = "/var/loki/cache"
            cache_ttl              = "168h"
          }
        }
        structuredConfig = {
          limits_config = {
            max_entries_limit_per_query = 10000
          }
        }
      }
      ingester = {
        extraArgs = [
          "-config.expand-env=true"
        ]
        extraEnvFrom = [
          {
            secretRef = {
              name = kubernetes_manifest.loki-bucket.manifest.metadata.name
            }
          },
          {
            configMapRef = {
              name = kubernetes_manifest.loki-bucket.manifest.metadata.name
            }
          }
        ]
      }
      querier = {
        extraArgs = [
          "-config.expand-env=true"
        ]
        extraEnvFrom = [
          {
            secretRef = {
              name = kubernetes_manifest.loki-bucket.manifest.metadata.name
            }
          },
          {
            configMapRef = {
              name = kubernetes_manifest.loki-bucket.manifest.metadata.name
            }
          }

        ]
      }
    }
  )]
}
