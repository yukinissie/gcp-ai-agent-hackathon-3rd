resource "google_project_service" "required_apis" {
  for_each = toset([
    "run.googleapis.com",
    "cloudbuild.googleapis.com",
    "artifactregistry.googleapis.com",
    "secretmanager.googleapis.com"
  ])

  project = var.project_id
  service = each.value

  disable_dependent_services = false
}

# Rails master key secret (existing, created per environment)
data "google_secret_manager_secret" "rails_master_key" {
  secret_id = var.rails_master_key_secret_name
  project   = var.project_id
}

# Artifact Registry is managed externally (in production environment)
data "google_artifact_registry_repository" "culture_rails" {
  location      = var.region
  project       = var.project_id
  repository_id = "culture-rails"
}

resource "google_cloud_run_service" "culture_rails" {
  name     = var.service_name
  location = var.region
  project  = var.project_id

  template {
    spec {
      containers {
        image = "${var.region}-docker.pkg.dev/${var.project_id}/culture-rails/culture-rails:latest"

        ports {
          container_port = 3000
        }

        env {
          name  = "RAILS_ENV"
          value = "production"
        }

        env {
          name  = "RACK_ENV"
          value = "production"
        }

        env {
          name  = "DATABASE_HOST"
          value = var.database_host
        }

        env {
          name  = "DATABASE_USER"
          value = var.database_user
        }

        env {
          name = "DATABASE_PASSWORD"
          value_from {
            secret_key_ref {
              name = var.database_password_secret_name
              key  = "latest"
            }
          }
        }

        env {
          name = "RAILS_MASTER_KEY"
          value_from {
            secret_key_ref {
              name = var.rails_master_key_secret_name
              key  = "latest"
            }
          }
        }

        resources {
          limits = {
            cpu    = var.cpu_limit
            memory = var.memory_limit
          }
        }

        startup_probe {
          http_get {
            path = "/up"
            port = 3000
          }
          initial_delay_seconds = 15
          timeout_seconds       = 10
          period_seconds        = 10
          failure_threshold     = 3
        }

        liveness_probe {
          http_get {
            path = "/up"
            port = 3000
          }
          initial_delay_seconds = 30
          timeout_seconds       = 5
          period_seconds        = 30
          failure_threshold     = 3
        }
      }

      timeout_seconds = 300
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale"         = tostring(var.min_instances)
        "autoscaling.knative.dev/maxScale"         = tostring(var.max_instances)
        "run.googleapis.com/cpu-throttling"        = "false"
        "run.googleapis.com/execution-environment" = "gen2"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [
    google_project_service.required_apis,
    data.google_artifact_registry_repository.culture_rails
  ]
}

resource "google_cloud_run_service_iam_binding" "public_access" {
  location = google_cloud_run_service.culture_rails.location
  project  = google_cloud_run_service.culture_rails.project
  service  = google_cloud_run_service.culture_rails.name
  role     = "roles/run.invoker"
  members  = ["allUsers"]
}

# IAM binding for Secret Manager access
data "google_project" "project" {
  project_id = var.project_id
}

resource "google_secret_manager_secret_iam_binding" "rails_master_key_access" {
  project   = var.project_id
  secret_id = data.google_secret_manager_secret.rails_master_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  members = [
    "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com",
  ]
}
