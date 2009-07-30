
@echo off
setlocal

if not [%7]==[] goto proceed

echo ******************************************************************************
echo **                                                                          **
echo **  �� 㪠���� ��ࠬ����                                                    **
echo **                                                                          **
echo **  make_install FSFN DBN SFN IFN AFN TFN /FTP|/NO_FTP                      **
echo **                                                                          **
echo **    FSFN -- ������ ��� 䠩�� � ����⮬ ����஥�                           **
echo **    DBN  -- ⮫쪮 ��� (��� ���७��) 䠩�� ��                          **
echo **    SFN  -- ��� 䠩�� ���⠢�� � ��⠫��� d:\golden\gedemin\images\splash **
echo **    IFN  -- ��� 䠩�� �஥�� ��⠭����, ��� ���७��                   **
echo **    AFN  -- ��� 䠩�� � ��娢�� ��⠭����                                 **
echo **    TFN  -- ��� 䠩�� � ��⠫��� ����ਡ�⨢� ��⠭����                   **
echo **                                                                          **
echo **  ���ਬ��:                                                               **
echo **    make_install "d:\golden\setting\a.gsf" plat doc.jpg _                 **
echo **    platlocal_wo_demo plat_setup.rar _                                    **
echo **    "\\alex2006\\GoldSoft\Gedymin\Local\���⥦�� ���㬥���\setup.exe"    **
echo **                                                                          **
echo ******************************************************************************

goto exit

:proceed

if NOT exist d:\nul subst d: g:\

eventcreate /t INFORMATION /id 200 /l application /so gedemin /d "Start making install %4."

echo *************************************************
echo **                                             **
echo **  ���樠�����㥬 �������� ��६����       **
echo **                                             **
echo *************************************************

set path=c:\program files\firebird 2.5\bin;c:\windows;c:\windows\system32;c:\windows\System32\Wbem

set inno_setup_path=C:\Program Files\Inno Setup 5
set fb_path=c:\program files\Firebird 2.5\bin
set install_source_path=..\..\..\gedemin_local_fb
set database_path=d:\golden\gedemin_local_fb\database
set winrar_path=C:\Program Files\WinRar
set setup_path=..\InnoSetup
set setting_path=d:\golden\setting

set server_name=localhost/3053

echo *************************************************
echo **                                             **
echo **  ������� �⠫����� ��                       **
echo **                                             **
echo *************************************************

cd ..\..\sql
call create.bat %server_name% %database_path%\%2.fdb
if not errorlevel 0 Error

cd ..\setup\bootstrap
if not errorlevel 0 Error

echo *************************************************
echo **                                             **
echo **  ����㦠�� ����� ����஥�                   **
echo **                                             **
echo *************************************************

set params=/sn "%server_name%:%database_path%\%2.fdb" /user Administrator /password Administrator /sp %setting_path% /rd /q
..\..\exe\gedemin.exe %params% /sfn "%~1" /ns
if not errorlevel 0 Error

echo *************************************************
echo **                                             **
echo **  ������� ��� ����                         **
echo **                                             **
echo *************************************************

del "%database_path%\%2.bk" > nul
"%fb_path%\gbak" -b "%server_name%:%database_path%\%2.fdb" "%database_path%\%2.bk" -user SYSDBA -pas masterkey
if not errorlevel 0 goto Error

del "%database_path%\%2.fdb" > nul
if not errorlevel 0 goto Error

echo *************************************************
echo **                                             **
echo **  ������ ���⮫���                          **
echo **                                             **
echo *************************************************

copy ..\..\images\splash\%3 "%install_source_path%\gedemin.jpg" /Y
"%inno_setup_path%\iscc.exe" "%setup_path%\%4.iss" "/o%~dp6" /fsetup /q
if not errorlevel 0 goto Error

"%winrar_path%\winrar" a -m5 "%~dp6\%5" "%~dp6\setup.exe"
if not errorlevel 0 goto Error

eventcreate /t INFORMATION /id 201 /l application /so gedemin /d "End making install %4."

if not [%7]==[/ftp] goto exit

echo *************************************************
echo **                                             **
echo **  Upload to ftp                              **
echo **                                             **
echo *************************************************

ftp -s:d:\ftp_commands.txt gsbelarus.com
if not errorlevel 0 goto Error

del "%~dp6\%5"
if not errorlevel 0 goto Error

goto Exit

:Error

eventcreate /t error /id 102 /l application /so gedemin /d "Error while making install %4."

echo *************************************************
echo **                                             **
echo **  �ந��諠 �訡��!                          **
echo **                                             **
echo *************************************************

exit /b 1

:Exit

endlocal