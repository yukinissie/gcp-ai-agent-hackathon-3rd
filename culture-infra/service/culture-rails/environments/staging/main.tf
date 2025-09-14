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
  service_name = "${var.service_name}-staging"
  environment  = "staging"

  min_instances = 0
  max_instances = 5
  cpu_limit     = "2"
  memory_limit  = "4Gi"
}