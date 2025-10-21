@echo off
chcp 65001 > nul
cd /d "%~dp0"
echo.
echo ========================================
echo YouTube Downloader v8.0
echo ========================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0YouTube_Downloader_v8_INTERACTIVE.ps1"
echo.
pause
