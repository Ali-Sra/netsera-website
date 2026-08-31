$ErrorActionPreference = "Stop"

Write-Host "==> Netsera Mobile - Phase 6 Fix" -ForegroundColor Cyan

if (-not (Test-Path ".\mobile\package.json")) {
    throw "Run this script from the netsera-website repository root."
}

$mobile = ".\mobile"
$packagePath = "$mobile\package.json"

Write-Host "==> Fixing package.json quality scripts" -ForegroundColor Yellow

$pkg = Get-Content -LiteralPath $packagePath -Raw | ConvertFrom-Json

if (-not $pkg.scripts) {
    $pkg | Add-Member -MemberType NoteProperty -Name scripts -Value ([pscustomobject]@{})
}

function Set-ScriptProperty {
    param(
        [Parameter(Mandatory=$true)][object]$Scripts,
        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$true)][string]$Value
    )

    if ($Scripts.PSObject.Properties.Name -contains $Name) {
        $Scripts.$Name = $Value
    } else {
        $Scripts | Add-Member -MemberType NoteProperty -Name $Name -Value $Value
    }
}

Set-ScriptProperty -Scripts $pkg.scripts -Name "typecheck" -Value "tsc --noEmit"
Set-ScriptProperty -Scripts $pkg.scripts -Name "quality" -Value "npm run typecheck"
Set-ScriptProperty -Scripts $pkg.scripts -Name "start:clear" -Value "expo start -c"

$pkg | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $packagePath -Encoding UTF8

Write-Host "==> Ensuring production readiness documentation exists" -ForegroundColor Yellow

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

## Current local development

A physical phone can continue using a LAN API URL in `.env`, for example:

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
'@

Set-Content -LiteralPath "$mobile\README-PHASE6.md" -Value $readme -Encoding UTF8

Write-Host "==> Ensuring local .env is ignored" -ForegroundColor Yellow

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
        Write-Host ""
        Write-Host "Expo Doctor reported warnings/errors. Send me the output and I will fix them." -ForegroundColor Yellow
    }
}
finally {
    Pop-Location
}

Write-Host ""
Write-Host "==> Phase 6 fix completed successfully" -ForegroundColor Green
Write-Host "    package.json updated" -ForegroundColor Green
Write-Host "    TypeScript check passed" -ForegroundColor Green
Write-Host ""
Write-Host "For local testing:" -ForegroundColor Cyan
Write-Host "  cd mobile"
Write-Host "  npm run start:clear"
