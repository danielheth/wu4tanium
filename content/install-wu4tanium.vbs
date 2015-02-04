Option Explicit

Dim objShell,fso,file,files,folder,objEnv
Dim strTaniumDir,strPath,strCurrentDir
Dim intCopyResult,intMoveCount,intMaxMoveCount
Dim strGeoIPDllFile,strGeoIPDllFilePath

strTaniumDir = GetTaniumDir("Tools\WU")

Set objShell = CreateObject("WScript.shell")
strCurrentDir = Replace(WScript.ScriptFullName, WScript.ScriptName, "")

Set fso = CreateObject("Scripting.FileSystemObject")

'Remove older versions
If fso.FileExists(strTaniumDir&"wu4tanium.exe") Then fso.DeleteFile strTaniumDir&"wu4tanium.exe",True
If fso.FileExists(strTaniumDir&"Interop.WUApiLib.dll") Then fso.DeleteFile strTaniumDir&"Interop.WUApiLib.dll",True

WScript.Echo "Processing " & strCurrentDir & "wu4tanium.zip"
GUnzip strCurrentDir&"wu4tanium.zip", strTaniumDir






	
Sub GUnzip(strGZipFilePath, strTargetDir)
' Takes full file path to Gzip file (not tarball), path to target directory
' will extract to target directory as a subdirectory 
' overwriting anything in the subdirectory and showing no UI.

	Dim objShell, objFSO, strCurrentDir, strZipUtil
	Dim strTempDir, strGZipFileName, strCommand, intResult
    
    Set objShell = WScript.CreateObject("WScript.Shell")
    Set objFSO = CreateObject("Scripting.FileSystemObject")

	strCurrentDir = Replace(WScript.ScriptFullName, WScript.ScriptName, "")
    
    If Not objFSO.FileExists(strGZipFilePath) Then
    	WScript.Echo "Error - Cannnot successfully complete install - " & strGZipFilePath & " does not exist"
    	Exit Sub
    End If
    
    strZipUtil = strCurrentDir & "7za.exe"
    
    If Not objFSO.FileExists(strZipUtil) Then 
    	WScript.Echo "Cannot continue - " & strZipUtil & " does not exist"
    	Exit Sub
    End If
    
    If Not objFSO.FolderExists(strTargetDir) Then
    	objFSO.CreateFolder(strTargetDir)
    End If
    
	strGZipFileName = objFSO.GetFile(strGZipFilePath).Name
	

	strCommand = Chr(34) & strZipUtil & Chr(34) & " x -y -o" & Chr(34) & strTargetDir & Chr(34) & " " & Chr(34) & strGZipFilePath & Chr(34)

	WScript.Echo "running unzip:"
	WScript.Echo "   command: " & strCommand
			
	objShell.Run strCommand, 0, True
End Sub 'GUnzip


Sub GUnzipFile(strGZipFilePath, strTargetDir)
' Takes full file path to .gz file, path to target directory
' will extract to target directory as a subdirectory 
' overwriting anything in the subdirectory and showing no UI.

	Dim objShell, objFSO, strCurrentDir, strZipUtil
	Dim strTargetFile, strGZipFileName, strCommand, intResult
    
    Set objShell = WScript.CreateObject("WScript.Shell")
    Set objFSO = CreateObject("Scripting.FileSystemObject")

	strCurrentDir = Replace(WScript.ScriptFullName, WScript.ScriptName, "")
    
    If Not objFSO.FileExists(strGZipFilePath) Then
    	WScript.Echo "Cannot continue - " & strGZipFilePath & " does not exist"
    	Exit Sub
    End If
    
    strZipUtil = strCurrentDir & "7za.exe"
    
    If Not objFSO.FileExists(strZipUtil) Then 
    	WScript.Echo "Cannot continue - " & strZipUtil & " does not exist"
    	Exit Sub
    End If
    
    If Not objFSO.FolderExists(strTargetDir) Then
    	objFSO.CreateFolder(strTargetDir)
    End If
    
	strGZipFileName = objFSO.GetFile(strGZipFilePath).Name
	' remove .gz from end
	If InStr(LCase(strGZipFileName),".gz") = Len(strGZipFileName) - 2 Then ' ends in gz
		strGZipFileName = Left(strGZipFileName,Len(strGZipFileName) - 3)
	End If
	
    strTargetFile = strCurrentDir & strGZipFileName

	strCommand = Chr(34) & strZipUtil & Chr(34) & " x -y -o" & Chr(34) & "." & Chr(34) & " " & Chr(34) & strGZipFilePath & Chr(34)

	WScript.Echo "running unzip:"
	WScript.Echo "   command: " & strCommand
			
	objShell.Run strCommand, 0, True

    If objFSO.FileExists(strTargetFile) Then
    	On Error Resume Next
    	intResult = objFSO.CopyFile(strTargetFile,strTargetDir,True) ' overwrite
    	On Error Goto 0
    	If intResult = 0 Then
    		WScript.Echo "Success"
    	Else
    		WScript.Echo "Failure - result is " & intResult
    	End If
    End If
End Sub 'GUnzipFile


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
End Function 'GeneratePath