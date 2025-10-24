# YouTube Downloader v8 - INTERAKTIV MODE + EMBEDDING

## 🎯 NYA FUNKTIONER I V8

### ✅ Helt Interaktiv Konfiguration
Scriptet frågar efter ALLT:
- URL (video eller spellista)
- Vad du vill ladda ner (video/undertexter/både)
- **NYT: Bädda in undertexter i video?**
- Antal videos (för spellistor)
- Rate-limiting delay
- Progress-tracking

### ✅ Embedded Subtitles (Inbäddade Undertexter)
Undertexter bäddas in DIREKT i videofilen!
- Ingen omkodning (snabbt!)
- Undertexter alltid tillgängliga i videon
- Perfekt för mediaspelare som Plex, Kodi, VLC

---

## 🚀 SNABBSTART

```powershell
.\YouTube_Downloader_v8_INTERACTIVE.ps1
```

### Exempel-session:

```
========================================
YouTube Downloader v8.0 - INTERACTIVE
========================================

📺 STEG 1: YouTube-URL
   Exempel video: https://www.youtube.com/watch?v=xxxxx
   Exempel spellista: https://www.youtube.com/playlist?list=PLxxxxx

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

[Laddar ner...]
```

---

## 🎬 EMBEDDED SUBTITLES - HUR DET FUNGERAR

### Vad Händer?
1. Video laddas ner → `Video [ID].mp4`
2. Undertexter laddas ner → `Video [ID].en.srt`
3. ffmpeg bäddar in undertexter → `Video [ID]_with_subs.mp4`

### Resultat:
```
Filmer/
├── Rick Astley [dQw4w9WgXcQ].mp4              ← Original (utan subs)
└── Rick Astley [dQw4w9WgXcQ]_with_subs.mp4    ← Med inbäddade subs
```

### Fördelar:
- ✅ Undertexter alltid tillgängliga
- ✅ Funkar i alla mediaspelare
- ✅ Ingen omkodning = snabbt
- ✅ Original-fil bevaras

---

## 📋 SPELLISTA-SESSION

```
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
   Sekunder delay (8-12 rekommenderat, Enter = 8): 
✓ Använder 8 sekunders delay

   Spara progress för att fortsätta senare? (j/n): j
✓ Progress sparas i: youtube_progress.txt

========================================
KONFIGURATION KLAR - STARTAR NEDLADDNING
========================================
```

---

## ⚙️ AUTOMATION MODE

Om du vill skippa alla frågor (för automation):

```powershell
# Öppna scriptet, ändra rad 23:
$interactiveMode = $false

# Sätt hårdkodade värden (rad 28-34):
$videoUrl = "https://www.youtube.com/watch?v=xxxxx"
$downloadVideo = $true
$downloadSubs = $true
$embedSubtitles = $true
$maxDownloads = 10
$sleepSubtitles = 8
$downloadArchive = "progress.txt"
```

---

## 🎯 ANVÄNDNINGSFALL

### Use Case 1: En video med inbäddade undertexter
```
1) URL: https://www.youtube.com/watch?v=xxxxx
2) Val: 3 (både video och undertexter)
3) Embed: j (ja)

→ Resultat: video_with_subs.mp4 (redo för Plex/Kodi!)
```

### Use Case 2: Spellista, bara videos (snabbt)
```
1) URL: https://www.youtube.com/playlist?list=PLxxxxx
2) Val: 1 (bara video)
3) Max: 5

→ Resultat: 5 videos, inga undertexter
```

### Use Case 3: Spellista med separata undertexter
```
1) URL: https://www.youtube.com/playlist?list=PLxxxxx
2) Val: 3 (både)
3) Embed: n (nej)
4) Max: 20
5) Delay: 10
6) Progress: j

→ Resultat: 20 videos + separata VTT/SRT/TXT-filer
```

### Use Case 4: Bara undertexter för research
```
1) URL: https://www.youtube.com/playlist?list=PLxxxxx
2) Val: 2 (bara undertexter)
3) Max: 50
4) Delay: 12
5) Progress: j

→ Resultat: VTT, SRT och TXT-filer för 50 videos
```

---

## ⚠️ VIKTIGT ATT VETA

### Embedding Kräver ffmpeg
- Om ffmpeg.exe saknas → varning visas
- Embedding skippas, men övriga funktioner fungerar

### Filstorlekar vid Embedding
- **Ingen omkodning** = minimal storleksökning
- Original: 100 MB → Med subs: ~100.2 MB
- SRT-filer är små (typiskt 50-200 KB)

### Båda Versionerna Sparas
- `video.mp4` = original (utan subs)
- `video_with_subs.mp4` = med inbäddade subs
- Du kan radera original om du vill

### Progress-Tracking
- Om aktiverad: `youtube_progress.txt` sparas
- Kör scriptet igen → fortsätter automatiskt
- Skippar redan nedladdade videos

---

## 🔧 TEKNISKA DETALJER

### Embedding-Kommando (ffmpeg)
```bash
ffmpeg -i video.mp4 -i subtitles.srt \
  -c copy \              # Ingen omkodning (snabbt!)
  -c:s mov_text \        # Subtitle codec för MP4
  -metadata:s:s:0 language=eng \
  video_with_subs.mp4
```

### Subtitle-Format
- **VTT** = WebVTT (YouTube-standard)
- **SRT** = SubRip (universellt format)
- **TXT** = Ren text med tidsstämplar + beskrivning
- **Embedded** = mov_text i MP4-container

---

## 📊 FILÖVERSIKT

### Med Embedding Aktiverat:
```
Filmer/
├── Video [ID].mp4              (original)
└── Video [ID]_with_subs.mp4    (med subs) ← Använd denna!

Undertextfiler/
├── Video [ID].description
├── Video [ID].en.vtt
├── Video [ID].en.srt           ← Denna bäddades in
├── Video [ID].en.vtt.txt
└── Video [ID].sv.vtt (om tillgänglig)
```

### Utan Embedding:
```
Filmer/
└── Video [ID].mp4

Undertextfiler/
├── Video [ID].description
├── Video [ID].en.vtt
├── Video [ID].en.srt
├── Video [ID].en.vtt.txt
└── Video [ID].sv.vtt
```

---

## 💡 TIPS & TRICKS

### Testa först!
```
Max videos: 1
→ Testa att allt fungerar med en video först
```

### Stora spellistor
```
Max videos: 10
Delay: 10-12
Progress: j (ja!)
→ Kör i batches om 10
```

### Endast engelska undertexter bäddas in
- Prioritet: `.en.srt` > `.en-orig.srt` > `.srt`
- Svenska undertexter laddas ner separat

### Radera original-filer?
```powershell
# Efter embedding, om du bara vill ha _with_subs.mp4:
Get-ChildItem -Path "Filmer" -Filter "*.mp4" | 
  Where-Object { $_.Name -notlike "*_with_subs.mp4" } |
  Remove-Item
```

---

## 🆚 JÄMFÖRELSE: V7 vs V8

| Funktion | v7.0 | v8.0 |
|----------|------|------|
| Interaktiv URL | ✅ | ✅ |
| Interaktiva alternativ | ❌ | ✅ |
| Embedded subtitles | ❌ | ✅ |
| Spellista-stöd | ✅ | ✅ |
| Progress-tracking | ✅ | ✅ |
| Automation mode | Delvis | ✅ |

---

## 📞 SUPPORT

**Dokumentation:** Se andra medföljande .md-filer  
**Version:** 8.0 (Interactive + Embedding)  
**Datum:** 2025-10-21  
**Ny funktion:** Embedded subtitles (inbäddade undertexter)
