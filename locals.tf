locals {
  // Get a list of unique PVCs to create a single volume block per PVC
  unique_pvcs = distinct([for pvc in var.pvcs : pvc.name])

  pod_additional_ports_uses_host_port = length([for port in var.pod_additional_ports : port if port.host_port != null]) > 0

  // Explicit `statefulset` wins; null keeps the previous automatic rule.
  use_statefulset = coalesce(var.statefulset, var.container_port != null && length(keys(var.paths)) > 0)

  // A single-replica pod holding a host port or a ReadWriteOnce claim cannot roll: the new pod
  // waits for the port or volume the old one still holds, or two copies write the same data.
  // Recreate stops the old pod first. `deployment_strategy` overrides the automatic choice.
  deployment_strategy = coalesce(
    var.deployment_strategy,
    (var.host_port != null || local.pod_additional_ports_uses_host_port || length(var.pvcs) > 0) ? "Recreate" : "RollingUpdate",
  )

  // Probes without an explicit port target the "http" container port, which only exists with container_port.
  probes_need_http_port = anytrue([
    for probe in [var.liveness_probe, var.readiness_probe, var.startup_probe] :
    probe != null && try(probe.http_get.port, probe.tcp_socket.port, null) == null
  ])
}
