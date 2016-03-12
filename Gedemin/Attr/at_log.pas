
unit at_Log;

interface

uses
  Classes, gsMMFStream, gd_KeyAssoc;

type
  TatLogType = (atltInfo, atltWarning, atltError);
  TatLogTypes = set of TatLogType;

  TatLogRec = record
    LogType: TatLogType;
    Src: Integer;
    Logged: TDateTime;
    Offset: Int64;
  end;

  TatLog = class(TObject)
  private
    FCount, FSize: Integer;
    FArray: array of TatLogRec;
    FFilterCount, FFilterSize: Integer;
    FFilterArray: array of Integer;
    FStream: TgsStream64;
    FWasError: Boolean;
    FReposition: Boolean;
    FErrorArray: TgdKeyArray;
    FSources: TStringList;
    FFilterStr: String;
    FFilterSrc: String;
    FFilterTypes: TatLogTypes;

    function GetLogRec(Index: Integer): TatLogRec;
    function GetLogText(Index: Integer): String;
    function GetErrorCount: Integer;
    function GetSources(Index: Integer): String;
    function FilterRecord(const Index: Integer): Boolean;

  public
    constructor Create;
    destructor Destroy; override;

    procedure AddRecord(const S: String; const ALogType: TatLogType = atltInfo); overload;
    procedure AddRecord(const ASrc: String; const S: String; const ALogType: TatLogType = atltInfo); overload;
    procedure Clear;
    function GetRealErrorRecIndex(AListIndex: Integer): Integer;
    procedure SaveToFile(const AFileName: String);
    procedure SaveToStringList(const AnIncludeSuccess: Boolean; const AnIncludeWarning: Boolean;
      out AWarningCount: Integer; out AnErrorCount: Integer; SL: TStringList);

    property Count: Integer read FCount;
    property ErrorCount: Integer read GetErrorCount;

    property WasError: Boolean read FWasError;
    property LogRec[Index: Integer]: TatLogRec read GetLogRec;
    property LogText[Index: Integer]: String read GetLogText;
    property Sources[Index: Integer]: String read GetSources;
    property FilterStr: String read FFilterStr;
    property FilterSrc: String read FFilterSrc;
    property FilterTypes: TatLogTypes read FFilterTypes;
  end;

implementation

uses
  SysUtils;

{ TatLog }

procedure TatLog.AddRecord(const ASrc: String; const S: String; const ALogType: TatLogType);
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

  FArray[FCount].Src := FSources.IndexOf(ASrc);
  if FArray[FCount].Src = -1 then
  begin
    FSources.Add(ASrc);
    FArray[FCount].Src := FSources.IndexOf(ASrc);
  end;

  FStream.WriteString(S);

  if FilterRecord(FCount) then
  begin
    if FFilterCount >= FFilterSize then
    begin
      if FFilterSize = 0 then
        FFilterSize := 64
      else
        FFilterSize := FFilterSize * 2;
      SetLength(FFilterArray, FFilterSize);
    end;
    FFilterArray[FFilterCount] := FCount;
    Inc(FFilterCount);
  end;

  if (ALogType = atltError) or (ALogType = atltWarning) then
  begin
    if ALogType = atltError then
      FWasError := True;
    FErrorArray.Add(FCount);
  end;

  Inc(FCount);
end;

procedure TatLog.AddRecord(const S: String;
  const ALogType: TatLogType);
begin
  AddRecord('', S, ALogType);
end;

procedure TatLog.Clear;
begin
  FreeAndNil(FStream);
  SetLength(FArray, 0);
  FSize := 0;
  FCount := 0;
  SetLength(FFilterArray, 0);
  FFilterSize := 0;
  FFilterCount := 0;
  FWasError := False;
  FErrorArray.Clear;
end;

constructor TatLog.Create;
begin
  FErrorArray := TgdKeyArray.Create;
  FSources := TStringList.Create;
end;

destructor TatLog.Destroy;
begin
  FreeAndNil(FErrorArray);
  FStream.Free;
  SetLength(FArray, 0);
  FSources.Free;
  inherited;
end;

function TatLog.FilterRecord(const Index: Integer): Boolean;
begin
  Result := True;
end;

function TatLog.GetErrorCount: Integer;
begin
  Result := FErrorArray.Count;
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

function TatLog.GetRealErrorRecIndex(AListIndex: Integer): Integer;
begin
  if (AListIndex >= 0) and (AListIndex < ErrorCount) then
    Result := FErrorArray.Keys[AListIndex]
  else
    Result := AListIndex;
end;

function TatLog.GetSources(Index: Integer): String;
begin
  Result := FSources[Index];
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

procedure TatLog.SaveToStringList(const AnIncludeSuccess,
  AnIncludeWarning: Boolean; out AWarningCount, AnErrorCount: Integer;
  SL: TStringList);
var
  I: Integer;
  S, L: String;
begin
  Assert(SL is TStringList);
  AWarningCount := 0;
  AnErrorCount := 0;
  for I := 0 to FCount - 1 do
  begin
    with FArray[I] do
    begin
      if (AnIncludeSuccess and (LogType = atltInfo))
        or (AnIncludeWarning and (LogType = atltWarning))
        or (LogType = atltError) then
      begin
        case LogType of
          atltError:
          begin
            S := '[Ошибка] ';
            Inc(AnErrorCount);
          end;

          atltWarning:
          begin
            S :='[Предупреждение] ';
            Inc(AWarningCount);
          end;
        else
          S := '';
        end;
        S := S + FormatDateTime('hh:nn:ss', Logged);

        L := LogText[I];
        if Pos(#13, L) > 0 then
          S := S + #13#10 + L
        else
          S := S + '  ' + L;

        SL.Add(S);
      end;
    end;
  end;
end;

end.
