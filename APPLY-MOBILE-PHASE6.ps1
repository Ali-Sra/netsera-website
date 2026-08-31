$ErrorActionPreference = "Stop"

Write-Host "==> Netsera Mobile - Phase 6: Quality + Production Foundation" -ForegroundColor Cyan

if (-not (Test-Path ".\mobile\package.json")) {
    throw "Run this script from the netsera-website repository root."
}

$mobile = ".\mobile"

function Backup-IfExists([string]$Path) {
    if (Test-Path -LiteralPath $Path) {
        Copy-Item -LiteralPath $Path -Destination "$Path.phase6-backup" -Force
    }
}

Write-Host "==> Creating production-safe environment template" -ForegroundColor Yellow

$envExample = @'
# Local development on a physical phone:
# EXPO_PUBLIC_API_URL=http://192.168.x.x:8080

# Production MUST use HTTPS:
EXPO_PUBLIC_API_URL=https://api.netsera.de
'@
Set-Content -LiteralPath "$mobile\.env.example" -Value $envExample -Encoding UTF8

Write-Host "==> Hardening app config" -ForegroundColor Yellow

$appConfig = @'
const rawApiUrl = process.env.EXPO_PUBLIC_API_URL?.trim();

function normalizeBaseUrl(value: string) {
  return value.replace(/\/+$/, '');
}

export const appConfig = {
  apiBaseUrl: normalizeBaseUrl(rawApiUrl || 'http://localhost:8080'),
  requestTimeoutMs: 10000,
  isProductionApi: Boolean(rawApiUrl?.startsWith('https://')),
} as const;
'@

Backup-IfExists "$mobile\src\config\app.ts"
Set-Content -LiteralPath "$mobile\src\config\app.ts" -Value $appConfig -Encoding UTF8

Write-Host "==> Creating EAS build configuration" -ForegroundColor Yellow

$eas = @'
{
  "cli": {
    "version": ">= 16.0.0"
  },
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal"
    },
    "preview": {
      "distribution": "internal"
    },
    "production": {
      "autoIncrement": true
    }
  },
  "submit": {
    "production": {}
  }
}
'@
Set-Content -LiteralPath "$mobile\eas.json" -Value $eas -Encoding UTF8

Write-Host "==> Updating Expo app metadata conservatively" -ForegroundColor Yellow

$appJsonPath = "$mobile\app.json"
if (Test-Path -LiteralPath $appJsonPath) {
    Backup-IfExists $appJsonPath

    $json = Get-Content -LiteralPath $appJsonPath -Raw | ConvertFrom-Json

    if (-not $json.expo) {
        throw "app.json does not contain an 'expo' object."
    }

    $json.expo.name = "Netsera"
    $json.expo.slug = "netsera-mobile"
    $json.expo.version = "1.0.0"

    if (-not $json.expo.ios) {
        $json.expo | Add-Member -MemberType NoteProperty -Name ios -Value ([pscustomobject]@{})
    }
    if (-not $json.expo.android) {
        $json.expo | Add-Member -MemberType NoteProperty -Name android -Value ([pscustomobject]@{})
    }

    if (-not ($json.expo.ios.PSObject.Properties.Name -contains "bundleIdentifier")) {
        $json.expo.ios | Add-Member -MemberType NoteProperty -Name bundleIdentifier -Value "de.netsera.mobile"
    } else {
        $json.expo.ios.bundleIdentifier = "de.netsera.mobile"
    }

    if (-not ($json.expo.android.PSObject.Properties.Name -contains "package")) {
        $json.expo.android | Add-Member -MemberType NoteProperty -Name package -Value "de.netsera.mobile"
    } else {
        $json.expo.android.package = "de.netsera.mobile"
    }

    $json | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $appJsonPath -Encoding UTF8
}

Write-Host "==> Adding quality scripts to package.json" -ForegroundColor Yellow

$packagePath = "$mobile\package.json"
Backup-IfExists $packagePath

$nodeScript = @'
const fs = require("fs");

const path = process.argv[1];
const pkg = JSON.parse(fs.readFileSync(path, "utf8"));

pkg.scripts = pkg.scripts || {};
pkg.scripts.typecheck = "tsc --noEmit";
pkg.scripts["quality"] = "npm run typecheck";
pkg.scripts["start:clear"] = "expo start -c";

fs.writeFileSync(path, JSON.stringify(pkg, null, 2) + "\n");
'@

$nodeTemp = Join-Path $env:TEMP "netsera-phase6-package.cjs"
Set-Content -LiteralPath $nodeTemp -Value $nodeScript -Encoding UTF8
node $nodeTemp $packagePath
if ($LASTEXITCODE -ne 0) {
    throw "Could not update package.json."
}
Remove-Item -LiteralPath $nodeTemp -Force -ErrorAction SilentlyContinue

Write-Host "==> Creating production readiness documentation" -ForegroundColor Yellow

$readme = @'
# Netsera Mobile — Phase 6

Phase 6 establishes the production/build foundation without pretending the app
is already ready for App Store or Google Play submission.

## Added

- EAS build configuration
- iOS bundle identifier: `de.netsera.mobile`
- Android package: `de.netsera.mobile`
- production environment example
- normalized API base URL
- TypeScript quality script
- cache-clear start script
- backups of modified configuration files

## Current local development

Your physical phone can continue using a LAN API URL in `.env`, for example:

`EXPO_PUBLIC_API_URL=http://192.168.x.x:8080`

Do not commit a machine-specific `.env`.

## Before public store release

The production mobile app must use a public HTTPS backend, for example:

`EXPO_PUBLIC_API_URL=https://api.netsera.de`

Still required before store submission:

1. Real production HTTPS API/domain
2. Production PostgreSQL/secrets
3. App icon and splash assets
4. Privacy policy URL
5. Apple Developer account
6. Google Play Console account
7. EAS project initialization/login
8. Physical-device release testing
9. Store screenshots and listing text
10. Privacy/data-collection declarations

## Build commands later

After EAS is initialized:

`npx eas build --platform ios --profile production`

`npx eas build --platform android --profile production`

Do not run store submission until production HTTPS and privacy information are ready.
'@

Set-Content -LiteralPath "$mobile\README-PHASE6.md" -Value $readme -Encoding UTF8

Write-Host "==> Ensuring local env is ignored by Git" -ForegroundColor Yellow

$gitignorePath = "$mobile\.gitignore"
if (Test-Path -LiteralPath $gitignorePath) {
    $gitignore = Get-Content -LiteralPath $gitignorePath -Raw
} else {
    $gitignore = ""
}

if ($gitignore -notmatch "(?m)^\.env$") {
    Add-Content -LiteralPath $gitignorePath -Value "`n# Local environment`n.env`n" -Encoding UTF8
}

Write-Host "==> Running TypeScript check" -ForegroundColor Yellow

Push-Location $mobile
try {
    npx tsc --noEmit
    if ($LASTEXITCODE -ne 0) {
        throw "TypeScript check failed."
    }

    Write-Host "==> Running Expo Doctor" -ForegroundColor Yellow
    npx expo-doctor
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Expo Doctor reported warnings/errors. TypeScript is clean; review the doctor output before release." -ForegroundColor Yellow
    }
}
finally {
    Pop-Location
}

Write-Host ""
Write-Host "==> Phase 6 completed" -ForegroundColor Green
Write-Host "    Production/build foundation added." -ForegroundColor Green
Write-Host ""
Write-Host "IMPORTANT:" -ForegroundColor Yellow
Write-Host "  Local iPhone testing can keep using your LAN HTTP API."
Write-Host "  App Store / Google Play release must use a public HTTPS API."
Write-Host ""
Write-Host "To continue local testing:" -ForegroundColor Cyan
Write-Host "  cd mobile"
Write-Host "  npm run start:clear"
