# YouTube Downloader Launcher
# Detta script konverteras till .exe med ps2exe

#Requires -Version 5.1

# Sätt error handling
$ErrorActionPreference = "Stop"

# Hitta installation directory
$InstallDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Läs konfiguration från registry
try {
    $RegPath = "HKCU:\Software\YouTube Downloader\Settings"
    if (Test-Path $RegPath) {
        $OutputDir = (Get-ItemProperty -Path $RegPath -Name "OutputDir" -ErrorAction SilentlyContinue).OutputDir
    }
} catch {
    $OutputDir = $null
}

# Om ingen output-dir är satt, använd default
if (-not $OutputDir) {
    $OutputDir = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "YouTube Downloads"
}

# Skapa output-mappen om den inte finns
if (-not (Test-Path $OutputDir)) {
    try {
        New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
    } catch {
        # Ignorera fel om mappen redan skapas
    }
}

# Hitta GUI-scriptet
$GuiScript = Join-Path $InstallDir "scripts\YouTube_Downloader_GUI.ps1"

if (-not (Test-Path $GuiScript)) {
    # Prova alternativ plats (om körs direkt från build)
    $GuiScript = Join-Path $InstallDir "..\scripts\YouTube_Downloader_GUI.ps1"
}

if (-not (Test-Path $GuiScript)) {
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.MessageBox]::Show(
        "Kunde inte hitta GUI-scriptet!`n`nFörväntad plats:`n$GuiScript`n`nKontrollera installationen.",
        "YouTube Downloader - Fel",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    )
    exit 1
}

# Kör GUI-scriptet
try {
    & $GuiScript
} catch {
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.MessageBox]::Show(
        "Ett fel uppstod när GUI skulle startas:`n`n$($_.Exception.Message)`n`nSe fellogg för detaljer.",
        "YouTube Downloader - Fel",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    )
    exit 1
}
