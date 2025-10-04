# CLAUDE.md - Project Context for AI Assistants

This document provides comprehensive context for AI assistants working on the Culture project - an AI-driven news curation platform for GCP AI Agent Hackathon.

## 🎯 Project Overview

**Project Type**: Full-Stack AI-Powered News Curation Platform
**Purpose**: Personalized news discovery through AI agent interaction and user preference learning
**Architecture**: Modern cloud-native microservices with AI/LLM integration

### Core Features Implemented

- **AI-Driven News Curation**: Google Gemini 2.0 Flash powered article summarization and categorization
- **Personalized Recommendations**: User evaluation history-based content suggestions
- **Interactive Chat**: AI agent dialogue for topic exploration
- **Tag-Based Search**: Category-organized article discovery
- **User Authentication**: NextAuth v5 + Rails JWT authentication system
- **Article Rating**: Good/Bad evaluation with exclusive selection logic

## 🏗️ System Architecture

### Layer Structure

```
┌─────────────────────────────────────────────────────────────┐
│                    Frontend Layer                            │
│   Next.js 15.5 + React 19 + TypeScript + Radix UI          │
│   App Router, Server Components, Parallel Routes            │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                   AI Agent Layer                             │
│   Mastra Framework + Google Gemini 2.0 Flash                │
│   - News Curation Agent                                      │
│   - Tag Determination Agent                                  │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                    Backend Layer                             │
│   Rails 8.0 API + PostgreSQL + NextAuth                     │
│   RESTful API, JWT Auth, OpenAPI Validation                 │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                Infrastructure Layer                          │
│   Google Cloud Run + Artifact Registry + Secret Manager     │
└─────────────────────────────────────────────────────────────┘
```

### Technology Stack

#### Frontend (culture-web)

- **Framework**: Next.js 15.5.3 with React 19.1.0
- **Language**: TypeScript 5.x with strict typing
- **Build Tool**: Turbopack for faster development
- **UI Library**: Radix UI (Toast, Themes, Icons)
- **Styling**: CSS Modules + Radix Colors
- **Code Quality**: Biome 2.2.4 (unified linting + formatting)
- **Architecture**: App Router with Parallel Routes (@articles, @chatSideBar)
- **AI Integration**: Mastra Framework + @ai-sdk/google + @ai-sdk/react
- **Authentication**: NextAuth v5 (Auth.js)
- **Theme**: next-themes for dark mode support

#### Backend (culture_rails)

- **Framework**: Ruby on Rails 8.0.2+ (API mode)
- **Database**: PostgreSQL 15+ with Docker Compose
- **Web Server**: Puma
- **Authentication**: Custom JWT (JsonWebToken class) + Sorcery gem patterns
- **API**: JSON APIs with JBuilder (jb gem) + Committee Rails for OpenAPI validation
- **Cache/Queue**: Solid Cache, Solid Queue, Solid Cable (Redis-free)
- **Testing**: RSpec + FactoryBot + Committee Rails
- **Code Quality**: RuboCop Rails Omakase + Brakeman security scanner
- **Editor Support**: Ruby LSP configured

#### Infrastructure & DevOps

- **Cloud**: Google Cloud (Asia-Northeast1)
- **Containers**: Cloud Run (serverless)
- **Registry**: Google Artifact Registry
- **Secrets**: Secret Manager for credentials
- **IaC**: Terraform with modular structure
- **CI/CD**: GitHub Actions (separate workflows for web/rails, prod/staging)
- **Development**: Docker Compose + Dip for CLI simplification

## 📁 Directory Structure

```
gcp-ai-agent-hackathon-3rd/
├── culture-web/                     # Next.js Frontend
│   ├── src/
│   │   ├── app/
│   │   │   ├── (anonymous)/         # Unauthenticated pages
│   │   │   │   ├── _actions/        # Server actions (signInUser)
│   │   │   │   ├── _components/     # Login/Register components
│   │   │   │   └── page.tsx
│   │   │   ├── (authorized)/        # Authenticated pages
│   │   │   │   ├── home/            # Main page with parallel routes
│   │   │   │   │   ├── @articles/   # Article list slot
│   │   │   │   │   ├── @chatSideBar/ # Chat interface slot
│   │   │   │   │   └── layout.tsx   # Parallel route layout
│   │   │   │   ├── articles/[id]/   # Article detail page
│   │   │   │   └── test/            # Test endpoints
│   │   │   ├── (public)/            # Public pages (terms, privacy, about)
│   │   │   └── api/
│   │   │       ├── auth/[...nextauth]/ # NextAuth endpoints
│   │   │       ├── home/agent/      # Home chat agent API
│   │   │       └── news/agent/      # News agent API
│   │   ├── mastra/
│   │   │   ├── agents/              # AI agent definitions
│   │   │   │   ├── news-curation-agent.ts
│   │   │   │   └── determine-tags-agent.ts
│   │   │   ├── tools/               # Agent tools
│   │   │   └── lib/storage.ts       # Memory storage
│   │   ├── lib/
│   │   │   ├── apiClient.ts         # Centralized API client
│   │   │   └── zod.ts               # Validation schemas
│   │   ├── types/
│   │   │   └── next-auth.d.ts       # NextAuth type extensions
│   │   └── middleware.ts            # Auth middleware
│   ├── package.json
│   ├── next.config.ts
│   └── biome.json
│
├── culture_rails/                    # Rails Backend
│   ├── app/
│   │   ├── controllers/api/v1/
│   │   │   ├── sessions_controller.rb       # Auth (login/logout)
│   │   │   ├── users_controller.rb          # User registration
│   │   │   ├── user_attributes_controller.rb # User profile
│   │   │   ├── articles_controller.rb       # Article CRUD
│   │   │   ├── activities_controller.rb     # Article ratings
│   │   │   ├── tags_controller.rb           # Tag listing
│   │   │   ├── tag_search_histories_controller.rb
│   │   │   ├── feeds_controller.rb          # RSS feed management
│   │   │   └── ping_controller.rb           # Health check
│   │   ├── models/
│   │   │   ├── user.rb
│   │   │   ├── user_credential.rb
│   │   │   ├── article.rb
│   │   │   ├── tag.rb
│   │   │   ├── article_tagging.rb
│   │   │   ├── activity.rb
│   │   │   ├── feed.rb
│   │   │   ├── tag_search_history.rb
│   │   │   └── json_web_token.rb            # JWT utilities
│   │   └── views/                            # JB JSON templates
│   ├── db/
│   │   ├── migrate/                          # Migrations
│   │   └── schema.rb
│   ├── spec/                                 # RSpec tests
│   ├── doc/openapi.yml                       # OpenAPI specification
│   ├── Gemfile
│   ├── docker-compose.yml
│   ├── Dockerfile
│   └── dip.yml
│
├── culture-infra/                    # Terraform Infrastructure
│   ├── service/
│   │   ├── culture-web/
│   │   │   ├── environments/
│   │   │   │   ├── production/
│   │   │   │   └── staging/
│   │   │   └── modules/culture-web/
│   │   └── culture-rails/
│   │       ├── environments/
│   │       │   ├── production/
│   │       │   └── staging/
│   │       └── modules/culture-rails/
│   └── README.md
│
├── .github/workflows/                # CI/CD Pipelines
│   ├── deploy-culture-web-production.yml
│   ├── deploy-culture-web-staging.yml
│   ├── deploy-culture-rails-production.yml
│   └── deploy-culture-rails-staging.yml
│
├── README.md                         # Project documentation
├── CLAUDE.md                         # This file
└── DEPLOYMENT_SECRET_SETUP.md        # Secret Manager setup guide
```

## 🔧 Development Commands

### Frontend Development (culture-web)

```bash
cd culture-web
npm install          # Install dependencies
npm run dev          # Development server (http://localhost:3030)
npm run build        # Production build
npm run start        # Production server
npm run lint         # Biome linting
npm run format       # Biome formatting
```

### Backend Development (culture_rails)

```bash
# Using Dip (recommended)
dip provision        # Initial setup: DB + dependencies + migration
dip rails s          # Start Rails server (http://localhost:3000)
dip c               # Rails console
dip rspec           # Run RSpec tests
dip rubocop         # RuboCop linting
dip brakeman        # Security scanning
dip bundle          # Bundle commands
dip rails db:migrate # Run migrations
dip rails db:seed    # Seed database

# Direct Docker Compose
docker-compose up    # Start all services
docker-compose down  # Stop all services
```

### Infrastructure Management

```bash
cd culture-infra/service/culture-web/environments/production
terraform init -backend-config=backend.hcl
terraform plan       # Preview changes
terraform apply      # Apply infrastructure changes
terraform output     # View outputs (service URLs, etc.)
```

## 📊 Database Schema

### Core Tables

```sql
users                          # Identity core
├── id (PK)
├── human_id (unique, external reference)
├── created_at, updated_at

user_credentials              # Authentication
├── id (PK)
├── user_id (FK → users.id, 1:1)
├── email_address (unique)
├── password_digest (bcrypt)
├── created_at, updated_at

articles                      # Article content
├── id (PK)
├── title, summary, content
├── content_format (text/html/markdown)
├── author, source_url, image_url
├── published (boolean), published_at
├── created_at, updated_at

tags                          # Tag master
├── id (PK)
├── name
├── category (tech/art/music/sports/business/science/lifestyle/other)
├── created_at, updated_at

article_taggings              # Article-Tag relationship
├── article_id (FK → articles.id)
├── tag_id (FK → tags.id)
├── created_at, updated_at

activities                    # User evaluation history
├── id (PK)
├── user_id (FK → users.id)
├── article_id (FK → articles.id)
├── activity_type (0: good, 1: bad)
├── action (0: add, 1: remove)
├── created_at, updated_at

tag_search_histories          # Tag search tracking
├── id (PK)
├── user_id (FK → users.id)
├── tag_id (FK → tags.id)
├── created_at, updated_at

feeds                         # RSS feed sources
├── id (PK)
├── name, url, category
├── last_fetched_at
├── created_at, updated_at
```

## 🔌 API Endpoints

### Authentication

| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| POST | `/api/v1/users` | User registration | No |
| POST | `/api/v1/sessions` | Login (JWT token) | No |
| DELETE | `/api/v1/sessions` | Logout | Yes |
| GET | `/api/v1/user_attributes` | Get user profile | Yes |

### Articles

| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| GET | `/api/v1/articles` | List articles | Yes |
| GET | `/api/v1/articles/:id` | Get article detail | Yes |
| POST | `/api/v1/articles` | Create article | Yes |
| PUT/PATCH | `/api/v1/articles/:id` | Update article | Yes |
| DELETE | `/api/v1/articles/:id` | Delete article | Yes |

### Ratings & Activities

| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| POST | `/api/v1/articles/:article_id/activities` | Rate article (good/bad) | Yes |

**Rating Logic**:
- Good evaluation auto-removes existing Bad evaluation
- Bad evaluation auto-removes existing Good evaluation
- Implemented in Activity model, not controller

### Tags & Search

| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| GET | `/api/v1/tags` | List all tags | Yes |
| POST | `/api/v1/tag_search_histories` | Save tag search | Yes |
| GET | `/api/v1/tag_search_histories/articles` | Get articles by search history | Yes |

### Feeds

| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| GET | `/api/v1/feeds` | List feeds | Yes |
| POST | `/api/v1/feeds` | Create feed | Yes |
| POST | `/api/v1/feeds/:id/fetch` | Fetch single feed | Yes |
| POST | `/api/v1/feeds/batch_fetch` | Batch fetch feeds | Yes |

For complete API specification, see `culture_rails/doc/openapi.yml`

## 🤖 AI Agent Integration

### Mastra Framework Setup

The project uses Mastra Framework for AI agent orchestration with Google Gemini 2.0 Flash.

**Key Files**:
- `culture-web/src/mastra/index.ts` - Mastra instance configuration
- `culture-web/src/mastra/agents/news-curation-agent.ts` - News curation agent
- `culture-web/src/mastra/agents/determine-tags-agent.ts` - Tag determination agent
- `culture-web/src/mastra/tools/` - Agent tool definitions

**API Routes**:
- `/api/home/agent` - Home chat agent endpoint
- `/api/news/agent` - News agent endpoint

**Usage Pattern**:
```typescript
import { mastra } from '@/mastra';

const agent = mastra.getAgent('newsCurationAgent');
const response = await agent.generate(userMessage);
```

## 🚀 Deployment Architecture

### Infrastructure Diagram

<img width="6212" height="3068" alt="image" src="https://github.com/user-attachments/assets/dda1bd63-85c5-48e2-bbad-81ee5bfcff9b" />

### Environments

| Environment | Service | URL Pattern | Resources | Auto Deploy |
|------------|---------|-------------|-----------|-------------|
| **Staging** | culture-web-staging | `*.run.app` | 2 CPU / 2Gi | main branch push |
| **Staging** | culture-rails-staging | `*.run.app` | 2 CPU / 2Gi | main branch push |
| **Production** | culture-web-prod | `*.run.app` | 4 CPU / 4Gi | Manual trigger |
| **Production** | culture-rails-prod | `*.run.app` | 4 CPU / 4Gi | Manual trigger |

### CI/CD Pipeline (GitHub Actions)

**Workflow Files**:
- `deploy-culture-web-production.yml` - Frontend production deployment (manual)
- `deploy-culture-web-staging.yml` - Frontend staging deployment (auto on main push)
- `deploy-culture-rails-production.yml` - Backend production deployment (manual)
- `deploy-culture-rails-staging.yml` - Backend staging deployment (auto on main push)

**Deployment Process**:
1. Multi-stage Docker image build
2. Push to Google Artifact Registry
3. Deploy to Cloud Run with environment variables from Secret Manager
4. Automatic release tagging (production only)
5. Output deployment URL

**Deployment Flow**:
- **Staging**: Automatically deployed when changes are pushed to `main` branch
- **Production**: Manually triggered via GitHub Actions workflow dispatch (includes automatic release tagging)

### Container Strategy

- **Multi-stage builds**: Separate build and runtime stages
- **Platform**: Linux/AMD64 for Cloud Run compatibility
- **Security**: Non-root user execution, Secret Manager integration
- **Size optimization**: Standalone Next.js output, minimal base images

## 🏆 Development Best Practices

### Code Quality Standards

- **Rails**: RuboCop Rails Omakase (opinionated styling)
- **Frontend**: Biome for unified TypeScript linting + formatting
- **Security**: Brakeman security scanning
- **Testing**: Comprehensive RSpec + Committee Rails OpenAPI validation

### Rails API Development Guidelines

1. **RESTful Design**: Use only standard Rails actions (index, show, create, update, destroy)
2. **No Service Classes**: All business logic in models (app/models/)
3. **OpenAPI Compliance**: Every endpoint must have OpenAPI schema with `additionalProperties: false`
4. **TDD Approach**: Write tests before implementation
5. **Committee Rails**: Automatic request/response validation

See `culture_rails/CLAUDE.md` for detailed Rails development guidelines.

### Frontend Patterns

- **App Router**: Leverage Server Components and Parallel Routes
- **API Client**: Always use `lib/apiClient.ts` instead of direct fetch
- **Type Safety**: Strict TypeScript with Zod validation
- **Component Organization**: Co-locate styles, actions, components, drivers
- **Authentication**: NextAuth v5 with JWT token from Rails

## 🔒 Security Considerations

- **Authentication**: bcrypt password hashing + JWT token-based auth
- **CORS**: Rails configured to allow Next.js frontend origin only
- **Environment Variables**: Secret Manager for production credentials
- **CSRF**: Disabled for API endpoints (token-based auth instead)
- **HTTPS**: Cloud Run enforces HTTPS connections
- **Security Scanning**: Brakeman runs on Rails codebase

## 📝 Important Notes for AI Assistants

### Current Implementation Status

✅ **Completed**:
- NextAuth v5 authentication system
- Rails JWT authentication (sessions, users, user_attributes)
- Article CRUD operations
- Article rating system (Good/Bad with exclusive logic)
- Tag management and search
- Tag search history tracking
- Feed management (RSS sources)
- AI agent integration (Mastra + Gemini)
- Parallel Routes UI (home with @articles and @chatSideBar)
- Dark mode support
- Production/Staging deployment pipelines

🚧 **In Development/Future**:
- Advanced personalization algorithms
- More AI agent types
- Real-time notifications
- Article recommendation engine improvements

### Key Configuration Files

- **Rails**: `culture_rails/config/application.rb` - Main Rails config
- **Next.js**: `culture-web/next.config.ts` - Standalone output enabled
- **Auth**: `culture-web/src/auth.ts` - NextAuth configuration
- **API Client**: `culture-web/src/lib/apiClient.ts` - Centralized API calls
- **OpenAPI**: `culture_rails/doc/openapi.yml` - API specification
- **Docker**: `culture_rails/docker-compose.yml` - Local development
- **Infrastructure**: `culture-infra/service/*/modules/` - Terraform modules

### Common Development Tasks

1. **Adding API endpoints**:
   - Create OpenAPI schema in `doc/openapi.yml`
   - Create controller in `culture_rails/app/controllers/api/v1/`
   - Create JB view template in `culture_rails/app/views/api/v1/`
   - Write RSpec tests with Committee Rails validation

2. **Frontend pages**:
   - Add to `culture-web/src/app/`
   - Use appropriate route group: (anonymous), (authorized), (public)
   - Follow co-location pattern: _components, _actions, _styles, _drivers

3. **Database changes**:
   - Create migration: `dip rails g migration MigrationName`
   - Run migration: `dip rails db:migrate`
   - Update `spec/factories/` for testing

4. **AI Agent modifications**:
   - Edit agents in `culture-web/src/mastra/agents/`
   - Update tools in `culture-web/src/mastra/tools/`
   - API routes in `culture-web/src/app/api/*/agent/`

5. **Infrastructure changes**:
   - Modify Terraform in `culture-infra/service/*/modules/`
   - Apply environment-specific changes in `environments/production|staging/`

### Testing Strategy

- **Backend**: RSpec with FactoryBot for unit/integration tests
- **API Validation**: Committee Rails for automatic OpenAPI compliance checking
- **Frontend**: No testing framework currently configured (consider adding Vitest)
- **E2E**: Manual testing currently (consider adding Playwright)

### API Integration Guidelines

**Always use the centralized API client**:
```typescript
import { apiClient } from '@/lib/apiClient';

// Good ✅
const data = await apiClient.get('/articles');

// Bad ❌
const response = await fetch('/api/v1/articles');
```

**The API client handles**:
- JWT token injection from NextAuth session
- Error handling and logging
- Base URL configuration
- Type-safe responses with Zod validation

This project demonstrates enterprise-grade development practices suitable for rapid hackathon development with production-ready AI integration and cloud deployment capabilities.
