$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$detector = Join-Path $root 'src\check-coding-windows.ps1'
$ps = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
$exe = Join-Path ([IO.Path]::GetTempPath()) ('Monitor Window Fixture ' + [guid]::NewGuid().ToString('N') + '.exe')
$fixture = $null
try {
    & "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\csc.exe" /nologo /target:winexe /reference:System.Windows.Forms.dll "/out:$exe" "$PSScriptRoot\WindowFixture.cs"
    if ($LASTEXITCODE -ne 0) { throw 'Could not compile window fixture' }
    $fixture = Start-Process -FilePath $exe -WindowStyle Hidden -PassThru
    Start-Sleep -Seconds 2
    & $ps -NoProfile -ExecutionPolicy Bypass -File $detector ([IO.Path]::GetFileName($exe))
    if ($LASTEXITCODE -ne 0) { throw 'Open window not detected' }
    'PASS: open window, including spaces in executable name'
    Start-Sleep -Seconds 5
    & $ps -NoProfile -ExecutionPolicy Bypass -File $detector ([IO.Path]::GetFileName($exe))
    if ($LASTEXITCODE -ne 0) { throw 'Minimized window not detected' }
    'PASS: minimized window counts'
    Start-Sleep -Seconds 5
    & $ps -NoProfile -ExecutionPolicy Bypass -File $detector ([IO.Path]::GetFileName($exe))
    if ($LASTEXITCODE -ne 1 -or $fixture.HasExited) { throw 'Background-only process must not count' }
    'PASS: process surviving its closed window does not count'
} finally {
    if ($fixture -and -not $fixture.HasExited) { Stop-Process -Id $fixture.Id -Force }
    if (Test-Path -LiteralPath $exe) { Remove-Item -LiteralPath $exe -Force }
}
