# Netsera Backend — Phase 3

ASP.NET Core Web API with EF Core and PostgreSQL.

## Projects
- `Netsera.Domain` — entities
- `Netsera.Application` — DTOs, interfaces, services
- `Netsera.Infrastructure` — EF Core/PostgreSQL
- `Netsera.Api` — HTTP API

## Local validation
```powershell
cd backend
dotnet restore
dotnet build
```

## Create the first migration
Install the EF CLI once if needed:
```powershell
dotnet tool install --global dotnet-ef --version 8.*
```

Then:
```powershell
cd backend
dotnet ef migrations add InitialCreate `
  --project src/Netsera.Infrastructure `
  --startup-project src/Netsera.Api `
  --output-dir Persistence/Migrations

dotnet ef database update `
  --project src/Netsera.Infrastructure `
  --startup-project src/Netsera.Api
```

Run API:
```powershell
dotnet run --project src/Netsera.Api
```

Swagger is available in Development mode at `/swagger`.
