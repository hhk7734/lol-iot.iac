resource "kubernetes_namespace" "argo-cd" {
  metadata {
    name = "argo-cd"
  }
}

resource "kubernetes_secret" "argo-cd-client-secret" {
  metadata {
    name      = "argo-cd-client-secret"
    namespace = kubernetes_namespace.argo-cd.metadata[0].name
    labels = {
      "app.kubernetes.io/part-of" = "argo-cd"
    }
  }
  data = {
    "oidc.casdoor.clientSecret" = file("${local.secret_dir}/argo-cd/oidc.casdoor.clientSecret")
  }
}

resource "helm_release" "argo-cd" {
  chart       = "${local.charts_dir}/argo-cd-5.53.13.tgz"
  max_history = 3
  name        = "argo-cd"
  namespace   = kubernetes_namespace.argo-cd.metadata[0].name
  timeout     = 300
  values = [
    jsonencode({
      fullnameOverride : "argo-cd"
      configs = {
        cm = {
          "server.rbac.log.enforce.enable" = "true"
          "exec.enabled"                   = "true"
          "admin.enabled"                  = "false"

          url = "https://argo-cd.loliot.net"
          "oidc.config" = yamlencode({
            name         = "casdoor"
            issuer       = "https://auth.loliot.net"
            clientID     = "08751c9654e43e77f7b6"
            clientSecret = format("$%s:oidc.casdoor.clientSecret", kubernetes_secret.argo-cd-client-secret.metadata[0].name)
          })
        }
        rbac = {
          "policy.csv" : <<-EOT
            g, loliot/argo-cd-admin, role:admin
            EOT
        }
      }
      dex = {
        enabled = false
      }
      server = {
        extraArgs = [
          "--insecure"
        ]
      }
      applicationSet = {
        enabled = false
      }
      notifications = {
        enabled = false
      }
    })
  ]
  wait = true
}


resource "kubernetes_manifest" "virtualservice-argo-cd" {
  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "VirtualService"
    metadata = {
      name      = "argo-cd"
      namespace = kubernetes_namespace.argo-cd.metadata[0].name
    }
    spec = {
      hosts    = ["argo-cd.loliot.net"]
      gateways = ["loliot/gateway"]
      http = [{
        match = [{
          uri = {
            prefix = "/"
          }
        }]
        route = [{
          destination = {
            host = "argo-cd-server"
            port = {
              number = 80
            }
          }
        }]
      }]
    }
  }
}

resource "kubernetes_secret" "github-hhk7734-creds" {
  metadata {
    name      = "github-hhk7734-creds"
    namespace = kubernetes_namespace.argo-cd.metadata[0].name
    labels = {
      "argocd.argoproj.io/secret-type" = "repo-creds"
    }
  }
  data = {
    type          = "git"
    url           = "git@github.com:hhk7734"
    sshPrivateKey = file("${local.secret_dir}/argo-cd/sshPrivateKey")
  }
}

resource "kubernetes_secret" "github-hhk7734-argo-cd-repo" {
  metadata {
    name      = "github-hhk7734-argo-cd-repo"
    namespace = kubernetes_namespace.argo-cd.metadata[0].name
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }
  data = {
    type = "git"
    url  = "git@github.com:hhk7734/argo-cd.git"
  }
}

resource "kubernetes_manifest" "appproject-loliot" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "AppProject"
    metadata = {
      name       = "loliot"
      namespace  = kubernetes_namespace.argo-cd.metadata[0].name
      finalizers = ["resources-finalizer.argocd.argoproj.io"]
    }
    spec = {
      description = ""
      sourceRepos = [
        "git@github.com:hhk7734/argo-cd.git"
      ]
      destinations = [
        {
          name      = "in-cluster"
          namespace = "*"
        }
      ]
    }
  }

}

resource "kubernetes_manifest" "application-loliot-wiki" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name       = "loliot-wiki"
      namespace  = kubernetes_namespace.argo-cd.metadata[0].name
      finalizers = ["resources-finalizer.argocd.argoproj.io"]
    }
    spec = {
      project = kubernetes_manifest.appproject-loliot.manifest.metadata.name
      source = {
        repoURL        = "git@github.com:hhk7734/argo-cd.git"
        path           = "wiki"
        targetRevision = "main"
        helm = {
          valueFiles = [
            "cd/prod-values.yaml"
          ]
        }
      }
      destination = {
        name      = "in-cluster"
        namespace = "loliot"
      }
      revisionHistoryLimit = 5
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
      }
    }
  }
}
