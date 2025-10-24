# Konfigurationsguide

Denna guide förklarar alla konfigurationsalternativ i YouTube Downloader.

## Innehåll
- [Grundläggande konfiguration](#grundläggande-konfiguration)
- [Sökvägar](#sökvägar)
- [Nedladdningsalternativ](#nedladdningsalternativ)
- [Spellista-alternativ](#spellista-alternativ)
- [Rate-limiting](#rate-limiting)
- [Felhantering](#felhantering)
- [Avancerade användningsfall](#avancerade-användningsfall)

## Grundläggande konfiguration

De viktigaste variablerna finns i början av scriptet (`scripts/youtube-downloader.ps1`).

### Sökvägar

```powershell
# Huvudmapp för alla nedladdningar
$baseDir = "C:\Youtube"

# Mapp för videor
$filmFolder = Join-Path $baseDir "Videos"

# Mapp för undertexter
$subsDir = Join-Path $baseDir "Subtitles"

# Sökväg till yt-dlp (kan vara kommando eller full sökväg)
$yt = "yt-dlp"          # Om i PATH
# eller
$yt = "C:\Tools\yt-dlp.exe"  # Full sökväg

# Sökväg till ffmpeg
$ffmpeg = "ffmpeg"      # Om i PATH
# eller
$ffmpeg = "C:\Tools\ffmpeg.exe"  # Full sökväg
```

**Tips:**
- Använd `Join-Path` för portabilitet mellan olika Windows-versioner
- Om verktyget är i din PATH kan du bara använda namnet
- Undvik mellanslag i sökvägar om möjligt

### URL-konfiguration

```powershell
# Sätt URL direkt (hoppar över prompt)
$videoUrl = "https://www.youtube.com/watch?v=xxxxxxxx"

# Eller lämna tom för interaktiv prompt
$videoUrl = ""
```

**När ska man använda vilken metod?**
- **Tom URL:** När du kör scriptet manuellt och vill ange URL varje gång
- **Förifylld URL:** När du kör scriptet automatiskt eller via scheduled task

## Nedladdningsalternativ

### Välja vad som ska laddas ner

```powershell
$downloadVideo = $true   # Ladda ner video
$downloadSubs = $true    # Ladda ner undertexter
```

**Vanliga kombinationer:**

| Video | Subs | Användningsfall |
|-------|------|-----------------|
| true  | true | Standard - allt |
| true  | false| Bara video (sparar tid) |
| false | true | Bara undertexter (för transkriptering) |
| false | false| Ingen mening - scriptet gör ingenting |

### Videoformat

Scriptet använder följande format-prioritering:

```powershell
-S "ext:mp4:m4a,vcodec:h264,acodec:aac"
-f "bv*+ba/best"
```

Detta betyder:
- **Föredrar:** MP4-container med H.264 video och AAC audio
- **Fallback:** Bästa tillgängliga kvalitet
- **Resultat:** Högsta kompatibilitet med de flesta spelare

**Varför dessa format?**
- H.264: Universellt stöd, bra kvalitet/storlek-ratio
- AAC: Modern ljudcodec med bra komprimering
- MP4: Fungerar överallt (Windows, Mac, mobiler, webbläsare)

### Undertextformat

Scriptet laddar ner och konverterar undertexter till flera format:

| Format | Användning |
|--------|------------|
| VTT    | Original från YouTube |
| SRT    | Standard för videospelare |
| TXT    | Läsbart textformat med timestamps |

**Undertextspråk:**

```powershell
--sub-langs "en.*,sv.*"
```

Detta laddar ner:
- Engelska undertexter (alla varianter)
- Svenska undertexter (alla varianter)

**Ändra språk:**

```powershell
# Bara engelska
--sub-langs "en.*"

# Engelska och spanska
--sub-langs "en.*,es.*"

# Alla tillgängliga språk
--sub-langs "all"
```

## Spellista-alternativ

### Begränsa antal nedladdningar

```powershell
$maxDownloads = 10
```

**Använd när:**
- Du testar scriptet första gången
- Du bara vill ha de första X videos från en spellista
- Du vill dela upp en stor spellista i mindre batcher

**Exempel:**

```powershell
# Ladda ner första 5 videos (test)
$maxDownloads = 5

# Ladda ner 100 videos åt gången
$maxDownloads = 100
```

### Välj intervall i spellistan

```powershell
$playlistStart = 5    # Börja från video 5
$playlistEnd = 15     # Sluta vid video 15
```

**Använd när:**
- Du vill ha ett specifikt intervall
- Du fortsätter en avbruten nedladdning manuellt
- Du delar upp arbetet mellan flera datorer

**Exempel:**

```powershell
# Ladda ner videos 1-50
$playlistStart = 1
$playlistEnd = 50

# Ladda ner videos 51-100
$playlistStart = 51
$playlistEnd = 100
```

### Progress-tracking

```powershell
$downloadArchive = "downloaded.txt"
```

**Hur det fungerar:**
- Varje nedladdad videos ID sparas i filen
- Nästa gång scriptet körs skippar det videos i filen
- Perfekt för att fortsätta avbrutna nedladdningar

**Använd när:**
- Du laddar ner stora spellistor (>50 videos)
- Du vill köra scriptet flera gånger
- Du är osäker på nätverkets stabilitet

**Exempel:**

```powershell
# Standard
$downloadArchive = "downloaded.txt"

# Per-spellista archive
$downloadArchive = "my-playlist-archive.txt"

# Datum i filnamn
$downloadArchive = "archive-$(Get-Date -Format 'yyyy-MM-dd').txt"
```

### Omvänd ordning

```powershell
$playlistReverse = $true
```

**Använd när:**
- Du vill ha de senaste videos först
- Spellistan är kronologisk och du vill ha nyaste först
- Du fortsätter från slutet av en spellista

### Kombinationsexempel

**Ladda ner en hel spellista säkert:**

```powershell
$videoUrl = "https://www.youtube.com/playlist?list=PLxxxxxx"
$downloadArchive = "playlist-archive.txt"
$sleepSubtitles = 10
$ignoreErrors = $true
# Kör scriptet flera gånger tills allt är klart
```

**Ladda ner första 20, hoppa första 5:**

```powershell
$videoUrl = "https://www.youtube.com/playlist?list=PLxxxxxx"
$playlistStart = 6
$maxDownloads = 20
```

## Rate-limiting

### Sleep mellan subtitle-requests

```powershell
$sleepSubtitles = 4    # Standard för enskilda videos
$sleepSubtitles = 10   # Rekommenderat för spellistor
```

**Varför viktigt?**
- YouTube rate-limiterar subtitle-requests hårdare än video-requests
- För många requests → HTTP 429 (Too Many Requests)
- Med korrekt delay: inga problem

**Rekommendationer:**

| Scenario | Rekommenderad delay |
|----------|---------------------|
| Enskild video | 4s (standard) |
| Spellista 1-10 videos | 6s |
| Spellista 10-50 videos | 8-10s |
| Spellista 50+ videos | 10-15s |
| HTTP 429-fel inträffat | 15-20s |

## Felhantering

### Fortsätt vid fel

```powershell
$ignoreErrors = $true
```

**Vad händer:**
- Om en video failar: scriptet fortsätter med nästa
- Utan denna: scriptet avbryts vid första felet

**Använd när:**
- Du laddar ner spellistor (vissa videos kan vara privata/borttagna)
- Du vill ha så många videos som möjligt
- Du inte bryr dig om alla videos lyckas

**Använd INTE när:**
- Du måste ha alla videos (kvalitetskontroll)
- Du vill felsöka varför videos failar

## Avancerade användningsfall

### Bara nya videos från en kanal

```powershell
$videoUrl = "https://www.youtube.com/@channelname/videos"
$downloadArchive = "channel-archive.txt"
$maxDownloads = 20
$sleepSubtitles = 10
$ignoreErrors = $true
```

Kör regelbundet (t.ex. via scheduled task) för att hålla dig uppdaterad.

### Backup av spellista (allt utom video)

```powershell
$downloadVideo = $false
$downloadSubs = $true
$videoUrl = "https://www.youtube.com/playlist?list=PLxxxxxx"
$downloadArchive = "backup-archive.txt"
```

Detta ger dig alla undertexter och beskrivningar utan att ta mycket diskutrymme.

### Stor spellista i delar

**Del 1 (videos 1-100):**
```powershell
$playlistStart = 1
$playlistEnd = 100
$downloadArchive = "part1.txt"
```

**Del 2 (videos 101-200):**
```powershell
$playlistStart = 101
$playlistEnd = 200
$downloadArchive = "part2.txt"
```

### Test före full nedladdning

```powershell
# STEG 1: Testa med första videon
$maxDownloads = 1
$sleepSubtitles = 4

# STEG 2: Om OK, kör 10 videos
$maxDownloads = 10
$downloadArchive = "test-archive.txt"

# STEG 3: Om OK, kör allt
Remove-Variable maxDownloads
$downloadArchive = "full-archive.txt"
$sleepSubtitles = 10
```

## Tips & bästa praxis

1. **Börja smått:** Testa alltid med `$maxDownloads = 1` först
2. **Använd archive:** Alltid för spellistor med >10 videos
3. **Öka sleep:** Hellre för långsamt än HTTP 429-fel
4. **Ignorera fel:** Sätt `$ignoreErrors = $true` för spellistor
5. **Schemalägg:** Använd Windows Task Scheduler för automatiska nedladdningar
6. **Backup konfiguration:** Spara din config i `config.local.ps1` (finns i .gitignore)

## Nästa steg

- Se [exempel-konfigurationer](../examples/) för färdiga konfigurationer
- Läs [TROUBLESHOOTING.md](TROUBLESHOOTING.md) om du stöter på problem
- Läs [INSTALLATION.md](INSTALLATION.md) om du behöver hjälp med installation
