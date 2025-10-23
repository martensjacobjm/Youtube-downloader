# Build-Installer.ps1
# Bygger InnoSetup installer från release-paket

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  YouTube Downloader - Build Installer  " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Kontrollera att release-paketet finns
$ReleaseDir = Join-Path $ProjectRoot "release\app"

if (-not (Test-Path $ReleaseDir)) {
    Write-Host "FEL: Release-paket saknas!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Kör först: .\installer\Build-Release.ps1" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

# Kontrollera att EXE finns
$ExePath = Join-Path $ReleaseDir "YouTubeDownloader.exe"
if (-not (Test-Path $ExePath)) {
    Write-Host "FEL: YouTubeDownloader.exe saknas i release-paketet!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Kör först: .\installer\Build-Release.ps1" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

Write-Host "Release-paket hittat: $ReleaseDir" -ForegroundColor Green
Write-Host ""

# Läs version
$VersionFile = Join-Path $ProjectRoot "version.txt"
if (Test-Path $VersionFile) {
    $Version = Get-Content $VersionFile -Raw | ForEach-Object { $_.Trim() }
    Write-Host "Version: $Version" -ForegroundColor Green
} else {
    Write-Host "VARNING: version.txt saknas, använder 1.0.0" -ForegroundColor Yellow
    $Version = "1.0.0"
}

# Skapa dist-mapp
$DistDir = Join-Path $ProjectRoot "dist"
if (-not (Test-Path $DistDir)) {
    New-Item -ItemType Directory -Path $DistDir -Force | Out-Null
}

Write-Host ""
Write-Host "Bygger InnoSetup installer..." -ForegroundColor Cyan

# Hitta InnoSetup
$InnoSetupPaths = @(
    "C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
    "C:\Program Files\Inno Setup 6\ISCC.exe"
    "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe"
    "$env:ProgramFiles\Inno Setup 6\ISCC.exe"
)

$ISCC = $null
foreach ($path in $InnoSetupPaths) {
    if (Test-Path $path) {
        $ISCC = $path
        break
    }
}

if (-not $ISCC) {
    Write-Host ""
    Write-Host "FEL: InnoSetup 6 hittades inte!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Installera InnoSetup från:" -ForegroundColor Yellow
    Write-Host "  https://jrsoftware.org/isdl.php" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Installera i standardmappen:" -ForegroundColor Yellow
    Write-Host "  C:\Program Files (x86)\Inno Setup 6\" -ForegroundColor Cyan
    Write-Host ""
    exit 1
}

Write-Host "  Hittade InnoSetup: $ISCC" -ForegroundColor Green

$ISSFile = Join-Path $PSScriptRoot "config\YouTubeDownloader.iss"

if (-not (Test-Path $ISSFile)) {
    Write-Host "  FEL: InnoSetup config saknas: $ISSFile" -ForegroundColor Red
    exit 1
}

Write-Host "  Kompilerar installer..." -ForegroundColor Yellow

try {
    $output = & $ISCC $ISSFile 2>&1

    # Hitta den skapade installern
    $InstallerPattern = "YouTubeDownloader-Setup-*.exe"
    $Installer = Get-ChildItem -Path $DistDir -Filter $InstallerPattern |
                 Sort-Object LastWriteTime -Descending |
                 Select-Object -First 1

    if ($Installer) {
        $installerSize = $Installer.Length / 1MB

        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "  INSTALLER KLAR!" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "Installer:" -ForegroundColor Cyan
        Write-Host "  $($Installer.FullName)" -ForegroundColor White
        Write-Host "  Storlek: $([math]::Round($installerSize, 2)) MB" -ForegroundColor White
        Write-Host ""
        Write-Host "Testa installern:" -ForegroundColor Cyan
        Write-Host "  $($Installer.FullName)" -ForegroundColor White
        Write-Host ""
    } else {
        Write-Host ""
        Write-Host "VARNING: Ingen installer hittades i dist-mappen!" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "InnoSetup output:" -ForegroundColor Yellow
        $output | ForEach-Object { Write-Host "  $_" }
        Write-Host ""
    }
} catch {
    Write-Host ""
    Write-Host "FEL: InnoSetup kompilering misslyckades" -ForegroundColor Red
    Write-Host "  $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    exit 1
}
