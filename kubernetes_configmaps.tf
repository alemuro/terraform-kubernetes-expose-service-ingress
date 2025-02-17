resource "kubernetes_config_map_v1" "configmap" {
  count = length(var.configmaps) > 0 ? 1 : 0

  metadata {
    name = var.name
    namespace = var.namespace
    labels = {
      k8s-app = var.name
    }
  }

  data = { for key, value in var.configmaps : replace(trimprefix(key, "/"), "/", "-") => value }
}
