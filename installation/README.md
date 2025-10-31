# YouTube Downloader - Installation

Denna mapp innehåller ALLT som behövs för att bygga en Windows-installer.

---

## SNABBGUIDE - Bygg Installer (4 enkla steg)

### Steg 1: Navigera till installation-mappen

```powershell
cd "C:\Users\JMS\OneDrive - Dala VS Värme & Sanitet\Privat\Youtube download\Youtube-downloader-claude-organize-and-fix-encoding-011CULRzAioj7ztQXDv1GLkU\installation"
```

### Steg 2: Synka senaste källfiler

```powershell
.\installer\Sync-Source.ps1
```

Detta kopierar senaste versionen av GUI-scriptet från `../scripts/` till `src/scripts/`

### Steg 3: Bygg release-paket

```powershell
.\installer\Build-Release.ps1
```

### Steg 4: Bygg installer

```powershell
.\installer\Build-Installer.ps1
```

**KLART!** Installern finns nu i: `dist\YouTubeDownloader-Setup-1.0.0.exe`

---

## Komplett Kommandosekvens (kopiera och klistra in)

```powershell
# Navigera till installation-mappen
cd "C:\Users\JMS\OneDrive - Dala VS Värme & Sanitet\Privat\Youtube download\Youtube-downloader-claude-organize-and-fix-encoding-011CULRzAioj7ztQXDv1GLkU\installation"

# Synka källfiler
.\installer\Sync-Source.ps1

# Bygg release-paket
.\installer\Build-Release.ps1

# Bygg installer
.\installer\Build-Installer.ps1

# KLART! Installer finns i:
# .\dist\YouTubeDownloader-Setup-1.0.0.exe
```

---

## Mappstruktur

```
installation/                   # <-- DU ÄR HÄR
│
├── src/                        # Källfiler (kopieras hit av Sync-Source.ps1)
│   └── scripts/
│       ├── YouTube_Downloader_GUI.ps1
│       ├── Download-Dependencies.ps1
│       └── Check-Updates.ps1
│
├── installer/                  # Build-scripts
│   ├── config/
│   │   └── YouTubeDownloader.iss
│   ├── Sync-Source.ps1         # STEG 1: Synka källfiler
│   ├── Build-Release.ps1       # STEG 2: Bygg release-paket
│   ├── Build-Installer.ps1     # STEG 3: Bygg installer
│   └── YouTubeDownloader-Launcher.ps1
│
├── release/                    # Release-paket (genereras av Build-Release)
│   └── app/
│       ├── YouTubeDownloader.exe
│       ├── scripts/
│       └── version.txt
│
└── dist/                       # Färdiga installers (genereras av Build-Installer)
    └── YouTubeDownloader-Setup-1.0.0.exe
```

---

## Förutsättningar (installera EN gång)

### 1. ps2exe (PowerShell till EXE)

```powershell
Install-Module -Name ps2exe -Scope CurrentUser -Force
```

### 2. InnoSetup 6

**Ladda ner:** https://jrsoftware.org/isdl.php

**Installera i:** `C:\Program Files (x86)\Inno Setup 6\`

---

## Detaljerad Process

### Sync-Source.ps1

**Vad det gör:**
- Kopierar senaste GUI-scriptet från `../scripts/YouTube_Downloader_GUI.ps1`
- Kopierar beroende-scripts
- Sparar i `src/scripts/`

**Varför:** Håller installation-mappen uppdaterad med senaste koden.

### Build-Release.ps1

**Vad det gör:**
- Läser källfiler från `src/scripts/`
- Bygger `YouTubeDownloader.exe` med ps2exe
- Kopierar version.txt, README, LICENSE
- Skapar komplett paket i `release/app/`

**Output:** `release/app/YouTubeDownloader.exe` + alla filer klara för distribution

### Build-Installer.ps1

**Vad det gör:**
- Verifierar att release-paketet finns
- Hittar och kör InnoSetup
- Kompilerar Windows installer
- Sparar i `dist/`

**Output:** `dist/YouTubeDownloader-Setup-1.0.0.exe`

---

## Uppdatera Version

1. **Redigera version.txt** i projektroten:
   ```
   1.0.1
   ```

2. **Bygg om:**
   ```powershell
   cd installation
   .\installer\Sync-Source.ps1
   .\installer\Build-Release.ps1
   .\installer\Build-Installer.ps1
   ```

3. **Ny installer:**
   ```
   dist\YouTubeDownloader-Setup-1.0.1.exe
   ```

---

## Testa Installern

```powershell
# Från installation-mappen
.\dist\YouTubeDownloader-Setup-1.0.0.exe
```

Installern kommer:
- Låta dig välja installationsplats
- Låta dig välja nedladdningsmapp
- Ladda ner yt-dlp och ffmpeg automatiskt
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

Kontrollera att InnoSetup är installerat:
```
C:\Program Files (x86)\Inno Setup 6\ISCC.exe
```

### "Källfiler saknas"

Kör Sync-Source först:
```powershell
.\installer\Sync-Source.ps1
```

### "Release-paket saknas"

Kör Build-Release:
```powershell
.\installer\Build-Release.ps1
```

### "Execution Policy" fel

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force
```

---

## Rensa Allt och Börja Om

```powershell
cd installation

# Ta bort genererade filer
Remove-Item release -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item dist -Recurse -Force -ErrorAction SilentlyContinue

# Bygg från scratch
.\installer\Sync-Source.ps1
.\installer\Build-Release.ps1
.\installer\Build-Installer.ps1
```

---

## Mer Information

- `installer/README.md` - Detaljerad build-guide
- `installer/README-BUILD.md` - Teknisk dokumentation
- `../docs/USER-MANUAL.md` - Användarmanual
