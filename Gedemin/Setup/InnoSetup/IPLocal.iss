; External components: Windows Script Host, Windows Script Control

#include "CommonLocal.iss"

[Setup]
AppName=Гедымин: Индивидуальный предприниматель
AppVerName=Гедымин: Индивидуальный предприниматель

[Files]
Source: "Database\ip.bk"; DestDir: "{app}\Database"; Flags: deleteafterinstall; Tasks: databasefile

[Code]
function GetSafeAppName(Param: String): String;
begin
  Result := 'Индивидуальный предприниматель';
end;

function GetDBFileName(Param: String): String;
begin
  Result := 'ip.fdb';
end;

function GetBKFileName(Param: String): String;
begin
  Result := 'ip.bk';
end;

function GetRegAccessSubKey(Param: String): String;
begin
  Result := GetSafeAppName('');
end;

