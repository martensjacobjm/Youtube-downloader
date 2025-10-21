@echo off
REM YouTube Downloader GUI Launcher
REM Startar Windows Forms GUI

echo ========================================
echo   YouTube Downloader GUI
echo ========================================
echo.
echo Startar grafiskt granssnitt...
echo.

REM Kör PowerShell GUI-skriptet
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\YouTube_Downloader_GUI.ps1"

if errorlevel 1 (
    echo.
    echo FEL: Kunde inte starta GUI!
    echo Kontrollera att filen finns: scripts\YouTube_Downloader_GUI.ps1
    echo.
    pause
)
