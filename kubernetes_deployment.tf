locals {
  // Get a list of unique PVCs to create a single volume block per PVC
  unique_pvcs = distinct([for pvc in var.pvcs : pvc.name])

  pod_additional_ports_uses_host_port = length([for port in var.pod_additional_ports : port if port.host_port != null]) > 0
}

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
      for_each = (var.host_port != null || local.pod_additional_ports_uses_host_port) ? [1] : []
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

        // Host path volumes
        dynamic "volume" {
          for_each = var.paths
          content {
            name = "${var.name}-data-${replace(volume.key, "/", "-")}"
            host_path {
              path = volume.key
            }
          }
        }

        // PVCs volumes
        dynamic "volume" {
          for_each = local.unique_pvcs
          content {
            name = "${var.name}-data-${volume.value}"
            persistent_volume_claim {
              claim_name = volume.value
              read_only  = false
            }
          }
        }

        dynamic "image_pull_secrets" {
          for_each = var.image_pull_secret != "" ? [1] : []
          content {
            name = var.image_pull_secret
          }
        }

        dynamic "security_context" {
          for_each = length(var.supplemental_groups) > 0 ? [1] : []
          content {
            supplemental_groups = var.supplemental_groups
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

          dynamic "port" {
            for_each = var.container_port != null ? [1] : []
            content {
              container_port = var.container_port
              name           = "http"
              protocol       = "TCP"
              host_port      = var.host_port
            }
          }

          dynamic "port" {
            for_each = var.pod_additional_ports
            content {
              container_port = port.value.container_port
              name           = port.value.name
              protocol       = port.value.protocol
              host_port      = port.value.host_port
            }
          }

          // Args
          args = var.args

          // Host path volumes
          dynamic "volume_mount" {
            for_each = var.paths
            content {
              name       = "${var.name}-data-${replace(volume_mount.key, "/", "-")}"
              mount_path = volume_mount.value
            }
          }

          // PVCs volumes
          dynamic "volume_mount" {
            for_each = var.pvcs
            content {
              name       = "${var.name}-data-${volume_mount.value.name}"
              mount_path = volume_mount.value.path
              sub_path   = volume_mount.value.sub_path
              read_only  = volume_mount.value.read_only
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
