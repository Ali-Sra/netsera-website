# Architecture

## High-level flow

Browser -> Next.js frontend -> ASP.NET Core API -> PostgreSQL

Supporting concerns:
- HTTPS / reverse proxy
- authentication and authorization
- logging and monitoring
- CI/CD
- backups

## Principles
- separation of concerns
- strong typing
- secure defaults
- incremental delivery
- avoid unnecessary complexity
