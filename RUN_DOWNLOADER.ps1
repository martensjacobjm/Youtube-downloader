# YouTube Downloader - PowerShell Launcher
# Startar skriptet i en ren PowerShell-session

$scriptPath = Join-Path $PSScriptRoot "scripts\YouTube_Downloader_v8_INTERACTIVE.ps1"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "YouTube Downloader v8.0" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Kontrollera att scriptet finns
if (-not (Test-Path $scriptPath)) {
    Write-Host "`nFEL: Hittar inte scriptet!" -ForegroundColor Red
    Write-Host "Letar efter: $scriptPath" -ForegroundColor Yellow
    Write-Host "`nTryck valfri tangent för att avsluta..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

# Kör skriptet i samma session
try {
    & $scriptPath
} catch {
    Write-Host "`nFEL UPPSTOD!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Yellow
}

Write-Host "`nTryck valfri tangent för att avsluta..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
