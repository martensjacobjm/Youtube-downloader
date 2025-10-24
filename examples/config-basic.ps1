#==============================================================================
# GRUNDLÄGGANDE KONFIGURATION
# Enklaste sättet att komma igång med YouTube-downloader
#==============================================================================

# SÖKVÄGAR - Byt till dina egna mappar
$baseDir = "C:\Youtube"                    # Huvudmapp
$filmFolder = Join-Path $baseDir "Videos"  # Videomapp
$subsDir = Join-Path $baseDir "Subtitles"  # Undertextmapp
$yt = Join-Path $baseDir "yt-dlp.exe"      # Sökväg till yt-dlp
$ffmpeg = Join-Path $baseDir "ffmpeg.exe"  # Sökväg till ffmpeg

# URL - Lämna tom för att bli tillfrågad, eller fyll i direkt
$videoUrl = ""

# VAD SKA LADDAS NER?
$downloadVideo = $true   # Ladda ner video
$downloadSubs = $true    # Ladda ner undertexter

# KLAR! Kopiera dessa variabler till huvudscriptet och kör.
