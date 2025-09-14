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

module "culture_rails" {
  source = "../../modules/culture-rails"

  project_id   = var.project_id
  region       = var.region
  service_name = "${var.service_name}-prod"
  environment  = "production"

  min_instances = 1
  max_instances = 20
  cpu_limit     = "4"
  memory_limit  = "8Gi"

  # Artifact Registry dependency
  depends_on = [google_artifact_registry_repository.culture_rails]
}