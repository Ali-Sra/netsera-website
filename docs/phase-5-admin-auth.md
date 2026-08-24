# Phase 5 — Admin Authentication & Contact Dashboard

## Goal

Protect the first admin workflow with an HTTP-only authentication cookie and allow an authenticated administrator to read and update contact-message status.

## Implemented

- `admin_users` database entity
- password hashing with ASP.NET Core `PasswordHasher`
- initial admin bootstrap from environment variables
- HTTP-only cookie authentication
- secure-cookie policy in production
- role claim: `Admin`
- login rate limiting
- API-friendly 401/403 behavior
- CORS credentials support
- custom admin request header for state-changing admin API calls
- protected admin endpoints
- contact-message list
- message status: `New`, `Read`, `Archived`
- Next.js `/admin/login`
- Next.js `/admin` dashboard
- logout and session check

## Important security rule

Never commit a real admin password. Bootstrap credentials are supplied through environment variables only.

## Apply database migration

From `backend`:

```powershell
dotnet ef migrations add AddAdminAuth `
  --project .\src\Netsera.Infrastructure `
  --startup-project .\src\Netsera.Api `
  --output-dir Persistence\Migrations

dotnet ef database update `
  --project .\src\Netsera.Infrastructure `
  --startup-project .\src\Netsera.Api
```

## Local admin bootstrap

Before starting the backend in PowerShell:

```powershell
$env:ASPNETCORE_ENVIRONMENT="Development"
$env:AdminBootstrap__Email="your-admin-email@example.com"
$env:AdminBootstrap__Password="use-a-unique-password-at-least-12-chars"

dotnet run --project .\src\Netsera.Api
```

The admin is created only if that normalized e-mail does not already exist.

## Frontend

```powershell
cd frontend
npm run typecheck
npm run build
npm run dev
```

Open:

- `http://localhost:3000/admin/login`
- `http://localhost:3000/admin`

For local development, use `localhost` consistently instead of the VM/adapter IP so cookie/CORS behavior is predictable.

## Next phase

Admin CRUD for projects/services, stronger security hardening, audit logging, and tests.
