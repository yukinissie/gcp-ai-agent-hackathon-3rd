output "service_url" {
  description = "The URL of the deployed Cloud Run service"
  value       = google_cloud_run_service.culture_rails.status[0].url
}

output "service_name" {
  description = "The name of the Cloud Run service"
  value       = google_cloud_run_service.culture_rails.name
}

output "service_location" {
  description = "The location of the Cloud Run service"
  value       = google_cloud_run_service.culture_rails.location
}

output "artifact_registry_repository" {
  description = "The Artifact Registry repository details"
  value = {
    name     = data.google_artifact_registry_repository.culture_rails.name
    location = data.google_artifact_registry_repository.culture_rails.location
    format   = data.google_artifact_registry_repository.culture_rails.format
  }
}