include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  root_dir = get_parent_terragrunt_dir("root")
}

dependencies {
  paths = [
    "${local.root_dir}/network/cilium",
  ]
}

dependency "monitoring_namespace" {
  config_path = "${local.root_dir}/monitoring/namespace"
}

inputs = {
  monitoring_namespace = dependency.monitoring_namespace.outputs.namespace
}