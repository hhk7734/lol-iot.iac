# Generated by Terragrunt. Sig: nIlQXj57tbuaRZEa
provider "kubernetes" {
  config_paths   = ["~/.kube/config","~/.kube/lol-iot.yaml"]
  config_context = "arn:lol-iot:k8s:home:hhk7734:cluster/lol-iot/user/admin"
}

provider "helm" {
  kubernetes {
    config_paths   = ["~/.kube/config","~/.kube/lol-iot.yaml"]
    config_context = "arn:lol-iot:k8s:home:hhk7734:cluster/lol-iot/user/admin"
  }
}
