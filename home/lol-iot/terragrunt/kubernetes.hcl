locals {
  kube_config_paths = jsonencode([
    "~/.kube/config",
    "~/.kube/lol-iot.yaml"
  ])
  kube_config_context =        "home/lol-iot/admin"
}

generate "kubernetes" {
  path      = "gen-kubernetes.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    terraform {
      required_providers {
        kubernetes = {
          source = "hashicorp/kubernetes"
          version = "~>2"
        }
        helm = {
          source = "hashicorp/helm"
          version = "~>3"
        }
      }
    }

    provider "kubernetes" {
      config_paths   = ${local.kube_config_paths}
      config_context = "${local.kube_config_context}"
    }

    provider "helm" {
      kubernetes = {
        config_paths   = ${local.kube_config_paths}
        config_context = "${local.kube_config_context}"
      }
    }
    EOF
}
