unit prp_WatchList;

interface
uses classes, contnrs, sysutils, gd_directories_const;
type

  TWatch = class
  private
    FAllowFunctionCall: Boolean;
    FEnabled: Boolean;
    FBreakWhenChange: Boolean;
    FName: String;
    procedure SetAllowFunctionCall(const Value: Boolean);
    procedure SetBreakWhenChange(const Value: Boolean);
    procedure SetEnabled(const Value: Boolean);
    procedure SetName(const Value: String);
  public
    constructor Create;
    procedure SaveToStream(const Stream: TStream);
    procedure LoadFromStream(const Stream: TStream);
    procedure Assign(Source: TWatch);
    property Name: String read FName write SetName;
    property Enabled: Boolean read FEnabled write SetEnabled;
    property AllowFunctionCall: Boolean read FAllowFunctionCall write SetAllowFunctionCall;
    property BreakWhenChange: Boolean read FBreakWhenChange write SetBreakWhenChange;
  end;

  TWatchList = class(TObjectList)
  private
    function GetWatches(Index: Integer): TWatch;
    procedure SetWatches(Index: Integer; const Value: TWatch);
  public
    procedure SaveToStream(Stream: TStream);
    procedure LoadFromStream(Stream: TStream);
    procedure LoadFromStorage;
    procedure SaveToStorage;

    property Watches[Index: Integer]: TWatch read GetWatches write SetWatches; default;
  end;

var
  WatchList: TWatchList;

procedure CheckWatchList;
procedure SaveAndDestroyWatchList;

const
  sWatchPropertiesPath = 'Options\PropertySettings\WatchProperties';

implementation
uses prp_MessageConst, Storages;
type
  TLabelStream = array[0..3] of Char;

const
  SCR_WATCH = '^WCH';
  SCR_WATCH_LIST = 'WLST';
  LblSize = SizeOf(TLabelStream);

const
  cWatchList = 'WatchList';

procedure SaveAndDestroyWatchList;
begin
 if WatchList <> nil then
 begin
   WatchList.SaveToStorage;
   WatchList.Free;
   WatchList := nil;
 end;
end;

procedure CheckWatchList;
begin
  if WatchList = nil then
  begin
    WatchList := TWatchList.Create(True);
    WatchList.LoadFromStorage;
  end;
end;

function ReadStringFromStream(Stream: TStream): string;
var
  L: Integer;
  Str: String;
begin
  Stream.ReadBuffer(L, SizeOf(L));
  SetLength(str, L);
  Stream.ReadBuffer(str[1], L);
  Result := Str;
end;

procedure SaveStringToStream(Str: String; Stream: TStream);
var
  L: Integer;
begin
  L := Length(Str);
  Stream.WriteBuffer(L, SizeOf(L));
  Stream.WriteBuffer(Str[1], L);
end;

{ TWatch }

procedure TWatch.Assign(Source: TWatch);
begin
  FAllowFunctionCall := Source.FAllowFunctionCall;
  FEnabled := Source.FEnabled;
  FName := Source.FName;
end;

constructor TWatch.Create;
begin
  FEnabled := True;
  FAllowFunctionCall := True;
end;

procedure TWatch.LoadFromStream(const Stream: TStream);
begin
  if Stream = nil then
    raise Exception.Create(MSG_STREAM_DO_NOT_INIT);

  Stream.ReadBuffer(FEnabled, SizeOf(FEnabled));
  Stream.ReadBuffer(FAllowFunctionCall, SizeOf(FAllowFunctionCall));
  Stream.ReadBuffer(FBreakWhenChange, SizeOf(FBreakWhenChange));
  FName := ReadStringFromStream(Stream);
end;

procedure TWatch.SaveToStream(const Stream: TStream);
begin
  if Stream = nil then
    raise Exception.Create(MSG_STREAM_DO_NOT_INIT);

  Stream.WriteBuffer(FEnabled, SizeOf(FEnabled));
  Stream.WriteBuffer(FAllowFunctionCall, SizeOf(FAllowFunctionCall));
  Stream.WriteBuffer(FBreakWhenChange, SizeOf(FBreakWhenChange));
  SaveStringToStream(Fname, Stream);
end;

procedure TWatch.SetAllowFunctionCall(const Value: Boolean);
begin
  FAllowFunctionCall := Value;
end;

procedure TWatch.SetBreakWhenChange(const Value: Boolean);
begin
  FBreakWhenChange := Value;
end;

procedure TWatch.SetEnabled(const Value: Boolean);
begin
  FEnabled := Value;
end;

procedure TWatch.SetName(const Value: String);
begin
  FName := Value;
end;

{ TWatchList }

function TWatchList.GetWatches(Index: Integer): TWatch;
begin
  Result := TWatch(Items[Index]);
end;

procedure TWatchList.LoadFromStorage;
var
  Str: TMemoryStream;
begin
  if not Assigned(UserStorage) then
    Exit;

  Str := TMemoryStream.Create;
  try
    UserStorage.ReadStream(sWatchPropertiesPath, cWatchList, Str);
    Str.Position := 0;
    LoadFromStream(Str);
  finally
    Str.Free;
  end;
end;

procedure TWatchList.LoadFromStream(Stream: TStream);
var
  I, C: Integer;
  L: TLabelStream;
  W: TWatch;
begin
  if Stream = nil then
    raise Exception.Create(MSG_STREAM_DO_NOT_INIT);

  Clear;
  if Stream.Size > 0 then
  begin
    Stream.ReadBuffer(L, LblSize);
    if L <> SCR_WATCH then
      raise Exception.Create(MSG_WRONG_DATA);

    Stream.ReadBuffer(C, SizeOf(C));
    try
      for I := 0 to C - 1 do
      begin
        W := TWatch.Create;
        W.LoadFromStream(Stream);
        Add(W);
      end;
    except
      Clear;
    end;
  end;
end;

procedure TWatchList.SaveToStorage;
var
  Str: TMemoryStream;
begin
  if not Assigned(UserStorage) then
    Exit;

  Str := TMemoryStream.Create;
  try
    SaveToStream(Str);
    Str.Position := 0;
    UserStorage.WriteStream(sWatchPropertiesPath, cWatchList, Str);
  finally
    Str.Free;
  end;
end;

procedure TWatchList.SaveToStream(Stream: TStream);
var
  I: Integer;
begin
  if Stream = nil then
    raise Exception.Create(MSG_STREAM_DO_NOT_INIT);

  Stream.Write(SCR_WATCH, LblSize);
  Stream.WriteBuffer(Count, SizeOf(Count));
  for I := 0 to Count - 1 do
    Watches[I].SaveToStream(Stream);
end;

procedure TWatchList.SetWatches(Index: Integer; const Value: TWatch);
begin
  TWatch(Items[Index]).Assign(Value);
end;

initialization
finalization
end.
