#Requires -Version 7.2
<#
.SYNOPSIS
    Word Document Generator - PowerShell Wrapper
.DESCRIPTION
    Robust wrapper for word_document_creator.py with dynamic path resolution,
    logging, error handling, and Windows compatibility.
.NOTES
    Author: Generated for Jacob's Word Document Repository
    Version: 1.0
    Language: Svenska i kommentarer, English in code
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$PSStyle.OutputRendering = "Host"  # Deterministic output

# --- [Config: Dynamic Paths] ------------------------------------------------
$ScriptDir = $PSScriptRoot
$PythonScript = Join-Path $ScriptDir "word_document_creator.py"
$LogDir = Join-Path $ScriptDir "logs"
$LogFile = Join-Path $LogDir "powershell_wrapper_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
$RequirementsFile = Join-Path $ScriptDir "requirements.txt"
$OutputDir = Join-Path $ScriptDir "output"
$TemplatesDir = Join-Path $ScriptDir "templates"
$ConfigDir = Join-Path $ScriptDir "config"

# --- [Setup: Create Directories] --------------------------------------------
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
New-Item -ItemType Directory -Force -Path $TemplatesDir | Out-Null
New-Item -ItemType Directory -Force -Path $ConfigDir | Out-Null

# --- [Logging: Start Transcript] --------------------------------------------
Start-Transcript -Path $LogFile -Append | Out-Null

try {
    Write-Host "==================================================================" -ForegroundColor Cyan
    Write-Host "  Word Document Generator - PowerShell Wrapper" -ForegroundColor Cyan
    Write-Host "==================================================================" -ForegroundColor Cyan
    Write-Host ""

    # --- [Step 1: Verify Python] --------------------------------------------
    Write-Host "[1/5] Verifierar Python-installation..." -ForegroundColor Yellow

    $PythonCmd = $null
    foreach ($cmd in @("python", "python3", "py")) {
        try {
            $version = & $cmd --version 2>&1
            if ($LASTEXITCODE -eq 0) {
                $PythonCmd = $cmd
                Write-Host "  [OK] Hittade Python: $version" -ForegroundColor Green
                break
            }
        }
        catch {
            # Continue to next command
        }
    }

    if (-not $PythonCmd) {
        throw "Python hittades inte. Installera Python 3.8+ från python.org"
    }

    # --- [Step 2: Check Dependencies] ---------------------------------------
    Write-Host "`n[2/5] Kontrollerar Python-beroenden..." -ForegroundColor Yellow

    $pipList = & $PythonCmd -m pip list 2>&1
    $hasDocx = $pipList | Select-String "python-docx"

    if (-not $hasDocx) {
        Write-Host "  [INFO] python-docx saknas. Installerar beroenden..." -ForegroundColor Yellow

        if (Test-Path $RequirementsFile) {
            Write-Host "  [INFO] Kör: pip install -r requirements.txt" -ForegroundColor Cyan
            & $PythonCmd -m pip install -r $RequirementsFile

            if ($LASTEXITCODE -ne 0) {
                throw "Misslyckades att installera beroenden"
            }

            Write-Host "  [OK] Beroenden installerade" -ForegroundColor Green
        }
        else {
            throw "requirements.txt saknas: $RequirementsFile"
        }
    }
    else {
        Write-Host "  [OK] Alla beroenden installerade" -ForegroundColor Green
    }

    # --- [Step 3: Verify Script] --------------------------------------------
    Write-Host "`n[3/5] Verifierar Python-skript..." -ForegroundColor Yellow

    if (-not (Test-Path $PythonScript)) {
        throw "Python-skript saknas: $PythonScript"
    }

    Write-Host "  [OK] Python-skript hittat: $PythonScript" -ForegroundColor Green

    # --- [Step 4: Interactive Menu] -----------------------------------------
    Write-Host "`n[4/5] Välj körläge:" -ForegroundColor Yellow
    Write-Host "  1) Skapa dokument från JSON-konfiguration" -ForegroundColor White
    Write-Host "  2) Skapa enkelt dokument med titel" -ForegroundColor White
    Write-Host "  3) Visa hjälp (--help)" -ForegroundColor White
    Write-Host "  4) Öppna output-mapp i Utforskaren" -ForegroundColor White
    Write-Host "  5) Avsluta" -ForegroundColor White
    Write-Host ""

    $choice = Read-Host "Ange val (1-5)"

    # --- [Step 5: Execute Based on Choice] ----------------------------------
    Write-Host "`n[5/5] Kör Python-skript..." -ForegroundColor Yellow

    switch ($choice) {
        "1" {
            # From config
            Write-Host "`nTillgängliga konfigurationsfiler:" -ForegroundColor Cyan
            $configs = Get-ChildItem -Path $ConfigDir -Filter "*.json" -ErrorAction SilentlyContinue

            if ($configs.Count -eq 0) {
                Write-Host "  [INFO] Inga konfigurationsfiler hittades i: $ConfigDir" -ForegroundColor Yellow
                Write-Host "  [INFO] Skapar exempel-konfiguration..." -ForegroundColor Yellow

                # Create example config (will be done in next file)
                $exampleConfig = Join-Path $ConfigDir "example.json"
                Write-Host "  [INFO] Se: $exampleConfig" -ForegroundColor Cyan
                break
            }

            for ($i = 0; $i -lt $configs.Count; $i++) {
                Write-Host "  $($i+1)) $($configs[$i].Name)" -ForegroundColor White
            }

            $configChoice = Read-Host "`nVälj konfiguration (1-$($configs.Count))"
            $selectedConfig = $configs[[int]$configChoice - 1].FullName

            Write-Host "`n[EXEC] & $PythonCmd `"$PythonScript`" --config `"$selectedConfig`"" -ForegroundColor Cyan
            & $PythonCmd $PythonScript --config $selectedConfig
        }

        "2" {
            # Simple document
            $title = Read-Host "`nAnge dokumenttitel"
            $filename = Read-Host "Ange filnamn (utan .docx)"

            if (-not $filename.EndsWith(".docx")) {
                $filename += ".docx"
            }

            Write-Host "`n[EXEC] & $PythonCmd `"$PythonScript`" --output `"$filename`" --title `"$title`"" -ForegroundColor Cyan
            & $PythonCmd $PythonScript --output $filename --title $title
        }

        "3" {
            # Help
            Write-Host "`n[EXEC] & $PythonCmd `"$PythonScript`" --help" -ForegroundColor Cyan
            & $PythonCmd $PythonScript --help
        }

        "4" {
            # Open output folder
            Write-Host "`n[INFO] Öppnar output-mapp i Utforskaren..." -ForegroundColor Cyan
            Start-Process explorer.exe -ArgumentList $OutputDir
        }

        "5" {
            Write-Host "`n[INFO] Avslutar..." -ForegroundColor Yellow
            break
        }

        default {
            Write-Host "`n[WARNING] Ogiltigt val: $choice" -ForegroundColor Yellow
        }
    }

    # --- [Completion] -------------------------------------------------------
    if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
        Write-Host "`n[SUCCESS] Körning slutförd!" -ForegroundColor Green
        Write-Host "[LOG] Loggfil: $LogFile" -ForegroundColor Cyan
        Write-Host "[OUTPUT] Dokument finns i: $OutputDir" -ForegroundColor Cyan
    }
    else {
        Write-Host "`n[ERROR] Python-skriptet returnerade felkod: $LASTEXITCODE" -ForegroundColor Red
    }

}
catch {
    Write-Host "`n[ERROR] Ett fel uppstod:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host "`n[STACK]" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
    exit 1
}
finally {
    Stop-Transcript | Out-Null

    Write-Host "`n=================================================================="
    Write-Host "  Tryck på valfri tangent för att avsluta..."
    Write-Host "=================================================================="
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
