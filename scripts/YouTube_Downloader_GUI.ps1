# YouTube Downloader GUI
# Grafisk GUI for att ladda ner YouTube-videos med yt-dlp

# UTF-8 encoding
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Ladda Windows Forms
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# === KONFIGURATION ===
# Hitta huvudmappen (en nivå upp från projektmappen)
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptDir
$baseDir = Split-Path -Parent $projectRoot

$ytDlpPath = Join-Path -Path $baseDir -ChildPath "yt-dlp.exe"
$ffmpegPath = Join-Path -Path $baseDir -ChildPath "ffmpeg.exe"
$outputDir = Join-Path -Path $baseDir -ChildPath "downloaded"

# Skapa output-mapp om den inte finns
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

# === SKAPA FORMULAR ===
$form = New-Object System.Windows.Forms.Form
$form.Text = 'YouTube Downloader'
$form.Size = New-Object System.Drawing.Size(700, 750)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false

# === URL SEKTION ===
$labelUrl = New-Object System.Windows.Forms.Label
$labelUrl.Location = New-Object System.Drawing.Point(10, 10)
$labelUrl.Size = New-Object System.Drawing.Size(680, 20)
$labelUrl.Text = 'YouTube URL (video eller spellista):'
$form.Controls.Add($labelUrl)

$textBoxUrl = New-Object System.Windows.Forms.TextBox
$textBoxUrl.Location = New-Object System.Drawing.Point(10, 35)
$textBoxUrl.Size = New-Object System.Drawing.Size(660, 25)
$textBoxUrl.Font = New-Object System.Drawing.Font("Consolas", 10)
$form.Controls.Add($textBoxUrl)

# === INNEHALLSTYP ===
$groupContent = New-Object System.Windows.Forms.GroupBox
$groupContent.Location = New-Object System.Drawing.Point(10, 70)
$groupContent.Size = New-Object System.Drawing.Size(320, 160)
$groupContent.Text = 'Vad vill du ladda ner?'
$form.Controls.Add($groupContent)

$radioVideo = New-Object System.Windows.Forms.RadioButton
$radioVideo.Location = New-Object System.Drawing.Point(15, 25)
$radioVideo.Size = New-Object System.Drawing.Size(280, 25)
$radioVideo.Text = 'Video (med eller utan undertexter)'
$radioVideo.Checked = $true
$groupContent.Controls.Add($radioVideo)

$radioAudio = New-Object System.Windows.Forms.RadioButton
$radioAudio.Location = New-Object System.Drawing.Point(15, 55)
$radioAudio.Size = New-Object System.Drawing.Size(280, 25)
$radioAudio.Text = 'Bara ljud (MP3)'
$groupContent.Controls.Add($radioAudio)

$radioSubsOnly = New-Object System.Windows.Forms.RadioButton
$radioSubsOnly.Location = New-Object System.Drawing.Point(15, 85)
$radioSubsOnly.Size = New-Object System.Drawing.Size(280, 25)
$radioSubsOnly.Text = 'Bara undertexter'
$groupContent.Controls.Add($radioSubsOnly)

$radioDescOnly = New-Object System.Windows.Forms.RadioButton
$radioDescOnly.Location = New-Object System.Drawing.Point(15, 115)
$radioDescOnly.Size = New-Object System.Drawing.Size(280, 25)
$radioDescOnly.Text = 'Bara beskrivning (textfil)'
$groupContent.Controls.Add($radioDescOnly)

# === KVALITET ===
$groupQuality = New-Object System.Windows.Forms.GroupBox
$groupQuality.Location = New-Object System.Drawing.Point(350, 70)
$groupQuality.Size = New-Object System.Drawing.Size(320, 80)
$groupQuality.Text = 'Videokvalitet'
$form.Controls.Add($groupQuality)

$labelQuality = New-Object System.Windows.Forms.Label
$labelQuality.Location = New-Object System.Drawing.Point(15, 25)
$labelQuality.Size = New-Object System.Drawing.Size(100, 20)
$labelQuality.Text = 'Valj kvalitet:'
$groupQuality.Controls.Add($labelQuality)

$comboQuality = New-Object System.Windows.Forms.ComboBox
$comboQuality.Location = New-Object System.Drawing.Point(15, 45)
$comboQuality.Size = New-Object System.Drawing.Size(280, 25)
$comboQuality.DropDownStyle = 'DropDownList'
$comboQuality.Items.AddRange(@('Basta (2160p/4K)', '1440p (2K)', '1080p (Full HD)', '720p (HD)', '480p', '360p', '240p'))
$comboQuality.SelectedIndex = 2  # Default: 1080p
$groupQuality.Controls.Add($comboQuality)

# === UNDERTEXTER ===
$groupSubs = New-Object System.Windows.Forms.GroupBox
$groupSubs.Location = New-Object System.Drawing.Point(350, 160)
$groupSubs.Size = New-Object System.Drawing.Size(320, 150)
$groupSubs.Text = 'Undertexter'
$form.Controls.Add($groupSubs)

$checkDownloadSubs = New-Object System.Windows.Forms.CheckBox
$checkDownloadSubs.Location = New-Object System.Drawing.Point(15, 25)
$checkDownloadSubs.Size = New-Object System.Drawing.Size(280, 25)
$checkDownloadSubs.Text = 'Ladda ner undertexter'
$checkDownloadSubs.Checked = $false
$groupSubs.Controls.Add($checkDownloadSubs)

$checkEmbedSubs = New-Object System.Windows.Forms.CheckBox
$checkEmbedSubs.Location = New-Object System.Drawing.Point(15, 55)
$checkEmbedSubs.Size = New-Object System.Drawing.Size(280, 25)
$checkEmbedSubs.Text = 'Badda in undertexter i video'
$checkEmbedSubs.Enabled = $false
$groupSubs.Controls.Add($checkEmbedSubs)

$labelSubLang = New-Object System.Windows.Forms.Label
$labelSubLang.Location = New-Object System.Drawing.Point(15, 85)
$labelSubLang.Size = New-Object System.Drawing.Size(100, 20)
$labelSubLang.Text = 'Sprak:'
$groupSubs.Controls.Add($labelSubLang)

$comboSubLang = New-Object System.Windows.Forms.ComboBox
$comboSubLang.Location = New-Object System.Drawing.Point(15, 105)
$comboSubLang.Size = New-Object System.Drawing.Size(280, 25)
$comboSubLang.DropDownStyle = 'DropDownList'
$comboSubLang.Items.AddRange(@('Svenska', 'Engelska', 'Alla tillgangliga'))
$comboSubLang.SelectedIndex = 0  # Default: Svenska
$comboSubLang.Enabled = $false
$groupSubs.Controls.Add($comboSubLang)

# Enable/disable subtitle controls based on checkbox
$checkDownloadSubs.Add_CheckedChanged({
    $checkEmbedSubs.Enabled = $checkDownloadSubs.Checked -and $radioVideo.Checked
    $comboSubLang.Enabled = $checkDownloadSubs.Checked
})

# Disable embed checkbox when not in video mode
$radioVideo.Add_CheckedChanged({
    $checkEmbedSubs.Enabled = $checkDownloadSubs.Checked -and $radioVideo.Checked
})
$radioAudio.Add_CheckedChanged({
    $checkEmbedSubs.Enabled = $false
})
$radioSubsOnly.Add_CheckedChanged({
    $checkEmbedSubs.Enabled = $false
})
$radioDescOnly.Add_CheckedChanged({
    $checkEmbedSubs.Enabled = $false
})

# === EXTRA ALTERNATIV ===
$groupExtra = New-Object System.Windows.Forms.GroupBox
$groupExtra.Location = New-Object System.Drawing.Point(10, 240)
$groupExtra.Size = New-Object System.Drawing.Size(320, 120)
$groupExtra.Text = 'Extra alternativ'
$form.Controls.Add($groupExtra)

$checkDescription = New-Object System.Windows.Forms.CheckBox
$checkDescription.Location = New-Object System.Drawing.Point(15, 25)
$checkDescription.Size = New-Object System.Drawing.Size(280, 25)
$checkDescription.Text = 'Spara beskrivning i textfil'
$checkDescription.Checked = $false
$groupExtra.Controls.Add($checkDescription)

$labelMaxVideos = New-Object System.Windows.Forms.Label
$labelMaxVideos.Location = New-Object System.Drawing.Point(15, 60)
$labelMaxVideos.Size = New-Object System.Drawing.Size(200, 20)
$labelMaxVideos.Text = 'Max antal videos (spellista):'
$groupExtra.Controls.Add($labelMaxVideos)

$numMaxVideos = New-Object System.Windows.Forms.NumericUpDown
$numMaxVideos.Location = New-Object System.Drawing.Point(220, 57)
$numMaxVideos.Size = New-Object System.Drawing.Size(80, 25)
$numMaxVideos.Minimum = 1
$numMaxVideos.Maximum = 999
$numMaxVideos.Value = 5
$groupExtra.Controls.Add($numMaxVideos)

# === STATUS/OUTPUT ===
$labelStatus = New-Object System.Windows.Forms.Label
$labelStatus.Location = New-Object System.Drawing.Point(10, 370)
$labelStatus.Size = New-Object System.Drawing.Size(660, 20)
$labelStatus.Text = 'Status:'
$form.Controls.Add($labelStatus)

$textBoxStatus = New-Object System.Windows.Forms.TextBox
$textBoxStatus.Location = New-Object System.Drawing.Point(10, 395)
$textBoxStatus.Size = New-Object System.Drawing.Size(660, 250)
$textBoxStatus.Multiline = $true
$textBoxStatus.ReadOnly = $true
$textBoxStatus.ScrollBars = 'Vertical'
$textBoxStatus.Font = New-Object System.Drawing.Font("Consolas", 9)
$textBoxStatus.BackColor = [System.Drawing.Color]::Black
$textBoxStatus.ForeColor = [System.Drawing.Color]::LimeGreen
$form.Controls.Add($textBoxStatus)

# === LADDA NER KNAPP ===
$btnDownload = New-Object System.Windows.Forms.Button
$btnDownload.Location = New-Object System.Drawing.Point(10, 660)
$btnDownload.Size = New-Object System.Drawing.Size(660, 40)
$btnDownload.Text = 'LADDA NER'
$btnDownload.Font = New-Object System.Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Bold)
$btnDownload.BackColor = [System.Drawing.Color]::Green
$btnDownload.ForeColor = [System.Drawing.Color]::White
$form.Controls.Add($btnDownload)

# === FUNKTIONER FOR TXT-GENERERING ===
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
        [Parameter(Mandatory)][string]$OutputDir
    )

    $output = New-Object System.Text.StringBuilder

    $descFile = Get-ChildItem -Path $OutputDir -Filter "*[$VideoID].description" -File | Select-Object -First 1
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

# === NEDLADDNINGSLOGIK ===
$btnDownload.Add_Click({
    # Rensa status
    $textBoxStatus.Text = ""

    # Validera URL
    $url = $textBoxUrl.Text.Trim()
    if ([string]::IsNullOrWhiteSpace($url)) {
        [System.Windows.Forms.MessageBox]::Show("Du maste ange en URL!", "Fel", 'OK', 'Error')
        return
    }

    # Ta bort &index=X fran URL for att ladda hela spellistan
    $url = $url -replace '&index=\d+', ''
    $url = $url -replace '\?index=\d+&', '?'
    $url = $url -replace '\?index=\d+$', ''

    # Kontrollera att yt-dlp finns
    if (-not (Test-Path $ytDlpPath)) {
        [System.Windows.Forms.MessageBox]::Show("Hittar inte yt-dlp.exe pa: $ytDlpPath", "Fel", 'OK', 'Error')
        return
    }

    $textBoxStatus.AppendText(">> Startar nedladdning...`r`n")
    $textBoxStatus.AppendText(">> URL: $url`r`n`r`n")

    # Bygg yt-dlp kommando
    $ytArgs = @()

    # Output directory
    $ytArgs += "-P"
    $ytArgs += "`"$outputDir`""

    # === FORMAT OCH TYP ===
    if ($radioVideo.Checked) {
        # Video mode
        $textBoxStatus.AppendText("[VIDEO] Laddar ner video`r`n")

        # VIKTIGT: Anvand samma parametrar som det fungerande scriptet!
        $ytArgs += "-S"
        $ytArgs += "ext:mp4:m4a,vcodec:h264,acodec:aac"
        $ytArgs += "-f"
        $ytArgs += "bv*+ba/best"
        $ytArgs += "--merge-output-format"
        $ytArgs += "mp4"
        $ytArgs += "--embed-metadata"
        $ytArgs += "--remux-video"
        $ytArgs += "mp4"

        # Output template - MASTE citeras for att undvika problem med hakparenteser
        $ytArgs += "-o"
        $ytArgs += "`"%(title)s [%(id)s].%(ext)s`""

        $textBoxStatus.AppendText("[KVALITET] Basta tillgangliga`r`n")

    } elseif ($radioAudio.Checked) {
        # Audio only (MP3)
        $textBoxStatus.AppendText("[AUDIO] Laddar ner bara ljud (MP3)`r`n")
        $ytArgs += "-f"
        $ytArgs += "bestaudio"
        $ytArgs += "-x"  # Extract audio
        $ytArgs += "--audio-format"
        $ytArgs += "mp3"
        $ytArgs += "--audio-quality"
        $ytArgs += "0"  # Best quality
        $ytArgs += "-o"
        $ytArgs += "`"%(title)s [%(id)s].%(ext)s`""

    } elseif ($radioSubsOnly.Checked) {
        # Subtitles only
        $textBoxStatus.AppendText("[SUBS] Laddar ner bara undertexter`r`n")
        $ytArgs += "--skip-download"
        $ytArgs += "--write-subs"
        $ytArgs += "--write-auto-subs"

        # Sprak
        $langMap = @{
            'Svenska' = 'sv'
            'Engelska' = 'en'
            'Alla tillgangliga' = 'all'
        }
        $selectedLang = $comboSubLang.SelectedItem.ToString()
        if ($selectedLang -ne 'Alla tillgangliga') {
            $ytArgs += "--sub-langs"
            $ytArgs += $langMap[$selectedLang]
        }

        $ytArgs += "-o"
        $ytArgs += "`"%(title)s [%(id)s]`""

    } elseif ($radioDescOnly.Checked) {
        # Description only
        $textBoxStatus.AppendText("[DESC] Laddar ner bara beskrivning`r`n")
        $ytArgs += "--skip-download"
        $ytArgs += "--write-description"
        $ytArgs += "-o"
        $ytArgs += "`"%(title)s [%(id)s]`""
    }

    # === UNDERTEXTER (for video/audio mode) ===
    if ($checkDownloadSubs.Checked -and ($radioVideo.Checked -or $radioAudio.Checked)) {
        $textBoxStatus.AppendText("[SUBS] Inkluderar undertexter`r`n")
        $ytArgs += "--write-subs"
        $ytArgs += "--write-auto-subs"

        # Sprak
        $langMap = @{
            'Svenska' = 'sv'
            'Engelska' = 'en'
            'Alla tillgangliga' = 'all'
        }
        $selectedLang = $comboSubLang.SelectedItem.ToString()
        if ($selectedLang -ne 'Alla tillgangliga') {
            $ytArgs += "--sub-langs", $langMap[$selectedLang]
        }

        # Embed subtitles (only for video)
        if ($checkEmbedSubs.Checked -and $radioVideo.Checked) {
            $textBoxStatus.AppendText("[EMBED] Baddar in undertexter i video`r`n")
            $ytArgs += "--embed-subs"
        }
    }

    # === BESKRIVNING ===
    if ($checkDescription.Checked -and -not $radioDescOnly.Checked) {
        $textBoxStatus.AppendText("[DESC] Sparar beskrivning`r`n")
        $ytArgs += "--write-description"
    }

    # === PLAYLIST HANTERING ===
    $maxVids = $numMaxVideos.Value
    $ytArgs += "--max-downloads"
    $ytArgs += $maxVids.ToString()
    $textBoxStatus.AppendText("[PLAYLIST] Max antal videos: $maxVids`r`n")

    # === OVRIGA INSTALLNINGAR ===
    $ytArgs += "--ffmpeg-location"
    $ytArgs += "`"$baseDir`""
    $ytArgs += "--yes-playlist"  # VIKTIGT: Tvingar spellista-nedladdning aven med &index=X

    # Lagg till URL sist
    $ytArgs += $url

    $textBoxStatus.AppendText("`r`n>> Kor yt-dlp...`r`n")
    $textBoxStatus.AppendText("=========================================`r`n")

    # Disable button during download
    $btnDownload.Enabled = $false
    $btnDownload.Text = "LADDAR NER..."
    $form.Refresh()

    try {
        # Kor yt-dlp
        $outputFile = Join-Path -Path $env:TEMP -ChildPath "ytdlp_output.txt"
        $errorFile = Join-Path -Path $env:TEMP -ChildPath "ytdlp_error.txt"

        $process = Start-Process -FilePath $ytDlpPath -ArgumentList $ytArgs -NoNewWindow -Wait -PassThru -RedirectStandardOutput $outputFile -RedirectStandardError $errorFile

        # Las output och filtrera progress-spam
        if (Test-Path $outputFile) {
            $allLines = Get-Content $outputFile
            $filteredLines = $allLines | Where-Object {
                # Behall alla rader UTOM progress-uppdateringar
                $_ -notmatch '^\[download\]\s+\d+\.\d+%' -and
                $_ -notmatch '^\[download\]\s+100\.0% of ~'
            }

            # Lagg till viktig information
            foreach ($line in $filteredLines) {
                $textBoxStatus.AppendText("$line`r`n")
            }

            # Lagg till slutlig progress-rad om nedladdning slutford
            $finalProgress = $allLines | Where-Object { $_ -match '^\[download\] 100% of\s+[\d.]+\w+iB in' } | Select-Object -Last 1
            if ($finalProgress) {
                $textBoxStatus.AppendText("$finalProgress`r`n")
            }
        }

        if ($process.ExitCode -eq 0) {
            # === GENERERA TXT-FILER FRAN VTT ===
            $textBoxStatus.AppendText("`r`n>> Genererar TXT-filer fran undertexter...`r`n")

            $vttFiles = @(Get-ChildItem -Path $outputDir -Filter "*.vtt" -File)

            if ($vttFiles.Count -gt 0) {
                foreach ($vtt in $vttFiles) {
                    $txtPath = "$($vtt.FullName).txt"

                    # Skippa om redan finns
                    if ((Test-Path $txtPath) -and (Get-Item $txtPath).Length -gt 0) {
                        continue
                    }

                    try {
                        $videoID = Get-VideoIDFromFilename -Filename $vtt.Name
                        if (-not $videoID) {
                            $textBoxStatus.AppendText("   VARNING: Kunde inte extrahera video-ID fran $($vtt.Name)`r`n")
                            continue
                        }

                        $cues = Parse-SubtitleFile -Path $vtt.FullName

                        if ($cues.Count -gt 0) {
                            $cleaned = Remove-ConsecutiveDuplicates -Cues $cues
                            Write-SubtitleTxt -Cues $cleaned -OutputPath $txtPath -VideoID $videoID -OutputDir $outputDir
                            $textBoxStatus.AppendText("   > Skapade: $($vtt.Name).txt ($($cleaned.Count) cues)`r`n")
                        }
                    } catch {
                        $textBoxStatus.AppendText("   VARNING: TXT-generering failade for $($vtt.Name): $($_.Exception.Message)`r`n")
                    }
                }
                $textBoxStatus.AppendText(">> TXT-filer klara!`r`n")
            } else {
                $textBoxStatus.AppendText("   Inga VTT-filer hittades (ingen txt att skapa)`r`n")
            }

            $textBoxStatus.AppendText("`r`n=========================================`r`n")
            $textBoxStatus.AppendText(">> KLART! Filerna sparades i: $outputDir`r`n")
            [System.Windows.Forms.MessageBox]::Show("Nedladdning klar!`n`nFilerna finns i:`n$outputDir", "Klart!", 'OK', 'Information')
        } else {
            $errorOutput = ""
            if (Test-Path $errorFile) {
                $errorOutput = Get-Content $errorFile -Raw
            }
            $textBoxStatus.AppendText("`r`n=========================================`r`n")
            $textBoxStatus.AppendText(">> FEL uppstod!`r`n")
            $textBoxStatus.AppendText($errorOutput)
            [System.Windows.Forms.MessageBox]::Show("Ett fel uppstod under nedladdningen. Se statusfonstret for detaljer.", "Fel", 'OK', 'Error')
        }
    } catch {
        $textBoxStatus.AppendText("`r`n>> FEL: $($_.Exception.Message)`r`n")
        [System.Windows.Forms.MessageBox]::Show("Ett fel uppstod: $($_.Exception.Message)", "Fel", 'OK', 'Error')
    } finally {
        # Re-enable button
        $btnDownload.Enabled = $true
        $btnDownload.Text = "LADDA NER"

        # Cleanup temp files
        if (Test-Path $outputFile) { Remove-Item $outputFile -Force }
        if (Test-Path $errorFile) { Remove-Item $errorFile -Force }
    }
})

# === VISA FORMULARET ===
$textBoxStatus.AppendText(">> YouTube Downloader GUI redo!`r`n")
$textBoxStatus.AppendText(">> Nedladdningar sparas i: $outputDir`r`n`r`n")
$textBoxStatus.AppendText("Ange en URL och valj dina alternativ, sedan tryck pa 'LADDA NER'`r`n")

[void]$form.ShowDialog()
