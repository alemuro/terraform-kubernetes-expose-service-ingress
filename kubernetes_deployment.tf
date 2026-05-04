resource "kubernetes_deployment" "deployment" {
  count = local.use_statefulset ? 0 : 1

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

        host_network = var.host_network

        // Host path volumes
        dynamic "volume" {
          for_each = var.paths
          content {
            name = lower("${var.name}-data-${replace(volume.key, "/", "-")}")
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

        // Configmaps
        dynamic "volume" {
          for_each = length(var.configmaps) > 0 ? [1] : []
          content {
            name = "config"
            config_map {
              name = kubernetes_config_map_v1.configmap[0].metadata[0].name
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
          image             = var.image
          image_pull_policy = var.image_pull_policy
          name              = var.name

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
              name       = lower("${var.name}-data-${replace(volume_mount.key, "/", "-")}")
              mount_path = volume_mount.value
            }
          }

          // PVCs volumes
          dynamic "volume_mount" {
            for_each = var.pvcs
            content {
              name       = "${var.name}-data-${lower(volume_mount.value.name)}"
              mount_path = volume_mount.value.path
              sub_path   = volume_mount.value.sub_path
              read_only  = volume_mount.value.read_only
            }
          }

          dynamic "security_context" {
            for_each = length(var.capabilities_add) > 0 || var.privileged ? [1] : []
            content {
              privileged = var.privileged

              dynamic "capabilities" {
                for_each = length(var.capabilities_add) > 0 ? [1] : []
                content {
                  add = var.capabilities_add
                }
              }
            }
          }

          // Configmap
          dynamic "volume_mount" {
            for_each = var.configmaps
            iterator = configmap
            content {
              name       = "config"
              mount_path = configmap.key
              sub_path   = replace(trimprefix(configmap.key, "/"), "/", "-")
              read_only  = true
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

moved {
  from = kubernetes_deployment.deployment
  to   = kubernetes_deployment.deployment[0]
}
