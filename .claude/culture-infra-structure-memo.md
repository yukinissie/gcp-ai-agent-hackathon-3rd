# Culture-Infra Structure Quick Reference

## 📁 Directory Structure Overview

```
culture-infra/
├── service/
│   ├── culture-web/          # Next.js Frontend Infrastructure
│   │   ├── environments/
│   │   │   ├── production/   # Production config (1-20 instances, 4CPU/4Gi)
│   │   │   ├── staging/      # Staging config (0-5 instances, 2CPU/2Gi)
│   │   │   └── common/docker/# Shared Docker files
│   │   └── modules/
│   │       ├── culture-web/  # Cloud Run service module
│   │       └── load-balancer/# LB + CDN module
│   └── culture-rails/        # Rails Backend Infrastructure
│       ├── environments/
│       │   ├── production/   # Production config
│       │   ├── staging/      # Staging config
│       │   └── common/docker/# Shared Docker files
│       └── modules/
│           ├── culture-rails/# Cloud Run service module
│           └── database/     # PostgreSQL Cloud SQL module
```

## 🏗️ Infrastructure Components

### Culture-Web (Frontend)
**Location**: `culture-infra/service/culture-web/`

**Modules**:
- `modules/culture-web/`: Cloud Run service with Next.js
  - Container port: 3000
  - Health checks: `/` endpoint
  - Environment: NODE_ENV=production
  - Auto-scaling with min/max instances
  - Artifact Registry integration
- `modules/load-balancer/`: HTTP(S) Load Balancer + CDN
  - SSL termination
  - HTTP→HTTPS redirect
  - CDN caching
  - Custom domain support

**Environments**:
- **Production**: `environments/production/`
  - Service: `culture-web-prod`
  - Resources: 4 CPU, 4Gi memory
  - Instances: 1-20
  - Ingress: internal-and-cloud-load-balancing
- **Staging**: `environments/staging/`
  - Service: `culture-web-staging`
  - Resources: 2 CPU, 2Gi memory
  - Instances: 0-5

### Culture-Rails (Backend)
**Location**: `culture-infra/service/culture-rails/`

**Modules**:
- `modules/culture-rails/`: Cloud Run service with Rails API
  - Container port: 3000
  - Health checks: `/health` endpoint
  - Environment: RAILS_ENV=production
  - Database connection via environment variables
  - Secret Manager integration for DB password
- `modules/database/`: PostgreSQL Cloud SQL
  - Private IP only (VPC peering)
  - Automated backups & point-in-time recovery
  - Performance insights enabled
  - Secret Manager for password storage

**Required APIs**:
- Culture-Web: `run.googleapis.com`, `cloudbuild.googleapis.com`, `artifactregistry.googleapis.com`
- Culture-Rails: + `secretmanager.googleapis.com`
- Database: + `sqladmin.googleapis.com`, `servicenetworking.googleapis.com`

## 🚀 Quick Deployment Commands

### For Culture-Web
```bash
cd culture-infra/service/culture-web/environments/production
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with actual values
terraform init -backend-config=backend.hcl
terraform plan
terraform apply
```

### For Culture-Rails
```bash
cd culture-infra/service/culture-rails/environments/production
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with actual values
terraform init -backend-config=backend.hcl
terraform plan
terraform apply
```

## 📋 Key Configuration Files

### Environment-Level Files (per environment)
- `main.tf`: Main module calls and provider config
- `variables.tf`: Input variable definitions
- `outputs.tf`: Output values (service URLs, etc.)
- `terraform.tfvars.example`: Template for actual variables
- `backend.hcl`: GCS backend configuration
- `mise.toml`: Tool version management

### Module-Level Files (reusable components)
- `main.tf`: Resource definitions
- `variables.tf`: Module input variables
- `outputs.tf`: Module output values
- `terraform.tf`: Provider version constraints

## 🔧 Common Variables Structure

### Culture-Web Variables
```hcl
project_id   = "your-project-id"
region       = "asia-northeast1"
service_name = "culture-web"
domains      = ["example.com"]  # Optional
enable_cdn   = true             # Optional
```

### Culture-Rails Variables
```hcl
project_id          = "your-project-id"
region              = "asia-northeast1"
service_name        = "culture-rails"
database_name       = "culture_production"
database_user       = "culture_user"
db_tier            = "db-f1-micro"  # or db-n1-standard-1
```

## 🎯 Adding New Infrastructure

### New Service Pattern
1. Create `service/new-service/` directory
2. Add `modules/new-service/` with core resources
3. Create `environments/production/` and `staging/`
4. Copy pattern from existing services
5. Update variables and outputs appropriately

### New Module Pattern
1. Create `modules/new-module/` directory
2. Add `main.tf`, `variables.tf`, `outputs.tf`, `terraform.tf`
3. Reference from environment `main.tf`
4. Test in staging before production

## 💡 Best Practices for Quick Development

1. **Use existing patterns**: Copy from culture-web or culture-rails
2. **Environment separation**: Always test in staging first
3. **Module reusability**: Create modules for reusable components
4. **Variable consistency**: Follow naming conventions from existing code
5. **Backend management**: Use GCS backend with proper prefixes
6. **Version pinning**: Use `~> 5.0` for Google provider

## 🔗 Dependencies & Relationships

- **Artifact Registry**: Created in production environment, referenced in modules
- **Load Balancer**: Depends on Cloud Run service
- **Database**: Uses VPC peering, integrates with Cloud Run via env vars
- **Secret Manager**: Stores database passwords, accessed by Cloud Run
- **IAM**: Minimal permissions, allUsers for public services

This structure supports rapid infrastructure additions while maintaining separation of concerns and environment isolation.