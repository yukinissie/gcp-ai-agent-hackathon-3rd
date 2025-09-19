terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  backend "gcs" {}
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_compute_network" "production" {
  name                    = "culture-production-network"
  auto_create_subnetworks = true
  project                 = var.project_id
}

module "database" {
  source = "../../modules/database"

  project_id      = var.project_id
  region          = var.region
  environment     = "production"
  vpc_network_id  = google_compute_network.production.id

  db_tier                = "db-f1-micro"
  availability_type      = "REGIONAL"
  disk_size             = 20
  disk_autoresize_limit = 100
  deletion_protection   = true
}

module "culture_rails" {
  source = "../../modules/culture-rails"

  project_id   = var.project_id
  region       = var.region
  service_name = "${var.service_name}-prod"
  environment  = "production"

  min_instances = 1
  max_instances = 1
  cpu_limit     = "1"
  memory_limit  = "512Mi"

  # Database configuration
  database_url                    = module.database.database_url
  database_host                   = module.database.database_host
  database_port                   = module.database.database_port
  database_name                   = module.database.database_name
  database_user                   = module.database.database_user
  database_password_secret_name   = module.database.database_password_secret_name

  # Rails configuration
  rails_master_key_secret_name    = "culture-rails-master-key-prod"

  # Dependencies
  depends_on = [
    google_artifact_registry_repository.culture_rails,
    module.database
  ]
}
