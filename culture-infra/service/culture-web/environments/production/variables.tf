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
  description = "Base name of the Cloud Run service"
  type        = string
  default     = "culture-web"
}

# Load balancer and CDN variables
variable "domains" {
  description = "List of domains for SSL certificate (empty list for HTTP-only setup)"
  type        = list(string)
  default     = []
}

variable "enable_cdn" {
  description = "Enable Cloud CDN for better performance"
  type        = bool
  default     = true
}

# Note: Health check path is not needed for serverless NEGs
# variable "health_check_path" {
#   description = "The path for load balancer health checks"
#   type        = string
#   default     = "/"
# }

variable "redirect_http_to_https" {
  description = "Whether to redirect HTTP traffic to HTTPS"
  type        = bool
  default     = true
}