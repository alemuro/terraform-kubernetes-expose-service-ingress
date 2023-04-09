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
          }

          dynamic "volume_mount" {
            for_each = var.paths
            content {
              name       = "${var.name}-data-${replace(volume_mount.key, "/", "-")}"
              mount_path = volume_mount.value
            }
          }
        }
      }
    }
  }
}
