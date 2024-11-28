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
