# YouTube Downloader (PowerShell)

🎬 Kraftfulla PowerShell-script för att ladda ner YouTube-videor och undertexter, med fullt stöd för spellistor.

## Versioner

Detta projekt innehåller två versioner av downloader-scriptet:

### 📺 Version 8 (INTERACTIVE) - **Rekommenderas för de flesta användare**
- ✅ Interaktiv guide som frågar vad du vill ladda ner
- ✅ Bädda in undertexter direkt i videofilen
- ✅ Användarvänligt - inga konfigurationsfiler att redigera
- ✅ Perfekt för snabba, engångsnedladdningar

### 📋 Version 7 (CLASSIC) - För avancerade användare
- ✅ Konfigurationsfil-baserad (för automation)
- ✅ Mer avancerade alternativ
- ✅ Bra för återkommande nedladdningar
- ✅ Fler format-konverteringar

## Snabbstart

### Enklaste sättet (Windows):

1. **Dubbelklicka på `RUN_DOWNLOADER.bat`**
2. Följ instruktionerna på skärmen
3. Klart!

### Alternativt (PowerShell):

```powershell
# Version 8 (Interaktiv)
.\scripts\YouTube_Downloader_v8_INTERACTIVE.ps1

# Version 7 (Klassisk)
.\scripts\youtube-downloader.ps1
```

## Funktioner

### Version 8 - INTERACTIVE
- ✅ **Interaktiv konfiguration** - Slipper editera script-filer
- ✅ **Embedded subtitles** - Bädda in undertexter direkt i videofilen
- ✅ Ladda ner videor i högsta kvalitet (MP4 med H.264 + AAC)
- ✅ Ladda ner undertexter i flera format (VTT, SRT, TXT)
- ✅ Fullständigt stöd för YouTube-spellistor
- ✅ Rate-limiting för att undvika API-begränsningar
- ✅ Progress-tracking för att fortsätta nedladdningar senare

### Version 7 - CLASSIC
- ✅ Ladda ner videor i högsta kvalitet (MP4 med H.264 + AAC)
- ✅ Ladda ner undertexter i flera format (VTT, SRT, TXT)
- ✅ Fullständigt stöd för YouTube-spellistor
- ✅ Automatisk konvertering av undertexter mellan format
- ✅ Rate-limiting för att undvika API-begränsningar
- ✅ Progress-tracking för att fortsätta nedladdningar senare
- ✅ Anpassningsbara nedladdningsalternativ
- ✅ Videobeskrivningar inkluderade i textfiler

## Krav

- **Windows** med PowerShell 5.1 eller senare
- **[yt-dlp](https://github.com/yt-dlp/yt-dlp)** - Modern YouTube-downloader
- **[ffmpeg](https://ffmpeg.org/)** - För videobehandling och undertextkonvertering

## Installation

### 1. Ladda ner beroenden

**yt-dlp:**
```powershell
# Via winget (rekommenderas)
winget install yt-dlp

# Eller ladda ner manuellt från:
# https://github.com/yt-dlp/yt-dlp/releases
```

**ffmpeg:**
```powershell
# Via winget
winget install ffmpeg

# Eller ladda ner manuellt från:
# https://ffmpeg.org/download.html
```

### 2. Konfigurera sökvägar

**För Version 8 (INTERACTIVE):**
Redigera `scripts/YouTube_Downloader_v8_INTERACTIVE.ps1`:

```powershell
$baseDir = "C:\DinMapp\Youtube download"  # Byt till din mapp
```

**För Version 7 (CLASSIC):**
Redigera `scripts/youtube-downloader.ps1`:

```powershell
$baseDir = "C:\DinMapp\Youtube download"  # Byt till din mapp
```

## Användning

### Version 8 - INTERACTIVE MODE

#### Enklast: Dubbelklicka på `RUN_DOWNLOADER.bat`

#### Eller via PowerShell:
```powershell
.\scripts\YouTube_Downloader_v8_INTERACTIVE.ps1
```

Scriptet frågar dig:
1. **YouTube-URL** - Ange video eller spellista-URL
2. **Vad vill du ladda ner?**
   - Bara video
   - Bara undertexter
   - Både video och undertexter
3. **Bädda in undertexter i video?** (om du valde båda)
4. **Spellista-inställningar** (om du angav en spellista)
   - Hur många videos?
   - Rate-limiting delay
   - Spara progress?

### Version 7 - CLASSIC MODE

1. Öppna `scripts/youtube-downloader.ps1` i en textredigerare
2. Konfigurera i början av filen:

```powershell
# Sätt URL
$videoUrl = "https://www.youtube.com/watch?v=xxxxx"

# Välj vad som ska laddas ner
$downloadVideo = $true
$downloadSubs = $true

# För spellistor
$maxDownloads = 10
$sleepSubtitles = 8
```

3. Kör scriptet:
```powershell
.\scripts\youtube-downloader.ps1
```

## Projektstruktur

```
Youtube-downloader/
├── RUN_DOWNLOADER.bat           # Enkel launcher (dubbelklicka)
├── RUN_DOWNLOADER.ps1           # PowerShell launcher
├── scripts/
│   ├── YouTube_Downloader_v8_INTERACTIVE.ps1  # Version 8 (rekommenderas)
│   └── youtube-downloader.ps1                 # Version 7 (klassisk)
├── examples/
│   ├── config-basic.ps1          # Grundläggande konfiguration (v7)
│   ├── config-playlist.ps1       # Spellista-konfiguration (v7)
│   └── config-advanced.ps1       # Avancerade alternativ (v7)
├── docs/
│   ├── INSTALLATION.md                              # Installationsguide
│   ├── CONFIGURATION.md                             # Konfigurationsguide (v7)
│   ├── TROUBLESHOOTING.md                           # Felsökningsguide
│   ├── YouTube_Downloader_v8_GUIDE.md              # Version 8 guide
│   └── YouTube_Downloader_COMPLETE_DOCUMENTATION_v8.md  # Fullständig v8 dokumentation
└── README.md                     # Denna fil
```

## Exempel på användning

### Exempel 1: Ladda ner en video med inbäddade undertexter (V8)

```powershell
.\scripts\YouTube_Downloader_v8_INTERACTIVE.ps1
# Följ instruktionerna:
# 1. Ange URL
# 2. Välj "3" (båda)
# 3. Välj "j" (ja till embedding)
```

### Exempel 2: Ladda ner en spellista (första 20 videos) (V7)

Redigera `scripts/youtube-downloader.ps1`:
```powershell
$videoUrl = "https://www.youtube.com/playlist?list=PLxxxxxx"
$maxDownloads = 20
$downloadArchive = "downloaded.txt"
$sleepSubtitles = 8
```

Kör:
```powershell
.\scripts\youtube-downloader.ps1
```

### Exempel 3: Bara undertexter (ingen video) (V8)

```powershell
.\scripts\YouTube_Downloader_v8_INTERACTIVE.ps1
# Välj "2" (bara undertexter)
```

## Output-format

### Videor
- **Format:** MP4 (H.264 + AAC)
- **Filnamn:** `VideoTitel [VideoID].mp4`
- **Med embedded subs (v8):** `VideoTitel [VideoID]_with_subs.mp4`

### Undertexter
- **VTT:** Originalformat från YouTube
- **SRT:** Konverterat för bättre kompatibilitet
- **TXT:** Ren text med timestamps och videobeskrivning (v7)
- **Filnamn:** `VideoTitel [VideoID].vtt/srt/vtt.txt`

## Felsökning

### HTTP 429 (Too Many Requests)

Om du får detta fel vid spellista-nedladdning:
- **V8:** Öka delay när scriptet frågar (välj 12-15 sekunder)
- **V7:** Öka `$sleepSubtitles` till 10-15 sekunder
- Använd progress-tracking och kör scriptet flera gånger

### "yt-dlp.exe saknas"

Kontrollera att:
1. yt-dlp är installerat: `yt-dlp --version`
2. Sökvägen i scriptet är korrekt
3. Eller sätt `$yt = "yt-dlp"` om det finns i PATH

### "Skript körning är inaktiverat"

Öppna PowerShell som administratör och kör:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Undertexter konverteras inte korrekt

- Se till att ffmpeg är installerat: `ffmpeg -version`
- Version 7 har en fallback-metod för VTT→SRT konvertering

## Vilken version ska jag använda?

| Scenario | Rekommenderad version |
|----------|----------------------|
| Du är nybörjare | **Version 8 (INTERACTIVE)** |
| Engångsnedladdning | **Version 8 (INTERACTIVE)** |
| Vill ha embedded subtitles | **Version 8 (INTERACTIVE)** |
| Återkommande nedladdningar | Version 7 (CLASSIC) |
| Automation/scheduled tasks | Version 7 (CLASSIC) |
| Behöver TXT-format | Version 7 (CLASSIC) |

## Dokumentation

- **[INSTALLATION.md](docs/INSTALLATION.md)** - Detaljerad installationsguide
- **[CONFIGURATION.md](docs/CONFIGURATION.md)** - Konfigurationsguide (v7)
- **[TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)** - Felsökningsguide
- **[Version 8 Guide](docs/YouTube_Downloader_v8_GUIDE.md)** - Guide för v8
- **[Version 8 Dokumentation](docs/YouTube_Downloader_COMPLETE_DOCUMENTATION_v8.md)** - Fullständig v8 dokumentation

## Bidra

Bidrag är välkomna! Skapa gärna issues eller pull requests.

## Licens

MIT License - Se [LICENSE](LICENSE) för detaljer.

## Acknowledgments

- [yt-dlp](https://github.com/yt-dlp/yt-dlp) - Modern YouTube downloader
- [ffmpeg](https://ffmpeg.org/) - Multimedia-behandling

---

## English Summary

Powerful PowerShell scripts for downloading YouTube videos and subtitles with full playlist support.

**Two Versions:**
- **Version 8 (INTERACTIVE)** - User-friendly with interactive prompts and embedded subtitle support
- **Version 7 (CLASSIC)** - Configuration-based for advanced users and automation

**Features:**
- Download videos in highest quality (MP4 with H.264 + AAC)
- Download subtitles in multiple formats (VTT, SRT, TXT)
- Full YouTube playlist support
- Automatic subtitle format conversion
- Rate-limiting to avoid API restrictions
- Progress tracking for resumable downloads
- Embedded subtitles (v8 only)

**Requirements:**
- Windows with PowerShell 5.1+
- yt-dlp
- ffmpeg

**Quick Start:**
Double-click `RUN_DOWNLOADER.bat` or run the scripts directly with PowerShell.

See the Swedish documentation above for detailed usage instructions.