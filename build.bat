set msBuildDir=%WINDIR%\Microsoft.NET\Framework\v4.0.30319
call %msBuildDir%\msbuild.exe  wu4tanium.sln /p:Configuration=Release /l:FileLogger,Microsoft.Build.Engine;logfile=Manual_MSBuild_ReleaseVersion_LOG.log
set msBuildDir=

pushd wu4tanium\bin\Release\
7za.exe a -tzip wu4tanium.zip wu4tanium.exe Interop.WUApiLib.dll
cd ../../../