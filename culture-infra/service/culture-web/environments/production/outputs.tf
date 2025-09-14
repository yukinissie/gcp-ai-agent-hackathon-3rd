output "service_url" {
  description = "URL of the Cloud Run service"
  value       = module.culture_web.service_url
}

output "service_name" {
  description = "Name of the Cloud Run service"
  value       = module.culture_web.service_name
}

output "docker_image_url" {
  description = "Docker image URL for the application"
  value       = module.culture_web.docker_image_url
}

output "artifact_registry_repository" {
  description = "Artifact Registry repository (shared across environments)"
  value       = google_artifact_registry_repository.culture_web.name
}

output "artifact_registry_url" {
  description = "Artifact Registry repository URL"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/culture-web"
}