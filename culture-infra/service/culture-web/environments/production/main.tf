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
  service_name = "${var.service_name}-prod"
  environment  = "production"

  min_instances = 1
  max_instances = 1
  cpu_limit     = "1"
  memory_limit  = "512Mi"

  # Load balancer configuration - ingress controls access, not IAM
  ingress = "internal-and-cloud-load-balancing"

  rails_api_host_secret_name = "${var.service_name}-rails-api-host-production"

  # Artifact Registry dependency
  depends_on = [google_artifact_registry_repository.culture_web]
}

# Load balancer with CDN
module "load_balancer" {
  source = "../../modules/load-balancer"

  project_id   = var.project_id
  region       = var.region
  service_name = "${var.service_name}-prod"

  cloud_run_service_name = module.culture_web.service_name
  domains                = var.domains
  enable_cdn             = var.enable_cdn
  redirect_http_to_https = var.redirect_http_to_https

  depends_on = [module.culture_web]
}
