# Check-Updates.ps1
# Kontrollerar om det finns uppdateringar tillgängliga

param(
    [Parameter(Mandatory=$false)]
    [string]$UpdateUrl = "https://raw.githubusercontent.com/martensjacobjm/Youtube-downloader/main/version.txt",

    [Parameter(Mandatory=$false)]
    [switch]$AutoInstall
)

$ErrorActionPreference = "Stop"

# Läs nuvarande version
$InstallDir = Split-Path -Parent $PSScriptRoot
$CurrentVersionFile = Join-Path $InstallDir "version.txt"

if (-not (Test-Path $CurrentVersionFile)) {
    Write-Host "Kunde inte hitta version.txt" -ForegroundColor Red
    return $false
}

$CurrentVersion = (Get-Content $CurrentVersionFile -Raw).Trim()
Write-Host "Nuvarande version: $CurrentVersion" -ForegroundColor Cyan

# Hämta senaste version från GitHub
try {
    Write-Host "Kontrollerar uppdateringar..." -ForegroundColor Yellow

    $LatestVersion = (Invoke-WebRequest -Uri $UpdateUrl -UseBasicParsing).Content.Trim()

    Write-Host "Senaste version:   $LatestVersion" -ForegroundColor Cyan

    # Jämför versioner
    if ($LatestVersion -ne $CurrentVersion) {
        Write-Host ""
        Write-Host "En ny version finns tillgänglig!" -ForegroundColor Green
        Write-Host "  Nuvarande: $CurrentVersion" -ForegroundColor Yellow
        Write-Host "  Senaste:   $LatestVersion" -ForegroundColor Green
        Write-Host ""

        if ($AutoInstall) {
            Write-Host "Laddar ner och installerar uppdatering..." -ForegroundColor Yellow

            # URL till senaste installern
            $InstallerUrl = "https://github.com/martensjacobjm/Youtube-downloader/releases/latest/download/YouTubeDownloader-Setup-$LatestVersion.exe"
            $InstallerPath = Join-Path $env:TEMP "YouTubeDownloader-Setup-$LatestVersion.exe"

            try {
                Invoke-WebRequest -Uri $InstallerUrl -OutFile $InstallerPath -UseBasicParsing

                Write-Host "Startar installer..." -ForegroundColor Green
                Start-Process -FilePath $InstallerPath -Wait

                Write-Host "Uppdatering slutförd!" -ForegroundColor Green
                return $true
            } catch {
                Write-Host "Kunde inte ladda ner uppdatering: $($_.Exception.Message)" -ForegroundColor Red
                Write-Host "Besök: https://github.com/martensjacobjm/Youtube-downloader/releases" -ForegroundColor Yellow
                return $false
            }
        } else {
            Write-Host "Besök: https://github.com/martensjacobjm/Youtube-downloader/releases" -ForegroundColor Cyan
            return $true
        }
    } else {
        Write-Host ""
        Write-Host "Du har redan senaste versionen!" -ForegroundColor Green
        return $false
    }
} catch {
    Write-Host "Kunde inte kontrollera uppdateringar: $($_.Exception.Message)" -ForegroundColor Red
    return $false
}
