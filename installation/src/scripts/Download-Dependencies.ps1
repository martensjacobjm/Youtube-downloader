# Download-Dependencies.ps1
# Laddar ner yt-dlp och ffmpeg automatiskt

param(
    [Parameter(Mandatory=$false)]
    [string]$InstallDir = $PSScriptRoot
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  YouTube Downloader - Installerar..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# URLs för att ladda ner
$ytdlpUrl = "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe"
$ffmpegUrl = "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip"

# Målfiler
$ytdlpPath = Join-Path $InstallDir "yt-dlp.exe"
$ffmpegZip = Join-Path $env:TEMP "ffmpeg.zip"
$ffmpegExtract = Join-Path $env:TEMP "ffmpeg-extract"

# Funktion för att ladda ner med progress
function Download-FileWithProgress {
    param(
        [string]$Url,
        [string]$OutputPath,
        [string]$Description
    )

    Write-Host "Laddar ner $Description..." -ForegroundColor Yellow

    try {
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($Url, $OutputPath)
        Write-Host "  OK! Nedladdad till: $OutputPath" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "  FEL: Kunde inte ladda ner $Description" -ForegroundColor Red
        Write-Host "  Felmeddelande: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# 1. Ladda ner yt-dlp
Write-Host "[1/3] Hämtar yt-dlp..." -ForegroundColor Cyan
if (Test-Path $ytdlpPath) {
    Write-Host "  yt-dlp.exe finns redan, uppdaterar..." -ForegroundColor Yellow
}

if (-not (Download-FileWithProgress -Url $ytdlpUrl -OutputPath $ytdlpPath -Description "yt-dlp")) {
    Write-Host ""
    Write-Host "VARNING: yt-dlp kunde inte laddas ner automatiskt." -ForegroundColor Yellow
    Write-Host "Du kan ladda ner manuellt från: $ytdlpUrl" -ForegroundColor Yellow
    Write-Host ""
}

# 2. Ladda ner ffmpeg
Write-Host ""
Write-Host "[2/3] Hämtar ffmpeg..." -ForegroundColor Cyan

$ffmpegPath = Join-Path $InstallDir "ffmpeg.exe"
$ffprobePath = Join-Path $InstallDir "ffprobe.exe"

if ((Test-Path $ffmpegPath) -and (Test-Path $ffprobePath)) {
    Write-Host "  ffmpeg och ffprobe finns redan!" -ForegroundColor Green
} else {
    Write-Host "  Laddar ner ffmpeg (detta kan ta några minuter)..." -ForegroundColor Yellow

    if (Download-FileWithProgress -Url $ffmpegUrl -OutputPath $ffmpegZip -Description "ffmpeg") {
        Write-Host "  Packar upp ffmpeg..." -ForegroundColor Yellow

        try {
            # Skapa extraktionsmapp
            if (Test-Path $ffmpegExtract) {
                Remove-Item $ffmpegExtract -Recurse -Force
            }
            New-Item -ItemType Directory -Path $ffmpegExtract -Force | Out-Null

            # Packa upp ZIP
            Expand-Archive -Path $ffmpegZip -DestinationPath $ffmpegExtract -Force

            # Hitta ffmpeg.exe och ffprobe.exe i den uppackade strukturen
            $ffmpegExe = Get-ChildItem -Path $ffmpegExtract -Filter "ffmpeg.exe" -Recurse | Select-Object -First 1
            $ffprobeExe = Get-ChildItem -Path $ffmpegExtract -Filter "ffprobe.exe" -Recurse | Select-Object -First 1

            if ($ffmpegExe) {
                Copy-Item $ffmpegExe.FullName -Destination $ffmpegPath -Force
                Write-Host "  OK! ffmpeg.exe kopierad" -ForegroundColor Green
            }

            if ($ffprobeExe) {
                Copy-Item $ffprobeExe.FullName -Destination $ffprobePath -Force
                Write-Host "  OK! ffprobe.exe kopierad" -ForegroundColor Green
            }

            # Städa upp
            Remove-Item $ffmpegZip -Force -ErrorAction SilentlyContinue
            Remove-Item $ffmpegExtract -Recurse -Force -ErrorAction SilentlyContinue

        } catch {
            Write-Host "  FEL: Kunde inte packa upp ffmpeg" -ForegroundColor Red
            Write-Host "  Felmeddelande: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host ""
            Write-Host "  Du kan ladda ner manuellt från: https://ffmpeg.org/download.html" -ForegroundColor Yellow
        }
    }
}

# 3. Verifiera installation
Write-Host ""
Write-Host "[3/3] Verifierar installation..." -ForegroundColor Cyan

$allOk = $true

if (Test-Path $ytdlpPath) {
    $ytdlpSize = (Get-Item $ytdlpPath).Length / 1MB
    Write-Host "  OK yt-dlp.exe ($([math]::Round($ytdlpSize, 2)) MB)" -ForegroundColor Green
} else {
    Write-Host "  X  yt-dlp.exe saknas!" -ForegroundColor Red
    $allOk = $false
}

if (Test-Path $ffmpegPath) {
    $ffmpegSize = (Get-Item $ffmpegPath).Length / 1MB
    Write-Host "  OK ffmpeg.exe ($([math]::Round($ffmpegSize, 2)) MB)" -ForegroundColor Green
} else {
    Write-Host "  X  ffmpeg.exe saknas!" -ForegroundColor Red
    $allOk = $false
}

if (Test-Path $ffprobePath) {
    $ffprobeSize = (Get-Item $ffprobePath).Length / 1MB
    Write-Host "  OK ffprobe.exe ($([math]::Round($ffprobeSize, 2)) MB)" -ForegroundColor Green
} else {
    Write-Host "  !  ffprobe.exe saknas (inte kritiskt)" -ForegroundColor Yellow
}

Write-Host ""
if ($allOk) {
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  Installation slutförd!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
} else {
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "  Installation slutförd med varningar" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
}

Write-Host ""
return $allOk
