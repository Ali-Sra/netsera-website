# Netsera Mobile — Phase 3

This package upgrades the Phase 2 foundation to a professional mobile UI.

It adds:
- reusable buttons, cards, section headers and feature cards
- typography tokens
- professional Home screen
- Services, Projects, Infrastructure and Contact screens
- consistent dark Netsera visual language
- responsive mobile layout
- no backend data is faked; real API integration remains for Phase 4

## Run

From the `netsera-website` repository root:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\APPLY-MOBILE-PHASE3.ps1
```

Then:

```powershell
cd mobile
npx expo start --tunnel
```
