# Phase 7 — Security Hardening & Audit Logging

## Goal

Strengthen the existing API without changing the public product workflow, and add a durable audit trail for important administrator actions.

## Implemented

- database-backed `audit_logs`
- audit records for:
  - admin login
  - admin logout
  - contact-message status changes
  - project create/update/delete
  - service create/update/delete
- audit metadata intentionally excludes:
  - passwords
  - authentication cookies
  - tokens
  - contact-message body text
- protected audit-log endpoint:
  - `GET /api/admin/audit-logs`
- global exception middleware
- generic Problem Details response with `traceId`
- security response headers
- stricter public contact-form rate limiting
- existing admin-login rate limiting retained
- forwarded-header support for future reverse proxy
- health endpoints:
  - `/health/live`
  - `/health/ready`
  - `/health`
- PostgreSQL readiness health check

## Database migration

Phase 7 adds `audit_logs`, so create and apply a migration:

```powershell
cd backend

dotnet ef migrations add AddAuditLogging `
  --project .\src\Netsera.Infrastructure `
  --startup-project .\src\Netsera.Api `
  --output-dir Persistence\Migrations

dotnet ef database update `
  --project .\src\Netsera.Infrastructure `
  --startup-project .\src\Netsera.Api
```

## Validate

```powershell
dotnet build
```

Run backend:

```powershell
$env:ASPNETCORE_ENVIRONMENT="Development"
dotnet run --project .\src\Netsera.Api
```

Test:

- `http://localhost:5000/health`
- `http://localhost:5000/health/live`
- `http://localhost:5000/health/ready`
- Swagger in Development

Then login to the admin UI and perform one project/service/status action.

To inspect audit logs through PostgreSQL:

```sql
SELECT "ActorEmail", "Action", "EntityType", "EntityId", "Metadata", "CreatedAtUtc"
FROM audit_logs
ORDER BY "CreatedAtUtc" DESC;
```

Or use the authenticated API:

`GET /api/admin/audit-logs`

## Security notes

This phase improves the application baseline, but production security still depends on:
- HTTPS termination
- a real secret store
- database credentials unique to production
- restricted network exposure
- correct reverse-proxy configuration
- OS/container patching
- monitoring and alerting

## Next phase

Automated unit, integration, authentication and authorization tests.
