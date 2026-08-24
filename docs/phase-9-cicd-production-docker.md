# Phase 9 — CI/CD Foundation + Production Docker + Reverse Proxy

## Goal

Create a production-like container architecture and automatic CI validation without deploying to the public internet yet.

## Architecture

```text
Browser
  |
  v
Nginx :80
  |----------------------|
  v                      v
Next.js :3000        ASP.NET Core :8080
                         |
                         v
                    PostgreSQL :5432
```

PostgreSQL is on an internal Docker network and is not published to the host.

## Added

- multi-stage production frontend Dockerfile
- Next.js standalone output
- hardened multi-stage backend Dockerfile
- non-root users in frontend/backend images
- production Compose file
- Nginx reverse proxy
- private PostgreSQL network
- same-origin `/api` routing
- GitHub Actions CI:
  - backend restore/build/test
  - frontend npm ci/typecheck/build
  - Docker image build validation
- production environment example

## Important: database migrations

Phase 9 does not automatically run EF migrations at application startup.

Before a real deployment, migrations should be executed as a controlled deployment step. Phase 10 will finalize that deployment procedure.

For the local production-like test, the database already contains the Phase 1–8 migrations from development.

## Local production-like test

From the repository root:

```powershell
Copy-Item .env.production.example .env.production
```

Edit `.env.production` and replace the placeholder passwords.

Then:

```powershell
docker compose --env-file .env.production -f docker-compose.prod.yml build
docker compose --env-file .env.production -f docker-compose.prod.yml up -d
docker compose --env-file .env.production -f docker-compose.prod.yml ps
```

Open:

```text
http://localhost:8088
```

Health:

```text
http://localhost:8088/health
http://localhost:8088/health/live
http://localhost:8088/health/ready
```

Admin:

```text
http://localhost:8088/admin/login
```

## CI

After pushing the Phase 9 commit, GitHub Actions should automatically run the `CI` workflow.

The pipeline intentionally does not require production secrets because it only restores, builds, tests and validates Docker image builds.

## Security

- PostgreSQL has no host port in production Compose.
- Backend and frontend are only exposed to Nginx through Docker networks.
- real secrets are not stored in source control.
- public API traffic uses a same-origin `/api` path.
- TLS is intentionally deferred to Phase 10 deployment.

## Next phase

Phase 10:
- real deployment architecture
- DNS/domain
- HTTPS/TLS
- controlled EF migration deployment
- backups
- monitoring/log retention
- production secret handling
- update/rollback procedure
