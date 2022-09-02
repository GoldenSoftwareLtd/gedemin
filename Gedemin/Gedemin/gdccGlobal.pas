// ShlTanya, 09.03.2019

unit gdccGlobal;

interface

uses
  Classes, idTCPConnection, ContNrs, SyncObjs;

type
  TgdccHeader = record
    Signature: Integer;
    Version: Integer;
    Command: Integer;
    DataSize: Integer;
  end;

  TgdccCommand = class(TObject)
  private
    FHdr: TgdccHeader;
    FStream: TStream;

  public
    destructor Destroy; override;

    function Read(AConnection: TidTCPConnection): Boolean;

    class function ReadCommand(AConnection: TidTCPConnection;
      AStream: TStream): Integer; overload;
    class function ReadCommand(AConnection: TidTCPConnection): Integer; overload;
    class function ReadCommand(AConnection: TidTCPConnection;
      out AData: Cardinal): Integer; overload;
    class function WriteCommand(AConnection: TidTCPConnection; const ACommand: Integer;
      AStream: TStream): Boolean; overload;
    class function WriteCommand(AConnection: TidTCPConnection; const ACommand: Integer): Boolean;
      overload;
    class function WriteCommand(AConnection: TidTCPConnection; const ACommand: Integer;
      AData: Cardinal): Boolean; overload;

    property Hdr: TgdccHeader read FHdr;
    property Stream: TStream read FStream;
  end;

  TgdccProgress = class(TObject)
  private
    FID: Integer;
    FCaption: String;
    FName: String;
    FDone: Boolean;
    FCanceled: Boolean;
    FStepTotal: Integer;
    FStepDone: Integer;
    FStepName: String;
    FStepWeight: Integer;
    FStarted: TDateTime;
    FFinished: TDateTime;
    FCanCancel: Boolean;
    FShow: Boolean;
    FHideOnFinish: Boolean;
    FFinishMessage: String;

    function GetElapsed: TDateTime;
    function GetEstimFinish: TDateTime;
    function GetEstimLeft: TDateTime;
    function GetWorkStarted: Boolean;
    procedure SendCommand(const ACommand: Integer);
    procedure CheckWorkStarted;

  public
    procedure Assign(ASource: TgdccProgress);
    procedure SaveToStream(S: TStream);
    procedure LoadFromStream(S: TStream);

    procedure StartWork(const ACaption, AWorkName: String; const AStepTotal: Integer;
      const AShow: Boolean = True; const ACanCancel: Boolean = True);
    procedure EndWork(const AMessage: String = ''; const AHide: Boolean = True);
    procedure StartStep(const AStepName: String; const AStepWeight: Integer = 1);

    property ID: Integer read FID;
    property Caption: String read FCaption;
    property Name: String read FName;
    property StepTotal: Integer read FStepTotal;
    property StepDone: Integer read FStepDone;
    property StepName: String read FStepName;
    property Started: TDateTime read FStarted;
    property Finished: TDateTime read FFinished;
    property Elapsed: TDateTime read GetElapsed;
    property EstimLeft: TDateTime read GetEstimLeft;
    property EstimFinish: TDateTime read GetEstimFinish;
    property Canceled: Boolean read FCanceled;
    property WorkStarted: Boolean read GetWorkStarted;
    property Done: Boolean read FDone;
    property HideOnFinish: Boolean read FHideOnFinish;
    property FinishMessage: String read FFinishMessage;
    property CanCancel: Boolean read FCanCancel;
  end;

  TgdccProcess = class(TObject)
  private
    FID: Integer;
    FSrc, FName: String;
    FStart, FStop, FFreq: Int64;

  public
    constructor Create;
    destructor Destroy; override;

    procedure DoStop;
    procedure SaveToStream(ASt: TStream);
    procedure LoadFromStream(ASt: TStream);

    property ID: Integer read FID write FID;
    property Src: String read FSrc write FSrc;
    property Name: String read FName write FName;
    property Start: Int64 read FStart write FStart;
    property Stop: Int64 read FStop write FStop;
    property Freq: Int64 read FFreq write FFreq;
  end;

  TgdccProcesses = class(TObjectList)
  private
    FCS: TCriticalSection;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Lock;
    procedure Unlock;

    function AddAndLock: TgdccProcess;
    function FindAndLock(const AnID: Integer; out P: TgdccProcess): Boolean;
  end;

implementation

uses
  SysUtils, gdccConst, gdccClient_unit, gd_common_functions, idException,
  Windows;

var
  _ProcessID: Integer;

{ TgdccProgress }

procedure TgdccProgress.Assign(ASource: TgdccProgress);
begin
  FID := ASource.FID;
  FCaption := ASource.FCaption;
  FName := ASource.FName;
  FDone := ASource.FDone;
  FCanceled := ASource.FCanceled;
  FStepTotal := ASource.FStepTotal;
  FStepDone := ASource.FStepDone;
  FStepName := ASource.FStepName;
  FStepWeight := ASource.FStepWeight;
  FStarted := ASource.FStarted;
  FFinished := ASource.FFinished;
  FCanCancel := ASource.FCanCancel;
  FShow := ASource.FShow;
  FHideOnFinish := ASource.FHideOnFinish;
  FFinishMessage := ASource.FFinishMessage;
end;

procedure TgdccProgress.CheckWorkStarted;
begin
  if not WorkStarted then
    raise Exception.Create('Progress work was not started properly');
end;

procedure TgdccProgress.EndWork(const AMessage: String;
  const AHide: Boolean);
begin
  CheckWorkStarted;
  FDone := True;
  FFinished := Now;
  FStepDone := FStepTotal;
  FStepName := '';
  FStepWeight := 0;
  FHideOnFinish := AHide;
  FFinishMessage := AMessage;
  SendCommand(gdcc_cmd_EndWork);
end;

function TgdccProgress.GetElapsed: TDateTime;
begin
  if FDone then
    Result := FFinished - FStarted
  else
    Result := Now - FStarted;
end;

function TgdccProgress.GetEstimFinish: TDateTime;
begin
  if FDone then
    Result := FFinished
  else begin
    if FStepDone = 0 then
      Result := 0
    else
      Result := Now +
        ((Now - FStarted) / FStepDone) * (FStepTotal - FStepDone);
  end;
end;

function TgdccProgress.GetEstimLeft: TDateTime;
begin
  if FDone then
    Result := 0
  else begin
    if FStepDone = 0 then
      Result := 0
    else
      Result :=
        ((Now - FStarted) / FStepDone) * (FStepTotal - FStepDone);
  end;
end;

function TgdccProgress.GetWorkStarted: Boolean;
begin
  Result := (FStarted > 0) and (FStepTotal > 0);
end;

procedure TgdccProgress.LoadFromStream(S: TStream);
var
  Version: Integer;
begin
  S.ReadBuffer(Version, SizeOf(Version));
  S.ReadBuffer(FID, SizeOf(FID));
  FCaption := ReadStringFromStream(S);
  FName := ReadStringFromStream(S);
  S.ReadBuffer(FDone, SizeOf(FDone));
  S.ReadBuffer(FCanceled, SizeOf(FCanceled));
  S.ReadBuffer(FStepTotal, SizeOf(FStepTotal));
  S.ReadBuffer(FStepDone, SizeOf(FStepDone));
  FStepName := ReadStringFromStream(S);
  S.ReadBuffer(FStepWeight, SizeOf(FStepWeight));
  S.ReadBuffer(FStarted, SizeOf(FStarted));
  S.ReadBuffer(FFinished, SizeOf(FFinished));
  S.ReadBuffer(FCanCancel, SizeOf(FCanCancel));
  S.ReadBuffer(FShow, SizeOf(FShow));
  S.ReadBuffer(FHideOnFinish, SizeOf(FHideOnFinish));
  FFinishMessage := ReadStringFromStream(S);
end;

procedure TgdccProgress.SaveToStream(S: TStream);
var
  Version: Integer;
begin
  Version := 1;
  S.WriteBuffer(Version, SizeOf(Version));
  S.WriteBuffer(FID, SizeOf(FID));
  SaveStringToStream(FCaption, S);
  SaveStringToStream(FName, S);
  S.WriteBuffer(FDone, SizeOf(FDone));
  S.WriteBuffer(FCanceled, SizeOf(FCanceled));
  S.WriteBuffer(FStepTotal, SizeOf(FStepTotal));
  S.WriteBuffer(FStepDone, SizeOf(FStepDone));
  SaveStringToStream(FStepName, S);
  S.WriteBuffer(FStepWeight, SizeOf(FStepWeight));
  S.WriteBuffer(FStarted, SizeOf(FStarted));
  S.WriteBuffer(FFinished, SizeOf(FFinished));
  S.WriteBuffer(FCanCancel, SizeOf(FCanCancel));
  S.WriteBuffer(FShow, SizeOf(FShow));
  S.WriteBuffer(FHideOnFinish, SizeOf(FHideOnFinish));
  SaveStringToStream(FFinishMessage, S);
end;

procedure TgdccProgress.SendCommand(const ACommand: Integer);
var
  S: TStream;
begin
  S := TMemoryStream.Create;
  SaveToStream(S);
  gdccClient.SendCommand(ACommand, S, True);
end;

procedure TgdccProgress.StartStep(const AStepName: String;
  const AStepWeight: Integer);
begin
  CheckWorkStarted;
  if FStepWeight > 0 then
  begin
    Inc(FStepDone, FStepWeight);
    if FStepDone > FStepTotal then
      FStepDone := FStepTotal;
  end;
  FStepName := AStepName;
  FStepWeight := AStepWeight;
  SendCommand(gdcc_cmd_StartStep);
  FCanceled := gdccClient.ProgressCanceled;
end;

procedure TgdccProgress.StartWork(const ACaption, AWorkName: String;
  const AStepTotal: Integer; const AShow: Boolean = True;
  const ACanCancel: Boolean = True);
const
  NextID: Integer = 3333;
begin
  if FID = 0 then
  begin
    FID := NextID;
    Inc(NextID);
  end;
  FCaption := ACaption;
  FName := AWorkName;
  FDone := False;
  FCanceled := False;
  if AStepTotal <= 0 then
    FStepTotal := 1
  else
    FStepTotal := AStepTotal;
  FStepDone := 0;
  FStepName := '';
  FStepWeight := 0;
  FStarted := Now;
  FFinished := 0;
  FCanCancel := ACanCancel;
  FShow := AShow;

  gdccClient.ProgressCanceled := False;
  SendCommand(gdcc_cmd_StartWork);
end;

{ TgdccCommand }

destructor TgdccCommand.Destroy;
begin
  FStream.Free;
  inherited;
end;

class function TgdccCommand.ReadCommand(AConnection: TidTCPConnection;
  AStream: TStream): Integer;
var
  Hdr: TgdccHeader;
  Buff: Pointer;
begin
  Result := gdcc_cmd_Unknown;

  if (AConnection <> nil) and AConnection.Connected then
  begin
    try
      AConnection.ReadBuffer(Hdr, SizeOf(Hdr));
      if (Hdr.Signature = gdcc_Signature) and (Hdr.Version = gdcc_Version) then
      begin
        if Hdr.DataSize > 0 then
        begin
          if AStream <> nil then
          begin
            AConnection.ReadStream(AStream, Hdr.DataSize);
            AStream.Position := 0;
          end else
          begin
            GetMem(Buff, Hdr.DataSize);
            try
              AConnection.ReadBuffer(Buff^, Hdr.DataSize);
            finally
              FreeMem(Buff, Hdr.DataSize);
            end;
          end;
        end;
        Result := Hdr.Command;
      end;
    except
      on EidReadTimeout do
        Result := gdcc_cmd_Unknown;
    end;
  end;
end;

class function TgdccCommand.WriteCommand(AConnection: TidTCPConnection;
  const ACommand: Integer; AStream: TStream): Boolean;
var
  Hdr: TgdccHeader;
begin
  Result := False;

  if (AConnection <> nil) and AConnection.Connected then
  begin
    Hdr.Signature := gdcc_Signature;
    Hdr.Version := gdcc_Version;
    Hdr.Command := ACommand;
    if AStream = nil then
      Hdr.DataSize := 0
    else
      Hdr.DataSize := AStream.Size;
    try
      AConnection.WriteBuffer(Hdr, SizeOf(Hdr));
      if (AStream <> nil) and (AStream.Size > 0) then
        AConnection.WriteStream(AStream);
      Result := True;
    except
      on EidException do ;
    end;
  end;
end;

class function TgdccCommand.ReadCommand(
  AConnection: TidTCPConnection): Integer;
begin
  Result := ReadCommand(AConnection, nil);
end;

class function TgdccCommand.WriteCommand(AConnection: TidTCPConnection;
  const ACommand: Integer): Boolean;
begin
  Result := WriteCommand(AConnection, ACommand, nil);
end;

function TgdccCommand.Read(AConnection: TidTCPConnection): Boolean;
begin
  Result := False;
  FillChar(FHdr, SizeOf(FHdr), 0);
  FreeAndNil(FStream);
  if (AConnection <> nil) and AConnection.Connected then
  begin
    if AConnection.InputBuffer.Size < SizeOf(FHdr) then
      AConnection.ReadFromStack(False, 0, False);
    if AConnection.Connected and (AConnection.InputBuffer.Size >= SizeOf(FHdr)) then
      AConnection.ReadBuffer(FHdr, SizeOf(FHdr));
    if (FHdr.Signature = gdcc_Signature) and (FHdr.Version = gdcc_Version) then
    begin
      if FHdr.DataSize = 0 then
        Result := True
      else if FHdr.DataSize > 0 then
      begin
        FStream := TMemoryStream.Create;
        FStream.Size := FHdr.DataSize;
        AConnection.ReadStream(FStream, FHdr.DataSize);
        FStream.Position := 0;
        Result := AConnection.Connected;
      end;
    end;
  end;
end;

class function TgdccCommand.WriteCommand(AConnection: TidTCPConnection;
  const ACommand: Integer; AData: Cardinal): Boolean;
var
  Hdr: TgdccHeader;
begin
  Result := False;

  if (AConnection <> nil) and AConnection.Connected then
  begin
    Hdr.Signature := gdcc_Signature;
    Hdr.Version := gdcc_Version;
    Hdr.Command := ACommand;
    Hdr.DataSize := SizeOf(AData);
    try
      AConnection.WriteBuffer(Hdr, SizeOf(Hdr));
      AConnection.WriteBuffer(AData, SizeOf(AData));
      Result := True;
    except
      on EidException do ;
    end;
  end;
end;

class function TgdccCommand.ReadCommand(AConnection: TidTCPConnection;
  out AData: Cardinal): Integer;
var
  S: TMemoryStream;
begin
  S := TMEmoryStream.Create;
  try
    Result := ReadCommand(AConnection, S);
    if Result <> gdcc_cmd_Unknown then
    begin
      S.Position := 0;
      S.ReadBuffer(AData, SizeOf(AData));
    end;  
  finally
    S.Free;
  end;
end;

{ TgdccProcesses }

constructor TgdccProcesses.Create;
begin
  inherited Create(True);
  FCS := TCriticalSection.Create;
end;

destructor TgdccProcesses.Destroy;
begin
  FCS.Free;
  inherited;
end;

procedure TgdccProcesses.Lock;
begin
  FCS.Enter;
end;

procedure TgdccProcesses.Unlock;
begin
  FCS.Leave;
end;

function TgdccProcesses.AddAndLock: TgdccProcess;
begin
  Lock;
  Result := TgdccProcess.Create;
  Add(Result);
end;

function TgdccProcesses.FindAndLock(const AnID: Integer;
  out P: TgdccProcess): Boolean;
var
  I: Integer;
begin
  P := nil;
  Lock;
  for I := 0 to Count - 1 do
    if (Items[I] as TgdccProcess).ID = AnID then
    begin
      P := Items[I] as TgdccProcess;
      break;
    end;
  if P = nil then
    Unlock;
  Result := P <> nil;
end;

{ TgdccProcess }

constructor TgdccProcess.Create;
begin
  inherited;
  FID := _ProcessID;
  if _ProcessID = MAXINT then
    _ProcessID := 1
  else
    Inc(_ProcessID);
  QueryPerformanceCounter(FStart);
end;

destructor TgdccProcess.Destroy;
begin
  inherited;
end;

procedure TgdccProcess.DoStop;
begin
  QueryPerformanceCounter(FStop);
  QueryPerformanceFrequency(FFreq);
end;

procedure TgdccProcess.LoadFromStream(ASt: TStream);
begin
  FID := ReadIntegerFromStream(ASt);
  FSrc := ReadStringFromStream(ASt);
  FName := ReadStringFromStream(ASt);
  FStart := ReadInt64FromStream(ASt);
  FStop := ReadInt64FromStream(ASt);
  FFreq := ReadInt64FromStream(ASt);
end;

procedure TgdccProcess.SaveToStream(ASt: TStream);
begin
  SaveIntegerToStream(FID, ASt);
  SaveStringToStream(FSrc, ASt);
  SaveStringToStream(FName, ASt);
  SaveInt64ToStream(FStart, ASt);
  SaveInt64ToStream(FStop, ASt);
  SaveInt64ToStream(FFreq, ASt);
end;

initialization
  _ProcessID := 1;
end.
