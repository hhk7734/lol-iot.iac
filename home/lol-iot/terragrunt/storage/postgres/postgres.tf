resource "kubernetes_namespace" "postgres" {
  metadata {
    name = "postgres"
  }
}

locals {
  postgres_version = "17.6"
}

resource "kubernetes_service_v1" "postgres-hl" {
  metadata {
    name      = "postgres-hl"
    namespace = kubernetes_namespace.postgres.metadata[0].name
    labels = {
      app                      = "postgres"
      "app.kubernetes.io/name" = "postgres"
    }
  }
  spec {
    type       = "ClusterIP"
    cluster_ip = "None"
    selector = {
      app                      = "postgres"
      "app.kubernetes.io/name" = "postgres"
    }
    port {
      name        = "postgres"
      port        = 5432
      target_port = "postgres"
    }
  }
}


resource "kubernetes_stateful_set_v1" "postgres" {
  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.postgres.metadata[0].name
    labels = {
      app                         = "postgres"
      "app.kubernetes.io/name"    = "postgres"
      "app.kubernetes.io/version" = local.postgres_version
    }
  }
  spec {
    service_name = kubernetes_service_v1.postgres-hl.metadata[0].name
    replicas     = 1
    selector {
      match_labels = {
        app                      = "postgres"
        "app.kubernetes.io/name" = "postgres"
      }
    }
    template {
      metadata {
        labels = {
          app                      = "postgres"
          "app.kubernetes.io/name" = "postgres"
        }
      }
      spec {
        container {
          name  = "postgres"
          image = "docker.io/library/postgres:${local.postgres_version}"
          port {
            name           = "postgres"
            container_port = 5432
          }
          env {
            name  = "POSTGRES_USER"
            value = "postgres"
          }
          env {
            name  = "POSTGRES_PASSWORD"
            value = "postgres"
          }
          env {
            name  = "PGDATA"
            value = "/var/lib/postgresql/17/docker"
          }
          resources {
            requests = {
              memory = "512Mi"
            }
            limits = {
              memory = "512Mi"
            }
          }
          volume_mount {
            name       = "pgdata"
            mount_path = "/var/lib/postgresql"
          }
        }
      }
    }
    volume_claim_template {
      metadata {
        name = "pgdata"
      }
      spec {
        storage_class_name = "ceph-block"
        access_modes       = ["ReadWriteOnce"]
        resources {
          requests = {
            storage = "5Gi"
          }
        }
      }
    }
  }
}
