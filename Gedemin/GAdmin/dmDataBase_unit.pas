
unit dmDataBase_unit;

interface

uses
  Classes, Forms, IBDatabase, Db, IBSQL;

type
  TdmDatabase = class(TDataModule)
    ibdbGAdmin: TIBDatabase;
    ibsqlGenUniqueID: TIBSQL;
    ibtrGenUniqueID: TIBTransaction;
    procedure DataModuleCreate(Sender: TObject);
    procedure ibdbGAdminBeforeDisconnect(Sender: TObject);
    procedure ibdbGAdminAfterConnect(Sender: TObject);
  end;

var
  dmDatabase: TdmDatabase;

implementation

{$R *.DFM}

uses
  IB, gd_security, gd_resourcestring, gd_security_operationconst,
  gd_CmdLineParams_unit, Storages, SysUtils, inst_const, Registry,
  Windows, dm_i_ClientReport_unit
  {$IFDEF GEDEMIN}
  ,prp_frmGedeminProperty_Unit
  {$ENDIF}
  ;

{TdmDataBase ---------------------------------------------}

procedure TdmDatabase.DataModuleCreate(Sender: TObject);
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create(KEY_WRITE);
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey(cExecuteRegPath, True) then
    begin
      if not Reg.ValueExists(Application.ExeName) then
        Reg.WriteInteger(Application.ExeName, 0);
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;

  ibdbGAdmin.Params.Text := 'lc_ctype=WIN1251';

  if gd_CmdLineParams.NoGarbageCollect then
    ibdbGAdmin.Params.Add('no_garbage_collect');

  {$IFDEF DEBUG}
  ibdbGAdmin.TraceFlags := [{tfQPrepare, }tfQExecute{, tfQFetch, tfError, tfStmt}, tfConnect,
     tfTransact{, tfBlob, tfService, tfMisc}];
  {$ELSE}
  ibdbGAdmin.TraceFlags := [];
  {$ENDIF}

  ibtrGenUniqueID.defaultdataBase := ibdbGAdmin;
end;

procedure TdmDatabase.ibdbGAdminBeforeDisconnect(Sender: TObject);
begin
{Весь код, который будет подключен на это событие будет выполняться каждый раз при
 переподключении к базе!
 Переподключение к базе осуществляется при: 1)загрузке настроек 2) Выполнении отоложенных операций
 При выполнении отложенных операций необходимо, чтобы к базе не было подключений!!!}
{  if dm_i_ClientReport <> nil then
    dm_i_ClientReport.DoDisconnect; }
 {$IFDEF GEDEMIN}
 if frmGedeminProperty <> nil then
   FreeAndNil(frmGedeminProperty);
 {$ENDIF}  
end;

procedure TdmDatabase.ibdbGAdminAfterConnect(Sender: TObject);
begin
{Весь код, который будет подключен на это событие будет выполняться каждый раз при
 переподключении к базе!
 Переподключение к базе осуществляется при: 1)загрузке настроек 2) Выполнении отоложенных операций
 При выполнении отложенных операций необходимо, чтобы к базе не было подключений!!!}
{  if dm_i_ClientReport <> nil then
    dm_i_ClientReport.DoConnect; }
end;

end.

