output "load_balancer_ip" {
  description = "The external IP address of the load balancer"
  value       = google_compute_global_address.lb_ip.address
}

output "load_balancer_ip_name" {
  description = "The name of the reserved IP address"
  value       = google_compute_global_address.lb_ip.name
}

output "backend_service_name" {
  description = "The name of the backend service"
  value       = google_compute_backend_service.backend.name
}

output "backend_service_id" {
  description = "The ID of the backend service"
  value       = google_compute_backend_service.backend.id
}

output "url_map_name" {
  description = "The name of the URL map"
  value       = google_compute_url_map.url_map.name
}

output "url_map_id" {
  description = "The ID of the URL map"
  value       = google_compute_url_map.url_map.id
}

output "ssl_certificate_name" {
  description = "The name of the SSL certificate (if created)"
  value       = length(google_compute_managed_ssl_certificate.ssl_cert) > 0 ? google_compute_managed_ssl_certificate.ssl_cert[0].name : null
}

output "ssl_certificate_id" {
  description = "The ID of the SSL certificate (if created)"
  value       = length(google_compute_managed_ssl_certificate.ssl_cert) > 0 ? google_compute_managed_ssl_certificate.ssl_cert[0].id : null
}

output "https_proxy_name" {
  description = "The name of the HTTPS target proxy (if created)"
  value       = length(google_compute_target_https_proxy.https_proxy) > 0 ? google_compute_target_https_proxy.https_proxy[0].name : null
}

output "http_proxy_name" {
  description = "The name of the HTTP target proxy"
  value = coalesce(
    length(google_compute_target_http_proxy.http_proxy) > 0 ? google_compute_target_http_proxy.http_proxy[0].name : null,
    length(google_compute_target_http_proxy.http_only_proxy) > 0 ? google_compute_target_http_proxy.http_only_proxy[0].name : null
  )
}

output "serverless_neg_id" {
  description = "The ID of the serverless Network Endpoint Group"
  value       = google_compute_region_network_endpoint_group.serverless_neg.id
}

# Note: Health checks are not used with serverless NEGs
# output "health_check_name" {
#   description = "The name of the health check"
#   value       = null
# }

output "load_balancer_url" {
  description = "The URL of the load balancer (HTTP or HTTPS based on configuration)"
  value       = length(var.domains) > 0 ? "https://${var.domains[0]}" : "http://${google_compute_global_address.lb_ip.address}"
}