unit xSyncCustomer;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DB, DBTables, xBKIni, xTable;

type
  TxSyncCustomer = class(TComponent)
  private
    { Private declarations }
    FBookkeepTable: TxTable;
    FLocalTable: TTable;
    FBookkeepIni: TxBookkeepIni;
    FDatabaseName: String;
    FspAddCustomer: String;
    FNameLocalTable: String;

    function SetBookkeepTableInfo: Boolean;
    function SyncClient: Boolean;    
  protected
    { Protected declarations }
    procedure Loaded; override;
  public
    { Public declarations }
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    procedure SyncAll;
    procedure LocalSync;
    procedure AddClientToAnjelica(CustomerKey: Integer);
    procedure AddAllClientToAnjelica(isNew: Boolean);
    property spAddCustomer: String read FspAddCustomer;
  published
    { Published declarations }
    property DatabaseName: String read FDatabaseName write FDatabaseName;
    property NameLocalTable: String read FNameLocalTable write
      FNameLocalTable;
  end;

var
  SyncCustomer : TxSyncCustomer;

implementation

uses
  frmRunningBoy_unit;

{ TxSyncCustomer }

procedure TxSyncCustomer.AddAllClientToAnjelica(isNew: Boolean);
var
  qryCustomer: TQuery;
  N: Integer;
begin
  qryCustomer := TQuery.Create(Self);
  try
    qryCustomer.DatabaseName := FDatabaseName;
    qryCustomer.SQL.Add('SELECT customerkey FROM cst_customer');
    qryCustomer.SQL.Add('WHERE kind <> 2');
    if isNew then
      qryCustomer.SQL.Add('AND externalkey IS NULL');
    qryCustomer.Open;
    frmRunningBoy.xRunMan.Value := 0;
    N := 0;
    frmRunningBoy.lblName.Caption := 'Перенос клиентов в Бухгалтерии';
    frmRunningBoy.Show;
    while not qryCustomer.EOF do
    begin
      AddClientToAnjelica(qryCustomer.FieldByName('CustomerKey').AsInteger);
      Inc(N);
      if (N / qryCustomer.RecordCount * 20) >
        frmRunningBoy.xRunMan.Value then
          frmRunningBoy.xRunMan.Value := frmRunningBoy.xRunMan.Value + 1;
      qryCustomer.Next;
    end;
    frmRunningBoy.Hide;
    qryCustomer.Close;
  finally
    qryCustomer.Free;
  end;
end;

procedure TxSyncCustomer.AddClientToAnjelica(CustomerKey: Integer);
var
  spGetClient: TStoredProc;
  qryUpdateClient: TQuery;
  MaxNom, ExternalKey, i: Integer;
  isOk : Boolean;
  Times: LongWord;
begin
  if SetBookkeepTableInfo then
  begin
    spGetClient := TStoredProc.Create(Self);
    try
      spGetClient.DatabaseName := FDatabaseName;
      spGetClient.StoredProcName := 'fin_p_customer_getvalue';
      spGetClient.Unprepare;
      spGetClient.Prepare;
      spGetClient.ParamByName('CustomerKey').AsInteger := CustomerKey;
      spGetClient.ExecProc;
      FBookkeepTable.Open;
      isOk := False;
      if not spGetClient.ParamByName('KodKAU').IsNull then
      begin
        isOk :=
         FBookkeepTable.FindKey([spGetClient.ParamByName('KodKAU').AsInteger]);
        MaxNom := spGetClient.ParamByName('KodKAU').AsInteger;
        ExternalKey := -1;
      end else
      begin
        FBookkeepTable.Last;
        MaxNom := FBookkeepTable.FieldByName('KodKAU').AsInteger + 1;
        ExternalKey := MaxNom;
      end;
      if not isOk then
      begin
        FBookkeepTable.Append;
        FBookkeepTable.FieldByName('KodKAU').AsInteger := MaxNom;
      end else
      begin
        FBookkeepTable.Edit;
      end;
      for i:= 2 to spGetClient.Params.Count - 1 do
        FBookkeepTable.Fields[i - 1].Text :=
          spGetClient.Params[i].Text;
      Times := GetTickCount;
      repeat
        try
          FBookkeepTable.Post;
          Break;
        except
          if Times > GetTickCount + 10000 then begin
            FBookkeepTable.Cancel;
            Break;
          end;
          Inc(MaxNom);
          FBookkeepTable.FieldByName('KodKAU').AsInteger := MaxNom;
          ExternalKey := MaxNom;
        end;
      until False;
      if ExternalKey <> -1 then
      begin
        qryUpdateClient := TQuery.Create(Application);
        try
          qryUpdateClient.SQL.Add(FORMAT('UPDATE cst_customer SET externalKey = %d',
             [ExternalKey]));
          qryUpdateClient.SQL.Add(FORMAT('WHERE customerkey = %d', [CustomerKey]));
          qryUpdateClient.DatabaseName := FDatabaseName;
          qryUpdateClient.ExecSQL;
        finally
          qryUpdateClient.Free;
        end;
      end;
    finally
      FBookkeepTable.Close;
      spGetClient.Free;
    end;
  end;
end;

constructor TxSyncCustomer.Create(aOwner: TComponent);
begin
  Assert(SyncCustomer = nil);

  inherited Create(aOwner);
  SyncCustomer := Self;
  FBookkeepTable := TxTable.Create(Self);
  FBookkeepTable.UseOEMFormat := True;
  FLocalTable := TTable.Create(Self);
  FBookkeepIni := TxBookkeepIni.Create(Self);
  FspAddCustomer := 'FIN_P_CUSTOMER_IMPORT';
end;

destructor TxSyncCustomer.Destroy;
begin
  if FBookkeepTable <> nil then
  begin
    FBookkeepTable.Free;
    FBookkeepTable := nil;
  end;
  if FBookkeepIni <> nil then
  begin
    FBookkeepIni.Free;
    FBookkeepIni := nil;
  end;
  if FLocalTable <> nil then
  begin
    FLocalTable.Free;
    FLocalTable := nil;
  end;
  inherited Destroy;
  SyncCustomer := nil;
end;
          
procedure TxSyncCustomer.Loaded;
begin
  inherited Loaded;
  if not (csDesigning in ComponentState) and (FNameLocalTable <> '')
  then
  begin
    FLocalTable.TableName := FNameLocalTable;
    FLocalTable.DatabaseName := ExtractFilePath(Application.ExeName);
  end;
end;

procedure TxSyncCustomer.LocalSync;
var
  Times: LongWord;
begin
  if (FNameLocalTable = '') or not SetBookkeepTableInfo then exit;

  Times := GetTickCount;
  repeat
    try
      FLocalTable.Exclusive := True;
      FLocalTable.Open;
      Break;
    except
      if Times - GetTickCount > 20000 then
        exit;
    end;
  until False;

  FLocalTable.First;
  while not FLocalTable.EOF do begin
    FBookkeepTable.FindKey([FLocalTable.Fields[0].AsInteger]);
    if not SyncClient then Break;
    FLocalTable.Delete;
  end;
  
  FLocalTable.Close;
  FBookkeepTable.Close;
end;

function TxSyncCustomer.SetBookkeepTableInfo: Boolean;
begin
  Result := False;
  if (FBookkeepIni.SystemCode > 0) then
  begin
    FBookkeepTable.DatabaseName := FBookkeepIni.MainDir;
    FBookkeepTable.TableName := 'klient.db';
  end
  else
    exit;

  try
    FBookkeepTable.Open;
  except
    exit;
  end;
  
  Result := True;
end;

procedure TxSyncCustomer.SyncAll;
var
  N: Integer;
begin
  if not SetBookkeepTableInfo then exit;

  frmRunningBoy.xRunMan.Value := 0;
  N := 0;
  frmRunningBoy.lblName.Caption := 'Перенос клиентов из Бухгалтерии';
  frmRunningBoy.Show;
  FBookkeepTable.First;
  while not FBookkeepTable.EOF do begin
    if not SyncClient then Break;
    Inc(N);
    if (N / FBookkeepTable.RecordCount * 20) >
      frmRunningBoy.xRunMan.Value then
        frmRunningBoy.xRunMan.Value := frmRunningBoy.xRunMan.Value + 1;
    FBookkeepTable.Next;
  end;
  frmRunningBoy.Hide;
  FBookkeepTable.Close;
end;

function TxSyncCustomer.SyncClient: Boolean;
var
  stAddClient: TStoredProc;
  i: Integer;
begin
  Result := True;
  stAddClient := TStoredProc.Create(Self);
  stAddClient.DatabaseName := FDatabaseName;
  stAddClient.StoredProcName := FspAddCustomer;
  stAddClient.Unprepare;
  stAddClient.Prepare;
  try
    for i := 0 to FBookkeepTable.FieldCount - 1 do
      stAddClient.Params[i].AsString :=
        FBookkeepTable.Fields[i].Text;
    try
      stAddClient.ExecProc;
    except
      raise;
      {Result := False;}
    end;
  finally
    stAddClient.Free;
  end;
end;

initialization

  SyncCustomer := nil;

end.
