; External components: Windows Script Host, Windows Script Control

#include "CommonLocal.iss"

[Setup]
AppName=�������: �����������
AppVerName=�������: �����������

[Files]
Source: "Database\devel.bk"; DestDir: "{app}\Database"; Flags: deleteafterinstall

[Code]
function GetSafeAppName(Param: String): String;
begin
  Result := '�����������';
end;

function GetDBFileName(Param: String): String;
begin
  Result := 'devel.fdb';
end;

function GetBKFileName(Param: String): String;
begin
  Result := 'devel.bk';
end;

function GetRegAccessSubKey(Param: String): String;
begin
  Result := GetSafeAppName('');
end;

