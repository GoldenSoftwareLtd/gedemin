
unit gdcNamespaceSyncController;

interface

uses
  Classes, DB, IBDatabase, IBSQL, IBCustomDataSet;

type
  TOnLogMessage = procedure(const AMessage: String) of object;

  TgdcNamespaceSyncController = class(TObject)
  private
    FTr: TIBTransaction;
    FqInsertFile: TIBSQL;
    FqFindFile: TIBSQL;
    FqFindDirectory: TIBSQL;
    FqInsertLink: TIBSQL;
    FqFillSync: TIBSQL;
    FDataSet: TIBDataSet;
    FDirectory: String;
    FUpdateCurrModified: Boolean;
    FOnLogMessage: TOnLogMessage;

    procedure Init;
    procedure DoLog(const AMessage: String);
    procedure AnalyzeFile(const AFileName: String);
    function GetDataSet: TDataSet;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Scan;

    property Directory: String read FDirectory write FDirectory;
    property UpdateCurrModified: Boolean read FUpdateCurrModified write FUpdateCurrModified;
    property OnLogMessage: TOnLogMessage read FOnLogMessage write FOnLogMessage;
    property DataSet: TDataSet read GetDataSet;
  end;

implementation

uses
  SysUtils, jclFileUtils, gdcBaseInterface, gdcBase, gdcNamespace,
  gd_GlobalParams_unit, yaml_parser, gd_common_functions;

{ TgdcNamespaceSyncController }

procedure TgdcNamespaceSyncController.AnalyzeFile(const AFileName: String);
var
  Parser: TyamlParser;
  M: TyamlMapping;
  S: TyamlSequence;
  I: Integer;
  NSRUID, UsesRuid: TRUID;
  UsesName: String;
begin
  FqFindDirectory.ParamByName('filename').AsString := ExtractFilePath(AFileName);
  FqFindDirectory.ExecQuery;

  if FqFindDirectory.EOF then
  begin
    FqInsertFile.ParamByName('filename').AsString := ExtractFilePath(AFileName);
    FqInsertFile.ParamByName('filetimestamp').Clear;
    FqInsertFile.ParamByName('filesize').Clear;
    FqInsertFile.ParamByName('name').AsString := ExtractFilePath(AFileName);
    FqInsertFile.ParamByName('caption').AsString := ExtractFilePath(AFileName);
    FqInsertFile.ParamByName('version').Clear;
    FqInsertFile.ParamByName('dbversion').Clear;
    FqInsertFile.ParamByName('optional').AsInteger := 0;
    FqInsertFile.ParamByName('internal').AsInteger := 0;
    FqInsertFile.ParamByName('comment').Clear;
    FqInsertFile.ParamByName('xid').Clear;
    FqInsertFile.ParamByName('dbid').Clear;
    FqInsertFile.ExecQuery;
  end;

  FqFindDirectory.Close;

  Parser := TyamlParser.Create;
  try
    Parser.Parse(AFileName, 'Objects', 8192);

    if (Parser.YAMLStream.Count > 0)
      and ((Parser.YAMLStream[0] as TyamlDocument).Count > 0)
      and ((Parser.YAMLStream[0] as TyamlDocument)[0] is TyamlMapping) then
    begin
      M := (Parser.YAMLStream[0] as TyamlDocument)[0] as TyamlMapping;
      if M.ReadString('Properties\Name') = '' then
        DoLog('Неверный формат файла ' + AFileName)
      else
      begin
        NSRUID := StrToRUID(M.ReadString('Properties\RUID'));

        FqFindFile.Close;
        FqFindFile.ParamByName('name').AsString := M.ReadString('Properties\Name');
        FqFindFile.ParamByName('xid').AsInteger := NSRUID.XID;
        FqFindFile.ParamByName('dbid').AsInteger := NSRUID.DBID;
        FqFindFile.ExecQuery;

        if not FqFindFile.EOF then
        begin
          DoLog(
            'Пространство имен: "' + M.ReadString('Properties\Name') + '" содержится в файлах:' + #13#10 +
            '1: ' + FqFindFile.FieldByName('filename').AsString + #13#10 +
            '2: ' + AFileName + #13#10 +
            'Только первый файл будет обработан!');
        end else
        begin
          FqInsertFile.ParamByName('filename').AsString := AFileName;
          FqInsertFile.ParamByName('filetimestamp').AsDateTime := gd_common_functions.GetFileLastWrite(AFileName);
          FqInsertFile.ParamByName('filesize').AsInteger := FileGetSize(AFileName);
          FqInsertFile.ParamByName('name').AsString := M.ReadString('Properties\Name');
          FqInsertFile.ParamByName('caption').AsString := M.ReadString('Properties\Caption');
          FqInsertFile.ParamByName('version').AsString := M.ReadString('Properties\Version');
          FqInsertFile.ParamByName('dbversion').AsString := M.ReadString('Properties\DBVersion');
          FqInsertFile.ParamByName('optional').AsInteger := M.ReadInteger('Properties\Optional');
          FqInsertFile.ParamByName('internal').AsInteger := M.ReadInteger('Properties\Internal');
          FqInsertFile.ParamByName('comment').AsString := M.ReadString('Properties\Comment');
          FqInsertFile.ParamByName('xid').AsInteger := NSRUID.XID;
          FqInsertFile.ParamByName('dbid').AsInteger := NSRUID.DBID;
          FqInsertFile.ExecQuery;

          if M.FindByName('Uses') is TYAMLSequence then
          begin
            S := M.FindByName('Uses') as TyamlSequence;
            for I := 0 to S.Count - 1 do
            begin
              if not (S.Items[I] is TyamlString) then
                raise Exception.Create('Invalid data!');

              TgdcNamespace.ParseReferenceString((S.Items[I] as TyamlString).AsString, UsesRUID, UsesName);

              FqInsertLink.ParamByName('filename').AsString := AFileName;
              FqInsertLink.ParamByName('uses_xid').AsInteger := UsesRUID.XID;
              FqInsertLink.ParamByName('uses_dbid').AsInteger := UsesRUID.DBID;
              FqInsertLink.ParamByName('uses_name').AsString := UsesName;
              FqInsertLink.ExecQuery;
            end;
          end;
        end;
      end;
    end;
  finally
    Parser.Free;
  end;
end;

constructor TgdcNamespaceSyncController.Create;
begin
  FUpdateCurrModified := True;
  FDirectory := gd_GlobalParams.NamespacePath;
  FDataSet := TIBDataSet.Create(nil);
end;

destructor TgdcNamespaceSyncController.Destroy;
begin
  FDataSet.Free;
  FqFillSync.Free;
  FqFindDirectory.Free;
  FqInsertLink.Free;
  FqFindFile.Free;
  FqInsertFile.Free;
  FTr.Free;
  inherited;
end;

procedure TgdcNamespaceSyncController.DoLog(const AMessage: String);
begin
  if Assigned(FOnLogMessage) then
    FOnLogMessage(AMessage);
end;

function TgdcNamespaceSyncController.GetDataSet: TDataSet;
begin
  Result := FDataSet as TDataSet;
end;

procedure TgdcNamespaceSyncController.Init;
begin
  Assert(gdcBaseManager <> nil);

  if FTr <> nil then
  begin
    FTr.Commit;
    FTr.StartTransaction;
    exit;
  end;

  FTr := TIBTransaction.Create(nil);
  FTr.DefaultDatabase := gdcBaseManager.Database;
  FTr.Params.CommaText := 'read_committed,rec_version,nowait';
  FTr.StartTransaction;

  FqInsertFile := TIBSQL.Create(nil);
  FqInsertFile.Transaction := FTr;
  FqInsertFile.SQL.Text :=
    'INSERT INTO at_namespace_file ' +
    '  (filename, filetimestamp, filesize, name, caption, version, ' +
    '   dbversion, optional, internal, comment, xid, dbid) ' +
    'VALUES ' +
    '  (:filename, :filetimestamp, :filesize, :name, :caption, :version, ' +
    '   :dbversion, :optional, :internal, :comment, :xid, :dbid)';

  FqFindFile := TIBSQL.Create(nil);
  FqFindFile.Transaction := FTr;
  FqFindFile.SQL.Text :=
    'SELECT * FROM at_namespace_file ' +
    'WHERE (xid = :xid AND dbid = :dbid) OR (name = :name)';

  FqInsertLink := TIBSQL.Create(nil);
  FqInsertLink.Transaction := FTr;
  FqInsertLink.SQL.Text :=
    'INSERT INTO at_namespace_file_link ' +
    '  (filename, uses_xid, uses_dbid, uses_name) ' +
    'VALUES ' +
    '  (:filename, :uses_xid, :uses_dbid, :uses_name)';

  FqFindDirectory := TIBSQL.Create(nil);
  FqFindDirectory.Transaction := FTr;
  FqFindDirectory.SQL.Text :=
    'SELECT * FROM at_namespace_file ' +
    'WHERE filename = :filename AND xid IS NULL AND dbid IS NULL';

  FqFillSync := TIBSQL.Create(nil);
  FqFillSync.Transaction := FTr;
  FqFillSync.SQL.Text :=
    'EXECUTE BLOCK ' +
    'AS ' +
    'BEGIN ' +
    '  INSERT INTO at_namespace_sync (namespacekey) ' +
    '  SELECT id FROM at_namespace; ' +
    ' ' +
    '  MERGE INTO at_namespace_sync s ' +
    '  USING ( ' +
    '    SELECT f.filename, n.id, f.xid ' +
    '    FROM at_namespace_file f ' +
    '      LEFT JOIN gd_ruid r ' +
    '        ON r.xid = f.xid AND r.dbid = f.dbid ' +
    '      LEFT JOIN at_namespace n ' +
    '        ON (r.id = n.id) OR (n.name = f.name) ' +
    '    ) j ' +
    '  ON (s.namespacekey = j.id) ' +
    '  WHEN MATCHED THEN UPDATE SET filename = j.filename ' +
    '  WHEN NOT MATCHED THEN INSERT (filename, operation) ' +
    '    VALUES (j.filename, IIF(j.xid IS NULL, ''  '', ''< '')); ' +
    ' ' +
    '  UPDATE at_namespace_sync SET operation = ''> '' ' +
    '  WHERE operation = ''  '' AND namespacekey IS NOT NULL ' +
    '    AND filename IS NULL; ' +
    ' ' +
    '  UPDATE at_namespace_sync s SET s.operation = ''>>'' ' +
    '  WHERE ' +
    '    EXISTS (SELECT * FROM at_object o ' +
    '      WHERE o.namespacekey = s.namespacekey ' +
    '        AND DATEDIFF(SECOND, o.modified, o.curr_modified) >= 1) ' +
    '    AND (s.operation = ''  ''); ' +
    ' ' +
    '  UPDATE at_namespace_sync s SET s.operation = ' +
    '    iif(s.operation = ''  '', ''<<'', ''? '') ' +
    '  WHERE ' +
    '    (SELECT f.filetimestamp FROM at_namespace_file f ' +
    '      WHERE f.filename = s.filename) > ' +
    '    (SELECT n.filetimestamp FROM at_namespace n ' +
    '      WHERE n.id = s.namespacekey) ' +
    '    AND (s.operation = ''  ''); ' +
    ' ' +

    'END';

  FDataSet.ReadTransaction := FTr;
  FDataSet.Transaction := FTr;
  FDataSet.SelectSQL.Text :=
    'SELECT ' +
    '  n.id AS NamespaceKey, ' +
    '  n.name AS NamespaceName, ' +
    '  n.version AS NamespaceVersion, ' +
    '  n.filetimestamp AS NamespaceTimestamp, ' +
    '  n.internal AS NamespaceInternal, ' +
    '  s.operation, ' +
    '  f.filename, ' +
    '  f.name AS FileNamespaceName, ' +
    '  f.version AS FileVersion, ' +
    '  f.filetimestamp AS FileTimeStamp, ' +
    '  f.filesize AS FileSize, ' +
    '  (f.xid || ''_'' || f.dbid) AS FileRUID, ' +
    '  f.internal AS FileInternal ' +
    'FROM ' +
    '  at_namespace_sync s ' +
    '  LEFT JOIN at_namespace n ON n.id = s.namespacekey ' +
    '  LEFT JOIN at_namespace_file f ON f.filename = s.filename ' +
    'ORDER BY ' +
    '  f.filename'; 
end;

procedure TgdcNamespaceSyncController.Scan;
var
  SL: TStringList;
  I: Integer;
begin
  Init;

  if FUpdateCurrModified then
  begin
    DoLog('Обновление даты изменения объекта...');
    TgdcNamespace.UpdateCurrModified;
    DoLog('Окончено обновление даты изменения объекта...');
  end;

  SL := TStringList.Create;
  try
    if AdvBuildFileList(IncludeTrailingBackslash(FDirectory) + '*.yml',
      faAnyFile, SL, amAny, [flFullNames, flRecursive], '*.*', nil) then
    begin
      for I := 0 to SL.Count - 1 do
        AnalyzeFile(SL[I]);
    end;
  finally
    SL.Free;
  end;

  FqFillSync.ExecQuery;

  FDataSet.Close;
  FDataSet.Open;

  gd_GlobalParams.NamespacePath := FDirectory;
end;

end.
