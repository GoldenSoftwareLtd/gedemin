
@echo off
setlocal

echo *************************************************
echo **                                             **
echo **  ���樠�����㥬 �������� ��६����       **
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
echo **  ���㦠�� ����ன�� �� StarTeam            **
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
echo **  ��������㥬 gedemin.exe                    **
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
echo **  ��⨬����㥬 gedemin.exe                   **
echo **                                             **
echo *************************************************

z:
cd \
stripreloc gedemin.exe
if not errorlevel 0 goto Error

echo *************************************************
echo **                                             **
echo **  �����㥬 gedemin.exe                       **
echo **                                             **
echo *************************************************

copy gedemin.exe %install_source_path%\gedemin.exe /Y

echo *************************************************
echo **                                             **
echo **  ������ ���⮫�樨                          **
echo **                                             **
echo *************************************************

echo %~dp0make_install.bat

call %~dp0make_install.bat "%setting_source_path%\����\���� � ����.gsf"                                         plat      doc.jpg     platlocal     plat_setup.rar  "%install_target_path%\���⥦�� ���㬥���\setup.exe" 
call %~dp0make_install.bat "%setting_source_path%\��騥\��騥 �����.gsf"                                        devel     complex.jpg devellocal    devel_setup.rar "%install_target_path%\���ࠡ��稪\setup.exe" 
call %~dp0make_install.bat "%setting_source_path%\��騥\�������᭠�_��⮬�⨧���.gsf"                           business  complex.jpg businesslocal compl_setup.rar "%install_target_path%\�������᭠� ��⮬�⨧���\setup.exe" 
call %~dp0make_install.bat "%setting_source_path%\�।�ਭ���⥫�\����室��\�।�ਭ���⥫�_����室��.gsf"     ip        ip.jpg      iplocal       ip_setup.rar    "%install_target_path%\�।�ਭ���⥫�\setup.exe" 
call %~dp0make_install.bat "%setting_source_path%\�।�ਭ���⥫�\����� �����\�।�ਭ���⥫�_�����_�����.gsf" ip        ip.jpg      iplocal       ip_setup_ed.rar "%install_target_path%\�।�ਭ���⥫�\setup_ed.exe" 

if not errorlevel 0 goto Error

goto Exit

:Error

echo *************************************************
echo **                                             **
echo **  �ந��諠 �訡��!                          **
echo **                                             **
echo *************************************************

set exit_code=200
set exit_message="Unknown error"

goto Exit

:Exit

if not %exit_code%==0 eventcreate /t error /id %exit_code% /l application /so gedemin /d %exit_message%
if not %exit_code%==0 exit /b %exit_code%

endlocal