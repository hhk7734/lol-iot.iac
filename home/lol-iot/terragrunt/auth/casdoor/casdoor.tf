resource "kubernetes_namespace" "casdoor" {
  metadata {
    name = "casdoor"
  }
}

resource "helm_release" "casdoor" {
  repository  = "https://hhk7734.github.io/helm-charts/"
  chart       = "casdoor-helm-charts"
  version     = "v1.762.0"
  max_history = 3
  name        = "casdoor"
  namespace   = kubernetes_namespace.casdoor.metadata[0].name
  timeout     = 300
  values = [jsonencode({
    fullnameOverride = "casdoor"
    database = {
      driver   = "postgres"
      user     = "casdoor"
      password = rsadecrypt("eI/1FvpJrqi2IIkNY7f4RBTj23usF0473dSEkTLV+tYlbjn/aNJ/FLXjaGa4nupUvREaJl8miNUW68w0wVCfEy364oA63+L0l1NqTW/m2w018mbcNq7idlmg5Vvj7J94HCBqqsd591anhKT41GKF7vtCdwIudOASiod57EIv0Smhi8/yaHPv/jKUNtSct+5ncJAp1zrUPAh1FIDhL3JRsLFbzP5jd70fTSwAUbLksHX/twOnw6wS5yhDrJ54lLYxnNINSNq5B03R/X12Uz1HOIlgENoxuMTBS9cLvBowmiNhjqJn63SDelQew+ma4wSHi3v/rxBkrpUEysJIcms6Mz1LY7XPQvpSVccZTBQTcOssO2XW9FWWWvibx4z3hVfx94cDGJ2dkTGqrh8B9IRcjbENgcKt3/mOpDdVqHtsJuz8oP8DDwXa5u1WyXRe2I+ZOASAEbnARCbUYQ2bwNj62Smgll0+Ebwuv1D8wWGZItZKI3lvfXLgZzKBac4KQh3eC/I1JsN1Q8z20/rIW7XCJZxdXv2AkOxpYuN61urWwPrpeNc/OQXVeYXzNN1I4EdKPp3THrtvFtvovLGD4ZxoK8t11iM46SYd71Snis1bDeR8RTAjHYcjstg+BI3l4vUYmW+SXA/zS1CAXgg/BpEJOmZS48RJPRn+8bNjTemv1VA=", local.private_pem)
      host     = "postgres.postgres.svc.cluster.local"
    }
  })]
}

resource "kubernetes_manifest" "httproute_casdoor" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"
    metadata = {
      name      = "casdoor"
      namespace = kubernetes_namespace.casdoor.metadata[0].name
    }
    spec = {
      parentRefs = [{
        name      = "gateway"
        namespace = "kube-system"
      }]
      hostnames = ["casdoor.lol-iot.loliot.net"]
      rules = [{
        matches = [{
          path = {
            type  = "PathPrefix"
            value = "/"
          }
        }]
        backendRefs = [{
          name = "casdoor"
          port = 8000
        }]
      }]
    }
  }
}
