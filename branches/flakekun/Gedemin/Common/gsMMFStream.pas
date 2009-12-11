
unit gsMMFStream;

interface

uses
  Classes, Windows, SysUtils, ContNrs;

type
  TgsStream64 = class(TObject)
  private
    FHandle: THandle;
    FFileMapping: THandle;
    FPointer: PAnsiChar;
    FOwnFile: Boolean;

    FStreamStart, FStreamSize: Int64;
    FProtection, FAccessMode: DWORD;

    FViewStart: Int64;
    FViewSize, FOffset: Cardinal;

    function GetPosition: Int64;
    procedure SetPosition(const Value: Int64);

    procedure InitViewSize;
    procedure OpenFile;
    procedure MapView(ANewGlobalPos: Int64);

  public
    constructor Create; overload;
    constructor Create(AHandle: THandle; AProtection: DWORD;
      AStreamStart, AStreamSize: Int64); overload;
    destructor Destroy; override;

    function Read(var Buffer; Count: Longint): Longint;
    function Write(const Buffer; Count: Longint): Longint;
    function Seek(Offset: Int64; Origin: Word): Int64;
    procedure ReadBuffer(var Buffer; Count: Longint);
    procedure WriteBuffer(const Buffer; Count: Longint);
    procedure WriteString(const S: String);
    function ReadString(const AStrLen: Integer = -1): String;
    function CopyFrom(Source: TStream; Count: LongInt): LongInt;

    property Position: Int64 read GetPosition write SetPosition;
    property Size: Int64 read FStreamSize;
    property ViewSize: Cardinal read FViewSize;
  end;

  EgsMMFStream = class(Exception);

implementation

uses
  Consts;

{ TgsStream64 }

constructor TgsStream64.Create;
begin
  inherited Create;
  InitViewSize;
  FProtection := PAGE_READWRITE;
  FAccessMode := FILE_MAP_WRITE;
  FOwnFile := True;
end;

constructor TgsStream64.Create(AHandle: THandle; AProtection: DWORD;
  AStreamStart, AStreamSize: Int64);
begin
  inherited Create;
  InitViewSize;
  FHandle := AHandle;
  FProtection := AProtection;
  if (FProtection and PAGE_READWRITE) <> 0 then
    FAccessMode := FILE_MAP_WRITE
  else
    FAccessMode := FILE_MAP_READ;
  FStreamStart := AStreamStart;
  FStreamSize := AStreamSize;
  MapView(FStreamStart);
end;

destructor TgsStream64.Destroy;
begin
  UnMapViewOfFile(FPointer);
  CloseHandle(FFileMapping);
  if FOwnFile then
    CloseHandle(FHandle);
  inherited;
end;

function TgsStream64.CopyFrom(Source: TStream; Count: Integer): LongInt;
var
  Buff: array[0..4096 - 1] of AnsiChar;
  L: LongInt;
begin
  if Count = 0 then
    Source.Position := 0;
  Result := 0;
  repeat
    L := Source.Read(Buff, SizeOf(Buff));
    WriteBuffer(Buff, L);
    Result := Result + L;
  until L = 0;
end;

function TgsStream64.GetPosition: Int64;
begin
  Result := FViewStart + FOffset - FStreamStart;
end;

procedure TgsStream64.InitViewSize;
var
  SI: TSystemInfo;
begin
  FViewSize := 65536;
  GetSystemInfo(SI);
  if FViewSize mod SI.dwAllocationGranularity <> 0  then
    FViewSize := SI.dwAllocationGranularity;
end;

procedure TgsStream64.MapView(ANewGlobalPos: Int64);
var
  L: ULARGE_INTEGER;
  ANewViewStart: Int64;
  ANewOffset: Cardinal;
begin
  ANewViewStart := (ANewGlobalPos div FViewSize) * FViewSize;
  ANewOffset := ANewGlobalPos - ANewViewStart;

  if (ANewViewStart <> FViewStart) or (FPointer = nil) then
  begin
    if FPointer <> nil then
    begin
      if not UnMapViewOfFile(FPointer) then
        raise EgsMMFStream.Create('Can not unmap view of file');
    end;

    if (ANewViewStart > FViewStart) or (FFileMapping = 0) then
    begin
      if FFileMapping <> 0 then
      begin
        if not CloseHandle(FFileMapping) then
          raise EgsMMFStream.Create('Can not close file mapping');
      end;

      if FOwnFile then
        L.QuadPart := ANewViewStart + FViewSize
      else
        L.QuadPart := FStreamStart + FStreamSize;
      FFileMapping := CreateFileMapping(FHandle,
        nil,
        FProtection,
        L.HighPart,
        L.LowPart,
        nil);
      if FFileMapping = 0 then
        raise EgsMMFStream.Create('Can not create a file mapping');
    end;
    FViewStart := ANewViewStart;

    L.QuadPart := FViewStart;
    FPointer := MapViewOfFile(FFileMapping,
      FAccessMode,
      L.HighPart,
      L.LowPart,
      FViewSize);
    if FPointer = nil then
      raise EgsMMFStream.CreateFmt('Can not map view of file, error #%d', [GetLastError]);
  end;

  FOffset := ANewOffset;
end;

procedure TgsStream64.OpenFile;
var
  TempPath: array[0..1023] of Char;
  TempFileName: array[0..1023] of Char;
begin
  if (GetTempPath(SizeOf(TempPath), TempPath) = 0) or
    (GetTempFileName(TempPath, 'gd', 0, TempFileName) = 0) then
      raise EgsMMFStream.Create('Can not get a name for temp file');

  FHandle := CreateFile(TempFileName,
    GENERIC_READ or GENERIC_WRITE,
    FILE_SHARE_READ,
    nil,
    CREATE_ALWAYS,
    FILE_ATTRIBUTE_TEMPORARY or FILE_FLAG_DELETE_ON_CLOSE,
    0);
  if FHandle = INVALID_HANDLE_VALUE then
    raise EgsMMFStream.Create('Can not create a file for gsMMFStream');

  MapView(0);
end;

function TgsStream64.Read(var Buffer; Count: Integer): Longint;
var
  ToCopy: Cardinal;
  Trg: Integer;
begin
  Trg := 0;
  while Count > 0 do
  begin
    ToCopy := Count;
    if ToCopy > FViewSize - FOffset then
      ToCopy := FViewSize - FOffset;
    if ToCopy > FStreamStart + FStreamSize - FViewStart - FOffset then
    begin
      ToCopy := FStreamStart + FStreamSize - FViewStart - FOffset;
      if ToCopy = 0 then
        break;
    end;
    Move(FPointer[FOffset], Pointer(Longint(@Buffer) + Trg)^, ToCopy);
    Dec(Count, ToCopy);
    Inc(Trg, ToCopy);
    if FOffset + ToCopy = FViewSize then
      MapView(FViewStart + FViewSize)
    else
      Inc(FOffset, ToCopy);
  end;
  Result := Trg;
end;

procedure TgsStream64.ReadBuffer(var Buffer; Count: Integer);
begin
  if (Count <> 0) and (Read(Buffer, Count) <> Count) then
    raise EReadError.CreateRes(@SReadError);
end;

function TgsStream64.ReadString(const AStrLen: Integer = -1): String;
var
  L: Integer;
begin
  if AStrLen = -1 then
    ReadBuffer(L, SizeOf(L))
  else
    L := AStrLen;
  if L < 0 then
    raise EgsMMFStream.Create('Invalid stream format');
  SetLength(Result, L);
  if L > 0 then
    ReadBuffer(Result[1], L * SizeOf(Char));
end;

function TgsStream64.Seek(Offset: Int64; Origin: Word): Int64;
var
  NewGlobalPos: Int64;
begin
  case Origin of
    soFromBeginning: NewGlobalPos := FStreamStart + Offset;
    soFromCurrent: NewGlobalPos := FViewStart + FOffset + Offset;
  else
    {soFromEnd:} NewGlobalPos := FStreamSize + Offset;
  end;

  if (NewGlobalPos < FStreamStart) or (NewGlobalPos > FStreamStart + FStreamSize) then
    raise EgsMMFStream.Create('Invalid offset');

  MapView(NewGlobalPos);
  Result := NewGlobalPos - FStreamStart;
end;

procedure TgsStream64.SetPosition(const Value: Int64);
begin
  if (Value < 0) or (Value > FStreamSize - FStreamStart) then
    raise EgsMMFStream.Create('Invalid position');
  MapView(Value + FStreamStart);
end;

function TgsStream64.Write(const Buffer; Count: Integer): Longint;
var
  Src, ToCopy: Integer;
begin
  if FHandle = 0 then
    OpenFile;

  Src := 0;
  while Count > 0 do
  begin
    ToCopy := FViewSize - FOffset;
    if ToCopy > Count then
      ToCopy := Count;
    if not FOwnFile then
    begin
      if (FViewStart + FOffset + ToCopy) >= (FStreamStart + FStreamSize) then
        ToCopy := (FStreamStart + FStreamSize) - (FViewStart + FOffset + ToCopy);
      if ToCopy <= 0 then
        break;
    end;
    Move((PAnsiChar(@Buffer) + Src)^, (FPointer + FOffset)^, ToCopy);
    Inc(Src, ToCopy);
    Inc(FOffset, ToCopy);
    if (FViewStart + FOffset) > (FStreamStart + FStreamSize) then
      FStreamSize := FViewStart + FOffset - FStreamStart;
    if FOffset >= FViewSize then
    begin
      MapView(FViewStart + FViewSize);
    end;
    Dec(Count, ToCopy);
  end;
  Result := Src;
end;

procedure TgsStream64.WriteBuffer(const Buffer; Count: Integer);
begin
  if (Count <> 0) and (Write(Buffer, Count) <> Count) then
    raise EWriteError.CreateRes(@SWriteError);
end;

procedure TgsStream64.WriteString(const S: String);
var
  L: Integer;
begin
  L := Length(S);
  WriteBuffer(L, SizeOf(L));
  if L > 0 then
    WriteBuffer(S[1], L * SizeOf(Char));
end;

end.
