# Sync-Source.ps1
# Synkroniserar källfiler från utvecklingsmappen till installation/src/

$ErrorActionPreference = "Stop"

# installation/installer/ -> installation/ -> Youtube-downloader/
$InstallationRoot = Split-Path -Parent $PSScriptRoot
$ProjectRoot = Split-Path -Parent $InstallationRoot

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Synkroniserar källfiler..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Källfiler i projektroten
$DevScriptsDir = Join-Path $ProjectRoot "scripts"
$InstallSrcDir = Join-Path $InstallationRoot "src\scripts"

# Skapa destination om den inte finns
if (-not (Test-Path $InstallSrcDir)) {
    New-Item -ItemType Directory -Path $InstallSrcDir -Force | Out-Null
    Write-Host "Skapade: $InstallSrcDir" -ForegroundColor Green
}

# Filer att synka
$FilesToSync = @(
    "YouTube_Downloader_GUI.ps1",
    "Download-Dependencies.ps1",
    "Check-Updates.ps1"
)

Write-Host "Kopierar från: $DevScriptsDir" -ForegroundColor Cyan
Write-Host "Till:          $InstallSrcDir" -ForegroundColor Cyan
Write-Host ""

$syncCount = 0
foreach ($file in $FilesToSync) {
    $sourcePath = Join-Path $DevScriptsDir $file
    $destPath = Join-Path $InstallSrcDir $file

    if (Test-Path $sourcePath) {
        Copy-Item $sourcePath -Destination $destPath -Force
        Write-Host "  OK $file" -ForegroundColor Green
        $syncCount++
    } else {
        Write-Host "  VARNING: $file saknas i $DevScriptsDir" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  $syncCount filer synkroniserade!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
