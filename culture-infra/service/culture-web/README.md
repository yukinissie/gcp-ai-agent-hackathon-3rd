# Culture Web Infrastructure

This directory contains Terraform configurations for deploying the Culture Next.js web application to Google Cloud Run with optional load balancer and CDN support.

## Architecture Overview

```
Internet → Global External Application Load Balancer → Cloud CDN → Cloud Run (Next.js)
```

### Components

- **Cloud Run**: Hosts the containerized Next.js application
- **Global External Application Load Balancer**: Routes traffic and provides SSL termination
- **Cloud CDN**: Caches static content globally for improved performance
- **Google-managed SSL Certificates**: Automatic SSL certificate management
- **Serverless NEG**: Connects Cloud Run to the load balancer

## Directory Structure

```
culture-web/
├── modules/
│   ├── culture-web/          # Cloud Run service module
│   └── load-balancer/        # Load balancer with CDN module
└── environments/
    ├── production/           # Production environment
    └── staging/             # Staging environment
```

## Configuration Options

### Production Environment

The production environment **always** includes the load balancer and CDN for optimal performance:

```hcl
# Production configuration
module "culture_web" {
  # Cloud Run with load balancer-only access
  ingress = "internal-and-cloud-load-balancing"
}

module "load_balancer" {
  # Always enabled in production
  enable_cdn = true
  domains    = var.domains  # Configure your domains
}
```

### Staging Environment

The staging environment supports both modes:

- **Direct Cloud Run Access** (default): Simple setup for development
- **Load Balancer + CDN**: Testing production-like setup

```hcl
# Toggle load balancer for staging
enable_load_balancer = false  # Direct Cloud Run (default)
enable_load_balancer = true   # With load balancer + CDN
```

## Deployment Instructions

### 1. Production Deployment (with Custom Domain)

```bash
cd culture-infra/service/culture-web/environments/production

# Configure your domain
terraform plan -var="domains=[\"your-domain.com\"]"
terraform apply -var="domains=[\"your-domain.com\"]"
```

**DNS Configuration Required:**
After deployment, configure your DNS to point to the load balancer IP:

```
A    your-domain.com    →  <load_balancer_ip>
```

### 2. Production Deployment (HTTP-only)

```bash
# Deploy without custom domain (uses load balancer IP)
terraform plan -var="domains=[]"
terraform apply -var="domains=[]"
```

Access via: `http://<load_balancer_ip>`

### 3. Staging Deployment

#### Option A: Direct Cloud Run (Simple)
```bash
cd culture-infra/service/culture-web/environments/staging

terraform plan
terraform apply
```
Access via the Cloud Run URL from outputs.

#### Option B: With Load Balancer (Production-like)
```bash
terraform plan -var="enable_load_balancer=true"
terraform apply -var="enable_load_balancer=true"
```

## Variables Reference

### Common Variables

| Variable | Description | Type | Default | Required |
|----------|-------------|------|---------|----------|
| `project_id` | GCP Project ID | string | - | ✅ |
| `region` | GCP Region | string | asia-northeast1 | ❌ |
| `service_name` | Base service name | string | culture-web | ❌ |

### Load Balancer Variables

| Variable | Description | Type | Default | Required |
|----------|-------------|------|---------|----------|
| `domains` | SSL certificate domains | list(string) | [] | ❌ |
| `enable_cdn` | Enable Cloud CDN | bool | true | ❌ |
| `redirect_http_to_https` | HTTP→HTTPS redirect | bool | true | ❌ |

### Staging-Only Variables

| Variable | Description | Type | Default |
|----------|-------------|------|---------|
| `enable_load_balancer` | Enable load balancer for staging | bool | false |

## Outputs Reference

### Production Outputs

| Output | Description |
|--------|-------------|
| `load_balancer_ip` | External IP address |
| `load_balancer_url` | Primary access URL |
| `ssl_certificate_name` | SSL certificate name |
| `dns_configuration` | DNS setup instructions |

### Staging Outputs

| Output | Description |
|--------|-------------|
| `load_balancer_url` | LB URL (if enabled) or Cloud Run URL |
| `load_balancer_ip` | External IP (if LB enabled) |
| `service_url` | Direct Cloud Run URL |

## CDN Configuration

The load balancer module includes optimized CDN settings:

- **Static Content TTL**: 1 hour (3600 seconds)
- **Max TTL**: 24 hours (86400 seconds)
- **Client TTL**: 1 hour (3600 seconds)
- **Compression**: Automatic gzip/brotli
- **Cache Mode**: CACHE_ALL_STATIC
- **Negative Caching**: 60 seconds for 404/410 errors

## Security Features

- **SSL/TLS**: Google-managed certificates with auto-renewal
- **HTTPS Redirect**: Automatic HTTP to HTTPS redirection
- **Ingress Control**: Restricts direct Cloud Run access when using load balancer
- **Built-in Monitoring**: Cloud Run provides internal health monitoring (external health checks not needed)

### Access Control Model

Google Cloud Run uses a two-layer security model:

1. **IAM Layer**: Controls who can invoke the service
   - Set to `allUsers` to allow load balancer access
   - Required even when using ingress restrictions

2. **Ingress Layer**: Controls where traffic can originate
   - `all`: Direct public access allowed
   - `internal-and-cloud-load-balancing`: Only load balancer and VPC traffic
   - `internal`: Only VPC traffic
   - `none`: No traffic allowed

**Production Setup**: IAM = `allUsers` + Ingress = `internal-and-cloud-load-balancing`
- Result: Only load balancer can reach Cloud Run, users cannot access directly

## Monitoring and Troubleshooting

### Check Deployment Status

```bash
# View outputs
terraform output

# Check SSL certificate status (may take 10-15 minutes)
gcloud compute ssl-certificates describe <certificate_name> --global

# Check load balancer health
gcloud compute backend-services describe <backend_service_name> --global
```

### Common Issues

1. **SSL Certificate Pending**: Wait 10-15 minutes and verify DNS configuration
2. **502 Bad Gateway**: Check Cloud Run service health and ingress settings
3. **403 Forbidden**: Verify IAM permissions for load balancer to Cloud Run

## Cost Optimization

- **Production**: Always uses load balancer for performance and reliability
- **Staging**: Defaults to direct Cloud Run to minimize costs
- **CDN**: Only charges for cache hits and egress traffic
- **SSL**: Google-managed certificates are free

## Migration from Direct Cloud Run

If upgrading from direct Cloud Run access:

1. Deploy the load balancer module
2. Update DNS to point to load balancer IP
3. Traffic automatically flows through CDN
4. No application code changes required

## Next Steps

After deployment:

1. Configure DNS records (if using custom domain)
2. Test HTTPS access and certificate
3. Monitor CDN cache hit rates
4. Set up monitoring alerts for backend health