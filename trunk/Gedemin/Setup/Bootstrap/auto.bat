
@echo off
setlocal

echo *************************************************
echo **                                             **
echo **  Инициализируем глобальные переменные       **
echo **                                             **
echo *************************************************

set path=c:\program files\StarBase\StarTeam 5.3
set path=%path%;c:\program files\Firebird 2.5\bin
set path=%path%;c:\Program Files\Borland\Delphi5\Bin
set path=%path%;C:\Program Files\WinRar
set path=%path%;c:\windows;c:\windows\system32;c:\windows\System32\Wbem

set gedemin_path=..\..
set install_source_path=..\..\..\gedemin_local
set setting_source_path=..\..\..\setting
set install_target_path=g:\Distrib2\GoldSoft\Gedymin\Local

set starteam_connect=Andreik:1@india:49201

set exit_code=0
set exit_message=0

goto CompileGedemin

echo *************************************************
echo **                                             **
echo **  Выгружаем настройки из StarTeam            **
echo **                                             **
echo *************************************************

stcmd co -p "%starteam_connect%/Setting" -is -x -stop -f NCO -nologo -q
stcmd co -p "%starteam_connect%/Comp5"   -is -x -stop -f NCO -nologo -q
stcmd co -p "%starteam_connect%/Gedemin" -is -x -stop -f NCO -nologo -q

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


dcc32 -b %gedemin_path%\gedemin\gedemin.dpr 

if errorlevel 0 goto OptimizeGedemin

set exit_code=101
set exit_message="Can not compile gedemin.exe"
goto Exit

:OptimizeGedemin

pause

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

call %~dp0make_install.bat "%setting_source_path%\Банк\Банк и касса.gsf"                                         plat      doc.jpg     platlocal     plat_setup.rar  "%install_target_path%\Платежные документы\setup.exe" 
call %~dp0make_install.bat "%setting_source_path%\Общие\Общие данные.gsf"                                        devel     complex.jpg devellocal    devel_setup.rar "%install_target_path%\Разработчик\setup.exe" 
call %~dp0make_install.bat "%setting_source_path%\Общие\Комплексная_автоматизация.gsf"                           business  complex.jpg businesslocal compl_setup.rar "%install_target_path%\Комплексная автоматизация\setup.exe" 
call %~dp0make_install.bat "%setting_source_path%\Предприниматель\Подоходный\Предприниматель_подоходный.gsf"     ip        ip.jpg      iplocal       ip_setup.rar    "%install_target_path%\Предприниматель\setup.exe" 
call %~dp0make_install.bat "%setting_source_path%\Предприниматель\Единый налог\Предприниматель_единый_налог.gsf" ip        ip.jpg      iplocal       ip_setup_ed.rar "%install_target_path%\Предприниматель\setup_ed.exe" 

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