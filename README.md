# YouTube Downloader (PowerShell)

🎬 Ett kraftfullt PowerShell-script för att ladda ner YouTube-videor och undertexter, med fullt stöd för spellistor.

## Funktioner

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

## Snabbstart

### 1. Installation

#### Ladda ner beroenden

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

#### Konfigurera scriptets sökvägar

Redigera `scripts/youtube-downloader.ps1` och ändra följande variabler:

```powershell
$baseDir = "C:\DinMapp\Youtube download"  # Byt till din mapp
$filmFolder = Join-Path $baseDir "Filmer"
$subsDir = Join-Path $baseDir "Undertextfiler"
$yt = Join-Path $baseDir "yt-dlp.exe"
$ffmpeg = Join-Path $baseDir "ffmpeg.exe"
```

### 2. Grundläggande användning

```powershell
# Kör scriptet
.\scripts\youtube-downloader.ps1

# Du kommer bli tillfrågad om en URL
# Exempel:
# Enskild video: https://www.youtube.com/watch?v=aMYyBsjhBR4
# Spellista: https://www.youtube.com/playlist?list=PLxxxxxx
```

### 3. Anpassad konfiguration

Du kan också sätta URL:en direkt i scriptet:

```powershell
# I början av scriptet:
$videoUrl = "https://www.youtube.com/watch?v=aMYyBsjhBR4"

# Välj vad som ska laddas ner:
$downloadVideo = $true      # Ladda ner video
$downloadSubs = $true       # Ladda ner undertexter
```

## Avancerade funktioner

### Spellista-alternativ

```powershell
# Begränsa antal nedladdningar
$maxDownloads = 10              # Ladda bara ner 10 videos

# Välj intervall
$playlistStart = 5              # Börja från video 5
$playlistEnd = 15               # Sluta vid video 15

# Omvänd ordning
$playlistReverse = $true        # Börja från sista videon

# Spara progress
$downloadArchive = "downloaded.txt"  # Skippa redan nedladdade videos
```

### Rate-limiting

För spellistor är det viktigt att använda rate-limiting för att undvika HTTP 429-fel:

```powershell
$sleepSubtitles = 8  # Sekunder mellan subtitle-requests (standard: 4)
```

### Felhantering

```powershell
$ignoreErrors = $true  # Fortsätt med nästa video vid fel
```

## Projektstruktur

```
Youtube-downloader/
├── scripts/
│   └── youtube-downloader.ps1    # Huvudscript
├── examples/
│   ├── config-basic.ps1          # Grundläggande konfiguration
│   ├── config-playlist.ps1       # Spellista-konfiguration
│   └── config-advanced.ps1       # Avancerade alternativ
├── docs/
│   ├── INSTALLATION.md           # Detaljerad installationsguide
│   ├── CONFIGURATION.md          # Konfigurationsguide
│   └── TROUBLESHOOTING.md        # Felsökningsguide
└── README.md                     # Denna fil
```

## Exempel på användning

### Exempel 1: Ladda ner en enskild video med undertexter

```powershell
# Kör scriptet och ange URL när du tillfrågas
.\scripts\youtube-downloader.ps1
```

### Exempel 2: Ladda ner en spellista (första 20 videos)

```powershell
# Konfigurera i scriptet:
$videoUrl = "https://www.youtube.com/playlist?list=PLxxxxxx"
$maxDownloads = 20
$downloadArchive = "downloaded.txt"
$sleepSubtitles = 8

# Kör scriptet
.\scripts\youtube-downloader.ps1
```

### Exempel 3: Bara undertexter (ingen video)

```powershell
# Konfigurera i scriptet:
$downloadVideo = $false
$downloadSubs = $true

# Kör scriptet
.\scripts\youtube-downloader.ps1
```

## Output-format

### Videor
- **Format:** MP4 (H.264 + AAC)
- **Filnamn:** `VideoTitel [VideoID].mp4`
- **Plats:** `$filmFolder`

### Undertexter
- **VTT:** Originalformat från YouTube
- **SRT:** Konverterat för bättre kompatibilitet
- **TXT:** Ren text med timestamps och videobeskrivning
- **Filnamn:** `VideoTitel [VideoID].vtt/srt/vtt.txt`
- **Plats:** `$subsDir`

## Felsökning

### HTTP 429 (Too Many Requests)

Om du får detta fel vid spellista-nedladdning:
- Öka `$sleepSubtitles` till 10-15 sekunder
- Använd `$maxDownloads` för att begränsa antalet videos
- Aktivera `$downloadArchive` för att kunna fortsätta senare

### "yt-dlp.exe saknas"

Kontrollera att:
1. yt-dlp är installerat
2. Sökvägen i `$yt` är korrekt
3. Filen har körningsrättigheter

### Undertexter konverteras inte korrekt

- Se till att ffmpeg är installerat och korrekt konfigurerat
- Scriptet har en fallback-metod för VTT→SRT konvertering

## Bidra

Bidrag är välkomna! Skapa gärna issues eller pull requests.

## Licens

MIT License - Se LICENSE-filen för detaljer.

## Acknowledgments

- [yt-dlp](https://github.com/yt-dlp/yt-dlp) - Modern YouTube downloader
- [ffmpeg](https://ffmpeg.org/) - Multimedia-behandling

---

## English Summary

A powerful PowerShell script for downloading YouTube videos and subtitles with full playlist support.

**Features:**
- Download videos in highest quality (MP4 with H.264 + AAC)
- Download subtitles in multiple formats (VTT, SRT, TXT)
- Full YouTube playlist support
- Automatic subtitle format conversion
- Rate-limiting to avoid API restrictions
- Progress tracking for resumable downloads
- Customizable download options

**Requirements:**
- Windows with PowerShell 5.1+
- yt-dlp
- ffmpeg

See the Swedish documentation above for detailed usage instructions.
