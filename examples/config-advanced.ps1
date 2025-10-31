#==============================================================================
# AVANCERAD KONFIGURATION
# Alla tillgängliga alternativ för maximal kontroll
#==============================================================================

# SÖKVÄGAR
$baseDir = "C:\Youtube"
$filmFolder = Join-Path $baseDir "Videos"
$subsDir = Join-Path $baseDir "Subtitles"
$yt = Join-Path $baseDir "yt-dlp.exe"
$ffmpeg = Join-Path $baseDir "ffmpeg.exe"

# URL
$videoUrl = ""

# NEDLADDNINGSVAL
$downloadVideo = $true
$downloadSubs = $true

#==============================================================================
# SPELLISTA-ALTERNATIV
#==============================================================================

# Begränsa antal nedladdningar
$maxDownloads = 10              # Ladda bara ner X videos

# Välj intervall i spellistan
$playlistStart = 5              # Börja från video nummer X
$playlistEnd = 15               # Sluta vid video nummer X

# Progress-tracking
$downloadArchive = "downloaded.txt"  # Fil för att spara nedladdningshistorik
                                     # Scriptet skippar videos som finns i denna fil

# Ordning
$playlistReverse = $true        # true = börja från slutet av spellistan
                                # false/kommenterad = normal ordning

#==============================================================================
# RATE-LIMITING & PRESTANDA
#==============================================================================

# Delay mellan subtitle-requests (viktigt för spellistor!)
$sleepSubtitles = 10            # Sekunder mellan varje subtitle-request
                                # Standard: 4s (enskilda videos)
                                # Rekommenderat för spellistor: 8-15s
                                # Öka om du får HTTP 429 (Too Many Requests)

#==============================================================================
# FELHANTERING
#==============================================================================

# Fortsätt vid fel
$ignoreErrors = $true           # true = fortsätt med nästa video om en failar
                                # false = avbryt hela nedladdningen vid fel

#==============================================================================
# EXEMPEL-SCENARIOS
#==============================================================================

# SCENARIO 1: Ladda ner hela spellistan (säkert och pålitligt)
# $videoUrl = "https://www.youtube.com/playlist?list=PLxxxxxx"
# $downloadArchive = "downloaded.txt"
# $sleepSubtitles = 10
# $ignoreErrors = $true
# Kör scriptet flera gånger tills allt är nedladdat

# SCENARIO 2: Ladda ner första 50 videos från en spellista
# $videoUrl = "https://www.youtube.com/playlist?list=PLxxxxxx"
# $maxDownloads = 50
# $sleepSubtitles = 10

# SCENARIO 3: Ladda ner bara undertexter för en spellista
# $downloadVideo = $false
# $downloadSubs = $true
# $videoUrl = "https://www.youtube.com/playlist?list=PLxxxxxx"
# $sleepSubtitles = 8

# SCENARIO 4: Ladda ner videos 20-40 från en spellista
# $playlistStart = 20
# $playlistEnd = 40
# $videoUrl = "https://www.youtube.com/playlist?list=PLxxxxxx"

# SCENARIO 5: Ladda ner en spellista i omvänd ordning
# $playlistReverse = $true
# $videoUrl = "https://www.youtube.com/playlist?list=PLxxxxxx"
# $downloadArchive = "downloaded.txt"

#==============================================================================
# VANLIGA PROBLEM & LÖSNINGAR
#==============================================================================

# PROBLEM: HTTP 429 (Too Many Requests)
# LÖSNING: Öka $sleepSubtitles till 15-20

# PROBLEM: Vissa videos failar
# LÖSNING: Aktivera $ignoreErrors = $true

# PROBLEM: Stora spellistor tar för lång tid
# LÖSNING: Använd $maxDownloads och $downloadArchive
#          Kör scriptet flera gånger

# PROBLEM: Vill fortsätta en avbruten nedladdning
# LÖSNING: Använd $downloadArchive - scriptet skippar automatiskt
#          redan nedladdade videos
