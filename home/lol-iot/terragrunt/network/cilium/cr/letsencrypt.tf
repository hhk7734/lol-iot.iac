resource "kubernetes_secret_v1" "cloudflare_api_token" {
  metadata {
    name      = "cloudflare-api-token"
    namespace = "kube-system"
  }
  data = {
    token = rsadecrypt("yx2z+lCUAWN72PqqB8SuzRmLt7ZFxtlTefIUN0OTzMSoA4NrYmexl6OdLN3qAR65ut+WLFPNiMbyKqUCSz/AxUl9lDioHNMeYjy0uDaKwZ455W2tNUSho6MJ5etzea1khydiRZPtZiz+MDtY0pRQyu2Ji1c6OiDEvtzSbrUPhskklAjPhNE/CiYPF21/iiYKLsRYN3ILnUhCMU69bASFU6OEjo2gbz6yxu7NfSbgxQilVbGyiagC4OA977h+uYyNOrhJ6+JMDMQ03fTVh6F1ztgdp+/GUOYr+zDAz8tMndTkK6n51/pVd4f5iMxj3/UnBKcug0cxhPxuzG4CdkNrUwWiCdTEma3+PSAs3oqvRdHGNE6XZ56Jth+6aXEb1heYkUzbXXckENLm0DkMvhUcHOODqJ1SuCA0B9q7jIksh73BpGYlj1iIuO98GxQgI6GFKD6IQw11FWQJ9wKo4Wd+eClfWxWepLDnSzTtHq782LN75Bh0fCKDLvxL1B4gKRxke6psWXbaByiEwpqbZpEMk09oOfZpwML8Ltf/q924Fyiw3MWvdwVrG4CnsuuXn4GfRZ10/zyY/371zSIg2LONn9BgmPqCyacxhYg8J0VSMvwkyfxrmvERrWLQhwAJDnh7e8SRbJ+Arwu15QlNmqg0567dyymaBehOgeRcV7gVw6U=", local.private_pem)
  }
}

resource "kubernetes_manifest" "issuer_letsencrypt" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Issuer"
    metadata = {
      name      = "letsencrypt"
      namespace = "kube-system"
    }
    spec = {
      acme = {
        email  = "hhk7734@gmail.com"
        server = "https://acme-v02.api.letsencrypt.org/directory"
        privateKeySecretRef = {
          name = "letsencrypt"
        }
        solvers = [{
          selector = {
            dnsZones = ["loliot.net"]
          }
          dns01 = {
            cloudflare = {
              email = "hhk7734@gmail.com"
              apiTokenSecretRef = {
                name = kubernetes_secret_v1.cloudflare_api_token.metadata[0].name
                key  = "token"
              }
            }
          }
        }]
      }
    }
  }
}

resource "kubernetes_manifest" "certificate_lol_iot" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "lol-iot"
      namespace = "kube-system"
    }
    spec = {
      secretName = "lol-iot-tls"
      issuerRef = {
        kind = kubernetes_manifest.issuer_letsencrypt.manifest.kind
        name = kubernetes_manifest.issuer_letsencrypt.manifest.metadata.name
      }
      dnsNames = [
        "lol-iot.loliot.net",
        "*.lol-iot.loliot.net"
      ]
      duration    = "2160h" # 90d
      renewBefore = "360h"  # 15d
    }
  }
}
