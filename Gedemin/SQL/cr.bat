
@echo off

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

echo SET NAMES WIN1251;                        >  result.sql
echo SET SQL DIALECT 3;                        >> result.sql
echo CREATE DATABASE '%database_name%'         >> result.sql
echo USER %user_name% PASSWORD %user_pass%     >> result.sql 
echo PAGE_SIZE 8192                            >> result.sql
echo DEFAULT CHARACTER SET WIN1251;            >> result.sql

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

isql.exe -i result.sql 

if not errorlevel 0 goto Error

makelbrbtree.exe /sn %database_name%    

if not errorlevel 0 goto Error

echo SET NAMES WIN1251;                         >  result2.sql
echo SET SQL DIALECT 3;                         >> result2.sql
echo CONNECT '%database_name%'                  >> result2.sql
echo USER %user_name% PASSWORD %user_pass%;     >> result2.sql 

copy result2.sql /a + gd_header.sql             /a result2.sql    > nul
copy result2.sql /a + gd_addressbook_after.sql  /a result2.sql    > nul
copy result2.sql /a + rp_report_after.sql       /a result2.sql    > nul
copy result2.sql /a + gd_constants.sql          /a result2.sql    > nul
copy result2.sql /a + gd_oper_const.sql         /a result2.sql    > nul
copy result2.sql /a + gd_securityrole.sql       /a result2.sql    > nul
copy result2.sql /a + gd_db_triggers.sql        /a result2.sql    > nul

isql.exe -i result2.sql

if not errorlevel 0 goto Error

if not exist %2 goto Error

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

endlocal
exit /b 1

:End

endlocal
exit /b
























@echo *********************************************
@echo *********************************************
@echo **  Закомментировано:                      **
@echo **    1. ctl_  -- скот                     **
@echo **    2. pr_   -- регистрация              **
@echo **    3. gd_realization                    **
@echo **    4. gd_newtransaction                 **
@echo *********************************************
@echo *********************************************
@echo .

isql -i gd_create.sql
isql -i gudf.sql
@rem isql -i fbudf.sql
isql -i gd_domains.sql
@rem isql -i gd_link.sql
isql -i gd_version.sql
@rem isql -i st_setting.sql
isql -i gd_link.sql

isql -i gd_security.sql
isql -i gd_place.sql
isql -i gd_currency.sql
isql -i wg_tblcal.sql
isql -i gd_addressbook.sql
isql -i gd_ourcompany.sql
isql -i gd_ruid.sql
isql -i gd_storage.sql
isql -i at_attribute.sql

isql -i gd_const.sql

isql -i gd_script.sql
isql -i gd_document.sql
isql -i at_sync_procedures.sql
@rem isql -i gd_cardaccount.sql
@rem isql -i gd_newtransaction.sql
isql -i flt_filter.sql


@rem isql -i bn_bankorder.sql
@rem isql -i dp_reference.sql
@rem isql -i dp_document.sql
isql -i bn_bankstatement.sql
@rem isql -i bn_checklist.sql
@rem isql -i bn_currcommission.sql


isql -i gd_upgrade.sql
isql -i bug_bugbase.sql
isql -i gd_command.sql
isql -i gd_good.sql

isql -i ac_accounting.sql

rem isql -i ac_quantity.sql

isql -i msg_messaging.sql
isql -i rp_registry.sql
isql -i rp_report.sql
isql -i evt_script.sql
@rem isql -i gd_realization.sql
@rem isql -i dp_report.sql
@rem isql -i ctl_cattle.sql
@rem isql -i ctl_cattle_consts.sql

@rem isql -i pr_protect.sql
isql -i inv_movement.sql

isql -i inv_price.sql
@rem isql -i inv_invoice.sql

isql -i gd_tax.sql

isql -i at_setting.sql

@rem Заносим локализацию
@rem isql -i gd_loc_r.sql 
@rem isql -i gd_loc_f.sql 
@rem isql -i gd_loc_rf.sql 

@rem isql -i gd_currrate.sql

@rem isql -i gd_productivity.sql

isql -i gd_file.sql

@rem Таблицы для инкрементного сохранения
isql -i rpl_database.sql

makelbrbtree.exe /sn india:k:\bases\gedemin\etalon.fdb /tmp tst_tree_tbl.sql

isql -i gd_addressbook_after.sql
isql -i rp_report_after.sql


rem Заносим константы и настройки системы
isql -i gd_constants.sql
isql -i gd_oper_const.sql
@rem isql -i dp_constants.sql


rem Должно выполняться последним
isql -i gd_securityrole.sql
@rem isql -i dp_securityrole.sql

@endlocal
