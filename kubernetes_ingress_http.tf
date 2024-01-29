resource "kubernetes_ingress_v1" "http" {
  count = (length(var.domains) > 0) && var.http ? 1 : 0

  metadata {
    name      = "${var.name}-http"
    namespace = var.namespace
    labels = {
      k8s-app = var.name
    }

    annotations = merge(var.annotations["ingress"], {
      "traefik.ingress.kubernetes.io/router.entrypoints" = "web"
      "cert-manager.io/issuer"                           = "letsencrypt"
    })
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
