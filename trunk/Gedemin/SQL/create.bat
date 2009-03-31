
@echo off

if "%2"=="" goto CreateDefault

cr.bat %1 %2

goto End

:CreateDefault

cr.bat india k:\bases\gedemin\etalon.fdb

:End