; External components: Windows Script Host, Windows Script Control

#include "CommonLocal.iss"

[Setup]
AppName=�������: ��������� ���������
AppVerName=�������: ��������� ���������

[Files]
Source: "Database\plat.bk"; DestDir: "{app}\Database"; Flags: deleteafterinstall
;Source: "Database\plat.fdb"; DestDir: "{app}\Database"; Flags: onlyifdoesntexist uninsneveruninstall

[Code]
function GetSafeAppName(Param: String): String;
begin
  Result := '��������� ���������';
end;

function GetDBFileName(Param: String): String;
begin
  Result := 'plat.fdb';
end;

function GetBKFileName(Param: String): String;
begin
  Result := 'plat.bk';
end;

function GetRegAccessSubKey(Param: String): String;
begin
  Result := GetSafeAppName('');
end;

