// ShlTanya, 24.02.2019

unit gdSQLMonitor;

interface

uses
  Classes, IBSQLMonitor, gd_KeyAssoc;

type
  TStatementRec = record
    StatementCRC: Integer;
    ParamsCRC: Integer;
    HasParams: Boolean;
    StartTime: TDateTime;
    Duration: Integer;
  end;

  TgdSQLMonitor = class(TIBCustomSQLMonitor)
  private
    FStatements, FParams: TgdKeyStringAssoc;
    FList: array of TStatementRec;
    FCurrent, FSize: Integer;

    procedure SaveEvent(EventText: String; EventTime : TDateTime);

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure Clear;
    procedure Unload(Strings: TStrings);
    procedure Flush;
    function GetSize: Integer;
  end;

var
  SQLMonitor: TgdSQLMonitor;  

implementation

uses
  SysUtils, zlib, jclSelected, IBDatabase, IBSQL, gdcBaseInterface, gd_security,
  at_classes;

{ TgdSQLMonitor }

procedure TgdSQLMonitor.Clear;
begin
  FStatements.Clear;
  FParams.Clear;
  FCurrent := 0;
end;

constructor TgdSQLMonitor.Create(AnOwner: TComponent);
begin
  inherited;
  FStatements := TgdKeyStringAssoc.Create;
  FParams := TgdKeyStringAssoc.Create;
  FSize := 0;
  FCurrent := 0;
  OnSQL := SaveEvent;
end;

destructor TgdSQLMonitor.Destroy;
begin
  FStatements.Free;
  FParams.Free;
  FList := nil;
  inherited;
end;

procedure TgdSQLMonitor.Flush;
var
  q, q2: TIBSQL;
  Tr: TIBTransaction;
  I: Integer;
  OldEnabled: Boolean;
begin
  if (gdcBaseManager.Database = nil) or (not gdcBaseManager.Database.Connected) then
    exit;

  if (atDatabase = nil)
    or (atDatabase.Relations.ByRelationName('GD_SQL_STATEMENT') = nil)
    or (atDatabase.Relations.ByRelationName('GD_SQL_LOG') = nil) then
  begin
    exit;
  end;

  OldEnabled := Enabled;
  try
    Enabled := False;

    try
      Tr := TIBTransaction.Create(nil);
      q := TIBSQL.Create(nil);
      q2 := TIBSQL.Create(nil);
      try
        Tr.DefaultDatabase := gdcBaseManager.Database;
        q.Transaction := Tr;
        q2.Transaction := Tr;
        Tr.StartTransaction;

        q.SQL.Text := 'SELECT id FROM gd_sql_statement WHERE crc=:CRC';
        q.Prepare;
        q2.SQL.Text := 'INSERT INTO gd_sql_statement (crc, kind, data) VALUES (:CRC, :KIND, :DATA) ';
        q2.Prepare;
        for I := 0 to FCurrent - 1 do
        begin
          q.ParamByName('crc').AsInteger := FList[I].StatementCRC;
          q.ExecQuery;
          if q.EOF then
          begin
            q2.ParamByName('crc').AsInteger := FList[I].StatementCRC;
            q2.ParamByName('kind').AsInteger := 0;
            q2.ParamByName('data').AsString :=
              ZDecompressStr(FStatements.ValuesByKey[FList[I].StatementCRC]);
            q2.ExecQuery;
          end;
          q.Close;

          if FList[I].HasParams then
          begin
            q.ParamByName('crc').AsInteger := FList[I].ParamsCRC;
            q.ExecQuery;
            if q.EOF then
            begin
              q2.ParamByName('crc').AsInteger := FList[I].ParamsCRC;
              q2.ParamByName('kind').AsInteger := 1;
              q2.ParamByName('data').AsString :=
                ZDecompressStr(FParams.ValuesByKey[FList[I].ParamsCRC]);
              q2.ExecQuery;
            end;
            q.Close;
          end;
        end;

        q2.SQL.Text := 'INSERT INTO gd_sql_log (statementcrc, paramscrc, contactkey, starttime, duration) ' +
          'VALUES (:SCRC, :PCRC, :CK, :ST, :D) ';
        q2.Prepare;
        for I := 0 to FCurrent - 1 do
        with FList[I] do
        begin
          q2.ParamByName('scrc').AsInteger := StatementCRC;
          if HasParams then
            q2.ParamByName('pcrc').AsInteger := ParamsCRC
          else
            q2.ParamByName('pcrc').IsNull := True;
          SetTID(q2.ParamByName('ck'), IBLogin.ContactKey);
          q2.ParamByName('st').AsDateTime := StartTime;
          q2.ParamByName('d').AsInteger := Duration;
          q2.ExecQuery;
        end;

        Tr.Commit;
      finally
        q.Free;
        q2.Free;
        Tr.Free;
      end;
    except
    end;

    Clear;
  finally
    Enabled := OldEnabled;
  end;
end;

function TgdSQLMonitor.GetSize: Integer;
var
  I: Integer;
begin
  Result := FSize * SizeOf(TStatementRec);
  for I := 0 to FStatements.Count - 1 do
    Result := Result + Length(FStatements.ValuesByIndex[I])
      + SizeOf(String) + SizeOf(Integer);
  for I := 0 to FParams.Count - 1 do
    Result := Result + Length(FParams.ValuesByIndex[I])
      + SizeOf(String) + SizeOf(Integer);
end;

procedure TgdSQLMonitor.SaveEvent(EventText: String; EventTime: TDateTime);
var
  I, SCRC, PCRC: Integer;
  ParamText, DurText: String;
  F: Boolean;
  D: Cardinal;
begin
  PCRC := 0;
  D := 0;

  I := Pos('[Duration: ', EventText);
  if I > 0 then
  begin
    DurText := Copy(EventText, I + 11, 12);
    DurText := Copy(DurText, 1, Pos(']', DurText) - 1);
    D := StrToIntDef(DurText, 0);
    SetLength(EventText, I - 1);
  end;

  I := Pos('[Params]', EventText);
  F := I > 0;
  if F then
  begin
    ParamText := Copy(EventText, I + 8 + 2, 64000);
    if ParamText = '' then
      F := False
    else begin
      ParamText := ZCompressStr(ParamText, zcDefault);
      PCRC := Integer(Crc32_P(@ParamText[1], Length(ParamText), 0));
      if FParams.IndexOf(PCRC) = -1 then
        FParams.ValuesByIndex[FParams.Add(PCRC)] := ParamText;
    end;
    SetLength(EventText, I - 1);
  end;

  if Length(EventText) > 0 then
  begin
    EventText := ZCompressStr(EventText, zcDefault);
    SCRC := Integer(Crc32_P(@EventText[1], Length(EventText), 0));
    if FStatements.IndexOf(SCRC) = -1 then
      FStatements.ValuesByIndex[FStatements.Add(SCRC)] := EventText;

    if FCurrent >= FSize then
    begin
      if FSize > 10000 then
        Flush
      else
      begin
        if FSize = 0 then
          FSize := 1024
        else
          FSize := FSize * 2;
        SetLength(FList, FSize);
      end;
    end;

    with FList[FCurrent] do
    begin
      StatementCRC := SCRC;
      if F then
        ParamsCRC := PCRC;
      HasParams := F;
      StartTime := EventTime;
      Duration := D;
    end;

    Inc(FCurrent);
  end;
end;

procedure TgdSQLMonitor.Unload(Strings: TStrings);
var
  I, J: Integer;
  SL: TStringList;
  S: String;
begin
  Strings.Clear;

  SL := TStringList.Create;
  try
    for I := 0 to FCurrent - 1 do
    with FList[I] do
    begin
      Strings.Add('');
      S := FormatDateTime('hh:nn:ss.zzz', StartTime);
      if Duration > 0 then
        S := S + ' [' + IntToStr(Duration) + ']';
      Strings.Add(S);
      SL.Text := ZDecompressStr(FStatements.ValuesByKey[StatementCRC]);
      for J := 2 to SL.Count - 1 do
        Strings.Add(SL[J]);
      if HasParams then
      begin
        S := ZDecompressStr(FParams.ValuesByKey[ParamsCRC]);
        if S > ' ' then
        begin
          SL.Text := S;
          for J := 0 to SL.Count - 1 do
            Strings.Add(SL[J]);
        end;
      end;  
    end;
  finally
    SL.Free;
  end;
end;

initialization
  SQLMonitor := nil;

finalization
  FreeAndNil(SQLMonitor);
end.
