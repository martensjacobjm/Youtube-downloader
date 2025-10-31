@echo off
chcp 65001 > nul
cd /d "%~dp0"
echo.
echo ========================================
echo YouTube Downloader v8.0
echo ========================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\YouTube_Downloader_v8_INTERACTIVE.ps1"
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ========================================
    echo FEL UPPSTOD! Se felmeddelandet ovan.
    echo ========================================
)
echo.
echo Tryck valfri tangent for att avsluta...
pause > nul
