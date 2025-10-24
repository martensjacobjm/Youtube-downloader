# YouTube Downloader - Build Instructions

Denna guide visar hur du bygger installationsprogrammet för YouTube Downloader.

## Förutsättningar

### 1. PowerShell 5.1 eller senare
Kontrollera version:
```powershell
$PSVersionTable.PSVersion
```

### 2. ps2exe PowerShell-modul
Installera med:
```powershell
Install-Module -Name ps2exe -Scope CurrentUser -Force
```

### 3. Inno Setup 6
Ladda ner och installera från: https://jrsoftware.org/isdl.php

**VIKTIGT:** Välj den svenska språkfilen under installation om du vill ha svensk installer!

---

## Projektstruktur

```
Youtube-downloader/
│
├── scripts/
│   ├── YouTube_Downloader_GUI.ps1       # Huvudprogram (GUI)
│   ├── Download-Dependencies.ps1         # Laddar ner yt-dlp och ffmpeg
│   └── Check-Updates.ps1                 # Uppdateringskontroll
│
├── launcher/
│   └── YouTubeDownloader-Launcher.ps1    # Launcher (konverteras till EXE)
│
├── installer/
│   ├── YouTubeDownloader.iss             # InnoSetup script
│   └── README-BUILD.md                   # Denna fil
│
├── build/
│   ├── Build-Installer.ps1               # Build-script
│   └── YouTubeDownloader.exe             # (skapas av build-scriptet)
│
├── dist/
│   └── YouTubeDownloader-Setup-X.X.X.exe # (skapas av InnoSetup)
│
├── assets/
│   └── icon.ico                          # Programikon (valfri)
│
└── version.txt                           # Aktuell version
```

---

## Bygga Installer - Snabbguide

### Steg 1: Öppna PowerShell

```powershell
cd "C:\path\to\Youtube-downloader"
```

### Steg 2: Kör build-scriptet

```powershell
.\build\Build-Installer.ps1
```

### Steg 3: Installern är klar!

Hämta den från:
```
dist\YouTubeDownloader-Setup-X.X.X.exe
```

---

## Detaljerad Build-process

### Manual Build (steg för steg)

#### 1. Konvertera Launcher till EXE

```powershell
Import-Module ps2exe

ps2exe `
    -inputFile "launcher\YouTubeDownloader-Launcher.ps1" `
    -outputFile "build\YouTubeDownloader.exe" `
    -title "YouTube Downloader" `
    -version "1.0.0" `
    -noConsole `
    -iconFile "assets\icon.ico"
```

#### 2. Bygg InnoSetup Installer

Om InnoSetup är installerat i standardmappen:

```powershell
& "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" installer\YouTubeDownloader.iss
```

---

## Build-alternativ

### Hoppa över ps2exe

Om du redan har en EXE:

```powershell
.\build\Build-Installer.ps1 -SkipPs2Exe
```

### Hoppa över InnoSetup

Om du bara vill bygga EXE:

```powershell
.\build\Build-Installer.ps1 -SkipInnoSetup
```

---

## Anpassa Installern

### Ändra Version

Redigera `version.txt`:
```
1.0.0
```

### Ändra Installerns Utseende

Redigera `installer\YouTubeDownloader.iss`:

```ini
#define MyAppName "YouTube Downloader"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Ditt Namn"
```

### Lägg till Egen Ikon

1. Skapa en .ico-fil (256x256 rekommenderas)
2. Spara den som `assets\icon.ico`
3. Bygg om med build-scriptet

---

## Testa Installern

### 1. Installera på lokal dator

```powershell
.\dist\YouTubeDownloader-Setup-1.0.0.exe
```

### 2. Välj installationsplats

Standard: `C:\Program Files\YouTube Downloader`

### 3. Välj nedladdningsmapp

Standard: `C:\Users\USERNAME\Documents\YouTube Downloads`

### 4. Starta programmet

Genväg skapas på skrivbordet och i startmenyn.

---

## Felsökning

### ps2exe saknas

```powershell
Install-Module -Name ps2exe -Scope CurrentUser -Force
```

### InnoSetup hittas inte

Kontrollera att InnoSetup är installerat i:
- `C:\Program Files (x86)\Inno Setup 6\`
- `C:\Program Files\Inno Setup 6\`

### "Execution Policy" fel

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force
```

### Icon.ico saknas

Detta är inte kritiskt. Installern byggs utan ikon om filen saknas.

För att skapa en ikon:
1. Hitta en PNG-bild (256x256)
2. Konvertera till .ico med online-verktyg (t.ex. https://convertico.com/)
3. Spara som `assets\icon.ico`

---

## Distribution

### Ladda upp till GitHub Releases

1. Skapa en ny release på GitHub
2. Ladda upp `YouTubeDownloader-Setup-X.X.X.exe`
3. Tagga releasen med versionsnumret (t.ex. `v1.0.0`)

### Uppdatera Version

1. Redigera `version.txt`
2. Bygg ny installer
3. Ladda upp till GitHub releases med samma tagg som version

### Auto-uppdatering

Användare kan kontrollera uppdateringar med:

```powershell
.\scripts\Check-Updates.ps1
```

Eller installera automatiskt:

```powershell
.\scripts\Check-Updates.ps1 -AutoInstall
```

---

## Vad händer vid installation?

1. **Användaren väljer plats**
   - Installation: `C:\Program Files\YouTube Downloader`
   - Nedladdningar: `C:\Users\USERNAME\Documents\YouTube Downloads`

2. **Filer kopieras**
   - `YouTubeDownloader.exe` (launcher)
   - `scripts\YouTube_Downloader_GUI.ps1` (GUI)
   - `scripts\Download-Dependencies.ps1`

3. **Beroenden laddas ner**
   - `yt-dlp.exe` hämtas från GitHub
   - `ffmpeg.exe` och `ffprobe.exe` hämtas från gyan.dev

4. **Genvägar skapas**
   - Skrivbord: `YouTube Downloader`
   - Startmeny: `YouTube Downloader`

5. **Registry-inställningar**
   - `HKCU\Software\YouTube Downloader\Settings\OutputDir`
   - `HKCU\Software\YouTube Downloader\Settings\Version`
   - `HKCU\Software\YouTube Downloader\Settings\InstallDir`

---

## Avinstallation

Användaren kan avinstallera via:

1. **Windows Inställningar**
   - `Inställningar` → `Appar` → `YouTube Downloader` → `Avinstallera`

2. **Startmenyn**
   - `Startmeny` → `YouTube Downloader` → `Avinstallera`

Vid avinstallation får användaren välja om de vill:
- Ta bort allt (inklusive nedladdade videor)
- Behålla nedladdningar och inställningar

---

## Support

Om du har problem med bygget:

1. Kontrollera att alla förutsättningar är installerade
2. Kör build-scriptet i administratörsläge
3. Kontrollera att alla filer finns på rätt plats
4. Se fellogg i PowerShell-output

---

## Licens

Se `LICENSE`-filen i projektroten.
