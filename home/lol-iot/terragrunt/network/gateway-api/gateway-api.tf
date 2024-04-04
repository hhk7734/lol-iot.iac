resource "kubernetes_manifest" "gatewayclass" {
  manifest = {
    for k, v in yamldecode(
      file("${path.module}/gateway.networking.k8s.io_gatewayclasses.yaml")
    ) :
    k => v if !contains(["status"], k)
  }
}

resource "kubernetes_manifest" "gateway" {
  manifest = {
    for k, v in yamldecode(
      file("${path.module}/gateway.networking.k8s.io_gateways.yaml")
    ) :
    k => v if !contains(["status"], k)
  }
}

resource "kubernetes_manifest" "httproute" {
  manifest = {
    for k, v in yamldecode(
      file("${path.module}/gateway.networking.k8s.io_httproutes.yaml")
    ) :
    k => v if !contains(["status"], k)
  }
}

resource "kubernetes_manifest" "referencegrant" {
  manifest = {
    for k, v in yamldecode(
      file("${path.module}/gateway.networking.k8s.io_referencegrants.yaml")
    ) :
    k => v if !contains(["status"], k)
  }
}

resource "kubernetes_manifest" "grpcroute" {
  manifest = {
    for k, v in yamldecode(
      file("${path.module}/gateway.networking.k8s.io_grpcroutes.yaml")
    ) :
    k => v if !contains(["status"], k)
  }
}

resource "kubernetes_manifest" "tlsroute" {
  manifest = {
    for k, v in yamldecode(
      file("${path.module}/gateway.networking.k8s.io_tlsroutes.yaml")
    ) :
    k => v if !contains(["status"], k)
  }
}
