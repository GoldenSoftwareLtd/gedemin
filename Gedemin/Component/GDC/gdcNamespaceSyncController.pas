// ShlTanya, 10.02.2019

unit gdcNamespaceSyncController;

interface

uses
  Classes, DB, IBDatabase, IBSQL, IBCustomDataSet, gdcBaseInterface;

type
  TLogMessageType = (lmtInfo, lmtWarning, lmtError);
  TOnLogMessage = procedure(const AMessageType: TLogMessageType; const AMessage: String) of object;

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
    FFilterOnlyFiles: Boolean;
    FFilterText: String;
    FFilterOperation: String;
    Fq: TIBSQL;
    FqUpdateOperation: TIBSQL;
    FqUsesList: TIBSQL;

    procedure Init;
    procedure DoLog(const AMessageType: TLogMessageType; const AMessage: String);
    procedure AnalyzeFile(const AFileName: String);
    function GetDataSet: TDataSet;
    function GetFiltered: Boolean;
    function GetdsFileTree: TDataSet;
    procedure GetDependentList(ASL: TStrings);

  public
    constructor Create;
    destructor Destroy; override;

    procedure Scan(const ACalculateStatus: Boolean; const AClearUnexisted: Boolean;const ARecursive: boolean;const ASaveDir: Boolean);
    procedure ApplyFilter;
    procedure BuildTree;
    procedure DeleteFile(const AFileName: String);
    procedure SetOperation(const AnOp: String; const AScanUsesList: Boolean = True);
    procedure ClearAll;
    procedure Sync;
    procedure SyncSilent(const ATerminate: Boolean);
    procedure EditNamespace(const ANSK: TID);
    procedure CompareWithData(const ANSK: TID; const AFileName: String;
      const A3Way: Boolean);
    procedure ShowChanged;

    property Directory: String read FDirectory write FDirectory;
    property UpdateCurrModified: Boolean read FUpdateCurrModified write FUpdateCurrModified;
    property OnLogMessage: TOnLogMessage read FOnLogMessage write FOnLogMessage;
    property DataSet: TDataSet read GetDataSet;
    property dsFileTree: TDataSet read GetdsFileTree;
    property FilterOnlyPackages: Boolean read FFilterOnlyPackages write FFilterOnlyPackages;
    property FilterText: String read FFilterText write FFilterText;
    property FilterOperation: String read FFilterOperation write FFilterOperation;
    property Filtered: Boolean read GetFiltered;
    property FilterOnlyFiles:Boolean read FFilterOnlyFiles write FFilterOnlyFiles;
  end;

implementation

uses
  SysUtils, Controls, jclFileUtils, gdcBase,
  gdcNamespace, gdcNamespaceLoader, gd_GlobalParams_unit, yaml_parser,
  gd_common_functions, at_dlgCheckOperation_unit, at_frmSQLProcess,
  flt_frmSQLEditorSyn_unit, gd_security, gdccClient_unit, gdccConst;

{ TgdcNamespaceSyncController }

procedure TgdcNamespaceSyncController.AnalyzeFile(const AFileName: String);
var
  Parser: TyamlParser;
  M: TyamlMapping;
  S: TyamlSequence;
  I: Integer;
  NSRUID, UsesRuid: TRUID;
  UsesName: String;
  CharReplace: LongBool;
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
    FqInsertFile.ParamByName('md5').Clear;
    FqInsertFile.ExecQuery;
  end;

  FqFindDirectory.Close;

  Parser := TyamlParser.Create;
  try
    Parser.Parse(AFileName, CharReplace, 'Objects', 8192);

    if (Parser.YAMLStream.Count > 0)
      and ((Parser.YAMLStream[0] as TyamlDocument).Count > 0)
      and ((Parser.YAMLStream[0] as TyamlDocument)[0] is TyamlMapping)
      and (((Parser.YAMLStream[0] as TyamlDocument)[0] as TyamlMapping).ReadString('Properties\Name') > '') 
      and (Pos('.', ((Parser.YAMLStream[0] as TyamlDocument)[0] as TyamlMapping).ReadString('Properties\Version')) > 0) then
    begin
      if CharReplace then
        DoLog(lmtWarning, 'Замена символов при конвертации из UTF-8. ' + AFileName);

      M := (Parser.YAMLStream[0] as TyamlDocument)[0] as TyamlMapping;
      NSRUID := StrToRUID(M.ReadString('Properties\RUID'));

      FqFindFile.Close;
      FqFindFile.ParamByName('name').AsString := M.ReadString('Properties\Name');
      SetTID(FqFindFile.ParamByName('xid'), NSRUID.XID);
      FqFindFile.ParamByName('dbid').AsInteger := NSRUID.DBID;
      FqFindFile.ExecQuery;

      if not FqFindFile.EOF then
      begin
        DoLog(lmtWarning,
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
        SetTID(FqInsertFile.ParamByName('xid'), NSRUID.XID);
        FqInsertFile.ParamByName('dbid').AsInteger := NSRUID.DBID;
        FqInsertFile.ParamByName('md5').AsString := M.ReadString('Properties\MD5');
        FqInsertFile.ExecQuery;

        if M.FindByName('Uses') is TYAMLSequence then
        begin
          S := M.FindByName('Uses') as TyamlSequence;
          for I := 0 to S.Count - 1 do
          begin
            if not (S.Items[I] is TyamlString) then
              DoLog(lmtError, 'Ошибка в секции USES файла ' + AFileName)
            else begin
              TgdcNamespace.ParseReferenceString((S.Items[I] as TyamlString).AsString, UsesRUID, UsesName);

              FqInsertLink.ParamByName('filename').AsString := AFileName;
              SetTID(FqInsertLink.ParamByName('uses_xid'), UsesRUID.XID);
              FqInsertLink.ParamByName('uses_dbid').AsInteger := UsesRUID.DBID;
              FqInsertLink.ParamByName('uses_name').AsString := UsesName;
              FqInsertLink.ExecQuery;
            end;
          end;
        end;
        DoLog(lmtInfo, AFileName);
      end;
    end else
      DoLog(lmtError, 'Неверный формат файла ' + AFileName);
  finally
    Parser.Free;
  end;
end;

procedure TgdcNamespaceSyncController.ApplyFilter;
var
  NK: TID;
  FN: String;
begin
  if not FDataSet.EOF then
  begin
    NK := GetTID(FDataSet.FieldByName('namespacekey'));
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


     if FFilterOnlyFiles then
      FDataSet.SelectSQL.Text := FDataSet.SelectSQL.Text + ' WHERE (RIGHT(f.name,1)<> ''\'') ';

     if FFilterOnlyPackages or (FFilterText > '') or (FFilterOperation > '') then
     begin

     if FFilterOnlyFiles then  FDataSet.SelectSQL.Text := FDataSet.SelectSQL.Text + ' AND ('
     else
      FDataSet.SelectSQL.Text := FDataSet.SelectSQL.Text +
        'WHERE (f.name CONTAINING ''\'') OR (';


      if FFilterOnlyPackages then  begin
        FDataSet.SelectSQL.Text := FDataSet.SelectSQL.Text +
          '((n.id IS NOT NULL AND n.internal = 0) OR (f.name IS NOT NULL AND f.internal = 0))';
      end;


      if FFilterText > '' then
      begin
        if FFilterOnlyPackages  then
          FDataSet.SelectSQL.Text := FDataSet.SelectSQL.Text + ' AND ';
        FDataSet.SelectSQL.Text := FDataSet.SelectSQL.Text +
          '(' +
          '  CAST(COALESCE(UPPER(n.name), '''') AS VARCHAR(1024)) LIKE :t OR ' +
          '  CAST(COALESCE(UPPER(n.version), '''') AS VARCHAR(1024)) LIKE :t OR ' +
          '  CAST(COALESCE(UPPER(n.filetimestamp), '''') AS VARCHAR(1024)) LIKE :t OR ' +
          '  CAST(COALESCE(UPPER(f.filename), '''') AS VARCHAR(1024)) LIKE :t OR ' +
          '  CAST(COALESCE(UPPER(f.name), '''') AS VARCHAR(1024)) LIKE :t OR ' +
          '  CAST(COALESCE(UPPER(f.version), '''') AS VARCHAR(1024)) LIKE :t OR ' +
          '  CAST(COALESCE(UPPER(f.filetimestamp), '''') AS VARCHAR(1024)) LIKE :t' +
          ')';
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
      FDataSet.ParamByName('t').AsString := '%' + AnsiUpperCase(FFilterText) + '%';

    if FFilterOperation > '' then
      FDataSet.ParamByName('op').AsString := FFilterOperation;

    FDataSet.Open;

    if (NK = 0) or (not FDataSet.Locate('namespacekey', TID2V(NK), [])) then
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

procedure TgdcNamespaceSyncController.ClearAll;
var
  q: TIBSQL;
begin
  Assert((FTr <> nil) and FTr.InTransaction);
  q := TIBSQL.Create(nil);
  try
    q.Transaction := FTr;
    q.SQL.Text :=
      'UPDATE at_namespace_sync SET operation = ''  '' WHERE operation <> ''  '' ';
    q.ExecQuery;
  finally
    q.Free;
  end;
end;

procedure TgdcNamespaceSyncController.CompareWithData(const ANSK: TID;
  const AFileName: String; const A3Way: Boolean);
var
  NS: TgdcNamespace;
  NSO: TgdcNamespaceObject;
  Tr: TIBTransaction;
  Parser: TYAMLParser;
  Mapping, MObject: TYAMLMapping;
  Objects, UsesNS: TYAMLSequence;
  J: Integer;
  NSID: TID;
  Obj: TgdcBase;
  C: TPersistentClass;
  HSL: TStringList;
  q, qList, qUpdate: TIBSQL;
  R: TRUID;
  SRUID, SName: String;
  CharReplace: LongBool;
begin
  Assert(gdcBaseManager <> nil);

  Tr := TIBTransaction.Create(nil);
  NS := TgdcNamespace.Create(nil);
  NSO := TgdcNamespaceObject.Create(nil);
  HSL := TStringList.Create;
  try
    Tr.DefaultDatabase := gdcBaseManager.Database;
    Tr.StartTransaction;

    NS.Transaction := Tr;
    NS.ReadTransaction := Tr;
    NS.SubSet := 'ByID';
    NS.ID := ANSK;
    NS.Open;

    if NS.EOF then
    begin
      Parser := TYAMLParser.Create;
      try
        Parser.Parse(AFileName, CharReplace);

        if (Parser.YAMLStream.Count = 0)
          or ((Parser.YAMLStream[0] as TyamlDocument).Count = 0)
          or (not ((Parser.YAMLStream[0] as TyamlDocument)[0] is TyamlMapping)) then
        begin
          raise Exception.Create('Invalid YAML stream.');
        end;

        Mapping := (Parser.YAMLStream[0] as TyamlDocument)[0] as TyamlMapping;

        if Mapping.ReadString('StructureVersion') <> '1.0' then
          raise Exception.Create('Unsupported YAML stream version.');

        NS.Close;
        NS.ID := gdcBaseManager.GetIDByRUIDString(Mapping.ReadString('Properties\RUID'));
        NS.Open;

        if NS.EOF then
        begin
          NS.BaseState := NS.BaseState + [sLoadFromStream];
          NS.StreamXID := StrToRUID(Mapping.ReadString('Properties\RUID')).XID;
          NS.StreamDBID := StrToRUID(Mapping.ReadString('Properties\RUID')).DBID;

          NS.Insert;
          NS.FieldByName('name').AsString := Mapping.ReadString('Properties\Name', 255);
          NS.FieldByName('caption').AsString := Mapping.ReadString('Properties\Caption', 255);
          NS.FieldByName('version').AsString := Mapping.ReadString('Properties\Version', 20);
          NS.FieldByName('dbversion').AsString := Mapping.ReadString('Properties\DBversion', 20);
          NS.FieldByName('optional').AsInteger := Mapping.ReadInteger('Properties\Optional', 0);
          NS.FieldByName('internal').AsInteger := Mapping.ReadInteger('Properties\Internal', 1);
          NS.FieldByName('comment').AsString := Mapping.ReadString('Properties\Comment');
          NS.FieldByName('filetimestamp').AsDateTime := gd_common_functions.GetFileLastWrite(AFileName);
          if NS.FieldByName('filetimestamp').AsDateTime > Now then
            NS.FieldByName('filetimestamp').AsDateTime := Now;
          NS.FieldByName('filename').AsString := System.Copy(AFileName, 1, 255);
          NS.FieldByName('md5').AsString := Mapping.ReadString('Properties\MD5');
          NS.Post;

          if Mapping.FindByName('Objects') is TYAMLSequence then
          begin
            Objects := Mapping.FindByName('Objects') as TYAMLSequence;

            NSO.Transaction := Tr;
            NSO.ReadTransaction := Tr;
            NSO.BaseState := NS.BaseState + [sLoadFromStream];
            NSO.SubSet := 'All';
            NSO.Open;

            for J := 0 to Objects.Count - 1 do
            begin
              if not (Objects[J] is TYAMLMapping) then
                raise Exception.Create('Invalid YAML stream.');

              MObject := Objects[J] as TYAMLMapping;

              C := GetClass(MObject.ReadString('Properties\Class'));

              if (C = nil) or (not C.InheritsFrom(TgdcBase)) then
                continue;

              Obj := CgdcBase(C).Create(nil);
              try
                if not Obj.CheckSubType(MObject.ReadString('Properties\SubType')) then
                  continue;

                Obj.SubType := MObject.ReadString('Properties\SubType');
                Obj.SubSet := 'ByID';
                Obj.ID := gdcBaseManager.GetIDByRUIDString(MObject.ReadString('Properties\RUID'), Tr);
                Obj.Open;

                if not Obj.EOF then
                begin
                  NSO.Insert;
                  SetTID(NSO.FieldByName('namespacekey'), NS.ID);
                  NSO.FieldByName('objectname').AsString := Obj.ObjectName;
                  NSO.FieldByName('objectclass').AsString := Obj.ClassName;
                  NSO.FieldByName('subtype').AsString := Obj.SubType;
                  SetTID(NSO.FieldByName('xid'), Obj.GetRUID.XID);
                  NSO.FieldByName('dbid').AsInteger := Obj.GetRUID.DBID;
                  NSO.FieldByName('alwaysoverwrite').AsInteger :=
                    MObject.ReadInteger('Properties\AlwaysOverwrite');
                  NSO.FieldByName('dontremove').AsInteger :=
                    MObject.ReadInteger('Properties\DontRemove');
                  NSO.FieldByName('includesiblings').AsInteger :=
                    MObject.ReadInteger('Properties\IncludeSiblings');
                  if Obj.FindField('editiondate') <> nil then
                  begin
                    NSO.FieldByName('modified').AsDateTime := Obj.FieldByName('editiondate').AsDateTime;
                    NSO.FieldByName('curr_modified').AsDateTime := Obj.FieldByName('editiondate').AsDateTime;
                  end;
                  NSO.Post;

                  if MObject.ReadString('Properties\HeadObject') > '' then
                    HSL.Add(TID2S(NSO.ID) + '=' + MObject.ReadString('Properties\HeadObject'));
                end;
              finally
                Obj.Free;
              end;
            end;

            if HSL.Count > 0 then
            begin
              qList := TIBSQL.Create(nil);
              qUpdate := TIBSQL.Create(nil);
              try
                qList.Transaction := Tr;
                qList.SQL.Text :=
                  'SELECT id FROM at_object WHERE namespacekey = :nsk ' +
                  ' AND xid = :xid AND dbid = :dbid';

                qUpdate.Transaction := Tr;
                qUpdate.SQL.Text :=
                  'UPDATE at_object SET headobjectkey = :ho ' +
                  'WHERE id = :id';

                for J := 0 to HSL.Count - 1 do
                begin
                  R := StrToRUID(HSL.Values[HSL.Names[J]]);

                  qList.Close;
                  SetTID(qList.ParamByName('nsk'), NS.ID);
                  SetTID(qList.ParamByName('xid'), R.XID);
                  qList.ParamByName('dbid').AsInteger := R.DBID;
                  qList.ExecQuery;

                  if not qList.EOF then
                  begin
                    SetTID(qUpdate.ParamByName('ho'), qList.Fields[0]);
                    qUpdate.ParamByName('id').AsString := HSL.Names[J];
                    qUpdate.ExecQuery;
                  end;
                end;
              finally
                qList.Free;
                qUpdate.Free;
              end;
            end;
          end;

          if Mapping.FindByName('Uses') is TYAMLSequence then
          begin
            UsesNS := Mapping.FindByName('Uses') as TYAMLSequence;
            q := TIBSQL.Create(nil);
            try
              q.Transaction := Tr;
              q.SQL.Text :=
                'INSERT INTO at_namespace_link (namespacekey, useskey) ' +
                'VALUES (:nsk, :uk)';

              for J := 0 to UsesNS.Count - 1 do
              begin
                if not (UsesNS[J] is TYAMLString) then
                  continue;

                ParseReferenceString(TYAMLString(UsesNS[J]).AsString, SRUID, SName);

                NSID := gdcBaseManager.GetIDByRUIDString(SRUID, Tr);
                if (NSID = -1) or (NSID = NS.ID) then
                  continue;

                SetTID(q.ParamByName('nsk'), NS.ID);
                SetTID(q.ParamByName('uk'), NSID);
                try
                  q.ExecQuery;
                except
                  on E: Exception do
                    DoLog(lmtError, E.Message);
                end;
              end;
            finally
              q.Free;
            end;
          end;
        end;
      finally
        Parser.Free;
      end;

      TgdcNamespace.UpdateCurrModified(Tr, NS.ID);
    end;

    NS.CompareWithData(AFileName, A3Way);

    NS.Close;
  finally
    HSL.Free;
    NSO.Free;
    NS.Free;

    if Tr.InTransaction then
      Tr.Rollback;
    Tr.Free;
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
    DoLog(lmtInfo, 'Удален файл ' + AFileName);

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

procedure TgdcNamespaceSyncController.DoLog(const AMessageType: TLogMessageType;
  const AMessage: String);
begin
  if Assigned(FOnLogMessage) then
    FOnLogMessage(AMessageType, AMessage);

  if Assigned(gdccClient) then
    case AMessageType of
      lmtInfo: gdccClient.AddLogRecord('ns_sync', AMessage, gdcc_lt_Info);
      lmtWarning: gdccClient.AddLogRecord('ns_sync', AMessage, gdcc_lt_Warning);
      lmtError: gdccClient.AddLogRecord('ns_sync', AMessage, gdcc_lt_Error);
    end;
end;

procedure TgdcNamespaceSyncController.EditNamespace(const ANSK: TID);
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

procedure TgdcNamespaceSyncController.GetDependentList(ASL: TStrings);
var
  q: TIBSQL;
  I, J, C: Integer;
  SL: TStringList;
begin
  Assert(ASL <> nil);
  Assert(FTr <> nil);
  Assert(FTr.InTransaction);

  SL := TStringList.Create;
  q := TIBSQL.Create(nil);
  try
    q.Transaction := FTr;
    q.SQL.Text :=
      'SELECT f.filename ' +
      'FROM ' +
      '  at_namespace_file f ' +
      '  JOIN at_namespace_sync s ON s.filename = f.filename ' +
      'WHERE ' +
      '  s.operation IN (''< '', ''<<'')';
    q.ExecQuery;
    while not q.EOF do
    begin
      if SL.IndexOf(q.Fields[0].AsString) = -1 then
        SL.Add(q.Fields[0].AsString)
      else
        DoLog(lmtWarning, 'ПИ "' + q.Fields[0].AsString + '" уже находится в списке загрузки.');
      q.Next;
    end;

    q.Close;
    q.SQL.Text :=
      'SELECT l.filename ' +
      'FROM ' +
      '  at_namespace_file f ' +
      '  JOIN at_namespace_file_link l ' +
      '    ON l.uses_xid = f.xid AND l.uses_dbid = f.dbid ' +
      '  JOIN at_namespace_sync s ' +
      '    ON s.filename = l.filename ' +
      'WHERE ' +
      '  f.filename = :filename ' +
      '  AND s.operation IN (''< '', ''<<'')';
    I := 0;
    C := 0;
    while I < SL.Count do
    begin
      q.ParamByName('filename').AsString := SL[I];
      q.ExecQuery;
      while not q.EOF do
      begin
        J := SL.IndexOf(q.Fields[0].AsString);
        if J = -1 then
          SL.Add(q.Fields[0].AsString)
        else if J < I then
        begin
          SL.Insert(I + 1, SL[J]);
          SL.Delete(J);
          Dec(I);
        end;
        q.Next;
      end;
      q.Close;
      Inc(I);

      if C > SL.Count * SL.Count * SL.Count / 2 then
        raise Exception.Create('Превышен внутренний лимит на количество итераций при построении списка ПИ. Возможны циклические ссылки.');
      Inc(C);
    end;

    ASL.Assign(SL);
  finally
    q.Free;
    SL.Free;
  end;
end;

function TgdcNamespaceSyncController.GetdsFileTree: TDataSet;
begin
  Result := FdsFileTree;
end;

function TgdcNamespaceSyncController.GetFiltered: Boolean;
begin
  Result := FFilterOnlyPackages
    or FFilterOnlyFiles
    or (FFilterText > '')
    or (FFilterOperation > '');
end;

procedure TgdcNamespaceSyncController.Init;
begin
  Assert(gdcBaseManager <> nil);
  Assert(IBLogin <> nil);

  if not IBLogin.IsIBUserAdmin then
    raise Exception.Create('Access denied.');

  if FTr <> nil then
  begin
    if FTr.InTransaction then
      FTr.Commit;
    FTr.StartTransaction;
    exit;
  end;

  FTr := TIBTransaction.Create(nil);
  FTr.Name := 'NSSyncTr';
  FTr.DefaultDatabase := gdcBaseManager.Database;
  FTr.Params.CommaText := 'read_committed,rec_version,nowait';
  FTr.StartTransaction;

  FqInsertFile := TIBSQL.Create(nil);
  FqInsertFile.Transaction := FTr;
  FqInsertFile.SQL.Text :=
    'INSERT INTO at_namespace_file ' +
    '  (filename, filetimestamp, filesize, name, caption, version, ' +
    '   dbversion, optional, internal, comment, xid, dbid, md5) ' +
    'VALUES ' +
    '  (:filename, :filetimestamp, :filesize, :name, :caption, :version, ' +
    '   :dbversion, :optional, :internal, :comment, :xid, :dbid, :md5)';

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
    '    (EXISTS (SELECT * FROM at_namespace n '#13#10 +
    '       WHERE n.id = s.namespacekey '#13#10 +
    '         AND n.changed <> 0) '#13#10 +
    '     OR '#13#10 +
    '     (EXISTS (SELECT * FROM at_namespace_sync s2 '#13#10 +
    '        JOIN at_namespace n ON n.id = s2.namespacekey '#13#10 +
    '        JOIN at_namespace_file f ON f.filename = s2.filename '#13#10 +
    '        WHERE '#13#10 +
//    '          n.filetimestamp > f.filetimestamp '#13#10 +
    '          TRUNC(RIGHT(n.version, POSITION(''.'', REVERSE(n.version)) - 1)) > '#13#10 +
    '            TRUNC(RIGHT(f.version, POSITION(''.'', REVERSE(f.version)) - 1)) '#13#10 +
    '          AND s2.namespacekey = s.namespacekey AND s2.filename = s.filename'#13#10 +
    '      )'#13#10 +
    '     ) '#13#10 +
    '    ) '#13#10 +
    '    AND (s.operation = ''  ''); '#13#10 +
    ' '#13#10 +
    '  UPDATE at_namespace_sync s SET s.operation = ''<<'' '#13#10 +
    '  WHERE '#13#10 +
    '   (EXISTS (SELECT * FROM at_namespace_sync s2 '#13#10 +
    '      JOIN at_namespace n ON n.id = s2.namespacekey '#13#10 +
    '      JOIN at_namespace_file f ON f.filename = s2.filename '#13#10 +
    '      WHERE  '#13#10 +
//    '        n.filetimestamp < f.filetimestamp '#13#10 +
    '          TRUNC(RIGHT(n.version, POSITION(''.'', REVERSE(n.version)) - 1)) < '#13#10 +
    '            TRUNC(RIGHT(f.version, POSITION(''.'', REVERSE(f.version)) - 1)) '#13#10 +
    '        AND s2.namespacekey = s.namespacekey AND s2.filename = s.filename'#13#10 +
    '      )'#13#10 +
    '    )'#13#10 +
    '    AND (s.operation = ''  ''); '#13#10 +
    ' '#13#10 +
    '  UPDATE at_namespace_sync s SET s.operation = ''? '' '#13#10 +
    '  WHERE '#13#10 +
    '   (EXISTS (SELECT * FROM at_namespace_sync s2 '#13#10 +
    '      JOIN at_namespace n ON n.id = s2.namespacekey '#13#10 +
    '      JOIN at_namespace_file f ON f.filename = s2.filename '#13#10 +
    '      WHERE '#13#10 +
//    '        n.filetimestamp < f.filetimestamp '#13#10 +
    '        TRUNC(RIGHT(n.version, POSITION(''.'', REVERSE(n.version)) - 1)) < '#13#10 +
    '          TRUNC(RIGHT(f.version, POSITION(''.'', REVERSE(f.version)) - 1)) '#13#10 +
    '        AND s2.namespacekey = s.namespacekey AND s2.filename = s.filename'#13#10 +
    '      )'#13#10 +
    '    )'#13#10 +
    '    AND (s.operation = ''>>''); '#13#10 +
    ' '#13#10 +
    '  UPDATE at_namespace_sync s SET s.operation = ''? '' '#13#10 +
    '  WHERE '#13#10 +
    '   (EXISTS (SELECT * FROM at_namespace_sync s2 '#13#10 +
    '      JOIN at_namespace n ON n.id = s2.namespacekey '#13#10 +
    '      JOIN at_namespace_file f ON f.filename = s2.filename '#13#10 +
    '      WHERE n.filetimestamp IS NULL '#13#10 +
    '        AND s2.namespacekey = s.namespacekey AND s2.filename = s.filename'#13#10 +
    '      )'#13#10 +
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
    '  UPDATE at_namespace_sync s SET s.operation = ''? '' '#13#10 +
    '  WHERE s.operation = ''  '' AND s.namespacekey IS NOT NULL '#13#10 +
    '    AND s.filename IS NOT NULL '#13#10 +
    '    AND (SELECT COALESCE(f.md5, '''') FROM at_namespace_file f WHERE f.filename = s.filename) > '''' '#13#10 +
    '    AND (SELECT COALESCE(s2.md5, '''') FROM at_namespace s2 WHERE s2.id = s.namespacekey) > '''' '#13#10 +
    '    AND (SELECT f.md5 FROM at_namespace_file f WHERE f.filename = s.filename) '#13#10 +
    '      IS DISTINCT FROM (SELECT s2.md5 FROM at_namespace s2 WHERE s2.id = s.namespacekey); '#13#10 +
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
    '  AND filename IS NOT DISTINCT FROM :fn ' +
    '  AND operation IS DISTINCT FROM :op';

  {
  FqDependentList := TIBSQL.Create(nil);
  FqDependentList.Transaction := FTr;
  FqDependentList.SQL.Text :=
    'WITH RECURSIVE '#13#10 +
    '  ns_tree AS ( '#13#10 +
    '    SELECT '#13#10 +
    '      n.filename AS headname, '#13#10 +
    '      0 AS usescount, '#13#10 +
    '      -- CAST((n.xid || ''_'' || n.dbid) AS VARCHAR(1024)) AS path, '#13#10 +
    '      n.filename '#13#10 +
    '    FROM '#13#10 +
    '      at_namespace_file n '#13#10 +
    '        JOIN at_namespace_sync s ON s.filename = n.filename '#13#10 +
    '          AND s.operation IN (''<<'', ''< '')'#13#10 +
    ' '#13#10 +
    '    UNION ALL '#13#10 +
    ' '#13#10 +
    '    SELECT '#13#10 +
    '      t.headname, '#13#10 +
    '      (t.usescount + 1) AS usescount, '#13#10 +
    '      -- (t.path || ''-'' || n.xid || ''_'' || n.dbid) AS path, '#13#10 +
    '      n.filename '#13#10 +
    '    FROM '#13#10 +
    '      ns_tree t '#13#10 +
    '      JOIN at_namespace_file_link l '#13#10 +
    '        ON l.filename = t.filename '#13#10 +
    '      JOIN at_namespace_file n '#13#10 +
    '        ON l.uses_xid = n.xid and l.uses_dbid = n.dbid '#13#10 +
    '      JOIN at_namespace_sync s ON s.filename = n.filename '#13#10 +
    '        AND s.operation IN (''<<'', ''< '')'#13#10 +
    '    WHERE '#13#10 +
    '      -- POSITION ((n.xid || ''_'' || n.dbid) IN t.path) = 0 '#13#10 +
    '      t.usescount < 40 '#13#10 +
    '    ) '#13#10 +
    'SELECT '#13#10 +
    '  t.headname, sum(t.usescount) '#13#10 +
    'FROM '#13#10 +
    '  ns_tree t '#13#10 +
    'GROUP BY '#13#10 +
    '  1 '#13#10 +
    'ORDER BY '#13#10 +
    '  2';
  }

  FqUsesList := TIBSQL.Create(nil);
  FqUsesList.Transaction := FTr;
  FqUsesList.SQL.Text :=
    'SELECT s.filename, s.namespacekey ' +
    'FROM at_namespace_file f ' +
    '  JOIN at_namespace_file_link l ' +
    '    ON l.uses_xid = f.xid AND l.uses_dbid = f.dbid ' +
    '  JOIN at_namespace_sync s ' +
    '    ON s.filename = f.filename ' +
    'WHERE ' +
    '  l.filename = :filename ';
  {
    'WITH RECURSIVE '#13#10 +
    '  ns_tree AS ( '#13#10 +
    '    SELECT '#13#10 +
    '      f.filename, '#13#10 +
    '      0 AS usescount, '#13#10 +
    '      -- CAST((f.xid || ''_'' || f.dbid) AS VARCHAR(1024)) AS path, '#13#10 +
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
    ' '#13#10 +
    '    UNION ALL '#13#10 +
    ' '#13#10 +
    '    SELECT '#13#10 +
    '      f.filename, '#13#10 +
    '      (t.usescount + 1) AS usescount,'#13#10 +
    '      -- (t.path || ''-'' || f.xid || ''_'' || f.dbid) AS path,'#13#10 +
    '      l.uses_xid, '#13#10 +
    '      l.uses_dbid '#13#10 +
    '    FROM '#13#10 +
    '      ns_tree t '#13#10 +
    '      JOIN at_namespace_file f '#13#10 +
    '        ON t.uses_xid = f.xid AND t.uses_dbid = f.dbid '#13#10 +
    '      JOIN at_namespace_file_link l '#13#10 +
    '        ON l.filename = f.filename '#13#10 +
    '    WHERE '#13#10 +
    '      -- POSITION ((f.xid || ''_'' || f.dbid) IN t.path) = 0)'#13#10 +
    '      t.usescount < 40)'#13#10 +
    ' '#13#10 +
    'SELECT '#13#10 +
    '  t.filename, s.namespacekey '#13#10 +
    'FROM '#13#10 +
    '  ns_tree t '#13#10 +
    '  JOIN at_namespace_sync s ON t.filename = s.filename '#13#10 +
    'WHERE '#13#10 +
    '  s.operation <> ''! '' '#13#10 +
    ' '#13#10 +
    'UNION '#13#10 +
    ' '#13#10 +
    'SELECT '#13#10 +
    '  f.filename, s.namespacekey '#13#10 +
    'FROM '#13#10 +
    '  ns_tree t '#13#10 +
    '  JOIN at_namespace_file f '#13#10 +
    '    ON f.xid = t.uses_xid AND f.dbid = t.uses_dbid '#13#10 +
    '  LEFT JOIN at_namespace_file_link l '#13#10 +
    '    ON l.filename = f.filename '#13#10 +
    '  JOIN at_namespace_sync s ON f.filename = s.filename '#13#10 +
    'WHERE '#13#10 +
    '  l.filename IS NULL '#13#10 +
    '  AND '#13#10 +
    '  s.operation <> ''! '' ';
  }
end;

procedure TgdcNamespaceSyncController.Scan(const ACalculateStatus: Boolean;
  const AClearUnexisted: Boolean;const ARecursive: Boolean; const ASaveDir: Boolean);
var
  SL: TStringList;
  I: Integer;
  LO : TFileListOptions;
begin
  Init;

  if FUpdateCurrModified then
  begin
    DoLog(lmtInfo, 'Обновление даты изменения объекта...');
    TgdcNamespace.UpdateCurrModified(nil);
  end;

  if ARecursive then LO :=  [flFullNames , flRecursive]
  else LO :=[flFullNames];

  SL := TStringList.Create;
  try
    if AdvBuildFileList(IncludeTrailingBackslash(FDirectory) + '*.yml',
      faAnyFile, SL, amAny, LO, '*.*', nil) then
    begin
      for I := 0 to SL.Count - 1 do
      try
         AnalyzeFile(SL[I]);
      except
        on E: Exception do
        begin
          DoLog(lmtError, 'Ошибка в процессе обработки файла ' + SL[I]);
          DoLog(lmtError, E.Message);
        end;
      end;
    end;
  finally
    SL.Free;
  end;

  if ACalculateStatus then
  begin
    DoLog(lmtInfo, 'Определение статуса...');
    FqFillSync.ExecQuery;

    if AClearUnexisted then
    begin
      Fq.Close;
      Fq.SQL.Text :=
        'UPDATE at_namespace_sync SET operation = ''  '' ' +
        'WHERE operation IN (''> '', ''< '') ';
      Fq.ExecQuery;  
    end;
  end else
  begin
    Fq.Close;
    Fq.SQL.Text :=
      'EXECUTE BLOCK '#13#10 +
      'AS '#13#10 +
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
      '    VALUES (j.filename, ''  ''); '#13#10 +
      'END';
    Fq.ExecQuery;
  end;

  if ASaveDir then
    gd_GlobalParams.NamespacePath := FDirectory;

  DoLog(lmtInfo, 'Выполнено сравнение с каталогом: ' + FDirectory);
end;

procedure TgdcNamespaceSyncController.SetOperation(const AnOp: String; const AScanUsesList: Boolean = True);
var
  SL, SLDone: TStringList;
begin
  Assert(FDataSet <> nil);
  Assert(not FDataSet.IsEmpty);

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
      SetTID(FqUpdateOperation.ParamByName('nk'), FDataSet.FieldByName('namespacekey'));

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

    if (AnOp = '<<') and AScanUsesList then
    begin
      SL := TStringList.Create;
      SLDone := TStringList.Create;
      try
        SLDone.Sorted := True;
        SLDone.Duplicates := dupError;

        SL.Add(FDataSet.FieldByName('filename').AsString);

        while SL.Count > 0 do
        begin
          FqUsesList.ParamByName('filename').AsString := SL[0];
          FqUsesList.ExecQuery;
          while not FqUsesList.EOF do
          begin
            if FqUsesList.FieldByName('namespacekey').IsNull then
            begin
              FqUpdateOperation.ParamByName('op').AsString := '< ';
              FqUpdateOperation.ParamByName('nk').Clear;
            end else
            begin
              FqUpdateOperation.ParamByName('op').AsString := '<<';
              SetTID(FqUpdateOperation.ParamByName('nk'), FqUsesList.FieldByName('namespacekey'));
            end;
            FqUpdateOperation.ParamByName('fn').AsString := FqUsesList.FieldByName('filename').AsString;
            FqUpdateOperation.ExecQuery;

            if SLDone.IndexOf(FqUsesList.FieldByName('filename').AsString) = -1 then
            begin
              SLDone.Add(FqUsesList.FieldByName('filename').AsString);
              if SL.IndexOf(FqUsesList.FieldByName('filename').AsString) = -1 then
                SL.Add(FqUsesList.FieldByName('filename').AsString);
            end;

            FqUsesList.Next;
          end;
          FqUsesList.Close;
          SL.Delete(0);
        end;
      finally
        SLDone.Free;
        SL.Free;
      end;
    end;
  end;
end;

procedure TgdcNamespaceSyncController.ShowChanged;
begin
  Assert(FDataSet <> nil);
  Assert(not FDataSet.EOF);
  Assert(not FDataSet.FieldByName('namespacekey').IsNull);

  with TfrmSQLEditorSyn.Create(nil) do
  try
    ShowSQL(
      'SELECT o.* FROM at_object o '#13#10 +
      'WHERE o.namespacekey = ' + FDataSet.FieldByName('namespacekey').AsString + #13#10 +
      '  AND o.modified <> o.curr_modified'#13#10 +
      'ORDER BY o.objectpos ASC');
  finally
    Free;
  end;
end;

procedure TgdcNamespaceSyncController.Sync;
var
  NS: TgdcNamespace;
  SL: TStringList;
  LoadList: TStringList;
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

    actSaveObjects.Checked := mSaveList.Lines.Count > 0;

    LoadList := TStringList.Create;
    try
      GetDependentList(LoadList);
      mLoadList.Lines.Assign(LoadList);
      lLoadRecords.Caption := 'Выбрано для загрузки из файлов: ' + IntToStr(LoadList.Count);
    finally
      LoadList.Free;
    end;

    actLoadObjects.Checked := mLoadList.Lines.Count > 0;

    if ShowModal = mrOk then
    begin
      if actSaveObjects.Checked then
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
            NS.ID := GetTID(Fq.FieldByName('id'));
            NS.Open;
            if (not NS.EOF) and NS.SaveNamespaceToFile(Fq.FieldByName('filename').AsString, chbxIncVersion.Checked) then
              DoLog(lmtInfo, 'Пространство имен "' + NS.ObjectName + '" записано в файл: ' +
                Fq.FieldByName('filename').AsString);
            Fq.Next;
          end;

          Fq.Close;
        finally
          NS.Free;
        end;                               
      end;

      if actLoadObjects.Checked then
      begin
        SL := TStringList.Create;
        try
          GetDependentList(SL);
          TgdcNamespaceLoader.LoadDelayed(SL, chbxAlwaysOverwrite.Checked,
            chbxDontRemove.Checked, chbxTerminate.Checked,
            chbxIgnoreMissedFields.Checked, chbxUnMethod.Checked);
        finally
          SL.Free;
        end;
      end;
    end;
  finally
    Free;
  end;
end;

procedure TgdcNamespaceSyncController.SyncSilent(const ATerminate: Boolean);
var
  SL: TStringList;
begin
  try
    SL := TStringList.Create;
    try
      GetDependentList(SL);
      with TgdcNamespaceLoader.Create do
      try
        LoadDelayed(SL, True, False, ATerminate, True, True);
      finally
        Free;
      end;
    finally
      SL.Free;
    end;
  except
    on E: Exception do
    begin
      AddMistake(E.Message);
      raise;
    end;
  end;
end;

end.
