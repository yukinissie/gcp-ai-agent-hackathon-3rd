resource "google_project_service" "required_apis" {
  for_each = toset([
    "run.googleapis.com",
    "cloudbuild.googleapis.com",
    "artifactregistry.googleapis.com"
  ])

  project = var.project_id
  service = each.value

  disable_dependent_services = false
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

        resources {
          limits = {
            cpu    = var.cpu_limit
            memory = var.memory_limit
          }
        }

        startup_probe {
          http_get {
            path = "/health"
            port = 3000
          }
          initial_delay_seconds = 15
          timeout_seconds       = 10
          period_seconds        = 10
          failure_threshold     = 3
        }

        liveness_probe {
          http_get {
            path = "/health"
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
