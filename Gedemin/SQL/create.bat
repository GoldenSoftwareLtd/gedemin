
@echo off

if "%2"=="" goto CreateDefault

cr.bat %1 %2

if errorlevel 0 goto End

exit /b 1

:CreateDefault

cr.bat india k:\bases\gedemin\etalon.fdb

if errorlevel 0 goto End

exit /b 1

:End