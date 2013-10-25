unit FDBExtractData_unit;

interface

uses
  IB, IBDatabase, IBSQL, Classes, gd_KeyAssoc;

type
  TgsDBExtractData = class(TObject)
  private
    FUserName: AnsiString;
    FPassword: AnsiString;
    FDatabaseName: AnsiString;
    FDatabase: TIBDatabase;
    FTr: TIBTransaction;
    FRUIDS: TgdKeyStringAssoc;
    Fq: TIBSQL;
    FRelations: TStringList;

    function GetConnected: Boolean;
    procedure WriteString(AStream: TStream; AValue: AnsiString);
    procedure WriteBinary(AStream: TStream; AData: AnsiString);
    procedure LoadRUIDs;
    procedure LoadRelations;
    function GetSelectSQL(const ARelationName: AnsiString): AnsiString;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Connect;
    procedure Disconnect;

    procedure ExtractData(const AFileName: AnsiString; const AnIgnoreFields: TStrings);

    property DatabaseName: AnsiString read FDatabaseName write FDatabaseName;
    property UserName: AnsiString read FUserName write FUserName;
    property Password: AnsiString read FPassword write FPassword;
    property Connected: Boolean read GetConnected;
  end;

implementation

uses
  IBHeader, SysUtils, JclStrings, gd_common_functions, gd_directories_const;

constructor TgsDBExtractData.Create;
begin
  inherited;

  FDatabase := TIBDatabase.Create(nil);

  FTr := TIBTransaction.Create(nil);
  FTr.DefaultDatabase := FDatabase;
  FTr.Params.CommaText := 'read_committed,rec_version,nowait';

  Fq := TIBSQL.Create(nil);
  Fq.Transaction := FTr;

  FRUIDs := TgdKeyStringAssoc.Create;
  FRelations := TStringList.Create;
end;

destructor TgsDBExtractData.Destroy;
begin
  Disconnect;

  FRelations.Free;
  FRUIDs.Free;
  Fq.Free;
  FTr.Free;
  FDatabase.Free; 
  inherited;
end;

procedure TgsDBExtractData.Connect;
begin
  Assert(not Connected);

  FDatabase.DatabaseName := FDatabaseName;
  FDatabase.LoginPrompt := False;
  FDatabase.Params.Clear;
  FDatabase.Params.Add('user_name=' + FUserName);
  FDatabase.Params.Add('password=' + FPassword);
  FDatabase.Params.Add('lc_ctype=win1251');
  FDatabase.SQLDialect := 3;
  FDatabase.Open;

  FTr.StartTransaction;

  LoadRUIDS;
  LoadRelations;
end;

procedure TgsDBExtractData.Disconnect;
begin
  Fq.Close;
  if FTr.InTransaction then
    FTr.Commit;
  if Connected then
    FDatabase.Close;
end;

function TgsDBExtractData.GetConnected: Boolean;
begin
  Result := FDatabase.Connected;
end;

procedure TgsDBExtractData.WriteString(AStream: TStream; AValue: AnsiString);
begin
  AValue := AValue + #13#10;
  AStream.WriteBuffer(AValue[1], Length(AValue));
end;

procedure TgsDBExtractData.ExtractData(const AFileName: AnsiString;
  const AnIgnoreFields: TStrings);
var
  FN: TFileStream;
  I, J, K: Integer;
  V: TIBXSQLVAR;
begin
  Assert(Connected);

  for J := 0 to FRelations.Count - 1 do
  begin
    FN := TFileStream.Create(IncludeTrailingBackslash(AFileName) + FRelations[J] + '.dat', fmCreate);
    try
      Fq.SQL.Text := GetSelectSQL(FRelations[J]);
      WriteString(FN, Fq.SQL.Text);

      Fq.ExecQuery;
      while not Fq.EOF do
      begin
        WriteString(FN, '===========================================');

        for I := 0 to Fq.Current.Count - 1 do
        begin
          V := Fq.Current[I];

          if AnIgnoreFields.IndexOf(V.Name) > -1 then
            continue;

          if V.IsNull then
            WriteString(FN, V.Name + ': NULL')
          else if (V.SQLType = SQL_LONG) and (V.AsXSQLVAR.SQLScale = 0)
            and (V.AsInteger >= cstUserIDStart) then
          begin
            K := FRUIDs.IndexOf(V.AsInteger);
            if K = -1 then
            begin
              if (V.Name <> 'ID') and (V.Name <> 'PARENT') and (Copy(V.Name, Length(V.Name) - 3 + 1, 3) <> 'KEY') then
                WriteString(FN, V.Name + ': ' + V.AsString);
            end else
              WriteString(FN, V.Name + ': ' + FRUIDs.ValuesByIndex[K]);
          end
          else if V.SQLType = SQL_BLOB then
          begin
            if V.AsXSQLVAR.sqlsubtype = 1 then
              WriteString(FN, V.Name + ':'#13#10 + TrimRight(V.AsString))
            else begin
              WriteString(FN, V.Name + ':');
              WriteBinary(FN, V.AsString);
            end
          end else
            WriteString(FN, V.Name + ': ' + V.AsString);
        end;
        Fq.Next;
      end;
      Fq.Close;
    finally
      FN.Free;
    end;
  end;
end;

procedure TgsDBExtractData.LoadRUIDs;
begin
  Assert(Connected);

  FRUIDs.Clear;

  Fq.Close;
  Fq.SQL.Text := 'SELECT id, xid || ''_'' || dbid FROM gd_ruid';
  Fq.ExecQuery;
  while not Fq.EOF do
  begin
    FRUIDs.ValuesByIndex[FRUIDs.Add(Fq.Fields[0].AsInteger)] :=
      Fq.Fields[1].AsString;
    Fq.Next;
  end;
  Fq.Close;
end;

procedure TgsDBExtractData.LoadRelations;
const
  PassTable =
    ';AT_SETTING;AT_SETTINGPOS;AT_SETTING_STORAGE;AT_NAMESPACE;AT_OBJECT' +
    ';AT_NAMESPACE_LINK;GD_RUID;GD_JOURNAL;';
begin
  Assert(Connected);

  FRelations.Clear;

  Fq.Close;
  Fq.SQL.Text :=
    'SELECT rdb$relation_name FROM rdb$relations ' +
    'WHERE rdb$system_flag = 0 AND rdb$relation_type = 0 ' +
    'ORDER BY rdb$relation_name';
  Fq.ExecQuery;
  while not Fq.Eof do
  begin
    if Pos(';' + Fq.Fields[0].AsTrimString + ';', PassTable) = 0 then
      FRelations.Add(Fq.Fields[0].AsTrimString);
    Fq.Next;
  end;
  Fq.Close;
end;

procedure TgsDBExtractData.WriteBinary(AStream: TStream;
  AData: AnsiString);
const
  HexInRow = 16;
var
  I, L: Integer;
  B, C: PAnsiChar;
  Size: Integer;
begin
  if TryObjectBinaryToText(AData) then
    WriteString(AStream, AData)
  else begin
    L := Length(AData);
    Size := L * 3 + ((L div HexInRow) + 1) * (2 + 4) + 32;
    GetMem(B, Size);
    try
      C := B;
      C[0] := #0;
      for I := 1 to L do
      begin
        if I mod HexInRow = 1 then
          C := StrCat(C, '    ') + StrLen(C);
        C := StrCat(C, PChar(AnsiCharToHex(AData[I]) + ' ')) + StrLen(C);
        if I mod HexInRow = 0 then
          C := StrCat(C, #13#10) + StrLen(C);
      end;
      StrCat(C, #13#10);
      WriteString(AStream, B);
    finally
      FreeMem(B, Size);
    end;
  end;
end;

function TgsDBExtractData.GetSelectSQL(const ARelationName: AnsiString): AnsiString;
begin
  Assert(Connected);

  if ARelationName = 'GD_STORAGE_DATA' then
    Result :=
      'SELECT d.DATA_TYPE, d.STR_DATA, d.INT_DATA, d.DATETIME_DATA, ' +
      '  d.CURR_DATA, d.BLOB_DATA, d.EDITIONDATE, d.EDITORKEY, t.path ' +
      'FROM gd_storage_data d JOIN ' +
      '(WITH RECURSIVE '#13#10 +
      'group_tree AS ( '#13#10 +
      'SELECT '#13#10 +
      'CAST('''' AS VARCHAR(1024)) as path, '#13#10 +
      '-1 as id, '#13#10 +
      '-1 as parent, '#13#10 +
      'CAST('''' AS dname) as name '#13#10 +
      'FROM '#13#10 +
      'rdb$database '#13#10 +
      '  '#13#10 +
      'UNION ALL '#13#10 +
      '  '#13#10 +
      'SELECT '#13#10 +
      'IIF(gt.path > '''', gt.path || ''.'', '''') || g2.name, '#13#10 +
      'g2.id, '#13#10 +
      'g2.parent, '#13#10 +
      'g2.name '#13#10 +
      'FROM '#13#10 +
      'gd_storage_data g2 JOIN group_tree gt '#13#10 +
      'ON COALESCE(g2.parent, -1) = gt.id '#13#10 +
      ') '#13#10 +
      'SELECT '#13#10 +
      '* '#13#10 +
      'FROM '#13#10 +
      'group_tree '#13#10 +
      'WHERE '#13#10 +
      'path > '''') t ON t.id = d.id ORDER BY t.path'
  else if ARelationName = 'AT_INDICES' then
    Result := 'SELECT * FROM AT_INDICES WHERE NOT indexname LIKE ''RDB$%'' ORDER BY relationname, fieldslist'
  else if ARelationName = 'GD_COMMAND' then
    Result := 'SELECT parent, name, cmd, cmdtype, hotkey, imgindex, ordr, classname, subtype, disabled FROM GD_COMMAND ORDER BY classname, subtype, name, cmdtype'
  else if ARelationName = 'AT_TRIGGERS' then
    Result := 'SELECT * FROM AT_TRIGGERS WHERE NOT triggername LIKE ''CHECK_%'' ORDER BY relationname, triggername'
  else if ARelationName = 'GD_CURRRATE' then
    Result := 'SELECT * FROM GD_CURRRATE ORDER BY fromcurr, tocurr, fordate'
  else if ARelationName = 'FLT_COMPONENTFILTER' then
    Result := 'SELECT * FROM FLT_COMPONENTFILTER ORDER BY fullname'
  else if ARelationName = 'EVT_OBJECT' then
    Result :=
      'SELECT COALESCE(e8.name, '''') || COALESCE(e7.name, '''') || COALESCE(e6.name, '''') || '#13#10 +
      '  COALESCE(e5.name, '''') || COALESCE(e4.name, '''') || COALESCE(e3.name, '''') ||  '#13#10 +
      '  COALESCE(e2.name, '''') || COALESCE(e.name, ''''), '#13#10 +
      '  e.DESCRIPTION, e.OBJECTTYPE, e.MACROSGROUPKEY, e.REPORTGROUPKEY, '#13#10 +
      '  e.CLASSNAME, e.OBJECTNAME, e.SUBTYPE, e.EDITIONDATE, e.EDITORKEY '#13#10 +
      'FROM evt_object e '#13#10 +
      '  LEFT JOIN evt_object e2 ON e2.id = e.parent '#13#10 +
      '  LEFT JOIN evt_object e3 ON e3.id = e2.parent '#13#10 +
      '  LEFT JOIN evt_object e4 ON e4.id = e3.parent '#13#10 +
      '  LEFT JOIN evt_object e5 ON e5.id = e4.parent '#13#10 +
      '  LEFT JOIN evt_object e6 ON e6.id = e5.parent '#13#10 +
      '  LEFT JOIN evt_object e7 ON e7.id = e6.parent '#13#10 +
      '  LEFT JOIN evt_object e8 ON e8.id = e7.parent '#13#10 +
      'ORDER BY 1'
  else if ARelationName = 'EVT_OBJECTEVENT' then
    Result := 'SELECT a.* FROM EVT_OBJECTEVENT a LEFT JOIN gd_ruid r ON r.id = a.id ORDER BY r.xid, r.dbid'
  else if ARelationName = 'EVT_MACROSGROUP' then
    Result := 'SELECT a.* FROM EVT_MACROSGROUP a LEFT JOIN gd_ruid r ON r.id = a.id ORDER BY r.xid, r.dbid'
  else if ARelationName = 'AC_TRANSACTION' then
    Result := 'SELECT a.* FROM AC_TRANSACTION a LEFT JOIN gd_ruid r ON r.id = a.id ORDER BY r.xid, r.dbid'
  else if ARelationName = 'AC_AUTOTRRECORD' then
    Result := 'SELECT a.* FROM AC_AUTOTRRECORD a LEFT JOIN gd_ruid r ON r.id = a.id ORDER BY r.xid, r.dbid'
  else if ARelationName = 'AC_ACCOUNT' then
    Result := 'SELECT * FROM AC_ACCOUNT ORDER BY name'
  else if ARelationName = 'AC_TRRECORD' then
    Result := 'SELECT * FROM AC_TRRECORD ORDER BY description, id'
  else if ARelationName = 'GD_CONSTVALUE' then
    Result := 'SELECT * FROM GD_CONSTVALUE ORDER BY constdate, constvalue'
  else if ARelationName = 'GD_PEOPLE' then
    Result := 'SELECT * FROM GD_PEOPLE ORDER BY surname'
  else if ARelationName = 'GD_PLACE' then
    Result := 'SELECT * FROM GD_PLACE ORDER BY lb'
  else if ARelationName = 'GD_GOODGROUP' then
    Result := 'SELECT * FROM GD_GOODGROUP ORDER BY name, lb'
  else if ARelationName = 'RP_ADDITIONALFUNCTION' then
    Result := 'SELECT m.name, a.name FROM RP_ADDITIONALFUNCTION r ' +
    ' LEFT JOIN gd_function m ON m.id = r.mainfunctionkey ' +
    ' LEFT JOIN gd_function a ON a.id = r.addfunctionkey ' +
    ' ORDER BY m.name, a.name '
  else if ARelationName = 'USR$CROSS179_256548741' then
    Result :=
      'SELECT t.usr$name, g.usr$name'#13#10 +
      'FROM USR$CROSS179_256548741 c'#13#10 +
      '  join usr$wg_feetype t on c.usr$wg_feetypekey = t.id'#13#10 +
      '  join usr$wg_feegroup g on c.usr$wg_feegroupkey = g.id'#13#10 +
      'ORDER BY 1, 2'
  else if ARelationName = 'GD_FUNCTION' then
    Result := 'SELECT f.* FROM GD_FUNCTION f ORDER BY f.name, HASH(f.script)'
  else if ARelationName = 'AT_RELATION_FIELDS' then
    Result := 'SELECT * FROM AT_RELATION_FIELDS ORDER BY relationname, fieldname'
  else begin
    Result := 'SELECT * FROM ' + ARelationName + ' ORDER BY ';

    Fq.Close;
    Fq.SQL.Text :=
      'SELECT '#13#10 +
      '  r.RDB$RELATION_NAME, i.RDB$INDEX_NAME, LIST(iseg.RDB$FIELD_NAME) '#13#10 +
      'FROM '#13#10 +
      '  RDB$INDICES i JOIN RDB$RELATIONS r '#13#10 +
      '    ON r.RDB$RELATION_NAME = i.RDB$RELATION_NAME '#13#10 +
      '  JOIN RDB$INDEX_SEGMENTS iseg '#13#10 +
      '    ON iseg.RDB$INDEX_NAME = i.RDB$INDEX_NAME '#13#10 +
      '  JOIN RDB$RELATION_FIELDS rf '#13#10 +
      '    ON rf.RDB$FIELD_NAME = iseg.RDB$FIELD_NAME '#13#10 +
      '      AND rf.RDB$RELATION_NAME = r.RDB$RELATION_NAME '#13#10 +
      '  JOIN RDB$FIELDS f '#13#10 +
      '    ON f.RDB$FIELD_NAME = rf.RDB$FIELD_SOURCE '#13#10 +
      'WHERE '#13#10 +
      '  i.RDB$UNIQUE_FLAG = 1 '#13#10 +
      '  AND '#13#10 +
      '  f.RDB$FIELD_TYPE <> 8 '#13#10 +
      '  AND '#13#10 +
      '  r.RDB$RELATION_NAME = :RN '#13#10 +
      'GROUP BY '#13#10 +
      '  1, 2';
    Fq.ParamByName('RN').AsString := ARelationName;
    Fq.ExecQuery;
    if Fq.EOF then
      Result := Result + '1'
    else
      Result := Result + Fq.Fields[2].AsString;
    Fq.Close;
  end;
end;

end.

