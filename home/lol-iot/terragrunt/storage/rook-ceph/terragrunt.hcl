include "base" {
  path = find_in_parent_folders("base.hcl")
}

include "kubernetes" {
  path = find_in_parent_folders("kubernetes.hcl")
}
