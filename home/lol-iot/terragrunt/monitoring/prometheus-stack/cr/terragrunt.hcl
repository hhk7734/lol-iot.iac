include "base" {
  path = find_in_parent_folders("base.hcl")
}

include "kubernetes" {
  path = find_in_parent_folders("kubernetes.hcl")
}

locals {
  k8s_dir = get_parent_terragrunt_dir("kubernetes")
}

dependency "prometheus_stack" {
  config_path = "${local.k8s_dir}/monitoring/prometheus-stack"
}

dependencies {
  paths = [
    "${local.k8s_dir}/storage/rook-ceph/cr"
  ]
}

inputs = {
  prometheus_stack_namespace = dependency.prometheus_stack.outputs.namespace
}
