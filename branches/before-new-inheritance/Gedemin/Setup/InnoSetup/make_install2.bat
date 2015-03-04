
@echo off
setlocal

If "%7"=="" goto :noparam

goto :proceed

:noparam

echo ******************************************************************************
echo **                                                                          **
echo **  Не указаны параметры                                                    **
echo **                                                                          **
echo **  make_install FSFN DBN SFN IFN AFN TFN B                                 **
echo **                                                                          **
echo **    FSFN -- полное имя файла с пакетом настроек                           **
echo **    DBN  -- только имя (без расширения) файла БД                          **
echo **    SFN  -- имя файла заставки в каталоге d:\golden\gedemin\images\splash **
echo **    IFN  -- имя файла проекта установки, без расширения                   **
echo **    AFN  -- имя файла с архивом установки                                 **
echo **    TFN  -- имя файла в каталоге дистрибутива установки                   **
echo **    B    -- Y/N выполнять build gedemin.exe                               **
echo **                                                                          **
echo ******************************************************************************

goto exit

:proceed

echo *************************************************
echo **                                             **
echo **  Инициализируем глобальные переменные       **
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
echo **  Компилируем gedemin.exe                    **
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
echo **  Выгружаем настройки из StarTeam            **
echo **                                             **
echo *************************************************

stcmd co -p "Andreik:1@czech:49201/Setting" -is -stop -f NCO -nologo -q
if errorlevel 0 goto CreateEtalonDb

echo Error while checking out files!
goto exit

:CreateEtalonDB

echo *************************************************
echo **                                             **
echo **  Создаем чистый эталон                      **
echo **                                             **
echo *************************************************

d:
cd \golden\gedemin\sql\
call create.bat
copy k:\bases\gedemin\etalon.fdb d:\bases\etalon.fdb /Y

echo *************************************************
echo **                                             **
echo **  Загружаем пакет настроек                   **
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
echo **  Делаем инстоляцию                          **
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