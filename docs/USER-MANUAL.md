# YouTube Downloader - Användarmanual

En enkel och kraftfull YouTube-nedladdare med grafiskt gränssnitt.

---

## Installation

1. **Ladda ner installer**
   - Hämta `YouTubeDownloader-Setup-X.X.X.exe` från releases

2. **Kör installern**
   - Dubbelklicka på nedladdad fil
   - Välj var du vill installera programmet (standard: `C:\Program Files\YouTube Downloader`)
   - Välj var dina nedladdningar ska sparas (standard: `Dokument\YouTube Downloads`)

3. **Klicka "Installera"**
   - Installern laddar ner automatiskt yt-dlp och ffmpeg (kan ta några minuter första gången)

4. **Klart!**
   - Starta programmet från skrivbordsgenvägen eller startmenyn

---

## Använda Programmet

### Grundläggande Nedladdning

1. **Kopiera YouTube-URL**
   - Gå till YouTube och kopiera länken till videon

2. **Klistra in i YouTube Downloader**
   - Öppna programmet
   - Klistra in URL:en i textfältet längst upp

3. **Välj vad du vill ladda ner**
   - **Video** - Laddar ner video med ljud (MP4)
   - **Ljud (MP3)** - Konverterar till MP3-fil
   - **Endast undertexter** - Laddar bara ner undertexter
   - **Endast beskrivning** - Laddar bara ner videobeskrivning

4. **Tryck "LADDA NER"**
   - Programmet visar progress i realtid
   - Fönstret kan flyttas medan nedladdning pågår

### Kvalitetsinställningar

Välj kvalitet från rullgardinsmenyn:
- **Bästa tillgängliga** (rekommenderas)
- **4K (2160p)**
- **1440p**
- **1080p**
- **720p**
- **480p**
- **360p**
- **240p**

**Tips:** Alla videor har inte 4K. Om du väljer 4K men videon bara finns i 1080p, laddas 1080p ner.

### Undertexter

1. **Kryssa i "Ladda ner undertexter"**

2. **Välj språk:**
   - Svenska
   - Engelska
   - Alla tillgängliga

3. **Bädda in i video (valfritt):**
   - Kryssa i "Bädda in undertexter i video"
   - Undertexter finns då direkt i MP4-filen
   - Aktiveras med 'V'-knappen i VLC eller andra spelare

4. **TXT-filer:**
   - Automatiskt skapas även `.txt`-filer med:
     - Videobeskrivning
     - Undertexter med tidsstämplar
     - Kommentarer (om du kryssat i det)

### Beskrivning och Kommentarer

- **Spara beskrivning i textfil**
  - Skapar `.description`-fil
  - Läggs också in i `.txt`-filen

- **Ladda ner kommentarer**
  - Laddar ner upp till 100 kommentarer
  - Sparas i `.info.json` och `.txt`-fil
  - Visar författare och antal likes

### Spellista-nedladdning

1. **Kopiera spellista-URL**
   - T.ex. `https://www.youtube.com/playlist?list=XXXXX`

2. **Ställ in "Max antal videos"**
   - Standard: 5
   - Öka till önskat antal (max 999)

3. **Klicka "LADDA NER"**
   - Alla videor i spellistan laddas ner
   - Status visas för varje video

**OBS:** Privata spellistor kan inte laddas ner!

---

## Filformat och Output

### Video-nedladdningar skapar:

- **`.mp4`** - Videofil
- **`.en.vtt`** - Undertexter (om valt)
- **`.description`** - Videobeskrivning (om valt)
- **`.info.json`** - Metadata och kommentarer (om valt)
- **`.en.vtt.txt`** - Läsbar textfil med beskrivning + undertexter + kommentarer

### Ljud-nedladdningar skapar:

- **`.mp3`** - Ljudfil (konverterad från bästa tillgängliga ljud)
- Samma textfiler som video (om valt)

### Filnamn-format:

```
Videotitel [VideoID].mp4
Videotitel [VideoID].en.vtt
Videotitel [VideoID].en.vtt.txt
```

---

## Inställningar och Konfiguration

### Ändra Nedladdningsmapp

1. **Via Windows Registry:**
   ```
   HKEY_CURRENT_USER\Software\YouTube Downloader\Settings\OutputDir
   ```

2. **Eller i kod:**
   - Öppna `scripts\YouTube_Downloader_GUI.ps1`
   - Ändra `$outputDir`-variabeln

### Uppdatera Programmet

#### Manuell uppdatering:

1. Ladda ner ny installer från releases
2. Kör installern
3. Installera över befintlig installation

#### Auto-uppdatering:

Öppna PowerShell och kör:
```powershell
cd "C:\Program Files\YouTube Downloader"
.\scripts\Check-Updates.ps1 -AutoInstall
```

### Uppdatera yt-dlp

YouTube ändrar ibland sina API:er. Uppdatera yt-dlp med:

```powershell
cd "C:\Program Files\YouTube Downloader"
.\yt-dlp.exe -U
```

---

## Felsökning

### "FEL uppstod!" med varningar

**Problem:** GUI visar fel men videor laddades ner ändå

**Lösning:** Detta är ofta bara varningar från YouTube (SABR streaming). Uppdatera yt-dlp:
```powershell
.\yt-dlp.exe -U
```

### "Access Denied" / "Åtkomst nekad"

**Problem:** OneDrive låser filer under synkronisering

**Lösning:**
1. Pausa OneDrive-synk tillfälligt
2. Eller ändra nedladdningsmapp till lokal disk (C:\Videos\YouTube)

### "Playlist does not exist"

**Problem:** Kan inte ladda ner spellista

**Möjliga orsaker:**
- Spellistan är privat
- Spellistan har raderats
- Fel URL

**Lösning:** Kontrollera att spellistan är offentlig och URL:en är korrekt

### Inga undertexter laddas ner

**Problem:** Inga .vtt-filer skapas

**Möjliga orsaker:**
- Videon har inga undertexter
- Du valde fel språk

**Lösning:**
- Välj "Alla tillgängliga" språk
- Kontrollera på YouTube om videon har undertexter

### GUI fryser / hänger sig

**Problem:** GUI uppdateras inte under nedladdning

**Lösning:** Detta ska vara fixat i senaste versionen. Om det fortfarande händer, uppdatera programmet.

### ffprobe-varning

**Problem:** "WARNING: Unable to extract metadata: ffprobe not found"

**Lösning:** Detta är inte kritiskt, men du kan ladda ner ffprobe.exe från:
- https://ffmpeg.org/download.html
- Placera `ffprobe.exe` i installationsmappen

---

## Vanliga Frågor (FAQ)

### Kan jag ladda ner hela kanaler?

Ja! Kopiera kanalens URL och öka "Max antal videos" till önskat antal.

### Fungerar det med andra video-siter?

Nej, för närvarande endast YouTube. yt-dlp stödjer fler siter, men GUI:n är optimerad för YouTube.

### Var sparas filerna?

Standard: `C:\Users\DITT NAMN\Documents\YouTube Downloads`

Du kan ändra detta i registry eller genom att installera om.

### Är det lagligt?

Du ansvarar själv för att följa YouTubes användarvillkor och upphovsrättslagstiftning. Ladda endast ner innehåll du har rätt att ladda ner.

### Kan jag pausa nedladdningar?

Nej, inte för närvarande. Du kan dock stänga programmet och köra nedladdningen igen senare (redan nedladdade filer hoppas över).

---

## Avancerade Funktioner

### Kommandorad

Du kan också köra GUI-scriptet direkt med PowerShell:

```powershell
powershell -File "C:\Program Files\YouTube Downloader\scripts\YouTube_Downloader_GUI.ps1"
```

### Anpassa GUI

Redigera `scripts\YouTube_Downloader_GUI.ps1` för att:
- Ändra fönsterstorlek
- Lägga till fler språk för undertexter
- Ändra standardvärden

---

## Support och Kontakt

- **GitHub Issues:** https://github.com/martensjacobjm/Youtube-downloader/issues
- **Dokumentation:** Se `README.md` i installationsmappen

---

## Licens

Se `LICENSE`-filen i installationsmappen.

---

**Version:** 1.0.0
**Uppdaterad:** 2025-01-23
