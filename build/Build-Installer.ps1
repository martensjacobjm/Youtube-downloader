# Build-Installer.ps1
# Bygger YouTube Downloader installer

param(
    [switch]$SkipPs2Exe,
    [switch]$SkipInnoSetup
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  YouTube Downloader - Build Installer  " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
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

# Skapa build-mapp
$BuildDir = Join-Path $ProjectRoot "build"
if (-not (Test-Path $BuildDir)) {
    New-Item -ItemType Directory -Path $BuildDir -Force | Out-Null
}

# Skapa dist-mapp för output
$DistDir = Join-Path $ProjectRoot "dist"
if (-not (Test-Path $DistDir)) {
    New-Item -ItemType Directory -Path $DistDir -Force | Out-Null
}

Write-Host ""
Write-Host "[1/3] Bygger EXE från PowerShell..." -ForegroundColor Cyan

if ($SkipPs2Exe) {
    Write-Host "  Hoppas över ps2exe (--SkipPs2Exe angiven)" -ForegroundColor Yellow
} else {
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

    # Konvertera launcher till EXE
    $LauncherScript = Join-Path $ProjectRoot "launcher\YouTubeDownloader-Launcher.ps1"
    $OutputExe = Join-Path $BuildDir "YouTubeDownloader.exe"

    # Kolla om ikon finns
    $IconPath = Join-Path $ProjectRoot "assets\icon.ico"
    $IconParam = @{}
    if (Test-Path $IconPath) {
        $IconParam = @{ iconFile = $IconPath }
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
            Write-Host "  OK! EXE skapad: $OutputExe ($([math]::Round($exeSize, 2)) KB)" -ForegroundColor Green
        } else {
            Write-Host "  FEL: EXE skapades inte!" -ForegroundColor Red
            exit 1
        }
    } catch {
        Write-Host "  FEL: ps2exe misslyckades" -ForegroundColor Red
        Write-Host "  $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "[2/3] Förbereder filer..." -ForegroundColor Cyan

# Kopiera nödvändiga filer till build
$FilesToCopy = @(
    @{ Source = "scripts\YouTube_Downloader_GUI.ps1"; Dest = "scripts" }
    @{ Source = "scripts\Download-Dependencies.ps1"; Dest = "scripts" }
    @{ Source = "version.txt"; Dest = "." }
    @{ Source = "README.md"; Dest = "."; Optional = $true }
    @{ Source = "LICENSE"; Dest = "."; Optional = $true }
)

foreach ($file in $FilesToCopy) {
    $SourcePath = Join-Path $ProjectRoot $file.Source
    $DestPath = Join-Path $BuildDir $file.Dest

    if (Test-Path $SourcePath) {
        if (-not (Test-Path $DestPath)) {
            New-Item -ItemType Directory -Path $DestPath -Force | Out-Null
        }
        $DestFile = Join-Path $DestPath (Split-Path $file.Source -Leaf)
        Copy-Item $SourcePath -Destination $DestFile -Force
        Write-Host "  Kopierade: $($file.Source)" -ForegroundColor Green
    } elseif (-not $file.Optional) {
        Write-Host "  VARNING: $($file.Source) saknas!" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "[3/3] Bygger InnoSetup installer..." -ForegroundColor Cyan

if ($SkipInnoSetup) {
    Write-Host "  Hoppas över InnoSetup (--SkipInnoSetup angiven)" -ForegroundColor Yellow
} else {
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
        Write-Host "  VARNING: InnoSetup hittades inte!" -ForegroundColor Yellow
        Write-Host "  Ladda ner från: https://jrsoftware.org/isdl.php" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  EXE finns i: $BuildDir" -ForegroundColor Cyan
        Write-Host "  Du kan köra InnoSetup manuellt på: installer\YouTubeDownloader.iss" -ForegroundColor Cyan
    } else {
        Write-Host "  Hittade InnoSetup: $ISCC" -ForegroundColor Green

        $ISSFile = Join-Path $ProjectRoot "installer\YouTubeDownloader.iss"

        if (-not (Test-Path $ISSFile)) {
            Write-Host "  FEL: InnoSetup script saknas: $ISSFile" -ForegroundColor Red
            exit 1
        }

        try {
            & $ISCC $ISSFile

            # Hitta den skapade installern
            $InstallerPattern = "YouTubeDownloader-Setup-*.exe"
            $Installer = Get-ChildItem -Path $DistDir -Filter $InstallerPattern | Select-Object -First 1

            if ($Installer) {
                $installerSize = $Installer.Length / 1MB
                Write-Host ""
                Write-Host "========================================" -ForegroundColor Green
                Write-Host "  BUILD SLUTFÖRD!" -ForegroundColor Green
                Write-Host "========================================" -ForegroundColor Green
                Write-Host ""
                Write-Host "Installer skapad:" -ForegroundColor Cyan
                Write-Host "  $($Installer.FullName)" -ForegroundColor White
                Write-Host "  Storlek: $([math]::Round($installerSize, 2)) MB" -ForegroundColor White
                Write-Host ""
            } else {
                Write-Host "  VARNING: Installern skapades inte!" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "  FEL: InnoSetup compilation misslyckades" -ForegroundColor Red
            Write-Host "  $($_.Exception.Message)" -ForegroundColor Red
            exit 1
        }
    }
}

Write-Host ""
Write-Host "Färdiga filer:" -ForegroundColor Cyan
Write-Host "  EXE:       $BuildDir\YouTubeDownloader.exe" -ForegroundColor White
Write-Host "  Installer: $DistDir\YouTubeDownloader-Setup-$Version.exe" -ForegroundColor White
Write-Host ""
