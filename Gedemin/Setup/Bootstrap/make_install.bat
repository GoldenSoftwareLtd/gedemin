
@echo off
setlocal

if not [%7]==[] goto proceed

echo ******************************************************************************
echo **                                                                          **
echo **  �� 㪠���� ��ࠬ����                                                    **
echo **                                                                          **
echo **  make_install FSFN DBN SFN IFN AFN TFN /FTP ��� /NO_FTP EMAIL            **
echo **                                                                          **
echo **    FSFN -- ������ ��� 䠩�� � ����⮬ ����஥�                           **
echo **    DBN  -- ⮫쪮 ��� (��� ���७��) 䠩�� ��                          **
echo **    SFN  -- ��� 䠩�� ���⠢�� � ��⠫��� d:\golden\gedemin\images\splash **
echo **    IFN  -- ��� 䠩�� �஥�� ��⠭����, ��� ���७��                   **
echo **    AFN  -- ��� 䠩�� � ��娢�� ��⠭����                                 **
echo **    TFN  -- ��� 䠩�� � ��⠫��� ����ਡ�⨢� ��⠭����                   **
echo **    EMAIL-- ᯨ᮪ ���ᮢ, �१ �������
echo **                                                                          **
echo **  ���ਬ��:                                                               **
echo **    make_install "d:\golden\setting\a.gsf" plat doc.jpg _                 **
echo **    platlocal_wo_demo plat_setup.rar _                                    **
echo **    "\\alex2006\\GoldSoft\Gedymin\Local\���⥦�� ���㬥���\setup.exe"    **
echo **                                                                          **
echo ******************************************************************************

goto exit

:proceed

rem if NOT exist d:\nul subst d: k:\

eventcreate /t INFORMATION /id 200 /l application /so gedemin /d "Start making install %4."

echo *************************************************
echo **                                             **
echo **  make_install:                              **
echo **  ���樠�����㥬 �������� ��६����       **
echo **                                             **
echo *************************************************

@set path=c:\program files\firebird 2.5\bin;c:\windows;c:\windows\system32;c:\windows\System32\Wbem

@set inno_setup_path=C:\Program Files\Inno Setup 5
@set fb_path=c:\program files\Firebird 2.5\bin
@set install_source_path=..\..\..\gedemin_local_fb
@set database_path=k:\golden\gedemin_local_fb\database
@set winrar_path=C:\Program Files\WinRar
@set setup_path=..\InnoSetup
@set setting_path=%~d0\golden\gedemin-apps
if %~x1==.gsf set setting_path=%~d0\golden\setting

@set server_name=localhost/3053

echo *************************************************
echo **                                             **
echo **  make_install:                              **
echo **  ������� �⠫����� ��                       **
echo **                                             **
echo *************************************************

cd ..\..\sql
call create.bat %server_name% %database_path%\%2.fdb
if not errorlevel 0 goto Error

cd ..\setup\bootstrap
if not errorlevel 0 goto Error

echo *************************************************
echo **                                             **
echo **  make_install:                              **
echo **  ����㦠�� ����� ����஥�                   **
echo **  %1                                         
echo **                                             **
echo *************************************************

cd ..\..\exe
set params=/sn "%server_name%:%database_path%\%2.fdb" /user Administrator /password Administrator /sp %setting_path% /rd /q /sl %8
gedemin.exe %params% /sfn "%~1" /ns
if not errorlevel 0 goto Error
cd ..\setup\bootstrap

echo *************************************************
echo **                                             **
echo **  make_install:                              **
echo **  ������� ����� ����                         **
echo **                                             **
echo *************************************************

del "%database_path%\%2.bk" > nul
"%fb_path%\gbak" -b "%server_name%:%database_path%\%2.fdb" "%database_path%\%2.bk" -user SYSDBA -pas masterkey
if not errorlevel 0 goto Error

rem del "%database_path%\%2.fdb" > nul
if not errorlevel 0 goto Error

echo *************************************************
echo **                                             **
echo **  make_install:                              **
echo **  ������ ���⮫���                          **
echo **  %~dp6\setup.exe
echo **                                             **
echo *************************************************

rem copy ..\..\images\splash\%3 "%install_source_path%\gedemin.jpg" /Y
if exist "%~dp6setup.exe" del "%~dp6setup.exe"

rem pause

"%inno_setup_path%\iscc.exe" "%setup_path%\%4.iss" "/o%~dp6" /fsetup /q
if not exist "%~dp6setup.exe" goto Error

if exist "%~dp6\%5" del "%~dp6\%5" 
"%winrar_path%\winrar" a -m5 -ep -ibck "%~dp6%5" "%~dp6setup.exe"
if not errorlevel 0 goto Error

eventcreate /t INFORMATION /id 201 /l application /so gedemin /d "End making install %4."

if not [%7]==[/ftp] goto exit

echo *************************************************
echo **                                             **
echo **  make_install:                              **
echo **  Upload to ftp                              **
echo **                                             **
echo *************************************************

move /y "%~dp6%5" ./%5

rem �ய�᪠�� FTP, ��㧨� �१ PHP �ਯ�

goto SkipFTP

if exist ftp.txt del ftp.txt
copy ftp_commands.txt ftp.txt
echo send %5 %5 >> ftp.txt
echo quit >> ftp.txt

ftp -s:ftp.txt

:SkipFTP

curl -F data=@"./%5" http://gsbelarus.com/gs/content/upload.php

if not errorlevel 0 goto Error

del %5 > nul
del ftp.txt > nul
if not errorlevel 0 goto Error

echo *************************************************
echo **                                             **
echo **  make_install:                              **
echo **  ������ ��७�ᨬ�� ���⮫���              **
echo **                                             **
echo *************************************************

xcopy %install_source_path%\*.* Gedemin /Y /I
xcopy %install_source_path%\udf\*.* Gedemin\UDF /Y /I
xcopy %install_source_path%\intl\*.* Gedemin\Intl /Y /I
xcopy %install_source_path%\help\*.* Gedemin\Help /Y /I
xcopy %install_source_path%\swipl\*.* Gedemin\SWIPl /Y /I
xcopy %install_source_path%\swipl\lib\*.* Gedemin\SWIPl\Lib /Y /I

md Gedemin\Database

copy %install_source_path%\database\%2.fdb Gedemin\Database\%2.fdb /Y 

del Gedemin\databases.ini > nul
del Gedemin\gedemin.ini > nul
del Gedemin\*.jpg > nul

if not [%2]==[cash] goto make_arc

del Gedemin\USBPD.DLL > nul
del Gedemin\PDPosiFlexCommand.DLL > nul
del Gedemin\PDComWriter.DLL > nul

:make_arc

"c:\program files\winrar\winrar.exe" a -ibck %2_portable.rar Gedemin

goto SkipPortableFTP

if exist ftp.txt del ftp.txt
copy ftp_commands.txt ftp.txt
echo send %2_portable.rar %2_portable.rar >> ftp.txt
echo quit >> ftp.txt

ftp -s:ftp.txt

:SkipPortableFTP

curl -F data=@"./%2_portable.rar" http://gsbelarus.com/gs/content/upload.php

if not errorlevel 0 goto Error

del %2_portable.rar > nul
del ftp.txt > nul
rd Gedemin /s /q
if not errorlevel 0 goto Error

goto Exit

:Error

eventcreate /t error /id 102 /l application /so gedemin /d "Error while making install %4."

echo *************************************************
echo **                                             **
echo **  make_install:                              **
echo **  �ந��諠 �訡��!                          **
echo **                                             **
echo *************************************************

exit /b 1

:Exit

endlocal