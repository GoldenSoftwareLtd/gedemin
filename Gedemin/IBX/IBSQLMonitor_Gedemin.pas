unit IBSQLMonitor_Gedemin;

interface

uses
  Classes, IB, IBDatabase, IBSQL, IBServices;

type
  TGedeminSQLMonitor = class(TObject)
  private
    FTraceFlags: TTraceFlags;
    FEnabled: Boolean;

    procedure WriteToDatabase(F: TTraceFlag; AComp: TComponent; const AMethod: String;
      const ASQL: String = ''; const AParams: String = '');

  public
    constructor Create;

    procedure SQLPrepare(qry: TIBSQL); virtual;
    procedure SQLExecute(qry: TIBSQL; const Duration: Cardinal = 0); virtual;
    procedure SQLFetch(qry: TIBSQL); virtual;
    procedure DBConnect(db: TIBDatabase); virtual;
    procedure DBDisconnect(db: TIBDatabase); virtual;
    procedure TRStart(tr: TIBTransaction); virtual;
    procedure TRCommit(tr: TIBTransaction); virtual;
    procedure TRCommitRetaining(tr: TIBTransaction); virtual;
    procedure TRRollback(tr: TIBTransaction); virtual;
    procedure TRRollbackRetaining(tr: TIBTransaction); virtual;
    procedure ServiceAttach(service: TIBCustomService); virtual;
    procedure ServiceDetach(service: TIBCustomService); virtual;
    procedure ServiceQuery(service: TIBCustomService); virtual;
    procedure ServiceStart(service: TIBCustomService); virtual;
    procedure SendMisc(Msg : String);
    procedure SendError(Msg : String; db: TIBDatabase); overload;
    procedure SendError(Msg : String); overload;

    property TraceFlags: TTraceFlags read FTraceFlags write FTraceFlags;
    property Enabled : Boolean read FEnabled write FEnabled default True;
  end;

function MonitorHook: TGedeminSQLMonitor;

implementation

uses
  Windows, SysUtils, gdcBaseInterface, gdcSQLHistory, gd_CmdLineParams_unit
  {$IFDEF WITH_INDY}
  , gdccClient_unit
  {$ENDIF}
  ;

var
  GedeminSQLMonitor: TGedeminSQLMonitor;

function MonitorHook: TGedeminSQLMonitor;
begin
  if not Assigned(GedeminSQLMonitor) then
    GedeminSQLMonitor := TGedeminSQLMonitor.Create;
  Result := GedeminSQLMonitor;
end;

{ TGedeminSQLMonitor }

constructor TGedeminSQLMonitor.Create;
begin
  FTraceFlags := [tfQExecute, tfError, tfStmt, tfConnect,
    tfTransact, tfService, tfMisc];
  FEnabled := gd_CmdLineParams.TraceSQL;  
end;

procedure TGedeminSQLMonitor.DBConnect(db: TIBDatabase);
begin
  if FEnabled and (tfConnect in FTraceFlags) then
    WriteToDatabase(tfConnect, db, 'Connect');
end;

procedure TGedeminSQLMonitor.DBDisconnect(db: TIBDatabase);
begin
  if FEnabled and (tfConnect in FTraceFlags) then
    WriteToDatabase(tfConnect, db, 'Disconnect');
end;

procedure TGedeminSQLMonitor.SendError(Msg: String);
begin
  if FEnabled and (tfError in FTraceFlags) then
    WriteToDatabase(tfError, nil, '', Msg);
end;

procedure TGedeminSQLMonitor.SendError(Msg: String; db: TIBDatabase);
begin
  if FEnabled and (tfError in FTraceFlags) then
    WriteToDatabase(tfError, db, '', Msg);
end;

procedure TGedeminSQLMonitor.SendMisc(Msg: String);
begin
  if FEnabled and (tfMisc in FTraceFlags) then
    WriteToDatabase(tfMisc, nil, '', Msg);
end;

procedure TGedeminSQLMonitor.ServiceAttach(service: TIBCustomService);
begin
  if FEnabled and (tfService in FTraceFlags) then
    WriteToDatabase(tfService, service, 'Attach');
end;

procedure TGedeminSQLMonitor.ServiceDetach(service: TIBCustomService);
begin
  if FEnabled and (tfService in FTraceFlags) then
    WriteToDatabase(tfService, service, 'Detach');
end;

procedure TGedeminSQLMonitor.ServiceQuery(service: TIBCustomService);
begin
  if FEnabled and (tfService in FTraceFlags) then
    WriteToDatabase(tfService, service, 'Query');
end;

procedure TGedeminSQLMonitor.ServiceStart(service: TIBCustomService);
begin
  if FEnabled and (tfService in FTraceFlags) then
    WriteToDatabase(tfService, service, 'Start');
end;

procedure TGedeminSQLMonitor.SQLExecute(qry: TIBSQL;
  const Duration: Cardinal = 0);
begin
  if FEnabled and (tfQExecute in FTraceFlags) then
    WriteToDatabase(tfQExecute, qry, '', qry.SQL.Text, TgdcSQLHistory.EncodeParamsText(qry.Params));
end;

procedure TGedeminSQLMonitor.SQLFetch(qry: TIBSQL);
begin
  if FEnabled and (tfQFetch in FTraceFlags) then
    WriteToDatabase(tfQFetch, qry, 'Fetch');
end;

procedure TGedeminSQLMonitor.SQLPrepare(qry: TIBSQL);
begin
  if FEnabled and (tfQPrepare in FTraceFlags) then
    WriteToDatabase(tfQPrepare, qry, 'Prepare');
end;

procedure TGedeminSQLMonitor.TRCommit(tr: TIBTransaction);
begin
  if FEnabled and (tfTransact in FTraceFlags) then
    WriteToDatabase(tfTransact, tr, 'Commit');
end;

procedure TGedeminSQLMonitor.TRCommitRetaining(tr: TIBTransaction);
begin
  if FEnabled and (tfTransact in FTraceFlags) then
    WriteToDatabase(tfTransact, tr, 'CommitRetaining');
end;

procedure TGedeminSQLMonitor.TRRollback(tr: TIBTransaction);
begin
  if FEnabled and (tfTransact in FTraceFlags) then
    WriteToDatabase(tfTransact, tr, 'Rollback');
end;

procedure TGedeminSQLMonitor.TRRollbackRetaining(tr: TIBTransaction);
begin
  if FEnabled and (tfTransact in FTraceFlags) then
    WriteToDatabase(tfTransact, tr, 'RollbackRetaining');
end;

procedure TGedeminSQLMonitor.TRStart(tr: TIBTransaction);
begin
  if FEnabled and (tfTransact in FTraceFlags) then
    WriteToDatabase(tfTransact, tr, 'StartTransaction');
end;

procedure TGedeminSQLMonitor.WriteToDatabase(F: TTraceFlag; AComp: TComponent; const AMethod: String;
  const ASQL, AParams: String);
var
  S: String;
begin
  if AComp = nil then
    S := ''
  else begin
    if (AComp.Owner <> nil) and (AComp.Owner.Name > '') then
      S := AComp.Owner.Name + '.';
    if AComp.Name > '' then
    begin
      S := S + AComp.Name;
      if AMethod > '' then
        S := S + '.';
    end else begin
      if AMethod > '' then
        S := AComp.ClassName + '($' + IntToHex(Integer(AComp), 8) + ').'
      else
        S := '';
    end;
  end;

  if AMethod > '' then
    S := S + AMethod
  else begin
    if S > '' then
      S := '-- ' + S + #13#10 + ASQL
    else
      S := ASQL;

    if AParams > '' then
      S := S + #13#10 + AParams;  
  end;

  try
    {$IFDEF WITH_INDY}
    if gdccClient <> nil then
      gdccClient.AddLogRecord('sql_monitor', S);
    {$ENDIF}
  except
    on E: Exception do
    begin
      MessageBox(0,
        PChar('Произошла ошибка при записи в SQL журнал. Трассировка будет отключена.'#13#10#13#10 +
          E.Message),
        'Ошибка',
        MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
      FEnabled := False;
    end;
  end;
end;

initialization
  GedeminSQLMonitor := nil;

finalization
  FreeAndNil(GedeminSQLMonitor);
end.
