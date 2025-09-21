# Reserve global static IP address
resource "google_compute_global_address" "lb_ip" {
  name         = "${var.service_name}-lb-ip"
  project      = var.project_id
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
}

# Create serverless NEG for Cloud Run
resource "google_compute_region_network_endpoint_group" "serverless_neg" {
  name                  = "${var.service_name}-serverless-neg"
  project               = var.project_id
  region                = var.region
  network_endpoint_type = "SERVERLESS"

  cloud_run {
    service = var.cloud_run_service_name
  }
}

# Create backend service for API (no CDN - fresh responses)
resource "google_compute_backend_service" "backend" {
  name                            = "${var.service_name}-backend"
  project                         = var.project_id
  protocol                        = "HTTP"
  timeout_sec                     = 30
  connection_draining_timeout_sec = 10

  # CDN disabled for API endpoints to ensure fresh responses
  enable_cdn = false

  backend {
    group = google_compute_region_network_endpoint_group.serverless_neg.id
  }
}

# Note: Health checks are not used with serverless NEGs
# Cloud Run services have built-in health monitoring and don't require
# external health checks for load balancer backends

# Backend service for static/cacheable content
resource "google_compute_backend_service" "cached_backend" {
  count                           = var.enable_cdn && length(var.cacheable_paths) > 0 ? 1 : 0
  name                            = "${var.service_name}-cached-backend"
  project                         = var.project_id
  protocol                        = "HTTP"
  timeout_sec                     = 30
  connection_draining_timeout_sec = 10

  # Enable Cloud CDN for static content
  enable_cdn = true

  cdn_policy {
    cache_mode        = "CACHE_ALL_STATIC"
    default_ttl       = 3600  # 1 hour for static content
    max_ttl           = 86400 # 24 hours max
    client_ttl        = 3600  # 1 hour client cache
    negative_caching  = true
    serve_while_stale = 86400 # Serve stale content for 24 hours

    # Cache key policy for static content
    cache_key_policy {
      include_host           = true
      include_protocol       = true
      include_query_string   = true
      query_string_whitelist = []
    }

    # Negative caching policy
    negative_caching_policy {
      code = 404
      ttl  = 300
    }
    negative_caching_policy {
      code = 410
      ttl  = 300
    }
  }

  backend {
    group = google_compute_region_network_endpoint_group.serverless_neg.id
  }
}

# URL map for routing with path-based caching
resource "google_compute_url_map" "url_map" {
  name            = "${var.service_name}-url-map"
  project         = var.project_id
  default_service = google_compute_backend_service.backend.id

  # Path matcher for differentiating cached vs non-cached content
  dynamic "path_matcher" {
    for_each = var.enable_cdn && length(var.cacheable_paths) > 0 ? ["main"] : []
    content {
      name            = "main"
      default_service = google_compute_backend_service.backend.id

      # Route cacheable paths to cached backend
      dynamic "path_rule" {
        for_each = var.cacheable_paths
        content {
          paths   = [path_rule.value]
          service = google_compute_backend_service.cached_backend[0].id
        }
      }
    }
  }

  # Host rule to use path matcher when caching is enabled
  dynamic "host_rule" {
    for_each = var.enable_cdn && length(var.cacheable_paths) > 0 ? ["main"] : []
    content {
      hosts        = ["*"]
      path_matcher = "main"
    }
  }

  # Custom path-based routing rules (if specified)
  dynamic "path_matcher" {
    for_each = length(var.path_rules) > 0 ? ["custom"] : []
    content {
      name            = "custom"
      default_service = google_compute_backend_service.backend.id

      dynamic "path_rule" {
        for_each = var.path_rules
        content {
          paths   = path_rule.value.paths
          service = path_rule.value.backend_service
        }
      }
    }
  }
}

# SSL certificate (Google-managed)
resource "google_compute_managed_ssl_certificate" "ssl_cert" {
  count   = length(var.domains) > 0 ? 1 : 0
  name    = "${var.service_name}-ssl-cert"
  project = var.project_id

  managed {
    domains = var.domains
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Target HTTPS proxy
resource "google_compute_target_https_proxy" "https_proxy" {
  count   = length(var.domains) > 0 ? 1 : 0
  name    = "${var.service_name}-https-proxy"
  project = var.project_id
  url_map = google_compute_url_map.url_map.id

  ssl_certificates = [google_compute_managed_ssl_certificate.ssl_cert[0].id]
}

# Target HTTP proxy (for redirect)
resource "google_compute_target_http_proxy" "http_proxy" {
  count   = var.redirect_http_to_https && length(var.domains) > 0 ? 1 : 0
  name    = "${var.service_name}-http-proxy"
  project = var.project_id
  url_map = google_compute_url_map.redirect_url_map[0].id
}

# URL map for HTTP to HTTPS redirect
resource "google_compute_url_map" "redirect_url_map" {
  count   = var.redirect_http_to_https && length(var.domains) > 0 ? 1 : 0
  name    = "${var.service_name}-redirect-url-map"
  project = var.project_id

  default_url_redirect {
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
    https_redirect         = true
  }
}

# Global forwarding rule for HTTPS
resource "google_compute_global_forwarding_rule" "https_forwarding_rule" {
  count       = length(var.domains) > 0 ? 1 : 0
  name        = "${var.service_name}-https-forwarding-rule"
  project     = var.project_id
  target      = google_compute_target_https_proxy.https_proxy[0].id
  port_range  = "443"
  ip_address  = google_compute_global_address.lb_ip.address
  ip_protocol = "TCP"
}

# Global forwarding rule for HTTP (redirect)
resource "google_compute_global_forwarding_rule" "http_forwarding_rule" {
  count       = var.redirect_http_to_https && length(var.domains) > 0 ? 1 : 0
  name        = "${var.service_name}-http-forwarding-rule"
  project     = var.project_id
  target      = google_compute_target_http_proxy.http_proxy[0].id
  port_range  = "80"
  ip_address  = google_compute_global_address.lb_ip.address
  ip_protocol = "TCP"
}

# Fallback HTTP forwarding rule (when no SSL domains are configured)
resource "google_compute_global_forwarding_rule" "http_only_forwarding_rule" {
  count       = length(var.domains) == 0 ? 1 : 0
  name        = "${var.service_name}-http-forwarding-rule"
  project     = var.project_id
  target      = google_compute_target_http_proxy.http_only_proxy[0].id
  port_range  = "80"
  ip_address  = google_compute_global_address.lb_ip.address
  ip_protocol = "TCP"
}

# Target HTTP proxy for HTTP-only setup
resource "google_compute_target_http_proxy" "http_only_proxy" {
  count   = length(var.domains) == 0 ? 1 : 0
  name    = "${var.service_name}-http-only-proxy"
  project = var.project_id
  url_map = google_compute_url_map.url_map.id
}