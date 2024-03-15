include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  root_dir = get_parent_terragrunt_dir("root")
}

dependencies {
  paths = [
    "${local.root_dir}/monitoring/prometheus",
    "${local.root_dir}/storage/rook-ceph"
  ]
}

retryable_errors = [
  "Failed to determine GroupVersionResource for manifest"
]
retry_sleep_interval_sec = 30
