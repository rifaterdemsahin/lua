@echo off
set "LOGFILE=%~dp0alt_w_s_enter.log"

echo ============================================== >> "%LOGFILE%"
echo [%date% %time%] BAT started >> "%LOGFILE%"
echo Working directory: %~dp0 >> "%LOGFILE%"
echo Script path: %~dp0alt_w_s_enter.ps1 >> "%LOGFILE%"

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0alt_w_s_enter.ps1" >> "%LOGFILE%" 2>&1

if %ERRORLEVEL% NEQ 0 (
    echo [%date% %time%] ERROR: PowerShell exited with code %ERRORLEVEL% >> "%LOGFILE%"
) else (
    echo [%date% %time%] SUCCESS: PowerShell exited with code 0 >> "%LOGFILE%"
)
echo ============================================== >> "%LOGFILE%"
