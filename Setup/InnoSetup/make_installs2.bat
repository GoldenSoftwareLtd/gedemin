
@echo off
setlocal

call make_install2 "d:\golden\setting\Общие\Комплексная_автоматизация.gsf" business complex.jpg businesslocal compl_setup.rar "g:\Distrib2\GoldSoft\Gedymin\Local\Комплексная автоматизация\setup.exe" N
call make_install2 "d:\golden\setting\Банк\Банк и касса.gsf" plat doc.jpg platlocal plat_setup.rar "g:\Distrib2\GoldSoft\Gedymin\Local\Платежные документы\setup.exe" N
call make_install2 "d:\golden\setting\Предприниматель\Подоходный\Предприниматель_подоходный.gsf" ip ip.jpg iplocal ip_setup.rar "g:\Distrib2\GoldSoft\Gedymin\Local\Предприниматель\setup.exe" N
call make_install2 "d:\golden\setting\Предприниматель\Единый налог\Предприниматель_единый_налог.gsf" ip ip.jpg iplocal ip_setup_ed.rar "g:\Distrib2\GoldSoft\Gedymin\Local\Предприниматель\setup_ed.exe" N
call make_install2 "d:\golden\setting\Общие\Общие данные.gsf" devel complex.jpg DevelLocal devel_setup.rar "g:\Distrib2\GoldSoft\Gedymin\Local\Разработчик\setup.exe" N

endlocal
