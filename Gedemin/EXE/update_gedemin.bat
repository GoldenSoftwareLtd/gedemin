@echo off
setlocal

echo *************************************************
echo **                                             **
echo **  Usage:                                     **
echo **  update_gedemin {/ftp /no_ftp} {/d /p}      **
echo **                                             **
echo *************************************************

if "%2"=="" goto exit

if NOT exist d:\nul subst d: k:\

set RegQry=HKLM\Hardware\Description\System\CentralProcessor\0
reg.exe Query %RegQry% > checkOS.txt
find /i "x86" < CheckOS.txt > StringCheck.txt
 
if %ERRORLEVEL% == 0 (
  goto os32
) else (
  goto os64
)

:os32
set delphi_path=C:\Program Files\Borland\Delphi5\Bin
goto path_is_set

:os64
set delphi_path=C:\Program Files (x86)\Borland\Delphi5\Bin

:path_is_set

del StringCheck.txt
del CheckOS.txt

set starteam_connect=Andreik:1@india:49201

if "%2"=="/d" goto make_debug 

set gedemin_cfg=gedemin.product.cfg
set gedemin_upd_cfg=gedemin_upd.product.cfg
set gudf_cfg=gudf.product.cfg
set compiler_switch=-b
set arc_name=gedemin.rar
goto start_process

:make_debug
set gedemin_cfg=gedemin.debug.cfg
set gedemin_upd_cfg=gedemin_upd.debug.cfg
set gudf_cfg=gudf.debug.cfg
set compiler_switch=-b -vt
set arc_name=gedemin_debug.rar

:start_process

echo *************************************************
echo **                                             **
echo **  update_gedemin:                            **
echo **  Check out latest sources                   **
echo **                                             **
echo *************************************************

"c:\program files\StarBase\StarTeam 5.3\stcmd" co -p "%starteam_connect%/Gedemin" -is -x -stop -f NCO -nologo -q
"c:\program files\StarBase\StarTeam 5.3\stcmd" co -p "%starteam_connect%/Comp5"   -is -x -stop -f NCO -nologo -q

echo *************************************************
echo **                                             **
echo **  update_gedemin:                            **
echo **  Increment version number                   **
echo **                                             **
echo *************************************************

incverrc.exe ..\gedemin\gedemin.rc

echo *************************************************
echo **                                             **
echo **  update_gedemin:                            **
echo **  Prepare .cfg files                         **
echo **                                             **
echo *************************************************

cd ..\gedemin
copy gedemin.cfg gedemin.current.cfg /y
copy %gedemin_cfg% gedemin.cfg /y

echo *************************************************
echo **                                             **
echo **  update_gedemin:                            **
echo **  Compile resources                          **
echo **                                             **
echo *************************************************

del gedemin.res
"%delphi_path%\brcc32.exe" -fogedemin.res -i..\images gedemin.rc

echo *************************************************
echo **                                             **
echo **  update_gedemin:                            **
echo **  Compile gedemin.exe                        **
echo **                                             **
echo *************************************************

del ..\exe\gedemin.exe
"%delphi_path%\dcc32.exe" %compiler_switch% gedemin.dpr

if not exist ..\exe\gedemin.exe eventcreate /t error /id 1 /l application /so gedemin /d "gedemin.exe compilation error"

echo *************************************************
echo **                                             **
echo **  update_gedemin:                            **
echo **  Restore .cfg files                         **
echo **                                             **
echo *************************************************

copy gedemin.current.cfg gedemin.cfg /y
del gedemin.current.cfg > nul

echo *************************************************
echo **                                             **
echo **  update_gedemin:                            **
echo **  Strip relocation information               **
echo **                                             **
echo *************************************************

cd ..\exe
stripreloc /b gedemin.exe

if "%2"=="/p" goto skip_optimize_debug 

echo *************************************************
echo **                                             **
echo **  update_gedemin:                            **
echo **  Optimize debug information                 **
echo **                                             **
echo *************************************************

tdspack -e -o -a gedemin.exe

:skip_optimize_debug

echo *************************************************
echo **                                             **
echo **  gedemin_upd:                               **
echo **  Prepare .cfg files                         **
echo **                                             **
echo *************************************************

cd ..\gedemin
copy gedemin_upd.cfg gedemin_upd.current.cfg /y
copy %gedemin_upd_cfg% gedemin_upd.cfg /y

echo *************************************************
echo **                                             **
echo **  gedemin_upd:                               **
echo **  Compile gedemin_upd.exe                    **
echo **                                             **
echo *************************************************

del ..\exe\gedemin_upd.exe
"%delphi_path%\dcc32.exe" %compiler_switch% gedemin_upd.dpr

if not exist ..\exe\gedemin_upd.exe eventcreate /t error /id 1 /l application /so gedemin /d "gedemin_upd.exe compilation error"

echo *************************************************
echo **                                             **
echo **  gedemin_upd:                               **
echo **  Restore .cfg files                         **
echo **                                             **
echo *************************************************

copy gedemin_upd.current.cfg gedemin_upd.cfg /y
del gedemin_upd.current.cfg > nul

echo *************************************************
echo **                                             **
echo **  gedemin_upd:                               **
echo **  Strip relocation information               **
echo **                                             **
echo *************************************************

cd ..\exe
stripreloc /b gedemin_upd.exe

echo *************************************************
echo **                                             **
echo **  gudf.dll:                                  **
echo **  Prepare .cfg files                         **
echo **                                             **
echo *************************************************

cd ..\gudf
copy gudf.cfg gudf.current.cfg /y
copy %gudf_cfg% gudf.cfg /y

echo *************************************************
echo **                                             **
echo **  gudf.dll:                                  **
echo **  Compile gudf.dll                           **
echo **                                             **
echo *************************************************

del ..\exe\udf\gudf.dll
"%delphi_path%\dcc32.exe" %compiler_switch% gudf.dpr

if not exist ..\exe\udf\gudf.dll eventcreate /t error /id 1 /l application /so gedemin /d "gudf.dll compilation error"

echo *************************************************
echo **                                             **
echo **  gudf.dll:                                  **
echo **  Restore .cfg files                         **
echo **                                             **
echo *************************************************

copy gudf.current.cfg gudf.cfg /y
del gudf.current.cfg > nul

cd ..\exe

echo *************************************************
echo **                                             **
echo **  update_gedemin:                            **
echo **  Check in version number changes            **
echo **                                             **
echo *************************************************

"c:\program files\StarBase\StarTeam 5.3\stcmd" ci -p "%starteam_connect%/Gedemin" -is -x -stop -f NCI -r "Inc build number" -nologo -q

if "%1"=="/no_ftp" goto :exit

echo *************************************************
echo **                                             **
echo **  update_gedemin:                            **
echo **  Make an archive                            **
echo **                                             **
echo *************************************************

del *.bak /s
del *.tmp /s
del *.new /s
del *.~* /s
del gedemin_upd.ini
del gudf.dll

set arc_command="c:\program files\winrar\winrar.exe" a %arc_name%

if exist %arc_name% del %arc_name% 
%arc_command% gedemin.exe midas.dll midas.sxs.manifest gedemin.exe.manifest
%arc_command% ib_util.dll icudt30.dll icuin30.dll icuuc30.dll
%arc_command% fbembed.dll firebird.msg
%arc_command% microsoft.vc80.crt.manifest msvcp80.dll msvcr80.dll
%arc_command% gedemin_upd.exe
%arc_command% udf\gudf.dll intl\fbintl.conf intl\fbintl.dll

echo *************************************************
echo **                                             **
echo **  update_gedemin:                            **
echo **  Upload to FTP                              **
echo **                                             **
echo *************************************************

if exist temp_ftp_commands.txt del temp_ftp_commands.txt
call BatchSubstitute.bat gedemin.rar %arc_name% ftp_commands.txt > temp_ftp_commands.txt
ftp -s:temp_ftp_commands.txt
if not errorlevel 0 goto exit

del %arc_name%
del temp_ftp_commands.txt

echo *************************************************
echo **                                             **
echo **  for internal usage only                    **
echo **                                             **
echo **                                             **
echo *************************************************

xcopy gedemin.exe g:\common\gedemin\gedemin.exe /Y


:exit



