# Phase 3 — Backend + Database

## Implemented
- ASP.NET Core Web API
- layered Domain/Application/Infrastructure/API structure
- Entity Framework Core
- PostgreSQL provider
- ContactMessage, Project, Service entities
- EF Core configurations and indexes
- public `POST /api/contact`
- `GET /api/system/info`
- `/health` health endpoint
- Swagger in development
- CORS for local Next.js frontend
- Docker backend service + PostgreSQL

## Deferred to Phase 4+
- authentication/authorization
- admin-only CRUD endpoints
- rate limiting
- email delivery
- audit logs
- production secrets
- reverse proxy / HTTPS

## Security note
Do not expose contact-message listing endpoints before admin authentication is implemented.
