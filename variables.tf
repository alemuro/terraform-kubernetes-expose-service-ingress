variable "name" {
  type        = string
  description = "Name used to identify deployed container and all related resources."
}
variable "image" {
  type        = string
  description = "Image name and tag to deploy."
}
variable "paths" {
  type        = map(any)
  description = "Object mapping local paths to container paths"
  default     = {}
}
variable "pvcs" {
  type = list(object({
    name      = string
    path      = string
    sub_path  = optional(string, "")
    read_only = optional(bool, false)
  }))
  description = "Object that contains the list of PVCs to mount in the container"
  default     = []
}
variable "domains" {
  type        = list(string)
  description = "List of domains that should be configured to route traffic from."
  default     = []
}
variable "cloudflare_domains" {
  type        = list(string)
  description = "List of domains that should be exposed through Cloudflare Tunnel. Requires the ingress class 'cloudflare-tunnel' to be configured."
  default     = []
}
variable "namespace" {
  type        = string
  description = "Kubernetes namespace where resources must be created."
  default     = "default"
}
variable "node_selector" {
  type        = map(string)
  description = "Node selector to use when deploying the container."
  default     = null
}
variable "container_port" {
  type        = string
  description = "Container port where to send to requests to. If doesn't exist, service won't be created"
  default     = null
}
variable "service_port" {
  type        = string
  description = "Port configured on the service side to receive requests (routed to the container port)."
  default     = "80"
}
variable "environment_variables" {
  type        = map(any)
  description = "Map with environment variables injected to the containers."
  default     = {}
}
variable "resources" {
  type = object({
    limits   = map(string)
    requests = map(string)
  })
  description = "Map with resources limits and requests."
  default = {
    limits   = {}
    requests = {}
  }
}
variable "capabilities_add" {
  type        = list(string)
  description = "List of capabilities to add to the container."
  default     = []
}
variable "supplemental_groups" {
  type        = list(string)
  description = "List of supplemental groups to add to the container."
  default     = []
}
variable "host_port" {
  type        = string
  description = "Host port where to send to requests to."
  default     = null
}
variable "pod_additional_ports" {
  type = list(object({
    name           = string
    container_port = string
    host_port      = string
    protocol       = string
  }))
  description = "List of additional ports to expose on the pod."
  default     = []
}
variable "image_pull_secret" {
  type        = string
  description = "Kubernetes secret storing registry credentials."
  default     = ""
}

variable "annotations" {
  type = object({
    ingress = optional(map(string), {})
    service = optional(map(string), {})
  })
  description = "Annotations added to some components. Only ingress and service supported at the moment."
  default = {
    ingress = {}
    service = {}
  }
}

variable "http" {
  type        = bool
  description = "Whether to create an ingress for HTTP traffic."
  default     = true
}

variable "https" {
  type        = bool
  description = "Whether to create an ingress for HTTPS traffic."
  default     = true
}

variable "allow_from" {
  type        = list(string)
  description = "List of services to allow traffic from"
  default     = []
}
variable "args" {
  type        = list(string)
  description = "List of arguments to pass to the container"
  default     = []
}

variable "privileged" {
  type        = bool
  description = "Whether to run the container in privileged mode"
  default     = false
}

variable "configmaps" {
  type = map(string)
  description = <<-EOF
    Map with configmaps to mount in the container, where the key is the
    path where it should be mounted and the value is the content
  EOF
  default = {}
}