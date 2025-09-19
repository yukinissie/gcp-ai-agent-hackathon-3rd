# Database Module

Environment-agnostic database module that can be used across different environments (development, staging, production).

## Features

- Environment-specific configurations with sensible defaults
- Automatic naming with environment prefixes
- Environment validation
- Private IP configuration for security
- Secret Manager integration for password management
- Comprehensive outputs for integration

## Environment Configurations

The module automatically configures database settings based on the environment:

### Development

- **Tier**: `db-f1-micro` (minimal resources)
- **Availability**: `ZONAL` (single zone)
- **Disk Size**: `20GB`
- **Deletion Protection**: `false` (allows easy cleanup)

### Staging

- **Tier**: `db-g1-small` (small but more robust than dev)
- **Availability**: `ZONAL` (single zone)
- **Disk Size**: `20GB`
- **Deletion Protection**: `false` (allows cleanup)

### Production

- **Tier**: `db-custom-2-4096` (2 vCPUs, 4GB RAM)
- **Availability**: `REGIONAL` (high availability)
- **Disk Size**: `50GB`
- **Deletion Protection**: `true` (prevents accidental deletion)

## Usage

### Basic Usage with Environment Defaults

```hcl
module "database" {
  source = "../modules/database"

  project_id     = var.project_id
  region         = var.region
  environment    = "production"  # or "staging", "development"
  vpc_network_id = var.vpc_network_id
}
```

### Custom Configuration Override

```hcl
module "database" {
  source = "../modules/database"

  project_id     = var.project_id
  region         = var.region
  environment    = "production"
  vpc_network_id = var.vpc_network_id

  # Override defaults for specific requirements
  db_tier               = "db-custom-4-8192"  # More powerful instance
  disk_size            = 100                  # Larger disk
  disk_autoresize_limit = 500                 # Higher autoresize limit
}
```

### Using Existing VPC Peering (Recommended for Multiple Environments)

```hcl
# First environment creates VPC peering
module "database_staging" {
  source = "../modules/database"

  project_id     = var.project_id
  region         = var.region
  environment    = "staging"
  vpc_network_id = var.vpc_network_id
}

# Subsequent environments use existing peering
module "database_production" {
  source = "../modules/database"

  project_id     = var.project_id
  region         = var.region
  environment    = "production"
  vpc_network_id = var.vpc_network_id

  depends_on = [module.database_staging]
}
```

## Variable Reference

### Required Variables

- `project_id`: GCP project ID
- `environment`: Environment name (development, staging, production)

### Optional Variables

- `region`: GCP region (default: "asia-northeast1")
- `db_name`: Base name for database resources (default: "culture-rails-db")
- `database_name`: Database name within instance (default: "culture_rails")
- `database_user`: Database username (default: "culture_rails_user")
- `database_version`: PostgreSQL version (default: "POSTGRES_15")
- `vpc_network_id`: VPC network for private IP (default: "default")

### Override Variables

Set these to override environment-specific defaults:

- `db_tier`: Machine type
- `availability_type`: ZONAL or REGIONAL
- `disk_size`: Disk size in GB
- `deletion_protection`: Enable/disable deletion protection
- `disk_autoresize_limit`: Maximum autoresize limit (default: 100GB)

## Outputs

- `database_instance_name`: Cloud SQL instance name
- `database_instance_id`: Cloud SQL instance ID
- `database_instance_connection_name`: Instance connection name
- `database_instance_private_ip`: Private IP address
- `database_name`: Database name
- `database_user`: Database username (sensitive)
- `database_password_secret_name`: Secret Manager secret name for password
- `database_url`: Complete database URL (sensitive)
- `database_host`: Database host
- `database_port`: Database port
- `environment`: Deployed environment
- `database_config`: Complete configuration object

## Resource Naming

All resources are automatically named with environment prefixes:

- Database Instance: `{db_name}-{environment}-{random_suffix}`
- Private IP: `{db_name}-{environment}-private-ip`
- Secret: `{db_name}-{environment}-password`

## Security Features

- Private IP configuration (no public IP)
- VPC peering for secure access
- Password stored in Secret Manager
- Environment-appropriate deletion protection
- SSL configuration support
- Database audit logging enabled

## Example Deployment Patterns

### Multi-Environment Setup

```hcl
# Development (first environment creates VPC peering)
module "database_dev" {
  source = "../modules/database"

  project_id     = var.project_id
  region         = var.region
  environment    = "development"
  vpc_network_id = var.vpc_network_id
}

# Staging (uses existing VPC peering)
module "database_staging" {
  source = "../modules/database"

  project_id     = var.project_id
  region         = var.region
  environment    = "staging"
  vpc_network_id = var.vpc_network_id

  depends_on = [module.database_dev]
}

# Production (uses existing VPC peering)
module "database_prod" {
  source = "../modules/database"

  project_id     = var.project_id
  region         = var.region
  environment    = "production"
  vpc_network_id = var.vpc_network_id

  depends_on = [module.database_dev]
}
```
