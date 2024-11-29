output "namespace" {
  value = kubernetes_namespace.prometheus_stack.metadata[0].name
}
