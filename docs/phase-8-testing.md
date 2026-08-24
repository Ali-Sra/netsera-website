# Phase 8 — Automated Testing

## Goal

Add repeatable automated tests for the most important backend behavior without touching the developer's Docker PostgreSQL database.

## Test stack

- xUnit
- Microsoft.AspNetCore.Mvc.Testing
- WebApplicationFactory<Program>
- EF Core InMemory
- coverlet collector

## Covered scenarios

- valid contact request returns 201 and persists data
- invalid contact request returns 400
- contact data normalization
- health endpoints return 200
- anonymous admin request returns 401
- invalid login returns 401
- authenticated admin can access messages
- security headers are present
- successful admin login creates an audit record

## Run

From `backend`:

```powershell
dotnet restore
dotnet build
dotnet test
```

Detailed output:

```powershell
dotnet test --logger "console;verbosity=normal"
```

Coverage:

```powershell
dotnet test --collect:"XPlat Code Coverage"
```

## Important

The tests replace PostgreSQL with an EF Core InMemory database only inside the test host. Your Docker PostgreSQL database and real data are not modified.

## Next phase

GitHub Actions CI and production Docker/reverse-proxy preparation.
