# YouTube Downloader GUI Launcher

$scriptPath = Join-Path $PSScriptRoot "scripts\YouTube_Downloader_GUI.ps1"

if (Test-Path $scriptPath) {
    Write-Host "🚀 Startar YouTube Downloader GUI..." -ForegroundColor Green
    & $scriptPath
} else {
    Write-Host "❌ FEL: Hittar inte GUI-skriptet på: $scriptPath" -ForegroundColor Red
    Write-Host ""
    Write-Host "Kontrollera att filen finns i scripts-mappen." -ForegroundColor Yellow
    Read-Host "Tryck Enter för att avsluta"
}
