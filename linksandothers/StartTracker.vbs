Set WinScriptHost = CreateObject("WScript.Shell")
Set FileSystem = CreateObject("Scripting.FileSystemObject")
ScriptDir = FileSystem.GetParentFolderName(WScript.ScriptFullName)
WinScriptHost.Run Chr(34) & ScriptDir & "\run_newapp.bat" & Chr(34), 0
Set FileSystem = Nothing
Set WinScriptHost = Nothing
