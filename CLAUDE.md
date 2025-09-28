# CLAUDE.md - Project Context for AI Assistants

This document provides comprehensive context for AI assistants working on the GCP AI Agent Hackathon Culture project.

## 🎯 Project Overview

**Project Type**: Full-Stack Web Application with Microservices Architecture
**Purpose**: GCP AI Agent Hackathon project - "Culture" application
**Architecture**: Modern cloud-native microservices combining Rails API backend and Next.js frontend

## 🏗️ System Architecture

### Components

- **Frontend**: Next.js 15.5 React application (`culture-web`)
- **Backend**: Ruby on Rails 8.0 API service (`culture_rails`)
- **Infrastructure**: Terraform-managed GCP resources (`culture-infra`)
- **Deployment**: Google Cloud Run with automated CI/CD

### Technology Stack

#### Frontend (culture-web)

- **Framework**: Next.js 15.5.3 with React 19.1.0
- **Language**: TypeScript 5.x with strict typing
- **Build Tool**: Turbopack for faster development
- **Styling**: CSS Modules
- **Code Quality**: Biome 2.2.0 (unified linting + formatting)
- **Architecture**: App Router with standalone output for containerization

#### Backend (culture_rails)

- **Framework**: Ruby on Rails 8.0.2+ (latest version)
- **Database**: PostgreSQL with Docker Compose setup
- **Web Server**: Puma
- **Asset Pipeline**: Propshaft (modern Rails assets)
- **Frontend Integration**: Hotwire (Turbo + Stimulus)
- **API**: JSON APIs with Jbuilder + Committee Rails for OpenAPI validation
- **Cache/Queue**: Solid Cache, Solid Queue, Solid Cable (Redis alternatives)
- **Testing**: RSpec + FactoryBot + Capybara for system tests
- **Code Quality**: RuboCop Rails Omakase + Brakeman security scanner
- **Editor Support**: Ruby LSP configured

#### Infrastructure & DevOps

- **Cloud**: Google Cloud Platform (GCP)
- **Containers**: Cloud Run (serverless)
- **Registry**: Google Artifact Registry
- **IaC**: Terraform with modular structure
- **CI/CD**: GitHub Actions
- **Development**: Docker Compose + Dip for CLI simplification
- **Region**: Asia-Northeast1 (Japan)

## 📁 Directory Structure

```
gcp-ai-agent-hackathon-3rd/
├── culture-web/                    # Next.js Frontend
│   ├── src/app/                   # App Router pages
│   ├── public/                    # Static assets
│   ├── package.json               # Dependencies & scripts
│   ├── next.config.ts             # Next.js config (standalone output)
│   ├── tsconfig.json              # TypeScript config
│   └── biome.json                 # Biome linting config
├── culture_rails/                  # Rails Backend
│   ├── app/                       # Rails application code
│   ├── config/                    # Rails configuration
│   ├── db/                        # Database migrations & seeds
│   ├── spec/                      # RSpec tests
│   ├── Gemfile                    # Ruby dependencies
│   ├── docker-compose.yml         # Local development setup
│   ├── Dockerfile                 # Rails container config
│   └── dip.yml                    # Docker command shortcuts
├── culture-infra/                  # Terraform Infrastructure
│   ├── service/culture-web/
│   │   ├── environments/          # Production/Staging configs
│   │   └── modules/               # Reusable Terraform modules
│   └── README.md                  # Infrastructure documentation
├── .github/workflows/              # CI/CD Pipelines
│   └── deploy-culture-web.yml     # Next.js deployment workflow
└── dip.yml                        # Global Docker CLI config
```

## 🔧 Development Commands

### Frontend Development (culture-web)

```bash
cd culture-web
npm run dev          # Development server with Turbopack
npm run build        # Production build with standalone output
npm run start        # Production server
npm run lint         # Biome linting
npm run format       # Biome formatting
```

### Backend Development (culture_rails)

```bash
# Using Dip (recommended)
dip provision        # Initial setup: DB + dependencies + migration
dip rails s          # Start Rails server
dip c               # Rails console
dip rspec           # Run RSpec tests
dip rubocop         # RuboCop linting
dip brakeman        # Security scanning
dip bundle          # Bundle commands

# Direct Docker Compose
docker-compose up    # Start all services
docker-compose exec web bundle exec rails c  # Rails console
```

### Infrastructure Management

```bash
cd culture-infra/service/culture-web/environments/production
terraform init -backend-config=backend.hcl
terraform plan       # Preview changes
terraform apply      # Apply infrastructure changes
terraform output     # View outputs (service URLs, etc.)
```

## 🚀 Deployment Architecture

### Environments

- **Production**: `culture-web-prod` (1-20 instances, 4 CPU, 4Gi memory)
- **Staging**: `culture-web-staging` (0-5 instances, 2 CPU, 2Gi memory)

### CI/CD Pipeline (GitHub Actions)

- **Trigger**: Push to main or PR changes to `culture-web/`
- **Process**:
  1. Build multi-stage Docker image
  2. Push to Google Artifact Registry
  3. Deploy to Cloud Run
  4. Output deployment URL

### Container Strategy

- **Frontend**: Multi-stage Dockerfile with Node.js 24 Alpine
- **Build**: Standalone Next.js output for minimal container size
- **Platform**: Linux/AMD64 for Cloud Run compatibility
- **Security**: Non-root user execution

## 🏆 Development Best Practices

### Code Quality Standards

- **Rails**: RuboCop Rails Omakase (opinionated styling)
- **Frontend**: Biome for unified TypeScript tooling
- **Security**: Brakeman security scanning
- **Testing**: Comprehensive RSpec + system tests

### Modern Rails Patterns

- **Solid Stack**: Cache/Queue/Cable without Redis dependency
- **API-First**: OpenAPI validation with Committee Rails
- **Hotwire**: SPA-like experience with minimal JavaScript
- **Modern Assets**: Propshaft pipeline

### Frontend Patterns

- **TypeScript**: Strict typing throughout
- **App Router**: Modern Next.js routing patterns
- **Component Architecture**: CSS Modules for styling
- **Performance**: Turbopack for development speed

## 📝 Important Notes for AI Assistants

### Current State

- **Backend**: Basic Rails setup with minimal controllers
- **Frontend**: Simple landing page with Japanese content
- **Infrastructure**: Full Terraform setup with production/staging
- **CI/CD**: Automated deployment pipeline active

### Development Environment Setup

1. **Prerequisites**: Docker, Docker Compose, Node.js 24, Ruby 3.x
2. **Backend**: Use `dip provision` for complete setup
3. **Frontend**: `npm install && npm run dev`
4. **Database**: PostgreSQL via Docker Compose

### Key Configuration Files

- **Rails**: `culture_rails/config/application.rb` - Main Rails config
- **Next.js**: `culture-web/next.config.ts` - Standalone output enabled
- **Docker**: `culture_rails/docker-compose.yml` - Local development
- **Infrastructure**: `culture-infra/service/culture-web/modules/` - Terraform modules
- **CI/CD**: `.github/workflows/deploy-culture-web.yml` - Deployment pipeline

### Common Development Tasks

- **Adding API endpoints**: Create controllers in `culture_rails/app/controllers/`
- **Frontend pages**: Add to `culture-web/src/app/`
- **Database changes**: Rails migrations in `culture_rails/db/migrate/`
- **Infrastructure changes**: Modify Terraform in `culture-infra/`
- **Dependencies**: Update `Gemfile` or `package.json` respectively
- **API integration**: Use `culture-web/src/lib/apiClient.ts` for all API communications instead of direct fetch calls

### Testing Strategy

- **Backend**: RSpec with FactoryBot for unit/integration tests
- **System Tests**: Capybara for end-to-end testing
- **API Validation**: Committee Rails for OpenAPI compliance
- **Frontend**: No testing framework currently configured

This project demonstrates enterprise-grade development practices suitable for rapid hackathon development with production-ready deployment capabilities.
