
@echo off

echo  ************************************************************************
echo  ************************************************************************
echo  **                                                                    **
echo  **  Compiling utility gedemin\utility\makelbrbtree\makelbrbtree.dpr   **
echo  **                                                                    **
echo  ************************************************************************   
echo  ************************************************************************

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

cd ..\Utility\MakeLBRBTree

"%delphi_path%\dcc32.exe" -b makelbrbtree.dpr

if not errorlevel 0 goto Error

cd ..\..\sql

:create_db

if not "%2"=="" goto proceed

echo  *******************************************************************************************
echo  *******************************************************************************************
echo  **                                                                                       **
echo  ** Usage:   cr.bat {server[/port]|embed} database [fb\bin path]                          **
echo  ** Example: cr.bat india k:\bases\gedemin\etalon.fdb "c:\program files\firebird\bin"     **
echo  **                                                                                       **
echo  *******************************************************************************************   
echo  *******************************************************************************************

exit /b 1

:proceed

if exist gd_create.sql goto SetVars

echo *********************************************
echo *********************************************
echo **                                         **
echo **  cr.bat:                                **
echo **  Launch the batch file within           **
echo **  gedemin\sql directory.                 **
echo **                                         **
echo *********************************************
echo *********************************************

exit /b 1

:SetVars

setlocal

if not [%3]==[] set path=%~3;%path%

set user_name='SYSDBA'
set user_pass='masterkey'

if "%1"=="embed" (set database_name=%2) else set database_name=%1:%2

if exist %2 del %2 > nul

if exist result.sql del result.sql > nul

copy gd_header.sql                             /a result.sql    > nul
copy result.sql /a + gd_create.sql             /a result.sql    > nul
copy result.sql /a + gudf.sql                  /a result.sql    > nul
copy result.sql /a + gd_domains.sql            /a result.sql    > nul
copy result.sql /a + gd_version.sql            /a result.sql    > nul
copy result.sql /a + gd_link.sql               /a result.sql    > nul
copy result.sql /a + gd_security.sql           /a result.sql    > nul
copy result.sql /a + gd_place.sql              /a result.sql    > nul
copy result.sql /a + gd_currency.sql           /a result.sql    > nul
copy result.sql /a + wg_tblcal.sql             /a result.sql    > nul
copy result.sql /a + gd_addressbook.sql        /a result.sql    > nul
copy result.sql /a + gd_ourcompany.sql         /a result.sql    > nul
copy result.sql /a + gd_ruid.sql               /a result.sql    > nul
copy result.sql /a + at_attribute.sql          /a result.sql    > nul
copy result.sql /a + gd_const.sql              /a result.sql    > nul
copy result.sql /a + gd_script.sql             /a result.sql    > nul
copy result.sql /a + gd_document.sql           /a result.sql    > nul
copy result.sql /a + at_sync_procedures.sql    /a result.sql    > nul
copy result.sql /a + flt_filter.sql            /a result.sql    > nul
copy result.sql /a + bn_bankstatement.sql      /a result.sql    > nul
copy result.sql /a + gd_upgrade.sql            /a result.sql    > nul
copy result.sql /a + bug_bugbase.sql           /a result.sql    > nul
copy result.sql /a + gd_command.sql            /a result.sql    > nul
copy result.sql /a + gd_good.sql               /a result.sql    > nul
copy result.sql /a + ac_accounting.sql         /a result.sql    > nul
copy result.sql /a + msg_messaging.sql         /a result.sql    > nul
copy result.sql /a + rp_registry.sql           /a result.sql    > nul
copy result.sql /a + rp_report.sql             /a result.sql    > nul
copy result.sql /a + evt_script.sql            /a result.sql    > nul
copy result.sql /a + inv_movement.sql          /a result.sql    > nul
copy result.sql /a + inv_price.sql             /a result.sql    > nul
copy result.sql /a + gd_tax.sql                /a result.sql    > nul
copy result.sql /a + at_setting.sql            /a result.sql    > nul
copy result.sql /a + gd_file.sql               /a result.sql    > nul
copy result.sql /a + gd_block_rule.sql         /a result.sql    > nul
copy result.sql /a + rpl_database.sql          /a result.sql    > nul
copy result.sql /a + gd_autotask.sql           /a result.sql    > nul
copy result.sql /a + gd_smtp.sql               /a result.sql    > nul

echo SET NAMES WIN1251;                        >  temp_hdr.sql
echo SET SQL DIALECT 3;                        >> temp_hdr.sql
echo CREATE DATABASE '%database_name%'         >> temp_hdr.sql
echo USER %user_name% PASSWORD %user_pass%     >> temp_hdr.sql 
echo PAGE_SIZE 8192                            >> temp_hdr.sql
echo DEFAULT CHARACTER SET WIN1251;            >> temp_hdr.sql

if exist temp.sql del temp.sql > nul

copy temp_hdr.sql /a + result.sql              /a temp.sql      > nul

isql.exe -i temp.sql

if not errorlevel 0 goto Error

makelbrbtree.exe /sn %database_name% /fo result2.sql   

if not errorlevel 0 goto Error

copy result.sql /a + result2.sql               /a result.sql    > nul

copy result.sql /a + gd_constants.sql          /a result.sql    > nul
copy result.sql /a + gd_oper_const.sql         /a result.sql    > nul
copy result.sql /a + gd_securityrole.sql       /a result.sql    > nul
copy result.sql /a + gd_db_triggers.sql        /a result.sql    > nul

if exist temp.sql del temp.sql > nul

copy temp_hdr.sql /a + result.sql              /a temp.sql      > nul

if exist %2 del %2 > nul

isql.exe -i temp.sql

if not errorlevel 0 goto Error

if not exist %2 goto Error

echo SET NAMES WIN1251;                        >  temp.sql
echo SET SQL DIALECT 3;                        >> temp.sql
echo CREATE DATABASE 'put_your_database_name'  >> temp.sql
echo USER 'SYSDBA' PASSWORD 'masterkey'        >> temp.sql 
echo PAGE_SIZE 8192                            >> temp.sql
echo DEFAULT CHARACTER SET WIN1251;            >> temp.sql

copy temp.sql /a + result.sql                  /a temp.sql > nul

if not exist etalon.sql copy temp.sql etalon.sql > nul

FC temp.sql etalon.sql /C | FIND "FC: no dif" > nul 
IF ERRORLEVEL 1 goto s_files_are_different

goto End

:s_files_are_different

if exist etalon.sql del etalon.sql > nul
copy temp.sql etalon.sql > nul

goto End

:Error

echo *********************************************
echo *********************************************
echo **                                         **
echo **  В процессе создания БД произошла       **
echo **  ошибка. См. файл result.sql.           **
echo **                                         **
echo *********************************************
echo *********************************************

if exist temp.sql del temp.sql > nul
if exist temp_hdr.sql del temp_hdr.sql > nul
if exist result.sql del result.sql > nul
if exist result2.sql del result2.sql > nul

endlocal
exit /b 1

:End

if exist temp.sql del temp.sql > nul
if exist temp_hdr.sql del temp_hdr.sql > nul
if exist result.sql del result.sql > nul
if exist result2.sql del result2.sql > nul

endlocal
exit /b

