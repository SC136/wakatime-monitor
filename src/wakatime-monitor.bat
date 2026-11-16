@echo off
title Coding App Monitor - WakaTime Auto-Starter
color 0A
setlocal

REM Use full System32 paths: Git's usr\bin (find, timeout) can shadow the Windows tools on PATH
set "SYS=%SystemRoot%\System32"

REM The script writes its log line by line instead of redirecting its own stdout.
REM A redirected handle is inherited by anything started with START, so WakaTime
REM would hold logs\monitor.log open for its whole lifetime and the next monitor
REM start would silently fail to write anything.
set "LOG=%~dp0..\logs\monitor.log"
if not exist "%~dp0..\logs" md "%~dp0..\logs" >nul 2>&1
>>"%LOG%" echo.

call :say =========================================
call :say   Coding App Monitor for WakaTime
call :say =========================================
call :blank
call :say Monitoring: VS Code, Zed, Claude, Qoder, Cursor, Trae, Kiro, Antigravity,
call :say Freebuff, ZCode, Android Studio, Arduino IDE, Keil uVision, Visual Studio
call :say ChatGPT/Codex, OpenCode, DeepSeek Harness, Context Hub, Orchestrator,
call :say Unity, Roblox Studio, Postman, MongoDB Compass, Python IDLE, PowerShell ISE
call :blank
call :say When any opens: WakaTime starts
call :say When all close: WakaTime stops
call :blank
call :say Press Ctrl+C to stop monitoring
call :blank

set "WAKATIME_EXE=%LOCALAPPDATA%\Programs\desktop-wakatime\WakaTime.exe"

if not exist "%WAKATIME_EXE%" (
    call :say ERROR: Cannot find WakaTime at: %WAKATIME_EXE%
    exit /b 1
)

call :say WakaTime found at: %WAKATIME_EXE%
call :blank

REM Monitored apps (quoted because some names contain spaces)
set APPS="Code.exe" "Zed.exe" "Claude.exe" "Qoder.exe" "Cursor.exe" "Trae.exe" "Kiro.exe" "Antigravity.exe" "Antigravity IDE.exe" "Freebuff.exe" "ZCode.exe" "studio64.exe" "Arduino IDE.exe" "UV4.exe" "devenv.exe" "ChatGPT.exe" "Codex.exe" "OpenCode.exe" "DeepSeek Harness.exe" "context-hub.exe" "agent-orchestrator.exe" "Unity.exe" "RobloxStudioBeta.exe" "Postman.exe" "MongoDBCompass.exe" "pythonw.exe" "powershell_ise.exe"

REM Cycles left before another start attempt, so a slow WakaTime startup is not
REM launched several times in a row.
set "COOLDOWN=0"

:loop
set "FOUND=0"
REM A process can outlive its editor window (for example Antigravity's sidecar).
REM Count actual editor windows, including minimized ones, in this session.
"%SYS%\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "%~dp0check-coding-windows.ps1" %APPS%
if errorlevel 2 (
    call :log ERROR: Could not check editor windows - retrying.
    goto wait
)
if not errorlevel 1 set "FOUND=1"

REM Ask Windows every cycle whether WakaTime is really running. A cached "already
REM started" flag goes stale as soon as WakaTime exits on its own (crash, update,
REM manual quit), and then it is never restarted while coding apps stay open.
set "ACTIVE=0"
"%SYS%\tasklist.exe" /nh /fi "IMAGENAME eq WakaTime.exe" 2>nul | "%SYS%\findstr.exe" /i /c:"WakaTime.exe" >nul && set "ACTIVE=1"

if "%FOUND%"=="1" if "%ACTIVE%"=="0" if "%COOLDOWN%"=="0" (
    call :log Starting WakaTime...
    REM Explorer starts WakaTime in the user's shell: it does not inherit this
    REM script's open handles or its job object, so WakaTime outlives the monitor.
    "%SystemRoot%\explorer.exe" "%WAKATIME_EXE%"
    set "COOLDOWN=2"
)
if not "%COOLDOWN%"=="0" set /a COOLDOWN-=1

if "%FOUND%"=="0" if "%ACTIVE%"=="1" (
    call :log All apps closed - stopping WakaTime...
    "%SYS%\taskkill.exe" /IM "WakaTime.exe" /F >nul 2>&1
)

:wait
"%SYS%\ping.exe" -n 6 127.0.0.1 >nul
goto loop

:blank
echo.
>>"%LOG%" echo.
exit /b

:say
echo %*
>>"%LOG%" echo %*
exit /b

:log
echo [%date% %time%] %*
>>"%LOG%" echo [%date% %time%] %*
exit /b
