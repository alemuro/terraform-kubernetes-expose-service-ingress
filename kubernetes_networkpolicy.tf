data "kubernetes_all_namespaces" "allns" {}

locals {
  allow_from_ns       = setintersection(var.allow_from, data.kubernetes_all_namespaces.allns.namespaces)
  allow_from_ips      = [for from in var.allow_from : from if(can(cidrhost(from, 0)))]
  allow_from_services = setsubtract(setsubtract(var.allow_from, local.allow_from_ns), local.allow_from_ips)
}

resource "kubernetes_network_policy_v1" "policy" {
  count = length(var.allow_from) > 0 ? 1 : 0

  metadata {
    name      = "${var.name}-allow"
    namespace = var.namespace
  }

  spec {
    pod_selector {
      match_labels = {
        "k8s-app" = var.name
      }
    }

    ingress {
      // Services
      dynamic "from" {
        for_each = local.allow_from_services
        content {
          pod_selector {
            match_labels = {
              "k8s-app" = from.value
            }
          }
        }
      }

      // Namespaces
      dynamic "from" {
        for_each = local.allow_from_ns
        content {
          namespace_selector {
            match_labels = {
              "kubernetes.io/metadata.name" = from.value
            }
          }
        }
      }

      // IPs
      dynamic "from" {
        for_each = local.allow_from_ips
        content {
          ip_block {
            cidr = from.value
          }
        }
      }
    }

    policy_types = ["Ingress"]
  }
}
