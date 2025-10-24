# Felsökningsguide

Denna guide hjälper dig att lösa vanliga problem med YouTube Downloader.

## Innehåll
- [Vanliga felmeddelanden](#vanliga-felmeddelanden)
- [Nedladdningsproblem](#nedladdningsproblem)
- [Undertextproblem](#undertextproblem)
- [Spellistproblem](#spellistproblem)
- [Prestanda och optimering](#prestanda-och-optimering)
- [Felsökningsverktyg](#felsökningsverktyg)

## Vanliga felmeddelanden

### "FATAL: yt-dlp.exe saknas"

**Symptom:**
```
Write-Error "FATAL: yt-dlp.exe saknas i C:\Youtube"
```

**Orsak:**
Scriptet hittar inte yt-dlp på den angivna platsen.

**Lösningar:**

1. **Kontrollera om yt-dlp är installerat:**
   ```powershell
   yt-dlp --version
   ```

2. **Om kommandot fungerar:** Ändra scriptet till att använda kommandot direkt:
   ```powershell
   $yt = "yt-dlp"  # Istället för full sökväg
   ```

3. **Om kommandot inte fungerar:** Installera yt-dlp:
   ```powershell
   winget install yt-dlp
   ```

4. **Verifiera sökväg:** Om du har lagt yt-dlp.exe i en specifik mapp:
   ```powershell
   # Kontrollera att filen finns
   Test-Path "C:\Youtube\yt-dlp.exe"  # Ska returnera True
   ```

### "Skript körning är inaktiverat på det här systemet"

**Symptom:**
```
.\youtube-downloader.ps1 : File ... cannot be loaded because running scripts
is disabled on this system.
```

**Orsak:**
PowerShell Execution Policy blockerar scriptkörning.

**Lösning:**

Öppna PowerShell som **administratör** och kör:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Bekräfta med `Y`.

**Förklaring:**
- `RemoteSigned`: Tillåter lokala scripts, kräver signatur för nedladdade
- `CurrentUser`: Påverkar bara din användare, inte hela systemet

**Alternativ (tillfällig lösning):**
```powershell
PowerShell -ExecutionPolicy Bypass -File .\scripts\youtube-downloader.ps1
```

### "HTTP Error 429: Too Many Requests"

**Symptom:**
```
WARNING: yt-dlp exit code: 1 (kan vara HTTP 429)
```

**Orsak:**
YouTube rate-limiterar dina requests (för många förfrågningar på kort tid).

**Lösningar:**

1. **Öka sleep-delay:**
   ```powershell
   $sleepSubtitles = 15  # Eller högre
   ```

2. **Vänta och försök igen:**
   - Vänta 5-10 minuter
   - Kör scriptet igen

3. **Använd download archive:**
   ```powershell
   $downloadArchive = "downloaded.txt"
   ```
   Scriptet fortsätter där det slutade.

4. **Begränsa nedladdningar:**
   ```powershell
   $maxDownloads = 10  # Gör mindre batcher
   ```

**Förebyggande:**
- Börja alltid med `$sleepSubtitles = 10` för spellistor
- Använd `$ignoreErrors = $true` för att fortsätta vid fel

### "Inga VTT-filer skapades"

**Symptom:**
```
Write-Error "FATAL: Inga VTT-filer skapades"
```

**Orsak:**
Videon har inga undertexter tillgängliga.

**Lösningar:**

1. **Kontrollera manuellt:**
   - Gå till videon på YouTube
   - Klicka på inställningar (kugghjul)
   - Kolla om "Undertexter" finns

2. **Om videon har undertexter:**
   Kör yt-dlp manuellt för debug:
   ```powershell
   yt-dlp --list-subs "https://www.youtube.com/watch?v=xxxxx"
   ```

3. **Om ingen har undertexter:**
   Detta är normalt. Sätt:
   ```powershell
   $ignoreErrors = $true
   ```

4. **Skippa undertexter för denna video:**
   ```powershell
   $downloadSubs = $false
   ```

## Nedladdningsproblem

### Video laddas ner i fel kvalitet

**Problem:** Video är lågupplöst eller fel format.

**Lösning:**

1. **Kontrollera tillgängliga format:**
   ```powershell
   yt-dlp -F "https://www.youtube.com/watch?v=xxxxx"
   ```

2. **Välj specifikt format:**
   Redigera scriptet och ändra format-strängen:
   ```powershell
   # Nuvarande:
   -f "bv*+ba/best"

   # För högre kvalitet (kan ge stora filer):
   -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best"

   # För 1080p max:
   -f "bestvideo[height<=1080][ext=mp4]+bestaudio[ext=m4a]"
   ```

### Nedladdning hänger sig / tar för lång tid

**Problem:** Scriptet verkar fastna.

**Troubleshooting:**

1. **Kontrollera nätverket:**
   ```powershell
   Test-Connection youtube.com -Count 4
   ```

2. **Kör yt-dlp manuellt med verbose:**
   ```powershell
   yt-dlp -v "https://www.youtube.com/watch?v=xxxxx"
   ```

3. **Kontrollera diskutrymme:**
   ```powershell
   Get-PSDrive C | Select-Object Used,Free
   ```

4. **Timeout-problem:**
   Om du har långsam anslutning, lägg till i yt-dlp-kommandot:
   ```powershell
   --socket-timeout 30
   ```

### Videor hamnar i fel mapp

**Problem:** Filer sparas inte där du förväntar dig.

**Lösning:**

1. **Kontrollera variabler:**
   ```powershell
   Write-Host "Videos sparas i: $filmFolder"
   Write-Host "Undertexter sparas i: $subsDir"
   ```

2. **Skapa mappar manuellt:**
   ```powershell
   New-Item -ItemType Directory -Force -Path "C:\Youtube\Videos"
   New-Item -ItemType Directory -Force -Path "C:\Youtube\Subtitles"
   ```

3. **Använd absoluta sökvägar:**
   ```powershell
   $filmFolder = "C:\Youtube\Videos"  # Istället för Join-Path
   ```

## Undertextproblem

### VTT konverteras inte till SRT

**Problem:** Bara .vtt-filer skapas, ingen .srt.

**Diagnos:**

1. **Kontrollera ffmpeg:**
   ```powershell
   ffmpeg -version
   ```

2. **Om ffmpeg saknas:**
   ```powershell
   winget install ffmpeg
   ```

3. **Om ffmpeg finns:**
   Scriptet har en fallback-metod. Kolla efter varningar i output.

**Manuell konvertering:**

Om allt annat failar, konvertera manuellt:

```powershell
# Konvertera en fil
ffmpeg -i input.vtt output.srt

# Konvertera alla VTT-filer
Get-ChildItem -Filter "*.vtt" | ForEach-Object {
    $srt = $_.FullName -replace '\.vtt$', '.srt'
    ffmpeg -y -i $_.FullName $srt
}
```

### TXT-filer saknar beskrivning

**Problem:** .vtt.txt-filer har undertexter men ingen videobeskrivning.

**Orsak:**
Videon har ingen beskrivning, eller description-filen laddades inte ner.

**Lösning:**

1. **Kontrollera om description-fil finns:**
   ```powershell
   Get-ChildItem -Path $subsDir -Filter "*.description"
   ```

2. **Om den saknas:**
   Lägg till explicit i yt-dlp-kommandot:
   ```powershell
   --write-description
   ```
   (Detta finns redan i scriptet, men dubbelkolla)

### Undertexter har fel språk

**Problem:** Får undertexter på fel språk.

**Lösning:**

Ändra språkinställningen i scriptet:

```powershell
# Nuvarande (engelska och svenska):
--sub-langs "en.*,sv.*"

# Bara svenska:
--sub-langs "sv.*"

# Bara engelska:
--sub-langs "en.*"

# Svenska, engelska, spanska:
--sub-langs "sv.*,en.*,es.*"

# Alla språk:
--sub-langs "all"
```

## Spellistproblem

### Bara första videon laddas ner från spellista

**Problem:** Trots spellista-URL laddas bara en video ner.

**Diagnos:**

1. **Kontrollera URL:**
   ```powershell
   # Korrekt spellista-URL måste innehålla "list=":
   https://www.youtube.com/playlist?list=PLxxxxxx

   # INTE:
   https://www.youtube.com/watch?v=xxxxx  # Detta är en enskild video
   ```

2. **Kontrollera yt-dlp-version:**
   ```powershell
   yt-dlp --version
   ```
   Uppdatera om det är en gammal version:
   ```powershell
   yt-dlp -U
   ```

### Vissa videos i spellistan hoppas över

**Problem:** Inte alla videos laddas ner.

**Möjliga orsaker:**

1. **Private/unlisted videos:** YouTube skippar dessa automatiskt
2. **Geo-blocked:** Videos inte tillgängliga i ditt land
3. **Age-restricted:** Kräver inloggning
4. **Deleted videos:** Finns kvar i spellistan men raderade

**Lösning:**

Använd `$ignoreErrors = $true` för att fortsätta trots fel:

```powershell
$ignoreErrors = $true
```

**Se vilka som skippades:**

Kör yt-dlp manuellt med verbose:

```powershell
yt-dlp -v --ignore-errors "https://www.youtube.com/playlist?list=PLxxxxxx"
```

### Spellista-nedladdning avbryts

**Problem:** Scriptet stoppar mitt i en spellista.

**Lösningar:**

1. **Använd download archive:**
   ```powershell
   $downloadArchive = "playlist-archive.txt"
   ```

2. **Öka rate-limiting:**
   ```powershell
   $sleepSubtitles = 15
   ```

3. **Begränsa batch-storlek:**
   ```powershell
   $maxDownloads = 20
   ```

4. **Fortsätt från specifik video:**
   ```powershell
   $playlistStart = 25  # Om du kom till video 24
   ```

## Prestanda och optimering

### Nedladdning går för långsamt

**Optimeringar:**

1. **Skippa undertexter temporärt:**
   ```powershell
   $downloadSubs = $false  # Ladda bara video
   ```

2. **Begränsa kvalitet:**
   ```powershell
   -f "bestvideo[height<=720]+bestaudio/best[height<=720]"
   ```

3. **Kontrollera internethasighet:**
   ```powershell
   # Windows 10+:
   speedtest-cli  # Om installerat
   ```

### Tar för mycket diskutrymme

**Lösningar:**

1. **Ladda bara undertexter:**
   ```powershell
   $downloadVideo = $false
   $downloadSubs = $true
   ```

2. **Begränsa kvalitet:**
   ```powershell
   # 720p max istället för 1080p/4K:
   -f "bestvideo[height<=720]+bestaudio"
   ```

3. **Rensa gamla VTT-filer:**
   VTT behövs inte efter SRT/TXT-konvertering:
   ```powershell
   Get-ChildItem -Path $subsDir -Filter "*.vtt" | Remove-Item
   ```

## Felsökningsverktyg

### Debug-läge för yt-dlp

Kör yt-dlp manuellt med verbose output:

```powershell
yt-dlp -v "URL"
```

### Lista tillgängliga format

```powershell
yt-dlp -F "URL"
```

### Lista tillgängliga undertexter

```powershell
yt-dlp --list-subs "URL"
```

### Simulera nedladdning (dry-run)

Se vad som skulle laddas ner utan att faktiskt ladda ner:

```powershell
yt-dlp --simulate "URL"
```

### Kontrollera scriptvärden

Lägg till debug-output i scriptet:

```powershell
Write-Host "=== DEBUG INFO ===" -ForegroundColor Yellow
Write-Host "baseDir: $baseDir"
Write-Host "filmFolder: $filmFolder"
Write-Host "subsDir: $subsDir"
Write-Host "yt: $yt"
Write-Host "ffmpeg: $ffmpeg"
Write-Host "videoUrl: $videoUrl"
Write-Host "==================" -ForegroundColor Yellow
```

## Fortfarande problem?

### Skapa en detaljerad felrapport

Om du behöver hjälp, samla följande information:

1. **Systeminformation:**
   ```powershell
   $PSVersionTable
   Get-ComputerInfo | Select-Object WindowsVersion, OsArchitecture
   ```

2. **Verktygsversioner:**
   ```powershell
   yt-dlp --version
   ffmpeg -version
   ```

3. **Felmeddelande:**
   - Kopiera hela felmeddelandet
   - Inkludera vad du försökte göra

4. **Scriptkonfiguration:**
   - Vilka variabler har du ändrat?
   - URL (om det inte är känslig info)

### Rapportera problem

Skapa en GitHub issue med ovanstående information:
- Tydlig beskrivning av problemet
- Steg för att återskapa felet
- Förväntad vs faktisk output
- Systeminformation

## Relaterade guider

- [INSTALLATION.md](INSTALLATION.md) - Om du har installationsproblem
- [CONFIGURATION.md](CONFIGURATION.md) - För konfigurationshjälp
- [README.md](../README.md) - Allmän översikt
