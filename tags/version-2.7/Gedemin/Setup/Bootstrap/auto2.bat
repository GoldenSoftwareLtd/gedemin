
@echo off
setlocal

set exit_code=0
set exit_message=0

if not [%1]==[] goto InitVars

echo *************************************************
echo **                                             **
echo **  Auto:                                      **
echo **  �ᯮ�짮�����: auto2.bat /ftp ��� /no_ftp  **
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
@set path=%path%;c:\program files\git\cmd
@set path=%path%;C:\Program Files\Borland\Delphi5\Bin
@set path=%path%;c:\windows;c:\windows\system32;c:\windows\System32\Wbem

@set gedemin_path=..\..
@set install_source_path=..\..\..\gedemin_local_fb
@set setting_source_path=%~d0\golden\gedemin-apps
@set install_target_path=\Distrib2\GoldSoft\Gedymin\Local

set send_ftp=%1

echo *************************************************
echo **                                             **
echo **  Auto:                                      **
echo **  ���㦠�� ����࠭�⢠ ����                **
echo **                                             **
echo *************************************************

cd ..\..\..\gedemin-apps
git pull

if errorlevel 0 goto CompileGedemin

cd ..\gedemin\setup\bootstrap
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

cd ..\gedemin\exe
call update_gedemin.bat /no_ftp /p
cd ..\setup\bootstrap

if not errorlevel 0 goto Error

if not exist ..\..\exe\gedemin.exe goto Error

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

call make_install.bat "%setting_source_path%\����\���� � ����.yml"                                         plat      doc.jpg     platlocal     plat_setup.rar     "%install_target_path%\���⥦�� ���㬥���\setup.exe" %send_ftp% 
call make_install.bat "%setting_source_path%\��騥\�������᭠� ��⮬�⨧���.yml"                           business  complex.jpg businesslocal compl_setup.rar    "%install_target_path%\�������᭠� ��⮬�⨧���\setup.exe" %send_ftp%
rem goto exit
call make_install.bat "%setting_source_path%\�����筠� �࣮���\PositiveCash\GS.PositiveCash.yml"           cash      complex.jpg kkc_positive_cash    cash_setup.rar      "%install_target_path%\����\setup.exe" %send_ftp%
call make_install.bat "%setting_source_path%\��騥\��騥 �����.yml"                                        devel     complex.jpg devellocal    devel_setup.rar    "%install_target_path%\���ࠡ��稪\setup.exe"         %send_ftp%
call make_install.bat "%setting_source_path%\����\2014 ��-���\GS.��饯��.back.yml"                        menuback  complex.jpg menubacklocal menuback_setup.rar "%install_target_path%\����\setup_back.exe" %send_ftp%
call make_install.bat "%setting_source_path%\���⨭��\GS.���⨭��.yml"                                    hotel     doc.jpg     hotellocal    hotel_setup.rar    "%install_target_path%\���⨭��\setup.exe" %send_ftp% 
call make_install.bat "%setting_source_path%\�����਩\GS.�����਩.yml"                                    san       doc.jpg     sanlocal      san_setup.rar      "%install_target_path%\�����਩\setup.exe" %send_ftp% 
goto exit
call make_install.bat "%setting_source_path%\���\��� ��饥.gsf"                                             cash      complex.jpg kkc_positive_cash    cash_setup.rar      "%install_target_path%\����\setup.exe" %send_ftp%
call make_install.bat "%setting_source_path%\����\2013 Menu. front\2013 - Menu. Front.gsf"                  menufront complex.jpg kkc_positive_check   menufront_setup.rar "%install_target_path%\����\setup_front.exe" %send_ftp%
call make_install.bat "%setting_source_path%\�।�ਭ���⥫�\����室��\�।�ਭ���⥫�_����室��.gsf"     ip        ip.jpg      iplocal       ip_setup.rar       "%install_target_path%\�।�ਭ���⥫�\setup.exe" %send_ftp%
call make_install.bat "%setting_source_path%\�।�ਭ���⥫�\����� �����\�।�ਭ���⥫�_�����_�����.gsf" ip        ip.jpg      iplocal       ip_setup_ed.rar    "%install_target_path%\�।�ਭ���⥫�\setup_ed.exe" %send_ftp%

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