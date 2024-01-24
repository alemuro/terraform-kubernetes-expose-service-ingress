resource "kubernetes_service" "service" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels = {
      k8s-app = var.name
    }

    annotations = var.annotations["service"]
  }
  spec {
    selector = {
      k8s-app = var.name
    }

    port {
      name        = "http"
      port        = var.service_port
      target_port = "http"
    }

    type = "ClusterIP"
  }
}
