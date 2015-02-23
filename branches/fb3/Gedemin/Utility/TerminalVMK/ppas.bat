@echo off
SET THEFILE=terminal
echo Assembling %THEFILE%
C:\lazarus\fpc\2.4.4\bin\i386-win32\arm-wince-as.exe -mfpu=softvfp -o C:\golden\terminal\lib\i386-win32\terminal.o C:\golden\terminal\lib\i386-win32\terminal.s
if errorlevel 1 goto asmend
Del C:\golden\terminal\lib\i386-win32\terminal.s
SET THEFILE=terminal.exe
echo Linking %THEFILE%
C:\lazarus\fpc\2.4.4\bin\i386-win32\arm-wince-ld.exe -m arm_wince_pe  --gc-sections   --subsystem wince --entry=_WinMainCRTStartup    -o terminal.exe link.res
if errorlevel 1 goto linkend
arm-wince-postw32.exe --subsystem gui --input terminal.exe --stack 262144
if errorlevel 1 goto linkend
goto end
:asmend
echo An error occured while assembling %THEFILE%
goto end
:linkend
echo An error occured while linking %THEFILE%
:end
