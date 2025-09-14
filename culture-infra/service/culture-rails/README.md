# Culture Rails Infrastructure

This directory contains Terraform configurations for deploying the Culture Rails API application to Google Cloud Run with a managed PostgreSQL database.

## Architecture

- **Cloud Run**: Serverless container deployment for the Rails API
- **Cloud SQL PostgreSQL**: Managed database with private IP connectivity
- **Secret Manager**: Secure storage for database passwords
- **VPC Peering**: Private network connectivity between Cloud Run and Cloud SQL

## Environment Structure

```
culture-rails/
├── modules/
│   ├── culture-rails/     # Cloud Run service module
│   └── database/          # Cloud SQL PostgreSQL module
└── environments/
    ├── production/        # Production environment
    └── staging/           # Staging environment
```

## Database Configuration

### Features

- **Private IP**: Database is accessible only within the VPC
- **Automated Backups**: 7-day retention with point-in-time recovery
- **Security**: Encrypted connections and Secret Manager integration
- **High Availability**: Regional deployment for production
- **Monitoring**: Query insights and performance monitoring enabled

### Environment Differences

| Feature | Production | Staging |
|---------|------------|---------|
| Machine Type | db-custom-2-4096 (2 vCPU, 4GB) | db-f1-micro |
| Availability | Regional (HA) | Zonal |
| Disk Size | 100GB | 20GB |
| Max Disk Size | 500GB | 100GB |
| Deletion Protection | Enabled | Disabled |

## Environment Variables

The following environment variables are automatically configured for the Rails application:

- `DATABASE_URL`: Full PostgreSQL connection string
- `POSTGRES_HOST`: Database host IP address
- `POSTGRES_PORT`: Database port (5432)
- `POSTGRES_DB`: Database name
- `POSTGRES_USER`: Database username
- `POSTGRES_PASSWORD`: Database password (from Secret Manager)

## Deployment Instructions

### Prerequisites

1. **GCP Project**: Ensure you have a GCP project with billing enabled
2. **APIs**: The following APIs will be automatically enabled:
   - Cloud Run API
   - Cloud SQL Admin API
   - Service Networking API
   - Secret Manager API
   - Artifact Registry API
3. **Terraform**: Version >= 1.0
4. **Authentication**: GCP credentials configured

### Production Deployment

```bash
cd culture-infra/service/culture-rails/environments/production

# Initialize Terraform
terraform init -backend-config=backend.hcl

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply
```

### Staging Deployment

```bash
cd culture-infra/service/culture-rails/environments/staging

# Initialize Terraform
terraform init -backend-config=backend.hcl

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply
```

## Database Connection

The Rails application will automatically connect to the Cloud SQL instance using the provided environment variables. Ensure your Rails `database.yml` is configured to use these environment variables:

```yaml
production:
  adapter: postgresql
  url: <%= ENV['DATABASE_URL'] %>
  host: <%= ENV['POSTGRES_HOST'] %>
  port: <%= ENV['POSTGRES_PORT'] %>
  database: <%= ENV['POSTGRES_DB'] %>
  username: <%= ENV['POSTGRES_USER'] %>
  password: <%= ENV['POSTGRES_PASSWORD'] %>
  encoding: unicode
  pool: 5
```

## Security Considerations

1. **Private IP**: Database is not accessible from the internet
2. **VPC Peering**: Secure communication within Google's network
3. **Secret Manager**: Database passwords are encrypted and rotated
4. **IAM**: Cloud Run service account has minimal required permissions
5. **Backups**: Automated encrypted backups with retention policies

## Monitoring and Maintenance

### Database Monitoring

- **Cloud SQL Insights**: Query performance monitoring enabled
- **Backup Status**: Automated daily backups at 02:00 JST
- **Maintenance Window**: Sundays 03:00 JST

### Scaling

- **Storage**: Automatic disk resizing enabled
- **Connection Pooling**: Configure in Rails application
- **Read Replicas**: Can be added for read-heavy workloads

## Troubleshooting

### Common Issues

1. **Connection Timeout**: Ensure VPC peering is properly configured
2. **Authentication Failed**: Check Secret Manager permissions
3. **Database Not Found**: Verify database creation in module

### Useful Commands

```bash
# Check database status
gcloud sql instances describe [INSTANCE_NAME] --project=[PROJECT_ID]

# View database logs
gcloud sql instances logs [INSTANCE_NAME] --project=[PROJECT_ID]

# Test connectivity from Cloud Run
gcloud run services describe [SERVICE_NAME] --region=asia-northeast1 --project=[PROJECT_ID]
```

## Cost Optimization

### Production
- Regional availability for high availability
- Automated disk resizing to optimize storage costs
- Scheduled maintenance windows to minimize downtime

### Staging
- Zonal deployment for cost efficiency
- Smaller instance size (f1-micro)
- No deletion protection for easy cleanup

## Outputs

Both environments provide the following outputs:

- `service_url`: Cloud Run service URL
- `service_name`: Cloud Run service name
- `database_instance_name`: Cloud SQL instance name
- `database_instance_connection_name`: Connection name for proxy connections
- `database_host`: Private IP address (sensitive)