include "base" {
  path = find_in_parent_folders("base.hcl")
}

include "kubernetes" {
  path = find_in_parent_folders("kubernetes.hcl")
}

locals {
  k8s_dir = get_parent_terragrunt_dir("kubernetes")
}

dependency "rook_ceph" {
  config_path = "${local.k8s_dir}/storage/rook-ceph"
}

inputs = {
  rook_ceph_namespace = dependency.rook_ceph.outputs.namespace
}
