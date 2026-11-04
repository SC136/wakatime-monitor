@echo off
REM Stops the background monitor and WakaTime
powershell -NoProfile -Command "Get-CimInstance Win32_Process -Filter \"Name='cmd.exe'\" | Where-Object { $_.CommandLine -like '*wakatime-monitor.bat*' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }"
%SystemRoot%\System32\taskkill.exe /IM WakaTime.exe /F >nul 2>&1
echo Monitor stopped.
