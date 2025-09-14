resource "google_artifact_registry_repository" "culture_rails" {
  location      = var.region
  project       = var.project_id
  repository_id = "culture-rails"
  description   = "Docker repository for culture-rails application (shared across environments)"
  format        = "DOCKER"
}