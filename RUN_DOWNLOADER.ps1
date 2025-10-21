# YouTube Downloader - PowerShell Launcher
# Startar skriptet i en ren PowerShell-session

$scriptPath = Join-Path $PSScriptRoot "YouTube_Downloader_v8_INTERACTIVE.ps1"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "YouTube Downloader v8.0" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Kör skriptet i samma session
& $scriptPath

Write-Host "`nTryck valfri tangent för att avsluta..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
