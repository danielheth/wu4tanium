Option Explicit

If SetWorkingDirectory Then
	
	Dim objShell: Set objShell = WScript.CreateObject("WScript.shell")
	Dim vPath: vPath = GetTaniumDir("Tools\WU")
	Dim vCmd: vCmd = "cmd /c " + Chr(34) + vPath + "wu4tanium.exe" + Chr(34) + " status"

	Dim strText
	Dim objScriptExec: Set objScriptExec = objShell.Exec(vCmd)
	Do While Not objScriptExec.StdOut.AtEndOfStream
		strText = objScriptExec.StdOut.ReadLine()
    	Wscript.Echo strText    
	Loop

	Set objShell = Nothing
	
Else
	WScript.Echo("Missing Windows Update Tools")
End If

'==============================================
Function SetWorkingDirectory
	Dim vFileSystem: Set vFileSystem = CreateObject("Scripting.FileSystemObject")
	Dim vPath: vPath = GetTaniumDir("Tools\WU")
	Dim vShell: Set vShell = CreateObject("WScript.Shell")
	If vFileSystem.FileExists(vPath + "wu4tanium.exe") Then
		SetWorkingDirectory = True
	End If
End Function 'SetWorkingDirectory

Function ClientToolsRegValue(name)
	Dim vValue
	Dim vPath: vPath = "HKLM\" & GetTaniumRegistryPath & "\Client Tools\" & name
	Dim vShell: Set vShell = CreateObject("WScript.Shell")
	On Error Resume Next
	vValue = vShell.RegRead(vPath)
	On Error Goto 0
	If (vValue = "") Then: vValue = "[Not Available]"
	ClientToolsRegValue = vValue
End Function

Function QS(vText)
	QS = Chr(34) + vText + Chr(34)
End Function

Function WcToSl(vExpression)
	WcToSl = Replace(vExpression, "*", "%")
End Function

Function ClientToolsCommand(cmd)
	Dim vExec: Set vExec = vShell.Exec(cmd)
	Do While Not vExec.StdOut.AtEndOfStream
		WScript.Echo vExec.StdOut.ReadLine()
	Loop
End Function

Function GetTaniumRegistryPath
'GetTaniumRegistryPath works in x64 or x32
'looks for a valid Path value

    Dim objShell
    Dim keyNativePath, keyWoWPath, strPath, strFoundTaniumRegistryPath
      
    Set objShell = CreateObject("WScript.Shell")
    
    keyNativePath = "Software\Tanium\Tanium Client"
    keyWoWPath = "Software\Wow6432Node\Tanium\Tanium Client"
    
    ' first check the Software key (valid for 32-bit machines, or 64-bit machines in 32-bit mode)
    On Error Resume Next
    strPath = objShell.RegRead("HKLM\"&keyNativePath&"\Path")
    On Error Goto 0
    strFoundTaniumRegistryPath = keyNativePath
 
    If strPath = "" Then
        ' Could not find 32-bit mode path, checking Wow6432Node
        On Error Resume Next
        strPath = objShell.RegRead("HKLM\"&keyWoWPath&"\Path")
        On Error Goto 0
        strFoundTaniumRegistryPath = keyWoWPath
    End If
    
    If Not strPath = "" Then
        GetTaniumRegistryPath = strFoundTaniumRegistryPath
    Else
        GetTaniumRegistryPath = False
        WScript.Echo "Error: Cannot locate Tanium Registry Path"
    End If
End Function 'GetTaniumRegistryPath

Function GetTaniumDir(strSubDir)
'GetTaniumDir with GeneratePath, works in x64 or x32
'looks for a valid Path value
	
	Dim objShell
	Dim keyNativePath, keyWoWPath, strPath
	  
    Set objShell = CreateObject("WScript.Shell")
    
	keyNativePath = "HKLM\Software\Tanium\Tanium Client"
	keyWoWPath = "HKLM\Software\Wow6432Node\Tanium\Tanium Client"
    
    ' first check the Software key (valid for 32-bit machines, or 64-bit machines in 32-bit mode)
    On Error Resume Next
    strPath = objShell.RegRead(keyNativePath&"\Path")
    On Error Goto 0
 
  	If strPath = "" Then
  		' Could not find 32-bit mode path, checking Wow6432Node
  		On Error Resume Next
  		strPath = objShell.RegRead(keyWoWPath&"\Path")
  		On Error Goto 0
  	End If
  	
  	If Not strPath = "" Then
		If strSubDir <> "" Then
			strSubDir = "\" & strSubDir
		End If	
	
		Dim fso
		Set fso = WScript.CreateObject("Scripting.Filesystemobject")
		If fso.FolderExists(strPath) Then
			If Not fso.FolderExists(strPath & strSubDir) Then
				''Need to loop through strSubDir and create all sub directories
				GeneratePath strPath & strSubDir, fso
			End If
			GetTaniumDir = strPath & strSubDir & "\"
		Else
			' Specified Path doesn't exist on the filesystem
			WScript.Echo "Error: " & strPath & " does not exist on the filesystem"
			GetTaniumDir = False
		End If
	Else
		WScript.Echo "Error: Cannot find Tanium Client path in Registry"
		GetTaniumDir = False
	End If
End Function 'GetTaniumDir

Function GeneratePath(pFolderPath, fso)
	GeneratePath = False

	If Not fso.FolderExists(pFolderPath) Then
		If GeneratePath(fso.GetParentFolderName(pFolderPath), fso) Then
			GeneratePath = True
			Call fso.CreateFolder(pFolderPath)
		End If
	Else
		GeneratePath = True
	End If
End Function 'GeneratePath'==============================================
