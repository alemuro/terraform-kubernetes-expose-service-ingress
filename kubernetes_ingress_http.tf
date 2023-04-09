resource "kubernetes_ingress_v1" "http" {
  count = (length(var.domains) > 0) ? 1 : 0

  metadata {
    name = "${var.name}-http"
    namespace = var.namespace
    labels = {
      k8s-app = var.name
    }

    annotations = {
      "traefik.ingress.kubernetes.io/router.entrypoints" = "web"
    }
  }

  spec {
    dynamic "rule" {
      for_each = toset(var.domains)
      content {
        host = rule.key
        http {
          path {
            path = "/"
            backend {
              service {
                name = var.name
                port {
                  name = "http"
                }
              }
            }
          }
        }
      }
    }
  }
}
