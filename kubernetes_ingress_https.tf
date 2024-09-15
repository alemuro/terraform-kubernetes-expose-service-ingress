resource "kubernetes_ingress_v1" "https" {
  count = (length(var.domains) > 0) && var.https ? 1 : 0

  metadata {
    name      = "${var.name}-https"
    namespace = var.namespace
    labels = {
      k8s-app = var.name
    }

    annotations = merge(var.annotations["ingress"], {
      "traefik.ingress.kubernetes.io/router.entrypoints"      = "web,websecure"
      "traefik.ingress.kubernetes.io/router.tls"              = "true"
      "traefik.ingress.kubernetes.io/router.tls.certresolver" = "default"
      "cert-manager.io/cluster-issuer"                        = "letsencrypt"
    })
  }

  spec {
    tls {
      hosts       = var.domains
      secret_name = "tls-${var.name}-https"
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

# Expose services through Cloudflare Tunnel with Argo Tunnel
resource "kubernetes_ingress_v1" "cloudflare" {
  count = (length(var.cloudflare_domains) > 0) && var.https ? 1 : 0

  metadata {
    name      = "${var.name}-cloudflare"
    namespace = var.namespace
    labels = {
      k8s-app = var.name
    }

    annotations = merge(var.annotations["ingress"], {
      "traefik.ingress.kubernetes.io/router.entrypoints"      = "web,websecure"
      "traefik.ingress.kubernetes.io/router.tls"              = "true"
      "traefik.ingress.kubernetes.io/router.tls.certresolver" = "default"
      "cert-manager.io/cluster-issuer"                        = "letsencrypt"
    })
  }

  spec {
    ingress_class_name = "cloudflare-tunnel"

    tls {
      hosts       = var.cloudflare_domains
      secret_name = "tls-${var.name}-https"
    }

    dynamic "rule" {
      for_each = toset(var.cloudflare_domains)
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
