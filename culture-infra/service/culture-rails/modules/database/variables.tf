variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region where resources will be created"
  type        = string
  default     = "asia-northeast1"
}

variable "db_name" {
  description = "Base name of the Cloud SQL instance (environment will be appended)"
  type        = string
  default     = "culture-rails-db"
}

variable "database_name" {
  description = "Name of the database within the instance"
  type        = string
  default     = "culture_rails"
}

variable "database_user" {
  description = "Database user name"
  type        = string
  default     = "culture_rails_user"
}

variable "database_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "POSTGRES_15"
}

variable "db_tier" {
  description = "Machine type for the database instance"
  type        = string
  default     = null
}

variable "availability_type" {
  description = "Availability type for the database instance (ZONAL or REGIONAL)"
  type        = string
  default     = null
}

variable "disk_size" {
  description = "Disk size in GB"
  type        = number
  default     = null
}

variable "disk_autoresize_limit" {
  description = "Maximum disk size for autoresize in GB"
  type        = number
  default     = 100
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = null
}

variable "environment" {
  description = "Environment name (e.g., staging, production)"
  type        = string
  validation {
    condition     = contains(["staging", "production"], var.environment)
    error_message = "Environment must be one of: staging, production."
  }
}

variable "vpc_network_id" {
  description = "The VPC network ID for private IP configuration"
  type        = string
  default     = "default"
}
