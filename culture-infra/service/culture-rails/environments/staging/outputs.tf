output "service_url" {
  description = "The URL of the deployed Cloud Run service"
  value       = module.culture_rails.service_url
}

output "service_name" {
  description = "The name of the Cloud Run service"
  value       = module.culture_rails.service_name
}