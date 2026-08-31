$ErrorActionPreference = "Stop"

Write-Host "==> Netsera Mobile - Phase 5 Fix" -ForegroundColor Cyan

if (-not (Test-Path ".\mobile\package.json")) {
    throw "Run this script from the netsera-website repository root."
}

$infraPath = ".\mobile\app\(tabs)\infra.tsx"

if (-not (Test-Path -LiteralPath $infraPath)) {
    throw "Infrastructure screen was not found: $infraPath"
}

Write-Host "==> Fixing unsupported colors.accent references" -ForegroundColor Yellow

$content = Get-Content -LiteralPath $infraPath -Raw

# The existing Netsera theme does not define colors.accent.
# Use the same cyan visual role locally without changing the shared theme.
$content = $content.Replace("colors.accent", "'#22D3EE'")

Set-Content -LiteralPath $infraPath -Value $content -Encoding UTF8

Write-Host "==> Running TypeScript check" -ForegroundColor Yellow

Push-Location ".\mobile"
try {
    npx tsc --noEmit
    if ($LASTEXITCODE -ne 0) {
        throw "TypeScript check failed."
    }
}
finally {
    Pop-Location
}

Write-Host ""
Write-Host "==> Phase 5 fix completed successfully" -ForegroundColor Green
Write-Host "    TypeScript check passed." -ForegroundColor Green
Write-Host ""
Write-Host "Restart Expo with cache cleared:" -ForegroundColor Yellow
Write-Host "  cd mobile"
Write-Host "  npx expo start --tunnel -c"
