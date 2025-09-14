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

# Load balancer outputs
output "load_balancer_ip" {
  description = "External IP address of the load balancer"
  value       = module.load_balancer.load_balancer_ip
}

output "load_balancer_url" {
  description = "URL of the load balancer (primary access point)"
  value       = module.load_balancer.load_balancer_url
}

output "ssl_certificate_name" {
  description = "Name of the SSL certificate (if domains are configured)"
  value       = module.load_balancer.ssl_certificate_name
}

output "backend_service_name" {
  description = "Name of the load balancer backend service"
  value       = module.load_balancer.backend_service_name
}

# DNS Configuration Instructions
output "dns_configuration" {
  description = "DNS configuration instructions for the domains"
  value = length(var.domains) > 0 ? {
    instruction = "Configure your DNS records to point to the load balancer IP"
    ip_address  = module.load_balancer.load_balancer_ip
    domains     = var.domains
    records = [
      for domain in var.domains : {
        type  = "A"
        name  = domain
        value = module.load_balancer.load_balancer_ip
        ttl   = 300
      }
    ]
  } : null
}