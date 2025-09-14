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

data "google_compute_network" "default" {
  name    = "default"
  project = var.project_id
}

module "database" {
  source = "../../modules/database"

  project_id     = var.project_id
  region         = var.region
  environment    = "staging"
  vpc_network_id = data.google_compute_network.default.id

  db_tier               = "db-f1-micro"
  availability_type     = "ZONAL"
  disk_size             = 20
  disk_autoresize_limit = 100
  deletion_protection   = false
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

  # Database configuration
  database_url                  = module.database.database_url
  database_host                 = module.database.database_host
  database_port                 = module.database.database_port
  database_name                 = module.database.database_name
  database_user                 = module.database.database_user
  database_password_secret_name = module.database.database_password_secret_name

  # Dependencies
  depends_on = [module.database]
}