param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]] $AppNames
)

# MainWindowHandle includes minimized windows, but excludes background helpers
# and tray-only processes left behind after the last editor window closes.
try {
    $names = @($AppNames | ForEach-Object { [IO.Path]::GetFileNameWithoutExtension($_) })
    $sessionId = (Get-Process -Id $PID -ErrorAction Stop).SessionId
    $openApps = @(Get-Process -ErrorAction Stop | Where-Object {
        $_.SessionId -eq $sessionId -and
        $_.ProcessName -in $names -and
        $_.MainWindowHandle -ne [IntPtr]::Zero
    } | Where-Object {
        # IDLE shares pythonw.exe with unrelated Python GUI programs.
        if ($_.ProcessName -eq 'pythonw') {
            $command = (Get-CimInstance Win32_Process -Filter "ProcessId=$($_.Id)" -ErrorAction Stop).CommandLine
            $command -match '(?i)([\\/]idlelib[\\/]|-m\s+idlelib\b)'
        } else {
            $true
        }
    })
    if ($openApps.Count -gt 0) { exit 0 }
    exit 1
} catch {
    Write-Error $_
    exit 2
}
