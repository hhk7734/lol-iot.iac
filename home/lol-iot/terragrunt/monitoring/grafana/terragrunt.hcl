include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  root_dir = get_parent_terragrunt_dir("root")
}

dependencies {
  paths = [
    "${local.root_dir}/monitoring/prometheus-cr",
    "${local.root_dir}/monitoring/loki",
  ]
}
