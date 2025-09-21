variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region for regional resources"
  type        = string
}

variable "service_name" {
  description = "The name of the service (used as prefix for resources)"
  type        = string
}

variable "cloud_run_service_name" {
  description = "The name of the Cloud Run service to route traffic to"
  type        = string
}

variable "domains" {
  description = "List of domains for SSL certificate (empty list for HTTP-only setup)"
  type        = list(string)
  default     = []
}

variable "enable_cdn" {
  description = "Enable Cloud CDN for static/cacheable content only"
  type        = bool
  default     = false
}

variable "cacheable_paths" {
  description = "List of paths to cache (static assets, etc.). API paths are never cached."
  type        = list(string)
  default     = ["/assets/*", "/packs/*", "/images/*", "/css/*", "/js/*"]
}

variable "redirect_http_to_https" {
  description = "Whether to redirect HTTP traffic to HTTPS"
  type        = bool
  default     = true
}

variable "path_rules" {
  description = "List of path-based routing rules"
  type = list(object({
    paths           = list(string)
    backend_service = string
  }))
  default = []
}