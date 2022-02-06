resource "kubernetes_ingress" "http" {
  count = (length(var.domains) > 0) ? 1 : 0

  metadata {
    name = "${var.name}-http"

    annotations = {
      "traefik.ingress.kubernetes.io/router.entrypoints" = "web"
    }
  }

  spec {
    backend {
      service_name = var.name
      service_port = "http"
    }

    dynamic "rule" {
      for_each = toset(var.domains)
      content {
        host = rule.key
        http {
          path {
            path = "/"
            backend {
              service_name = var.name
              service_port = "http"
            }
          }
        }
      }
    }
  }
}
