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

set delphi_path=C:\Program Files\Borland\Delphi5\Bin
set starteam_connect=Andreik:1@india:49201

if "%2"=="/d" goto make_debug 

set gedemin_cfg=gedemin.product.cfg
set compiler_switch=-b
set arc_name=gedemin.rar
goto start_process

:make_debug
set gedemin_cfg=gedemin.debug.cfg
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

"%delphi_path%\brcc32.exe" -fogedemin.res -i..\images gedemin.rc

echo *************************************************
echo **                                             **
echo **  update_gedemin:                            **
echo **  Compile gedemin.exe                        **
echo **                                             **
echo *************************************************

"%delphi_path%\dcc32.exe" %compiler_switch% gedemin.dpr

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

set arc_command="c:\program files\winrar\winrar.exe" a %arc_name%

if exist %arc_name% del %arc_name% 
%arc_command% gedemin.exe midas.dll midas.sxs.manifest gedemin.exe.manifest

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



