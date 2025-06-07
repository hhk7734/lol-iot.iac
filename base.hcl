remote_state {
  backend = "local"
  generate = {
    path      = "gen-backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    path = "${get_path_to_repo_root()}/local_secret/${get_path_from_repo_root()}/terraform.tfstate"
  }
}

generate "base" {
  path      = "gen-base.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    variable "private_pem_path" {
      type    = string
      default = "${get_path_to_repo_root()}/private.pem"
    }

    locals {
      private_pem = file(var.private_pem_path)
    }
    EOF
}
