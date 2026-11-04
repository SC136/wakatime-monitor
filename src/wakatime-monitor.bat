@echo off
title Coding App Monitor - WakaTime Auto-Starter
color 0A
setlocal

REM Use full System32 paths: Git's usr\bin (find, timeout) can shadow the Windows tools on PATH
set "SYS=%SystemRoot%\System32"

echo.
echo =========================================
echo   Coding App Monitor for WakaTime
echo =========================================
echo.
echo Monitoring: VS Code, Zed, Claude, Qoder, Cursor, Trae, Kiro, Antigravity,
echo Freebuff, ZCode, Android Studio, Arduino IDE, Keil uVision, Visual Studio
echo.
echo When any opens -^> WakaTime starts
echo When all close -^> WakaTime stops
echo.
echo Press Ctrl+C to stop monitoring
echo.

set "WAKATIME_EXE=%LOCALAPPDATA%\Programs\desktop-wakatime\WakaTime.exe"

if not exist "%WAKATIME_EXE%" (
    echo ERROR: Cannot find WakaTime at: %WAKATIME_EXE%
    pause
    exit /b 1
)

echo WakaTime found at: %WAKATIME_EXE%
echo.

set "RUNNING=0"

REM Monitored apps (quoted because some names contain spaces)
set APPS="Code.exe" "Zed.exe" "Claude.exe" "Qoder.exe" "Cursor.exe" "Trae.exe" "Kiro.exe" "Antigravity.exe" "Antigravity IDE.exe" "Freebuff.exe" "ZCode.exe" "studio64.exe" "Arduino IDE.exe" "UV4.exe" "devenv.exe"

:loop
set "FOUND=0"
for %%P in (%APPS%) do (
    "%SYS%\tasklist.exe" /nh /fi "IMAGENAME eq %%P" 2>nul | "%SYS%\findstr.exe" /i /c:"%%~nP" >nul && set "FOUND=1"
)

if "%FOUND%"=="1" if "%RUNNING%"=="0" (
    echo [%date% %time%] Starting WakaTime...
    start "" "%WAKATIME_EXE%" >nul 2>&1
    set "RUNNING=1"
)
if "%FOUND%"=="0" if "%RUNNING%"=="1" (
    echo [%date% %time%] All apps closed - stopping WakaTime...
    "%SYS%\taskkill.exe" /IM "WakaTime.exe" /F >nul 2>&1
    set "RUNNING=0"
)

"%SYS%\ping.exe" -n 6 127.0.0.1 >nul
goto loop
