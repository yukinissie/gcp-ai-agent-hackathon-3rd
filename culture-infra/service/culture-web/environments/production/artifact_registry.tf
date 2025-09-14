resource "google_artifact_registry_repository" "culture_web" {
  location      = var.region
  project       = var.project_id
  repository_id = "culture-web"
  description   = "Docker repository for culture-web application (shared across environments)"
  format        = "DOCKER"
}
