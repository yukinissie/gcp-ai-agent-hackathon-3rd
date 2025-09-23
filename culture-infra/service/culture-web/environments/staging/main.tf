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

  min_instances = 1
  max_instances = 1
  cpu_limit     = "1"
  memory_limit  = "512Mi"

  # Load balancer configuration for staging (optional)
  # Ingress controls access: "all" for direct access, "internal-and-cloud-load-balancing" for LB
  ingress = var.enable_load_balancer ? "internal-and-cloud-load-balancing" : "all"

  rails_api_host_secret_name = "${var.service_name}-rails-api-host-staging"
  auth_secret_name           = "${var.service_name}-auth-secret-staging"
  google_generative_ai_api_key_secret_name = "${var.service_name}-google-generative-ai-api-key-staging"
  database_url_secret_name   = "${var.service_name}-database-url-staging"
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
