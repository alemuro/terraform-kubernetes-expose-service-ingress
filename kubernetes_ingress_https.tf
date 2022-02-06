resource "kubernetes_ingress" "https" {
  count = (length(var.domains) > 0) ? 1 : 0

  metadata {
    name = "${var.name}-https"

    annotations = {
      "traefik.ingress.kubernetes.io/router.entrypoints"      = "websecure"
      "traefik.ingress.kubernetes.io/router.tls"              = "true"
      "traefik.ingress.kubernetes.io/router.tls.certresolver" = "default"
    }
  }

  spec {
    backend {
      service_name = var.name
      service_port = "http"
    }

    tls {
      hosts = var.domains
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
