program gdcc;

uses
  FastMM4,
  Forms,
  Windows,
  gdccConst,
  gdccServer_unit,
  gdcc_frmMain_unit in 'gdcc_frmMain_unit.pas' {gdcc_frmMain},
  gdcc_frmProgress_unit in 'gdcc_frmProgress_unit.pas' {gdcc_frmProgress};

{$R *.RES}
{$R GDCC_VER.RES}

var
  MutexHandle: THandle;
  MutexExisted: Boolean;

begin
  MutexHandle := CreateMutex(nil, True, PChar(gdccMutexName));
  MutexExisted := GetLastError = ERROR_ALREADY_EXISTS;

  if (MutexHandle <> 0) and (not MutexExisted) then
  begin
    Application.Initialize;
    Application.ShowMainForm := False;
    Application.Title := 'Gedemin Control Center';
  Application.CreateForm(Tgdcc_frmMain, gdcc_frmMain);
    Application.Run;
  end;
end.
