@echo off
REM ============================================================================
REM Word Document Generator - Batch Wrapper
REM Purpose: Launch PowerShell wrapper with execution policy bypass
REM Notes: For Windows users who prefer double-clicking BAT files
REM ============================================================================

echo Starting Word Document Generator...
echo.

REM Get script directory
set "SCRIPT_DIR=%~dp0"

REM Run PowerShell script with execution policy bypass
powershell.exe -ExecutionPolicy Bypass -NoProfile -File "%SCRIPT_DIR%RUN_WORD_GENERATOR.ps1"

REM Check exit code
if %ERRORLEVEL% neq 0 (
    echo.
    echo [ERROR] Script failed with exit code: %ERRORLEVEL%
    pause
    exit /b %ERRORLEVEL%
)

exit /b 0
