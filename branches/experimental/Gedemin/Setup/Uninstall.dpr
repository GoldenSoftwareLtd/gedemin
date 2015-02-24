program Uninstall;

uses
  Forms,
  gsGedeminInstall,
  Windows,
  SysUtils,
  inst_string_const in 'inst_string_const.pas';

{$R *.RES}


var
  S: String;

begin
  Application.Initialize;
  with TGedeminInstall.Create(nil) do
  try
    S := '';
    if cServerFlags * YetInstalledModules = cServerFlags then
      S := '��������� �����, ';
    if cClientFlags * YetInstalledModules = cClientFlags then
      S := S + '���������� �����, ';
    if cReportFlags * YetInstalledModules = cReportFlags then
      S := S + '������ �������. ';
    if S <> '' then
      S[Length(S) - 1] := '.';
    if (YetInstalledModules <> []) and (MessageBox(0,
      PChar(Format('�� ����� ���������� ���������� ��������� ������ ' +
      '������������ ��������� Gedemin: %s������ ���������������� ��?', [S])),
      '��������', MB_YESNO + MB_ICONQUESTION) = IDYES) then
      StartUninstall;
  finally
    Free;
  end;
  Application.Title := 'Gedemin uninstaller';
  Application.Run;
end.
