@echo off
setlocal

if NOT exist d:\nul subst d: g:\

set delphi_path=C:\Program Files\Borland\Delphi5\Bin
set starteam_connect=Andreik:1@india:49201

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
copy gedemin.product.cfg gedemin.cfg /y

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

"%delphi_path%\dcc32.exe" -b gedemin.dpr

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
stripreloc gedemin.exe

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

set arc_name=gedemin.rar
set arc_command="c:\program files\winrar\winrar.exe" a %arc_name%

if exist %arc_name% del %arc_name% 
%arc_command% gedemin.exe

echo *************************************************
echo **                                             **
echo **  update_gedemin:                            **
echo **  Upload to FTP                              **
echo **                                             **
echo *************************************************

ftp -s:ftp_commands.txt
if not errorlevel 0 goto exit

del %arc_name%

:exit



