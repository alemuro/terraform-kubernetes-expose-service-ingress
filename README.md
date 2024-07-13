<!-- BEGIN_TF_DOCS -->
# Terraform Module for exposing a service through an Ingress

This module provides an easy way to deploy pods and to expose them to the Internet by configuring the proper service and ingresses.
It has been designed to allow pods with only one container. See examples below.

This module has been designed to work on a K3S cluster with Traefik and files stored locally.

It supports cert-manager for creating Let's Encrypt certificates. Take into consideration
that a ClusterIssuer with name "letsencrypt" should be created before using this module.

### Supported Ingresses

Currently there is only one ingress supported. Feel free to open PR's to add support for others:

* Traefik

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_image"></a> [image](#input\_image) | Image name and tag to deploy. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name used to identify deployed container and all related resources. | `string` | n/a | yes |
| <a name="input_allow_from"></a> [allow\_from](#input\_allow\_from) | List of services to allow traffic from | `list(string)` | `[]` | no |
| <a name="input_annotations"></a> [annotations](#input\_annotations) | Annotations added to some components. Only ingress and service supported at the moment. | <pre>object({<br>    ingress = optional(map(string), {})<br>    service = optional(map(string), {})<br>  })</pre> | <pre>{<br>  "ingress": {},<br>  "service": {}<br>}</pre> | no |
| <a name="input_args"></a> [args](#input\_args) | List of arguments to pass to the container | `list(string)` | `[]` | no |
| <a name="input_capabilities_add"></a> [capabilities\_add](#input\_capabilities\_add) | List of capabilities to add to the container. | `list(string)` | `[]` | no |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | Container port where to send to requests to. If doesn't exist, service won't be created | `string` | `null` | no |
| <a name="input_domains"></a> [domains](#input\_domains) | List of domains that should be configured to route traffic from. | `list(string)` | `[]` | no |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | Map with environment variables injected to the containers. | `map(any)` | `{}` | no |
| <a name="input_host_port"></a> [host\_port](#input\_host\_port) | Host port where to send to requests to. | `string` | `null` | no |
| <a name="input_http"></a> [http](#input\_http) | Whether to create an ingress for HTTP traffic. | `bool` | `true` | no |
| <a name="input_https"></a> [https](#input\_https) | Whether to create an ingress for HTTPS traffic. | `bool` | `true` | no |
| <a name="input_image_pull_secret"></a> [image\_pull\_secret](#input\_image\_pull\_secret) | Kubernetes secret storing registry credentials. | `string` | `""` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Kubernetes namespace where resources must be created. | `string` | `"default"` | no |
| <a name="input_node_selector"></a> [node\_selector](#input\_node\_selector) | Node selector to use when deploying the container. | `map(string)` | `null` | no |
| <a name="input_paths"></a> [paths](#input\_paths) | Object mapping local paths to container paths | `map(any)` | `{}` | no |
| <a name="input_pod_additional_ports"></a> [pod\_additional\_ports](#input\_pod\_additional\_ports) | List of additional ports to expose on the pod. | <pre>list(object({<br>    name           = string<br>    container_port = string<br>    host_port      = string<br>    protocol       = string<br>  }))</pre> | `[]` | no |
| <a name="input_pvcs"></a> [pvcs](#input\_pvcs) | Object that contains the list of PVCs to mount in the container | <pre>list(object({<br>    name      = string<br>    path      = string<br>    sub_path  = optional(string, "")<br>    read_only = optional(bool, false)<br>  }))</pre> | `[]` | no |
| <a name="input_resources"></a> [resources](#input\_resources) | Map with resources limits and requests. | <pre>object({<br>    limits   = map(string)<br>    requests = map(string)<br>  })</pre> | <pre>{<br>  "limits": {},<br>  "requests": {}<br>}</pre> | no |
| <a name="input_service_port"></a> [service\_port](#input\_service\_port) | Port configured on the service side to receive requests (routed to the container port). | `string` | `"80"` | no |
| <a name="input_supplemental_groups"></a> [supplemental\_groups](#input\_supplemental\_groups) | List of supplemental groups to add to the container. | `list(string)` | `[]` | no |

## Outputs

No outputs.

## Examples

On the following example we are deploying Wordpress stack with:
* 1 x Wordpress: All data is stored on a local folder.
* 1 x MariaDB (MySQL) database. All data is stored on a local folder.
* 1 x PHPMyAdmin

```hcl
module "wordpress" {
  source  = "alemuro/expose-service-ingress/kubernetes"
  version = "1.1.0"

  name           = "wordpress-example"
  image          = "wordpress:5"
  domains        = ["wordpress-example.com", "wordpress.example.com"]
  container_port = "80"
  paths = {
    "/opt/k3s/wordpress-example" = "/var/www/html"
  }
  pvcs = {
    name = "pvc-name" 
    path = "/tmp/pvc-example"
  }
  environment_variables = {
    WORDPRESS_DB_HOST     = "database"
    WORDPRESS_DB_USER     = "wordpress-example"
    WORDPRESS_DB_PASSWORD = "r@ndomPa$$w0rd!"
    WORDPRESS_DB_NAME     = "wordpress-example"
  }
}

module "database" {
  source  = "alemuro/expose-service-ingress/kubernetes"
  version = "1.1.0"

  name           = "database"
  image          = "mariadb"
  container_port = "3306"
  service_port   = "3306"
  paths = {
    "/opt/k3s/database" = "/var/lib/mysql"
  }
  environment_variables = {
    MYSQL_ALLOW_EMPTY_PASSWORD = "true"
  }
}

module "phpmyadmin" {
  source  = "alemuro/expose-service-ingress/kubernetes"
  version = "1.1.0"

  name           = "phpmyadmin"
  image          = "phpmyadmin"
  domains        = ["phpmyadmin.wordpress-example.com"]
  container_port = "80"

  environment_variables = {
    PMA_HOST            = "database"
    PMA_PORT            = 3306
    MYSQL_ROOT_PASSWORD = "r@ndomPa$$w0rd!"
  }
}
```
<!-- END_TF_DOCS -->