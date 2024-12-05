resource "kubernetes_namespace_v1" "temp" {
  metadata {
    name = "temp"
  }
}

resource "kubernetes_config_map_v1" "ads_txt" {
  metadata {
    name      = "ads-txt"
    namespace = kubernetes_namespace_v1.temp.metadata[0].name
  }
  data = {
    "ads.txt" = "google.com, pub-5199357432848758, DIRECT, f08c47fec0942fa0"
  }
}

resource "kubernetes_pod_v1" "ads_txt" {
  metadata {
    name      = "ads-txt"
    namespace = kubernetes_namespace_v1.temp.metadata[0].name
    labels = {
      app = "ads-txt"
    }
  }
  spec {
    container {
      name  = "ads-txt"
      image = "nginx:alpine"
      volume_mount {
        name       = "ads-txt"
        mount_path = "/usr/share/nginx/html"
      }
    }
    volume {
      name = "ads-txt"
      config_map {
        name = kubernetes_config_map_v1.ads_txt.metadata[0].name
      }
    }
  }
}

resource "kubernetes_service_v1" "ads_txt" {
  metadata {
    name      = "ads-txt"
    namespace = kubernetes_namespace_v1.temp.metadata[0].name
  }
  spec {
    selector = {
      app = kubernetes_pod_v1.ads_txt.metadata[0].labels.app
    }
    port {
      port        = 80
      target_port = 80
    }
  }
}

resource "kubernetes_manifest" "httproute_ads_txt" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"
    metadata = {
      name      = "ads-txt"
      namespace = kubernetes_namespace_v1.temp.metadata[0].name
    }
    spec = {
      parentRefs = [{
        name      = "gateway"
        namespace = "kube-system"
      }]
      hostnames = ["loliot.net"]
      rules = [{
        matches = [{
          path = {
            type  = "PathPrefix"
            value = "/"
          }
        }]
        backendRefs = [{
          name = kubernetes_service_v1.ads_txt.metadata[0].name
          port = kubernetes_service_v1.ads_txt.spec[0].port[0].port
        }]
      }]
    }
  }
}
