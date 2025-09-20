# Environment-specific configurations
locals {
  environment_configs = {
    staging = {
      db_tier               = "db-g1-small"
      availability_type     = "ZONAL"
      disk_size            = 20
      deletion_protection   = false
    }
    production = {
      db_tier               = "db-g1-small"
      availability_type     = "REGIONAL"
      disk_size            = 20
      deletion_protection   = true
    }
  }

  # Use environment-specific config or fallback to provided variables
  db_tier               = var.db_tier != null ? var.db_tier : local.environment_configs[var.environment].db_tier
  availability_type     = var.availability_type != null ? var.availability_type : local.environment_configs[var.environment].availability_type
  disk_size            = var.disk_size != null ? var.disk_size : local.environment_configs[var.environment].disk_size
  deletion_protection   = var.deletion_protection != null ? var.deletion_protection : local.environment_configs[var.environment].deletion_protection
}

resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "culture_rails_postgres" {
  name             = "${var.db_name}-${var.environment}-${random_id.db_name_suffix.hex}"
  database_version = var.database_version
  project          = var.project_id
  region           = var.region

  settings {
    tier                        = local.db_tier
    availability_type          = local.availability_type
    disk_type                  = "PD_SSD"
    disk_size                  = local.disk_size
    disk_autoresize           = true
    disk_autoresize_limit     = var.disk_autoresize_limit

    backup_configuration {
      enabled                        = true
      start_time                     = "02:00"
      location                       = var.region
      point_in_time_recovery_enabled = true
      backup_retention_settings {
        retained_backups = 7
        retention_unit   = "COUNT"
      }
    }

    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = var.vpc_network_id
      enable_private_path_for_google_cloud_services = true
      ssl_mode                                       = "ALLOW_UNENCRYPTED_AND_ENCRYPTED"
      allocated_ip_range = google_compute_global_address.private_ip_address.name
    }

    database_flags {
      name  = "log_checkpoints"
      value = "on"
    }

    database_flags {
      name  = "log_connections"
      value = "on"
    }

    database_flags {
      name  = "log_disconnections"
      value = "on"
    }

    maintenance_window {
      day          = 7
      hour         = 3
      update_track = "stable"
    }

    insights_config {
      query_insights_enabled  = true
      record_application_tags = true
      record_client_address   = true
    }
  }

  deletion_protection = local.deletion_protection

  depends_on = [
    google_service_networking_connection.private_vpc_connection
  ]
}

resource "google_compute_global_address" "private_ip_address" {
  project       = var.project_id
  name          = "${var.db_name}-${var.environment}-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = var.vpc_network_id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = var.vpc_network_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "google_sql_database" "culture_rails_database" {
  name     = "${var.database_name}-${var.environment}"
  instance = google_sql_database_instance.culture_rails_postgres.name
  project  = var.project_id
}

resource "random_password" "database_password" {
  length  = 32
  special = true
}

resource "google_sql_user" "database_user" {
  name     = "${var.database_user}-${var.environment}"
  instance = google_sql_database_instance.culture_rails_postgres.name
  password = random_password.database_password.result
  project  = var.project_id
}

resource "google_secret_manager_secret" "database_password" {
  secret_id = "${var.db_name}-${var.environment}-password"
  project   = var.project_id

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "database_password" {
  secret      = google_secret_manager_secret.database_password.id
  secret_data = random_password.database_password.result
}

data "google_compute_default_service_account" "default" {
  project = var.project_id
}

resource "google_secret_manager_secret_iam_member" "database_password_access" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.database_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${data.google_compute_default_service_account.default.email}"
}
