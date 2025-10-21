###############################################################################
# YouTube Video & Subtitle Downloader - v7 PLAYLIST
#
# Funktioner:
# - Ladda ner video (MP4 med H.264 + AAC)
# - Ladda ner undertexter (VTT, SRT, TXT)
# - Stöd för spellistor
# - Eller båda samtidigt
###############################################################################

#==============================================================================
# KONFIG - SÖKVÄGAR
#==============================================================================
$baseDir = "C:\Users\JMS\OneDrive - Dala VS Värme & Sanitet\Privat\Youtube download"
$filmFolder = Join-Path $baseDir "Filmer"
$subsDir = Join-Path $baseDir "Undertextfiler"
$yt = Join-Path $baseDir "yt-dlp.exe"
$ffmpeg = Join-Path $baseDir "ffmpeg.exe"

#==============================================================================
# KONFIG - URL (kan sättas här ELLER via prompt när scriptet körs)
#==============================================================================
# EXEMPEL:
# Enskild video: "https://www.youtube.com/watch?v=aMYyBsjhBR4"
# Spellista:     "https://www.youtube.com/playlist?list=PLxxxxxx"

# Lämna tom för att bli tillfrågad vid körning:
$videoUrl = ""

# Eller sätt direkt här (skippar då prompten):
#$videoUrl = "https://www.youtube.com/watch?v=aMYyBsjhBR4"

#==============================================================================
# KONFIG - NEDLADDNINGSVAL
#==============================================================================
$downloadVideo = $true      # true = ladda ner video
$downloadSubs = $true       # true = ladda ner undertexter

#==============================================================================
# KONFIG - AVANCERADE ALTERNATIV (aktivera genom att ta bort #)
#==============================================================================

# --- SPELLISTA-ALTERNATIV ---
# Begränsa antal videos som laddas ner
#$maxDownloads = 10          # Ladda bara ner första 10 videos

# Välj intervall i spellistan
#$playlistStart = 5          # Börja från video 5
#$playlistEnd = 15           # Sluta vid video 15

# Spara progress (för att fortsätta senare)
#$downloadArchive = "downloaded.txt"  # Skippa redan nedladdade videos

# Omvänd ordning (börja från slutet)
#$playlistReverse = $true    # true = börja från sista videon

# --- RATE LIMITING ---
# För spellistor: öka delay mellan undertexter (standard: 4s)
$sleepSubtitles = 4         # Sekunder mellan subtitle-requests
                            # För spellistor: öka till 8-10s

# --- ÖVRIGA ALTERNATIV ---
# Fortsätt även om en video failar
#$ignoreErrors = $true       # true = fortsätt med nästa video vid fel

#==============================================================================
# START
#==============================================================================

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "YouTube Downloader v7.0 - PLAYLIST" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# === INTERAKTIV URL-PROMPT ===
if (-not $videoUrl -or $videoUrl.Trim() -eq "") {
    Write-Host "📺 Ange YouTube-URL (video eller spellista):" -ForegroundColor Yellow
    Write-Host "   Exempel video: https://www.youtube.com/watch?v=xxxxx" -ForegroundColor Gray
    Write-Host "   Exempel spellista: https://www.youtube.com/playlist?list=PLxxxxx" -ForegroundColor Gray
    Write-Host ""

    do {
        $videoUrl = Read-Host "URL"

        if (-not $videoUrl -or $videoUrl.Trim() -eq "") {
            Write-Host "⚠️  URL kan inte vara tom. Försök igen." -ForegroundColor Red
        }
    } while (-not $videoUrl -or $videoUrl.Trim() -eq "")

    Write-Host ""
}

# === VALIDATION ===
if (-not (Test-Path $yt)) {
    Write-Error "FATAL: yt-dlp.exe saknas i $baseDir"
    throw "STOPPAR - yt-dlp.exe saknas"
}

# Skapa målmappar
New-Item -ItemType Directory -Force -Path $filmFolder | Out-Null
New-Item -ItemType Directory -Force -Path $subsDir | Out-Null

# === DETEKTERA SPELLISTA ===
$isPlaylist = $videoUrl -match 'playlist\?list=' -or $videoUrl -match '&list='

if ($isPlaylist) {
    Write-Host "📋 SPELLISTA detekterad!" -ForegroundColor Magenta

    # Justera rate-limiting för spellistor om inte manuellt satt
    if (-not (Get-Variable -Name sleepSubtitles -ValueOnly -ErrorAction SilentlyContinue)) {
        $sleepSubtitles = 8
        Write-Host "  ⚠️  Auto-ökar sleep-subtitles till 8s (spellista)" -ForegroundColor Yellow
    }
} else {
    Write-Host "📺 Enskild video detekterad" -ForegroundColor Cyan
}

Write-Host "  Video: $(if($downloadVideo){'JA'}else{'NEJ'})" -ForegroundColor $(if($downloadVideo){'Green'}else{'Gray'})
Write-Host "  Undertexter: $(if($downloadSubs){'JA'}else{'NEJ'})" -ForegroundColor $(if($downloadSubs){'Green'}else{'Gray'})

###############################################################################
# DEL 1: LADDA NER VIDEO
###############################################################################

if ($downloadVideo) {
    Write-Host "`n==> LADDAR NER VIDEO$(if($isPlaylist){' (SPELLISTA)'}else{''})..." -ForegroundColor Yellow
    Write-Host "Mål: $filmFolder" -ForegroundColor Gray

    # Bygg kommando dynamiskt
    $ytArgs = @(
        "--ffmpeg-location", $baseDir,
        "-S", "ext:mp4:m4a,vcodec:h264,acodec:aac",
        "-f", "bv*+ba/best",
        "--merge-output-format", "mp4",
        "--embed-metadata",
        "--remux-video", "mp4",
        "-o", "$filmFolder\%(title)s [%(id)s].%(ext)s",
        $videoUrl
    )

    # Lägg till avancerade alternativ om aktiva
    if (Get-Variable -Name maxDownloads -ValueOnly -ErrorAction SilentlyContinue) {
        $ytArgs += "--max-downloads"
        $ytArgs += $maxDownloads
        Write-Host "  📌 Begränsar till $maxDownloads videos" -ForegroundColor Cyan
    }

    if (Get-Variable -Name playlistStart -ValueOnly -ErrorAction SilentlyContinue) {
        $ytArgs += "--playlist-start"
        $ytArgs += $playlistStart
        Write-Host "  📌 Börjar från video $playlistStart" -ForegroundColor Cyan
    }

    if (Get-Variable -Name playlistEnd -ValueOnly -ErrorAction SilentlyContinue) {
        $ytArgs += "--playlist-end"
        $ytArgs += $playlistEnd
        Write-Host "  📌 Slutar vid video $playlistEnd" -ForegroundColor Cyan
    }

    if (Get-Variable -Name downloadArchive -ValueOnly -ErrorAction SilentlyContinue) {
        $ytArgs += "--download-archive"
        $ytArgs += $downloadArchive
        Write-Host "  📌 Progress sparas i: $downloadArchive" -ForegroundColor Cyan
    }

    if (Get-Variable -Name playlistReverse -ValueOnly -ErrorAction SilentlyContinue) {
        if ($playlistReverse) {
            $ytArgs += "--playlist-reverse"
            Write-Host "  📌 Omvänd ordning (från slutet)" -ForegroundColor Cyan
        }
    }

    if (Get-Variable -Name ignoreErrors -ValueOnly -ErrorAction SilentlyContinue) {
        if ($ignoreErrors) {
            $ytArgs += "--ignore-errors"
            Write-Host "  📌 Fortsätter vid fel" -ForegroundColor Cyan
        }
    }

    # Kör nedladdning
    & $yt @ytArgs

    if ($LASTEXITCODE -eq 0) {
        $videoFiles = Get-ChildItem -Path $filmFolder -Filter "*.mp4"
        Write-Host "✓ Video(r) nedladdade: $($videoFiles.Count) filer" -ForegroundColor Green

        $totalSize = ($videoFiles | Measure-Object -Property Length -Sum).Sum
        Write-Host "  Total storlek: $([math]::Round($totalSize/1MB, 2)) MB" -ForegroundColor Gray
    } else {
        Write-Warning "Video-nedladdning returnerade exit code: $LASTEXITCODE"
        if (-not $downloadSubs) {
            throw "STOPPAR - video-nedladdning failade"
        }
    }
}

###############################################################################
# DEL 2: LADDA NER UNDERTEXTER
###############################################################################

if ($downloadSubs) {
    Write-Host "`n==> LADDAR NER UNDERTEXTER$(if($isPlaylist){' (SPELLISTA)'}else{''})..." -ForegroundColor Yellow
    Write-Host "Mål: $subsDir" -ForegroundColor Gray

    if ($isPlaylist) {
        Write-Host "⚠️  VARNING: Spellistor = hårdare rate-limiting!" -ForegroundColor Yellow
        Write-Host "   Sleep-delay: $sleepSubtitles sekunder" -ForegroundColor Gray
    }

    Push-Location $subsDir

    # Bygg kommando dynamiskt
    $ytSubsArgs = @(
        "--ffmpeg-location", $baseDir,
        "--skip-download",
        "--write-sub", "--write-auto-sub",
        "--sub-langs", "en.*,sv.*",
        "--sub-format", "vtt",
        "--write-description",
        "--sleep-subtitles", $sleepSubtitles,
        "-o", "%(title)s [%(id)s].%(ext)s",
        $videoUrl
    )

    # Lägg till spellista-alternativ om aktiva
    if (Get-Variable -Name maxDownloads -ValueOnly -ErrorAction SilentlyContinue) {
        $ytSubsArgs += "--max-downloads"
        $ytSubsArgs += $maxDownloads
    }

    if (Get-Variable -Name playlistStart -ValueOnly -ErrorAction SilentlyContinue) {
        $ytSubsArgs += "--playlist-start"
        $ytSubsArgs += $playlistStart
    }

    if (Get-Variable -Name playlistEnd -ValueOnly -ErrorAction SilentlyContinue) {
        $ytSubsArgs += "--playlist-end"
        $ytSubsArgs += $playlistEnd
    }

    if (Get-Variable -Name downloadArchive -ValueOnly -ErrorAction SilentlyContinue) {
        $ytSubsArgs += "--download-archive"
        $ytSubsArgs += $downloadArchive
    }

    if (Get-Variable -Name playlistReverse -ValueOnly -ErrorAction SilentlyContinue) {
        if ($playlistReverse) {
            $ytSubsArgs += "--playlist-reverse"
        }
    }

    if (Get-Variable -Name ignoreErrors -ValueOnly -ErrorAction SilentlyContinue) {
        if ($ignoreErrors) {
            $ytSubsArgs += "--ignore-errors"
        }
    }

    # Kör nedladdning
    & $yt @ytSubsArgs

    if ($LASTEXITCODE -ne 0) {
        Write-Warning "yt-dlp exit code: $LASTEXITCODE (kan vara HTTP 429)"
    }

    # Verifiera VTT
    $vttFiles = @(Get-ChildItem -Path $subsDir -Filter "*.vtt" -File)

    if ($vttFiles.Count -eq 0) {
        Write-Error "FATAL: Inga VTT-filer skapades"
        Pop-Location
        throw "STOPPAR - inga undertexter"
    }

    Write-Host "✓ Hittade $($vttFiles.Count) VTT-fil(er)" -ForegroundColor Green

    # === KONVERTERA VTT → SRT ===
    Write-Host "`n==> Konverterar VTT → SRT..." -ForegroundColor Yellow

    foreach ($vtt in $vttFiles) {
        $srt = [IO.Path]::ChangeExtension($vtt.FullName, ".srt")

        # Skippa om redan finns
        if ((Test-Path $srt) -and (Get-Item $srt).Length -gt 0) {
            Write-Host "  ⏭️  $($vtt.Name) → SRT (finns redan)" -ForegroundColor Gray
            continue
        }

        # Försök ffmpeg
        if (Test-Path $ffmpeg) {
            & $ffmpeg -y -loglevel error -i $vtt.FullName -f srt $srt

            if ((Test-Path $srt) -and (Get-Item $srt).Length -gt 0) {
                Write-Host "  ✓ $($vtt.Name) → SRT" -ForegroundColor Green
                continue
            }
        }

        # Fallback: manuell konvertering
        try {
            $content = (Get-Content $vtt.FullName -Encoding UTF8) -join "`n"
            $content = $content -replace "WEBVTT.*?`n", ""
            $content = $content -replace "(?m)^\s*NOTE.*?`n`n", ""
            $content = $content -replace "(?m)\s*(align|position|line|size):[^\n]+", ""

            $blocks = ($content -replace "(?m)^\s*$", "`n") -split "`n`n"
            $sb = New-Object System.Text.StringBuilder
            $seq = 1

            foreach ($b in $blocks) {
                if (-not $b.Trim()) { continue }
                $b2 = $b -replace "(?m)(\d{2}:\d{2}:\d{2})\.(\d{3})\s*-->\s*(\d{2}:\d{2}:\d{2})\.(\d{3})", "`$1,`$2 --> `$3,`$4"
                $null = $sb.AppendLine($seq)
                $null = $sb.AppendLine($b2.Trim())
                $null = $sb.AppendLine()
                $seq++
            }

            [IO.File]::WriteAllText($srt, $sb.ToString(), [Text.UTF8Encoding]::new($false))
            Write-Host "  ✓ $($vtt.Name) → SRT (fallback)" -ForegroundColor Green
        } catch {
            Write-Warning "  Fallback failade för $($vtt.Name)"
        }
    }

    # === FUNKTIONER FÖR TXT ===
    function Parse-SubtitleFile {
        param([Parameter(Mandatory)][string]$Path)

        if (-not (Test-Path -LiteralPath $Path)) { return @() }

        $raw = (Get-Content -LiteralPath $Path -Encoding UTF8) -join "`n"
        if (-not $raw) { return @() }

        $raw = $raw -replace "(?m)^WEBVTT.*?`n", ""
        $raw = $raw -replace "(?m)^NOTE.*?`n`n", ""
        $raw = $raw -replace "(?m)\s*(align|position|line|size):[^\n]+", ""
        $raw = $raw -replace "</?[^>]+>", ""

        $blocks = $raw -split "`n`n" | Where-Object { $_.Trim() }
        $cues = @()

        foreach ($block in $blocks) {
            $lines = $block -split "`n" | Where-Object { $_.Trim() }
            if ($lines.Count -eq 0) { continue }

            $timestamp = $null
            $textLines = @()

            foreach ($line in $lines) {
                $trimmed = $line.Trim()
                if ($trimmed -match '^\d{1,6}$') { continue }
                if ($trimmed -match '^\d{2}:\d{2}:\d{2}[.,]\d{3}\s*-->\s*\d{2}:\d{2}:\d{2}[.,]\d{3}') {
                    $timestamp = $trimmed -replace ',', '.'
                    continue
                }
                if ($trimmed) { $textLines += $trimmed }
            }

            $text = ($textLines -join " ").Trim()
            if ($timestamp -and $text) {
                $cues += @{ Timestamp = $timestamp; Text = $text }
            }
        }

        return $cues
    }

    function Remove-ConsecutiveDuplicates {
        param([Parameter(Mandatory)][array]$Cues)

        if ($Cues.Count -eq 0) { return @() }

        $result = @()
        $previousText = $null

        foreach ($cue in $Cues) {
            if ($cue.Text -ne $previousText) {
                $result += $cue
                $previousText = $cue.Text
            }
        }

        return $result
    }

    function Get-VideoIDFromFilename {
        param([string]$Filename)

        if ($Filename -match '\[([A-Za-z0-9_-]{6,})\]') {
            return $matches[1]
        }
        return $null
    }

    function Write-SubtitleTxt {
        param(
            [Parameter(Mandatory)][array]$Cues,
            [Parameter(Mandatory)][string]$OutputPath,
            [Parameter(Mandatory)][string]$VideoID,
            [Parameter(Mandatory)][string]$SubsDir
        )

        $output = New-Object System.Text.StringBuilder

        # Beskrivning
        $descFile = Get-ChildItem -Path $SubsDir -Filter "*[$VideoID].description" -File | Select-Object -First 1
        if ($descFile -and (Test-Path -LiteralPath $descFile.FullName)) {
            $desc = (Get-Content -LiteralPath $descFile.FullName -Encoding UTF8) -join "`n"
            if ($desc.Trim()) {
                $null = $output.AppendLine("=" * 80)
                $null = $output.AppendLine("VIDEO DESCRIPTION")
                $null = $output.AppendLine("=" * 80)
                $null = $output.AppendLine($desc.Trim())
                $null = $output.AppendLine("")
                $null = $output.AppendLine("=" * 80)
                $null = $output.AppendLine("SUBTITLES")
                $null = $output.AppendLine("=" * 80)
                $null = $output.AppendLine("")
            }
        }

        # Undertexter
        foreach ($cue in $Cues) {
            $null = $output.AppendLine($cue.Timestamp)
            $null = $output.AppendLine($cue.Text)
            $null = $output.AppendLine("")
        }

        $finalText = $output.ToString().Trim()
        [IO.File]::WriteAllText($OutputPath, $finalText, [Text.UTF8Encoding]::new($false))
    }

    # === GENERERA TXT ===
    Write-Host "`n==> Genererar TXT-filer..." -ForegroundColor Yellow

    $vttForTxt = @(Get-ChildItem -Path $subsDir -Filter "*.vtt" -File)

    Write-Host "✓ Bearbetar $($vttForTxt.Count) VTT-filer" -ForegroundColor Cyan

    foreach ($vtt in $vttForTxt) {
        $txtPath = "$($vtt.FullName).txt"

        # Skippa om redan finns
        if ((Test-Path $txtPath) -and (Get-Item $txtPath).Length -gt 0) {
            Write-Host "  ⏭️  $($vtt.Name) → TXT (finns redan)" -ForegroundColor Gray
            continue
        }

        try {
            # Extrahera video-ID från filnamn
            $videoID = Get-VideoIDFromFilename -Filename $vtt.Name
            if (-not $videoID) {
                Write-Warning "  Kunde inte extrahera video-ID från $($vtt.Name)"
                continue
            }

            $cues = Parse-SubtitleFile -Path $vtt.FullName

            if ($cues.Count -gt 0) {
                $cleaned = Remove-ConsecutiveDuplicates -Cues $cues
                Write-SubtitleTxt -Cues $cleaned -OutputPath $txtPath -VideoID $videoID -SubsDir $subsDir
                Write-Host "  ✓ $($vtt.Name) → TXT ($($cleaned.Count) cues)" -ForegroundColor Green
            } else {
                Write-Warning "  Inga cues hittades i $($vtt.Name)"
            }
        } catch {
            Write-Warning "  TXT-generering failade för $($vtt.Name): $($_.Exception.Message)"
        }
    }

    Pop-Location
}

###############################################################################
# SAMMANFATTNING
###############################################################################

Write-Host "`n======== SAMMANFATTNING ========" -ForegroundColor Cyan

if ($downloadVideo) {
    $videoFiles = Get-ChildItem -Path $filmFolder -Filter "*.mp4"
    Write-Host "`nVideo:" -ForegroundColor Yellow
    Write-Host "  ✓ Antal filer: $($videoFiles.Count)" -ForegroundColor Green

    if ($videoFiles.Count -gt 0) {
        $totalSize = ($videoFiles | Measure-Object -Property Length -Sum).Sum
        Write-Host "  ✓ Total storlek: $([math]::Round($totalSize/1MB, 2)) MB" -ForegroundColor Green

        if ($videoFiles.Count -le 10) {
            foreach ($f in $videoFiles | Select-Object -First 10) {
                $size = "{0:N2} MB" -f ($f.Length/1MB)
                Write-Host "    • $($f.Name) ($size)" -ForegroundColor Gray
            }
        }

        if ($videoFiles.Count -gt 10) {
            Write-Host "    (visar inte alla filer - för många)" -ForegroundColor Gray
        }
    }

    Write-Host "  Katalog: $filmFolder" -ForegroundColor Gray
}

if ($downloadSubs) {
    $subFiles = Get-ChildItem -Path $subsDir -File
    Write-Host "`nUndertexter:" -ForegroundColor Yellow

    $vttCount = @($subFiles | Where-Object { $_.Extension -eq ".vtt" }).Count
    $srtCount = @($subFiles | Where-Object { $_.Extension -eq ".srt" }).Count
    $txtCount = @($subFiles | Where-Object { $_.Extension -eq ".txt" -and $_.Name -like "*.vtt.txt" }).Count
    $descCount = @($subFiles | Where-Object { $_.Extension -eq ".description" }).Count

    Write-Host "  ✓ VTT: $vttCount filer" -ForegroundColor Green
    Write-Host "  ✓ SRT: $srtCount filer" -ForegroundColor Green
    Write-Host "  ✓ TXT: $txtCount filer" -ForegroundColor Green
    Write-Host "  ✓ Beskrivningar: $descCount filer" -ForegroundColor Gray
    Write-Host "  Katalog: $subsDir" -ForegroundColor Gray
}

if ($isPlaylist) {
    Write-Host "`n📋 SPELLISTA-INFO:" -ForegroundColor Magenta
    Write-Host "  Säker rate-limiting användes" -ForegroundColor Green

    if (Get-Variable -Name downloadArchive -ValueOnly -ErrorAction SilentlyContinue) {
        Write-Host "  Progress sparad i: $downloadArchive" -ForegroundColor Cyan
        Write-Host "  💡 Kör scriptet igen för att fortsätta!" -ForegroundColor Yellow
    } else {
        Write-Host "  💡 TIP: Aktivera `$downloadArchive för att spara progress" -ForegroundColor Yellow
    }
}

Write-Host "`n==> KLART!" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan
