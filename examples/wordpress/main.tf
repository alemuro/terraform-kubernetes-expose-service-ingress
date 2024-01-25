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