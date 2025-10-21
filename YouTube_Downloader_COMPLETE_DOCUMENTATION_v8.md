# YouTube Downloader - Komplett Dokumentation v8.0

**Projekt:** YouTube video & undertextsnedladdning med interaktiv konfiguration  
**Version:** 8.0 (Interactive + Embedding)  
**Datum:** 2025-10-21  
**Status:** Produktionsklar med UTF-16LE encoding för PowerShell

---

## 🎯 VAD ÄR NYTT I V8.0?

### ✨ Nya Funktioner
1. **Helt Interaktiv Konfiguration** - Scriptet frågar efter allt
2. **Embedded Subtitles** - Bädda in undertexter direkt i videofiler
3. **Enkel Körning** - .BAT-fil för dubbelklick-start
4. **UTF-16LE Encoding** - Optimerad för PowerShell

### 📋 Vad Scriptet Frågar Efter
- 📺 YouTube-URL (video eller spellista)
- 📦 Vad vill du ladda ner? (video/undertexter/både)
- 🎬 Bädda in undertexter i video? (j/n)
- 📋 Spellista-inställningar (antal, delay, progress)

---

## 🚀 SNABBSTART

### Metod 1: .BAT-fil (ENKLAST!)

1. Ladda ner filerna:
   - `YouTube_Downloader_v8_INTERACTIVE.ps1`
   - `RUN_DOWNLOADER.bat`

2. Lägg båda i samma mapp (din Youtube download-mapp)

3. **Dubbelklicka på `RUN_DOWNLOADER.bat`**

4. Svara på frågorna!

### Metod 2: PowerShell

```powershell
cd "C:\Users\JMS\OneDrive - Dala VS Värme & Sanitet\Privat\Youtube download"
.\YouTube_Downloader_v8_INTERACTIVE.ps1
```

---

## 📺 INTERAKTIV SESSION - EXEMPEL

### Enskild Video med Embedded Subtitles

```
========================================
YouTube Downloader v8.0 - INTERACTIVE
========================================

📺 STEG 1: YouTube-URL
   Exempel video: https://www.youtube.com/watch?v=xxxxx

URL: https://www.youtube.com/watch?v=dQw4w9WgXcQ
✓ Enskild video detekterad

📦 STEG 2: Vad vill du ladda ner?
   1) Bara video
   2) Bara undertexter
   3) Både video och undertexter

Val (1-3): 3
✓ Laddar både video och undertexter

🎬 STEG 3: Bädda in undertexter i video?
   Detta bränner in undertexterna direkt i videofilen
   (kräver ffmpeg och tar lite längre tid)

   Vill du bädda in undertexter? (j/n): j
✓ Undertexter kommer bäddas in i video

========================================
KONFIGURATION KLAR - STARTAR NEDLADDNING
========================================

==> LADDAR NER VIDEO...
[download] Rick Astley - Never Gonna Give You Up.mp4

==> LADDAR NER UNDERTEXTER...
✓ Hittade 2 VTT-fil(er)

==> Konverterar VTT → SRT...
  ✓ Rick Astley [dQw4w9WgXcQ].en.vtt → SRT

==> Genererar TXT-filer...
  ✓ Rick Astley [dQw4w9WgXcQ].en.vtt → TXT (245 cues)

==> BÄDDAR IN UNDERTEXTER I VIDEO...
  🎬 Bearbetar: Rick Astley [dQw4w9WgXcQ].mp4
     Undertexter: Rick Astley [dQw4w9WgXcQ].en.srt
     ✓ Klar! Ny storlek: 78.5 MB (original: 78.3 MB)

======== SAMMANFATTNING ========

Video:
  ✓ Antal filer: 2
  ✓ Total storlek: 156.8 MB
  ✓ Med inbäddade undertexter: 1 filer
    🎬 Rick Astley [dQw4w9WgXcQ]_with_subs.mp4 (78.50 MB)
    📹 Rick Astley [dQw4w9WgXcQ].mp4 (78.30 MB)

Undertexter:
  ✓ VTT: 2 filer
  ✓ SRT: 2 filer
  ✓ TXT: 2 filer
  ✓ Beskrivningar: 1 filer

==> KLART!
```

### Spellista med Avancerade Inställningar

```
📺 STEG 1: YouTube-URL
URL: https://www.youtube.com/playlist?list=PLxxxxxx
✓ Spellista detekterad!

📦 STEG 2: Vad vill du ladda ner?
Val (1-3): 3
✓ Laddar både video och undertexter

🎬 STEG 3: Bädda in undertexter i video?
   Vill du bädda in undertexter? (j/n): j
✓ Undertexter kommer bäddas in i video

📋 STEG 4: Spellista-inställningar
   Hur många videos vill du ladda ner? (Enter = alla): 10
✓ Laddar max 10 videos

   Rate-limiting (delay mellan undertext-requests):
   Sekunder delay (8-12 rekommenderat, Enter = 8): 10
✓ Använder 10 sekunders delay

   Spara progress för att fortsätta senare? (j/n): j
✓ Progress sparas i: youtube_progress.txt

========================================
KONFIGURATION KLAR - STARTAR NEDLADDNING
========================================

[Laddar ner 10 videos med embedded subtitles...]

📋 SPELLISTA-INFO:
  Progress sparad i: youtube_progress.txt
  💡 Kör scriptet igen för att fortsätta!
```

---

## 🎬 EMBEDDED SUBTITLES - DETALJERAD FÖRKLARING

### Vad Är Det?
Undertexter bäddas in som en text-track INUTI MP4-filen, precis som professionella filmer.

### Process
1. **Ladda ner video** → `Video [ID].mp4`
2. **Ladda ner undertexter** → `Video [ID].en.srt`
3. **ffmpeg bäddar in** → `Video [ID]_with_subs.mp4`

### Teknisk Implementering
```bash
ffmpeg -i video.mp4 -i subtitles.srt \
  -c copy \                    # Ingen omkodning = snabbt!
  -c:s mov_text \              # Subtitle codec för MP4
  -metadata:s:s:0 language=eng \
  -metadata:s:s:0 title="English" \
  video_with_subs.mp4
```

### Fördelar
- ✅ **Ingen omkodning** - Video kopieras direkt, inga kvalitetsförluster
- ✅ **Minimal storleksökning** - SRT-filer är små (~100-200 KB)
- ✅ **Universell kompatibilitet** - Funkar i VLC, Plex, Kodi, Windows Media Player
- ✅ **Alltid tillgängliga** - Undertexter följer med videon automatiskt
- ✅ **Original bevaras** - Båda versionerna sparas

### Resultat
```
Filmer/
├── Rick Astley [dQw4w9WgXcQ].mp4              ← Original (78.3 MB)
└── Rick Astley [dQw4w9WgXcQ]_with_subs.mp4    ← Med subs (78.5 MB)
```

### I Mediaspelare
När du öppnar `*_with_subs.mp4`:
- VLC: Högerklicka → Subtitle → Track 1
- Plex/Kodi: Undertexter visas automatiskt eller via inställningar
- Windows Media Player: Play → Lyrics, captions, and subtitles

---

## 📁 FILSTRUKTUR - KOMPLETT ÖVERSIKT

### Med Embedding Aktiverat
```
Youtube download/
├── yt-dlp.exe
├── ffmpeg.exe
├── RUN_DOWNLOADER.bat                          ← DUBBELKLICKA HÄR!
├── YouTube_Downloader_v8_INTERACTIVE.ps1
├── youtube_progress.txt                        ← Skapas om progress-tracking aktivt
│
├── Filmer/
│   ├── Video Title [ID].mp4                    ← Original utan subs
│   └── Video Title [ID]_with_subs.mp4          ← Med inbäddade subs ✓
│
└── Undertextfiler/
    ├── Video Title [ID].description            ← Videobeskrivning
    ├── Video Title [ID].en.vtt                 ← VTT-format
    ├── Video Title [ID].en-orig.vtt            ← Original VTT
    ├── Video Title [ID].en.srt                 ← SRT-format (användes för embedding)
    ├── Video Title [ID].en-orig.srt
    ├── Video Title [ID].en.vtt.txt             ← TXT med tidsstämplar + beskrivning
    ├── Video Title [ID].en-orig.vtt.txt
    └── Video Title [ID].sv.vtt                 ← Svenska (om tillgängligt)
```

---

## ⚙️ AVANCERADE ALTERNATIV - FÖRKLARING

### 1. Max Downloads (Spellistor)
**Fråga:** "Hur många videos vill du ladda ner? (Enter = alla)"

**Användning:**
- `Enter` = Laddar alla videos i spellistan
- `10` = Laddar bara första 10 videos
- Perfekt för att testa eller köra i batches

### 2. Rate Limiting Delay
**Fråga:** "Sekunder delay (8-12 rekommenderat, Enter = 8)"

**Förklaring:**
- YouTube rate-limitar aggressivt vid undertext-nedladdningar
- För enskilda videos: 4s räcker
- För spellistor: 8-12s rekommenderat
- Vid HTTP 429-fel: Öka till 12-15s

**Rekommendationer:**
- 1-10 videos: 8s
- 10-50 videos: 10s
- 50+ videos: 12-15s

### 3. Progress Tracking
**Fråga:** "Spara progress för att fortsätta senare? (j/n)"

**Hur det fungerar:**
- Skapar `youtube_progress.txt`
- Loggar alla nedladdade video-ID:n
- Vid nästa körning: yt-dlp skippar automatiskt redan nedladdade videos

**Användning:**
```
Körning 1: Laddar video 1-10 (sedan HTTP 429)
Körning 2: Skippar 1-10, laddar 11-20
Körning 3: Skippar 1-20, laddar 21-30
```

**Perfekt för:**
- Stora spellistor (50+ videos)
- Instabil internetanslutning
- Rate-limiting problem

---

## 🎯 ANVÄNDNINGSFALL & EXEMPEL

### Use Case 1: En Tutorial-Video för Offline-Visning
```
Scenario: Ladda ner en instruktionsvideo med undertexter
URL: https://www.youtube.com/watch?v=xxxxx
Val: 3 (både video och undertexter)
Embed: j (ja)

Resultat:
✓ video_with_subs.mp4 (redo att kolla offline med undertexter)
✓ Original-filer som backup
```

### Use Case 2: Kurs-Spellista (50 videos)
```
Scenario: Ladda ner en hel online-kurs
URL: https://www.youtube.com/playlist?list=PLxxxxx
Val: 3 (både)
Embed: j (ja)
Max: 10
Delay: 10s
Progress: j (ja)

Strategi:
- Kör 1: Videos 1-10
- Kör 2: Videos 11-20 (auto-skippar 1-10)
- Kör 3: Videos 21-30
- osv...

Resultat:
✓ 50 videos med inbäddade undertexter
✓ Alla separata undertextfiler för sökning/analys
```

### Use Case 3: Dokumentär-Serie för Plex
```
Scenario: Arkivera en dokumentärserie till mediaserver
URL: https://www.youtube.com/playlist?list=PLxxxxx
Val: 3
Embed: j (ja)
Max: alla (Enter)
Delay: 12s
Progress: j

Resultat:
✓ Alla avsnitt med embedded subs
✓ Direkt kompatibel med Plex/Kodi
✓ Undertexter aktiveras automatiskt
```

### Use Case 4: Research-Material (Bara Undertexter)
```
Scenario: Samla transkript för textanalys
URL: https://www.youtube.com/playlist?list=PLxxxxx
Val: 2 (bara undertexter)
Max: 100
Delay: 10s
Progress: j

Resultat:
✓ 100 TXT-filer med tidsstämplar
✓ Videobeskrivningar
✓ VTT/SRT för andra användningar
✓ Inga videos (sparar disk & tid)
```

### Use Case 5: Snabb Video-Backup (Ingen Embedding)
```
Scenario: Snabbt backup av videos utan extras
URL: https://www.youtube.com/playlist?list=PLxxxxx
Val: 1 (bara video)
Max: 20
(Embedding skippas automatiskt)

Resultat:
✓ 20 videos, snabbt nedladdade
✓ Inga undertexter = snabbare process
```

---

## 🔧 AUTOMATION MODE - FÖR AVANCERADE ANVÄNDARE

Om du vill skippa alla frågor och köra scriptad nedladdning:

### Aktivera Automation Mode

Öppna `YouTube_Downloader_v8_INTERACTIVE.ps1` och ändra rad 23:

```powershell
# Ändra från:
$interactiveMode = $true

# Till:
$interactiveMode = $false
```

### Konfigurera Hårdkodade Värden (rad 28-34)

```powershell
$videoUrl = "https://www.youtube.com/playlist?list=PLxxxxx"
$downloadVideo = $true
$downloadSubs = $true
$embedSubtitles = $true
$maxDownloads = 10              # null = ingen gräns
$sleepSubtitles = 10
$downloadArchive = "progress.txt"  # null = ingen tracking
```

### Kör Script utan Frågor

```powershell
.\YouTube_Downloader_v8_INTERACTIVE.ps1
```

Scriptet kör direkt utan att fråga något!

---

## 🐛 FELSÖKNING

### Problem 1: "cannot be loaded" / "not digitally signed"

**Lösning A - Unblock filen:**
```powershell
Unblock-File .\YouTube_Downloader_v8_INTERACTIVE.ps1
```

**Lösning B - Använd .BAT-filen:**
```
Dubbelklicka på RUN_DOWNLOADER.bat
```

**Lösning C - Execution Policy:**
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Problem 2: Encoding-fel / Parse-errors

**Symptom:** "Missing statement block" eller liknande fel

**Orsak:** Fel encoding när filen laddades ner

**Lösning:** Ladda ner den uppdaterade v8-filen (UTF-16LE encoded)

### Problem 3: HTTP 429 - Too Many Requests

**Symptom:**
```
ERROR: Unable to download video subtitles for 'sv': HTTP Error 429
```

**Lösningar:**
1. Öka delay: Säg `12` istället för `8` när scriptet frågar
2. Minska antal videos per batch: Säg `5` istället för `10`
3. Vänta 1-2 timmar och försök igen
4. Kör i mindre batches över flera dagar

### Problem 4: Embedding Failar

**Symptom:** "ffmpeg.exe saknas"

**Lösning:** Ladda ner ffmpeg.exe till din Youtube download-mapp:
- https://www.gyan.dev/ffmpeg/builds/
- Välj "release essentials"
- Extrahera `ffmpeg.exe` till din mapp

**Alternativ:** Säg `n` när scriptet frågar om embedding

### Problem 5: Videos Laddar Långsamt

**Tips:**
- Testa din internetanslutning
- Stäng andra nedladdningar
- För stora spellistor: Använd progress-tracking och kör i batches
- Överväg att bara ladda undertexter först (`Val: 2`)

---

## 📊 PRESTANDADATA

### Enskild Video (10 min, 1080p)
- Video: ~200 MB, ~30 sekunder
- Undertexter: ~100 KB, ~5 sekunder
- VTT→SRT konvertering: <1 sekund
- TXT-generering: <1 sekund
- Embedding: ~2 sekunder
- **Total tid: ~40 sekunder**

### Spellista (10 videos, 10 min varje)
- Videos: ~2 GB, ~5 minuter
- Undertexter: ~1 MB, ~2 minuter (med 10s delay)
- Konverteringar: ~10 sekunder
- Embedding: ~20 sekunder
- **Total tid: ~7-8 minuter**

### Bara Undertexter (100 videos)
- Undertexter: ~10 MB, ~20 minuter (med 10s delay)
- Konverteringar: ~1 minut
- TXT-generering: ~2 minuter
- **Total tid: ~23 minuter**

---

## 💾 DISKUTRYMME

### Per Video (typiskt)
- Original video (1080p, 10 min): ~200 MB
- Med embedded subs: ~200.2 MB (+0.2 MB)
- VTT-filer: ~100 KB
- SRT-filer: ~100 KB
- TXT-filer: ~150 KB
- **Total per video: ~200.5 MB**

### Spellista (50 videos)
- Videos med subs: ~10 GB
- Alla undertextfiler: ~25 MB
- **Total: ~10 GB**

---

## 🔒 SÄKERHET & INTEGRITET

### Vad Scriptet Gör
- ✅ Laddar ner från YouTube via yt-dlp (officiellt verktyg)
- ✅ Konverterar undertextformat lokalt
- ✅ Bäddar in undertexter lokalt med ffmpeg
- ✅ Skapar textfiler för analys
- ❌ Skickar INGEN data någonstans
- ❌ Installerar INGET

### Verktyg Som Används
- **yt-dlp** - Open source, 60k+ GitHub stars
- **ffmpeg** - Industry standard, används av alla stora tech-företag
- **PowerShell** - Microsofts officiella scripting-språk

### Dina Filer
- Allt sparas lokalt på din dator
- Inget delas eller laddas upp
- Du äger alla nedladdade filer

---

## 📚 TEKNISK DOKUMENTATION

### Subtitle Format-Konverteringar

#### VTT → SRT
```
Input:  WEBVTT med style tags och metadata
Output: SubRip med sekvens-nummer

00:00:03.000 --> 00:00:05.500  →  1
                                   00:00:03,000 --> 00:00:05,500
```

#### VTT → TXT
```
Input:  VTT med repetitioner
Process:
1. Parse alla cue-blocks
2. Extrahera timestamps + text
3. Remove konsekutiva duplikater
4. Lägg till video-beskrivning

Output: Clean TXT med tidsstämplar
```

### Embedding Process (Tekniskt)
```bash
# Steg 1: Verifiera input
- video.mp4 existerar?
- subtitles.srt existerar?
- ffmpeg.exe existerar?

# Steg 2: ffmpeg kommando
ffmpeg -y -loglevel error \
  -i video.mp4 \                    # Input video
  -i subtitles.srt \                # Input subs
  -c copy \                         # Copy video/audio streams (no re-encode)
  -c:s mov_text \                   # Subtitle codec for MP4
  -metadata:s:s:0 language=eng \    # Set language metadata
  -metadata:s:s:0 title="English" \ # Set track title
  video_with_subs.mp4               # Output

# Steg 3: Verifiera output
- video_with_subs.mp4 skapades?
- Filstorlek > original?
```

---

## 🆚 VERSIONSHISTORIK

| Version | Datum | Nya Funktioner |
|---------|-------|----------------|
| v1.0 | 2025-10-21 | Initial release |
| v2.0 | 2025-10-21 | HTTP 429 fix, Get-ChildItem fixes |
| v3.0 | 2025-10-21 | TXT-generering med dedupe |
| v4.0 | 2025-10-21 | ffmpeg fallback för SRT |
| v5.0 | 2025-10-21 | Literal matching (.Contains) |
| v6.0 | 2025-10-21 | Kombinerat video + subs |
| v7.0 | 2025-10-21 | Spellista-stöd, interaktiv URL |
| **v8.0** | **2025-10-21** | **Full interaktivitet + Embedded subtitles + UTF-16LE encoding** |

---

## 🎓 LÄRDOMAR FRÅN UTVECKLINGEN

### PowerShell-Specifika Fallgropar (Fixade)
1. ✅ Get-ChildItem -Include kräver -Recurse
2. ✅ Brackets i filnamn tolkas som wildcard
3. ✅ Get-Content -Raw finns inte i alla versioner
4. ✅ UTF-8 vs UTF-16LE för .ps1-filer
5. ✅ Execution Policy-problem
6. ✅ OneDrive markerar filer som "downloaded from internet"

### YouTube/yt-dlp-Specifikt (Hanterat)
1. ✅ HTTP 429 rate-limiting
2. ✅ Exit code 1 vid partial success
3. ✅ Dubbla VTT-filer (orig vs auto)
4. ✅ Undertexter upprepar sig per frame

### Designprinciper Som Fungerade
- ✅ Strukturerad parsing över regex
- ✅ Separation of concerns (VTT→SRT→TXT separata steg)
- ✅ Explicit validering efter varje steg
- ✅ Konsekutiv dedupe för undertexter
- ✅ UTF-8 överallt (men UTF-16LE för .ps1)
- ✅ Interaktiv feedback till användaren

---

## 📞 SUPPORT & RESURSER

### Dokumentation
- **Denna fil** - Komplett dokumentation
- `YouTube_Downloader_v8_GUIDE.md` - Snabbguide med exempel
- `VERIFIED_ISSUES_AND_FIXES.md` - Alla buggar och fixes

### Verktyg
- **yt-dlp:** https://github.com/yt-dlp/yt-dlp
- **ffmpeg:** https://ffmpeg.org/

### Vanliga Frågor

**Q: Kan jag bädda in svenska undertexter?**
A: Ja! Scriptet prioriterar engelska, men du kan manuellt köra:
```powershell
ffmpeg -i video.mp4 -i subs.sv.srt -c copy -c:s mov_text -metadata:s:s:0 language=swe output.mp4
```

**Q: Kan jag ladda ner 4K-videos?**
A: Ja! yt-dlp väljer automatiskt högsta kvalitet. För att garantera 4K:
```powershell
# Ändra i scriptet, rad 201:
"-f", "bestvideo[height>=2160]+bestaudio/best"
```

**Q: Varför två versioner av varje fil (*_with_subs.mp4 och .mp4)?**
A: För säkerhet! Original bevaras alltid. Du kan radera den om du vill.

**Q: Kan scriptet ladda ner från andra sajter?**
A: Ja! yt-dlp stödjer 1000+ sajter. Ändra bara URL:en.

---

## 🎉 SAMMANFATTNING

### v8.0 Har Allt
- ✅ **Full interaktivitet** - Frågar efter allt du behöver
- ✅ **Embedded subtitles** - Undertexter inbäddade i video
- ✅ **Enkel körning** - .BAT-fil för dubbelklick
- ✅ **Spellista-stöd** - Med progress-tracking
- ✅ **Rate-limiting** - Undviker HTTP 429
- ✅ **UTF-16LE encoding** - Optimerad för PowerShell
- ✅ **Automation mode** - För scriptad användning
- ✅ **Alla format** - VTT, SRT, TXT, embedded

### Perfekt För
- 🏠 Hemma-mediaserver (Plex, Kodi, Jellyfin)
- 📚 Arkivering och backup
- 🎓 Utbildningsmaterial offline
- 📝 Transkribering och textanalys
- 🎬 Innehållsskapare

### Börja Nu!
1. Ladda ner `YouTube_Downloader_v8_INTERACTIVE.ps1`
2. Ladda ner `RUN_DOWNLOADER.bat`
3. Dubbelklicka på `RUN_DOWNLOADER.bat`
4. Njut! 🎉

---

**Version:** 8.0 (Interactive + Embedding + UTF-16LE)  
**Datum:** 2025-10-21  
**Status:** Produktionsklar  
**Total utvecklingstid:** ~5 timmar  
**Iterationer:** 8 versioner (v1 → v8)  
**Resultat:** Professionell lösning för alla användningsfall

---

**Lycka till med dina nedladdningar! 🚀**
