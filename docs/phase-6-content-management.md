# Phase 6 — Content Management

## Goal

Turn Projects and Services into database-backed content that can be managed from the authenticated admin area.

## Implemented

- public content API:
  - `GET /api/content/projects`
  - `GET /api/content/services`
- protected admin CRUD:
  - `/api/admin/projects`
  - `/api/admin/services`
- slug normalization and duplicate protection
- project soft delete
- publish/draft state
- display ordering
- admin pages:
  - `/admin/projects`
  - `/admin/services`
- shared admin navigation
- public Services and Projects sections load published database content
- fallback content remains visible when the database has no published records

## Database

No new migration is required in Phase 6 because `projects` and `services` tables already exist from Phase 3.

## Validation

Backend:

```powershell
cd backend
dotnet build
```

Frontend:

```powershell
cd frontend
npm run typecheck
npm run build
```

## Test

1. Run PostgreSQL and backend.
2. Login at `/admin/login`.
3. Create a Service and check `Veröffentlicht`.
4. Create a Project and check `Veröffentlicht`.
5. Open the public homepage.
6. Confirm published database content replaces the fallback content.
7. Edit, unpublish, reorder and delete content.

## Next phase

Testing, audit logging, security hardening and CI/CD.
