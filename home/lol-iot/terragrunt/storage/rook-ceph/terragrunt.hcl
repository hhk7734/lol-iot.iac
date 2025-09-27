include "base" {
  path = find_in_parent_folders("base.hcl")
}

include "kubernetes" {
  path = find_in_parent_folders("kubernetes.hcl")
}

locals {
  k8s_dir = get_parent_terragrunt_dir("kubernetes")
}

dependencies {
  paths = [
    "${local.k8s_dir}/network/cilium",
    "${local.k8s_dir}/monitoring/prometheus-stack",
  ]
}
