#==============================================================================
# SPELLISTA-KONFIGURATION
# Optimerad för nedladdning av YouTube-spellistor
#==============================================================================

# SÖKVÄGAR
$baseDir = "C:\Youtube"
$filmFolder = Join-Path $baseDir "Videos"
$subsDir = Join-Path $baseDir "Subtitles"
$yt = Join-Path $baseDir "yt-dlp.exe"
$ffmpeg = Join-Path $baseDir "ffmpeg.exe"

# SPELLISTA-URL
# Exempel: https://www.youtube.com/playlist?list=PLrAXtmErZgOeiKm4sgNOknGvNjby9efdf
$videoUrl = ""

# NEDLADDNINGSVAL
$downloadVideo = $true
$downloadSubs = $true

#==============================================================================
# SPELLISTA-ALTERNATIV
#==============================================================================

# Begränsa antal videos (rekommenderas för stora spellistor)
$maxDownloads = 20              # Ladda bara ner 20 videos

# Välj intervall (valfritt)
#$playlistStart = 1             # Börja från video 1
#$playlistEnd = 50              # Sluta vid video 50

# Spara progress - VIKTIGT för stora spellistor!
$downloadArchive = "downloaded.txt"  # Skippa redan nedladdade videos

# Omvänd ordning (valfritt)
#$playlistReverse = $true       # Börja från sista videon

# RATE-LIMITING - Viktigt för spellistor!
$sleepSubtitles = 10            # 10 sekunder mellan subtitle-requests
                                # Öka till 15 om du får HTTP 429-fel

# Fortsätt vid fel
$ignoreErrors = $true           # Skippa videos som inte går att ladda ner

#==============================================================================
# TIPS FÖR STORA SPELLISTOR
#==============================================================================
# 1. Använd alltid $downloadArchive för att kunna fortsätta senare
# 2. Börja med ett litet $maxDownloads-värde för att testa
# 3. Öka $sleepSubtitles om du får rate-limiting-fel
# 4. Kör scriptet flera gånger - det fortsätter automatiskt där det slutade
