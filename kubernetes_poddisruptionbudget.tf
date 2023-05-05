resource "kubernetes_pod_disruption_budget_v1" "pdb" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels = {
      k8s-app = var.name
    }
  }
  spec {
    max_unavailable = 1
    selector {
      match_labels = {
        k8s-app = var.name
      }
    }
  }
}
