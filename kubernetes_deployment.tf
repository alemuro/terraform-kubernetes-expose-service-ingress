resource "kubernetes_deployment" "deployment" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels = {
      k8s-app = var.name
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        k8s-app = var.name
      }
    }

    // When using host_port mode, recreate container
    dynamic "strategy" {
      for_each = var.host_port != null ? [1] : []
      content {
        type = "Recreate"
      }
    }

    template {
      metadata {
        labels = {
          k8s-app = var.name
        }
      }

      spec {

        node_selector = var.node_selector

        dynamic "volume" {
          for_each = var.paths
          content {
            name = "${var.name}-data-${replace(volume.key, "/", "-")}"
            host_path {
              path = volume.key
            }
          }
        }

        container {
          image = var.image
          name  = var.name

          dynamic "env" {
            for_each = var.environment_variables
            content {
              name  = env.key
              value = env.value
            }
          }

          port {
            container_port = var.container_port
            name           = "http"
            protocol       = "TCP"
            host_port      = var.host_port
          }

          dynamic "volume_mount" {
            for_each = var.paths
            content {
              name       = "${var.name}-data-${replace(volume_mount.key, "/", "-")}"
              mount_path = volume_mount.value
            }
          }

          dynamic "security_context" {
            for_each = length(var.capabilities_add) > 0 ? [1] : []
            content {
              capabilities {
                add = var.capabilities_add
              }
            }
          }

          resources {
            limits   = var.resources.limits
            requests = var.resources.requests
          }
        }
      }
    }
  }
}
