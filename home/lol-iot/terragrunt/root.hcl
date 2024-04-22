locals {
  k8s_config_paths = jsonencode([
    "~/.kube/config",
    "~/.kube/lol-iot.yaml",
  ])
  k8s_config_context = "arn:lol-iot:k8s:home:hhk7734:cluster/lol-iot/user/admin"
}

remote_state {
  backend = "local"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    path = "${get_path_to_repo_root()}/local_secret/${get_path_from_repo_root()}/terraform.tfstate"
  }
}

generate "main" {
  path      = "main.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    provider "kubernetes" {
      config_paths   = ${local.k8s_config_paths}
      config_context = "${local.k8s_config_context}"
    }

    provider "helm" {
      kubernetes {
        config_paths   = ${local.k8s_config_paths}
        config_context = "${local.k8s_config_context}"
      }
    }
    EOF
}
