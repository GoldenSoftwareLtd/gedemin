
@echo off
setlocal

set spath=d:\golden\setting
set dpath=\\alex2006\Distrib2\GoldSoft\Gedymin\Local

call make_install "%spath%\�����\�����������_�������������.gsf" business complex.jpg busilocal_wo_demo compl_setup.rar "%dpath%\����������� �������������\setup.exe" N
call make_install "%spath%\����\���� � �����.gsf" plat doc.jpg platlocal_wo_demo plat_setup.rar "%dpath%\��������� ���������\setup.exe" N
call make_install "%spath%\���������������\����������\���������������_����������.gsf" ip ip.jpg iplocal_wo_demo ip_setup.rar "%dpath%\���������������\setup.exe" N
call make_install "%spath%\���������������\������ �����\���������������_������_�����.gsf" ip ip.jpg iplocal_wo_demo ip_setup_ed.rar "%dpath%\���������������\setup_ed.exe" N
call make_install "%spath%\�����\����� ������.gsf" devel complex.jpg DeveloperLocal devel_setup.rar "%dpath%\�����������\setup.exe" N

endlocal
