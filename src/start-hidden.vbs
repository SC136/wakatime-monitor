' Runs the WakaTime monitor with no visible window. Skips if one is already running.
Set fso = CreateObject("Scripting.FileSystemObject")
srcDir = fso.GetParentFolderName(WScript.ScriptFullName)
rootDir = fso.GetParentFolderName(srcDir)

Set wmi = GetObject("winmgmts:\\.\root\cimv2")
Set procs = wmi.ExecQuery("SELECT CommandLine FROM Win32_Process WHERE Name = 'cmd.exe'")
For Each p In procs
    If Not IsNull(p.CommandLine) Then
        If InStr(p.CommandLine, "wakatime-monitor.bat") > 0 Then WScript.Quit
    End If
Next

If Not fso.FolderExists(rootDir & "\logs") Then fso.CreateFolder(rootDir & "\logs")

Set sh = CreateObject("WScript.Shell")
sh.CurrentDirectory = srcDir
sh.Run "cmd.exe /d /c ""wakatime-monitor.bat > ..\logs\monitor.log 2>&1""", 0, False
