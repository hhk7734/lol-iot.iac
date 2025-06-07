resource "random_password" "oauth2_proxy_cookie_secret" {
  length           = 32
  override_special = "-_"
}

resource "helm_release" "oauth2_proxy" {
  repository  = "https://oauth2-proxy.github.io/manifests"
  chart       = "oauth2-proxy"
  version     = "7.12.17"
  name        = "oauth2-proxy"
  namespace   = var.rook_ceph_namespace
  max_history = 5
  values = [jsonencode({
    config = {
      clientID     = "88ca91a4d7c4296b48fe"
      clientSecret = rsadecrypt("2aZI5vKVPjUa64teuD8Awomfot5JdSkrvNB4XALWm7ruLT/xREnWE+g6jCFasxoFS8Qh3MYZyx7PsxhMvnZ8K8vpkKwVNuhmc2Hil/fO/k+LgrTIt0a78BNLfEDT+gWI7A1rIWIS9FNkpkr9LcW2AhH/fAXn+ofBQc68UuuklOh4HN30U1GQC/SZeo4Bj55huPqcOTqVOcLTQVyM+dVeLwUHOyTyjb+wgGUuHqOWFnkYdhBZl+5C3bQh5tK3zRTyeXPBnfmBSSO7IjBWAf6jzFub6G/1wodw7BbjwjLDwYrlP//J6kn4Y80zauLXn3kHoEP9Xmbnr8eBVO48MuQ5Qe60gqc+jQPTu6V1P/zLzczom0RlHa878FhzWblProE2V+UKwfpXlGkQRXJ5By5FYJG39XeqZTyxMYATzKe40lMp6tgNZW7+gmrFpmzkDHEkWr/ucIW5zm1Jd/kNLcTurRbbD80jnhyN+vpdTcV9xbPUFU5Fcv5ZDvFWmQueHn08LwQaltBnie3ftejtq/crTTdIZ++M16JEzBWF0ZUEj4xMSq5J6EwefCtoQSnrWFrlV2/PCI3i900+Bo34SY6+Y17cHS9cpRGtsrz1xBSJDrRNV4g3GLwcDKSoP5407s0V7EizPup9F6GlikeNtrFINd9Utfkd6QSMEmQyb1ULF8Y=", local.private_pem)
      cookieSecret = random_password.oauth2_proxy_cookie_secret.result
      configFile   = <<-EOF
        email_domains = [ "*" ]

        provider = "oidc"
        oidc_issuer_url = "https://casdoor.lol-iot.loliot.net"
        scope = "openid email profile groups"
        redirect_url = "https://ceph.lol-iot.loliot.net/oauth2/callback"

        upstreams = [
          "http://rook-ceph-mgr-dashboard.rook-ceph.svc.cluster.local:7000"
        ]
        EOF
    }
  })]
}

resource "kubernetes_manifest" "httproute_oauth2_proxy" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"
    metadata = {
      name      = "oauth2-proxy"
      namespace = var.rook_ceph_namespace
    }
    spec = {
      parentRefs = [{
        name      = "gateway"
        namespace = "kube-system"
      }]
      hostnames = ["ceph.lol-iot.loliot.net"]
      rules = [{
        matches = [{
          path = {
            type  = "PathPrefix"
            value = "/"
          }
        }]
        backendRefs = [{
          name = "oauth2-proxy"
          port = 80
        }]
      }]
    }
  }

  depends_on = [helm_release.oauth2_proxy]
}
