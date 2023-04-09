resource "kubernetes_ingress_v1" "https" {
  count = (length(var.domains) > 0) ? 1 : 0

  metadata {
    name      = "${var.name}-https"
    namespace = var.namespace
    labels = {
      k8s-app = var.name
    }

    annotations = {
      "traefik.ingress.kubernetes.io/router.entrypoints"      = "websecure"
      "traefik.ingress.kubernetes.io/router.tls"              = "true"
      "traefik.ingress.kubernetes.io/router.tls.certresolver" = "default"
    }
  }

  spec {
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
