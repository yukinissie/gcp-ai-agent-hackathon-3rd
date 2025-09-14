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