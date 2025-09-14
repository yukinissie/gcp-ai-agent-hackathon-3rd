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

# Load balancer outputs (conditional based on whether LB is enabled)
output "load_balancer_ip" {
  description = "External IP address of the load balancer (if enabled)"
  value       = var.enable_load_balancer ? module.load_balancer[0].load_balancer_ip : null
}

output "load_balancer_url" {
  description = "URL of the load balancer (if enabled, otherwise Cloud Run URL)"
  value       = var.enable_load_balancer ? module.load_balancer[0].load_balancer_url : module.culture_web.service_url
}

output "ssl_certificate_name" {
  description = "Name of the SSL certificate (if load balancer and domains are configured)"
  value       = var.enable_load_balancer ? module.load_balancer[0].ssl_certificate_name : null
}

output "backend_service_name" {
  description = "Name of the load balancer backend service (if enabled)"
  value       = var.enable_load_balancer ? module.load_balancer[0].backend_service_name : null
}