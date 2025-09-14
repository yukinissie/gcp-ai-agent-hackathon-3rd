output "service_url" {
  description = "URL of the Cloud Run service"
  value       = google_cloud_run_service.culture_web.status[0].url
}

output "service_name" {
  description = "Name of the Cloud Run service"
  value       = google_cloud_run_service.culture_web.name
}

output "service_location" {
  description = "Location of the Cloud Run service"
  value       = google_cloud_run_service.culture_web.location
}

output "artifact_registry_repository" {
  description = "Name of the Artifact Registry repository"
  value       = data.google_artifact_registry_repository.culture_web.name
}

output "docker_image_url" {
  description = "Docker image URL for the application"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/culture-web/culture-web"
}