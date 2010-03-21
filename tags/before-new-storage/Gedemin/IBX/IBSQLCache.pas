
unit IBSQLCache;

interface

uses
  Classes, IBHeader, IB, IBDatabase, IBSQL, gd_KeyAssoc;

type
  TIBSQLCacheItem = class(TObject)
  public
    InUse: TIBSQL;
    Handle: TISC_STMT_HANDLE;
    SQLType: TIBSQLTypes;
    SQLRecord: TIBXSQLDA;
    SQLParams: TIBXSQLDA;
    ReleaseTime: Cardinal;
    FRequired: String;

    procedure Flush;
  end;

  TIBSQLCache = class(TObject)
  private
    FIBBase: TIBBase;
    FList: TgdKeyObjectAssoc;
    FLastClearTime: Cardinal;
    FEnabled: Boolean;

    function GetDatabase: TIBDatabase;
    procedure SetDatabase(const Value: TIBDatabase);
    procedure OnBeforeDatabaseDisconnect(Sender: TObject);
    procedure SetEnabled(const Value: Boolean);

  public
    constructor Create;
    destructor Destroy; override;

    procedure Flush;
    function FindItem(const S, ParamNames: String; q: TIBSQL): TIBSQLCacheItem;
    procedure BindHandle(const S: String; H: TISC_STMT_HANDLE; q: TIBSQL);
    function ReleaseStatement(H: TISC_STMT_HANDLE; q: TIBSQL): Boolean;

    property Database: TIBDatabase read GetDatabase write SetDatabase;
    property Enabled: Boolean read FEnabled write SetEnabled;
  end;

var
  _IBSQLCache: TIBSQLCache;

implementation

uses
  Windows, IBIntf, IBExternals, IBErrorCodes, SysUtils, jclSelected, jclStrings;

const
  MAX_COUNT = 100;
  CLEAR_INTERVAL = 60 * 15 * 1000; // in ms
  LIVE_INTERVAL = 60 * 70 * 1000;

{ TIBSQLCache }

procedure TIBSQLCache.BindHandle(const S: String; H: TISC_STMT_HANDLE; q: TIBSQL);
var
  L, I: Integer;
  Item: TIBSQLCacheItem;
begin
  if not FEnabled then
    exit;

  if StrIPos('SAVEPOINT ', S) > 0 then
    exit;

  if GetTickCount - FLastClearTime > CLEAR_INTERVAL then
  begin
    for I := FList.Count - 1 downto 0 do
    begin
      Item := FList.ObjectByIndex[I] as TIBSQLCacheItem;
      if (Item.InUse = nil) and (GetTickCount - Item.ReleaseTime > LIVE_INTERVAL) then
      begin
        Item.Flush;
        FList.Delete(I);
      end;
    end;
    FLastClearTime := GetTickCount;
  end;

  if FList.Count >= MAX_COUNT then
  begin
    for I := FList.Count - 1 downto 0 do
    begin
      Item := FList.ObjectByIndex[I] as TIBSQLCacheItem;
      if (Item.InUse = nil) and (Item.SQLParams.Count = 0) then
      begin
        Item.Flush;
        FList.Delete(I);
      end;
    end;
  end;

  if FList.Count < MAX_COUNT then
  begin
    L := Length(S);
    if L > 0 then
    begin
      Item := TIBSQLCacheItem.Create;
      Item.InUse := q;
      Item.Handle := H;
      Item.SQLType := q.SQLType;
      Item.SQLRecord := q.Current;
      Item.SQLParams := q.Params;

      for I := 0 to q.Current.Count - 1 do
      begin
        if not q.Current[I].IsNullable then
          Item.FRequired := Item.FRequired + '"' + q.Current[I].Name + '"';
      end;

      FList.AddObject(Crc32_P(@S[1], L, 0), Item);
    end;
  end;
end;

constructor TIBSQLCache.Create;
begin
  FIBBase := TIBBase.Create(nil);
  FIBBase.BeforeDatabaseDisconnect := OnBeforeDatabaseDisconnect;
  FList := TgdKeyObjectAssoc.Create(True);
  FList.Duplicates := dupAccept;
  FLastClearTime := GetTickCount;
end;

destructor TIBSQLCache.Destroy;
begin
  Flush;
  FList.Free;
  FIBBase.Free;
  inherited;
end;

function TIBSQLCache.FindItem(const S, ParamNames: String; q: TIBSQL): TIBSQLCacheItem;
var
  I, L: Integer;
  Item: TIBSQLCacheItem;
begin
  Result := nil;

  if not FEnabled then
    exit;

  L := Length(S);
  if L > 0 then
  begin
    I := FList.IndexOf(Crc32_P(@S[1], L, 0));
    if I > -1 then
    begin
      while (I > 0) and (FList.Keys[I - 1] = FList.Keys[I]) do
        Dec(I);

      repeat
        Item := FList.ObjectByIndex[I] as TIBSQLCacheItem;
        if (Item.InUse = nil) and (Item.SQLParams.Names = ParamNames) then
        begin
          Item.InUse := q;
          Result := Item;
          break;
        end;
        Inc(I);
      until (I >= FList.Count - 1) or (FList.Keys[I] <> FList.Keys[I - 1]);
    end;
  end;
end;

procedure TIBSQLCache.Flush;
var
  I: Integer;
begin
  if (Database <> nil) and Database.Connected then
  begin
    for I := 0 to FList.Count - 1 do
    begin
      (FList.ObjectByIndex[I] as TIBSQLCacheItem).Flush;
    end;
  end;  
  FList.Clear;
end;

function TIBSQLCache.GetDatabase: TIBDatabase;
begin
  Result := FIBBase.Database;
end;

procedure TIBSQLCache.OnBeforeDatabaseDisconnect(Sender: TObject);
begin
  Flush;
end;

function TIBSQLCache.ReleaseStatement(H: TISC_STMT_HANDLE;
  q: TIBSQL): Boolean;
var
  I: Integer;
  Item: TIBSQLCacheItem;
begin
  Result := True;
  for I := 0 to FList.Count - 1 do
  begin
    Item := FList.ObjectByIndex[I] as TIBSQLCacheItem;
    if (Item.InUse = q) then
    begin
      Assert(Item.Handle = H);
      Item.InUse := nil;
      Item.ReleaseTime := GetTickCount;
      Result := False;
      break;
    end;
  end;
end;

procedure TIBSQLCache.SetDatabase(const Value: TIBDatabase);
begin
  if Value <> FIBBase.Database then
  begin
    Flush;
    FIBBase.Database := Value;
  end;
end;

procedure TIBSQLCache.SetEnabled(const Value: Boolean);
begin
  if FEnabled <> Value then
  begin
    FEnabled := Value;
    if not FEnabled then
      Flush;
  end;
end;

{ TIBSQLCacheItem }

procedure TIBSQLCacheItem.Flush;
var
  isc_res: ISC_STATUS;
begin
  if InUse = nil then
  begin
    FRequired := '';
    SQLRecord.Free;
    SQLParams.Free;
    isc_res := isc_dsql_free_statement(StatusVector, @Handle, DSQL_drop);
    if (StatusVector^ = 1) and (isc_res > 0) and (isc_res <> isc_bad_stmt_handle) and
       (isc_res <> isc_lost_db_connection) then
      IBDataBaseError;
  end;
end;

initialization
  _IBSQLCache := TIBSQLCache.Create;

finalization
  FreeAndNil(_IBSQLCache);
end.

