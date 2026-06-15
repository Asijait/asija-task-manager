Set WinScriptHost = CreateObject("WScript.Shell")
Set FileSystem = CreateObject("Scripting.FileSystemObject")
ScriptDir = FileSystem.GetParentFolderName(WScript.ScriptFullName)
WinScriptHost.CurrentDirectory = ScriptDir
Command = "%ComSpec% /c " & Chr(34) & ScriptDir & "\Z_run_newapp.bat" & Chr(34)
WinScriptHost.Run Command, 0, False
WScript.Sleep 5000
WinScriptHost.Run "%ComSpec% /c start """" ""http://127.0.0.1:5001""", 0, False
Set FileSystem = Nothing
Set WinScriptHost = Nothing
