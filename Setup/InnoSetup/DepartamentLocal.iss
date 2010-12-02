; External components: Windows Script Host, Windows Script Control

#include "CommonLocal.iss"

[Setup]
AppName=�������: �����������
AppVerName=�������: �����������

[Files]
Source: "Database\region.bk"; DestDir: "{app}\Database"; Flags: deleteafterinstall
Source: "BDE\BdeInst.dll"; DestDir: "{tmp}"
Source: "BDE\IDAPI32.CFG"; DestDir: "{pf}\Common Files\Borland Shared\BDE"

[Run]
Filename: "regsvr32.exe"; Parameters: """{tmp}\BdeInst.dll"""; StatusMsg: "��������� DBE..."; Flags: skipifdoesntexist

[Code]
function GetSafeAppName(Param: String): String;
begin
  Result := '�����������';
end;

function GetDBFileName(Param: String): String;
begin
  Result := 'region.fdb';
end;

function GetBKFileName(Param: String): String;
begin
  Result := 'region.bk';
end;

function GetRegAccessSubKey(Param: String): String;
begin
  Result := GetSafeAppName('');
end;

