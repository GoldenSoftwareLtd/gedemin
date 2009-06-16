
@echo off
setlocal

set spath=d:\golden\setting
set dpath=\\alex2006\Distrib2\GoldSoft\Gedymin\Local

call make_install "%spath%\Общие\Комплексная_автоматизация.gsf" business complex.jpg busilocal_wo_demo compl_setup.rar "%dpath%\Комплексная автоматизация\setup.exe" N
call make_install "%spath%\Банк\Банк и касса.gsf" plat doc.jpg platlocal_wo_demo plat_setup.rar "%dpath%\Платежные документы\setup.exe" N
call make_install "%spath%\Предприниматель\Подоходный\Предприниматель_подоходный.gsf" ip ip.jpg iplocal_wo_demo ip_setup.rar "%dpath%\Предприниматель\setup.exe" N
call make_install "%spath%\Предприниматель\Единый налог\Предприниматель_единый_налог.gsf" ip ip.jpg iplocal_wo_demo ip_setup_ed.rar "%dpath%\Предприниматель\setup_ed.exe" N
call make_install "%spath%\Общие\Общие данные.gsf" devel complex.jpg DeveloperLocal devel_setup.rar "%dpath%\Разработчик\setup.exe" N

endlocal
