unit rpl_ReplicationManager_unit;

interface
uses rpl_BaseTypes_unit, Classes, rpl_ResourceString_unit, SysUtils, IBSQL, DB,
  Contnrs, rpl_const, rpl_mnRelations_unit, rpl_ProgressState_Unit,
  IBScript, Dialogs, rpl_GlobalVars_unit, IBDataBase, IBServices;

type
  TrpReplicationManager = class;

  TmnReplicationDBList = class(TReplicationDBList)
  public
    procedure LoadAll; override;
    function MainDB: TReplicationDB;
    //Возврыщает Тру если имя базы уникально в схеме репликации
    function CheckUniqueDBName(DBName: string): Integer;
    function GetUniqueDBName(Prefix: string): string;
  end;

  TrplBaseScriptClause = class (TObject)
  private
    FNextScript: TrplBaseScriptClause;
    FPrevScript: TrplBaseScriptClause;
    FStop: Boolean;
    FIndex: Integer;
    procedure SetNextScript(const Value: TrplBaseScriptClause);
    procedure SetPrevScript(const Value: TrplBaseScriptClause);
    procedure SetIndex(const Value: Integer);
  protected
    procedure DoExecute; virtual;
  public
    destructor Destroy; override;
    function Description: string; virtual; abstract;
    procedure Execute; virtual;
    procedure Register(Strings: TStrings); virtual;
    property NextScript: TrplBaseScriptClause read FNextScript write
            SetNextScript;
    property PrevScript: TrplBaseScriptClause read FPrevScript write 
            SetPrevScript;
    property Stop: Boolean read FStop write FStop;
    property Index: Integer read FIndex write SetIndex;
  end;

  TrplBaseScript = class (TrplBaseScriptClause)
  private
    FScriptClauses: TObjectList;
    function GetClauses(Index: Integer): TrplBaseScriptClause;
  protected
    procedure DoExecute; override;
  public
    destructor Destroy; override;
    procedure Execute; override;
    function AddClause(Clause: TrplBaseScriptClause): Integer;
    function ClauseCount: Integer;
    procedure Clear;
    function Description: string; override;
    procedure Register(Strings: TStrings); override;
    procedure RemoveClause(Clause: TrplBaseScriptClause);
    property Clauses[Index: Integer]: TrplBaseScriptClause read GetClauses;
  end;

  TrpReplicationManager = class (TObject, IConnectChangeNotify)
  private
    FDirection: TReplDirection;
    FGeneratorName: string;
    FKeyDivider: string;
    FPrimeKeyType: TPrimeKeyType;
    FScript: TrplBaseScript;
    FTriggerSQL: TIBSQL;
    FDBList: TmnReplicationDBList;
    FDBListOld: TStringList;
    FErrorDecision: TErrorDecision;
    FReplSchemaKey: Integer;
    FErrors: TStrings;

    FPreserve: Boolean;
    FRelations: TmnRelations;
    FGeneratorMask: string;

    procedure CheckInTransaction;
    procedure CheckTriggerSQL;
    function GetScript: TrplBaseScript;
    procedure SetGeneratorName(const Value: string);
    function GetRelations: TmnRelations;
    function GetDBList: TmnReplicationDBList;
    function GetDBListOld: TStringList;
    procedure SetErrorDecision(const Value: TErrorDecision);
  protected
    function RoleExist(Role: TRole): Boolean;
    procedure CheckRole(Role: TRole);
    procedure GrandLog;

    procedure CheckDomane(Domane: TDomane);
    procedure CheckDomanes;
    procedure CheckGenerator(Generator: TGenerator);
    procedure CheckGenerators;
    procedure CheckTable(Table: TTable);
    procedure CheckTables;
    procedure CreateTrigger(Trigger: TTrigger);
    function CreateTriggersActionCount: Integer;
    procedure CreateTriggers;
    procedure CreateRole;
    procedure DropRole;

    procedure CheckException(AException: TExcept);
    procedure CheckExceptions;

    procedure DropDomane(Domane: TDomane);
    procedure DropDomanes;
    procedure DropGenerator(Generator: TGenerator);
    procedure DropGenerators;
    procedure DropTable(Table: TTable);
    //Удаление таблиц и триггеров на системные таблицы
    procedure DropTables;
    procedure DropException(AException: TExcept);
    procedure DropExceptions;

    procedure DropTrigger(Trigger: TTrigger);
    function DropTriggersActionCount: Integer;
    procedure DropTriggers(const AMainDB: boolean = False);
    function GetTriggerName(RelationKey: Integer; Action: string): string;
    function NeedDropDomanes: Boolean;
    function NeedDropGenerators: Boolean;
    function NeedDropTables: Boolean;
    function NeedDropTriggers: Boolean;
    function NeedDeactivisation: boolean;

    function FillTablesActionCount: Integer;
    procedure FillTables;
    procedure UpdateReplDBList;

    function CreateRUIDsActionCount: Integer;

    procedure MakeCopy(Source, Destination: string);
    function CopyFile(Sender: TObject; Source, Destination: string;
      PeriodCount: Integer): Boolean;
    function CheckDiskFree(Path: string; NeedSpace: Integer): Boolean;
    function FileSize(FileName: string): integer;

    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    procedure DoAfterSuccessfullConnection;
    procedure DoBeforeDisconnect;
    procedure DoAfterConnectionLost;

    procedure Deactivization;
    procedure Activization;
  public
    constructor Create;
    destructor Destroy; override;
    procedure CreateRUIDs;
    procedure CreateMetaData;
    procedure GetReport(const Strings: TStrings);
    procedure DropAllMetaData;
    procedure ActivateTrigger(Trigger: TTrigger; State: TTriggerState);

    property Direction: TReplDirection read FDirection write FDirection;
    property GeneratorName: string read FGeneratorName write SetGeneratorName;
    property GeneratorMask: string read FGeneratorMask write FGeneratorMask;
    property KeyDivider: string read FKeyDivider write FKeyDivider;
    property PrimeKeyType: TPrimeKeyType read FPrimeKeyType write FPrimeKeyType;
    property ErrorDecision: TErrorDecision read FErrorDecision write SetErrorDecision;
    property Script: TrplBaseScript read GetScript;
    property Relations: TmnRelations read GetRelations;
    //Список таблиц, задействованных в схеме репликации
    property DBList: TmnReplicationDBList read GetDBList;
    property DBListOld: TStringList read GetDBListOld;
    function TriggerExist(Trigger: TTrigger): Boolean;
  end;

  TrplDropDomanes = class (TrplBaseScriptClause)
  protected
    procedure DoExecute; override;
  public
    function Description: string; override;
  end;

  TrplDropOldDomanes = class (TrplDropDomanes)
  public
    function Description: string; override;
  end;

  TrplDropTriggers = class (TrplBaseScriptClause)
  protected
    procedure DoExecute; override;
  public
    function Description: string; override;
  end;

  TrplDropTriggersMainDB = class (TrplBaseScriptClause)
  protected
    procedure DoExecute; override;
  public
    function Description: string; override;
  end;

  TrplDropOldTriggers = class (TrplDropTriggers)
  public
    function Description: string; override;
  end;

  TrplDropGenerators = class (TrplBaseScriptClause)
  protected
    procedure DoExecute; override;
  public
    function Description: string; override;
  end;
  
  TrplDropTables = class (TrplBaseScriptClause)
  protected
    procedure DoExecute; override;
  public
    function Description: string; override;
  end;

  TrplDropOldTables = class (TrplDropTables)
  public
    function Description: string; override;
  end;
  
  TrplCreateDomanes = class (TrplBaseScriptClause)
  protected
    procedure DoExecute; override;
  public
    function Description: string; override;
  end;

  TrplCreateGenerators = class (TrplBaseScriptClause)
  protected
    procedure DoExecute; override;
  public
    function Description: string; override;
  end;

  TrplCreateMetaDate = class (TrplBaseScript)
  public
    constructor Create;
  end;

  TrplCreateTables = class (TrplBaseScriptClause)
  protected
    procedure DoExecute; override;
  public
    function Description: string; override;
  end;
  
  TrplCreateTriggers = class (TrplBaseScriptClause)
  protected
    procedure DoExecute; override;
  public
    function Description: string; override;
  end;

  TrplCreateRuids = class (TrplBaseScriptClause)
  protected
    procedure DoExecute; override;
  public
    function Description: string; override;
  end;
  
  TrplDropMetaData = class (TrplBaseScript)
  public
    constructor Create;
  end;

  TrplMakeCopy = class (TrplBaseScriptClause)
  private
    FDestination: string;
    FSource: string;
  protected
    procedure DoExecute; override;
  public
    function Description: string; override;
    property Destination: string read FDestination write FDestination;
    property Source: string read FSource write FSource;
  end;

  TrplFillTables = class (TrplBaseScriptClause)
  protected
    procedure DoExecute; override;
  public
    function Description: string; override;
  end;

  TrplActivization = class (TrplBaseScriptClause)
  protected
    procedure DoExecute; override;
  public
    function Description: string; override;
  end;

  TrplDeactivization = class (TrplBaseScriptClause)
  protected
    procedure DoExecute; override;
  public
    function Description: string; override;
  end;

  TrplScript = class (TrplBaseScript)
  public
    procedure Execute; override;
    function Description: string; override;
  end;

  TrplDropOldMetaData = class (TrplBaseScript)
  public
    constructor Create;
  end;

  TrplCreateRole = class (TrplBaseScriptClause)
  protected
    procedure DoExecute; override;
  public
    function Description: string; override;
  end;

  TrplDropRole = class (TrplBaseScriptClause)
  protected
    procedure DoExecute; override;
  public
    function Description: string; override;
  end;

  TrplUpdateReplDBList = class (TrplBaseScriptClause)
  protected
    procedure DoExecute; override;
  public
    function Description: string; override;
  end;

function ReplicationManager: TrpReplicationManager;

implementation

uses IB, IBErrorCodes, rpl_ReplicationServer_unit;

var
  _ReplicationManager: TrpReplicationManager;

const
  cSelectFromRelations = 'SELECT * FROM rpl$relations';

function ReplicationManager: TrpReplicationManager;
begin
  if _ReplicationManager = nil then
    _ReplicationManager := TrpReplicationManager.Create;
  Result := _ReplicationManager;
end;

{
******************************* TrplDropDomanes ********************************
}
function TrplDropDomanes.Description: string;
begin
  Result := DropDomanes
end;

procedure TrplDropDomanes.DoExecute;
var
  RM: TrpReplicationManager;
begin
  RM := ReplicationManager;
  RM.DropDomanes;
end;

{
****************************** TrplDropOldDomanes ******************************
}
function TrplDropOldDomanes.Description: string;
begin
  Result := DropOldDomanes
end;

{
******************************* TrplDropTriggers *******************************
}
function TrplDropTriggers.Description: string;
begin
  Result := DropTriggers;
end;

procedure TrplDropTriggers.DoExecute;
var
  RM: TrpReplicationManager;
begin
  RM := ReplicationManager;
  RM.DropTriggers;
end;

{ TrplDropTriggersMainDB }

function TrplDropTriggersMainDB.Description: string;
begin
  Result := DropTriggersMainDB;
end;

procedure TrplDropTriggersMainDB.DoExecute;
var
  RM: TrpReplicationManager;
begin
  RM:= ReplicationManager;
  RM.DropTriggers(True);
end;

{
***************************** TrplDropOldTriggers ******************************
}
function TrplDropOldTriggers.Description: string;
begin
  Result := DropOldTriggers;
end;

{
****************************** TrplDropGenerators ******************************
}
function TrplDropGenerators.Description: string;
begin
  Result := DropGenerators
end;

procedure TrplDropGenerators.DoExecute;
var
  RM: TrpReplicationManager;
begin
  RM := ReplicationManager;
  RM.DropGenerators;
end;

{
******************************** TrplDropTables ********************************
}
function TrplDropTables.Description: string;
begin
  Result := DropTables;
end;

procedure TrplDropTables.DoExecute;
var
  RM: TrpReplicationManager;
begin
  RM := ReplicationManager;
  RM.DropTables;
end;

{
****************************** TrplDropOldTables *******************************
}
function TrplDropOldTables.Description: string;
begin
  Result := DropOldTables;
end;

{
****************************** TrplCreateDomanes *******************************
}
function TrplCreateDomanes.Description: string;
begin
  Result := CreateDomanes;
end;

procedure TrplCreateDomanes.DoExecute;
begin
  ReplicationManager.CheckDomanes
end;

{
***************************** TrplCreateGenerators *****************************
}
function TrplCreateGenerators.Description: string;
begin
  Result := CreateGenerators;
end;

procedure TrplCreateGenerators.DoExecute;
begin
  ReplicationManager.CheckGenerators
end;

{
****************************** TrplCreateMetaDate ******************************
}
constructor TrplCreateMetaDate.Create;
begin
  inherited Create;
  AddClause(TrplCreateGenerators.Create);
  AddClause(TrplCreateDomanes.Create);
  AddClause(TrplCreateTables.Create);
end;

{
******************************* TrplCreateTables *******************************
}
function TrplCreateTables.Description: string;
begin
  Result := CreateTables;
end;

procedure TrplCreateTables.DoExecute;
begin
  ReplicationManager.CheckTables;
end;

{
****************************** TrplCreateTriggers ******************************
}
function TrplCreateTriggers.Description: string;
begin
  Result := CreateTriggers;
end;

procedure TrplCreateTriggers.DoExecute;
begin
  ReplicationManager.CreateTriggers;
end;

{
******************************* TrplCreateRuids ********************************
}
function TrplCreateRuids.Description: string;
begin
  Result := CreateRuid;
end;

procedure TrplCreateRuids.DoExecute;
begin
  ReplicationManager.CreateRUIDs;
end;

{
******************************* TrplDropMetaData *******************************
}
constructor TrplDropMetaData.Create;
begin
  inherited Create;
  AddClause(TrplDropTriggers.Create);
  AddClause(TrplDropTables.Create);
  AddClause(TrplDropDomanes.Create);
  AddClause(TrplDropGenerators.Create);
end;

{
********************************* TrplMakeCopy *********************************
}
function TrplMakeCopy.Description: string;
begin
  Result := Format(MakeCopy, [FDestination])
end;

procedure TrplMakeCopy.DoExecute;
begin
  ReplicationManager.MakeCopy(FSource, FDestination);
end;

{
******************************** TrplFillTables ********************************
}
function TrplFillTables.Description: string;
begin
  Result := FillTables;
end;

procedure TrplFillTables.DoExecute;
begin
  ReplicationManager.FillTables
end;

{
********************************** TrplScript **********************************
}
function TrplScript.Description: string;
begin
  Result := ''
end;

{
***************************** TrplDropOldMetaData ******************************
}
constructor TrplDropOldMetaData.Create;
begin
  inherited Create;
  AddClause(TrplDropOldTriggers.Create);
  AddClause(TrplDropTables.Create);
end;

{
***************************** TrplBaseScriptClause *****************************
}
destructor TrplBaseScriptClause.Destroy;
var
  N, P: TrplBaseScriptClause;
begin
  N := FNextScript;
  P := FPrevScript;
  
  if N <> nil then
  begin
    FNextScript := nil;
    N.FPrevScript := P;
  end;
  
  if P <> nil then
  begin
    FPrevScript := nil;
    P.FNextScript := N;
  end;
  inherited Destroy;
end;

procedure TrplBaseScriptClause.DoExecute;
begin
  
end;

procedure TrplBaseScriptClause.Execute;
var
  ErrorCount: Integer;
begin
  ProgressState.MajorProgress(Self, paBefore);
  ErrorCount := Errors.Count;
  DoExecute;
  if ErrorCount <> Errors.Count then
    ProgressState.MajorProgress(Self, paError)
  else
    ProgressState.MajorProgress(Self, paSucces);
end;

procedure TrplBaseScriptClause.Register(Strings: TStrings);
begin
  FIndex := Strings.Add(Description);
end;

procedure TrplBaseScriptClause.SetIndex(const Value: Integer);
begin
  FIndex := Value;
end;

procedure TrplBaseScriptClause.SetNextScript(const Value: TrplBaseScriptClause);
begin
  if FNextScript <> Value then
  begin
    if FPrevScript <> nil then
      FNextScript.FPrevScript := nil;
  
    FNextScript := Value;
    if FNextScript <> nil then
      FNextScript.FPrevScript := Self;
  end;
end;

procedure TrplBaseScriptClause.SetPrevScript(const Value: TrplBaseScriptClause);
begin
  if FPrevScript <> Value then
  begin
    if FPrevScript <> nil then
      FPrevScript.FNextScript := nil;
  
    FPrevScript := Value;
    if FPrevScript <> nil then
      FPrevScript.FNextScript := Self;
  end;
end;

{
******************************** TrplBaseScript ********************************
}
destructor TrplBaseScript.Destroy;
begin
  FScriptClauses.Free;
  inherited Destroy;
end;

function TrplBaseScript.AddClause(Clause: TrplBaseScriptClause): Integer;
begin
  if FScriptClauses = nil then
    FScriptClauses := TObjectList.Create;
  Result := FScriptClauses.Add(Clause);
end;

function TrplBaseScript.ClauseCount: Integer;
begin
  Result := 0;
  if FScriptClauses <> nil then
    Result := FScriptClauses.Count;
end;

procedure TrplBaseScript.Clear;
begin
  if FScriptClauses <> nil then
  begin
    FScriptClauses.Clear;
    FreeAndNil(FScriptClauses);
  end;
end;

procedure TrplBaseScript.DoExecute;
var
  I: Integer;
begin
  if FScriptClauses <> nil then
  begin
    for I := 0 to FScriptClauses.Count - 1 do
    begin
      TrplBaseScriptClause(FScriptClauses.Items[I]).Execute;
    end;
  end;
end;

function TrplBaseScript.GetClauses(Index: Integer): TrplBaseScriptClause;
begin
  Result := nil;
  if FScriptClauses <> nil then
    Result := TrplBaseScriptClause(FScriptClauses.Items[Index])
end;

procedure TrplBaseScript.Register(Strings: TStrings);
var
  I: Integer;
begin
  if FScriptClauses <> nil then
  begin
    for I := 0 to FScriptClauses.Count - 1 do
    begin
      TrplBaseScriptClause(FScriptClauses.Items[I]).Register(Strings);
    end;
  end;
end;

procedure TrplBaseScript.RemoveClause(Clause: TrplBaseScriptClause);
var
  Index: Integer;
begin
  if FScriptClauses <> nil then
  begin
    Index := FScriptClauses.IndexOf(Clause);
    if Index > - 1 then
      FScriptClauses.Extract(Clause);
  
    if FScriptClauses.Count =  0 then
      FreeAndNil(FScriptClauses)
  end;
end;

{
**************************** TrpReplicationManager *****************************
}
destructor TrpReplicationManager.Destroy;
begin
  FTriggerSQL.Free;
  FScript.Free;
  FErrors.Free;
  ReplDataBase.RemoveConnectNotify(Self);
  FRelations.Free;
  inherited;
end;

procedure TrpReplicationManager.ActivateTrigger(Trigger: TTrigger; State: 
        TTriggerState);
var
  SQL: TIBSQL;
  TriggerState: string;
begin
  if TriggerExist(Trigger) then
  begin
    {$IFDEF DEBUG}
    CheckInTransaction;
    {$ENDIF}
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := ReplDataBase.Transaction;
      ReplDataBase.Transaction.StartTransaction;
      try
        if State = tsActive then
          TriggerState := 'ACTIVE'
        else
          TriggerState := 'INACTIVE';

        SQL.SQL.Add(Format('ALTER TRIGGER %s %s', [Trigger.TriggerName, TriggerState]));
        SQL.ExecQuery;
        ReplDataBase.Transaction.Commit;
      except
        on E: Exception do begin
          ReplDataBase.Transaction.Rollback;
          raise Exception.Create(Trigger.TriggerName + #13#10 + Trigger.RelationName + #13#10 + E.Message);
        end;
      end;
    finally
      SQL.Free;
    end;
  end;
end;

procedure TrpReplicationManager.CheckDomane(Domane: TDomane);
var
  SQL: TIBSQL;
begin
  if not ReplDataBase.DomaneExist(Domane) then
  begin
    {$IFDEF DEBUG}
    CheckInTransaction;
    {$ENDIF}
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := ReplDataBase.Transaction;
      ReplDataBase.Transaction.StartTransaction;
      try
        SQL.SQL.Add(Format('CREATE DOMAIN %s AS %s', [Domane.Name, Domane.Description]));
        SQL.ExecQuery;
        ReplDataBase.Transaction.Commit;
      except
        on E: Exception do
        begin
          ReplDataBase.Transaction.Rollback;
          Errors.Add(Format(ERR_CREATE_DOMANE, [Domane.Name]) + E.Message);
        end;
      end;
    finally
      SQL.Free;
    end;
  end;
end;

procedure TrpReplicationManager.CheckDomanes;
var
  I: Integer;
begin
  for I := 0 to DomaneCount - 1 do
    CheckDomane(Domanes[I]);

  CheckExceptions;  
end;

procedure TrpReplicationManager.CheckGenerator(Generator: TGenerator);
var
  SQL: TIBSQL;
begin
  if not ReplDataBase.GeneratorExist(Generator) then
  begin
    {$IFDEF DEBUG}
    CheckInTransaction;
    {$ENDIF}
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := ReplDataBase.Transaction;
      ReplDataBase.Transaction.StartTransaction;
      try
        SQL.SQL.Add(Format('CREATE GENERATOR %s', [Generator.Name]));
        SQL.ExecQuery;
        SQL.SQL.Clear;
        SQL.SQL.Add(Format('SET GENERATOR %s TO %d', [Generator.Name, Generator.Value]));
        SQL.ExecQuery;
        ReplDataBase.Transaction.Commit;
      except
        on E: Exception do
        begin
          ReplDataBase.Transaction.Rollback;
          Errors.Add(Format(ERR_CREATE_GENERATOR, [Generator.Name]) + E.Message);
        end;
      end;
    finally
      SQL.Free;
    end;
  end;
end;

procedure TrpReplicationManager.CheckGenerators;
var
  I: Integer;
begin
  for I := 0 to GeneratorCount - 1 do
    CheckGenerator(Generators[I]);
end;


procedure TrpReplicationManager.CheckInTransaction;
begin
  {$IFDEF DEBUG}
  if ReplDataBase.Transaction.InTransaction then
    raise Exception.Create('Перед вызовом данной функции транзанкция должна быть закрыта');
  {$ENDIF}
end;

procedure TrpReplicationManager.CheckTable(Table: TTable);
var
  SQl: TIBScript;
begin
  if not ReplDataBase.TableExist(Table) then
  begin
    {$IFDEF DEBUG}
    CheckInTransaction;
    {$ENDIF}
    SQl := TIBScript.Create(nil);
    try
      SQL.Transaction := ReplDataBase.Transaction;
      SQL.Database := ReplDataBase;
      ReplDataBase.Transaction.StartTransaction;
      try
        SQL.Script.Text := Table.Body;
//        SQL.ParamCheck := False;
        SQL.ExecuteScript;
        ReplDataBase.Transaction.Commit;
      except
        on E: Exception do
        begin
          ReplDataBase.Transaction.Rollback;
          Errors.Add(Format(ERR_CREATE_TABLE, [Table.Name]) + E.Message);
        end;
      end;
    finally
      SQL.Free;
    end;
  end;
end;

procedure TrpReplicationManager.CheckTables;
var
  I: Integer;
begin
  for I := 0 to TableCount - 1 do
    CheckTable(Tables[I]);
  {$IFNDEF GEDEMIN}
  case PrimeKeyType of
    ptUniqueInRelation: CheckTable(GD_RUID_RU);
    ptUniqueInDB: CheckTable(GD_RUID_DBU);
  end;
  {$ENDIF}
  //Создаем триггеры на системные таблицы и таблицы репликации
  for I := 0 to ReplTriggerCount - 1 do
  begin
    if not TriggerExist(ReplTriggers[I]) then
      CreateTrigger(ReplTriggers[I]);
  end;

  {$IFNDEF GEDEMIN}
  //Даем права доступа
//  GrandLog;
  {$ENDIF}
end;

procedure TrpReplicationManager.CheckTriggerSQL;
begin
  if FTriggerSQL = nil then
  begin
    FTriggerSQL := TIBSQL.Create(nil);
    FTriggerSQL.Transaction := ReplDataBase.ReadTransaction;
    FTriggerSQL.SQL.Add('SELECT * FROM rdb$triggers WHERE /*rdb$relation_name = ' +
      ' :relationname AND*/ rdb$trigger_name = :triggername');
  end;
  FTriggerSQL.Close;
end;

procedure TrpReplicationManager.CreateRUIDs;
var
  I, J: Integer;
  R: TmnRelation;
  F: TmnField;
  SQL: TIBSQL;
  DBKey: Integer;
begin
  ProgressState.MaxMinor := CreateRUIDsActionCount;
  CheckInTransaction;
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := ReplDataBase.Transaction;
    SQL.Transaction.StartTransaction;
    try
      DBKey := DBList.MainDB.DBKey;
      for I := 0 to Relations.Count - 1 do
      begin
        R := TmnRelation(Relations.RelationsByIndex[I]);
        if R.Checked then
        begin
          for J := 0 to R.Fields.Count - 1 do
          begin
            F := TmnField(R.Fields[J]);
            { TODO : Пока будем генерить РУИД для полей типа интежер }
            if F.Checked and (F.FieldType in [tfInteger{, tfInt64, tfSmallInt}]) and
              (F.FieldSubType = istFieldType) and (F.IsForeign or F.IsPrimeKey or
              R.NeedSaveRUID(F)) then
            begin
              {$IFDEF GEDEMIN}
                //Для гедемина различаются руиды записей с ид меньше и больше cstUserIDStart
              SQL.SQL.Text := Format(
                 'INSERT INTO gd_ruid (id, xid, dbid) ' +
                 '  SELECT z.%s, z.%s, %d FROM %s z WHERE NOT EXISTS (SELECT ' +
                 ' 1 FROM gd_ruid r WHERE r.id = z.%s) AND z.%s >= ' + IntToStr(cstUserIDStart),
                 [F.FieldName, F.FieldName, DBKey, R.RelationName, F.FieldName,
                 F.FieldName]);
              SQL.ExecQuery;
              SQL.Close;
              SQL.SQL.Text := Format(
                 'INSERT INTO gd_ruid (id, xid, dbid) ' +
                 '  SELECT z.%s, z.%s, 17 FROM %s z WHERE NOT EXISTS (SELECT ' +
                 ' 1 FROM gd_ruid r WHERE r.id = z.%s) AND z.%s < ' + IntToStr(cstUserIDStart),
                 [F.FieldName, F.FieldName, R.RelationName, F.FieldName,
                 F.FieldName]);
              SQL.ExecQuery;
              SQL.Close;
              {$ELSE}
              if PrimeKeyType = ptUniqueInRelation then
                SQL.SQL.Text := Format(
                   'INSERT INTO gd_ruid (id, xid, relationid, dbid) ' +
                   '  SELECT z.%s, z.%s, %d, %d FROM %s z WHERE NOT EXISTS (SELECT ' +
                   ' 1 FROM gd_ruid r WHERE r.id = z.%s) AND NOT z.%s IS NULL',
                   [F.FieldName, F.FieldName, R.RelationKey, DBKey,
                   R.RelationName, F.FieldName, F.FieldName, F.FieldName])
              else
                SQL.SQL.Text := Format(
                   'INSERT INTO gd_ruid (id, xid, dbid) ' +
                   '  SELECT z.%s, z.%s, %d FROM %s z WHERE NOT EXISTS (SELECT ' +
                   ' 1 FROM gd_ruid r WHERE r.id = z.%s) AND NOT z.%s IS NULL',
                   [F.FieldName, F.FieldName, DBKey,
                   R.RelationName, F.FieldName, F.FieldName]);

              SQL.ExecQuery;
              SQL.Close;
              {$ENDIF}
              ProgressState.MinorProgress(Self);
            end;
          end;
        end;
      end;
      SQL.Transaction.Commit;
    except
      on E: Exception do
      begin
        SQL.Transaction.Rollback;
        Errors.Add(E.Message);
      end;
    end;
  finally
    SQL.Free;
  end;
end;

procedure TrpReplicationManager.CreateTrigger(Trigger: TTrigger);
var
  SQL, qFields: TIBSQL;
  TriggerAction, State, ActionPosition, Cond: string;
begin
  if not TriggerExist(Trigger) then
  begin
    {$IFDEF DEBUG}
    CheckInTransaction;
    {$ENDIF}
    SQL := TIBSQL.Create(nil);
    qFields := TIBSQL.Create(nil);
    try
      SQL.Transaction := ReplDataBase.Transaction;
      qFields.Transaction := ReplDataBase.Transaction;

      ReplDataBase.Transaction.StartTransaction;

      try
        if Trigger.State = tsActive then
          State := 'ACTIVE'
        else
          State := 'INACTIVE';

        case Trigger.Action of
          taInsert: TriggerAction := 'INSERT';
          taUpdate: TriggerAction := 'UPDATE';
          taDelete: TriggerAction := 'DELETE';
        end;

        case Trigger.ActionPosition of
          tapBefore: ActionPosition := 'BEFORE';
          tapAfter: ActionPosition := 'AFTER';
        end;

        Cond := '';

        if (Trigger.Action = taUpdate) and (Trigger.ActionPosition = tapAfter) then
        begin
          qFields.SQL.Text := 'SELECT rf.RDB$FIELD_NAME FROM rdb$relation_fields rf ' +
            'JOIN rdb$fields f ON rf.rdb$field_source = f.rdb$field_name AND f.rdb$computed_blr IS NULL ' +
            ' AND rf.rdb$relation_name = ''' + UpperCase(Trigger.RelationName) + ''' ';
          qFields.ExecQuery;
          while not qFields.Eof do
          begin
            Cond := Cond + '(NEW.' + qFields.Fields[0].AsTrimString + '<>OLD.' +
              qFields.Fields[0].AsTrimString + ') OR ';
            qFields.Next;
          end;
          qFields.Close;
          SetLength(Cond, Length(Cond) - 4);
          Cond := 'IF (' + Cond + ') THEN ';
        end;

        SQL.SQL.Add(
          Format('CREATE TRIGGER %s FOR %s '#13#10'%s %s %s POSITION %d'#13#10 +
            ' AS'#13#10'BEGIN'#13#10'%s'#13#10'END',
          [Trigger.TriggerName, Trigger.RelationName, State, ActionPosition,
          TriggerAction, Trigger.Position, Cond + Trigger.Body]));
        SQL.ParamCheck := False;
        SQL.ExecQuery;
        ReplDataBase.Transaction.Commit;
      except
        on E: Exception do
        begin
          ReplDataBase.Transaction.Rollback;
          Errors.Add(Format(ERR_CREATE_TRIGGER, [Trigger.TriggerName]) + E.Message);
        end;
      end;
    finally
      SQL.Free;
      qFields.Free;
    end;
  end;
end;

procedure TrpReplicationManager.CreateTriggers;
var
  I: Integer;
  Trigger: TTrigger;
  R: TmnRelation;
  SQL: TIBSQL;

    // Возвращает строку для регистрации ключей
    function GetKeyLine(RelationKey: Integer; KeyType: String): String;
    var
      I: Integer;
      LSep: string;
      Relation: TrpRelation;
    begin
      Result := '';
      LSep := '||''' + KeyDivider + '''||';
      Relation := Relations.Relations[RelationKey];
      if Relation <> nil then
      begin
        for I := 0 to Relation.Keys.Count - 1 do
        begin
          if Result > '' then
            Result := Result + LSep;

          Result := Result + KeyType + '.' + Relation.Keys[I].FieldName;
        end;
      end else
        raise Exception.Create(InvalidRelationKey);
    end;

    function GetForeignUpdate(RelationKey: Integer): string;
    var
      R, RefR: TmnRelation;
      I, J, K: Integer;
      F, FF: TmnField;
      Index: Integer;
      UIndex: TrpUniqueIndex;
      WhereClause: string;
      L: TList;
    begin
      Result := '';
      R := TmnRelation(Relations.Relations[RelationKey]);
      if R <> nil then
      begin
        L := TList.Create;
        try
          for I := 0 to R.Fields.Count - 1 do
          begin
            F := TmnField(R.Fields[I]);
            if F.IsForeign then
            begin
              RefR := TmnRelation(F.ReferenceField.Relation);
              if L.IndexOf(RefR) = - 1 then
              begin
                L.Add(RefR);
                Index := RefR.UniqueIndices.IndexOfByField(F.ReferenceField.FieldName);
                if Index > - 1 then
                begin
                  UIndex := RefR.UniqueIndices.Indices[Index];
                  WhereClause := '';

                  for J := 0 to UIndex.Fields.Count - 1 do
                  begin
                    for K := 0 to R.Fields.Count - 1 do
                    begin
                      if R.Fields[K].IsForeign and (R.Fields[K].ReferenceField = UIndex.Fields[J]) then
                      begin
                        FF := TmnField(R.Fields[K]);
                        if WhereClause > '' then
                          WhereClause := WhereClause + ' AND ';

                        WhereClause := WhereClause + Format('new.%s = %s',
                          [FF.FieldName, UIndex.Fields[J].FieldName]);
                      end;
                    end;
                  end;

                  Result := Result + Format(cForeignUpdate, [F.FieldName, refR.RelationName,
                    F.ReferenceField.FieldName, F.ReferenceField.FieldName,
                    WhereClause]);
                end else
                  raise Exception.Create(InvalidFieldName);
              end;
            end;
          end;
        finally
          L.Free;
        end;
      end else
        raise Exception.Create(InvalidRelationKey);
    end;

  const
    cNew = 'NEW';
    cOLD = 'OLD';
    cNull = 'NULL';
begin
  ProgressState.MaxMinor := CreateTriggersActionCount;
  Relations.Sort;
  {$IFDEF DEBUG}
  CheckInTransaction;
  {$ENDIF}
  SQL:= TIBSQL.Create(nil);
  SQL.ParamCheck:= False;
  try
    for I := 0 to Relations.Count - 1 do begin
      R:= Relations[I];
      if R.Checked then begin
        if not TriggerExist(Trigger) then begin
          SQL.Transaction:= ReplDataBase.Transaction;

          if R.TriggerAI.Checked then begin
            ReplDataBase.Transaction.StartTransaction;
            try
              SQL.SQL.Text:= R.TriggerAI.CreateDll;
              SQL.ExecQuery;
              ReplDataBase.Transaction.Commit;
            except
              on E: Exception do begin
                ReplDataBase.Transaction.Rollback;
                Errors.Add(Format(ERR_CREATE_TRIGGER, [R.TriggerAI.TriggerName]) + E.Message);
              end;
            end;
          end;

          if R.TriggerAD.Checked then begin
            ReplDataBase.Transaction.StartTransaction;
            try
              SQL.SQL.Text:= R.TriggerAD.CreateDll;
              SQL.ParamCheck := False;
              SQL.ExecQuery;
              ReplDataBase.Transaction.Commit;
            except
              on E: Exception do begin
                ReplDataBase.Transaction.Rollback;
                Errors.Add(Format(ERR_CREATE_TRIGGER, [R.TriggerAD.TriggerName]) + E.Message);
              end;
            end;
          end;

          if R.TriggerAU.Checked then begin
            ReplDataBase.Transaction.StartTransaction;
            try
              SQL.SQL.Text:= R.TriggerAU.CreateDll;
              SQL.ParamCheck := False;
              SQL.ExecQuery;
              ReplDataBase.Transaction.Commit;
            except
              on E: Exception do begin
                ReplDataBase.Transaction.Rollback;
                Errors.Add(Format(ERR_CREATE_TRIGGER, [R.TriggerAU.TriggerName]) + E.Message);
              end;
            end;
          end;
        end;


(*      Trigger.State := tsActive;
      Trigger.ActionPosition := tapAfter;
      Trigger.Position := cTriggerPos;
      Trigger.RelationName := R.RelationName;
      Trigger.Action := taInsert;
      Trigger.TriggerName := GetTriggerName(R.RelationKey,
        atInsert);
      Trigger.Body := {GetForeignUpdate(R.RelationKey) + }
        Format(cTriggerBody, [R.RelationKey,
        '''I''', {cNull}GetKeyLine(R.RelationKey, cNew),
        GetKeyLine(R.RelationKey, cNew)]);
      CreateTrigger(Trigger);

      Trigger.Action := taUpdate;
      Trigger.TriggerName := GetTriggerName(R.RelationKey,
        atUpdate);
      Trigger.Body := {GetForeignUpdate(R.RelationKey) +}
        Format(cTriggerBody, [R.RelationKey,
        '''U''', GetKeyLine(R.RelationKey, cOld),
        GetKeyLine(R.RelationKey, cNew)]);
      CreateTrigger(Trigger);

      Trigger.Action := taDelete;
      Trigger.TriggerName := GetTriggerName(R.RelationKey,
        atDelete);
      Trigger.Body := Format(cTriggerBody, [R.RelationKey,
        '''D''', GetKeyLine(R.RelationKey, cOld),
        GetKeyLine(R.RelationKey, cOld){cNull}]);
      CreateTrigger(Trigger);*)
      end;
      ProgressState.MinorProgress(Self);
    end;
  finally
    SQL.Free;
  end;
  //Создание триггеров на системные таблицы
  {$IFDEF RDBTRIGGERS}
  for I := RdbTriggerCount - 1 downto 0 do
  begin
    if not TriggerExist(RdbTriggers[I]) then
      CreateTrigger(RdbTriggers[I]);
  end;
  {$ENDIF}
end;

procedure TrpReplicationManager.DropDomane(Domane: TDomane);
var
  SQL: TIBSQL;
begin
  if ReplDataBase.DomaneExist(Domane) then
  begin
    {$IFDEF DEBUG}
    CheckInTransaction;
    {$ENDIF}
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := ReplDataBase.Transaction;
      ReplDataBase.Transaction.StartTransaction;
      try
        SQL.SQL.Add(Format('DROP DOMAIN %s' , [Domane.Name]));
        SQL.ExecQuery;
        ReplDataBase.Transaction.Commit;
      except
        on E: Exception do
        begin
          ReplDataBase.Transaction.Rollback;
          Errors.Add(Format(ERR_DROP_DOMANE, [Domane.Name]) + E.Message);
        end;
      end;
    finally
      SQL.Free;
    end;
  end;
end;

procedure TrpReplicationManager.DropDomanes;
var
  I: Integer;
begin
  ProgressState.MaxMinor := DomaneCount;
  for I := 0 to DomaneCount - 1 do
  begin
    DropDomane(Domanes[I]);
    ProgressState.MinorProgress(Self);
  end;
  DropExceptions;
end;

procedure TrpReplicationManager.DropGenerator(Generator: TGenerator);
var
  SQL: TIBSQL;
begin
  if ReplDataBase.GeneratorExist(Generator) then
  begin
    {$IFDEF DEBUG}
    CheckInTransaction;
    {$ENDIF}
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := ReplDataBase.Transaction;
      ReplDataBase.Transaction.StartTransaction;
      try
        SQL.SQL.Add(Format('DROP GENERATOR %s', [Generator.Name]));
        SQL.ExecQuery;
        ReplDataBase.Transaction.Commit;
      except
        on E: Exception do
        begin
          ReplDataBase.Transaction.Rollback;
          Errors.Add(Format(ERR_DROP_GENERATOR, [Generator.Name]) + E.Message);
        end;
      end;
    finally
      SQL.Free;
    end;
  end;
end;

procedure TrpReplicationManager.DropGenerators;
var
  I: Integer;
begin
  ProgressState.MaxMinor := GeneratorCount;
  for I := 0 to GeneratorCount - 1 do
  begin
    DropGenerator(Generators[I]);
    ProgressState.MinorProgress(Self);
  end;
end;

procedure TrpReplicationManager.DropTable(Table: TTable);
var
  SQL: TIBSQL;
  procedure DropTableDependencies(Table: TTable);
  var
    SQL: TIBSQL;
    Trigger: TTrigger;
  begin
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := ReplDataBase.ReadTransaction;
      SQL.SQL.Text :=
        'SELECT DISTINCT d.RDB$DEPENDENT_NAME, d.RDB$DEPENDENT_TYPE FROM ' +
        ' RDB$DEPENDENCIES d WHERE d.RDB$DEPENDED_ON_NAME = :relationname AND NOT ' +
        ' EXISTS(SELECT * FROM rdb$check_constraints WHERE rdb$trigger_name = d.RDB$DEPENDENT_NAME)';
      SQL.ParamByName('relationname').AsString := Table.Name;
      SQl.ExecQuery;
      Trigger.RelationName := Table.Name;
      while not SQL.Eof do
      begin
        case SQL.FieldByName('RDB$DEPENDENT_TYPE').AsInteger of
          2: //триггер
          begin
            Trigger.TriggerName := Trim(SQL.FieldByName('RDB$DEPENDENT_NAME').AsString);
            try
              DropTrigger(Trigger);
            except
            end;
          end;
        end;
        SQL.Next;
      end;
    finally
      SQL.Free;
    end;
  end;

begin
  if ReplDataBase.TableExist(Table) then
  begin
    {$IFDEF DEBUG}
    CheckInTransaction;
    {$ENDIF}
    DropTableDependencies(Table);
    FPreserve := True;
    ReplDataBase.Preserve := True;
    try
      ReplDataBase.Connected := False;
    finally
      ReplDataBase.Connected := True;
      ReplDataBase.Preserve := False;
      FPreserve := False;
    end;
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := ReplDataBase.Transaction;
      ReplDataBase.Transaction.StartTransaction;
      try
        SQL.SQL.Add(Format('DROP TABLE %s', [Table.Name]));
        SQL.ExecQuery;
        ReplDataBase.Transaction.Commit;
      except
        on E: Exception do
        begin
          ReplDataBase.Transaction.Rollback;
          Errors.Add(Format(ERR_DROP_TABLE, [Table.Name]) + E.Message);
        end;
      end;
    finally
      SQL.Free;
    end;
  end;
end;

procedure TrpReplicationManager.DropTables;
var
  I: Integer;
begin
  ProgressState.MaxMinor := TableCount;
  for I := TableCount - 1 downto 0 do
  begin
    DropTable(Tables[I]);
    ProgressState.MinorProgress(Self);
  end;

  {$IFNDEF GEDEMIN}
  DropTable(GD_RUID_RU);
  {$ENDIF}
end;

procedure TrpReplicationManager.DropTrigger(Trigger: TTrigger);
var
  SQL: TIBSQL;
begin
  if TriggerExist(Trigger) then
  begin
    {$IFDEF DEBUG}
    CheckInTransaction;
    {$ENDIF}
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := ReplDataBase.Transaction;
      ReplDataBase.Transaction.StartTransaction;
      try
        SQL.SQL.Add(Format('DROP TRIGGER %s', [Trigger.TriggerName]));
        SQL.ExecQuery;
        ReplDataBase.Transaction.Commit;
      except
        on E: Exception do
        begin
          ReplDataBase.Transaction.Rollback;
          Errors.Add(Format(ERR_DROP_TRIGGER, [Trigger.TriggerName]) + E.Message);
        end;
      end;
    finally
      SQL.Free;
    end;
  end;
end;

procedure TrpReplicationManager.DropTriggers(const AMainDB: boolean = False);
var
  SQL: TIBSQL;
  Trigger: TTrigger;
  {$IFDEF RDBTRIGGERS}
  I: Integer;
  {$ENDIF}
begin
  ProgressState.MaxMinor := DropTriggersActionCount;

  //Удаляем триггеры с системных таблиц, но перед этим деактивизируем их
  {$IFDEF RDBTRIGGERS}
  for I := 0 to RdbTriggerCount - 1 do
  begin
    if TriggerExist(RdbTriggers[I]) then
    begin
      ActivateTrigger(RdbTriggers[I], tsInactive);
    end;
  end;

  for I := 0 to RdbTriggerCount - 1 do
  begin
    if TriggerExist(RdbTriggers[I]) then
    begin
      DropTrigger(RdbTriggers[I]);
    end;
  end;
  {$ENDIF}
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := ReplDataBase.ReadTransaction;
    SQL.SQL.Text:=
      'SELECT t.rdb$trigger_name AS triggername, t.rdb$relation_name AS relation ' +
      'FROM rdb$triggers t ';
    if AMainDB then
      SQL.SQL.Text:= SQL.SQL.Text +
        '  JOIN rpl$relations r ON r.relation = t.rdb$relation_name';
    SQL.SQL.Text:= SQL.SQL.Text +
      'WHERE t.rdb$trigger_name LIKE ''RPL$%'' ';
    if not AMainDB then
      SQL.SQL.Text:= SQL.SQL.Text +
        ' AND NOT t.rdb$relation_name LIKE ''RPL$%''';
    SQL.ExecQuery;
    while not SQL.Eof do
    begin
      Trigger.RelationName := SQL.FieldByName(fnRelation).AsString;
      Trigger.TriggerName := SQL.FieldByName(fnTriggerName).AsString;
      DropTrigger(Trigger);
      ProgressState.MinorProgress(Self);
      SQL.Next;
    end;
  finally
    SQL.Free;
  end;
end;

function TrpReplicationManager.GetScript: TrplBaseScript;
begin
  if FScript = nil then
    FScript := TrplScript.Create;

  Result := FScript;
end;

function TrpReplicationManager.GetTriggerName(RelationKey: Integer; Action: 
        string): string;
var
  Relation: TrpRelation;
begin
  Relation := Relations.Relations[RelationKey];
  if Relation <> nil then
  begin
    Result := 'RPL$A' + Action + '_' + Relation.RelationName;
    Result := Copy(Result, 1, 31);
  end else
    raise Exception.Create(InvalidRelationKey);
end;

function TrpReplicationManager.NeedDropDomanes: Boolean;
var
  I: Integer;
  Db: TReplDataBase;
  C: Integer;
begin
  DB := ReplDataBase;
  C := 0;
  for I := 0 to DomaneCount - 1 do
  begin
    if Db.DomaneExist(Domanes[I]) then
      Inc(C);
  end;
  
  Result := (C > 0) and (C <> DomaneCount);
end;

function TrpReplicationManager.NeedDropGenerators: Boolean;
var
  I: Integer;
  DB: TReplDataBase;
  C: Integer;
begin
  //генераторы удаляем усли их кол-во не совпадает с заданным
  //  Result := False;
  DB := ReplDataBase;
  C := 0;
  for I := 0 to GeneratorCount - 1 do
  begin
    if DB.GeneratorExist(Generators[I]) then
      Inc(C);
  end;
  
  Result := (C > 0) and (C <> GeneratorCount);
end;

function TrpReplicationManager.NeedDropTables: Boolean;
var
  I: Integer;
  DB: TReplDataBase;
  C: Integer;
begin
  DB := ReplDataBase;
  C := 0;
  for I := 0 to TableCount - 1 do
  begin
    if Db.TableExist(Tables[I]) then
      Inc(C);
  end;

  Result := (C <> TableCount) and (C > 0);

  if not Result then
  begin
    if Db.GeneratorExist(GD_G_DBID) then
      Result := not Db.TableExist(GD_RUID_RU);
  end
end;

function TrpReplicationManager.NeedDropTriggers: Boolean;
var
  SQL: TIBSQL;
begin
  //Триггеры удаляем при любой модификации схемы репликации
  Result := False;
  {$IFDEF DEBUG}
  CheckInTransaction;
  {$ENDIF}
  if ReplDataBase.TableExist(Tables[RPL_RELATION_INDEX]) and
    ReplDataBase.TableExist(Tables[RPL_KEYS_INDEX])then
  begin
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := ReplDataBase.Transaction;
      ReplDataBase.Transaction.StartTransaction;
      try
        SQL.SQL.Text := 'SELECT COUNT(rdb$trigger_name) FROM rdb$triggers WHERE rdb$trigger_name LIKE ''RPL$%'' '+
          ' AND NOT rdb$relation_name LIKE ''RPL$%''';
        SQL.ExecQuery;
        Result := SQL.Fields[0].AsInteger > 0;
        ReplDataBase.Transaction.Commit;
      except
        ReplDataBase.Transaction.Rollback;
        raise;
      end;
    finally
      SQL.Free;
    end;
  end;
end;

procedure TrpReplicationManager.CreateMetaData;
var
  I: Integer;
  MC: TrplMakeCopy;
begin
  if FScript = nil then
    FScript := TrplScript.Create
  else
    FScript.Clear;
  //При необходимости удаляем метаданные, оставшиеся после неудачной подготовке
  //к репликации
  if not RoleExist(Role) then
    FScript.AddClause(TrplCreateRole.Create);
    
  if NeedDeactivisation then
    FScript.AddClause(TrplDeactivization.Create);

  if NeedDropTriggers then
    FScript.AddClause(TrplDropOldTriggers.Create);

  if NeedDropTables then
    FScript.AddClause(TrplDropOldTables.Create);

  if NeedDropDomanes then
    FScript.AddClause(TrplDropOldDomanes.Create);

  if NeedDropGenerators then
    FScript.AddClause(TrplDropGenerators.Create);

  //Создаем метаданные
  FScript.AddClause(TrplCreateMetaDate.Create);
  //Заполняем таблицы
  FScript.AddClause(TrplFillTables.Create);

  //Создаем триггера
  if Direction <> rdFromServer then
    FScript.AddClause(TrplCreateTriggers.Create);

  //Заполняем таблицу GD_RUID
  if FPrimeKeyType <> ptNatural then
    FScript.AddClause(TrplCreateRuids.Create);

  FScript.AddClause(TrplActivization.Create);
  //Создание копий второстепенных баз
  for I := 0 to DBList.Count - 1 do
  begin
    if DBList.ItemsByIndex[I].DBState <> dbsMain then
    begin
      MC := TrplMakeCopy.Create;
      MC.Destination := DBList.ItemsByIndex[I].DBName;
      FScript.AddClause(MC);
    end;
  end;

  // Еслм репликация однонаправленная от подчиненных к главной, то очищаем главную базу
  case Direction of
    rdToServer:
      FScript.AddClause(TrplDropTriggersMainDB.Create);
    rdFromServer:
      FScript.AddClause(TrplCreateTriggers.Create);
  end;
end;

procedure TrpReplicationManager.SetGeneratorName(const Value: string);
begin
  FGeneratorName := Value;
end;

function TrpReplicationManager.TriggerExist(Trigger: TTrigger): Boolean;
begin
  CheckTriggerSQL;
  FTriggerSQL.ParamByName(fnTriggerName).AsString := Trigger.TriggerName;
  FTriggerSQL.ExecQuery;
  Result := FTriggerSQL.RecordCount > 0;
end;

function TrpReplicationManager.GetRelations: TmnRelations;
begin
  if FRelations = nil then
    FRelations := TmnRelations.Create;

  Result := FRelations;
end;

{ TmnReplicationDBList }

function TmnReplicationDBList.CheckUniqueDBName(DBName: string): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Count - 1 do
  begin
    if UpperCase(ItemsByIndex[I].DBName) = UpperCase(DBName) then
    begin
      Inc(Result);
    end;
  end;
end;

function TmnReplicationDBList.GetUniqueDBName(Prefix: string): string;
var
  I: Integer;
begin
  I := 1;
  repeat
    Result := Format('%s_%d', [Prefix, I]);
    Inc(I);
  until CheckUniqueDBName(Result) = 0;
end;

procedure TmnReplicationDBList.LoadAll;
begin
  if ReplDataBase.TableExist(Tables[RPL_REPLICATIONDB_INDEX]) then
    inherited;
end;

function TrpReplicationManager.GetDBListOld: TStringList;
begin
  if  FDBListOld = nil then
    FDBListOld:= TStringList.Create;
  Result:= FDBListOld;
end;

function TrpReplicationManager.GetDBList: TmnReplicationDBList;
var
  DB: PReplicationDB;
  FileName, FileExtension: string;
begin
  if  FDBList = nil then
  begin
    FDBList := TmnReplicationDBList.Create;
    FDBList.LoadAll;
    //База новая поэтому добавляем в список основную таблицу
    if FDBList.Count = 0 then
    begin
      New(DB);
      with DB^ do
      begin
        DBState := dbsMain;
        FileName := ExtractFileName(ReplDataBase.DatabaseName);
        FileExtension := ExtractFileExt(FileName);
        DBName := Copy(FileName, 1, Length(FileName) - Length(FileExtension));
        Priority := Integer(prHighest);
        ReplKey := DefaultReplKey;
        LastProcessReplKey := DefaultLastProcessReplKey;
        if ReplDataBase.GeneratorExist(GD_G_DBID) then
          DBKey := ReplDatabase.GenDBID
        else
          DBKey := GetNewDBID;
        DBPath := ReplDataBase.FileName;
      end;
      FDBList.Add(DB);
    end;
  end;
  Result := FDBList;
end;

procedure TrpReplicationManager.SetErrorDecision(
  const Value: TErrorDecision);
begin
  FErrorDecision := Value;
end;

procedure TrplBaseScript.Execute;
begin
  DoExecute;
end;

procedure TrpReplicationManager.UpdateReplDBList;
var
  SQL, SQLLogHist, SQLLog: TIBSQL;
  i, j, iAdd: integer;
  RDB: TReplicationDB;
  bNeed: boolean;
  slLog: TStringList;
begin
  ProgressState.MaxMinor:= DBList.Count + DBListOld.Count;

  SQL := TIBSQL.Create(nil);
  SQLLog := TIBSQL.Create(nil);
  SQLLogHist := TIBSQL.Create(nil);
  slLog:= TStringList.Create;
  try
    SQL.Transaction := ReplDataBase.Transaction;
    SQLLog.Transaction := ReplDataBase.Transaction;
    SQLLogHist.Transaction := ReplDataBase.Transaction;
    CheckInTransaction;
    SQL.Transaction.StartTransaction;
    SQL.SQL.Text:= 'SELECT seqno FROM rpl$log';
    SQL.ExecQuery;
    while not SQL.Eof do begin
      slLog.Add(IntToStr(SQL.FieldByName('seqno').AsInteger));
      SQL.Next;
    end;
    SQL.Close;
    iAdd:= 0;
    for i:= 0 to DBList.Count - 1 do begin
      if FDBListOld.IndexOf(IntToStr(DBList.ItemsByIndex[i].DBKey)) = -1 then
        Inc(iAdd);
    end;
    ProgressState.MaxMinor:= slLog.Count * iAdd + ProgressState.MaxMinor;

    try
      SQL.SQL.Text:= 'DELETE FROM rpl$replicationdb WHERE dbkey=:dbkey';
      for i:= 0 to FDBListOld.Count - 1 do begin
        bNeed:= True;
        for j:= 0 to DBList.Count - 1 do begin
          if StrToInt(FDBListOld[i]) = DBList.ItemsByIndex[j].DBKey then begin
            bNeed:= False;
            Break;
          end;
        end;
        if bNeed then begin
          SQL.ParamByName(fnDBKey).AsInteger:= StrToInt(FDBListOld[i]);
          SQl.ExecQuery;
          SQL.Close;
        end;
        ProgressState.MinorProgress(Self);
      end;

      SQLLogHist.SQL.Text:= 'INSERT INTO rpl$loghist (seqno, dbkey, replkey, tr_commit) ' +
        'VALUES (:seqno, :dbkey, 0, 1)';
      SQL.SQL.Text:= 'INSERT INTO rpl$replicationdb(dbkey, dbstate, priority, ' +
        ' dbname, lastprocessreplkey, replkey) VALUES(:dbkey, :dbstate, :priority, ' +
        ' :dbname, :lastprocessreplkey, :replkey)';
      for i := 0 to DBList.Count - 1 do begin
        RDB := DBList.ItemsByIndex[i];
        if FDBListOld.IndexOf(IntToStr(RDB.DBKey)) > -1 then
          Continue;
        SQL.ParamByName(fnDBKey).AsInteger:= RDB.DBKey;
        SQL.ParamByName(fnDBState).AsInteger:= Integer(RDB.DBState);
        SQL.ParamByName(fnPriority).AsInteger:= Integer(RDB.Priority);
        SQL.ParamByName(fnDBName).AsString:= RDB.DBName;
        SQL.ParamByName(fnLastProcessReplKey).AsInteger:= RDB.LastProcessReplKey;
        SQL.ParamByName(fnReplKey).AsInteger:= RDB.ReplKey;
        SQl.ExecQuery;
        SQL.Close;
        for j:= 0 to slLog.Count - 1 do begin
          SQLLogHist.ParamByName(fnDBKey).AsInteger:= RDB.DBKey;
          SQLLogHist.ParamByName(fnSeqNo).AsInteger:= StrToInt(slLog[j]);
          SQLLogHist.ExecQuery;
          SQLLogHist.Close;
          ProgressState.MinorProgress(Self);
        end;
        ProgressState.MinorProgress(Self);
      end;
    except
      on E: Exception do begin
        SQL.Transaction.Rollback;
        Errors.Add(E.Message);
      end;
    end;
  finally
    SQL.Free;
    SQLLog.Free;
    SQLLogHist.Free;
    slLog.Free;
  end;
end;

procedure TrpReplicationManager.FillTables;
var
  SQL: TIBSQL;
  I, J: Integer;
  R: TmnRelation;
  F: TmnField;
  RDB: TReplicationDB;
begin
  ProgressState.MaxMinor := FillTablesActionCount;

  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := ReplDataBase.Transaction;
    CheckInTransaction;
    SQL.Transaction.StartTransaction;
    try
      //Удаление старых данных
      for I := TableCount - 1 downto 0 do
      begin
        SQL.SQl.Text := Format('DELETE FROM %s', [Tables[I].Name]);
        SQL.ExecQuery;
        ProgressState.MinorProgress(Self);
      end;
      //Заполняем таблицу RPL$ReplicationDB
      SQL.SQL.Text := 'INSERT INTO rpl$replicationdb(dbkey, dbstate, priority, ' +
        ' dbname, lastprocessreplkey, replkey) VALUES(:dbkey, :dbstate, :priority, ' +
        ' :dbname, :lastprocessreplkey, :replkey)';

      for I := 0 to DBList.Count - 1 do
      begin
        RDB := DBList.ItemsByIndex[I];
        SQL.ParamByName(fnDBKey).AsInteger := RDB.DBKey;
        SQL.ParamByName(fnDBState).AsInteger := Integer(RDB.DBState);
        SQL.ParamByName(fnPriority).AsInteger := Integer(RDB.Priority);
        SQL.ParamByName(fnDBName).AsString := RDB.DBName;
        SQL.ParamByName(fnLastProcessReplKey).AsInteger := RDB.LastProcessReplKey;
        SQL.ParamByName(fnReplKey).AsInteger := RDB.ReplKey;
        SQl.ExecQuery;
        SQL.Close;
        ProgressState.MinorProgress(Self);
      end;

      //Заполняем таблицу RPL$DBSTATE
      SQL.SQL.Text :=
        'INSERT INTO rpl$DBSTATE(dbkey, replicationid, errordecision, ' +
        '  primekeytype, generatorname, keydivider, prepared, direction) ' +
        'VALUES(:dbkey, :replicationid, :errordecision, ' +
        ' :primekeytype, :generatorname, :keydivider, 0, :direction)';

      RDB := DBList.MainDB;
      SQL.ParamByName(fnDBKey).AsInteger := RDB.DBKey;
      FReplSchemaKey := GetNewDBID;
      SQL.ParamByName(fnReplicationId).AsInteger := FReplSchemaKey;
      SQL.ParamByName(fnErrorDecision).AsInteger := Integer(ErrorDecision);
      SQL.ParamByName(fnPrimeKeyType).AsInteger := Integer(PrimeKeyType);
      SQL.ParamByName(fnGeneratorName).AsString := GeneratorName;
      SQL.ParamByName(fnKeyDivider).AsString := KeyDivider;
      SQL.ParamByName(fnDirection).AsInteger := integer(Direction);
      SQL.ExecQuery;
      SQl.Close;
      ProgressState.MinorProgress(Self);

      //Заполняем таблицу RLP$RELATIONS
      SQL.SQL.Text := 'INSERT INTO rpl$relations (id, relation, generatorname) ' +
        ' VALUES (:id, :relation, :generatorname)';


//      Relations.Prepare;

      for I := 0 to Relations.Count - 1 do
      begin
        if Relations.RelationsByIndex[I].Checked then
        begin
          SQL.ParamByName(fnId).AsInteger := Relations.RelationsByIndex[I].RelationKey;
          SQL.ParamByName(fnRelation).AsString := Relations.RelationsByIndex[I].RelationName;

          SQL.ParamByName(fnGeneratorName).AsString := Relations.RelationsByIndex[I].GeneratorName;
          SQL.ExecQuery;
          SQL.Close;
        end;
        ProgressState.MinorProgress(Self);
      end;

      //Заполняем таблицу rpl$fields
      SQL.SQL.Text := 'INSERT INTO rpl$fields (relationkey, fieldname) ' +
        ' VALUES(:relationkey, :fieldname)';

      for I := 0 to Relations.Count - 1 do
      begin
        R := TmnRelation(Relations.RelationsByIndex[I]);
        if R.Checked then
        begin
          for J := 0 to R.Fields.Count - 1 do
          begin
            F := TmnField(R.Fields[J]);
            if not F.IsKey and F.Checked and not F.IsComputed then
            begin
              SQL.ParamByName(fnRelationKey).AsInteger := R.RelationKey;
              SQL.ParamByName(fnFieldName).AsString := F.FieldName;
              SQL.ExecQuery;
              SQL.Close;
            end;
          end;
        end;
        ProgressState.MinorProgress(Self);
      end;

      //Заполняем таблицу rpl$keys
      SQL.SQL.Text := 'INSERT INTO rpl$keys (relationkey, keyname) ' +
        ' VALUES(:relationkey, :keyname)';

      for I := 0 to Relations.Count - 1 do
      begin
        R := TmnRelation(Relations.RelationsByIndex[I]);
        if R.Checked then
        begin
          for J := 0 to R.Keys.Count - 1 do
          begin
            F := TmnField(R.Keys[J]);
            SQL.ParamByName(fnRelationKey).AsInteger := R.RelationKey;
            SQL.ParamByName(fnKeyName).AsString := F.FieldName;
            SQL.ExecQuery;
            SQL.Close;
          end;
        end;
        ProgressState.MinorProgress(Self);
      end;

      SQL.Transaction.Commit;
    except
      on E: Exception do
      begin
        SQL.Transaction.Rollback;
        Errors.Add(E.Message);
      end;
    end;
  finally
    SQL.Free;
  end;
end;

function TmnReplicationDBList.MainDB: TReplicationDB;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    if ItemsByIndex[I].DBState = dbsMain then
    begin
      Result := ItemsByIndex[i];
      Exit;
    end;
  end;
end;

function TrpReplicationManager.FillTablesActionCount: Integer;
begin
  Result := 1 + Relations.Count * 3 + DBList.Count + TableCount;
end;

function TrpReplicationManager.CreateTriggersActionCount: Integer;
begin
  Result := Relations.Count {$IFDEF RDBTRIGGERS}+ RdbTriggerCount{$ENDIF};
end;

function TrpReplicationManager.DropTriggersActionCount: Integer;
var
  SQL: TIBSQL;
begin
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := ReplDataBase.ReadTransaction;
    SQL.SQL.Text := 'SELECT COUNT(rdb$trigger_name) FROM rdb$triggers WHERE rdb$trigger_name LIKE ''RPL$%'' '+
      ' AND NOT rdb$relation_name LIKE ''RPL$%''';
    SQL.ExecQuery;
    Result := SQL.Fields[0].AsInteger {$IFDEF RDBTRIGGERS}+ RdbTriggerCount{$ENDIF};
  finally
    SQL.Free;
  end;
end;

function TrplBaseScript.Description: string;
begin
  Result := '';
end;

function TrpReplicationManager.CreateRUIDsActionCount: Integer;
var
  I, J: Integer;
  R: TmnRelation;
  F: TmnField;
begin
  Result := 0;
  for I := 0 to Relations.Count - 1 do
  begin
    R := TmnRelation(Relations.RelationsByIndex[I]);
    if R.Checked then
    begin
      for J := 0 to R.Fields.Count - 1 do
      begin
        F := TmnField(R.Fields[J]);
        { TODO : Пока будем генерить РУИД для полей типа интежер }
        if F.Checked and (F.FieldType in [tfInteger{, tfInt64, tfSmallInt}]) and
          (F.FieldSubType = istFieldType) and (F.IsForeign or F.IsPrimeKey) then
        begin
          Inc(Result);
        end;
      end;
    end;
  end;
end;

procedure TrpReplicationManager.MakeCopy(Source, Destination: string);
var
  SourceFileName, DestinationFileName: string;
  B: Boolean;
  O: TOpenDialog;
  DB: TIBDataBase;
  Tr: TIBTransaction;
  RemoteSQL: TIBSQL;
  I: Integer;
  Target: PReplicationDB;
  DBExtention: String;
const
  cPeriodCount = 100;
begin
  try
    I := DBList.IndexByDBName(Destination);
    Assert(I > - 1, 'Invalid db name');
    Target := DBList.Items[I];
    ProgressState.MaxMinor := cPeriodCount;

    CheckInTransaction;
    // Получаем путь к БД
    SourceFileName := ReplDataBase.FileName;
    if not FileExists(SourceFileName) then
      raise Exception.Create(ERR_MAKE_DB_COPY);

    DBExtention := '';
    if ExtractFileExt(Destination) = '' then
      DBExtention := ExtractFileExt(SourceFileName);
    DestinationFileName := ExtractFilePath(SourceFileName) + Destination +
      DBExtention;

    B := gvAskQuestion;
    try
      gvAskQuestion := True;
      while (FileExists(DestinationFileName) and
        not AskQuestion(Format(rpl_ResourceString_unit.FileExists, [DestinationFileName]))) or
        (not CheckDiskFree(ExtractFilePath(DestinationFileName), FileSize(SourceFileName))) do
      begin
        if not CheckDiskFree(ExtractFilePath(DestinationFileName),
          FileSize(SourceFileName)) then  ShowInfoMessage(NotEnoughDiskSpace);

        O := TOpenDialog.Create(nil);
        try
          O.InitialDir := ExtractFilePath(DestinationFileName);
          O.Filter := OpenDBFilter;
          O.FilterIndex := 0;
          O.Options := [ofOverwritePrompt, ofHideReadOnly, ofNoNetworkButton,
            ofEnableSizing];

          if O.Execute then
          begin
            DestinationFileName :=  O.FileName;
          end else
          begin
            if AskQuestion(Format(DoYouWantExstractDBFromRepl, [Destination])) then
            begin
              I := DBList.IndexByDBName(Destination);
              Assert(I > - 1, 'Invalid db name');
              DBList.Delete(I);
              Exit;
            end;
          end;
        finally
          O.Free;
        end;
      end;
    finally
      gvAskQuestion := B;
    end;

    B := ReplDataBase.Connected;
    try
      FPreserve := True;
      ReplDataBase.Preserve := True;

      ReplDataBase.Connected := False;

      Target^.DBPath := DestinationFileName;
      if CopyFile(Self, SourceFileName, DestinationFileName, cPeriodCount) then
      begin
        ReplDataBase.Connected := True;
        ReplDataBase.Preserve := False;
        FPreserve := False;

        DB := TIBDatabase.Create(nil);
        try
        { TODO :
        Если пользователь указал путь, который не является локальным
        для сервера то получится х-ня }
        { TODO :
        Нужно обрабатывать ситуацию, когда пользователь ввел имя
        файла, задействованого в схеме репликации }
          DB.DatabaseName := GetDataBaseName(ReplDataBase.ServerName,
            DestinationFileName, ReplDataBase.Protocol);
          DB.SQLDialect := ReplDataBase.SQLDialect;
          DB.Params.Assign(ReplDataBase.Params);
          DB.LoginPrompt := False;

          DB.Connected := True;
          try
            Tr := TIBTransaction.Create(nil);
            try
              Tr.DefaultDatabase := DB;
              Tr.StartTransaction;
              try
                RemoteSQL := TIBSQL.Create(nil);
                try
                  RemoteSQL.Transaction := Tr;
                  RemoteSQL.SQL.Text := 'UPDATE rpl$dbstate SET ' +
                    'dbkey = :dbkey, fk = :fk, triggers = :triggers, fketalon = :fketalon';
                  RemoteSQL.ParamByName(fnDBKey).AsInteger := Target^.DBKey;
                  RemoteSQL.ParamByName(fnFK).Clear;
                  RemoteSQL.ParamByName(fnFKEtalon).Clear;
                  RemoteSQL.ParamByName(fnTriggers).Clear;
                  RemoteSQL.ExecQuery;
                  RemoteSQL.Close;
                  {$IFDEF GEDEMIN}
                  // Меняем уникальный идентефикатор БД
                  RemoteSQL.SQL.Text := 'SET GENERATOR GD_G_DBID TO ' + IntToStr(Target^.DBKey);
                  RemoteSQL.ExecQuery;
                  RemoteSQL.Close;
                  {$ENDIF}
                  //Удаляем ненужные записи из RPL_REPLICATIONDB
                  RemoteSQL.SQL.Text := 'DELETE FROM rpl$replicationdb ' +
                    'WHERE NOT dbkey IN (:dbkey, :maindbkey)';
                  RemoteSQL.ParamByName(fnDbKey).AsInteger := Target^.DBKey;
                  RemoteSQL.ParamByName('maindbkey').AsInteger := DBList.MainDb.DBKey;
                  RemoteSQL.ExecQuery;

                  //Удаляем из RPL_LOGHIST & RPL_LOG
                  RemoteSQL.SQL.Text := 'DELETE FROM rpl$loghist';
                  RemoteSQL.ExecQuery;

                  RemoteSQL.SQL.Text := 'DELETE FROM rpl$log';
                  RemoteSQL.ExecQuery;
                  Tr.Commit;
                finally
                  RemoteSQL.Free;
                end;
              except
                Tr.Rollback;
                raise;
              end;
            finally
              TR.Free;
            end;
          finally
            DB.Connected := False;
          end;
        finally
          DB.Free;
        end;
      end;
    finally
      ReplDataBase.Connected := B;
    end;
  except
    on E: Exception do
      Errors.Add(E.Message);
  end;
end;

function TrpReplicationManager.CopyFile(Sender: TObject; Source,
  Destination: string; PeriodCount: Integer): Boolean;
var
  S, D: TFileStream;
  Delta: Int64;
  I: Integer;
begin
  S := TFileStream.Create(Source, fmOpenRead);
  try
    D := TFileStream.Create(Destination, fmOpenReadWrite or fmCreate);
    try
      if PeriodCount <= 0 then PeriodCount := 1;
      Delta := S.Size div PeriodCount;
      for I := 0 to PeriodCount - 1 do
      begin
        D.CopyFrom(S, Delta);
        ProgressState.MinorProgress(Sender);
      end;
      //Вследствии округления значения Delta мы могли недостигнуть конца файла
      if S.Position < S.Size then
      begin
        D.CopyFrom(S, S.Size - S.Position);
      end;
      Result := True;
    finally
      D.Free;
    end;
  finally
    S.Free;
  end;
end;

function TrpReplicationManager.CheckDiskFree(Path: string;
  NeedSpace: Integer): Boolean;
begin
  { TODO : Реализовать }
  Result := True;
end;

function TrpReplicationManager.FileSize(FileName: string): integer;
begin
  { TODO : Реализовать }
  Result := 0;
end;

procedure TrpReplicationManager.GetReport(const Strings: TStrings);
var
  I: Integer;
  DB: TReplicationDB;
begin
  Assert(Strings <> nil, '');
  Strings.BeginUpdate;
  try
    Strings.Clear;
    Strings.Add(Format(MSG_REPORT_DATE, [DateTimeToStr(Now)]));
    Strings.Add(Format(MSG_REPORT_REPLTYPE, [GetDiretionString(FDirection)]));
    Strings.Add(Format(MSG_REPORT_ERROR_DECISION, [GetErrorDecisionString(FErrorDecision)]));
    Strings.Add(Format(MSG_REPORT_REPL_KEY, [FReplSchemaKey]));
    Strings.Add(MSG_REPORT_DB);
    for I := 0 to DBList.Count - 1 do
    begin
      DB := DBList.ItemsByIndex[I];
      Strings.Add(Format(MSG_REPORT_DB_ALIAS, [DB.DBName]));
      Strings.Add(Format(MSG_REPORT_DB_FILE_NAME, [DB.DBPath]));
      Strings.Add(Format(MSG_REPORT_DB_STATE, [GetDBStateString(DB.DBState)]));
      Strings.Add(Format(MSG_REPORT_DB_PRIORITY, [GetDBPriorityString(TrplPriority(DB.Priority))]));
      Strings.Add('');
    end;
  finally
    Strings.EndUpdate;
  end;
end;

procedure TrpReplicationManager.DropAllMetaData;
begin
  if FScript = nil then
    FScript := TrplScript.Create
  else
    FScript.Clear;
  //При необходимости удаляем метаданные, оставшиеся после неудачной подготовке
  //к репликации

  if NeedDeactivisation then
    FScript.AddClause(TrplDeactivization.Create);
    
  if NeedDropTriggers then
    FScript.AddClause(TrplDropTriggers.Create);

  FScript.AddClause(TrplDropTables.Create);

  FScript.AddClause(TrplDropDomanes.Create);

  FScript.AddClause(TrplDropGenerators.Create);

  FScript.AddClause(TrplDropRole.Create);
end;

procedure TrplScript.Execute;
begin
  Errors.Clear;
  inherited;
end;

procedure TrpReplicationManager.DoAfterConnectionLost;
begin
  FreeAndNil(FRelations);

  if FDBList <> nil then
  begin
    FDBList.Clear;
    FreeAndNil(FDBList);
  end;
end;

procedure TrpReplicationManager.DoAfterSuccessfullConnection;
begin
end;

procedure TrpReplicationManager.DoBeforeDisconnect;
begin
  if not FPreserve then
  begin
    FreeAndNil(FRelations);

    if FDBList <> nil then
    begin
      FDBList.Clear;
      FreeAndNil(FDBList);
    end;
  end;
end;

constructor TrpReplicationManager.Create;
begin
  ReplDataBase.AddConnectNotify(Self);
end;

function TrpReplicationManager._AddRef: Integer;
begin
  Result := 0;
end;

function TrpReplicationManager._Release: Integer;
begin
  Result := 0;
end;

function TrpReplicationManager.QueryInterface(const IID: TGUID;
  out Obj): HResult;
begin
  Result := 0;
end;

procedure TrpReplicationManager.CheckException(AException: TExcept);
var
  SQL: TIBSQL;
begin
  if not ReplDataBase.ExceptionExist(AException) then
  begin
    {$IFDEF DEBUG}
    CheckInTransaction;
    {$ENDIF}
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := ReplDataBase.Transaction;
      ReplDataBase.Transaction.StartTransaction;
      try
        SQL.SQL.Add(Format('CREATE EXCEPTION %s  ''%s''', [AException.Name, AException.Message]));
        SQL.ExecQuery;
        ReplDataBase.Transaction.Commit;
      except
        on E: Exception do
        begin
          ReplDataBase.Transaction.Rollback;
          Errors.Add(Format(ERR_CREATE_EXCEPTION, [AException.Name]) + E.Message);
        end;
      end;
    finally
      SQL.Free;
    end;
  end;
end;

procedure TrpReplicationManager.CheckExceptions;
var
  I: Integer;
begin
  for I := 0 to ExceptionCount - 1 do
  begin
    CheckException(Exceptions[I]);
  end;
end;

procedure TrpReplicationManager.DropException(AException: TExcept);
var
  SQL: TIBSQL;
begin
  if ReplDataBase.ExceptionExist(AException) then
  begin
    {$IFDEF DEBUG}
    CheckInTransaction;
    {$ENDIF}
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := ReplDataBase.Transaction;
      ReplDataBase.Transaction.StartTransaction;
      try
        SQL.SQL.Add(Format('DROP EXCEPTION %s', [AException.Name]));
        SQL.ExecQuery;
        ReplDataBase.Transaction.Commit;
      except
        on E: Exception do
        begin
          ReplDataBase.Transaction.Rollback;
          Errors.Add(Format(ERR_DROP_EXCEPTION, [AException.Name]) + E.Message);
        end;
      end;
    finally
      SQL.Free;
    end;
  end;
end;

procedure TrpReplicationManager.DropExceptions;
var
  I: Integer;
begin
  for I := 0 to ExceptionCount - 1 do
  begin
    DropException(Exceptions[I]);
  end;
end;

{ TrplActivization }

function TrplActivization.Description: string;
begin
  Result := Activization
end;

procedure TrplActivization.DoExecute;
begin
  inherited;
  ReplicationManager.Activization
end;

{ TrplDeactivization }

function TrplDeactivization.Description: string;
begin
  Result := Deactivization
end;

procedure TrplDeactivization.DoExecute;
begin
  inherited;
  ReplicationManager.Deactivization
end;

function TrpReplicationManager.NeedDeactivisation: boolean;
var
  SQL: TIBSQL;
begin
  Result := ReplDataBase.TableExist(Tables[RPL_DBSTATE_INDEX]);
  if Result  then
  begin
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := ReplDataBase.ReadTransaction;
      SQl.SQl.Text := 'SELECT prepared FROM rpl$dbstate';
      SQL.ExecQuery;
      Result := SQL.FieldByName(fnPrepared).AsInteger = 1;
    finally
      SQL.Free;
    end;
  end;
end;

procedure TrpReplicationManager.Activization;
var
  SQL: TIBSQL;
begin
  {$IFDEF DEBUG}
  CheckInTransaction;
  {$ENDIF}
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := ReplDataBase.Transaction;
    ReplDataBase.Transaction.StartTransaction;
    try
      SQL.SQL.Text := 'UPDATE rpl$dbstate SET prepared = 1';
      SQL.ExecQuery;
      ReplDataBase.Transaction.Commit;
    except
      on E: Exception do
      begin
        ReplDataBase.Transaction.Rollback;
        Errors.Add(E.Message);
      end;
    end;
  finally
    SQl.Free;
  end;
end;

procedure TrpReplicationManager.Deactivization;
var
  SQL: TIBSQL;
begin
  {$IFDEF DEBUG}
  CheckInTransaction;
  {$ENDIF}
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := ReplDataBase.Transaction;
    ReplDataBase.Transaction.StartTransaction;
    try
      SQL.SQL.Text := 'UPDATE rpl$dbstate SET prepared = 0';
      SQL.ExecQuery;
      ReplDataBase.Transaction.Commit;
    except
      on E: Exception do
      begin
        ReplDataBase.Transaction.Rollback;
        Errors.Add(E.Message);
      end;
    end;
  finally
    SQl.Free;
  end;
end;

function TrpReplicationManager.RoleExist(Role: TRole): Boolean;
var
  SQL: TIBSQL;
begin
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := ReplDataBase.ReadTransaction;
    SQL.SQL.Add(Format('SELECT * FROM rdb$roles WHERE rdb$role_name = ''%s''', [Role]));
    SQL.ExecQuery;
    Result := SQL.RecordCount > 0;
  finally
    SQL.Free;
  end;
end;

procedure TrpReplicationManager.CheckRole(Role: TRole);
var
  SQL: TIBSQL;
begin
  if not RoleExist(Role) then
  begin
    {$IFDEF DEBUG}
    CheckInTransaction;
    {$ENDIF}
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := ReplDataBase.Transaction;
      ReplDataBase.Transaction.StartTransaction;
      try
        SQL.SQL.Add(Format('CREATE ROLE %s', [Role]));
        SQL.ExecQuery;
        ReplDataBase.Transaction.Commit;
        ReplDataBase.Transaction.StartTransaction;
        SQL.Close;
        SQl.SQL.Text := (Format('GRANT %s TO SYSDBA', [Role]));
        SQl.ExecQuery;
        ReplDataBase.Transaction.Commit;
      except
        on E: Exception do
        begin
          ReplDataBase.Transaction.Rollback;
          Errors.Add(Format(ERR_CREATE_ROLE, [Role]) + E.Message);
        end;
      end;
    finally
      SQL.Free;
    end;
  end;
end;

{ TrplCreateRole }

function TrplCreateRole.Description: string;
begin
  Result := CreateRole
end;

procedure TrplCreateRole.DoExecute;
begin
  ReplicationManager.CreateRole;
end;

procedure TrpReplicationManager.CreateRole;
begin
  CheckRole(Role);
end;

procedure TrpReplicationManager.DropRole;
var
  SQL: TIBSQL;
begin
  if RoleExist(Role) then begin
    {$IFDEF DEBUG}
    CheckInTransaction;
    {$ENDIF}
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := ReplDataBase.Transaction;
      ReplDataBase.Transaction.StartTransaction;
      try
        SQL.SQL.Add(Format('DROP ROLE %s', [Role]));
        SQL.ExecQuery;
        ReplDataBase.Transaction.Commit;
      except
        on E: Exception do begin
          ReplDataBase.Transaction.Rollback;
          Errors.Add(Format(ERR_DROP_ROLE, [Role]) + E.Message);
        end;
      end;
    finally
      SQL.Free;
    end;
  end;
end;

procedure TrpReplicationManager.GrandLog;
var
 SQL: TIBSQL;
 GrandSQL: TIBSQL;
 IBSecurityService: TIBSecurityService;
 I: Integer;
begin
  Exit;
  {$IFDEF DEBUG}
  CheckInTransaction;
  {$ENDIF}
  GrandSQL := TIBSQL.Create(nil);
  try
    GrandSQL.Transaction := ReplDataBase.Transaction;
    ReplDataBase.Transaction.StartTransaction;
    try
      SQL := TIBSQL.Create(nil);
      try
        SQL.Transaction := ReplDataBase.ReadTransaction;
        SQL.SQL.Text := 'SELECT rdb$role_name FROM rdb$roles';
        SQL.ExecQuery;
        while not SQL.Eof do
        begin
          GrandSQL.Close;
          GrandSQL.SQL.Text := Format('GRANT ALL ON TABLE rpl$log TO %s', [SQL.Fields[0].AsString]);
          GrandSQL.ExecQuery;
          SQL.Next;
        end;
      finally
        SQL.Free;
      end;

      IBSecurityService := TIBSecurityService.Create(nil);
      try
        IBSecurityService.ServerName := RepldataBase.ServerName;
        IBSecurityService.Protocol := TCP;
        IBSecurityService.LoginPrompt := False;
//        IBSecurityService.Params.Assign(ReplDataBase.Params);
        IBSecurityService.Params.Add(Format('user_name=%s', [ReplDataBase.Params.Values['user_name']]));
        IBSecurityService.Params.Add(Format('password=%s', [ReplDataBase.Params.Values['password']]));
        IBSecurityService.Active := True;
        IBSecurityService.DisplayUsers;
        for I := 0 to IBSecurityService.UserInfoCount - 1 do
        begin
          GrandSQL.Close;
          GrandSQL.SQL.Text := Format('GRANT ALL ON TABLE rpl$log TO %s', [IBSecurityService.UserInfo[I].UserName]);
          GrandSQl.ExecQuery;
        end;
      finally
        IBSecurityService.Free;
      end;

      ReplDataBase.Transaction.Commit;
    except
      on E: Exception do
      begin
        ReplDataBase.Transaction.Rollback;
        Errors.Add(ERR_CREATE_GRAND + E.Message);
      end;
    end;
  finally
    GrandSQL.Free;
  end;
end;

{ TrplUpdateReplDBList }

function TrplUpdateReplDBList.Description: string;
begin
  Result:= UpdateReplDBList;
end;

procedure TrplUpdateReplDBList.DoExecute;
begin
  inherited;
  ReplicationManager.UpdateReplDBList;
end;

{ TrplDropRole }

function TrplDropRole.Description: string;
begin
  Result := DropRole
end;

procedure TrplDropRole.DoExecute;
begin
  ReplicationManager.DropRole;
end;

initialization

finalization
  if _ReplicationManager <> nil then
    FreeAndNil(_ReplicationManager);
end.
