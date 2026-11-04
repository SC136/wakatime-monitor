# Adds a Startup shortcut so the monitor runs hidden at every Windows login.
$root = Split-Path $PSScriptRoot -Parent
$src = Join-Path $root 'src'
$lnk = Join-Path ([Environment]::GetFolderPath('Startup')) 'WakaTime Monitor.lnk'
$s = (New-Object -ComObject WScript.Shell).CreateShortcut($lnk)
$s.TargetPath = "$env:SystemRoot\System32\wscript.exe"
$s.Arguments = "`"$src\start-hidden.vbs`""
$s.WorkingDirectory = $src
$s.Save()
"Installed: $lnk"
