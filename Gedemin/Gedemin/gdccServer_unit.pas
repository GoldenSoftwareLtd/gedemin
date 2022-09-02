// ShlTanya, 09.03.2019

unit gdccServer_unit;

interface

uses
  Classes, Windows, SysUtils, SyncObjs, ContNrs, idTCPServer, gdccGlobal, at_Log,
  jclStrHashMap, gdccConst;

const
  gdcc_nConnect      = 1;
  gdcc_nDisconnect   = 2;
  gdcc_nLog          = 3;
  gdcc_nShow         = 4;
  gdcc_nUserShow     = 5;

  gdcc_nHostName     = 6;
  gdcc_nProc         = 7;

type
  TgdccProfilerObject = class(TObject)
  private
    FID: Integer;
    FSrc, FName: String;
    FCount, FTotal, FMax: Int64;
    function GetAvg: Int64;

  public
    constructor Create;

    property ID: Integer read FID write FID;
    property Count: Int64 read FCount write FCount;
    property Src: String read FSrc write FSrc;
    property Name: String read FName write FName;
    property Total: Int64 read FTotal write FTotal;
    property Max: Int64 read FMax write FMax;
    property Avg: Int64 read GetAvg;
  end;

  TgdccProfiler = class(TObject)
  private
    FObjects: TObjectList;
    FIDLast: Integer;
    FHash: TStringHashMap;

    FFilteredCount, FFilteredSize: Integer;
    FFilteredArray: array of Integer;
    FFilterStr: String;
    FFilterSrc: String;

    function GetCount: Integer;
    function FilterRecord(const Index: Integer): Boolean;
    function GetProfilerRec(Index: Integer): TgdccProfilerObject;
    function GetFilteredProfilerRec(Index: Integer): TgdccProfilerObject;

    procedure GrowFilteredArray;

  public
    constructor Create;
    destructor Destroy; override;

    procedure SortBySrc(const Ascending: Boolean);
    procedure SortByName(const Ascending: Boolean);
    procedure SortByCount(const Ascending: Boolean);
    procedure SortByAvg(const Ascending: Boolean);
    procedure SortByMax(const Ascending: Boolean);
    procedure SortByTotal(const Ascending: Boolean);

    procedure FilterRecords(const AFilterStr, AFilterSrc: String);

    function AddProfileItem(const ASrc, AName: String;
      const AnElapsed: Cardinal): TgdccProfilerObject;
    function Find(const AnID: Integer; out SP: TgdccProfilerObject): Boolean;
    function GetLast(out SP: TgdccProfilerObject): Boolean;
    function GetByIndex(const AnIndex: Integer; out SP: TgdccProfilerObject): Boolean;
    procedure SaveToFile(const AFileName: String);
    procedure Clear;

    property Count: Integer read GetCount;

    property FilteredCount: Integer read FFilteredCount;
    property FilterStr: String read FFilterStr;
    property FilterSrc: String read FFilterSrc;
    property FilteredProfilerRec[Index: Integer]: TgdccProfilerObject read GetFilteredProfilerRec;
  end;

  TgdccConnection = class(TObject)
  private
    FID: Integer;
    FThread: TIdPeerThread;
    FConnected, FDisconnected: TDateTime;
    FLog: TatLog;
    FProgress: TgdccProgress;
    FProgressHandle: THandle;
    FProgressCanceled: Boolean;
    FHostName: String;
    FProfiler: TgdccProfiler;

  public
    constructor Create;
    destructor Destroy; override;

    property Connected: TDateTime read FConnected write FConnected;
    property Disconnected: TDateTime read FDisconnected write FDisconnected;
    property Thread: TIdPeerThread read FThread write FThread;
    property ID: Integer read FID;
    property Log: TatLog read FLog;
    property Progress: TgdccProgress read FProgress;
    property ProgressHandle: THandle read FProgressHandle write FProgressHandle;
    property ProgressCanceled: Boolean read FProgressCanceled write FProgressCanceled;

    property HostName: String read FHostName write FHostName;
    property Profiler: TgdccProfiler read FProfiler;
  end;

  TgdccConnections = class(TObjectList)
  private
    FCS: TCriticalSection;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Lock;
    procedure Unlock;

    function AddAndLock: TgdccConnection;
    function FindAndLock(const AnID: Integer; out C: TgdccConnection): Boolean; overload;
    function FindAndLock(P: TObject; out C: TgdccConnection): Boolean; overload;
    procedure DeleteConnection(const AnID: Integer);
  end;

  TgdccServer = class(TObject)
  private
    FTCPServer: TidTCPServer;
    FConnections: TgdccConnections;
    FNotifyHandle: THandle;
    FCurrConnectionID: Integer;
    FLastLogNotified, FLastProfilerNotified: DWORD;

    function GetActive: Boolean;

    procedure ServerConnect(AThread: TIdPeerThread);
    procedure ServerExecute(AThread: TIdPeerThread);
    procedure ServerDisconnect(AThread: TIdPeerThread);

    procedure StartWork;
    procedure StartStep;
    procedure EndWork;

    function ShouldNotify(var LN: DWORD): Boolean;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Activate;
    procedure Deactivate;

    procedure Log(P: TObject; const ASrc, AMessage: String; const ALogType: Integer = gdcc_lt_Info);
    procedure SendHello;

    property Active: Boolean read GetActive;
    property NotifyHandle: THandle read FNotifyHandle write FNotifyHandle;
    property Connections: TgdccConnections read FConnections;
  end;

var
  gdccServer: TgdccServer;

implementation

uses
  Forms, idSocketHandle, idException, gd_common_functions, gdcc_frmProgress_unit, JclStrings;

var
  _ConnectionID, _ProfilerID: Integer;

{ TgdccServer }

procedure TgdccServer.Activate;
var
  Binding : TIdSocketHandle;
begin
  Binding := FTCPServer.Bindings.Add;
  Binding.Port := gdccDefPort;
  Binding.IP := gdccDefAddress;
  try
    FTCPServer.Active := True;
  except
    //
  end;
end;

constructor TgdccServer.Create;
begin
  FConnections := TgdccConnections.Create;
  FTCPServer := TidTCPServer.Create(nil);
  FTCPServer.OnConnect := ServerConnect;
  FTCPServer.OnExecute := ServerExecute;
  FTCPServer.OnDisconnect := ServerDisconnect;
end;

procedure TgdccServer.Deactivate;
var
  I: Integer;
begin
  FConnections.Lock;
  try
    for I := 0 to FConnections.Count - 1 do
    begin
      if (FConnections[0] as TgdccConnection).Thread <> nil then
        TgdccCommand.WriteCommand((FConnections[0] as TgdccConnection).Thread.Connection, gdcc_cmd_ServerClosing);
    end;
    FConnections.Clear;
  finally
    FConnections.Unlock;
  end;
end;

destructor TgdccServer.Destroy;
begin
  FTCPServer.Free;
  FConnections.Free;
  inherited;
end;

procedure TgdccServer.EndWork;
var
  C: TgdccConnection;
begin
  if FConnections.FindAndLock(FCurrConnectionID, C) then
  try
    if C.Progress.HideOnFinish or C.ProgressCanceled then
    begin
      PostMessage(C.ProgressHandle, WM_GDCC_PROGRESS_RELEASE, 0, 0);
      C.ProgressHandle := 0;
    end else
    begin
      PostMessage(C.ProgressHandle, WM_GDCC_PROGRESS_UPDATE, 0, 0);
    end;
    C.Log.AddRecord('progress', 'End work', atltInfo);
  finally
    FConnections.Unlock;
  end;
end;

function TgdccServer.GetActive: Boolean;
begin
  Result := FTCPServer.Active;
end;

procedure TgdccServer.Log(P: TObject; const ASrc, AMessage: String;
  const ALogType: Integer = gdcc_lt_Info);
var
  C: TgdccConnection;
begin
  if FConnections.FindAndLock(P, C) then
  try
    case ALogType of
      gdcc_lt_Error: C.Log.AddRecord(ASrc, AMessage, atltError);
      gdcc_lt_Warning: C.Log.AddRecord(ASrc, AMessage, atltWarning);
    else
      C.Log.AddRecord(ASrc, AMessage, atltInfo);
    end;
    if ShouldNotify(FLastLogNotified) then
      PostMessage(FNotifyHandle, WM_GDCC_SERVER_NOTIFY, gdcc_nLog, C.ID);
  finally
    FConnections.Unlock;
  end;
end;

procedure TgdccServer.SendHello;
begin
  FConnections.Lock;
  try
    if FConnections.Count > 0 then
    begin
      TgdccCommand.WriteCommand((FConnections[0] as
        TgdccConnection).Thread.Connection, gdcc_cmd_Hello);
    end;
  finally
    FConnections.Unlock;
  end;
end;

procedure TgdccServer.ServerConnect(AThread: TIdPeerThread);
var
  NewConnection: TgdccConnection;
begin
  NewConnection := FConnections.AddAndLock;
  try
    NewConnection.Connected := Now;
    NewConnection.Thread := AThread;
    NewConnection.Log.AddRecord('Connected');
    if FNotifyHandle <> 0 then
      PostMessage(FNotifyHandle, WM_GDCC_SERVER_NOTIFY, gdcc_nConnect, NewConnection.ID);
    AThread.Data := NewConnection;
  finally
    FConnections.Unlock;
  end;
end;

procedure TgdccServer.ServerDisconnect(AThread: TIdPeerThread);
var
  C: TgdccConnection;
begin
  if FConnections.FindAndLock(AThread.Data, C) then
  try
    Log(C, '', 'Disconnected');
    C.Thread := nil;
    C.Disconnected := Now;
    if C.ProgressHandle <> 0 then
    begin
      PostMessage(C.ProgressHandle, WM_GDCC_PROGRESS_RELEASE, 0, 0);
      C.ProgressHandle := 0;
    end;
    if FNotifyHandle <> 0 then
      PostMessage(FNotifyHandle, WM_GDCC_SERVER_NOTIFY, gdcc_nDisconnect, C.ID);
  finally
    FConnections.Unlock;
  end;
  AThread.Data := nil;
end;

procedure TgdccServer.ServerExecute(AThread: TIdPeerThread);

  procedure ReadProgress(S: TStream);
  var
    C: TgdccConnection;
  begin
    if FConnections.FindAndLock(AThread.Data, C) then
    try
      C.Progress.LoadFromStream(S);
      FCurrConnectionID := C.ID;
    finally
      FConnections.Unlock;
    end;
  end;

var
  S: TMemoryStream;
  Cmd, Flags, WarnCount, ErrorCount: Integer;
  FileHandle: Cardinal;
  C: TgdccConnection;
  SSrc, SMsg, SHostName: String;
  LT: Integer;
  Process: TgdccProcess;
  SL: TStringList;
  SS: TStringStream;
begin
  S := TMemoryStream.Create;
  try
    try
      if AThread.Connection.Connected then
        Cmd := TgdccCommand.ReadCommand(AThread.Connection, S)
      else
        exit;

      case Cmd of
        gdcc_cmd_Connect:
        begin
          SHostName := ReadStringFromStream(S);

          if FConnections.FindAndLock(AThread.Data, C) then
          try
            C.HostName := SHostName;
            if FNotifyHandle <> 0 then
              PostMessage(FNotifyHandle, WM_GDCC_SERVER_NOTIFY, gdcc_nHostName, C.ID);
          finally
            FConnections.Unlock;
          end;

          TgdccCommand.WriteCommand(AThread.Connection, gdcc_cmd_AckConnect,
            gdccVersion);
          Log(AThread.Data, '', 'Cmd - Connect ' + SHostName);
        end;

        gdcc_cmd_Disconnect:
        begin
          FileHandle := ReadCardinalFromStream(S);
          if (FileHandle > 32) and (FNotifyHandle <> 0) then
            PostMessage(FNotifyHandle, WM_GDCC_SERVER_CLOSE, 0, 0);
          Log(AThread.Data, '', 'Cmd - Disconnect');
        end;

        gdcc_cmd_StartWork:
        begin
          ReadProgress(S);
          AThread.Synchronize(StartWork);
        end;

        gdcc_cmd_EndWork:
        begin
          ReadProgress(S);
          AThread.Synchronize(EndWork);
        end;

        gdcc_cmd_StartStep:
        begin
          ReadProgress(S);
          AThread.Synchronize(StartStep);
          if FConnections.FindAndLock(AThread.Data, C) then
          try
            if C.ProgressCanceled then
              TgdccCommand.WriteCommand(AThread.Connection, gdcc_cmd_CancelProgress);
          finally
            FConnections.Unlock;
          end;
        end;

        gdcc_cmd_Record:
        begin
          LT := ReadIntegerFromStream(S);
          SSrc := ReadStringFromStream(S);
          SMsg := ReadStringFromStream(S);
          Log(AThread.Data, SSrc, SMsg, LT);
        end;

        gdcc_cmd_UserShowLog:
        begin
          if FNotifyHandle <> 0 then
            PostMessage(FNotifyHandle, WM_GDCC_SERVER_NOTIFY, gdcc_nUserShow, 0);
        end;

        gdcc_cmd_ShowLog:
        begin
          if FNotifyHandle <> 0 then
            PostMessage(FNotifyHandle, WM_GDCC_SERVER_NOTIFY, gdcc_nShow, 0);
        end;

        gdcc_cmd_Process:
        begin
          Process := TgdccProcess.Create;
          try
            Process.LoadFromStream(S);
            if FConnections.FindAndLock(AThread.Data, C) then
            try
              C.Profiler.AddProfileItem(Process.Src, Process.Name,
                ((Process.Stop - Process.Start) * 1000000) div Process.Freq);
              if ShouldNotify(FLastProfilerNotified) then
                PostMessage(FNotifyHandle, WM_GDCC_SERVER_NOTIFY, gdcc_nProc, C.ID);
            finally
              FConnections.Unlock;
            end;
          finally
            Process.Free;
          end;
        end;

        gdcc_cmd_GetLog:
        begin
          if FConnections.FindAndLock(AThread.Data, C) then
          try
            Flags := ReadIntegerFromStream(S);
            SS := TStringStream.Create('');
            SL := TStringList.Create;
            try
              C.Log.SaveToStringList((Flags and gdcc_lt_Info) <> 0,
                (Flags and gdcc_lt_Warning) <> 0, WarnCount, ErrorCount, SL);
              SaveStringToStream(SL.CommaText, SS);
                TgdccCommand.WriteCommand(AThread.Connection, gdcc_cmd_LogTransfered, SS);
            finally
              SS.Free;
              SL.Free;
            end;
          finally
            FConnections.Unlock;
          end;
        end;

      else
        Log(AThread.Data, 'gdcc', 'Unknown command');
      end;
    except
      on EidConnClosedGracefully do
        raise;

      on E: Exception do
      begin
        Log(AThread.Data, 'gdcc', E.Message, gdcc_lt_Error);
        raise;
      end;
    end;
  finally
    S.Free;
  end;
end;

function TgdccServer.ShouldNotify(var LN: DWORD): Boolean;
var
  T: DWORD;
begin
  T := GetTickCount;
  if (FNotifyHandle <> 0)
    and
    (
      (
        (T > LN)
        and
        ((T - LN) > 2000)
      )
      or
      (T < LN)
    ) then
  begin
    LN := T;
    Result := True;
  end else
    Result := False;
end;

procedure TgdccServer.StartStep;
var
  C: TgdccConnection;
  F: Tgdcc_frmProgress;
begin
  if FConnections.FindAndLock(FCurrConnectionID, C) then
  try
    if C.ProgressHandle = 0 then
    begin
      F := Tgdcc_frmProgress.Create(Application);
      F.ConnectionID := C.ID;
      C.ProgressHandle := F.Handle;
      C.ProgressCanceled := False;
    end;
    PostMessage(C.ProgressHandle, WM_GDCC_PROGRESS_UPDATE, 0, 0);
  finally
    FConnections.Unlock;
  end;
end;

procedure TgdccServer.StartWork;
var
  C: TgdccConnection;
  F: Tgdcc_frmProgress;
begin
  if FConnections.FindAndLock(FCurrConnectionID, C) then
  begin
    try
      if C.ProgressHandle <> 0 then
        PostMessage(C.ProgressHandle, WM_GDCC_PROGRESS_RELEASE, 0, 0);
      F := Tgdcc_frmProgress.Create(Application);
      F.ConnectionID := C.ID;
      C.ProgressHandle := F.Handle;
      C.ProgressCanceled := False;
      C.Log.AddRecord('progress', 'Start work', atltInfo);
    finally
      FConnections.Unlock;
    end;

    F.Show;
    PostMessage(F.Handle, WM_GDCC_PROGRESS_UPDATE, 0, 0);
  end;
end;

{ TgdccConnections }

function TgdccConnections.AddAndLock: TgdccConnection;
begin
  Lock;
  Result := TgdccConnection.Create;
  Result.FID := _ConnectionID;
  if _ConnectionID = MAXINT then
    _ConnectionID := 1
  else
    Inc(_ConnectionID);
  Add(Result);
end;

constructor TgdccConnections.Create;
begin
  inherited Create(True);
  FCS := TCriticalSection.Create;
end;

procedure TgdccConnections.DeleteConnection(const AnID: Integer);
var
  I: Integer;
begin
  Lock;
  try
    for I := 0 to Count - 1 do
      if (Items[I] as TgdccConnection).ID = AnID then
      begin
        Delete(I);
        break;
      end;
  finally
    Unlock;
  end;
end;

destructor TgdccConnections.Destroy;
begin
  inherited;
  FCS.Free;
end;

function TgdccConnections.FindAndLock(const AnID: Integer;
  out C: TgdccConnection): Boolean;
var
  I: Integer;
begin
  C := nil;
  Lock;
  for I := 0 to Count - 1 do
    if (Items[I] as TgdccConnection).ID = AnID then
    begin
      C := Items[I] as TgdccConnection;
      break;
    end;
  if C = nil then
    Unlock;
  Result := C <> nil;
end;

function TgdccConnections.FindAndLock(P: TObject; out C: TgdccConnection): Boolean;
var
  I: Integer;
begin
  C := nil;
  Lock;
  for I := 0 to Count - 1 do
    if Items[I] = P then
    begin
      C := Items[I] as TgdccConnection;
      break;
    end;
  if C = nil then
    Unlock;
  Result := C <> nil;
end;

procedure TgdccConnections.Lock;
begin
  FCS.Enter;
end;

procedure TgdccConnections.Unlock;
begin
  FCS.Leave;
end;

{ TgdccConnection }

constructor TgdccConnection.Create;
begin
  FLog := TatLog.Create;
  FProgress := TgdccProgress.Create;
  FProfiler := TgdccProfiler.Create;
end;

destructor TgdccConnection.Destroy;
begin
  FProfiler.Free;
  FProgress.Free;
  FLog.Free;
  inherited;
end;

{ TgdccProfiler }

function TgdccProfiler.AddProfileItem(const ASrc, AName: String;
  const AnElapsed: Cardinal): TgdccProfilerObject;
var
  SP: TgdccProfilerObject;
begin
  if not FHash.Find(AName + ASrc, SP) then
  begin
    SP := TgdccProfilerObject.Create;
    SP.FSrc := ASrc;
    SP.FName := AName;
    FObjects.Add(SP);
    FHash.Add(AName + ASrc, SP);

    if FilterRecord(FObjects.Count - 1) then
    begin
      GrowFilteredArray;
      FFilteredArray[FFilteredCount] := FObjects.Count - 1;
      Inc(FFilteredCount);
    end;
  end;
  SP.FCount := SP.FCount + 1;
  SP.FTotal := SP.FTotal + AnElapsed;
  if AnElapsed > SP.FMax then
    SP.FMax := AnElapsed;
  FIDLast := SP.ID;
  Result := SP;
end;

function TgdccProfiler.Find(const AnID: Integer;
  out SP: TgdccProfilerObject): Boolean;
var
  I: Integer;
begin
  SP := nil;
  for I := 0 to FObjects.Count - 1 do
    if (FObjects[I] as TgdccProfilerObject).ID = AnID then
    begin
      SP := FObjects[I] as TgdccProfilerObject;
      break;
    end;
  Result := SP <> nil;
end;

function CompareSrc(Item1, Item2: TgdccProfilerObject): Integer;
begin
  Result := AnsiCompareText(Item1.Src, Item2.Src);
  if Result = 0 then
    Result := Item1.ID - Item2.ID;
end;

function CompareName(Item1, Item2: TgdccProfilerObject): Integer;
begin
  Result := AnsiCompareText(Item1.Name, Item2.Name);
  if Result = 0 then
    Result := Item1.ID - Item2.ID;
end;

function CompareCount(Item1, Item2: TgdccProfilerObject): Integer;
begin
  Result := Item1.Count - Item2.Count;
  if Result = 0 then
    Result := Item1.ID - Item2.ID;
end;

function CompareAvg(Item1, Item2: TgdccProfilerObject): Integer;
begin
  if Item1.Avg < Item2.Avg then
    Result := -1
  else if Item1.Avg > Item2.Avg then
    Result := 1
  else
    Result := Item1.ID - Item2.ID;
end;

function CompareMax(Item1, Item2: TgdccProfilerObject): Integer;
begin
  if Item1.Max < Item2.Max then
    Result := -1
  else if Item1.Max > Item2.Max then
    Result := 1
  else
    Result := Item1.ID - Item2.ID;
end;

function CompareTotal(Item1, Item2: TgdccProfilerObject): Integer;
begin
  if Item1.Total < Item2.Total then
    Result := -1
  else if Item1.Total > Item2.Total then
    Result := 1
  else
    Result := Item1.ID - Item2.ID;
end;

function RevCompareSrc(Item1, Item2: TgdccProfilerObject): Integer;
begin
  Result := CompareSrc(Item2, Item1);
end;

function RevCompareName(Item1, Item2: TgdccProfilerObject): Integer;
begin
  Result := CompareName(Item2, Item1);
end;

function RevCompareCount(Item1, Item2: TgdccProfilerObject): Integer;
begin
  Result := CompareCount(Item2, Item1);
end;

function RevCompareAvg(Item1, Item2: TgdccProfilerObject): Integer;
begin
  Result := CompareAvg(Item2, Item1);
end;

function RevCompareMax(Item1, Item2: TgdccProfilerObject): Integer;
begin
  Result := CompareMax(Item2, Item1);
end;

function RevCompareTotal(Item1, Item2: TgdccProfilerObject): Integer;
begin
  Result := CompareTotal(Item2, Item1);
end;

procedure TgdccProfiler.SortBySrc(const Ascending: Boolean);
begin
  if Ascending then
    FObjects.Sort(@CompareSrc)
  else
    FObjects.Sort(@RevCompareSrc);

  FilterRecords(FFilterStr, FFilterSrc);
end;

procedure TgdccProfiler.SortByName(const Ascending: Boolean);
begin
  if Ascending then
    FObjects.Sort(@CompareName)
  else
    FObjects.Sort(@RevCompareName);

  FilterRecords(FFilterStr, FFilterSrc);
end;

procedure TgdccProfiler.SortByCount(const Ascending: Boolean);
begin
  if Ascending then
    FObjects.Sort(@CompareCount)
  else
    FObjects.Sort(@RevCompareCount);

  FilterRecords(FFilterStr, FFilterSrc);
end;

procedure TgdccProfiler.SortByAvg(const Ascending: Boolean);
begin
  if Ascending then
    FObjects.Sort(@CompareAvg)
  else
    FObjects.Sort(@RevCompareAvg);

  FilterRecords(FFilterStr, FFilterSrc);
end;

procedure TgdccProfiler.SortByMax(const Ascending: Boolean);
begin
  if Ascending then
    FObjects.Sort(@CompareMax)
  else
    FObjects.Sort(@RevCompareMax);

  FilterRecords(FFilterStr, FFilterSrc);
end;

procedure TgdccProfiler.SortByTotal(const Ascending: Boolean);
begin
  if Ascending then
    FObjects.Sort(@CompareTotal)
  else
    FObjects.Sort(@RevCompareTotal);

  FilterRecords(FFilterStr, FFilterSrc);
end;

function TgdccProfiler.GetLast(out SP: TgdccProfilerObject): Boolean;
begin
  Result := Find(FIDLast, SP);
end;

function TgdccProfiler.GetByIndex(const AnIndex: Integer;
  out SP: TgdccProfilerObject): Boolean;
begin
  if (AnIndex >= 0) and (AnIndex < FObjects.Count) then
    SP := FObjects[AnIndex] as TgdccProfilerObject
  else
    SP := nil;
  Result := SP <> nil;
end;

constructor TgdccProfiler.Create;
begin
  FObjects := TObjectList.Create(True);
  FHash := TStringHashMap.Create(TCaseSensitiveTraits.Create, 99929);
  FIDLast := -1;
end;

destructor TgdccProfiler.Destroy;
begin
  FHash.Free;
  FObjects.Free;
  inherited;
end;

function TgdccProfiler.GetCount: Integer;
begin
  Result := FObjects.Count;
end;

procedure TgdccProfiler.SaveToFile(const AFileName: String);

  function QuoteStr(const S: String): String;
  begin
    if S = '' then
      Result := ''
    else
      Result := '"' +
        StringReplace(
          StringReplace(
            StringReplace(S,
              #13#10#32, #32, [rfReplaceAll]),
            #13#10, #32, [rfReplaceAll]),
          '"', '""', [rfReplaceAll]) + '"';
  end;

var
  F: TextFile;
  P: TgdccProfilerObject;
  I: Integer;
begin
  AssignFile(F, AFileName);
  Rewrite(F);
  try
    for I := 0 to FObjects.Count - 1 do
    begin
      P := FObjects[I] as TgdccProfilerObject;

      Writeln(F, QuoteStr(P.Src) + ',' +
        QuoteStr(Copy(P.Name, 1, 256)) + ',' +
        IntToStr(P.Count) + ',' +
        IntToStr(P.Avg) + ',' +
        IntToStr(P.Max) + ',' +
        IntToStr(P.Total));
    end;
  finally
    CloseFile(F);
  end;
end;

function TgdccProfiler.FilterRecord(const Index: Integer): Boolean;
begin
  Assert((Index >= 0) and (Index < FObjects.Count));

  Result :=
    (
      (FFilterSrc = '')
      or
      ((FObjects[Index] as TgdccProfilerObject).Src = FFilterSrc)
    )
    and
    (
      (FFilterStr = '')
      or
      (StrIPos(FFilterStr, (FObjects[Index] as TgdccProfilerObject).Name) > 0)
    );
end;

procedure TgdccProfiler.FilterRecords(const AFilterStr, AFilterSrc: String);
var
  I: Integer;
begin
  FFilterStr := AFilterStr;
  FFilterSrc := AFilterSrc;

  FFilteredCount := 0;
  for I := 0 to FObjects.Count - 1 do
  begin
    if FilterRecord(I) then
    begin
      GrowFilteredArray;
      FFilteredArray[FFilteredCount] := I;
      Inc(FFilteredCount);
    end;
  end;
end;

procedure TgdccProfiler.GrowFilteredArray;
begin
  if FFilteredCount >= FFilteredSize then
  begin
    if FFilteredSize = 0 then
      FFilteredSize := 64
    else
      FFilteredSize := FFilteredSize * 2;
    SetLength(FFilteredArray, FFilteredSize);
  end;
end;

function TgdccProfiler.GetFilteredProfilerRec(Index: Integer): TgdccProfilerObject;
begin
  Assert((Index >= 0) and (Index < FFilteredCount));
  Result := GetProfilerRec(FFilteredArray[Index]);
end;

function TgdccProfiler.GetProfilerRec(Index: Integer): TgdccProfilerObject;
begin
  Assert((Index >= 0) and (Index < FObjects.Count));
  Result := FObjects[Index] as TgdccProfilerObject;
end;

procedure TgdccProfiler.Clear;
begin
  FHash.Clear;
  FObjects.Clear;
end;

{ TgdccProfilerObject }

constructor TgdccProfilerObject.Create;
begin
  inherited;
  FID := _ProfilerID;
  if _ProfilerID = MAXINT then
    _ProfilerID := 1
  else
    Inc(_ProfilerID);
end;


function TgdccProfilerObject.GetAvg: Int64;
begin
  Result := Total div Count;
end;

initialization
  _ConnectionID := 1;
  _ProfilerID := 1;
  gdccServer := TgdccServer.Create;
  gdccServer.Activate;

finalization
  gdccServer.Deactivate;
  FreeAndNil(gdccServer);
end.
