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
  description = "Enable Cloud CDN for the backend service"
  type        = bool
  default     = true
}

# Note: Health check path is not needed for serverless NEGs
# variable "health_check_path" {
#   description = "The path for health checks"
#   type        = string
#   default     = "/"
# }

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