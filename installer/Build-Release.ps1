# Build-Release.ps1
# Förbereder ett rent release-paket för distribution

param(
    [switch]$Clean
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  YouTube Downloader - Build Release    " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Läs version
$VersionFile = Join-Path $ProjectRoot "version.txt"
if (Test-Path $VersionFile) {
    $Version = Get-Content $VersionFile -Raw | ForEach-Object { $_.Trim() }
    Write-Host "Version: $Version" -ForegroundColor Green
} else {
    Write-Host "FEL: version.txt saknas!" -ForegroundColor Red
    exit 1
}

$ReleaseDir = Join-Path $ProjectRoot "release\app"
$SrcDir = Join-Path $ProjectRoot "src"

# Rensa release-mappen om --Clean
if ($Clean -and (Test-Path $ReleaseDir)) {
    Write-Host "Rensar release-mappen..." -ForegroundColor Yellow
    Remove-Item -Path $ReleaseDir -Recurse -Force
}

# Skapa release-struktur
Write-Host ""
Write-Host "[1/3] Skapar release-struktur..." -ForegroundColor Cyan

$Folders = @(
    $ReleaseDir,
    (Join-Path $ReleaseDir "scripts")
)

foreach ($folder in $Folders) {
    if (-not (Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder -Force | Out-Null
        Write-Host "  Skapade: $folder" -ForegroundColor Green
    }
}

# Kopiera nödvändiga filer
Write-Host ""
Write-Host "[2/3] Kopierar filer..." -ForegroundColor Cyan

$FilesToCopy = @(
    @{
        Source = "src\scripts\YouTube_Downloader_GUI.ps1"
        Dest = "scripts\YouTube_Downloader_GUI.ps1"
        Required = $true
    },
    @{
        Source = "src\scripts\Download-Dependencies.ps1"
        Dest = "scripts\Download-Dependencies.ps1"
        Required = $true
    },
    @{
        Source = "version.txt"
        Dest = "version.txt"
        Required = $true
    },
    @{
        Source = "README.md"
        Dest = "README.md"
        Required = $false
    },
    @{
        Source = "LICENSE"
        Dest = "LICENSE"
        Required = $false
    }
)

foreach ($file in $FilesToCopy) {
    $SourcePath = Join-Path $ProjectRoot $file.Source
    $DestPath = Join-Path $ReleaseDir $file.Dest

    if (Test-Path $SourcePath) {
        # Skapa destination-mapp om det behövs
        $DestDir = Split-Path $DestPath -Parent
        if (-not (Test-Path $DestDir)) {
            New-Item -ItemType Directory -Path $DestDir -Force | Out-Null
        }

        Copy-Item $SourcePath -Destination $DestPath -Force
        Write-Host "  OK $($file.Source)" -ForegroundColor Green
    } elseif ($file.Required) {
        Write-Host "  FEL: $($file.Source) saknas!" -ForegroundColor Red
        exit 1
    } else {
        Write-Host "  HOPPAR ÖVER: $($file.Source) (valfri, saknas)" -ForegroundColor Yellow
    }
}

# Bygg EXE från launcher
Write-Host ""
Write-Host "[3/3] Bygger launcher EXE..." -ForegroundColor Cyan

# Kolla om ps2exe är installerat
$ps2exeInstalled = Get-Module -ListAvailable -Name ps2exe

if (-not $ps2exeInstalled) {
    Write-Host "  ps2exe är inte installerat, installerar..." -ForegroundColor Yellow
    try {
        Install-Module -Name ps2exe -Scope CurrentUser -Force -AllowClobber
        Write-Host "  OK! ps2exe installerat" -ForegroundColor Green
    } catch {
        Write-Host "  FEL: Kunde inte installera ps2exe" -ForegroundColor Red
        Write-Host "  Kör manuellt: Install-Module -Name ps2exe" -ForegroundColor Yellow
        exit 1
    }
}

Import-Module ps2exe

$LauncherScript = Join-Path $PSScriptRoot "YouTubeDownloader-Launcher.ps1"
$OutputExe = Join-Path $ReleaseDir "YouTubeDownloader.exe"

# Kolla om ikon finns
$IconPath = Join-Path $ProjectRoot "assets\icon.ico"
$IconParam = @{}
if (Test-Path $IconPath) {
    $IconParam = @{ iconFile = $IconPath }
    Write-Host "  Använder ikon: assets\icon.ico" -ForegroundColor Green
} else {
    Write-Host "  VARNING: assets\icon.ico saknas, EXE får ingen ikon" -ForegroundColor Yellow
}

try {
    ps2exe -inputFile $LauncherScript -outputFile $OutputExe `
        -title "YouTube Downloader" `
        -company "YouTube Downloader Team" `
        -product "YouTube Downloader" `
        -version $Version `
        -copyright "© 2025 YouTube Downloader Team" `
        -noConsole `
        -requireAdmin:$false `
        @IconParam

    if (Test-Path $OutputExe) {
        $exeSize = (Get-Item $OutputExe).Length / 1KB
        Write-Host "  OK! EXE skapad ($([math]::Round($exeSize, 2)) KB)" -ForegroundColor Green
    } else {
        Write-Host "  FEL: EXE skapades inte!" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "  FEL: ps2exe misslyckades" -ForegroundColor Red
    Write-Host "  $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  RELEASE-PAKET KLART!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Release-paket finns i:" -ForegroundColor Cyan
Write-Host "  $ReleaseDir" -ForegroundColor White
Write-Host ""
Write-Host "Nästa steg:" -ForegroundColor Cyan
Write-Host "  Kör: .\installer\Build-Installer.ps1" -ForegroundColor White
Write-Host ""
