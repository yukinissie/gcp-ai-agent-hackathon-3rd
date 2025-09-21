variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region where resources will be created"
  type        = string
  default     = "asia-northeast1"
}

variable "service_name" {
  description = "Name of the Cloud Run service"
  type        = string
  default     = "culture-rails"
}

variable "domains" {
  description = "List of domains for SSL certificate (empty list for HTTP-only setup)"
  type        = list(string)
  default     = []
}

variable "enable_cdn" {
  description = "Enable Cloud CDN for the backend service"
  type        = bool
  default     = false
}

variable "cacheable_paths" {
  description = "List of cacheable paths for CDN (e.g., ['/assets/*', '/images/*'])"
  type        = list(string)
  default     = []
}