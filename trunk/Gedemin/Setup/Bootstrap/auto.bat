
@echo off
setlocal

set exit_code=0
set exit_message=0

if not [%1]==[] goto InitVars

echo *************************************************
echo **                                             **
echo **  Auto:                                      **
echo **  Использование: auto.bat /ftp или /no_ftp   **
echo **                                             **
echo *************************************************

goto Exit

:InitVars

echo *************************************************
echo **                                             **
echo **  Auto:                                      **
echo **  Инициализируем глобальные переменные       **
echo **                                             **
echo *************************************************

@set path=c:\program files\firebird 2.5\bin
@set path=%path%;C:\Program Files\Borland\Delphi5\Bin
rem set path=%path%;c:\program files\StarBase\StarTeam 5.3
@set path=%path%;c:\windows;c:\windows\system32;c:\windows\System32\Wbem

@set gedemin_path=..\..
@set install_source_path=..\..\..\gedemin_local_fb
@set setting_source_path=%~d0\golden\setting
rem set install_target_path=\Distrib2\GoldSoft\Gedymin\Local
@set install_target_path=\Distrib2\GoldSoft\Gedymin\Local

set send_ftp=%1

echo *************************************************
echo **                                             **
echo **  Auto:                                      **
echo **  Выгружаем настройки из StarTeam            **
echo **                                             **
echo *************************************************

set starteam_path=c:\program files\StarBase\StarTeam 5.3
set starteam_connect=Andreik:1@india:49201

"%starteam_path%\stcmd.exe" co -p "%starteam_connect%/Setting" -is -x -stop -f NCO -nologo -q
if errorlevel 0 goto CompileGedemin

set exit_code=100
set exit_message="Error while checking out files"
goto Exit

:CompileGedemin

echo *************************************************
echo **                                             **
echo **  Auto:                                      **
echo **  Компилируем gedemin.exe                    **
echo **                                             **
echo *************************************************

cd ..\..\exe
call update_gedemin.bat /no_ftp /p
cd ..\setup\bootstrap

if not errorlevel 0 goto Error

echo *************************************************
echo **                                             **
echo **  Auto:                                      **
echo **  Копируем gedemin.exe                       **
echo **                                             **
echo *************************************************

@copy ..\..\exe\gedemin.exe %install_source_path%\gedemin.exe /Y
if not errorlevel 0 goto Error
@copy ..\..\exe\gedemin_upd.exe %install_source_path%\gedemin_upd.exe /Y
if not errorlevel 0 goto Error
@copy ..\..\exe\udf\gudf.dll %install_source_path%\udf\gudf.dll /Y
if not errorlevel 0 goto Error

echo *************************************************
echo **                                             **
echo **  Auto:                                      **
echo **  Делаем инстоляции                          **
echo **                                             **
echo *************************************************

call make_install.bat "%setting_source_path%\Общие\Общие данные.gsf"                                        devel     complex.jpg devellocal    devel_setup.rar "%install_target_path%\Разработчик\setup.exe"         %send_ftp%
call make_install.bat "%setting_source_path%\Банк\Банк и касса.gsf"                                         plat      doc.jpg     platlocal     plat_setup.rar  "%install_target_path%\Платежные документы\setup.exe" %send_ftp% 
call make_install.bat "%setting_source_path%\Общие\Комплексная_автоматизация.gsf"                           business  complex.jpg businesslocal compl_setup.rar "%install_target_path%\Комплексная автоматизация\setup.exe" %send_ftp%
call make_install.bat "%setting_source_path%\Предприниматель\Подоходный\Предприниматель_подоходный.gsf"     ip        ip.jpg      iplocal       ip_setup.rar    "%install_target_path%\Предприниматель\setup.exe" %send_ftp%
call make_install.bat "%setting_source_path%\Предприниматель\Единый налог\Предприниматель_единый_налог.gsf" ip        ip.jpg      iplocal       ip_setup_ed.rar "%install_target_path%\Предприниматель\setup_ed.exe" %send_ftp%
call make_install.bat "%setting_source_path%\Меню\2011 Бэк-офис\2011 Менюback.gsf"                          menuback     complex.jpg menubacklocal    menuback_setup.rar "%install_target_path%\Меню\setup_back.exe" %send_ftp%
call make_install.bat "%setting_source_path%\Меню\2011 Фронт-офис\2011  Menu front.gsf"                     menufront    complex.jpg menufrontlocal   menufront_setup.rar "%install_target_path%\Меню\setup_front.exe" %send_ftp%

if not errorlevel 0 goto Error

goto Exit

:Error

echo *************************************************
echo **                                             **
echo **  Auto:                                      **
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