###############################################################################
# YouTube Video & Subtitle Downloader - v8 INTERACTIVE
# 
# Funktioner:
# - Ladda ner video (MP4 med H.264 + AAC)
# - Ladda ner undertexter (VTT, SRT, TXT)
# - Bädda in undertexter i video (embedded subtitles)
# - Stöd för spellistor
# - Interaktiv konfiguration
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
# KONFIG - INTERAKTIV MODE
#==============================================================================
# Sätt till $false för att använda hårdkodade värden nedan (automation)
$interactiveMode = $true

#==============================================================================
# KONFIG - HÅRDKODADE VÄRDEN (används om $interactiveMode = $false)
#==============================================================================
$videoUrl = ""
$downloadVideo = $true
$downloadSubs = $true
$embedSubtitles = $false        # Bädda in undertexter i video?
$maxDownloads = $null           # null = ingen gräns
$sleepSubtitles = 4
$downloadArchive = $null        # null = ingen progress-tracking

#==============================================================================
# START
#==============================================================================

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "YouTube Downloader v8.0 - INTERACTIVE" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# === VALIDATION ===
if (-not (Test-Path $yt)) {
    Write-Error "FATAL: yt-dlp.exe saknas i $baseDir"
    throw "STOPPAR - yt-dlp.exe saknas"
}

if (-not (Test-Path $ffmpeg)) {
    Write-Warning "ffmpeg.exe saknas - embedding av undertexter kommer inte fungera"
}

# Skapa målmappar
New-Item -ItemType Directory -Force -Path $filmFolder | Out-Null
New-Item -ItemType Directory -Force -Path $subsDir | Out-Null

#==============================================================================
# INTERAKTIV KONFIGURATION
#==============================================================================

if ($interactiveMode) {
    # === URL ===
    Write-Host "📺 STEG 1: YouTube-URL" -ForegroundColor Yellow
    Write-Host "   Exempel video: https://www.youtube.com/watch?v=xxxxx" -ForegroundColor Gray
    Write-Host "   Exempel spellista: https://www.youtube.com/playlist?list=PLxxxxx" -ForegroundColor Gray
    
    do {
        $videoUrl = Read-Host "`nURL"
        if (-not $videoUrl -or $videoUrl.Trim() -eq "") {
            Write-Host "⚠️  URL kan inte vara tom" -ForegroundColor Red
        }
    } while (-not $videoUrl -or $videoUrl.Trim() -eq "")
    
    # Detektera spellista
    $isPlaylist = $videoUrl -match 'playlist\?list=' -or $videoUrl -match '&list='
    
    if ($isPlaylist) {
        Write-Host "✓ Spellista detekterad!" -ForegroundColor Green
    } else {
        Write-Host "✓ Enskild video detekterad" -ForegroundColor Green
    }
    
    # === VAD SKA LADDAS NER ===
    Write-Host "`n📦 STEG 2: Vad vill du ladda ner?" -ForegroundColor Yellow
    
    $choice = Read-Host "   1) Bara video`n   2) Bara undertexter`n   3) Både video och undertexter`n`nVal (1-3)"
    
    switch ($choice) {
        "1" { 
            $downloadVideo = $true
            $downloadSubs = $false
            Write-Host "✓ Laddar bara video" -ForegroundColor Green
        }
        "2" { 
            $downloadVideo = $false
            $downloadSubs = $true
            Write-Host "✓ Laddar bara undertexter" -ForegroundColor Green
        }
        default { 
            $downloadVideo = $true
            $downloadSubs = $true
            Write-Host "✓ Laddar både video och undertexter" -ForegroundColor Green
        }
    }
    
    # === EMBED SUBTITLES ===
    if ($downloadVideo -and $downloadSubs) {
        Write-Host "`n🎬 STEG 3: Bädda in undertexter i video?" -ForegroundColor Yellow
        Write-Host "   Detta bränner in undertexterna direkt i videofilen" -ForegroundColor Gray
        Write-Host "   (kräver ffmpeg och tar lite längre tid)" -ForegroundColor Gray
        
        $embedChoice = Read-Host "`n   Vill du bädda in undertexter? (j/n)"
        
        if ($embedChoice -eq "j" -or $embedChoice -eq "J") {
            $embedSubtitles = $true
            Write-Host "✓ Undertexter kommer bäddas in i video" -ForegroundColor Green
        } else {
            $embedSubtitles = $false
            Write-Host "✓ Undertexter sparas som separata filer" -ForegroundColor Green
        }
    } else {
        $embedSubtitles = $false
    }
    
    # === SPELLISTA-ALTERNATIV ===
    if ($isPlaylist) {
        Write-Host "`n📋 STEG 4: Spellista-inställningar" -ForegroundColor Yellow
        
        # Max downloads
        $maxInput = Read-Host "   Hur många videos vill du ladda ner? (Enter = alla)"
        if ($maxInput -and $maxInput -match '^\d+$') {
            $maxDownloads = [int]$maxInput
            Write-Host "✓ Laddar max $maxDownloads videos" -ForegroundColor Green
        } else {
            $maxDownloads = $null
            Write-Host "✓ Laddar alla videos i spellistan" -ForegroundColor Green
        }
        
        # Sleep subtitles
        Write-Host "`n   Rate-limiting (delay mellan undertext-requests):" -ForegroundColor Gray
        $sleepInput = Read-Host "   Sekunder delay (8-12 rekommenderat, Enter = 8)"
        if ($sleepInput -and $sleepInput -match '^\d+$') {
            $sleepSubtitles = [int]$sleepInput
        } else {
            $sleepSubtitles = 8
        }
        Write-Host "✓ Använder $sleepSubtitles sekunders delay" -ForegroundColor Green
        
        # Download archive
        $archiveChoice = Read-Host "`n   Spara progress för att fortsätta senare? (j/n)"
        if ($archiveChoice -eq "j" -or $archiveChoice -eq "J") {
            $downloadArchive = "youtube_progress.txt"
            Write-Host "✓ Progress sparas i: $downloadArchive" -ForegroundColor Green
        } else {
            $downloadArchive = $null
            Write-Host "✓ Ingen progress-tracking" -ForegroundColor Green
        }
    } else {
        # Enskild video
        $sleepSubtitles = 4
    }
    
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "KONFIGURATION KLAR - STARTAR NEDLADDNING" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
    Start-Sleep -Seconds 2
}

# === DETEKTERA SPELLISTA (om inte redan gjort) ===
if (-not $interactiveMode) {
    $isPlaylist = $videoUrl -match 'playlist\?list=' -or $videoUrl -match '&list='
    
    if ($isPlaylist -and $sleepSubtitles -lt 8) {
        $sleepSubtitles = 8
        Write-Host "⚠️  Auto-ökar sleep-subtitles till 8s (spellista)" -ForegroundColor Yellow
    }
}

Write-Host "Konfiguration:" -ForegroundColor Cyan
Write-Host "  Video: $(if($downloadVideo){'JA'}else{'NEJ'})" -ForegroundColor $(if($downloadVideo){'Green'}else{'Gray'})
Write-Host "  Undertexter: $(if($downloadSubs){'JA'}else{'NEJ'})" -ForegroundColor $(if($downloadSubs){'Green'}else{'Gray'})
Write-Host "  Embedded subs: $(if($embedSubtitles){'JA'}else{'NEJ'})" -ForegroundColor $(if($embedSubtitles){'Green'}else{'Gray'})
if ($maxDownloads) { Write-Host "  Max videos: $maxDownloads" -ForegroundColor Cyan }
Write-Host "  Sleep delay: $sleepSubtitles s" -ForegroundColor Cyan
if ($downloadArchive) { Write-Host "  Progress: $downloadArchive" -ForegroundColor Cyan }

###############################################################################
# DEL 1: LADDA NER VIDEO
###############################################################################

if ($downloadVideo) {
    Write-Host "`n==> LADDAR NER VIDEO$(if($isPlaylist){' (SPELLISTA)'}else{''})..." -ForegroundColor Yellow
    Write-Host "Mål: $filmFolder" -ForegroundColor Gray
    
    # Bygg kommando
    $ytArgs = @(
        "--ffmpeg-location", $baseDir,
        "-S", "ext:mp4:m4a,vcodec:h264,acodec:aac",
        "-f", "bv*+ba/best",
        "--merge-output-format", "mp4",
        "--embed-metadata",
        "--remux-video", "mp4"
    )
    
    # VIKTIGT: Om vi ska embedda undertexter, ladda ner dem direkt med videon
    if ($embedSubtitles) {
        Write-Host "  📌 Kommer bädda in undertexter efter nedladdning" -ForegroundColor Cyan
        # Vi laddar ner undertexter separat och bäddar in dem efteråt
    }
    
    $ytArgs += "-o"
    $ytArgs += "$filmFolder\%(title)s [%(id)s].%(ext)s"
    
    # Lägg till spellista-alternativ
    if ($maxDownloads) {
        $ytArgs += "--max-downloads"
        $ytArgs += $maxDownloads
    }
    
    if ($downloadArchive) {
        $ytArgs += "--download-archive"
        $ytArgs += $downloadArchive
    }
    
    $ytArgs += $videoUrl
    
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
    
    # Bygg kommando
    $ytSubsArgs = @(
        "--ffmpeg-location", $baseDir,
        "--skip-download",
        "--write-sub", "--write-auto-sub",
        "--sub-langs", "en.*,sv.*",
        "--sub-format", "vtt",
        "--write-description",
        "--sleep-subtitles", $sleepSubtitles,
        "-o", "%(title)s [%(id)s].%(ext)s"
    )
    
    if ($maxDownloads) {
        $ytSubsArgs += "--max-downloads"
        $ytSubsArgs += $maxDownloads
    }
    
    if ($downloadArchive) {
        $ytSubsArgs += "--download-archive"
        $ytSubsArgs += $downloadArchive
    }
    
    $ytSubsArgs += $videoUrl
    
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
        
        if ((Test-Path $srt) -and (Get-Item $srt).Length -gt 0) {
            Write-Host "  ⏭️  $($vtt.Name) → SRT (finns redan)" -ForegroundColor Gray
            continue
        }
        
        if (Test-Path $ffmpeg) {
            & $ffmpeg -y -loglevel error -i $vtt.FullName -f srt $srt
            
            if ((Test-Path $srt) -and (Get-Item $srt).Length -gt 0) {
                Write-Host "  ✓ $($vtt.Name) → SRT" -ForegroundColor Green
                continue
            }
        }
        
        # Fallback
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
        
        if ((Test-Path $txtPath) -and (Get-Item $txtPath).Length -gt 0) {
            Write-Host "  ⏭️  $($vtt.Name) → TXT (finns redan)" -ForegroundColor Gray
            continue
        }
        
        try {
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
# DEL 3: BÄDDA IN UNDERTEXTER I VIDEO
###############################################################################

if ($embedSubtitles -and $downloadVideo -and $downloadSubs) {
    Write-Host "`n==> BÄDDAR IN UNDERTEXTER I VIDEO..." -ForegroundColor Yellow
    
    if (-not (Test-Path $ffmpeg)) {
        Write-Error "FATAL: ffmpeg.exe saknas - kan inte bädda in undertexter"
    } else {
        # Hitta alla videos
        $videoFiles = @(Get-ChildItem -Path $filmFolder -Filter "*.mp4" -File)
        Write-Host "Hittade $($videoFiles.Count) video(r) att bearbeta" -ForegroundColor Cyan
        
        foreach ($video in $videoFiles) {
            # Extrahera video-ID
            $videoID = Get-VideoIDFromFilename -Filename $video.Name
            if (-not $videoID) {
                Write-Warning "  Kunde inte extrahera ID från $($video.Name)"
                continue
            }
            
            # Hitta motsvarande SRT-fil (prioritera engelsk)
            $srtFile = Get-ChildItem -Path $subsDir -Filter "*[$videoID]*.en.srt" -File | Select-Object -First 1
            
            if (-not $srtFile) {
                $srtFile = Get-ChildItem -Path $subsDir -Filter "*[$videoID]*.srt" -File | Select-Object -First 1
            }
            
            if (-not $srtFile) {
                Write-Warning "  Ingen SRT hittades för $($video.Name)"
                continue
            }
            
            # Skapa output-filnamn
            $outputName = $video.BaseName + "_with_subs.mp4"
            $outputPath = Join-Path $filmFolder $outputName
            
            # Skippa om redan finns
            if (Test-Path $outputPath) {
                Write-Host "  ⏭️  $($video.Name) (finns redan)" -ForegroundColor Gray
                continue
            }
            
            Write-Host "  🎬 Bearbetar: $($video.Name)" -ForegroundColor Cyan
            Write-Host "     Undertexter: $($srtFile.Name)" -ForegroundColor Gray
            
            # Bädda in undertexter med ffmpeg
            # VIKTIGT: Vi använder -c copy för att undvika omkodning (snabbare!)
            & $ffmpeg -y -loglevel error `
                -i $video.FullName `
                -i $srtFile.FullName `
                -c copy `
                -c:s mov_text `
                -metadata:s:s:0 language=eng `
                -metadata:s:s:0 title="English" `
                $outputPath
            
            if ((Test-Path $outputPath) -and (Get-Item $outputPath).Length -gt 0) {
                $newSize = (Get-Item $outputPath).Length
                $oldSize = $video.Length
                Write-Host "     ✓ Klar! Ny storlek: $([math]::Round($newSize/1MB, 2)) MB (original: $([math]::Round($oldSize/1MB, 2)) MB)" -ForegroundColor Green
            } else {
                Write-Warning "     Embedding failade för $($video.Name)"
            }
        }
        
        Write-Host "`n✓ Embedding klar!" -ForegroundColor Green
        Write-Host "  Original-filer: *[videoID].mp4" -ForegroundColor Gray
        Write-Host "  Med undertexter: *[videoID]_with_subs.mp4" -ForegroundColor Gray
    }
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
        
        if ($embedSubtitles) {
            $embeddedCount = @($videoFiles | Where-Object { $_.Name -like "*_with_subs.mp4" }).Count
            Write-Host "  ✓ Med inbäddade undertexter: $embeddedCount filer" -ForegroundColor Green
        }
        
        if ($videoFiles.Count -le 10) {
            foreach ($f in $videoFiles | Select-Object -First 10) {
                $size = "{0:N2} MB" -f ($f.Length/1MB)
                $icon = if ($f.Name -like "*_with_subs.mp4") { "🎬" } else { "📹" }
                Write-Host "    $icon $($f.Name) ($size)" -ForegroundColor Gray
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
    
    if ($downloadArchive) {
        Write-Host "  Progress sparad i: $downloadArchive" -ForegroundColor Cyan
        Write-Host "  💡 Kör scriptet igen för att fortsätta!" -ForegroundColor Yellow
    }
}

Write-Host "`n==> KLART!" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan
