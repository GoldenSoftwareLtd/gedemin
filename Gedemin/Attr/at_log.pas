// ShlTanya, 31.01.2019

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
    FFilteredCount, FFilteredSize: Integer;
    FFilteredArray: array of Integer;
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
    function GetSource(Index: Integer): String;
    function FilterRecord(const Index: Integer): Boolean;
    function GetFilteredLogRec(Index: Integer): TatLogRec;
    function GetFilteredLogText(Index: Integer): String;
    procedure GrowArray;
    procedure GrowFilteredArray;

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
    procedure FilterRecords(const AFilterStr, AFilterSrc: String; AFilterTypes: TatLogTypes);

    property Count: Integer read FCount;
    property ErrorCount: Integer read GetErrorCount;

    property WasError: Boolean read FWasError;
    property LogRec[Index: Integer]: TatLogRec read GetLogRec;
    property LogText[Index: Integer]: String read GetLogText;
    property Source[Index: Integer]: String read GetSource;
    property Sources: TStringList read FSources;

    property FilterStr: String read FFilterStr;
    property FilterSrc: String read FFilterSrc;
    property FilterTypes: TatLogTypes read FFilterTypes;
    property FilteredCount: Integer read FFilteredCount;
    property FilteredLogRec[Index: Integer]: TatLogRec read GetFilteredLogRec;
    property FilteredLogText[Index: Integer]: String read GetFilteredLogText;
  end;

implementation

uses
  SysUtils, jclStrings;

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

  GrowArray;
  FArray[FCount].LogType := ALogType;
  FArray[FCount].Logged := Now;
  FArray[FCount].Offset := FStream.Position;

  if ASrc = '' then
    FArray[FCount].Src := -1
  else begin
    FArray[FCount].Src := FSources.IndexOf(ASrc);
    if FArray[FCount].Src = -1 then
    begin
      FSources.Add(ASrc);
      FArray[FCount].Src := FSources.IndexOf(ASrc);
    end;
  end;

  FStream.WriteString(S);
  Inc(FCount);

  if FilterRecord(FCount - 1) then
  begin
    GrowFilteredArray;
    FFilteredArray[FFilteredCount] := FCount - 1;
    Inc(FFilteredCount);
  end;

  if (ALogType = atltError) or (ALogType = atltWarning) then
  begin
    if ALogType = atltError then
      FWasError := True;
    FErrorArray.Add(FCount - 1);
  end;
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
  SetLength(FFilteredArray, 0);
  FFilteredSize := 0;
  FFilteredCount := 0;
  FWasError := False;
  FErrorArray.Clear;
  FSources.Clear;
end;

constructor TatLog.Create;
begin
  FErrorArray := TgdKeyArray.Create;
  FSources := TStringList.Create;
  FFilterTypes := [atltInfo, atltWarning, atltError];
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
  Assert((Index >= 0) and (Index < FCount));

  Result :=
    (FArray[Index].LogType in FFilterTypes)
    and
    (
      (FFilterSrc = '')
      or
      (FArray[Index].Src = FSources.IndexOf(FFilterSrc))
    )
    and
    (
      (FFilterStr = '')
      or
      (StrIPos(FFilterStr, LogText[Index]) > 0)
    );
end;

procedure TatLog.FilterRecords(const AFilterStr, AFilterSrc: String;
  AFilterTypes: TatLogTypes);
var
  I: Integer;
begin
  FFilterStr := AFilterStr;
  FFilterSrc := AFilterSrc;
  FFilterTypes := AFilterTypes;

  FFilteredCount := 0;
  for I := 0 to FCount - 1 do
  begin
    if FilterRecord(I) then
    begin
      GrowFilteredArray;
      FFilteredArray[FFilteredCount] := I;
      Inc(FFilteredCount);
    end;
  end;
end;

function TatLog.GetErrorCount: Integer;
begin
  Result := FErrorArray.Count;
end;

function TatLog.GetFilteredLogRec(Index: Integer): TatLogRec;
begin
  Assert((Index >= 0) and (Index < FFilteredCount));
  Result := GetLogRec(FFilteredArray[Index]);
end;

function TatLog.GetFilteredLogText(Index: Integer): String;
begin
  Assert((Index >= 0) and (Index < FFilteredCount));
  Result := GetLogText(FFilteredArray[Index]);
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

function TatLog.GetSource(Index: Integer): String;
begin
  Result := FSources[Index];
end;

procedure TatLog.GrowArray;
begin
  if FCount >= FSize then
  begin
    if FSize = 0 then
      FSize := 64
    else
      FSize := FSize * 2;
    SetLength(FArray, FSize);
  end;
end;

procedure TatLog.GrowFilteredArray;
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

procedure TatLog.SaveToFile(const AFileName: String);

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
  S, L: String;
  I: Integer;
begin
  if AnsiSameText(ExtractFileExt(AFileName), '.CSV') then
  begin
    AssignFile(F, AFileName);
    Rewrite(F);
    try
      for I := 0 to FCount - 1 do
      begin
        with FArray[I] do
        begin
          S := FormatDateTime('hh:nn:ss', Logged) + ',';

          case LogType of
            atltError: S := S + 'Ошибка,';
            atltWarning: S := S + 'Предупреждение,';
          else
            S := S + ',';
          end;

          Writeln(F, S + QuoteStr(LogText[I]));
        end;
      end;
    finally
      CloseFile(F);
    end;
  end else
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

        L := Copy(LogText[I], 1, 256);
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
