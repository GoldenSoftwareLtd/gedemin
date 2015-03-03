
@echo off
setlocal

If "%7"=="" goto :noparam

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
echo **    B    -- Y/N �믮����� build gedemin.exe                               **
echo **                                                                          **
echo ******************************************************************************

goto exit

:proceed

echo *************************************************
echo **                                             **
echo **  ���樠�����㥬 �������� ��६����       **
echo **                                             **
echo *************************************************

set path=c:\program files\StarBase\StarTeam 5.3
set path=%path%;c:\program files\yaffil\bin
set path=%path%;D:\Program Files\Borland\Delphi5\Bin
set path=%path%;C:\Program Files\Inno Setup 5
set path=%path%;C:\Program Files\WinRar
set path=%path%;c:\windows;c:\windows\system32

set gedemin_path=d:\golden\gedemin
set install_source_path=d:\golden\gedemin_local

echo *************************************************
echo **                                             **
echo **  ��������㥬 gedemin.exe                    **
echo **                                             **
echo *************************************************

if "%7"=="N" goto :NoCompile
delphi32 %gedemin_path%\gedemin\gedemin.dpr -b
if not errorlevel 0 goto exit

:NoCompile

z:
cd \
stripreloc gedemin.exe
copy gedemin.exe %install_source_path%\gedemin.exe /Y

echo *************************************************
echo **                                             **
echo **  ���㦠�� ����ன�� �� StarTeam            **
echo **                                             **
echo *************************************************

stcmd co -p "Andreik:1@czech:49201/Setting" -is -stop -f NCO -nologo -q
if errorlevel 0 goto CreateEtalonDb

echo Error while checking out files!
goto exit

:CreateEtalonDB

echo *************************************************
echo **                                             **
echo **  ������� ���� �⠫��                      **
echo **                                             **
echo *************************************************

d:
cd \golden\gedemin\sql\
call create.bat
copy k:\bases\gedemin\etalon.fdb d:\bases\etalon.fdb /Y

echo *************************************************
echo **                                             **
echo **  ����㦠�� ����� ����஥�                   **
echo **                                             **
echo *************************************************

set params=/sn d:\bases\etalon.fdb /user Administrator /password Administrator /sp d:\golden\setting
set ISC_USER=SYSDBA
set ISC_PASSWORD=masterkey

z:\gedemin.exe %params% /sfn %1 /ns
isql -i d:\reset_dbid.sql
gfix -write sync d:\bases\etalon.fdb
gbak -b localhost:d:\bases\etalon.fdb %install_source_path%\database\%2.bk

echo *************************************************
echo **                                             **
echo **  ������ ���⮫���                          **
echo **                                             **
echo *************************************************

copy %gedemin_path%\images\splash\%3 %install_source_path%\gedemin.jpg /Y

echo on


iscc /Od:\temp\setup /Fsetup /Q %gedemin_path%\setup\innosetup\%4.iss 

d:
cd \temp\setup
copy setup.exe %6 
winrar m -m5 %5 setup.exe


rem ftp -s:d:\ftp_commands.txt gsbelarus.com

:exit

endlocal