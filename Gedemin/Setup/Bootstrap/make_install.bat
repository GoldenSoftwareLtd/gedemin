
@echo off
setlocal

if [%6]==[] goto :noparam

goto :proceed

:noparam

echo ******************************************************************************
echo **                                                                          **
echo **  �� 㪠���� ��ࠬ����                                                    **
echo **                                                                          **
echo **  make_install FSFN DBN SFN IFN AFN TFN B                                 **
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
echo **    "\\alex2006\\GoldSoft\Gedymin\Local\���⥦�� ���㬥���\setup.exe" N  **
echo **                                                                          **
echo ******************************************************************************

goto exit

:proceed

eventcreate /t INFORMATION /id 200 /l application /so gedemin /d "Start making install %4."

echo *************************************************
echo **                                             **
echo **  ���樠�����㥬 �������� ��६����       **
echo **                                             **
echo *************************************************

set path=c:\program files\StarBase\StarTeam 5.3
set path=%path%;c:\program files\yaffil\bin;c:\program files\yaffil\client
set path=%path%;C:\Program Files\WinRar
set path=%path%;C:\Program Files\Inno Setup 5
set path=%path%;c:\windows;c:\windows\system32;c:\windows\System32\Wbem

set gedemin_path=d:\golden\gedemin
set install_source_path=d:\golden\gedemin_local

echo *************************************************
echo **                                             **
echo **  ������� �⠫����� ��                       **
echo **                                             **
echo *************************************************

d:
cd \golden\gedemin\sql
call create.bat localhost %install_source_path%\database\%2.fdb
if not errorlevel 0 Error

echo *************************************************
echo **                                             **
echo **  ����㦠�� ����� ����஥�                   **
echo **                                             **
echo *************************************************

set params=/sn localhost:%install_source_path%\database\%2.fdb /user Administrator /password Administrator /sp d:\golden\setting /rd
z:\gedemin.exe %params% /sfn %1 /ns

echo *************************************************
echo **                                             **
echo **  ������� ��� ����                         **
echo **                                             **
echo *************************************************

del %install_source_path%\database\%2.bk > nul
gbak -b localhost:%install_source_path%\database\%2.fdb %install_source_path%\database\%2.bk -user SYSDBA -pas masterkey
if not errorlevel 0 goto Error

echo *************************************************
echo **                                             **
echo **  ������ ���⮫���                          **
echo **                                             **
echo *************************************************

copy %gedemin_path%\images\splash\%3 %install_source_path%\gedemin.jpg /Y

set setup_path=D:\Golden\gedemin\Setup\InnoSetup
iscc.exe "%setup_path%\%4.iss" /od:\temp\setup\ /fsetup /q
if not errorlevel 0 goto Error

copy d:\temp\setup\setup.exe %6 /Y

rem winrar m -m5 %5 setup.exe
rem ftp -s:d:\ftp_commands.txt gsbelarus.com

eventcreate /t INFORMATION /id 201 /l application /so gedemin /d "End making install %4."

goto Exit

:Error

eventcreate /t error /id 102 /l application /so gedemin /d "Error while making install %4."

echo *************************************************
echo **                                             **
echo **  �ந��諠 �訡��!                          **
echo **                                             **
echo *************************************************

exit /b 1

:exit

endlocal