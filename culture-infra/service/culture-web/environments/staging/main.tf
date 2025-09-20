terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  backend "gcs" {}
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "culture_web" {
  source = "../../modules/culture-web"

  project_id   = var.project_id
  region       = var.region
  service_name = "${var.service_name}-staging"
  environment  = "staging"

  min_instances = 0
  max_instances = 5
  cpu_limit     = "2"
  memory_limit  = "2Gi"

  # Load balancer configuration for staging (optional)
  # Ingress controls access: "all" for direct access, "internal-and-cloud-load-balancing" for LB
  ingress = var.enable_load_balancer ? "internal-and-cloud-load-balancing" : "all"

  rails_api_host_secret_name = "${var.service_name}-rails-api-host-staging"
}

# Optional load balancer with CDN for staging
module "load_balancer" {
  count  = var.enable_load_balancer ? 1 : 0
  source = "../../modules/load-balancer"

  project_id   = var.project_id
  region       = var.region
  service_name = "${var.service_name}-staging"

  cloud_run_service_name = module.culture_web.service_name
  domains                = var.domains
  enable_cdn             = var.enable_cdn
  redirect_http_to_https = var.redirect_http_to_https

  depends_on = [module.culture_web]
}
