unit FDBExtractData_unit;

interface

uses
  IB, IBDatabase, IBSQL, Classes;

type
  TgsDBExtractData = class(TObject)
  private
    FUserName: String;
    FPassword: String;
    FDatabaseName: String;
    FDatabase: TIBDatabase;
    FReadTransaction: TIBTransaction;

    function GetConnected: Boolean;
    function GetPKField(const ARelName: String): String;
    function GetPassFieldName(const AName: String): String;
    procedure SetTableName(ATL: TStringList);
    procedure SetFKFields(AFL: TStringList; const AName: String);
    procedure WriteString(AStream: TFileStream; const AFieldName: String; const AValue: String);

  public
    constructor Create;
    destructor Destroy; override;

    procedure Connect;
    procedure Disconnect;
    procedure ExtractData(Const AFileName: String);

    property DatabaseName: String read FDatabaseName write FDatabaseName;
    property UserName: String read FUserName write FUserName;
    property Password: String read FPassword write FPassword;
    property Connected: Boolean read GetConnected;
  end;

implementation

uses
  SysUtils, JclStrings;

constructor TgsDBExtractData.Create;
begin
  inherited;
  FDatabase := TIBDatabase.Create(nil);
  FReadTransaction := TIBTransaction.Create(nil);
  FReadTransaction.DefaultDatabase := FDatabase;
  FReadTransaction.Params.Text := 'read_committed'#13#10'rec_version'#13#10'nowait'#13#10'read'#13#10;
  FReadTransaction.AutoStopAction := saNone; 
  FDatabase.DefaultTransaction := FReadTransaction;
end;

destructor TgsDBExtractData.Destroy;
begin
  if Assigned(FReadTransaction) and FReadTransaction.InTransaction then
    FReadTransaction.Commit;
  FReadTransaction.Free;
  if Connected then
    Disconnect;
  FDatabase.Free; 
  inherited;
end;

procedure TgsDBExtractData.Connect;
begin
  FDatabase.DatabaseName := FDatabaseName;
  FDatabase.LoginPrompt := False;
  FDatabase.Params.Clear;
  FDatabase.Params.Add('user_name=' + FUserName);
  FDatabase.Params.Add('password=' + FPassword);
  FDatabase.Params.Add('lc_ctype=win1251');
  FDatabase.SQLDialect := 3;
  FDatabase.Open;
  FReadTransaction.StartTransaction;
end;

procedure TgsDBExtractData.Disconnect;
begin
  if Connected then
    FDatabase.Close;
end;

function TgsDBExtractData.GetConnected: Boolean;
begin
  if Assigned(FDatabase) then
    Result := FDatabase.Connected
  else
    Result := False;
end;

procedure TgsDBExtractData.SetTableName(ATL: TStringList);
const
  PassTable = ';at_setting;at_settingpos;at_namespace;at_object;at_namespacelink;gd_ruid;';
var
  q: TIBSQL;
begin
  q := TIBSQL.Create(nil);
  try
    q.Transaction := FReadTransaction;
    q.SQL.Text := 'SELECT Trim(rdb$relation_name) as rn FROM rdb$relations ' +
      'WHERE rdb$system_flag = 0 and rdb$relation_type = 0 ' +
      'ORDER BY rdb$relation_name asc ';
    q.ExecQuery;

    while not q.Eof do
    begin
      if StrIPos(';' + q.Fields[0].AsString + ';', PassTable) = 0 then
        ATL.Add(q.Fields[0].AsString);
      q.Next;
    end;
  finally
    q.Free;
  end;
end;

function TgsDBExtractData.GetPKField(const ARelName: String): String;
var
  q: TIBSQL;
begin
  Result := '';
  q := TIBSQL.Create(nil);
  try
    q.Transaction := FReadTransaction;
    q.SQL.Text :=
      'SELECT  first 1 rf.rdb$field_name ' +
      'FROM  RDB$RELATION_FIELDS rf ' +
      'LEFT JOIN RDB$FIELDS f ON f.rdb$field_name = rf.rdb$field_source  AND f.rdb$field_type = 8 ' +
      'LEFT JOIN RDB$INDEX_SEGMENTS ss ' +
      '  ON rf.rdb$field_name = ss.rdb$field_name ' +
      'LEFT JOIN RDB$RELATION_CONSTRAINTS rc2 ' +
      '  ON rc2.rdb$index_name = ss.rdb$index_name and rc2.rdb$relation_name = rf.rdb$relation_name ' +
      'WHERE rc2.rdb$constraint_type = ''PRIMARY KEY'' ' +
      '  and  rf.rdb$relation_name = :rn ';
    q.ParamByName('rn').AsString := ARelName;
    q.ExecQuery;
    if not q.Eof then
      Result := Trim(q.Fields[0].AsString);
  finally
    q.Free;
  end;
end;

function TgsDBExtractData.GetPassFieldName(const AName: String): String;
var
  q: TIBSQL;
begin
  Result := '';
  q := TIBSQL.Create(nil);
  try
    q.Transaction := FReadTransaction;
    q.SQL.Text :=
      'SELECT  list(Trim(rf.rdb$field_name)) as listfield ' +
      'FROM  RDB$RELATION_FIELDS rf ' +
      'LEFT JOIN RDB$FIELDS f ON f.rdb$field_name = rf.rdb$field_source  AND f.rdb$field_type = 8 ' +
      'LEFT JOIN RDB$INDEX_SEGMENTS ss ' +
      '  ON rf.rdb$field_name = ss.rdb$field_name ' +
      'LEFT JOIN RDB$RELATION_CONSTRAINTS rc2 ' +
      '  ON rc2.rdb$index_name = ss.rdb$index_name and rc2.rdb$relation_name = rf.rdb$relation_name ' +
      'WHERE (rc2.rdb$constraint_type = ''PRIMARY KEY'' or rc2.rdb$constraint_type = ''FOREIGN KEY'') ' +
      '  and  rf.rdb$relation_name = :rn ';
    q.ParamByName('rn').AsString := AName;
    q.ExecQuery;
    if not q.Eof then
      Result := ',' + q.FieldByName('listfield').AsString + ',';
  finally
    q.Free;
  end;
end;

procedure TgsDBExtractData.SetFKFields(AFL: TStringList; const AName: String);
const
  PassFieldName =
    ';CREATORKEY;EDITORKEY;ACHAG;AVIEW;AFULL;LB;RB;RESERVED' +
    ';ENTEREDPARAMS;BREAKPOINTS;EDITORSTATE;TESTRESULT;' +
    'RDB$PROCEDURE_BLR;RDB$TRIGGER_BLR;RDB$VIEW_BLR;LASTEXTIME;EDITIONDATE;';
var
  q: TIBSQL;
begin
  q := TIBSQL.Create(nil);
  try
    q.Transaction := FReadTransaction;
    q.SQL.Text := 'SELECT rdb$field_name as fn FROM RDB$RELATION_FIELDS WHERE rdb$relation_name = :rn';
    q.ParamByName('rn').AsString := AName;
    q.ExecQuery;
    while not q.Eof do
    begin
      if StrIPos(';' + Trim(q.Fields[0].AsString) + ';', PassFieldName) = 0 then
        AFL.Add(Trim(q.Fields[0].AsString));
      q.Next;
    end;
  finally
    q.Free;
  end;
end;

procedure TgsDBExtractData.WriteString(AStream: TFileStream; const AFieldName: String; const AValue: String);
var
  Temps: String;
begin
  Temps := AFieldName + ': ' + Trim(AValue) + #13#10;
  AStream.WriteBuffer(PChar(Temps)^, Length(Temps));
end;

procedure TgsDBExtractData.ExtractData(Const AFileName: String);
const
  sqlGetRUID = 'SELECT xid || ''_'' || dbid as ruid FROM gd_ruid WHERE id = :id';
var
  q, q2: TIBSQL;
  Temps: String;
  FN: TFileStream;
  I, J: Integer;
  SL, TableList: TStringList;
  RN, PKField: String;
begin
  q := TIBSQL.Create(nil);
  q2 := TIBSQL.Create(nil);
  FN := TFileStream.Create(AFileName, fmCreate);
  SL := TStringList.Create;
  TableList := TStringList.Create;
  try
    q.Transaction := FReadTransaction;
    q2.Transaction := FReadTransaction;
    q2.SQL.Text := sqlGetRUID;
    TableList.Clear;
    SetTableName(TableList);
    for J := 0 to TableList.Count - 1 do
    begin
      RN := TableList[J];
      Temps := GetPassFieldName(RN);
      SL.Clear;
      SetFKFields(SL, RN);
      PKField := GetPKField(RN);

      q.Close;
      if PKField > '' then
      begin
        q.SQL.Text := 'SELECT r.xid || ''_'' || r.dbid as xruidx, rn.* FROM ' + RN + ' rn ' +
          ' LEFT JOIN gd_ruid r ON r.id = rn.' + PKField  +
          ' ORDER BY xruidx asc, rn.' + PKField + ' asc';
      end else
      begin
        q.SQL.Text := 'SELECT * FROM ' + RN + ' ORDER BY ' +  SL[0] + ' asc';
      end;
      q.ExecQuery;

      while not q.Eof do
      begin
        WriteString(FN, 'Table', RN);
        for I := 0 to SL.Count - 1 do
        begin
          if q.FieldByName(SL[I]).IsNull then
          begin
            WriteString(FN, SL[I], 'NULL');
          end else
          begin
            if StrIPos(',' + SL[I] + ',', Temps) > 0 then
            begin
              q2.ParamByName('id').AsInteger := q.FieldByName(SL[I]).AsInteger;
              q2.ExecQuery;
              if not q2.Eof then
                WriteString(FN, SL[I], q2.Fields[0].AsString)
              else
                WriteString(FN, SL[I], q.FieldByName(SL[I]).AsString);
              q2.Close;
            end else
              WriteString(FN, SL[I], q.FieldByName(SL[I]).AsString);
          end
        end;
        q.Next;
      end;
    end;
  finally
    q.Free;
    q2.Free;
    SL.Free;
    TableList.Free;
    FN.Free;
  end;
end;

end.

