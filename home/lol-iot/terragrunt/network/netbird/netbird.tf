resource "kubernetes_namespace_v1" "netbird" {
  metadata {
    name = "netbird"
  }
}

resource "helm_release" "netbird" {
  repository  = "https://lol-iot.github.io/helm-charts/"
  chart       = "netbird"
  version     = "0.59.2"
  max_history = 3
  name        = "netbird"
  namespace   = kubernetes_namespace_v1.netbird.metadata[0].name
  timeout     = 300
  values = [jsonencode(
    {
      management = {
        database = {
          host          = "postgres-0.postgres-hl.postgres.svc.cluster.local"
          encryptionKey = rsadecrypt("SOmo9aqjbGCRaB2VP+UXEPGBu3nWiW/gtBdKRH8N9KZeOnvm1T85pKR9cfFgeUDGjL+pwE3+byPJbnnpIz1MT2iQDKgaX7SsK9W2Yymo7tQJh9XopF5XGrpQ+aaVri6wPI4xj0cYcIZZ4Vyf8Vwas/uFMETKPkGvm2xW30IHdB6lgJtsA8a3Lo42ng0sZ1AjQ6DWA+c2L26Bu9PyYt8VAPVMSjzoRR6qakrC3cy10Xy+moGUgByXlF2NdXuKQQnblu4R7pzonht07+rOFIB+32jtWJ9OUoyObzfq2pKapOUSxv7dTrfEeL5jLr4AXGfzoRx1xoklX8j8bb2+VdNA5i6NjDIPARPvcqUBibCIGIauVhu+wnBZFi0SxjwcVUlEgv5la6DHoUAzEiJps2LY+GZjg5Qa1ZPpwpuwkb1Jt0GXT2O+EmW3Lwv/x1OFF/DL76ltV2iGUiBrMsqvrj3utpu9n6UNvGTtdsGKyq/0cEJGnsEJcat9oVTVsUxQS18olGYVwKiq4zQzoN6ombKGurqwJbMOv9Aj5oOBE1o6MwMGy4PP10dpuY3A47aYRpp1DHRGI+llsmwKCwXeHpSp8ExooTgiCnTynU2Awpqs+dSgaLyvEQHbrgmLQuA7xq4z5lTT628HB+gbpcWy8HNRfkluG4Tb22tbBu9Zla+D+qc=", local.private_pem)
        }
      }
      relay = {
        authSecret = rsadecrypt("Td6lDrfFUDoqcbeUmz5Jgd+/1/qRTJc0oPiXH/KZyyUwZJRBWSrO2Ck/bt1k+C1ONk9XFUk40LBAnW4I7vb2PQpPXBsgRRoZ913nQwm2Ag+vODQ9j3YV/VCnfk7xu2L8kOp2V178vQ9vyV7WS4icF51tfuVo5VOhaPcX/tf7xYHgOVhp8TjTibeUTCU8thX1o5q5rKCqN9dTfcde6MRfrDeW3To1wl/c2aehUGtFOcrYF5KC80n/6YQHde1qBgQ0xyVP7L+oPBmctTcR96GD7wR8SbcSftO9A78fY63JSsGZnG6DAZZVBy6Uj2pOhQrG3cxQ2/Y619WFkClCH7W2nMITDDfzwTokBqJc5Cz+6d+HQ1O//tXtsAlPd6Jb3PujMpVHgp2jpJ6tBXTVuI1vYV/PX70RYSFudJZRMam5j/opzJuSjyUiku2MKM+gCfmuxSrWJzc1HGle6Jw3m1271Dgcw40v9Vm9K55HlVBo2Cy3P4eb0uf4jVNSzGY7fGc3Lx3Vvl2HbHLklaJkc9PrB2FnL0MJtV0QPxMAMmDmjvYhU63gsJJfxEztsI2luQSoxEcbic7Grp4qLBUZk8psmvl4IxlWBowQ/ZQCg55pslpswrKXYyKCDYKvtNRsCgdEQFeJ4yRTjDrxyJipNvDOzslH0oWHcvVeor7F7HZ0GFE=", local.private_pem)
      }
      dashboard = {
        image = {
            tag = "v2.19.1"
        }
      }
      oidc = {
        issuer         = "https://auth.lol-iot.loliot.net/application/o/netbird"
        clientID       = "U03ndTXqloZ17avRB7nYuHhQ3p8dDi9TQSBiFc7N"
        deviceProvider = "hosted"
      }
      route = {
        enabled = true
        parentRefs = [{
          name      = "gateway"
          namespace = "kube-system"
        }]
        serverHostname    = "vpn.lol-iot.loliot.net"
        dashboardHostname = "vpn-dashboard.lol-iot.loliot.net"
      }
    }
  )]
}
