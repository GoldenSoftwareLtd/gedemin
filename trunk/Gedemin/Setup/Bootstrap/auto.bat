
@echo off
setlocal

echo *************************************************
echo **                                             **
echo **  Инициализируем глобальные переменные       **
echo **                                             **
echo *************************************************

if not exist d:\nul subst d: g:\
if not exist z:\nul subst z: g:\

set path=c:\program files\StarBase\StarTeam 5.3
set path=%path%;c:\program files\yaffil\bin;c:\program files\yaffil\client
set path=%path%;c:\Program Files\Borland\Delphi5\Bin
set path=%path%;C:\Program Files\WinRar
set path=%path%;c:\windows;c:\windows\system32;c:\windows\System32\Wbem

set gedemin_path=d:\golden\gedemin
set install_source_path=d:\golden\gedemin_local
set exit_code=0
set exit_message=0

echo *************************************************
echo **                                             **
echo **  Выгружаем настройки из StarTeam            **
echo **                                             **
echo *************************************************

stcmd co -p "Andreik:1@india:49201/Setting" -is -x -stop -f NCO -nologo -q
stcmd co -p "Andreik:1@india:49201/Comp5"   -is -x -stop -f NCO -nologo -q
stcmd co -p "Andreik:1@india:49201/Gedemin" -is -x -stop -f NCO -nologo -q

if errorlevel 0 goto CompileGedemin

set exit_code=100
set exit_message="Error while checking out files"
goto Exit

:CompileGedemin

echo *************************************************
echo **                                             **
echo **  Компилируем gedemin.exe                    **
echo **                                             **
echo *************************************************

if exist z:\gedemin.bak del z:\gedemin.bak
if exist z:\gedemin.exe ren z:\gedemin.exe *.bak
start delphi32 %gedemin_path%\gedemin\gedemin.dpr -b -ns 
timeout 60
taskkill /im delphi32.exe /f > nul

if exist z:\gedemin.exe goto OptimizeGedemin
if exist z:\gedemin.bak ren z:\gedemin.bak *.exe
if exist z:\gedemin.exe goto OptimizeGedemin

set exit_code=101
set exit_message="Can not compile gedemin.exe"
goto Exit

:OptimizeGedemin

echo *************************************************
echo **                                             **
echo **  Оптимизируем gedemin.exe                   **
echo **                                             **
echo *************************************************

z:
cd \
stripreloc gedemin.exe
if not errorlevel 0 goto Error

echo *************************************************
echo **                                             **
echo **  Копируем gedemin.exe                       **
echo **                                             **
echo *************************************************

copy gedemin.exe %install_source_path%\gedemin.exe /Y

echo *************************************************
echo **                                             **
echo **  Делаем инстоляции                          **
echo **                                             **
echo *************************************************

echo %~dp0make_install.bat

call %~dp0make_install.bat "d:\golden\setting\Банк\Банк и касса.gsf"                                         plat      doc.jpg     platlocal     plat_setup.rar  "g:\Distrib2\GoldSoft\Gedymin\Local\Платежные документы\setup.exe" 
call %~dp0make_install.bat "d:\golden\setting\Общие\Общие данные.gsf"                                        devel     complex.jpg devellocal    devel_setup.rar "g:\Distrib2\GoldSoft\Gedymin\Local\Разработчик\setup.exe" 
call %~dp0make_install.bat "d:\golden\setting\Общие\Комплексная_автоматизация.gsf"                           business  complex.jpg businesslocal compl_setup.rar "g:\Distrib2\GoldSoft\Gedymin\Local\Комплексная автоматизация\setup.exe" 
call %~dp0make_install.bat "d:\golden\setting\Предприниматель\Подоходный\Предприниматель_подоходный.gsf"     ip        ip.jpg      iplocal       ip_setup.rar    "g:\Distrib2\GoldSoft\Gedymin\Local\Предприниматель\setup.exe" 
call %~dp0make_install.bat "d:\golden\setting\Предприниматель\Единый налог\Предприниматель_единый_налог.gsf" ip        ip.jpg      iplocal       ip_setup_ed.rar "g:\Distrib2\GoldSoft\Gedymin\Local\Предприниматель\setup_ed.exe" 

if not errorlevel 0 goto Error

goto Exit

:Error

echo *************************************************
echo **                                             **
echo **  Произошла ошибка!                          **
echo **                                             **
echo *************************************************

set exit_code=200
set exit_message="Unknown error"

goto Exit

:Exit

if not %exit_code%==0 eventcreate /t error /id %exit_code% /l application /so gedemin /d %exit_message%
if not %exit_code%==0 exit /b %exit_code%

endlocal