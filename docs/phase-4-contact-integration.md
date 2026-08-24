# Phase 4 — Frontend ↔ API Contact Integration

## Goal

Connect the public Next.js contact form to the ASP.NET Core API and persist submitted messages in PostgreSQL.

## Implemented

- reusable client-side `ContactForm`
- fields matching backend validation: name, email, optional subject, message
- POST request to `/api/contact`
- loading, success and error states
- accessible `aria-live` status feedback
- environment-based API base URL
- local development default: `http://localhost:5000/api`
- successful submissions are stored through EF Core in PostgreSQL

## Local run

Terminal 1 — PostgreSQL:

```powershell
docker compose up -d postgres
```

Terminal 2 — backend:

```powershell
cd backend
$env:ASPNETCORE_ENVIRONMENT="Development"
dotnet run --project .\src\Netsera.Api
```

Terminal 3 — frontend:

```powershell
cd frontend
Copy-Item .env.example .env.local
npm run dev
```

Open `http://localhost:3000`, submit the contact form, and confirm a success reference is displayed.

## Validation

Frontend:

```powershell
cd frontend
npm run typecheck
npm run build
```

Backend:

```powershell
cd backend
dotnet build
```

## Next phase

Authentication and the first protected admin workflow for reading contact messages.
