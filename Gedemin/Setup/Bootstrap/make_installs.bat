
@echo off
setlocal

set spath=%~d0:\golden\setting
set dpath=\\alex2006\Distrib2\GoldSoft\Gedymin\Local

call make_install "%spath%\��騥\�������᭠�_��⮬�⨧���.gsf" business complex.jpg busilocal_wo_demo compl_setup.rar "%dpath%\�������᭠� ��⮬�⨧���\setup.exe" N
call make_install "%spath%\����\���� � ����.gsf" plat doc.jpg platlocal_wo_demo plat_setup.rar "%dpath%\���⥦�� ���㬥���\setup.exe" N
call make_install "%spath%\�।�ਭ���⥫�\����室��\�।�ਭ���⥫�_����室��.gsf" ip ip.jpg iplocal_wo_demo ip_setup.rar "%dpath%\�।�ਭ���⥫�\setup.exe" N
call make_install "%spath%\�।�ਭ���⥫�\����� �����\�।�ਭ���⥫�_�����_�����.gsf" ip ip.jpg iplocal_wo_demo ip_setup_ed.rar "%dpath%\�।�ਭ���⥫�\setup_ed.exe" N
call make_install "%spath%\��騥\��騥 �����.gsf" devel complex.jpg DeveloperLocal devel_setup.rar "%dpath%\���ࠡ��稪\setup.exe" N

endlocal
