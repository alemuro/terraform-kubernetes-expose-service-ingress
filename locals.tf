locals {
  // Get a list of unique PVCs to create a single volume block per PVC
  unique_pvcs = distinct([for pvc in var.pvcs : pvc.name])

  pod_additional_ports_uses_host_port = length([for port in var.pod_additional_ports : port if port.host_port != null]) > 0

  use_statefulset = var.container_port != null && length(keys(var.paths)) > 0
}