# Netsera Mobile — Phase 2 Continue

This package is for the Expo project that already exists in `netsera-website/mobile`.

## How to run

1. Stop Metro with `Ctrl+C`.
2. Copy `APPLY-MOBILE-PHASE2-CONTINUE.ps1` into the root of `netsera-website`.
3. In PowerShell, from the repository root, run:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\APPLY-MOBILE-PHASE2-CONTINUE.ps1
```

The script does **not** recreate the Expo project. It configures the existing SDK 54 app, backs up the original Expo template, adds the Netsera theme/API foundation, creates five tabs, and runs `tsc --noEmit`.

After it succeeds:

```powershell
cd mobile
npx expo start --tunnel
```

Then scan the new QR code with Expo Go on the iPhone.
