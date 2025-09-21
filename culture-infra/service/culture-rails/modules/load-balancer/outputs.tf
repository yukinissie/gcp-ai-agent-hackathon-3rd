output "lb_ip_address" {
  description = "The external IP address of the load balancer"
  value       = google_compute_global_address.lb_ip.address
}

output "lb_ip_name" {
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
  description = "The name of the SSL certificate (if SSL is enabled)"
  value       = length(google_compute_managed_ssl_certificate.ssl_cert) > 0 ? google_compute_managed_ssl_certificate.ssl_cert[0].name : null
}

output "https_proxy_name" {
  description = "The name of the HTTPS target proxy (if SSL is enabled)"
  value       = length(google_compute_target_https_proxy.https_proxy) > 0 ? google_compute_target_https_proxy.https_proxy[0].name : null
}

output "https_forwarding_rule_name" {
  description = "The name of the HTTPS forwarding rule (if SSL is enabled)"
  value       = length(google_compute_global_forwarding_rule.https_forwarding_rule) > 0 ? google_compute_global_forwarding_rule.https_forwarding_rule[0].name : null
}

output "http_forwarding_rule_name" {
  description = "The name of the HTTP forwarding rule"
  value       = length(google_compute_global_forwarding_rule.http_forwarding_rule) > 0 ? google_compute_global_forwarding_rule.http_forwarding_rule[0].name : (length(google_compute_global_forwarding_rule.http_only_forwarding_rule) > 0 ? google_compute_global_forwarding_rule.http_only_forwarding_rule[0].name : null)
}

output "load_balancer_url" {
  description = "The URL to access the load balancer (HTTPS if domains are configured, HTTP otherwise)"
  value       = length(var.domains) > 0 ? "https://${var.domains[0]}" : "http://${google_compute_global_address.lb_ip.address}"
}