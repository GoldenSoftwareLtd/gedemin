
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
    FDataSet, FdsFileTree: TIBDataSet;
    FDirectory: String;
    FUpdateCurrModified: Boolean;
    FOnLogMessage: TOnLogMessage;
    FFilterOnlyPackages: Boolean;
    FFilterText: String;
    FFilterOperation: String;
    Fq: TIBSQL;
    FqUpdateOperation: TIBSQL;
    FqDependentList: TIBSQL;
    FqUsesList: TIBSQL;

    procedure Init;
    procedure DoLog(const AMessage: String);
    procedure AnalyzeFile(const AFileName: String);
    function GetDataSet: TDataSet;
    function GetFiltered: Boolean;
    function GetdsFileTree: TDataSet;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Scan;
    procedure ApplyFilter;
    procedure BuildTree;
    procedure DeleteFile(const AFileName: String);
    procedure SetOperation(const AnOp: String);
    procedure Sync;
    procedure EditNamespace(const ANSK: Integer);
    procedure CompareWithData(const ANSK: Integer; const AFileName: String);

    property Directory: String read FDirectory write FDirectory;
    property UpdateCurrModified: Boolean read FUpdateCurrModified write FUpdateCurrModified;
    property OnLogMessage: TOnLogMessage read FOnLogMessage write FOnLogMessage;
    property DataSet: TDataSet read GetDataSet;
    property dsFileTree: TDataSet read GetdsFileTree;
    property FilterOnlyPackages: Boolean read FFilterOnlyPackages write FFilterOnlyPackages;
    property FilterText: String read FFilterText write FFilterText;
    property FilterOperation: String read FFilterOperation write FFilterOperation;
    property Filtered: Boolean read GetFiltered;
  end;

implementation

uses
  SysUtils, Controls, jclFileUtils, gdcBaseInterface, gdcBase, gdcNamespace,
  gdcNamespaceLoader, gd_GlobalParams_unit, yaml_parser, gd_common_functions,
  at_dlgCheckOperation_unit;

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
      and ((Parser.YAMLStream[0] as TyamlDocument)[0] is TyamlMapping)
      and (((Parser.YAMLStream[0] as TyamlDocument)[0] as TyamlMapping).ReadString('Properties\Name') > '') then
    begin
      M := (Parser.YAMLStream[0] as TyamlDocument)[0] as TyamlMapping;
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
              DoLog('Ошибка в секции USES файла ' + AFileName)
            else begin
              TgdcNamespace.ParseReferenceString((S.Items[I] as TyamlString).AsString, UsesRUID, UsesName);

              FqInsertLink.ParamByName('filename').AsString := AFileName;
              FqInsertLink.ParamByName('uses_xid').AsInteger := UsesRUID.XID;
              FqInsertLink.ParamByName('uses_dbid').AsInteger := UsesRUID.DBID;
              FqInsertLink.ParamByName('uses_name').AsString := UsesName;
              FqInsertLink.ExecQuery;
            end;
          end;
        end;
        DoLog(AFileName);
      end;
    end else
      DoLog('Неверный формат файла ' + AFileName);
  finally
    Parser.Free;
  end;
end;

procedure TgdcNamespaceSyncController.ApplyFilter;
var
  NK: Integer;
  FN: String;
begin
  if not FDataSet.EOF then
  begin
    NK := FDataSet.FieldByName('namespacekey').AsInteger;
    FN := FDataSet.FieldByName('filename').AsString;
  end else
  begin
    NK := 0;
    FN := '';
  end;

  FDataSet.DisableControls;
  try
    FDataSet.Close;
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
      '  LEFT JOIN at_namespace_file f ON f.filename = s.filename ';

    if FFilterOnlyPackages or (FFilterText > '') or (FFilterOperation > '') then
    begin
      FDataSet.SelectSQL.Text := FDataSet.SelectSQL.Text +
        'WHERE (f.name CONTAINING ''\'') OR (';

      if FFilterOnlyPackages then
        FDataSet.SelectSQL.Text := FDataSet.SelectSQL.Text +
          '((n.id IS NOT NULL AND n.internal = 0) OR (f.name IS NOT NULL AND f.internal = 0))';

      if FFilterText > '' then
      begin
        if FFilterOnlyPackages then
          FDataSet.SelectSQL.Text := FDataSet.SelectSQL.Text + ' AND ';
        FDataSet.SelectSQL.Text := FDataSet.SelectSQL.Text +
          '(POSITION(:t IN UPPER(' +
          '  COALESCE(n.name, '''') || ' +
          '  COALESCE(n.version, '''') || ' +
          '  COALESCE(n.filetimestamp, '''') || ' +
          '  COALESCE(f.filename, '''') || ' +
          '  COALESCE(f.name, '''') || ' +
          '  COALESCE(f.version, '''') || ' +
          '  COALESCE(f.filetimestamp, ''''))) > 0)';
      end;

      if FFilterOperation > '' then
      begin
        if FFilterOnlyPackages or (FFilterText > '') then
          FDataSet.SelectSQL.Text := FDataSet.SelectSQL.Text + ' AND ';
        FDataSet.SelectSQL.Text := FDataSet.SelectSQL.Text +
          '(POSITION(CAST(s.operation AS VARCHAR(1024)) IN :op) > 0)';
      end;

      FDataSet.SelectSQL.Text := FDataSet.SelectSQL.Text + ')';
    end;

    FDataSet.SelectSQL.Text := FDataSet.SelectSQL.Text +
      'ORDER BY ' +
      '  f.filename';

    if FFilterText > '' then
      FDataSet.ParamByName('t').AsString := AnsiUpperCase(FFilterText);

    if FFilterOperation > '' then
      FDataSet.ParamByName('op').AsString := FFilterOperation;

    FDataSet.Open;

    if (NK = 0) or (not FDataSet.Locate('namespacekey', NK, [])) then
    begin
      if FN > '' then
        FDataSet.Locate('filename', FN, []);
    end;
  finally
    FDataSet.EnableControls;
  end;
end;

procedure TgdcNamespaceSyncController.BuildTree;
begin
  FdsFileTree.Close;
  FdsFileTree.Open;
end;

procedure TgdcNamespaceSyncController.CompareWithData(const ANSK: Integer;
  const AFileName: String);
begin
  with TgdcNamespace.Create(nil) do
  try
    SubSet := 'ByID';
    ID := ANSK;
    Open;
    if not EOF then
      CompareWithData(AFileName);
  finally
    Free;
  end;
end;

constructor TgdcNamespaceSyncController.Create;
begin
  FUpdateCurrModified := True;
  FDirectory := gd_GlobalParams.NamespacePath;
  FDataSet := TIBDataSet.Create(nil);
  FdsFileTree := TIBDataSet.Create(nil);
end;

procedure TgdcNamespaceSyncController.DeleteFile(const AFileName: String);
begin
  if SysUtils.DeleteFile(AFileName) then
  begin
    DoLog('Файл ' + AFileName + ' был удален.');

    Fq.Close;
    Fq.SQL.Text :=
      'DELETE FROM at_namespace_file WHERE UPPER(filename) = :fn';
    Fq.ParamByName('fn').AsString := AnsiUpperCase(AFileName);
    Fq.ExecQuery;
  end;
end;

destructor TgdcNamespaceSyncController.Destroy;
begin
  FqUsesList.Free;
  FqDependentList.Free;
  FqUpdateOperation.Free;
  Fq.Free;
  FdsFileTree.Free;
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

procedure TgdcNamespaceSyncController.EditNamespace(const ANSK: Integer);
begin
  with TgdcNamespace.Create(nil) do
  try
    SubSet := 'ByID';
    ID := ANSK;
    Open;
    if not EOF then
      EditDialog;
  finally
    Free;
  end;
end;

function TgdcNamespaceSyncController.GetDataSet: TDataSet;
begin
  Result := FDataSet as TDataSet;
end;

function TgdcNamespaceSyncController.GetdsFileTree: TDataSet;
begin
  Result := FdsFileTree;
end;

function TgdcNamespaceSyncController.GetFiltered: Boolean;
begin
  Result := FFilterOnlyPackages
    or (FFilterText > '')
    or (FFilterOperation > '');
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
    'EXECUTE BLOCK '#13#10 +
    'AS '#13#10 +
    '  DECLARE VARIABLE Cont INTEGER; '#13#10 +
    'BEGIN '#13#10 +
    '  INSERT INTO at_namespace_sync (namespacekey) '#13#10 +
    '  SELECT id FROM at_namespace; '#13#10 +
    ' '#13#10 +
    '  MERGE INTO at_namespace_sync s '#13#10 +
    '  USING ( '#13#10 +
    '    SELECT f.filename, n.id, f.xid '#13#10 +
    '    FROM at_namespace_file f '#13#10 +
    '      LEFT JOIN gd_ruid r '#13#10 +
    '        ON r.xid = f.xid AND r.dbid = f.dbid '#13#10 +
    '      LEFT JOIN at_namespace n '#13#10 +
    '        ON (r.id = n.id) OR (n.name = f.name) '#13#10 +
    '    ) j '#13#10 +
    '  ON (s.namespacekey = j.id) '#13#10 +
    '  WHEN MATCHED THEN UPDATE SET filename = j.filename '#13#10 +
    '  WHEN NOT MATCHED THEN INSERT (filename, operation) '#13#10 +
    '    VALUES (j.filename, IIF(j.xid IS NULL, ''  '', ''< '')); '#13#10 +
    ' '#13#10 +
    '  UPDATE at_namespace_sync SET operation = ''> '' '#13#10 +
    '  WHERE namespacekey IS NOT NULL '#13#10 +
    '    AND filename IS NULL; '#13#10 +
    ' '#13#10 +
    '  UPDATE at_namespace_sync s SET s.operation = ''>>'' '#13#10 +
    '  WHERE '#13#10 +
    '    (EXISTS (SELECT * FROM at_object o '#13#10 +
    '       WHERE o.namespacekey = s.namespacekey '#13#10 +
    '         AND DATEDIFF(SECOND, o.modified, o.curr_modified) >= 1) '#13#10 +
    '     OR '#13#10 +
    '     (EXISTS (SELECT * FROM at_namespace_sync s '#13#10 +
    '        JOIN at_namespace n ON n.id = s.namespacekey '#13#10 +
    '        JOIN at_namespace_file f ON f.filename = s.filename '#13#10 +
    '        WHERE n.filetimestamp > f.filetimestamp '#13#10 +
    '      )'#13#10 +
    '     ) '#13#10 +
    '    ) '#13#10 +
    '    AND (s.operation = ''  ''); '#13#10 +
    ' '#13#10 +
    '  UPDATE at_namespace_sync s SET s.operation = ''<<'' '#13#10 +
    '  WHERE '#13#10 +
    '   (EXISTS (SELECT * FROM at_namespace_sync s '#13#10 +
    '      JOIN at_namespace n ON n.id = s.namespacekey '#13#10 +
    '      JOIN at_namespace_file f ON f.filename = s.filename '#13#10 +
    '      WHERE n.filetimestamp < f.filetimestamp) '#13#10 +
    '    )'#13#10 +
    '    AND (s.operation = ''  ''); '#13#10 +
    ' '#13#10 +
    '  UPDATE at_namespace_sync s SET s.operation = ''? '' '#13#10 +
    '  WHERE '#13#10 +
    '   (EXISTS (SELECT * FROM at_namespace_sync s '#13#10 +
    '      JOIN at_namespace n ON n.id = s.namespacekey '#13#10 +
    '      JOIN at_namespace_file f ON f.filename = s.filename '#13#10 +
    '      WHERE n.filetimestamp < f.filetimestamp) '#13#10 +
    '    )'#13#10 +
    '    AND (s.operation = ''>>''); '#13#10 +
    ' '#13#10 +
    '  UPDATE at_namespace_sync s SET s.operation = ''? '' '#13#10 +
    '  WHERE '#13#10 +
    '   (EXISTS (SELECT * FROM at_namespace_sync s '#13#10 +
    '      JOIN at_namespace n ON n.id = s.namespacekey '#13#10 +
    '      JOIN at_namespace_file f ON f.filename = s.filename '#13#10 +
    '      WHERE n.filetimestamp IS NULL) '#13#10 +
    '    )'#13#10 +
    '    AND (s.namespacekey IS NOT NULL) '#13#10 +
    '    AND (s.operation = ''  ''); '#13#10 +
    ' '#13#10 +
    '  UPDATE at_namespace_sync s SET s.operation = ''! '' '#13#10 +
    '  WHERE '#13#10 +
    '    EXISTS ('#13#10 +
    '      SELECT * FROM at_namespace_file_link l '#13#10 +
    '        LEFT JOIN '#13#10 +
    '       (SELECT r.xid, r.dbid FROM gd_ruid r JOIN at_namespace n '#13#10 +
    '          ON n.id = r.id '#13#10 +
    '        UNION '#13#10 +
    '        SELECT f.xid, f.dbid FROM at_namespace_file f) j '#13#10 +
    '        ON l.uses_xid = j.xid AND l.uses_dbid = j.dbid '#13#10 +
    '      WHERE l.filename = s.filename AND j.xid IS NULL) '#13#10 +
    '    AND (s.operation IN (''<<'', ''< '')); '#13#10 +
    ' '#13#10 +
    '  UPDATE at_namespace_sync s SET s.operation = ''=='' '#13#10 +
    '  WHERE s.operation = ''  '' AND s.namespacekey IS NOT NULL '#13#10 +
    '    AND s.filename IS NOT NULL; '#13#10 +
    ' '#13#10 +
    '  Cont = 1; '#13#10 +
    '  WHILE (:Cont > 0) DO '#13#10 +
    '  BEGIN'#13#10 +
    '    UPDATE at_namespace_sync s SET s.operation = ''<='' '#13#10 +
    '    WHERE s.operation = ''=='' AND EXISTS ('#13#10 +
    '      SELECT * FROM at_namespace_sync y JOIN at_namespace_file f '#13#10 +
    '        ON y.filename = f.filename '#13#10 +
    '      JOIN at_namespace_file_link l '#13#10 +
    '        ON l.uses_xid = f.xid AND l.uses_dbid = f.dbid '#13#10 +
    '      WHERE l.filename = s.filename '#13#10 +
    '        AND y.operation IN (''<<'', ''< '', ''<='')); '#13#10 +
    '    Cont = ROW_COUNT; '#13#10 +
    '  END'#13#10 +
    ' '#13#10 +
    '  Cont = 1; '#13#10 +
    '  WHILE (:Cont > 0) DO '#13#10 +
    '  BEGIN'#13#10 +
    '    UPDATE at_namespace_sync s SET s.operation = ''=>'' '#13#10 +
    '    WHERE s.operation = ''=='' AND EXISTS ('#13#10 +
    '      SELECT * FROM at_namespace_sync y '#13#10 +
    '      JOIN at_namespace_link l '#13#10 +
    '        ON l.useskey = y.namespacekey '#13#10 +
    '      WHERE l.namespacekey = s.namespacekey '#13#10 +
    '        AND y.operation IN (''>>'', ''> '', ''=>'')); '#13#10 +
    '    Cont = ROW_COUNT; '#13#10 +
    '  END'#13#10 +
    'END';

  FDataSet.ReadTransaction := FTr;
  FDataSet.Transaction := FTr;

  FdsFileTree.ReadTransaction := FTr;
  FdsFileTree.Transaction := FTr;
  FdsFileTree.SelectSQL.Text :=
    'WITH RECURSIVE '#13#10 +
    '  file_tree AS ( '#13#10 +
    '    SELECT '#13#10 +
    '      GEN_ID(at_g_file_tree, 1) AS id, '#13#10 +
    '      CAST(NULL AS INTEGER) AS Parent, '#13#10 +
    '      0 AS depth, '#13#10 +
    '      f.filename AS name, '#13#10 +
    '      f.filename, '#13#10 +
    '      f.xid, '#13#10 +
    '      f.dbid '#13#10 +
    '    FROM '#13#10 +
    '      at_namespace_file f '#13#10 +
    '    WHERE '#13#10 +
    '      f.version > '''' '#13#10 +
    '     '#13#10 +
    '    UNION ALL '#13#10 +
    '     '#13#10 +
    '    SELECT '#13#10 +
    '      GEN_ID(at_g_file_tree, 1) AS id, '#13#10 +
    '      t.id AS Parent, '#13#10 +
    '      (t.depth + 1) AS depth, '#13#10 +
    '      f.name, '#13#10 +
    '      f.filename, '#13#10 +
    '      f.xid, '#13#10 +
    '      f.dbid '#13#10 +
    '    FROM '#13#10 +
    '      file_tree t '#13#10 +
    '      JOIN at_namespace_file_link l '#13#10 +
    '        ON l.filename = t.filename '#13#10 +
    '      JOIN at_namespace_file f '#13#10 +
    '        ON l.uses_xid = f.xid AND l.uses_dbid = f.dbid '#13#10 +
    '    WHERE '#13#10 +
    '      t.depth < 8 '#13#10 +
    '  ) '#13#10 +
    'SELECT '#13#10 +
    '  * '#13#10 +
    'FROM '#13#10 +
    '  file_tree';

  Fq := TIBSQL.Create(nil);
  Fq.Transaction := FTr;

  FqUpdateOperation := TIBSQL.Create(nil);
  FqUpdateOperation.Transaction := FTr;
  FqUpdateOperation.SQL.Text :=
    'UPDATE at_namespace_sync SET operation = :op ' +
    'WHERE namespacekey IS NOT DISTINCT FROM :nk ' +
    '  AND filename IS NOT DISTINCT FROM :fn';

  FqDependentList := TIBSQL.Create(nil);
  FqDependentList.Transaction := FTr;
  FqDependentList.SQL.Text :=
    'WITH RECURSIVE '#13#10 +
    '  ns_tree AS ( '#13#10 +
    '    SELECT '#13#10 +
    '      n.filename AS headname, '#13#10 +
    '      CAST((n.xid || ''_'' || n.dbid || IIF(l.uses_xid IS NULL, '#13#10 +
    '        '''', ''-'' || l.uses_xid || ''_'' || l.uses_dbid)) '#13#10 +
    '        AS VARCHAR(1024)) AS path, '#13#10 +
    '      l.filename, '#13#10 +
    '      l.uses_xid, '#13#10 +
    '      l.uses_dbid '#13#10 +
    '    FROM '#13#10 +
    '      at_namespace_file n '#13#10 +
    '      LEFT JOIN at_namespace_file_link l '#13#10 +
    '        ON n.filename = l.filename '#13#10 +
    '         '#13#10 +
    '    UNION ALL '#13#10 +
    '     '#13#10 +
    '    SELECT '#13#10 +
    '      t.headname, '#13#10 +
    '      (t.path || ''-'' || f.xid || ''_'' || f.dbid) '#13#10 +
    '        AS path, '#13#10 +
    '      l.filename, '#13#10 +
    '      l.uses_xid, '#13#10 +
    '      l.uses_dbid '#13#10 +
    '    FROM '#13#10 +
    '      ns_tree t '#13#10 +
    '      JOIN at_namespace_file f '#13#10 +
    '        ON t.uses_xid = f.xid AND t.uses_dbid = f.dbid '#13#10 +
    '      JOIN at_namespace_file_link l '#13#10 +
    '        ON l.filename = f.filename '#13#10 +
    '    WHERE '#13#10 +
    '      POSITION ((f.xid || ''_'' || f.dbid) '#13#10 +
    '        IN t.path) = 0) '#13#10 +
    'SELECT '#13#10 +
    '  t.headname, COUNT(t.uses_xid) '#13#10 +
    'FROM '#13#10 +
    '  ns_tree t '#13#10 +
    '  JOIN at_namespace_sync s ON t.headname = s.filename '#13#10 +
    'WHERE '#13#10 +
    '  s.operation IN (''< '', ''<<'') '#13#10 +
    'GROUP BY '#13#10 +
    '  1 '#13#10 +
    'ORDER BY '#13#10 +
    '  2';

  FqUsesList := TIBSQL.Create(nil);
  FqUsesList.Transaction := FTr;
  FqUsesList.SQL.Text :=
    'WITH RECURSIVE '#13#10 +
    '  ns_tree AS ( '#13#10 +
    '    SELECT '#13#10 +
    '      f.filename, '#13#10 +
    '      CAST((f.xid || ''_'' || f.dbid) AS VARCHAR(1024)) AS path, '#13#10 +
    '      l2.uses_xid, '#13#10 +
    '      l2.uses_dbid '#13#10 +
    '    FROM '#13#10 +
    '      at_namespace_file f '#13#10 +
    '      JOIN at_namespace_file_link l '#13#10 +
    '        ON l.uses_xid = f.xid AND l.uses_dbid = f.dbid '#13#10 +
    '      LEFT JOIN at_namespace_file_link l2 '#13#10 +
    '        ON l2.filename = f.filename '#13#10 +
    '    WHERE '#13#10 +
    '      l.filename = :filename '#13#10 +
    '         '#13#10 +
    '    UNION ALL '#13#10 +
    '     '#13#10 +
    '    SELECT '#13#10 +
    '      f.filename, '#13#10 +
    '      (t.path || ''-'' || f.xid || ''_'' || f.dbid) '#13#10 +
    '        AS path, '#13#10 +
    '      l.uses_xid, '#13#10 +
    '      l.uses_dbid '#13#10 +
    '    FROM '#13#10 +
    '      ns_tree t '#13#10 +
    '      JOIN at_namespace_file f '#13#10 +
    '        ON t.uses_xid = f.xid AND t.uses_dbid = f.dbid '#13#10 +
    '      JOIN at_namespace_file_link l '#13#10 +
    '        ON l.filename = f.filename '#13#10 +
    '    WHERE '#13#10 +
    '      POSITION ((f.xid || ''_'' || f.dbid) '#13#10 +
    '        IN t.path) = 0) '#13#10 +
    'SELECT '#13#10 +
    '  t.filename, s.namespacekey '#13#10 +
    'FROM '#13#10 +
    '  ns_tree t '#13#10 +
    '  JOIN at_namespace_sync s ON t.filename = s.filename '#13#10 +
    'WHERE '#13#10 +
    '  t.filename <> :filename AND ' +
    '  s.operation IN (''  '', ''? '') ';
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
  end;

  SL := TStringList.Create;
  try
    if AdvBuildFileList(IncludeTrailingBackslash(FDirectory) + '*.yml',
      faAnyFile, SL, amAny, [flFullNames, flRecursive], '*.*', nil) then
    begin
      for I := 0 to SL.Count - 1 do
      try
        AnalyzeFile(SL[I]);
      except
        on E: Exception do
        begin
          DoLog('Ошибка в процессе обработки файла ' + SL[I]);
          DoLog(E.Message);
        end;
      end;
    end;
  finally
    SL.Free;
  end;

  DoLog('Определение статуса...');
  FqFillSync.ExecQuery;

  gd_GlobalParams.NamespacePath := FDirectory;
  DoLog('Выполнено сравнение с каталогом ' + FDirectory);
end;

procedure TgdcNamespaceSyncController.SetOperation(const AnOp: String);
begin
  Assert(not FDataSet.EOF);

  if
    (
      (AnOp = '<<')
      and
      (FDataSet.FieldByName('fileversion').AsString > '')
    )
    or
    (
      (AnOp = '>>')
      and
      (not FDataSet.FieldByName('namespacekey').IsNull)
    )
    or
    (
      AnOp = '  '
    ) then
  begin
    if FDataSet.FieldByName('namespacekey').IsNull then
      FqUpdateOperation.ParamByName('nk').Clear
    else
      FqUpdateOperation.ParamByName('nk').AsInteger := FDataSet.FieldByName('namespacekey').AsInteger;

    if FDataSet.FieldByName('fileversion').AsString > '' then
      FqUpdateOperation.ParamByName('fn').AsString := FDataSet.FieldByName('filename').AsString
    else
      FqUpdateOperation.ParamByName('fn').Clear;

    if (AnOp = '<<') and FDataSet.FieldByName('namespacekey').IsNull then
      FqUpdateOperation.ParamByName('op').AsString := '< '
    else if (AnOp = '>>') and (FDataSet.FieldByName('fileversion').AsString = '') then
      FqUpdateOperation.ParamByName('op').AsString := '> '
    else
      FqUpdateOperation.ParamByName('op').AsString := AnOp;

    FqUpdateOperation.ExecQuery;

    if AnOp = '<<' then
    begin
      FqUsesList.ParamByName('filename').AsString := FDataSet.FieldByName('filename').AsString;
      FqUsesList.ExecQuery;
      while not FqUsesList.EOF do
      begin
        if FqUsesList.FieldByName('namespacekey').IsNull then
          FqUpdateOperation.ParamByName('op').AsString := '< '
        else
          FqUpdateOperation.ParamByName('op').AsString := '<<';
        FqUpdateOperation.ParamByName('nk').Clear;
        FqUpdateOperation.ParamByName('fn').AsString := FqUsesList.FieldByName('filename').AsString;
        FqUpdateOperation.ExecQuery;
        
        FqUsesList.Next;
      end;
      FqUsesList.Close;
    end;
  end;
end;

procedure TgdcNamespaceSyncController.Sync;
var
  NS: TgdcNamespace;
  SL: TStringList;
begin
  with TdlgCheckOperation.Create(nil) do
  try
    Fq.Close;

    Fq.SQL.Text :=
      'SELECT LIST(n.name, ASCII_CHAR(13) || ASCII_CHAR(10)), COUNT(*) FROM at_namespace n ' +
      '  JOIN at_namespace_sync s ON s.namespacekey = n.id ' +
      'WHERE s.operation IN (''> '', ''>>'')';
    Fq.ExecQuery;
    mSaveList.Lines.Text := Fq.Fields[0].AsString;
    lSaveRecords.Caption := 'Выбрано для сохранения в файлы: ' + Fq.Fields[1].AsString;
    Fq.Close;

    Fq.SQL.Text :=
      'SELECT LIST(f.name, ASCII_CHAR(13) || ASCII_CHAR(10)), COUNT(*) FROM at_namespace_file f ' +
      '  JOIN at_namespace_sync s ON s.filename = f.filename ' +
      'WHERE s.operation IN (''< '', ''<<'')';
    Fq.ExecQuery;
    mLoadList.Lines.Text := Fq.Fields[0].AsString;
    lLoadRecords.Caption := 'Выбрано для загрузки из файлов: ' + Fq.Fields[1].AsString;
    Fq.Close;

    if ShowModal = mrOk then
    begin
      if mSaveList.Lines.Text > '' then
      begin
        NS := TgdcNamespace.Create(nil);
        try
          NS.SubSet := 'ByID';

          Fq.SQL.Text :=
            'SELECT n.id, s.filename FROM at_namespace n ' +
            '  JOIN at_namespace_sync s ON s.namespacekey = n.id ' +
            'WHERE s.operation IN (''> '', ''>>'')';
          Fq.ExecQuery;

          while not Fq.EOF do
          begin
            NS.Close;
            NS.ID := Fq.FieldByName('id').AsInteger;
            NS.Open;
            if (not NS.EOF) and NS.SaveNamespaceToFile(Fq.FieldByName('filename').AsString, chbxIncVersion.Checked) then
              DoLog('Пространство имен ' + NS.ObjectName + ' записано в файл.');
            Fq.Next;
          end;

          Fq.Close;
        finally
          NS.Free;
        end;
      end;

      if mLoadList.Lines.Text > '' then
      begin
        SL := TStringList.Create;
        try
          FqDependentList.ExecQuery;
          while not FqDependentList.EOF do
          begin
            SL.Add(FqDependentList.Fields[0].AsString);
            FqDependentList.Next;
          end;
          FqDependentList.Close;

          TgdcNamespaceLoader.LoadDelayed(SL, chbxAlwaysOverwrite.Checked, chbxDontRemove.Checked);
        finally
          SL.Free;
        end;
      end;
    end;
  finally
    Free;
  end;
end;

end.
