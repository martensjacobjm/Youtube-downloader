# YouTube Downloader - Installation

Denna mapp innehåller ALLT som behövs för att bygga en Windows-installer.

## Snabbguide - Bygg Installer

```powershell
# STEG 1: Bygg release-paket
.\installation\installer\Build-Release.ps1

# STEG 2: Bygg installer
.\installation\installer\Build-Installer.ps1
```

**Installer skapas i:** `installation/dist/YouTubeDownloader-Setup-1.0.0.exe`

---

## Mappstruktur

```
installation/
│
├── src/                        # KÄLLKOD (kopieras från ../scripts/)
│   └── scripts/
│       ├── YouTube_Downloader_GUI.ps1
│       ├── Download-Dependencies.ps1
│       └── Check-Updates.ps1
│
├── installer/                  # INSTALLER-KONFIGURATION
│   ├── config/
│   │   └── YouTubeDownloader.iss       # InnoSetup script
│   ├── Build-Release.ps1                # STEG 1
│   ├── Build-Installer.ps1              # STEG 2
│   ├── YouTubeDownloader-Launcher.ps1   # Launcher (blir .exe)
│   └── README.md
│
├── release/                    # RELEASE-PAKET (genereras)
│   └── app/
│       ├── YouTubeDownloader.exe
│       ├── scripts/
│       └── version.txt
│
└── dist/                       # FÄRDIGA INSTALLERS (genereras)
    └── YouTubeDownloader-Setup-1.0.0.exe
```

---

## Förutsättningar

### 1. ps2exe (PowerShell till EXE)

```powershell
Install-Module -Name ps2exe -Scope CurrentUser -Force
```

### 2. InnoSetup 6

**Ladda ner från:** https://jrsoftware.org/isdl.php

**Installera i:** `C:\Program Files (x86)\Inno Setup 6\`

---

## Vad Händer i Varje Steg?

### STEG 1: Build-Release.ps1

Skapar ett **rent release-paket** i `release/app/`:

✅ Kopierar GUI-scriptet från `src/scripts/`
✅ Kopierar beroende-script
✅ Bygger `YouTubeDownloader.exe` med ps2exe
✅ Kopierar `version.txt`, README, LICENSE

### STEG 2: Build-Installer.ps1

Skapar **Windows installer** med InnoSetup:

✅ Verifierar release-paketet
✅ Hittar och kör InnoSetup
✅ Kompilerar installer
✅ Sparar i `dist/`

---

## Användning

### Bygg från Scratch

```powershell
cd "C:\path\to\Youtube-downloader"

# Bygg med rensning
.\installation\installer\Build-Release.ps1 -Clean
.\installation\installer\Build-Installer.ps1
```

### Uppdatera Version

1. Redigera `version.txt` i projektroten:
   ```
   1.0.1
   ```

2. Bygg om:
   ```powershell
   .\installation\installer\Build-Release.ps1
   .\installation\installer\Build-Installer.ps1
   ```

3. Ny installer skapas:
   ```
   installation\dist\YouTubeDownloader-Setup-1.0.1.exe
   ```

---

## Testa Installern

```powershell
.\installation\dist\YouTubeDownloader-Setup-1.0.0.exe
```

Installern kommer att:
- Låta dig välja installationsplats
- Låta dig välja nedladdningsmapp
- Ladda ner yt-dlp och ffmpeg
- Skapa genvägar
- Registrera i Windows

---

## Felsökning

### "ps2exe saknas"

```powershell
Install-Module -Name ps2exe -Scope CurrentUser -Force
Import-Module ps2exe
```

### "InnoSetup hittas inte"

Kontrollera installation:
- `C:\Program Files (x86)\Inno Setup 6\ISCC.exe`

### "Release-paket saknas"

Kör först steg 1:
```powershell
.\installation\installer\Build-Release.ps1
```

### "Execution Policy" fel

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force
```

---

## Mer Information

Se också:
- `installer/README.md` - Detaljerad installer-guide
- `../docs/USER-MANUAL.md` - Användarmanual
- `../README.md` - Projektöversikt
