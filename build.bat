set msBuildDir=%WINDIR%\Microsoft.NET\Framework\v4.0.30319
call %msBuildDir%\msbuild.exe  wu4tanium.sln /p:Configuration=Release /l:FileLogger,Microsoft.Build.Engine;logfile=Manual_MSBuild_ReleaseVersion_LOG.log
set msBuildDir=




::ONLY SIGN IF THE CERT IS AVAILABLE
if exist "C:\SignCert\MoranIT.pfx" (
	"C:\Program Files\Microsoft SDKs\Windows\v7.1\Bin\signtool.exe" sign /f "C:\SignCert\MoranIT.pfx" /p "%SIGNINGPASSWORD%" /t "http://timestamp.verisign.com/scripts/timestamp.dll" "%WORKSPACE%\wu4tanium\bin\Release\wu4tanium.exe"
) else (
	echo Skipping signing since we're not on build server.
)


pushd %WORKSPACE%\wu4tanium\bin\Release\
7za.exe a -tzip wu4tanium.zip wu4tanium.exe Interop.WUApiLib.dll
pushd %WORKSPACE%\

