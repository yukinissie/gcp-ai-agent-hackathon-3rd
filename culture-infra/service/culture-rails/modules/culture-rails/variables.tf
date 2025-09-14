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
  default     = "4Gi"
}

# Database configuration variables
variable "database_url" {
  description = "The database URL for Rails"
  type        = string
  default     = ""
}

variable "database_host" {
  description = "Database host"
  type        = string
  default     = ""
}

variable "database_port" {
  description = "Database port"
  type        = string
  default     = "5432"
}

variable "database_name" {
  description = "Database name"
  type        = string
  default     = ""
}

variable "database_user" {
  description = "Database user"
  type        = string
  default     = ""
}

variable "database_password_secret_name" {
  description = "Name of the secret containing the database password"
  type        = string
  default     = ""
}