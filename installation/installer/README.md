# YouTube Downloader - Installer

Detta är installer-mappen för YouTube Downloader.

## Snabbguide

### Bygg Installer (2 steg)

```powershell
# Steg 1: Skapa release-paket
.\installer\Build-Release.ps1

# Steg 2: Bygg installer
.\installer\Build-Installer.ps1
```

**Output:** `dist\YouTubeDownloader-Setup-1.0.0.exe`

---

## Vad händer?

### Steg 1: Build-Release.ps1

Skapar ett **rent release-paket** i `release/app/`:

```
release/app/
├── YouTubeDownloader.exe       (launcher, byggd från ps2exe)
├── scripts/
│   ├── YouTube_Downloader_GUI.ps1
│   └── Download-Dependencies.ps1
└── version.txt
```

### Steg 2: Build-Installer.ps1

Använder release-paketet och skapar en **Windows installer** med InnoSetup:

```
dist/
└── YouTubeDownloader-Setup-1.0.0.exe
```

---

## Förutsättningar

### 1. ps2exe (PowerShell till EXE)

```powershell
Install-Module -Name ps2exe -Scope CurrentUser -Force
```

### 2. InnoSetup 6

Ladda ner och installera från: https://jrsoftware.org/isdl.php

**Installera i standardmappen:**
- `C:\Program Files (x86)\Inno Setup 6\`

---

## Mappstruktur

```
Youtube-downloader/
│
├── src/                        # Källkod (utveckling)
│   └── scripts/
│       ├── YouTube_Downloader_GUI.ps1
│       ├── Download-Dependencies.ps1
│       └── Check-Updates.ps1
│
├── installer/                  # Installer-konfiguration (här är du nu!)
│   ├── config/
│   │   └── YouTubeDownloader.iss    # InnoSetup script
│   ├── Build-Release.ps1            # Steg 1: Bygg release-paket
│   ├── Build-Installer.ps1          # Steg 2: Bygg installer
│   ├── YouTubeDownloader-Launcher.ps1
│   └── README.md                    # Denna fil
│
├── release/                    # Release-paket (genereras)
│   └── app/
│       ├── YouTubeDownloader.exe
│       ├── scripts/
│       └── version.txt
│
└── dist/                       # Färdiga installers (genereras)
    └── YouTubeDownloader-Setup-1.0.0.exe
```

---

## Användning

### Vanlig Build

```powershell
# Bygg allt från scratch
.\installer\Build-Release.ps1 -Clean
.\installer\Build-Installer.ps1
```

### Uppdatera Version

1. Redigera `version.txt`:
   ```
   1.0.1
   ```

2. Bygg om:
   ```powershell
   .\installer\Build-Release.ps1
   .\installer\Build-Installer.ps1
   ```

---

## Felsökning

### "ps2exe saknas"

```powershell
Install-Module -Name ps2exe -Scope CurrentUser -Force
```

### "InnoSetup hittas inte"

Kontrollera att InnoSetup är installerat i:
- `C:\Program Files (x86)\Inno Setup 6\`

### "Release-paket saknas"

Kör först:
```powershell
.\installer\Build-Release.ps1
```

### "Execution Policy" fel

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force
```

---

## Nästa Steg

Efter att du byggt installern:

1. **Testa installern:**
   ```powershell
   .\dist\YouTubeDownloader-Setup-1.0.0.exe
   ```

2. **Ladda upp till GitHub Releases:**
   - Skapa ny release med tag `v1.0.0`
   - Ladda upp `.exe`-filen

3. **Dela med andra!**

---

## Support

Se dokumentation:
- `docs/USER-MANUAL.md` - Användarmanual
- `installer/README-BUILD.md` - Detaljerad build-guide
