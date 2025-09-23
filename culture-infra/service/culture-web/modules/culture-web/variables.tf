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
  default     = "culture-web"
}

variable "environment" {
  description = "Environment name (e.g., staging, production)"
  type        = string
  default     = "staging"
}

variable "min_instances" {
  description = "Minimum number of instances"
  type        = number
  default     = 0
}

variable "max_instances" {
  description = "Maximum number of instances"
  type        = number
  default     = 10
}

variable "cpu_limit" {
  description = "CPU limit for each container"
  type        = string
  default     = "2"
}

variable "memory_limit" {
  description = "Memory limit for each container"
  type        = string
  default     = "2Gi"
}

# Note: IAM access is always set to "allUsers" but ingress annotation controls actual access
# variable "allow_public_access" {
#   description = "Whether to allow public access to the Cloud Run service"
#   type        = bool
#   default     = false
# }

variable "ingress" {
  description = "Ingress traffic sources allowed to call the service"
  type        = string
  default     = "internal-and-cloud-load-balancing"
  validation {
    condition = contains([
      "all",
      "internal",
      "internal-and-cloud-load-balancing",
      "none"
    ], var.ingress)
    error_message = "Ingress must be one of: 'all', 'internal', 'internal-and-cloud-load-balancing', or 'none'."
  }
}

variable "rails_api_host_secret_name" {
  description = "The name of the Secret Manager secret that contains the Rails API host URL"
  type        = string
  default     = ""
}

variable "auth_secret_name" {
  description = "The name of the Secret Manager secret that contains the authentication secret"
  type        = string
  default     = ""
}

variable "google_generative_ai_api_key_secret_name" {
  description = "The name of the Secret Manager secret that contains the Google Generative AI API key"
  type        = string
  default     = ""
}

variable "database_url_secret_name" {
  description = "The name of the Secret Manager secret that contains the Database URL"
  type        = string
  default     = ""
}
