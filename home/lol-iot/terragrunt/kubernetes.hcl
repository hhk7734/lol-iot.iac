locals {
  kube_config_paths = jsonencode([
    "~/.kube/config",
    "~/.kube/lol-iot.yaml"
  ])
  kube_config_context = "home/lol-iot/admin"
}

generate "kubernetes" {
  path      = "gen-kubernetes.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    provider "kubernetes" {
      config_paths   = ${local.kube_config_paths}
      config_context = "${local.kube_config_context}"
    }

    provider "helm" {
      kubernetes {
        config_paths   = ${local.kube_config_paths}
        config_context = "${local.kube_config_context}"
      }
    }
    EOF
}
