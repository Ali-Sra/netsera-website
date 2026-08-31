# APPLY-MOBILE-PHASE2

## What this does

This script creates the Netsera mobile foundation inside the existing repository:

- `mobile/`
- Expo
- React Native
- TypeScript
- Expo Router
- `src/api`
- `src/components`
- `src/constants`
- `src/theme`
- `src/types`
- `.env`
- `.env.example`

It does **not** modify the existing backend or frontend application.

## How to use

1. Copy `APPLY-MOBILE-PHASE2.ps1` into the root of `netsera-website`.
2. Open PowerShell in that folder.
3. Run:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\APPLY-MOBILE-PHASE2.ps1
```

4. When it finishes:

```powershell
cd mobile
npx expo start
```

## Important

If `mobile/` already exists, the script stops instead of overwriting it.
