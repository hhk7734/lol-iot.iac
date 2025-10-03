locals {
  redis_version = "8.2.1"
}

resource "kubernetes_service_v1" "redis_hl" {
  metadata {
    name      = "redis-hl"
    namespace = kubernetes_namespace_v1.authentik.metadata[0].name
    labels = {
      app                         = "redis"
      "app.kubernetes.io/name"    = "redis"
      "app.kubernetes.io/version" = local.redis_version
    }
  }
  spec {
    type       = "ClusterIP"
    cluster_ip = "None"
    selector = {
      app                      = "redis"
      "app.kubernetes.io/name" = "redis"
    }
    port {
      name        = "redis"
      port        = 6379
      target_port = "redis"
    }
  }
}

resource "kubernetes_config_map_v1" "redis" {
  metadata {
    name      = "redis"
    namespace = kubernetes_namespace_v1.authentik.metadata[0].name
    labels = {
      app                         = "redis"
      "app.kubernetes.io/name"    = "redis"
      "app.kubernetes.io/version" = local.redis_version
    }
  }
  data = {
    "redis.conf" = <<EOF
      EOF
  }
}

resource "kubernetes_stateful_set_v1" "redis" {
  metadata {
    name      = "redis"
    namespace = kubernetes_namespace_v1.authentik.metadata[0].name
    labels = {
      app                         = "redis"
      "app.kubernetes.io/name"    = "redis"
      "app.kubernetes.io/version" = local.redis_version
    }
  }
  spec {
    service_name = kubernetes_service_v1.redis_hl.metadata[0].name
    replicas     = 1
    selector {
      match_labels = {
        app                      = "redis"
        "app.kubernetes.io/name" = "redis"
      }
    }
    template {
      metadata {
        labels = {
          app                         = "redis"
          "app.kubernetes.io/name"    = "redis"
          "app.kubernetes.io/version" = local.redis_version
        }
      }
      spec {
        container {
          name    = "redis"
          image   = "docker.io/library/redis:${local.redis_version}"
          command = ["redis-server"]
          args    = ["/usr/local/etc/redis/redis.conf"]
          port {
            name           = "redis"
            container_port = 6379
          }
          volume_mount {
            name       = "config"
            mount_path = "/usr/local/etc/redis"
            read_only  = true
          }
          volume_mount {
            name       = "data"
            mount_path = "/data"
          }
        }
        volume {
          name = "config"
          config_map {
            name = kubernetes_config_map_v1.redis.metadata[0].name
          }
        }
      }
    }
    volume_claim_template {
      metadata {
        name = "data"
        labels = {
          app                         = "redis"
          "app.kubernetes.io/name"    = "redis"
          "app.kubernetes.io/version" = local.redis_version
        }
      }
      spec {
        storage_class_name = "ceph-block"
        access_modes       = ["ReadWriteOnce"]
        resources {
          requests = {
            storage = "1Gi"
          }
        }
      }
    }
  }
}
