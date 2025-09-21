# Artifact Registry is managed externally (in production environment)
data "google_artifact_registry_repository" "culture_web" {
  location      = var.region
  project       = var.project_id
  repository_id = "culture-web"
}


data "google_secret_manager_secret" "rails_api_host" {
  secret_id = var.rails_api_host_secret_name
  project   = var.project_id
}

data "google_secret_manager_secret" "auth_secret" {
  secret_id = var.auth_secret_name
  project   = var.project_id
}

resource "google_cloud_run_service" "culture_web" {
  name     = var.service_name
  location = var.region
  project  = var.project_id

  metadata {
    annotations = {
      "run.googleapis.com/ingress" = var.ingress
    }
  }

  template {
    spec {
      containers {
        image = "${var.region}-docker.pkg.dev/${var.project_id}/culture-web/culture-web:latest"

        ports {
          container_port = 3000
        }

        env {
          name  = "NODE_ENV"
          value = "production"
        }

        # Add environment variables for better caching with CDN
        env {
          name  = "NEXT_PUBLIC_CDN_ENABLED"
          value = "true"
        }

        env {
          name  = "RAILS_API_HOST"
          value_from {
            secret_key_ref {
              name = var.rails_api_host_secret_name
              key  = "latest"
            }
          }
        }

        env {
          name = "AUTH_SECRET"
          value_from {
            secret_key_ref {
              name = var.auth_secret_name
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
            path = "/"
            port = 3000
          }
          initial_delay_seconds = 10
          timeout_seconds       = 10
          period_seconds        = 10
          failure_threshold     = 3
        }

        liveness_probe {
          http_get {
            path = "/"
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
    data.google_artifact_registry_repository.culture_web
  ]
}

# IAM for Cloud Run service
# When using a load balancer, we need to allow "allUsers" to invoke the service
# but the ingress annotation will restrict access to only load balancer traffic
resource "google_cloud_run_service_iam_binding" "invoker" {
  location = google_cloud_run_service.culture_web.location
  project  = google_cloud_run_service.culture_web.project
  service  = google_cloud_run_service.culture_web.name
  role     = "roles/run.invoker"
  members  = ["allUsers"]
}

# IAM binding for Secret Manager access
data "google_project" "project" {
  project_id = var.project_id
}

resource "google_secret_manager_secret_iam_binding" "rails_api_host_access" {
  project   = var.project_id
  secret_id = data.google_secret_manager_secret.rails_api_host.secret_id
  role      = "roles/secretmanager.secretAccessor"
  members = [
    "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com",
  ]
}

resource "google_secret_manager_secret_iam_binding" "auth_secret_access" {
  project   = var.project_id
  secret_id = var.auth_secret_name
  role      = "roles/secretmanager.secretAccessor"
  members = [
    "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com",
  ]
}
