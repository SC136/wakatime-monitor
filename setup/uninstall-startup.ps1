# Removes the Startup shortcut (auto-start at login).
$lnk = Join-Path ([Environment]::GetFolderPath('Startup')) 'WakaTime Monitor.lnk'
Remove-Item $lnk -ErrorAction SilentlyContinue
"Removed: $lnk"
