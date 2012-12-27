
@echo off
setlocal

set exit_code=0
set exit_message=0

if not [%1]==[] goto InitVars

echo *************************************************
echo **                                             **
echo **  Auto:                                      **
echo **  �ᯮ�짮�����: auto.bat /ftp ��� /no_ftp   **
echo **                                             **
echo *************************************************

goto Exit

:InitVars

echo *************************************************
echo **                                             **
echo **  Auto:                                      **
echo **  ���樠�����㥬 �������� ��६����       **
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
echo **  ���㦠�� ����ன�� �� StarTeam            **
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
echo **  ��������㥬 gedemin.exe                    **
echo **                                             **
echo *************************************************

cd ..\..\exe
call update_gedemin.bat /no_ftp /p
cd ..\setup\bootstrap

if not errorlevel 0 goto Error

echo *************************************************
echo **                                             **
echo **  Auto:                                      **
echo **  �����㥬 gedemin.exe                       **
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
echo **  ������ ���⮫�樨                          **
echo **                                             **
echo *************************************************

call make_install.bat "%setting_source_path%\��騥\��騥 �����.gsf"                                        devel     complex.jpg devellocal    devel_setup.rar "%install_target_path%\���ࠡ��稪\setup.exe"         %send_ftp%
call make_install.bat "%setting_source_path%\����\���� � ����.gsf"                                         plat      doc.jpg     platlocal     plat_setup.rar  "%install_target_path%\���⥦�� ���㬥���\setup.exe" %send_ftp% 
call make_install.bat "%setting_source_path%\��騥\�������᭠�_��⮬�⨧���.gsf"                           business  complex.jpg businesslocal compl_setup.rar "%install_target_path%\�������᭠� ��⮬�⨧���\setup.exe" %send_ftp%
call make_install.bat "%setting_source_path%\�।�ਭ���⥫�\����室��\�।�ਭ���⥫�_����室��.gsf"     ip        ip.jpg      iplocal       ip_setup.rar    "%install_target_path%\�।�ਭ���⥫�\setup.exe" %send_ftp%
call make_install.bat "%setting_source_path%\�।�ਭ���⥫�\����� �����\�।�ਭ���⥫�_�����_�����.gsf" ip        ip.jpg      iplocal       ip_setup_ed.rar "%install_target_path%\�।�ਭ���⥫�\setup_ed.exe" %send_ftp%
call make_install.bat "%setting_source_path%\����\2011 ��-���\2011 ����back.gsf"                          menuback     complex.jpg menubacklocal    menuback_setup.rar "%install_target_path%\����\setup_back.exe" %send_ftp%
call make_install.bat "%setting_source_path%\����\2011 �஭�-���\2011  Menu front.gsf"                     menufront    complex.jpg menufrontlocal   menufront_setup.rar "%install_target_path%\����\setup_front.exe" %send_ftp%

if not errorlevel 0 goto Error

goto Exit

:Error

echo *************************************************
echo **                                             **
echo **  Auto:                                      **
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