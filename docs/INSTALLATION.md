# Installationsguide

Denna guide visar steg för steg hur du installerar och konfigurerar YouTube Downloader.

## Innehåll
- [Systemkrav](#systemkrav)
- [Installation av beroenden](#installation-av-beroenden)
- [Konfigurera scriptet](#konfigurera-scriptet)
- [Testa installationen](#testa-installationen)

## Systemkrav

- **Operativsystem:** Windows 10/11 (eller Windows Server 2016+)
- **PowerShell:** Version 5.1 eller senare
- **Diskutrymme:** Minst 1 GB ledigt utrymme (mer för videor)
- **Internetanslutning:** Krävs för nedladdningar

### Kontrollera PowerShell-version

Öppna PowerShell och kör:

```powershell
$PSVersionTable.PSVersion
```

Du bör se version 5.1 eller högre.

## Installation av beroenden

### Metod 1: Automatisk installation med winget (Rekommenderas)

Windows 10/11 har winget förinstallerat. Öppna PowerShell som administratör och kör:

```powershell
# Installera yt-dlp
winget install yt-dlp

# Installera ffmpeg
winget install ffmpeg
```

### Metod 2: Manuell installation

#### yt-dlp

1. Gå till https://github.com/yt-dlp/yt-dlp/releases
2. Ladda ner `yt-dlp.exe` (senaste versionen)
3. Spara filen i din basemapp (t.ex. `C:\Youtube\yt-dlp.exe`)

#### ffmpeg

1. Gå till https://ffmpeg.org/download.html
2. Välj "Windows builds" → "gyan.dev"
3. Ladda ner "ffmpeg-release-essentials.zip"
4. Packa upp ZIP-filen
5. Kopiera `ffmpeg.exe` från `bin`-mappen till din basemapp

### Verifiera installationen

Öppna PowerShell och kör:

```powershell
# Kontrollera yt-dlp
yt-dlp --version

# Kontrollera ffmpeg
ffmpeg -version
```

Om kommandona inte fungerar, se [Felsökning](#felsökning).

## Konfigurera scriptet

### 1. Klona eller ladda ner projektet

```powershell
# Med git
git clone https://github.com/DittAnvändarnamn/Youtube-downloader.git
cd Youtube-downloader

# Eller ladda ner ZIP från GitHub och packa upp
```

### 2. Skapa din arbetsmapp

Skapa en mapp där dina nedladdningar ska sparas:

```powershell
mkdir C:\Youtube
mkdir C:\Youtube\Videos
mkdir C:\Youtube\Subtitles
```

### 3. Redigera scriptkonfigurationen

Öppna `scripts/youtube-downloader.ps1` i en textredigerare och ändra följande rader:

```powershell
# Hitta dessa rader i början av filen:
$baseDir = "C:\Users\JMS\OneDrive - Dala VS Värme & Sanitet\Privat\Youtube download"

# Ändra till din egen mapp:
$baseDir = "C:\Youtube"
```

### 4. Uppdatera sökvägar till verktyg

Om du installerade med winget behöver du förmodligen inte göra något.

Om du installerade manuellt, se till att sökvägarna är korrekta:

```powershell
$yt = Join-Path $baseDir "yt-dlp.exe"      # Byt till full sökväg om nödvändigt
$ffmpeg = Join-Path $baseDir "ffmpeg.exe"  # Byt till full sökväg om nödvändigt
```

Exempel om verktygen är i din PATH:

```powershell
$yt = "yt-dlp"      # Om yt-dlp är i PATH
$ffmpeg = "ffmpeg"  # Om ffmpeg är i PATH
```

## Testa installationen

Kör ett enkelt test för att verifiera att allt fungerar:

```powershell
cd Youtube-downloader
.\scripts\youtube-downloader.ps1
```

När scriptet frågar efter URL, testa med en kort video:

```
https://www.youtube.com/watch?v=jNQXAC9IVRw
```

(Detta är "Me at the zoo", den första videon som laddades upp på YouTube)

Om allt fungerar ska du se:
- Progress-information i terminalen
- Video nedladdad till din `Videos`-mapp
- Undertexter nedladdade till din `Subtitles`-mapp

## Felsökning

### "yt-dlp.exe saknas"

**Problem:** Scriptet hittar inte yt-dlp.

**Lösning:**
1. Kontrollera att yt-dlp är installerat: `yt-dlp --version`
2. Om kommandot fungerar, ändra i scriptet:
   ```powershell
   $yt = "yt-dlp"  # Använd kommando istället för sökväg
   ```
3. Om kommandot inte fungerar, installera om yt-dlp

### "ffmpeg.exe saknas"

**Problem:** Scriptet hittar inte ffmpeg.

**Lösning:**
1. Kontrollera att ffmpeg är installerat: `ffmpeg -version`
2. Om kommandot fungerar, ändra i scriptet:
   ```powershell
   $ffmpeg = "ffmpeg"  # Använd kommando istället för sökväg
   ```
3. Om kommandot inte fungerar, installera om ffmpeg

### "Skript körning är inaktiverat på det här systemet"

**Problem:** PowerShell Execution Policy blockerar scriptet.

**Lösning:**

Öppna PowerShell som administratör och kör:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Bekräfta med `Y` (Yes).

Detta tillåter signerade scripts och lokala scripts att köras.

### HTTP 429 (Too Many Requests)

**Problem:** YouTube begränsar din åtkomst.

**Lösning:**
- Öka `$sleepSubtitles` i scriptet till 10-15 sekunder
- Vänta några minuter innan du försöker igen
- Använd `$maxDownloads` för att begränsa antalet nedladdningar

### Video laddas ner men inte undertexter

**Problem:** Vissa videos har inga undertexter tillgängliga.

**Lösning:**
- Detta är normalt - inte alla videos har undertexter
- Scriptet kommer visa en varning men fortsätta
- Använd `$ignoreErrors = $true` för att automatiskt fortsätta

## Nästa steg

- Läs [CONFIGURATION.md](CONFIGURATION.md) för detaljerade konfigurationsalternativ
- Se [exempel-konfigurationerna](../examples/) för vanliga användningsfall
- Läs [TROUBLESHOOTING.md](TROUBLESHOOTING.md) för mer felsökning

## Behöver du hjälp?

Skapa en issue på GitHub med:
- Din Windows-version
- PowerShell-version
- Felmeddelande (om något)
- Vad du försökte göra
