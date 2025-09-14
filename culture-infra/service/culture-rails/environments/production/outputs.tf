output "service_url" {
  description = "The URL of the deployed Cloud Run service"
  value       = module.culture_rails.service_url
}

output "service_name" {
  description = "The name of the Cloud Run service"
  value       = module.culture_rails.service_name
}

output "artifact_registry_repository_name" {
  description = "The Artifact Registry repository name"
  value       = google_artifact_registry_repository.culture_rails.name
}