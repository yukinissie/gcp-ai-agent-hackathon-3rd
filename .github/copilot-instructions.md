# GitHub Copilot Instructions

This document provides context for GitHub Copilot to generate appropriate code suggestions for the Culture project.

## Language Preference

**IMPORTANT: Always respond in Japanese (日本語) when providing explanations, comments, or documentation.**

- Code comments should be in Japanese
- Commit messages should be in Japanese
- Error messages and logs should be in Japanese where appropriate
- Documentation and explanations should be in Japanese
- Variable names and function names should remain in English (standard programming convention)

## Project Type
AI-powered news curation platform with Next.js frontend and Rails API backend.

## Tech Stack Overview

### Frontend (culture-web)
- **Framework**: Next.js 15.5 + React 19 + TypeScript (strict mode)
- **Router**: App Router with Parallel Routes (@articles, @chatSideBar)
- **UI**: Radix UI + CSS Modules + Radix Colors
- **Linting**: Biome 2.2.4 (not ESLint or Prettier)
- **Auth**: NextAuth v5 with JWT tokens
- **AI**: Mastra Framework + Google Gemini 2.0 Flash + @ai-sdk
- **API Client**: Centralized in `src/lib/apiClient.ts`

### Backend (culture_rails)
- **Framework**: Rails 8.0+ API mode
- **Database**: PostgreSQL 15+
- **Auth**: Custom JWT (JsonWebToken class)
- **Views**: JBuilder (jb gem) for JSON responses
- **Validation**: Committee Rails for OpenAPI compliance
- **Linting**: RuboCop Rails Omakase
- **Testing**: RSpec + FactoryBot

## Code Style Guidelines

### TypeScript/React
```typescript
// ✅ Use centralized API client
import { apiClient } from '@/lib/apiClient';
const articles = await apiClient.get('/articles');

// ❌ Don't use direct fetch
const response = await fetch('/api/v1/articles');

// ✅ Use Zod for validation
import { z } from 'zod';
const schema = z.object({ id: z.number() });

// ✅ Server Components by default
export default async function Page() { }

// ✅ Client Components when needed
'use client';
export default function InteractiveComponent() { }

// ✅ Co-locate files by feature
// app/feature/_components/, _actions/, _styles/, _drivers/
```

### Rails
```ruby
# ✅ RESTful controllers only (index, show, create, update, destroy)
class Api::V1::ArticlesController < ApplicationController
  def index; end
  def show; end
end

# ❌ No custom actions or service classes
# ✅ Business logic in models
class Article < ApplicationRecord
  def publish!
    update!(published: true, published_at: Time.current)
  end
end

# ✅ Use JBuilder for JSON views
# app/views/api/v1/articles/show.json.jb
json = {
  id: article.id,
  title: article.title
}

# ✅ Use Committee Rails for validation
it 'returns valid response', :committee do
  get api_v1_article_path(article)
  assert_request_schema_confirm
  assert_response_schema_confirm
end
```

## File Organization

### Frontend Structure
```
culture-web/src/app/
├── (anonymous)/          # Login/Register pages
├── (authorized)/         # Protected pages
│   ├── home/
│   │   ├── @articles/    # Parallel route slot
│   │   ├── @chatSideBar/ # Parallel route slot
│   │   └── layout.tsx
│   └── articles/[id]/
├── (public)/            # Public pages (terms, privacy)
└── api/
    ├── auth/[...nextauth]/
    └── home/agent/      # AI agent endpoints
```

### Backend Structure
```
culture_rails/app/
├── controllers/api/v1/  # Only RESTful actions
├── models/              # All business logic here
└── views/api/v1/        # JBuilder templates (.jb)
```

## Common Patterns

### API Integration
```typescript
// Always use the centralized API client
import { apiClient } from '@/lib/apiClient';

// GET request
const articles = await apiClient.get('/articles');

// POST request
const newArticle = await apiClient.post('/articles', {
  title: 'Title'
});

// Error handling is automatic
try {
  await apiClient.get('/articles');
} catch (error) {
  // Automatically handles 401, 403, etc.
}
```

### Authentication
```typescript
// Frontend: Get session
import { auth } from '@/auth';
const session = await auth();

// Backend: Require authentication
class Api::V1::ArticlesController < ApplicationController
  before_action :require_login  # From ApplicationController
end
```

### Database Queries
```ruby
# ✅ Use includes to avoid N+1
Article.includes(:tags).where(published: true)

# ✅ Use scopes in models
class Article < ApplicationRecord
  scope :published, -> { where(published: true) }
  scope :recent, -> { order(published_at: :desc) }
end

# ✅ Chain scopes
Article.published.recent.limit(10)
```

### AI Agent Usage
```typescript
// Use Mastra agents
import { mastra } from '@/mastra';

const agent = mastra.getAgent('newsCurationAgent');
const response = await agent.generate(message, {
  threadId: session.user.id
});
```

## Important Conventions

### Database
- User identity: `users.human_id` for external references, not `users.id`
- Timestamps: Always use `created_at`, `updated_at`
- Enums: Use integer enums (Activity: 0=good, 1=bad)
- Foreign Keys: Always add `foreign_key: true` and `null: false`

### API Responses
- Success: Return appropriate HTTP status (200, 201)
- Errors: Rails handles with proper status codes
- Format: JSON only, use JBuilder templates
- Validation: Must match OpenAPI schema in `doc/openapi.yml`

### Environment Variables
```bash
# Frontend (.env.local)
NEXT_PUBLIC_API_BASE_URL=http://localhost:3000/api/v1
NEXTAUTH_SECRET=xxx
GOOGLE_GENERATIVE_AI_API_KEY=xxx

# Backend (.env)
DATABASE_URL=postgresql://localhost/culture_development
JWT_SECRET_KEY=xxx
```

## Testing Guidelines

### RSpec
```ruby
# Use FactoryBot
let(:user) { create(:user) }

# Use Committee Rails for API validation
it 'returns valid response', :committee do
  get api_v1_articles_path
  expect(response).to have_http_status(:ok)
  assert_response_schema_confirm
end

# Test authentication
context 'when not authenticated' do
  it { expect(response).to have_http_status(:unauthorized) }
end
```

## DON'Ts

❌ Don't create service classes in Rails - use models
❌ Don't add custom controller actions - use RESTful routes only
❌ Don't use `fetch` directly - use `apiClient`
❌ Don't use ESLint/Prettier - use Biome
❌ Don't skip OpenAPI schema definitions
❌ Don't use `users.id` for external references - use `users.human_id`
❌ Don't commit secrets - use Secret Manager

## DOs

✅ Use Server Components by default
✅ Add `'use client'` only when needed (hooks, events)
✅ Use Parallel Routes for complex layouts
✅ Follow RESTful conventions strictly
✅ Write OpenAPI schemas with `additionalProperties: false`
✅ Use Committee Rails for API testing
✅ Put business logic in models
✅ Use centralized API client
✅ Use Biome for linting/formatting
✅ Use Zod for validation

## Quick Reference

### Start Development
```bash
# Frontend
cd culture-web && npm run dev

# Backend
cd culture_rails && dip rails s
# or: docker-compose up
```

### Common Commands
```bash
# Frontend
npm run lint       # Biome check
npm run format     # Biome format

# Backend
dip rails c        # Console
dip rspec          # Run tests
dip rubocop        # Lint
dip rails db:migrate
```

### Key Files
- Frontend API Client: `culture-web/src/lib/apiClient.ts`
- Auth Config: `culture-web/src/auth.ts`
- OpenAPI Spec: `culture_rails/doc/openapi.yml`
- Mastra Agents: `culture-web/src/mastra/agents/`

For complete project context, see `CLAUDE.md` at the repository root.
