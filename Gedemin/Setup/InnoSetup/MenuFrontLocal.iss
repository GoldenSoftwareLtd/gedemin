; External components: Windows Script Host, Windows Script Control

#include "CommonLocal.iss"

[Setup]
AppName=Гедымин: Меню фронт-офис
AppVerName=Гедымин: Меню фронт-офис

[Files]
Source: "Database\menufront.bk"; DestDir: "{app}\Database"; Flags: deleteafterinstall; Tasks: databasefile

[Code]
function GetSafeAppName(Param: String): String;
begin
  Result := 'Меню Фронт';
end;

function GetDBFileName(Param: String): String;
begin
  Result := 'menufront.fdb';
end;

function GetBKFileName(Param: String): String;
begin
  Result := 'menufront.bk';
end;

function GetRegAccessSubKey(Param: String): String;
begin
  Result := GetSafeAppName('');
end;

