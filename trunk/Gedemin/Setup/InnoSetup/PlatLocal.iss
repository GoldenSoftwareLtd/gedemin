; External components: Windows Script Host, Windows Script Control

#include "CommonLocal.iss"

[Setup]
AppName=Гедымин: Платежные документы
AppVerName=Гедымин: Платежные документы

[Files]
Source: "Database\plat.bk"; DestDir: "{app}\Database"; Flags: deleteafterinstall; Tasks: databasefile

[Code]
function GetSafeAppName(Param: String): String;
begin
  Result := 'Платежные документы';
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

