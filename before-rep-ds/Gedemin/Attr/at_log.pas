
unit at_Log;

interface

uses
  gsMMFStream, gd_KeyAssoc;

type
  TatLogType = (atltInfo, atltWarning, atltError);

  TatLogRec = record
    LogType: TatLogType;
    Logged: TDateTime;
    Offset: Int64;
  end;

  TatLog = class(TObject)
  private
    FCount, FSize: Integer;
    FArray: array of TatLogRec;
    FStream: TgsStream64;
    FWasError: Boolean;
    FReposition: Boolean;
    FErrorArray: TgdKeyArray;

    function GetLogRec(Index: Integer): TatLogRec;
    function GetLogText(Index: Integer): String;
    function GetErrorCount: Integer;
    function GetLogErrorRec(Index: Integer): TatLogRec;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AddRecord(const S: String; const ALogType: TatLogType = atltInfo);
    procedure Clear;
    procedure SaveToFile(const AFileName: String);

    property Count: Integer read FCount;
    property ErrorCount: Integer read GetErrorCount;

    property WasError: Boolean read FWasError;
    property LogRec[Index: Integer]: TatLogRec read GetLogRec;
    property LogErrorRec[Index: Integer]: TatLogRec read GetLogErrorRec;
    property LogText[Index: Integer]: String read GetLogText;
  end;

implementation

uses
  Classes, SysUtils;

{ TatLog }

procedure TatLog.AddRecord(const S: String; const ALogType: TatLogType);
begin
  if FStream = nil then
    FStream := TgsStream64.Create;

  if FReposition then
  begin
    FStream.Seek(0, soFromEnd);
    FReposition := False;
  end;

  if FCount >= FSize then
  begin
    if FSize = 0 then
      FSize := 64
    else
      FSize := FSize * 2;
    SetLength(FArray, FSize);
  end;

  FArray[FCount].LogType := ALogType;
  FArray[FCount].Logged := Now;
  FArray[FCount].Offset := FStream.Position;

  FStream.WriteString(S);

  if (ALogType = atltError) or (ALogType = atltWarning) then
  begin
    if ALogType = atltError then
      FWasError := True;
    FErrorArray.Add(FCount);
  end;

  Inc(FCount);
end;

procedure TatLog.Clear;
begin
  FreeAndNil(FStream);
  SetLength(FArray, 0);
  FSize := 0;
  FCount := 0;
  FWasError := False;
  FErrorArray.Clear;
end;

constructor TatLog.Create;
begin
  FErrorArray := TgdKeyArray.Create;
end;

destructor TatLog.Destroy;
begin
  FreeAndNil(FErrorArray);
  FStream.Free;
  SetLength(FArray, 0);
  inherited;
end;

function TatLog.GetErrorCount: Integer;
begin
  Result := FErrorArray.Count;
end;

function TatLog.GetLogErrorRec(Index: Integer): TatLogRec;
begin
  Assert((Index >= 0) and (Index < ErrorCount));
  Result := FArray[FErrorArray.Keys[Index]];
end;

function TatLog.GetLogRec(Index: Integer): TatLogRec;
begin
  Assert((Index >= 0) and (Index < FCount));
  Result := FArray[Index];
end;

function TatLog.GetLogText(Index: Integer): String;
begin
  FReposition := True;
  FStream.Seek(LogRec[Index].Offset, soFromBeginning);
  Result := FStream.ReadString;
end;

procedure TatLog.SaveToFile(const AFileName: String);
var
  F: TextFile;
  S, L: String;
  I: Integer;
begin
  AssignFile(F, AFileName);
  Rewrite(F);
  try
    for I := 0 to FCount - 1 do
    begin
      with FArray[I] do
      begin
        case LogType of
          atltError: S := '[Ошибка] ';
          atltWarning: S :='[Предупреждение] ';
        else
          S := '';
        end;
        S := S + FormatDateTime('hh:nn:ss', Logged);

        L := LogText[I];
        if Pos(#13, L) > 0 then
          S := S + #13#10 + L
        else
          S := S + '  ' + L;

        Writeln(F, S);
      end;
    end;
  finally
    CloseFile(F);
  end;
end;

end.