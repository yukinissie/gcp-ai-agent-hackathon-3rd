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

# Load Balancer outputs
output "load_balancer_ip" {
  description = "The external IP address of the load balancer"
  value       = module.load_balancer.lb_ip_address
}

output "load_balancer_url" {
  description = "The URL to access the application via load balancer"
  value       = module.load_balancer.load_balancer_url
}
