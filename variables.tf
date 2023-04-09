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

variable "domains" {
  type        = list(string)
  description = "List of domains that should be configured to route traffic from."
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
  description = "Container port where to send to requests to."
  default     = "80"
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
