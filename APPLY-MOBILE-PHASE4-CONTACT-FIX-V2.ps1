$ErrorActionPreference = "Stop"

Write-Host "==> Netsera Mobile - Phase 4 Contact Fix V2" -ForegroundColor Cyan

if (-not (Test-Path ".\mobile\package.json")) {
    throw "Run this script from the netsera-website repository root."
}

$contactPath = ".\mobile\app\(tabs)\contact.tsx"

if (-not (Test-Path -LiteralPath $contactPath)) {
    throw "Contact screen not found: $contactPath"
}

Write-Host "==> Fixing unsupported theme color reference" -ForegroundColor Yellow

$content = Get-Content -LiteralPath $contactPath -Raw

# The current Netsera theme does not expose colors.accent.
# Use the existing Netsera cyan directly so this patch is independent of theme key names.
$content = $content.Replace("colors.accent", "'#62C7F5'")

Set-Content -LiteralPath $contactPath -Value $content -Encoding UTF8

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
Write-Host "==> V2 fix completed successfully" -ForegroundColor Green
Write-Host "Contact Phase 4 + iPhone keyboard scrolling are ready."
Write-Host ""
Write-Host "Restart Expo with cache cleared:" -ForegroundColor Yellow
Write-Host "  cd mobile"
Write-Host "  npx expo start --tunnel -c"
