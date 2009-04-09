@echo off

SET DELPHIVERSION=%1

cd install

::jpp prototypes

..\devtools\jpp.exe -c -dVCL -dMSWINDOWS -uVisualCLX -uUnix -uKYLIX -xVclGui\ prototypes\JediGUIMain.pas
if ERRORLEVEL 1 goto FailedCompile
..\devtools\jpp.exe -c -dVCL -dMSWINDOWS -uVisualCLX -uUnix -uKYLIX -xVclGui\ prototypes\JediGUIReadme.pas
if ERRORLEVEL 1 goto FailedCompile
..\devtools\jpp.exe -c -dVCL -dMSWINDOWS -uVisualCLX -uUnix -uKYLIX -xVclGui\ prototypes\JediGUIInstall.pas
if ERRORLEVEL 1 goto FailedCompile


:: compile installer

build\dcc32ex.exe -q -w -dJCLINSTALL -E..\bin -I..\source -U..\source\common;..\source\windows JediInstaller.dpr
if ERRORLEVEL 1 goto FailedCompile


echo Launching JCL installer...

start ..\bin\JediInstaller.exe %2 %3 %4 %5 %6 %7 %8 %9
if ERRORLEVEL 1 goto FailStart
goto FINI

:FailStart
..\bin\JediInstaller.exe %2 %3 %4 %5 %6 %7 %8 %9
goto FINI

:FailedCompile
echo.
echo.
echo An error occured while compiling the installer. Installation aborted.
echo.
pause

:FINI
cd ..
SET DELPHIVERSION=
