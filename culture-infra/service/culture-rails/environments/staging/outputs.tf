output "service_url" {
  description = "The URL of the deployed Cloud Run service"
  value       = module.culture_rails.service_url
}

output "service_name" {
  description = "The name of the Cloud Run service"
  value       = module.culture_rails.service_name
}

output "database_instance_name" {
  description = "The name of the Cloud SQL instance"
  value       = module.database.database_instance_name
}

output "database_instance_connection_name" {
  description = "The connection name of the Cloud SQL instance"
  value       = module.database.database_instance_connection_name
}

output "database_host" {
  description = "The private IP address of the database"
  value       = module.database.database_host
  sensitive   = true
}
