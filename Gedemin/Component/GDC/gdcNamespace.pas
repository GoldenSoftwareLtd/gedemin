
unit gdcNamespace;

interface

uses                        
  SysUtils, gdcBase, gdcBaseInterface, Classes, gd_ClassList,
  gd_createable_form, at_classes, IBSQL, db, yaml_writer, yaml_parser,
  IBDatabase, gd_security, dbgrids, gd_KeyAssoc, contnrs, IB, gsNSObjects;

type
  TgdcNamespace = class(TgdcBase)
  private
    procedure CheckIncludesiblings;

  protected
    function GetOrderClause: String; override;
    procedure _DoOnNewRecord; override;
    procedure GetWhereClauseConditions(S: TStrings); override;
    procedure DoLoadNamespace(ANamespaceList: TStringList;
      const AnAlwaysoverwrite: Boolean = False; const ADontRemove: Boolean = False);

  public
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetSubSetList: String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;

    class procedure WriteObject(AgdcObject: TgdcBase; AWriter: TyamlWriter;
      const AHeadObject: String; AnAlwaysoverwrite: Boolean = True;
      ADontremove: Boolean = False; AnIncludesiblings: Boolean = False; const ATr: TIBTransaction = nil);
    class function LoadObject(AnObj: TgdcBase; AMapping: TyamlMapping;
      UpdateList: TObjectList; ATr: TIBTransaction;
      const AnAlwaysoverwrite: Boolean = False): Boolean;
    class procedure ScanDirectory(ADataSet: TDataSet; const APath: String;
      Log: TNSLog);

    class procedure SetNamespaceForObject(AnObject: TgdcBase;
      ANSL: TgdKeyStringAssoc; ATr: TIBTransaction = nil);
    class procedure SetObjectLink(AnObject: TgdcBase; ADataSet: TDataSet;
      ATr: TIBTransaction);
    class procedure AddObject(ANamespacekey: Integer; const AName: String;
      const AClass: String; const ASubType: String;
      xid, dbid: Integer; ATr: TIBTransaction; AnAlwaysoverwrite: Integer = 1;
      ADontremove: Integer = 0; AnIncludesiblings: Integer = 0);
    class function LoadNSInfo(const Path: String; ATr: TIBTransaction): Integer;  

    procedure AddObject2(AnObject: TgdcBase; AnUL: TObjectList;
      const AHeadObjectRUID: String = ''; AnAlwaysOverwrite: Integer = 1;
      ADontRemove: Integer = 0; AnIncludeSiblings: Integer = 0);
    procedure DeleteObject(xid, dbid: Integer; RemoveObj: Boolean = True);
    procedure InstallPackages(ANSList: TStringList;
      const AnAlwaysoverwrite: Boolean = False; const ADontremove: Boolean = False);
    function MakePos: Boolean;
    procedure LoadFromFile(const AFileName: String = ''); override;
    procedure SaveNamespaceToStream(St: TStream);
    procedure SaveNamespaceToFile(const AFileName: String = '');
    procedure CompareWithData(const AFileName: String);
    procedure DeleteNamespaceWithObjects;
  end;

  TgdcNamespaceObject = class(TgdcBase)
  protected
    function GetOrderClause: String; override;
    procedure GetWhereClauseConditions(S: TStrings); override;

  public
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetSubSetList: String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
  end;

  function GetReferenceString(const ARUID: String; const AName: String): String;
  function ParseReferenceString(const AStr: String; out ARUID: String; out AName: String): Boolean;

  procedure Register;

implementation

uses
  Windows, Controls, ComCtrls, gdc_dlgNamespacePos_unit, gdc_dlgNamespace_unit,
  gdc_frmNamespace_unit, at_sql_parser, jclStrings, gdcTree, yaml_common,
  gd_common_functions, prp_ScriptComparer_unit, gdc_dlgNamespaceObjectPos_unit,
  jclUnicode, at_frmSyncNamespace_unit, jclFileUtils, gd_directories_const,
  gd_FileList_unit, gdcClasses, at_sql_metadata, gdcConstants, at_frmSQLProcess,
  Graphics, IBErrorCodes, Storages, gdcMetadata, at_sql_setup, gsDesktopManager,
  at_dlgLoadNamespacePackages_unit, at_Classes_body;

type
  TNSFound = (nsfNone, nsfByName, nsfByRUID);

  TgdcReferenceUpdate = class(TObject)
  public
    FieldName: String;
    FullClass: TgdcFullClass;
    ID: TID;
    RefRUID: String;
    SQL: String;
  end;

  TgdcHeadObjectUpdate = class(TObject)
  public
    NamespaceKey: Integer;
    RUID: String;
    RefRUID: String;
  end;

procedure Register;
begin
  RegisterComponents('gdcNamespace', [TgdcNamespace, TgdcNamespaceObject]);
end;

function GetReferenceString(const ARUID: String; const AName: String): String;
begin
  Result := ARUID + ' ' + AName;
end;

function ParseReferenceString(const AStr: String;
  out ARUID: String; out AName: String): Boolean;
var
  P: Integer;
begin
  P := Pos(' ', AStr);
  if P = 0 then
  begin
    ARUID := AStr;
    AName := '';
  end else
  begin
    ARUID := System.Copy(AStr, 1, P - 1);
    AName := System.Copy(AStr, P + 1, MaxInt);
  end;
  Result := CheckRUID(ARUID);
end;

function CompareFolder(List: TStringList; Index1, Index2: Integer): Integer;
begin
  Result := AnsiCompareText(
    ExtractFilePath((List.Objects[Index1] as TgsNSNode).FileName),
    ExtractFilePath((List.Objects[Index2] as TgsNSNode).FileName));
end;

class function TgdcNamespace.GetDialogFormClassName(const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgNamespace';
end;

class function TgdcNamespace.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'at_namespace';
end;

class function TgdcNamespace.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'name';
end;

class function TgdcNamespace.GetViewFormClassName(const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmNamespace';
end;

class procedure TgdcNamespace.WriteObject(AgdcObject: TgdcBase; AWriter: TyamlWriter;
  const AHeadObject: String; AnAlwaysoverwrite: Boolean = True;
  ADontremove: Boolean = False; AnIncludesiblings: Boolean = False; const ATr: TIBTransaction = nil);

  procedure WriteSet(AObj: TgdcBase; AWriter: TyamlWriter);
  var
    I, K: Integer;
    F, FD: TatRelationField;
    AddedTitle: Boolean;
    q: TIBSQL;
    RL, LT: TStrings;
  begin
    q := TIBSQL.Create(nil);
    try
      if (ATr = nil) or (not ATr.InTransaction) then
        q.Transaction := gdcBaseManager.ReadTransaction
      else
        q.Transaction := ATr;
      AddedTitle := False;

      RL := TStringList.Create;
      try
        if AObj.GetListTable(AObj.SubType) <> '' then
          RL.Add(AnsiUpperCase(AObj.GetListTable(AObj.SubType)));

        LT := TStringList.Create;
        try
          (LT as TStringList).Duplicates := dupIgnore;
          GetTablesName(AObj.SelectSQL.Text, LT);
          for I := 0 to LT.Count - 1 do
          begin
            if (RL.IndexOf(LT[I]) = -1)
              and AObj.ClassType.InheritsFrom(GetBaseClassForRelation(LT[I]).gdClass)
            then
              RL.Add(LT[I]);
          end;
        finally
          LT.Free;
        end;

        for I := 0 to atDatabase.PrimaryKeys.Count - 1 do
          with atDatabase.PrimaryKeys[I] do
          if ConstraintFields.Count > 1 then
          begin
            F := nil;
            FD := nil;

            for K := 0 to RL.Count - 1 do
            begin
              if (ConstraintFields[0].References <> nil) and
                (AnsiCompareText(ConstraintFields[0].References.RelationName,
                 RL[K]) = 0)
              then
              begin
                F := ConstraintFields[0];
                Break;
              end;
            end;

            if not Assigned(F) then
              continue;

            for K := 1 to ConstraintFields.Count - 1 do
            begin
              if (ConstraintFields[K].References <> nil) and
                 (ConstraintFields[K] <> F) and (FD = nil)
              then
              begin
                FD := ConstraintFields[K];
                Break;
              end else

              if (ConstraintFields[K].References <> nil) and
                 (ConstraintFields[K] <> F) and (FD <> nil)
              then
              begin
                continue;
              end;
            end;

            if not Assigned(FD) then
              continue;

            q.Close;
            q.SQL.Text := 'SELECT ' + FD.FieldName +
              ' FROM ' + FD.Relation.RelationName +
              ' WHERE ' + F.FieldName + ' = :rf';
            q.ParamByName('rf').AsString := AObj.FieldByName(
              F.ReferencesField.FieldName).AsString;
            q.ExecQuery;

            if q.RecordCount > 0 then
            begin
              if not AddedTitle then
              begin
                AddedTitle := True;
                AWriter.DecIndent;
                AWriter.StartNewLine;
                AWriter.WriteKey('Set');
                AWriter.IncIndent;
              end;

              AWriter.StartNewLine;
              AWriter.WriteSequenceIndicator;
              AWriter.IncIndent;
              try
                AWriter.StartNewLine;
                AWriter.WriteKey('Table');
                AWriter.WriteText(FD.Relation.RelationName, qSingleQuoted);

                AWriter.StartNewLine;
                AWriter.WriteKey('Items');

                AWriter.IncIndent;
                try
                  while not q.Eof do
                  begin
                    AWriter.StartNewLine;
                    AWriter.WriteSequenceIndicator;
                    AWriter.WriteString(gdcBaseManager.GetRUIDStringByID(
                      q.Fields[0].AsInteger, AObj.Transaction));
                    q.Next;
                  end;
                finally
                  AWriter.DecIndent;
                end;
              finally
                AWriter.DecIndent;
              end;
            end;
          end;
      finally
        RL.Free;
      end;
    finally
      q.Free;
    end;
  end;

const
  PassFieldName =
    ';ID;CREATORKEY;EDITORKEY;ACHAG;AVIEW;AFULL;LB;RB;RESERVED' +
    ';ENTEREDPARAMS;BREAKPOINTS;EDITORSTATE;TESTRESULT;' +
    'RDB$PROCEDURE_BLR;RDB$TRIGGER_BLR;RDB$VIEW_BLR;LASTEXTIME;';
var
  I, L: Integer;
  R: TatRelation;
  F: TField;
  FN: String;
  RF: TatRelationField;
  FK: TatForeignKey;
  RN: String;
  Obj: TgdcBase;
  C: TgdcFullClass;
  BlobStream: TStream;
  TempS: String;
  Flag: Boolean;
begin
  Assert(gdcBaseManager <> nil);
  Assert(AgdcObject <> nil);
  Assert(not AgdcObject.EOF);
  Assert(atDatabase <> nil);

  AWriter.WriteKey('Properties');
  AWriter.IncIndent;
  AWriter.StartNewLine;
  AWriter.WriteKey('Class');
  AWriter.WriteText(AgdcObject.Classname, qSingleQuoted);
  if AgdcObject.SubType > '' then
  begin
    AWriter.StartNewLine;
    AWriter.WriteKey('SubType');
    AWriter.WriteText(AgdcObject.SubType, qSingleQuoted);
  end;
  AWriter.StartNewLine;
  AWriter.WriteKey('RUID');
  AWriter.WriteString(gdcBaseManager.GetRUIDStringByID(AgdcObject.ID));
  AWriter.StartNewLine;
  AWriter.WriteKey('AlwaysOverwrite');
  AWriter.WriteBoolean(AnAlwaysoverwrite);
  AWriter.StartNewLine;
  AWriter.WriteKey('DontRemove');
  AWriter.WriteBoolean(ADontremove);
  AWriter.StartNewLine;
  AWriter.WriteKey('IncludeSiblings');
  AWriter.WriteBoolean(AnIncludesiblings);
  if AHeadObject <> '' then
  begin
    AWriter.StartNewLine;
    AWriter.WriteKey('HeadObject');
    AWriter.WriteString(AHeadObject);
  end;
  AWriter.DecIndent;
  AWriter.StartNewLine;
  AWriter.WriteKey('Fields');
  AWriter.IncIndent;

  try
    for I := 0 to AgdcObject.Fields.Count - 1 do
    begin
      F := AgdcObject.Fields[I];

      if StrIPos(F.FieldName, PassFieldName) > 0 then
        continue;

      FN := '';

      if (F.Origin > '') and not F.IsNull then
      begin
        L := 0;
        RN := '';
        while F.Origin[L] <> '.' do
        begin
          if F.Origin[L] <> '"' then
            RN := RN + F.Origin[L];
          Inc(L);
        end;

        if RN > '' then
        begin
          R := atDatabase.Relations.ByRelationName(RN);
          if Assigned(R) then
          begin
            RF := R.RelationFields.ByFieldName(F.FieldName);
            if Assigned(RF) then
            begin
              if Assigned(RF.CrossRelation) then
              begin
                continue;
              end else
              if Assigned(RF.ForeignKey) then
              begin
                FK := RF.ForeignKey;

                if FK.IsSimpleKey and Assigned(FK.Relation.PrimaryKey)
                  and (FK.Relation.PrimaryKey.ConstraintFields.Count = 1)
                  and (FK.ConstraintField = FK.Relation.PrimaryKey.ConstraintFields[0])
                then
                  continue;

                C := GetBaseClassForRelation(RF.References.RelationName);
                if C.gdClass <> nil then
                begin
                  Obj := C.gdClass.CreateWithID(nil,
                    nil,
                    nil,
                    F.AsInteger,
                    C.SubType);
                  try
                    Obj.Open;
                    if not Obj.EOF then
                    begin
                      if Obj is TgdcTree then
                        FN := TgdcTree(Obj).GetPath
                      else
                        FN := Obj.ObjectName;
                    end;
                  finally
                    Obj.Free;
                  end;
                end;

                AWriter.StartNewLine;
                AWriter.WriteKey(F.FieldName);
                AWriter.WriteText(GetReferenceString(
                  gdcBaseManager.GetRUIDStringByID(
                    F.AsInteger, AgdcObject.Transaction),
                  FN), qSingleQuoted);
                continue;
              end;
            end;
          end;
        end;
      end;

      AWriter.StartNewLine;
      AWriter.WriteKey(F.FieldName);
      if not F.IsNull then
      begin
        case F.DataType of
          ftDate: AWriter.WriteDate(F.AsDateTime);
          ftDateTime, ftTime: AWriter.WriteTimestamp(F.AsDateTime);
          ftMemo: AWriter.WriteText(F.AsString, qPlain, sLiteral);
          ftInteger, ftSmallint, ftWord: AWriter.WriteInteger(F.AsInteger);
          ftBoolean: AWriter.WriteBoolean(F.AsBoolean);
          ftFloat: AWriter.WriteFloat(F.AsFloat);
          ftCurrency: AWriter.WriteCurrency(F.AsCurrency);
          ftLargeint: AWriter.WriteString(F.AsString);
          ftBlob, ftGraphic:
          begin
            Flag := False;

            if
              (AgdcObject.ClassName = 'TgdcStorageValue')
              and
              (
                (AgdcObject.FieldByName('name').AsString = 'dfm')
                or
                CheckRUID(AgdcObject.FieldByName('name').AsString)
                or
                (atDatabase.Relations.ByRelationName(AgdcObject.FieldByName('name').AsString) <> nil)
              ) then
            begin
              TempS := F.AsString;
              if TryObjectBinaryToText(TempS) then
              begin
                AWriter.WriteText(TempS, qPlain, sLiteral);
                Flag := True;
              end;
            end else if
              (AgdcObject.ClassName = 'TgdcTemplate')
              and
              (AgdcObject.FieldByName('templatetype').AsString = 'FR4')
              and
              (F.FieldName = 'TEMPLATEDATA') then
            begin
              AWriter.WriteText(F.AsString, qPlain, sLiteral);
              Flag := True;
            end;

            if not Flag then
            begin
              BlobStream := AgdcObject.CreateBlobStream(F, bmRead);
              try
                AWriter.WriteBinary(BlobStream);
              finally
                FreeAndNil(BlobStream);
              end;
            end;
          end;
        else
          AWriter.WriteText(F.AsString, qSingleQuoted);
        end;
      end else
        AWriter.WriteNull;
    end;

    WriteSet(AgdcObject, AWriter);
  finally
    AWriter.DecIndent;
  end;
end;

function TgdcNamespace.MakePos: Boolean;
var
  q: TIBSQL;
  Tr: TIBTransaction;
  LI: TListItem;
  I: Integer;
begin
  Result := False;
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := gdcBaseManager.Database;
    Tr.StartTransaction;

    q.Transaction := Tr;
    q.SQL.Text :=
      'SELECT * FROM at_object WHERE namespacekey = :NK ORDER BY objectpos';
    q.ParamByName('NK').AsInteger := ID;
    q.ExecQuery;

    if not q.EOF then
    begin
      with Tgdc_dlgNamespaceObjectPos.Create(ParentForm) do
      try
        lv.Items.BeginUpdate;
        while not q.EOF do
        begin
          LI := lv.Items.Add;    
          LI.Caption := q.FieldByName('objectname').AsString;
          LI.SubItems.Add(q.FieldByName('id').AsString);
          LI.SubItems.Add(q.FieldByName('objectpos').AsString);
          q.Next;
        end;
        lv.Items[0].Selected := True;
        lv.Items.EndUpdate;

        if ShowModal = mrOk then
        begin
          q.Close;
          q.SQL.Text := 'UPDATE at_object SET objectpos = :P ' +
            'WHERE id = :ID AND objectpos <> :P';

          for I := 0 to lv.Items.Count - 1 do
          begin
            if StrToInt(lv.Items[I].SubItems[1]) <> I then
            begin
              q.ParamByName('id').AsString := lv.Items[I].SubItems[0];
              q.ParamByName('p').AsInteger := I;
              q.ExecQuery;
              Result := True;
            end;
          end;
        end;
      finally
        Free;
      end;
    end;

    Tr.Commit;
  finally
    q.Free;
  end;
end;

procedure TgdcNamespace.CheckIncludesiblings;
var
  Obj: TgdcNamespaceObject;
  InstID: Integer;
  InstObj: TgdcBase;
  InstClass: TPersistentClass;
  q, SelectPos: TIBSQL;
  C: TgdcFullClass;
  gdcTree: TgdcTree;
  PositionOffset: Integer;
begin
  q := TIBSQL.Create(nil);
  SelectPos := TIBSQL.Create(nil);
  try
    q.Transaction := gdcBaseManager.ReadTransaction;
    SelectPos.Transaction := gdcBaseManager.ReadTransaction;
    SelectPos.SQL.Text :=
      'SELECT * FROM at_object WHERE namespacekey = :nk ' +
      'AND xid = :xid AND dbid = :dbid';
    q.SQL.Text := 'SELECT * FROM at_object WHERE namespacekey = :nk';
    q.ParamByName('nk').AsInteger := Self.ID;
    q.ExecQuery;

    PositionOffset := 0;
    while not q.Eof do
    begin
      if q.FieldByName('includesiblings').AsInteger = 1 then
      begin
        InstID := gdcBaseManager.GetIDByRUID(q.FieldByName('xid').AsInteger,
          q.FieldByName('dbid').AsInteger);

        InstClass := GetClass(q.FieldByName('objectclass').AsString);
        if (InstClass <> nil) and InstClass.InheritsFrom(TgdcTree) then
        begin
          InstObj := CgdcBase(InstClass).CreateSubType(nil,
            q.FieldByName('subtype').AsString, 'ByID');
          try
            InstObj.ID := InstID;
            InstObj.Open;
            if not InstObj.EOF then
            begin
              C := InstObj.GetCurrRecordClass;

              if C.gdClass.InheritsFrom(TgdcUserDocument) then
                C.gdClass := TgdcUserDocumentLine;

              if C.gdClass.InheritsFrom(TgdcTree) then
              begin
                gdcTree := C.gdClass.CreateSubType(nil,
                  C.SubType, 'ByParent') as TgdcTree;
                try
                  gdcTree.Parent := InstObj.ID;
                  gdcTree.Open;
                  while not gdcTree.EOF do
                  begin
                    SelectPos.ParamByName('nk').AsInteger := Self.ID;
                    SelectPos.ParamByName('xid').AsInteger := gdcTree.GetRUID.XID;
                    SelectPos.ParamByName('dbid').AsInteger := gdcTree.GetRUID.DBID;
                    SelectPos.ExecQuery;

                    if SelectPos.Eof then
                    begin
                      Obj := TgdcNamespaceObject.Create(nil);
                      try
                        Obj.Open;
                        Obj.Insert;
                        Obj.FieldByName('namespacekey').AsInteger := Self.ID;
                        Obj.FieldByName('objectname').AsString := gdcTree.FieldByName(gdcTree.GetListField(gdcTree.SubType)).AsString;
                        Obj.FieldByName('objectclass').AsString := gdcTree.ClassName;
                        Obj.FieldByName('subtype').AsString := gdcTree.SubType;
                        Obj.FieldByName('xid').AsInteger := gdcTree.GetRUID.XID;
                        Obj.FieldByName('dbid').AsInteger := gdcTree.GetRUID.DBID;
                        Obj.FieldByName('objectpos').AsInteger := q.FieldByName('objectpos').AsInteger + 1 + PositionOffset;
                        Obj.FieldByName('alwaysoverwrite').AsInteger := q.FieldByName('alwaysoverwrite').AsInteger;
                        Obj.FieldByName('dontremove').AsInteger := q.FieldByName('dontremove').AsInteger;
                        Obj.FieldByName('includesiblings').AsInteger := q.FieldByName('includesiblings').AsInteger;
                        Obj.Post;
                        Inc(PositionOffset);
                      finally
                        Obj.Free;
                      end;
                    end;
                    SelectPos.Close;
                    gdcTree.Next;
                  end;
                finally
                  gdcTree.Free;
                end;
              end;
            end;
          finaLLY
            InstObj.Free;
          end;
        end;
      end;
      q.Next;
    end;
  finally
    q.Free;
    SelectPos.Free;
  end;
end;

procedure TgdcNamespace.LoadFromFile(const AFileName: String = '');
var
  FN: String;
  SL: TStringList;
begin
  if AFileName = '' then
    FN := QueryLoadFileName(AFileName, 'yml', 'Модули|*.yml')
  else
    FN := AFileName;

  if FN > '' then
  begin
    SL := TStringList.Create;
    try
      SL.Add(FN);
      DoLoadNamespace(SL);
    finally
      SL.Free;
    end;
  end;
end;

procedure TgdcNamespace.DoLoadNamespace(ANamespaceList: TStringList;
  const AnAlwaysoverwrite: Boolean = False; const ADontRemove: Boolean = False);
var
  Tr: TIBTransaction;
  RelName: String;

  function LoadedNS(const Name: String; var RUID: String): TNSFound;
  var
    q: TIBSQL;
    Temps: String;
  begin
    Result := nsfNone;
    Temps := RUID;
    RUID := '';
    q := TIBSQL.Create(nil);
    try
      q.Transaction := Tr;
      q.SQL.Text := 'SELECT * FROM at_namespace n ' +
        'LEFT JOIN gd_ruid r ON n.id = r.id ' +
        'WHERE r.xid || ''_'' || r.dbid = :ruid';
      q.ParamByName('ruid').AsString := Temps;
      q.ExecQuery;

      if not q.Eof then
      begin
        RUID := Temps;
        Result := nsfByRUID;
      end else
      begin
        q.Close;
        q.SQL.Text := 'SELECT r.xid || ''_'' || r.dbid as ruid FROM at_namespace n ' +
          'LEFT JOIN gd_ruid r ON n.id = r.id ' +
          'WHERE UPPER(name) = UPPER(:name)';
        q.ParamByName('name').AsString := Name;
        q.ExecQuery;
        if not q.Eof then
        begin
          RUID := q.Fields[0].AsString;
          Result := nsfByName;
        end;
      end;
    finally
      q.Free;
    end;   
  end;

  procedure FillObjectsRUIDInDB(const RUID: String; SL: TStringList);
  var
    q: TIBSQL;
  begin
    Assert(SL <> nil);

    if RUID = '' then
      exit;

    q := TIBSQL.Create(nil);
    try
      q.Transaction := Tr;
      q.SQL.Text :=
        'SELECT o.xid || ''_'' || o.dbid as ruid ' +
        'FROM at_object o ' +
        '  LEFT JOIN gd_ruid r' +
        '    ON  o.namespacekey = r.id ' +
        'WHERE r.xid || ''_'' || r.dbid = :ruid';
      q.ParamByName('ruid').AsString := RUID;
      q.ExecQuery;

      while not q.Eof do
      begin
        SL.Add(q.FieldByName('ruid').AsString);
        q.Next;
      end;
    finally
      q.Free;
    end;
  end;

  procedure DisconnectDatabase(const WithCommit: Boolean);
  begin
    if gdcBaseManager.ReadTransaction.InTransaction then
      gdcBaseManager.ReadTransaction.Commit;
    if Tr.InTransaction then
    begin
    if WithCommit then
      begin
        Tr.Commit;
      end else
      begin
        Tr.Rollback;
      end;
    end;
    Tr.DefaultDatabase.Connected := False;
  end;

  procedure ConnectDatabase;
  begin
    Tr.DefaultDatabase.Connected := True;
    if not Tr.InTransaction then
      Tr.StartTransaction;
    if not gdcBaseManager.ReadTransaction.InTransaction then
      gdcBaseManager.ReadTransaction.StartTransaction;
  end;

  procedure ReConnectDatabase(const WithCommit: Boolean = True);
  begin
    try
      DisconnectDatabase(WithCommit);
    except
      on E: Exception do
      begin
        if MessageBox(0,
          PChar('В процессе загрузки пространства имен произошла ошибка:'#13#10 +
          E.Message + #13#10#13#10 +
          'Продолжать загрузку?'),
          'Ошибка',
          MB_ICONEXCLAMATION or MB_YESNO or MB_TASKMODAL) = IDNO then
        begin
          raise;
        end;
      end;
    end;
    ConnectDatabase;
  end;

  procedure RunMultiConnection;
  var
    WasConnect: Boolean;
    ibsql: TIBSQL;
    R: TatRelation;
  begin
    Assert(atDatabase <> nil, 'Не загружена база атрибутов');
    if atDatabase.InMultiConnection then
    begin
      ibsql := TIBSQL.Create(nil);
      try
        ibsql.Transaction := Tr;
        ibsql.SQL.Text := 'SELECT FIRST 1 * FROM at_transaction ';
        ibsql.ExecQuery;

        if ibsql.RecordCount = 0 then
        begin
          atDatabase.CancelMultiConnectionTransaction(True);
        end else
        begin
          with TmetaMultiConnection.Create do
          try
            WasConnect := Tr.DefaultDatabase.Connected;
            DisconnectDatabase(True);
            RunScripts(False);
            ConnectDatabase;
            R := atDatabase.Relations.ByRelationName(RelName);
            if Assigned(R) then
              R.RefreshConstraints(Tr.DefaultDatabase, Tr);
            if not WasConnect then
              DisconnectDatabase(True);
          finally
            Free;
          end;
        end;
      finally
        ibsql.Free;
      end;
    end;
  end;

  procedure HeadObjectUpdate(UL: TStringList; NamespaceKey: Integer;
    SourceRUID: String; TargetKeyValue: Integer);
  var
    I, Ind: Integer;
    q: TIBSQL;
    RUID: String;
  begin
    Ind := UL.IndexOf(SourceRUID);
    if Ind > -1 then
    begin
      q := TIBSQL.Create(nil);
      try
        q.Transaction := Tr;
        q.SQL.Text :=
          'UPDATE at_object SET headobjectkey = :hk ' +
          'WHERE namespacekey = :nk AND xid = :xid AND dbid = :dbid';
        for I := (UL.Objects[Ind] as TStringList).Count - 1 downto 0 do
        begin
          RUID := (UL.Objects[Ind] as TStringList)[I];
          q.ParamByName('hk').AsInteger := TargetKeyValue;
          q.ParamByName('nk').AsInteger := Namespacekey;
          q.ParamByName('xid').AsInteger := StrToRUID(RUID).XID;
          q.ParamByName('dbid').AsInteger := StrToRUID(RUID).dbid;
          q.ExecQuery;
        end;
        UL.Objects[Ind].Free;
        UL.Delete(Ind);
      finally
        q.Free;
      end;
    end;
  end;

  procedure CheckUses(Seq: TyamlSequence; Namespacekey: Integer);
  var
    I: Integer;
    gdcNamespace: TgdcNamespace;
    NSName, RUID, TempS: String;
    q: TIBSQL;
    NSID: TID;
  begin
    if Seq.Count = 0 then
      exit;

    gdcNamespace := TgdcNamespace.Create(nil);
    q := TIBSQL.Create(nil);
    try
      q.Transaction := Tr;
      gdcNamespace.Transaction := Tr;

      for I := 0 to Seq.Count - 1 do
      begin
        if not (Seq[I] is TyamlString) then
          break;

        if ParseReferenceString((Seq[I] as TyamlString).AsString, RUID, NSName) then
        begin
          TempS := RUID;
          LoadedNS(NSName, TempS);
          if TempS <> '' then
          begin
            NSID := gdcBaseManager.GetIDByRUIDString(
              Temps, Tr);
          end else
          begin
            gdcNamespace.Open;
            gdcNamespace.Insert;
            gdcNamespace.FieldByName('name').AsString := NSName;
            gdcNamespace.Post;
            NSID := gdcNamespace.ID;
            gdcNamespace.Close;
          end; 

          if gdcBaseManager.GetRUIDRecByID(NSID, Tr).XID = -1 then
          begin
            gdcBaseManager.InsertRUID(NSID,
              StrToRUID(RUID).XID, StrToRUID(RUID).DBID,
              Now, IBLogin.ContactKey, Tr);
          end else
          begin
            gdcBaseManager.UpdateRUIDByID(NSID,
              StrToRUID(RUID).XID, StrToRUID(RUID).DBID,
              Now, IBLogin.ContactKey, Tr);
          end;

          q.Close;
          q.SQL.Text :=
            'UPDATE OR INSERT INTO at_namespace_link ' +
            '(namespacekey, useskey) ' +
            'VALUES (:NK, :UK) ' +
            'MATCHING (namespacekey, useskey)';
          q.ParamByName('nk').AsInteger := Namespacekey;
          q.ParamByName('uk').AsInteger := NSID;
          q.ExecQuery;
        end
      end;
    finally
      gdcNamespace.Free;
      q.Free;
    end;
  end;

  function UpdateNamespace(Source: TgdcNamespace; const RUID: String; CurrOL, LoadOL: TStringList): Integer;
  const
    DontCopyList = ';ID;NAME;NAMESPACEKEY;';
  var
    I: Integer;
    gdcNamespaceObj: TgdcNamespaceObject;
    Dest: TgdcNamespace;
    DestObj: TgdcNamespaceObject;
    CurrName: String;
    TempS: String;
  begin
    Dest := TgdcNamespace.Create(nil);
    try
      CurrName := System.Copy(Source.FieldByName('name').AsString, 6, MaxInt);
      Dest.Transaction := Tr;
      Dest.ReadTransaction := Tr;
      Dest.SubSet := 'ByID';
      TempS := RUID;

      case LoadedNS(CurrName, TempS) of
        nsfByRUID:
        begin
          Dest.ID := gdcBaseManager.GetIDByRUIDString(
            Temps, Tr);
          Dest.Open;
          Dest.Edit;
        end;
        nsfByName:
        begin
          gdcBaseManager.DeleteRUIDbyXID(
            StrToRUID(RUID).XID,
            StrToRUID(RUID).DBID, Tr);
          Dest.ID := gdcBaseManager.GetIDByRUIDString(
            Temps, Tr);
          Dest.Open;
          Dest.Edit;
        end;
        nsfNone:
        begin
          gdcBaseManager.DeleteRUIDbyXID(
            StrToRUID(RUID).XID,
            StrToRUID(RUID).DBID, Tr);
          Dest.ID := -1;
          Dest.Open;
          Dest.Insert;
        end;
      end;


      for I := 0 to Dest.FieldCount - 1 do
      begin
        if (StrIPos(';' + Dest.Fields[I].FieldName + ';', DontCopyList) = 0) then
          Dest.Fields[I].Value := Source.FieldByName(Dest.Fields[I].FieldName).Value;
      end;

      Dest.FieldByName('name').AsString := CurrName;
      Dest.Post; 

      if gdcBaseManager.GetRUIDRecByID(Dest.ID, Tr).XID = -1 then
      begin
        gdcBaseManager.InsertRUID(Dest.ID,
          StrToRUID(RUID).XID,
          StrToRUID(RUID).DBID,
          Now, IBLogin.ContactKey, Tr);
      end else
      begin
        gdcBaseManager.UpdateRUIDByID(Dest.ID,
          StrToRUID(RUID).XID,
          StrToRUID(RUID).DBID,
          Now, IBLogin.ContactKey, Tr);
      end;

      for I := 0 to CurrOL.Count - 1 do
      begin
        if LoadOL.IndexOf(CurrOL[I]) = -1 then
          Dest.DeleteObject(StrToRUID(CurrOL[I]).XID, StrToRUID(CurrOL[I]).DBID, not ADontRemove);
      end;

      gdcNamespaceObj := TgdcNamespaceObject.Create(nil);
      try
        gdcNamespaceObj.Transaction := Tr;
        gdcNamespaceObj.ReadTransaction := Tr;
        gdcNamespaceObj.SubSet := 'ByNamespace';
        gdcNamespaceObj.ParamByName('namespacekey').AsInteger := Source.ID;
        gdcNamespaceObj.Open;

        if not gdcNamespaceObj.Eof then
        begin
          DestObj := TgdcNamespaceObject.Create(nil);
          try
            DestObj.Transaction := Tr;
            DestObj.ReadTransaction := Tr;
            DestObj.SubSet := 'ByObject';
            while not gdcNamespaceObj.Eof do
            begin
              DestObj.Close;
              DestObj.ParamByName('namespacekey').AsInteger := Dest.ID;
              DestObj.ParamByName('xid').AsInteger :=
                gdcNamespaceObj.FieldByName('xid').AsInteger;
              DestObj.ParamByName('dbid').AsInteger :=
                gdcNamespaceObj.FieldByName('dbid').AsInteger;
              DestObj.Open;
              if not DestObj.Eof then
                DestObj.Edit
              else
                DestObj.Insert;

              for I := 0 to gdcNamespaceObj.FieldCount - 1 do
              begin
                if (StrIPos(';' + DestObj.Fields[I].FieldName + ';', DontCopyList) = 0) then
                  DestObj.Fields[I].Value := gdcNamespaceObj.FieldByName(DestObj.Fields[I].FieldName).Value;
              end;

              DestObj.FieldByName('namespacekey').AsInteger := Dest.ID;
              DestObj.Post;
              gdcNamespaceObj.Next;
            end;
          finally
            DestObj.Free;
          end;
        end;
      finally
        gdcNamespaceObj.Free;
      end;
      Result := Dest.ID;
    finally
      Dest.Free;
    end;
  end;
var
  LoadNamespace: TStringList;
  LoadObjectsRUID: TStringList;
  CurrObjectsRUID: TStringList;     
  Parser: TyamlParser;
  I, J, Ind, K: Integer;
  gdcNamespace: TgdcNamespace;
  TempNamespaceID: Integer;
  M, ObjMapping: TyamlMapping;
  N: TyamlNode;
  RUID, HeadRUID, LoadNSRUID: String;
  WasMetaData, WasMetaDataInSetting, SubTypeFound: Boolean;
  LoadClassName, LoadSubType: String;
  C: TClass;
  ObjList: TStringList;
  Obj: TgdcBase;
  gdcNamespaceObj: TgdcNamespaceObject;
  UpdateList: TObjectList;
  UpdateHeadList, SubTypes: TStringList;
  q: TIBSQL;
  CurrID: Integer;
  gdcFullClass: TgdcFullClass;
  IsLoad: Boolean;
begin
  Assert(atDatabase <> nil, 'Не загружена atDatabase');

  LoadNamespace:= TStringlist.Create;
  LoadObjectsRUID := TStringList.Create;
  CurrObjectsRUID := TStringList.Create;   
  UpdateList := TObjectList.Create(True);
  ObjList := TStringList.Create;
  UpdateHeadList := TStringList.Create;
  q := TIBSQL.Create(nil);
  Tr := TIBTransaction.Create(nil);
  try
    Tr.DefaultDatabase := IBLogin.Database;
    Tr.Params.Add('nowait');
    Tr.Params.Add('read_committed');
    Tr.Params.Add('rec_version');
    Obj := nil;
    WasMetaData := False;
    WasMetaDataInSetting := True;
    TempNamespaceID := -1;
    q.Transaction := Tr;
    q.SQL.Text :=
      'SELECT * FROM at_object ' +
      'WHERE xid || ''_'' || dbid = :r AND namespacekey = :nk';
    try
      if (GlobalStorage <> nil) and GlobalStorage.IsModified then
      GlobalStorage.SaveToDatabase;

      if (UserStorage <> nil) and UserStorage.IsModified then
        UserStorage.SaveToDatabase;

      if (CompanyStorage <> nil) and CompanyStorage.IsModified then
        CompanyStorage.SaveToDatabase;

      DesktopManager.WriteDesktopData('Последний', True);
      FreeAllForms(False);
      ConnectDatabase;
      for I := 0 to ANamespaceList.Count - 1 do
      begin
        if LoadNamespace.IndexOf(ANamespaceList[I]) > -1 then
          continue;

        for J := 0 to UpdateHeadList.Count - 1 do
          UpdateHeadList.Objects[J].Free;
        UpdateHeadList.Clear;
        LoadObjectsRUID.Clear;
        CurrObjectsRUID.Clear;

        Parser := TyamlParser.Create;
        try
          Parser.Parse(ANamespaceList[I]);

          if (Parser.YAMLStream.Count > 0)
            and ((Parser.YAMLStream[0] as TyamlDocument).Count > 0)
            and ((Parser.YAMLStream[0] as TyamlDocument)[0] is TyamlMapping) then
          begin   
            if WasMetaDataInSetting then
            begin
              atDataBase.ProceedLoading(True);
              WasMetaDataInSetting := False;
            end;
            atDatabase.SyncIndicesAndTriggers(Tr);   

            M := (Parser.YAMLStream[0] as TyamlDocument)[0] as TyamlMapping;
            LoadNSRUID := M.ReadString('Properties\RUID');
            AddText('Начата загрузка пространства имен ' + M.ReadString('Properties\Name'), clBlack);
            gdcNamespace := TgdcNamespace.Create(nil);
            try
              gdcNamespace.Transaction := Tr;
              gdcNamespace.Open;
              gdcNamespace.Insert;
              gdcNamespace.FieldByName('name').AsString := 'Temp_' + M.ReadString('Properties\Name');
              gdcNamespace.FieldByName('caption').AsString := M.ReadString('Properties\Caption');
              gdcNamespace.FieldByName('version').AsString := M.ReadString('Properties\Version');
              gdcNamespace.FieldByName('dbversion').AsString := M.ReadString('Properties\DBversion');
              gdcNamespace.FieldByName('optional').AsInteger := Integer(M.ReadBoolean('Properties\Optional', False));
              gdcNamespace.FieldByName('internal').AsInteger := Integer(M.ReadBoolean('Properties\internal', True));
              gdcNamespace.FieldByName('comment').AsString := M.ReadString('Properties\Comment');
              gdcNamespace.Post;
              TempNamespaceID := gdcNamespace.ID;
            finally
              gdcNamespace.Free;
            end;

            RUID := LoadNSRUID;
            LoadedNS(M.ReadString('Properties\Name'), RUID); 
            FillObjectsRUIDInDB(RUID, CurrObjectsRUID);

            N := M.FindByName('Objects');
            if N <> nil then
            begin
              if not (N is TyamlSequence) then
                raise Exception.Create('Invalid objects!');
              with N as TyamlSequence do
              begin

                for J := 0 to Count - 1 do
                begin
                  ObjMapping := Items[J] as TyamlMapping;
                  LoadClassName := ObjMapping.ReadString('Properties\Class');
                  LoadSubType := ObjMapping.ReadString('Properties\SubType');
                  RUID := ObjMapping.ReadString('Properties\RUID');

                  if (LoadClassName = '') or (RUID = '') or not CheckRUID(RUID) then
                    raise Exception.Create('Invalid object!');

                  C := GetClass(LoadClassName);

                  if C = nil then
                    continue;

                  if (CgdcBase(C).InheritsFrom(TgdcMetaBase)) then
                  begin
                    WasMetaData := True;
                    WasMetaDataInSetting := True;
                  end else
                  begin
                    if WasMetaData then
                      ReconnectDatabase;
                    WasMetaData := False;
                  end;  

                  RunMultiConnection;

                  if (Obj = nil)
                    or (Obj.ClassType <> C)
                    or (LoadSubType <> Obj.SubType) then
                  begin
                    Ind := ObjList.IndexOf(LoadClassName + '('+ LoadSubType + ')');
                    if Ind = -1 then
                    begin
                      if LoadSubType > '' then
                      begin
                        SubTypes := TStringList.Create;
                        try
                          CgdcBase(C).GetSubTypeList(SubTypes);
                          SubTypeFound := False;
                          for K := 0 to SubTypes.Count - 1 do
                          begin
                            if Pos('=' + LoadSubType + '^', SubTypes[K] + '^') > 0 then
                            begin
                              SubTypeFound := True;
                              break;
                            end;
                          end;
                          if not SubTypeFound then
                            ReconnectDatabase;
                        finally
                          SubTypes.Free;
                        end;
                      end;

                      Obj := CgdcBase(C).CreateWithParams(nil,
                        Tr.DefaultDatabase, Tr, LoadSubType);

                      Obj.ReadTransaction := Tr;
                      Obj.SetRefreshSQLOn(False);
                      ObjList.AddObject(LoadClassName + '('+ LoadSubType + ')', Obj);
                      ObjList.Sort;
                    end else
                      Obj := TgdcBase(ObjList.Objects[Ind]);
                  end;

                  if Obj.SubSet <> 'ByID' then
                    Obj.SubSet := 'ByID';
                  Obj.Open;

                  IsLoad := LoadObject(Obj, ObjMapping, UpdateList, Tr);

                  if (Obj is TgdcRelationField) then
                    RelName := Obj.FieldByName('relationname').AsString
                  else
                    RelName := '';

                  gdcNamespaceObj :=  TgdcNamespaceObject.Create(nil);
                  try
                    gdcNamespaceObj.Transaction := Tr;
                    gdcNamespaceObj.ReadTransaction := Tr;
                    gdcNamespaceObj.SubSet := 'ByObject';
                    gdcNamespaceObj.ParamByName('namespacekey').AsInteger := TempNamespaceID;
                    gdcNamespaceObj.ParamByName('xid').AsInteger := Obj.GetRUID.XID;
                    gdcNamespaceObj.ParamByName('dbid').AsInteger := Obj.GetRUID.DBID;
                    gdcNamespaceObj.Open;
                    if gdcNamespaceObj.Eof then
                    begin
                      gdcNamespaceObj.Insert;
                      gdcNamespaceObj.FieldByName('namespacekey').AsInteger := TempNamespaceID;
                      if Obj.FieldByName(Obj.GetListField(Obj.SubType)).AsString <> '' then
                        gdcNamespaceObj.FieldByName('objectname').AsString := Obj.FieldByName(Obj.GetListField(Obj.SubType)).AsString
                      else
                        gdcNamespaceObj.FieldByName('objectname').AsString := RUIDToStr(Obj.GetRUID);
                      gdcNamespaceObj.FieldByName('objectclass').AsString := Obj.ClassName;
                      gdcNamespaceObj.FieldByName('subtype').AsString := Obj.SubType;
                      gdcNamespaceObj.FieldByName('xid').AsInteger := Obj.GetRUID.XID;
                      gdcNamespaceObj.FieldByName('dbid').AsInteger := Obj.GetRUID.DBID;
                      gdcNamespaceObj.FieldByName('alwaysoverwrite').AsInteger := Integer(ObjMapping.ReadBoolean('Properties\AlwaysOverwrite'));
                      gdcNamespaceObj.FieldByName('dontremove').AsInteger := Integer(ObjMapping.ReadBoolean('Properties\DontRemove'));
                      gdcNamespaceObj.FieldByName('includesiblings').AsInteger := Integer(ObjMapping.ReadBoolean('Properties\IncludeSiblings'));

                      HeadRUID := ObjMapping.ReadString('Properties\HeadObject');
                      if HeadRUID <> '' then
                      begin
                        q.Close;
                        q.ParamByName('r').AsString := HeadRUID;
                        q.ParamByName('nk').AsInteger := TempNamespaceID;
                        q.ExecQuery;

                        if not q.Eof then
                        begin
                          gdcNamespaceObj.FieldByName('headobjectkey').AsInteger := q.FieldByName('id').AsInteger;
                        end else
                        begin
                          Ind := UpdateHeadList.IndexOf(HeadRUID);
                          if Ind > -1 then
                          begin
                            (UpdateHeadList.Objects[Ind] as TStringList).Add(RUIDToStr(Obj.GetRUID));
                          end else
                          begin
                            Ind := UpdateHeadList.AddObject(HeadRUID, TStringList.Create);
                            (UpdateHeadList.Objects[Ind] as TStringList).Add(RUIDToStr(Obj.GetRUID));
                          end;
                        end;
                      end;
                      gdcNamespaceObj.Post;
                    end;
                    HeadObjectUpdate(UpdateHeadList, TempNamespaceID,
                      RUIDToStr(Obj.GetRUID), gdcNamespaceObj.ID);

                    if IsLoad then
                    begin
                      LoadObjectsRUID.Add(RUIDToStr(Obj.GetRUID));
                      if Obj is TgdcRelationField then
                      begin
                        gdcFullClass := GetBaseClassForRelation(Obj.FieldByName('relationname').AsString);
                        if gdcFullClass.gdClass <> nil then
                        begin
                          for K := ObjList.Count - 1 downto 0 do
                          begin
                            if ObjList.Objects[K].ClassType.InheritsFrom(gdcFullClass.gdClass)
                              and ((ObjList.Objects[K] as TgdcBase).SubType = gdcFullClass.SubType)  then
                            begin
                              if Obj = ObjList.Objects[K] then
                                Obj := nil;
                              ObjList.Objects[K].Free;
                              ObjList.Delete(K);
                            end;
                          end;
                        end;
                      end;
                    end;
                  finally
                    gdcNamespaceObj.Free;
                  end;
                end;
              end;
            end;

            gdcNamespace := TgdcNamespace.Create(nil);
            try
              gdcNamespace.Transaction := Tr;
              gdcNamespace.ReadTransaction := Tr;
              gdcNamespace.SubSet := 'ByID';
              gdcNamespace.ID := TempNamespaceID;
              gdcNamespace.Open;
              if not gdcNamespace.Eof then
              begin
                CurrID := UpdateNamespace(gdcNamespace, LoadNSRUID, CurrObjectsRUID, LoadObjectsRUID);
                gdcNamespace.Delete;
                N := M.FindByName('USES');
                if (N <> nil) and (N is TyamlSequence) and (CurrID > -1) then
                  CheckUses(N as TyamlSequence, CurrID);
              end;
            finally
              gdcNamespace.Free;
            end;

            LoadNamespace.Add(ANamespaceList[I]);
            RunMultiConnection;

            AddText('Закончена загрузка пространства имен ' + M.ReadString('Properties\Name'), clBlack);
          end;
        finally
          Parser.Free;
        end;
      end;

      DisconnectDatabase(True);
    except
      on E: Exception do
      begin
        if Tr.InTransaction then
          Tr.Rollback;
        if TempNamespaceID > 0 then
        begin 
          gdcNamespace := TgdcNamespace.Create(nil);
          try
            gdcNamespace.SubSet := 'ByID';
            gdcNamespace.ID := TempNamespaceID;
            gdcNamespace.Open;
            if not gdcNamespace.Eof then
              gdcNamespace.Delete;
          finally
            gdcNamespace.Free;
          end;
        end;
        AddMistake(E.Message, clRed);
        raise;
      end;
    end;
  finally
    try
      ConnectDatabase;

      if IBLogin.LoggedIn then
      begin
        Clear_atSQLSetupCache;
        IBLogin.Relogin;
      end else
        IBLogin.Login;
    finally
      LoadNamespace.Free;
      LoadObjectsRUID.Free; 
      CurrObjectsRUID.Free;
      Tr.Free;  
      UpdateList.Free;
      q.Free;
      for I := 0 to UpdateHeadList.Count - 1 do
        UpdateHeadList.Objects[I].Free;
      UpdateHeadList.Free;

      for I := 0 to ObjList.Count - 1 do
        ObjList.Objects[I].Free;
      ObjList.Free; 
    end;
  end;
end;

class function TgdcNamespace.LoadNSInfo(const Path: String; ATr: TIBTransaction): integer;
var
  M, ObjMapping: TyamlMapping;
  Parser: TyamlParser;
  N: TyamlNode;
  J: Integer;
  gdcNamespace: TgdcNamespace;
  gdcNamespaceObj: TgdcNamespaceObject;
  LoadClassName, LoadSubType, RUID: String;
begin
  Assert(ATr <> nil);
  Assert(ATr.InTransaction);

  Result := -1;
  gdcNamespace := TgdcNamespace.Create(nil);
  try
    gdcNamespace.Transaction := ATr;
    gdcNamespace.ReadTransaction := ATr;
    gdcNamespace.SubSet := 'ByID';

    Parser := TyamlParser.Create;
    try
     Parser.Parse(Path);
      if (Parser.YAMLStream.Count > 0)
        and ((Parser.YAMLStream[0] as TyamlDocument).Count > 0)
        and ((Parser.YAMLStream[0] as TyamlDocument)[0] is TyamlMapping) then
      begin
        M := (Parser.YAMLStream[0] as TyamlDocument)[0] as TyamlMapping;
        RUID := M.ReadString('Properties\RUID');
        gdcNamespace.Close;
        gdcNamespace.ID := gdcBaseManager.GetIDByRUIDString(RUID, ATr);
        gdcNamespace.Open;
        if gdcNamespace.Eof then
        begin
          gdcBaseManager.DeleteRUIDbyXID(StrToRUID(RUID).XID, StrToRUID(RUID).DBID, ATr);
          gdcNamespace.Insert;
          gdcNamespace.FieldByName('name').AsString := M.ReadString('Properties\Name');
          gdcNamespace.FieldByName('caption').AsString := M.ReadString('Properties\Caption');
          gdcNamespace.FieldByName('version').AsString := M.ReadString('Properties\Version');
          gdcNamespace.FieldByName('dbversion').AsString := M.ReadString('Properties\DBversion');
          gdcNamespace.FieldByName('optional').AsInteger := Integer(M.ReadBoolean('Properties\Optional', False));
          gdcNamespace.FieldByName('internal').AsInteger := Integer(M.ReadBoolean('Properties\internal', True));
          gdcNamespace.FieldByName('comment').AsString := M.ReadString('Properties\Comment');
          gdcNamespace.Post;

          if gdcBaseManager.GetRUIDRecByID(gdcNamespace.ID, ATr).XID = -1 then
          begin
            gdcBaseManager.InsertRUID(gdcNamespace.ID,
              StrToRUID(RUID).XID,
              StrToRUID(RUID).DBID,
              Now, IBLogin.ContactKey, ATr);
          end else
          begin
            gdcBaseManager.UpdateRUIDByID(gdcNamespace.ID,
              StrToRUID(RUID).XID,
              StrToRUID(RUID).DBID,
              Now, IBLogin.ContactKey, ATr);
          end;

          Result := gdcNamespace.ID;
          N := M.FindByName('Objects');
          if N <> nil then
          begin
            if not (N is TyamlSequence) then
              raise Exception.Create('Invalid objects!');
            gdcNamespaceObj := TgdcNamespaceObject.Create(nil);
            try
              gdcNamespaceObj.Transaction := ATr;
              gdcNamespaceObj.ReadTransaction := ATr;
              gdcNamespaceObj.SubSet := 'ByObject';

              with N as TyamlSequence do
              begin

                for J := 0 to Count - 1 do
                begin
                  ObjMapping := Items[J] as TyamlMapping;
                  LoadClassName := ObjMapping.ReadString('Properties\Class');
                  LoadSubType := ObjMapping.ReadString('Properties\SubType');
                  RUID := ObjMapping.ReadString('Properties\RUID');

                  if (LoadClassName = '') or (RUID = '') or not CheckRUID(RUID) then
                    raise Exception.Create('Invalid object!');
                    
                  gdcNamespaceObj.Close;
                  gdcNamespaceObj.ParamByName('namespacekey').AsInteger := gdcNamespace.ID;
                  gdcNamespaceObj.ParamByName('xid').AsInteger := StrToRUID(RUID).XID;
                  gdcNamespaceObj.ParamByName('dbid').AsInteger := StrToRUID(RUID).DBID;
                  gdcNamespaceObj.Open;

                  if gdcNamespaceObj.Eof then
                  begin
                    gdcNamespaceObj.Insert;
                    gdcNamespaceObj.FieldByName('namespacekey').AsInteger := gdcNamespace.ID;
                    gdcNamespaceObj.FieldByName('objectname').AsString := LoadClassName + '(' + LoadSubType + ')';
                    gdcNamespaceObj.FieldByName('objectclass').AsString := LoadClassName;
                    gdcNamespaceObj.FieldByName('subtype').AsString := LoadSubType;
                    gdcNamespaceObj.FieldByName('xid').AsInteger := StrToRUID(RUID).XID;
                    gdcNamespaceObj.FieldByName('dbid').AsInteger := StrToRUID(RUID).DBID;
                    gdcNamespaceObj.FieldByName('alwaysoverwrite').AsInteger := Integer(ObjMapping.ReadBoolean('Properties\AlwaysOverwrite'));
                    gdcNamespaceObj.FieldByName('dontremove').AsInteger := Integer(ObjMapping.ReadBoolean('Properties\DontRemove'));
                    gdcNamespaceObj.FieldByName('includesiblings').AsInteger := Integer(ObjMapping.ReadBoolean('Properties\IncludeSiblings'));
                    gdcNamespaceObj.Post;
                  end;
                end;
              end;
            finally
              gdcNamespaceObj.Free;
            end;
          end;
        end else
          Result := gdcNamespace.ID;
      end;
    finally
      Parser.Free;
    end;
  finally
    gdcNamespace.Free;   
  end;
end;

class function TgdcNamespace.LoadObject(AnObj: TgdcBase; AMapping: TyamlMapping;
  UpdateList: TObjectList; ATr: TIBTransaction; const AnAlwaysoverwrite: Boolean = False): Boolean;

  function InsertRecord(SourceYAML: TyamlMapping; Obj: TgdcBase;
    UL: TObjectList; const RUID: String): Boolean; forward;

  procedure CheckDataType(F: TField; Value: TyamlNode);
  var
    Flag: Boolean;
  begin
    Flag := False;
    case F.DataType of
      ftDateTime, ftTime: Flag := Value is TyamlDateTime;
      ftDate: Flag := Value is TyamlDate;
      ftInteger, ftLargeint, ftSmallint, ftWord: Flag := Value is TyamlInteger;
      ftFloat, ftCurrency: Flag := Value is TyamlNumeric;
      ftBlob, ftGraphic: Flag := (Value is TyamlBinary) or (Value is TyamlString);
      ftString, ftMemo, ftBCD: Flag := Value is TyamlString;
      ftBoolean: Flag := Value is TyamlBoolean;
    end;
    if not Flag then
      raise Exception.Create('Invalid data type, fieldtype = ' + IntToStr(Integer(F.DataType)));
  end;

  procedure ApplyDelayedUpdates(UL: TObjectList; SourceRUID: String; TargetKeyValue: Integer);
  var
    I: Integer;
    Obj: TgdcBase;
    q: TIBSQL;
  begin
    for I := UL.Count - 1 downto 0 do
    begin
      if (UL[I] as TgdcReferenceUpdate).RefRUID = SourceRUID then
      begin
        if (UL[I] as TgdcReferenceUpdate).SQL > '' then
        begin
          q := TIBSQL.Create(nil);
          try
            q.Transaction := ATr;
            q.SQL.Text := (UL[I] as TgdcReferenceUpdate).SQL;
            q.ParamByName('id1').AsInteger := (UL[I] as TgdcReferenceUpdate).ID;
            q.ParambyName('id2').AsInteger := TargetKeyValue;
            q.ExecQuery;
            q.Close;
          finally
            q.Free;
          end;
        end else
        begin
          Obj := (UL[I] as TgdcReferenceUpdate).FullClass.gdClass.CreateSubType(nil,
            (UL[I] as TgdcReferenceUpdate).FullClass.SubType, 'ByID');
          try
            Obj.Transaction := ATr;
            Obj.ReadTransaction := ATr;
            Obj.ID := (UL[I] as TgdcReferenceUpdate).ID;
            Obj.Open;
            if Obj.RecordCount > 0 then
            begin
              Obj.BaseState := Obj.BaseState + [sLoadFromStream];
              Obj.Edit;
              Obj.FieldByName((UL[I] as TgdcReferenceUpdate).FieldName).AsInteger := TargetKeyValue;
              Obj.Post;
            end;
          finally
            Obj.Free;
          end;
        end;
        UL.Delete(I);
      end;
    end;
  end;

  procedure SetValue(Field: TField; N: TyamlNode; SourceFields: TyamlMapping);
  var
    TempS: String;
    Flag: Boolean;
  begin
    if TyamlScalar(N).IsNull then
      Field.Clear
    else
    begin
      CheckDataType(Field, N);
      case Field.DataType of
        ftDateTime, ftTime: Field.AsDateTime := TyamlDateTime(N).AsDateTime;
        ftDate: Field.AsDateTime := TyamlDate(N).AsDate;
        ftInteger, ftLargeint, ftSmallint, ftWord: Field.AsInteger := TyamlScalar(N).AsInteger;
        ftFloat, ftCurrency: Field.AsFloat := TyamlScalar(N).AsFloat;
        ftBoolean: Field.AsBoolean := TyamlBoolean(N).AsBoolean;
        ftBlob, ftGraphic:
        begin
          Flag := False;

          if
            (AnObj.ClassName = 'TgdcStorageValue')
            and
            (
              (SourceFields.ReadString('name') = 'dfm')
              or
              CheckRUID(SourceFields.ReadString('name'))
              or
              (atDatabase.Relations.ByRelationName(SourceFields.ReadString('name')) <> nil)
            ) then
          begin
            TempS := TyamlScalar(N).AsString;
            if TryObjectTextToBinary(TempS) then
            begin
              Field.AsString := TempS;
              Flag := True;
            end
          end else if
            (AnObj.ClassName = 'TgdcTemplate')
            and
            (SourceFields.ReadString('templatetype') = 'FR4')
            and
            (Field.FieldName = 'TEMPLATEDATA') then
          begin
            Field.AsString := TyamlScalar(N).AsString;
            Flag := True;
          end;
          if not Flag then
          begin
            TBlobField(Field).LoadFromStream(TyamlBinary(N).AsStream);
          end;
        end;
      else 
        Field.AsString := TyamlScalar(N).AsString;
      end;
    end;
  end;

  function CopyRecord(SourceYAML: TyamlMapping; Obj: TgdcBase; UL: TObjectList): Boolean;
  var
    I, Key: Integer;
    R: TatRelation;
    F: TatRelationField;
    IsNull: Boolean;
    TargetField: TField;
    RU: TgdcReferenceUpdate;
    ErrorSt: String;
    RUOL: TList;
    Fields: TyamlMapping;
    N: TyamlNode;
    RUID, RefRUID, Name, KeyField: String;
  begin
    Assert(Obj.State in [dsInsert, dsEdit], 'Not in a insert or edit state!');
    
    Result := False;
    RUOL := nil;
    try
      Fields := SourceYAML.FindByName('Fields') as TyamlMapping;
      if Fields = nil then
        raise Exception.Create('Data fields is not found!');
      RUID := SourceYAML.ReadString('Properties\RUID');
      KeyField := Obj.GetKeyField(Obj.SubType);
      for I := 0 to Obj.Fields.Count - 1 do
      begin
        TargetField := Obj.Fields[I];
        if TargetField = nil then
          raise Exception.Create('Invalid field!');

        N := Fields.FindByName(TargetField.FieldName);
        if N <> nil then
        begin
          if not (N is TyamlScalar) then
            raise Exception.Create('Invalid yaml data type!');

          R := atDatabase.Relations.ByRelationName(Obj.RelationByAliasName(TargetField.FieldName));
          if R = nil then
          begin
            if (AnsiCompareText(TargetField.FieldName, KeyField) = 0) then
              Continue;

            SetValue(TargetField, N, Fields);
            Continue;
          end;

          if (Obj is TgdcDocument) and (TargetField.FieldName = fnDOCUMENTKEY)
            and (TargetField.Value > 0)
          then
            continue;

          F := R.RelationFields.ByFieldName(Obj.FieldNameByAliasName(TargetField.FieldName));

          IsNull := False;
          Key := -1;

          if (AnsiCompareText(TargetField.FieldName, KeyField) = 0) then
          begin
            if (F <> nil) and (F.References <> nil) then
            begin
              if not (N is TyamlString) then
                raise Exception.Create('Invalid YAML data type!');

              if ParseReferenceString(TyamlString(N).AsString, RefRUID, Name) then
              begin
                Key := gdcBaseManager.GetIDByRUIDString(RefRUID, ATr);
                if Key > -1 then
                  TargetField.AsInteger := Key;
              end else
                AddWarning(#13#10 + 'RUID ''' + RefRUID + ''' некорректен!'#13#10, clRed);
            end;
            Continue;
          end;

          if (F <> nil) and (F.References <> nil) then
          begin
            if not (N is TyamlScalar) then
              raise Exception.Create('Invalid YAML data type!');

            //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

            if not TyamlScalar(N).IsNull then
              ParseReferenceString(TyamlString(N).AsString, RefRUID, Name)
            else
              IsNull := True;

            if (RefRUID > '') and not CheckRUID(RefRUID) then
              AddWarning(#13#10 + 'RUID ''' + RefRUID + ''' некорректен!'#13#10, clRed);

            if not IsNull then
            begin
              if (RUID = RefRUID) and
                (Obj.ID > 0)
              then
                Key := Obj.ID
              else
              begin
                Key := gdcBaseManager.GetIDByRUIDString(RefRUID, ATr);
                IsNull := Key = -1;
              end;

              if (Key = -1) then
              begin
                if not Assigned(RUOL) then
                  RUOL := TList.Create;

                RU := TgdcReferenceUpdate.Create;
                RU.FieldName := TargetField.FieldName;
                RU.FullClass.gdClass := CgdcBase(Obj.ClassType);
                RU.FullClass.SubType := Obj.SubType;
                RU.ID := -1;
                RU.SQL := '';
                RU.RefRUID := RefRUID;
                UL.Add(RU);
                RUOL.Add(RU);
                IsNull := True;
              end; 
            end;
          end;

          if Key = -1 then
          begin
            if IsNull then
              TargetField.Clear
            else
            begin
              SetValue(TargetField, N, Fields);
            end
          end else
          begin
            if IsNull then
              TargetField.Clear
            else
              TargetField.AsInteger := Key;
          end;
        end;
      end;

      try
        if Obj.State = dsEdit then
        begin
          try
            Obj.Post;
            AddText('Объект обновлен данными из загружаемого пространства имен!', clBlack);

          except
            on E: EIBError do
            begin
              if (E.IBErrorCode = isc_no_dup) or (E.IBErrorCode = isc_except) then
              begin
                Obj.Cancel;
                AddText('РУИД некорректен. Попытка найти объект по уникальному ключу.', clBlack);
                gdcBaseManager.DeleteRUIDByXID(StrToRUID(RUID).XID,
                  StrToRUID(RUID).XID, ATr);
                InsertRecord(SourceYAML, Obj, UL, RUID);
              end else
                raise;
            end;
          end;
        end
        else if not Obj.CheckTheSame(True) then
          Obj.Post;

        if Assigned(RUOL) then
        begin
          for I := 0 to RUOL.Count - 1 do
            TgdcReferenceUpdate(RUOL[I]).ID := Obj.ID;
        end;

        ApplyDelayedUpdates(UL,
          RUID,
          Obj.ID);

        Result := True;
      except
        on E: EDatabaseError do
        begin
          if Obj.State = dsInsert then
            ErrorSt := Format('Невозможно добавить объект: %s %s %s ',
              [Obj.ClassName,
               Fields.ReadString(Obj.GetListField(Obj.SubType)),
               RUID])
          else
            ErrorSt := Format('Невозможно обновить объект: %s %s %s',
              [Obj.ClassName,
               Fields.ReadString(Obj.GetListField(Obj.SubType)),
               RUID]);

          AddMistake(E.Message, clRed);
          Obj.Cancel;
        end;
      end;
    finally
      if Assigned(RUOL) then
        RUOL.Free;
    end;
  end;

  function InsertRecord(SourceYAML: TyamlMapping; Obj: TgdcBase;
    UL: TObjectList; const RUID: String): Boolean;
  begin
    Result := False;
    Obj.Insert;
    if StrToRUID(RUID).XID < cstUserIDStart then
      Obj.ID := StrToRUID(RUID).XID; 
    if CopyRecord(SourceYAML, Obj, UL) then
    begin
      Obj.CheckBrowseMode;
      if gdcBaseManager.GetRUIDRecByID(Obj.ID, ATr).XID = -1 then
      begin
        gdcBaseManager.InsertRUID(Obj.ID, StrToRUID(RUID).XID, StrToRUID(RUID).DBID,
          now, IBLogin.ContactKey, ATr);
      end else
      begin
        gdcBaseManager.UpdateRUIDByID(Obj.ID, StrToRUID(RUID).XID, StrToRUID(RUID).DBID,
          now, IBLogin.ContactKey, ATr);
      end;
      Result := True;
    end;
  end;

  procedure LoadSet(AValue: TyamlMapping; AnID: Integer; UL: TObjectList);
  var
    RN: String;
    J: Integer;
    q: TIBSQL;
    R: TatRelation;
    N: TyamlNode;
    ID: Integer;
    Pr: TatPrimaryKey;
    RU: TgdcReferenceUpdate;
  begin
    q := TIBSQL.Create(nil);
    try
      q.Transaction := ATr;

      RN := AValue.ReadString('Table');
      if RN <> '' then
      begin
        N := AValue.FindByName('Items');
        if (N <> nil) and (N is TyamlSequence) then
        begin
          R := atDatabase.Relations.ByRelationName(RN);
          Pr := R.PrimaryKey;

          if not Assigned(Pr) then
          begin
            R.RefreshData(ATr.DefaultDatabase, ATr, True);
            R.RefreshConstraints(ATr.DefaultDatabase, ATr);

            Pr := R.PrimaryKey;
          end;

          if Assigned(Pr) then
          begin
            q.SQL.Text :=
              'DELETE FROM ' + RN +
              ' WHERE ' + Pr.ConstraintFields[0].FieldName + ' = :id';

            q.ParamByName('id').AsInteger := AnID;
            q.ExecQuery;
            q.Close;

            q.SQl.Text :=
              'INSERT INTO ' + RN + '(' + Pr.ConstraintFields[0].FieldName +
              ', ' + Pr.ConstraintFields[1].FieldName + ') VALUES(:id1, :id2)';

            with N as TyamlSequence do
            begin
              for J := 0 to Count - 1 do
              begin
                if not (Items[J] is TyamlScalar) then
                  raise Exception.Create('Invalid data!');

                ID := gdcBaseManager.GetIDByRUIDString((Items[J] as TyamlScalar).AsString, ATr);
                if ID > 0 then
                begin
                  q.ParamByName('id1').AsInteger := AnID;
                  q.ParambyName('id2').AsInteger := ID;
                  q.ExecQuery;
                  q.Close;
                end else
                begin
                  RU := TgdcReferenceUpdate.Create;
                  RU.ID := AnID;
                  RU.SQL := q.SQl.Text;
                  RU.RefRUID := (Items[J] as TyamlScalar).AsString;
                  UL.Add(RU);
                end;
                //  AddWarning(#13#10 + 'Запись в таблицу ' + RN + ' не добавлена!'#13#10, clRed);
              end;
            end;
          end else
             AddWarning(#13#10 + 'Данные множества ' + RN + ' не были добавлены!'#13#10, clRed);
        end;
      end;
    finally
      q.Free;
    end;
  end;
var
  D, J: Integer;
  RUID: String;
  RuidRec: TRuidRec;
  AlwaysOverwrite, ULCreated: Boolean;
  N: TyamlNode;
begin
  Assert(ATr <> nil);
  Assert(gdcBaseManager <> nil);
  Assert(AMapping <> nil);

  Result := False;
  RUID := AMapping.ReadString('Properties\RUID');
  AlwaysOverwrite := AMapping.ReadBoolean('Properties\AlwaysOverwrite')
    or AnAlwaysoverwrite;

  if UpdateList = nil then
  begin
    UpdateList := TObjectList.Create(True);
    ULCreated := True;
  end else
    ULCreated := False;
  try
    if AMapping.FindByName('Fields') <> nil then
    begin
      try
        AddText('Начата загрузка объекта ' +
          AMapping.ReadString('Properties\Class') + ' ' +
          AMapping.ReadString('Properties\RUID'), clBlack);
        AnObj.BaseState := AnObj.BaseState + [sLoadFromStream];
        AnObj.ModifyFromStream := AlwaysOverwrite;
        RuidRec := gdcBaseManager.GetRUIDRecByXID(StrToRUID(RUID).XID,
          StrToRUID(RUID).DBID, ATr);
        D := RuidRec.ID;

        if (D = -1) and (StrToRUID(RUID).XID < cstUserIDStart) then
        begin
          if AnObj.SubSet <> 'ByID' then
            AnObj.SubSet := 'ByID';
          AnObj.ID := StrToRUID(RUID).XID;
          AnObj.Open;

          if not AnObj.EOF then
          begin
            gdcBaseManager.InsertRUID(StrToRUID(RUID).XID,
              StrToRUID(RUID).XID,
              StrToRUID(RUID).DBID, Now, IBLogin.ContactKey, ATr);
            D := StrToRUID(RUID).XID;
          end;
        end;

        if D = -1 then
        begin
          Result := InsertRecord(AMapping, AnObj, UpdateList, RUID);
        end else
        begin
          if AnObj.SubSet <> 'ByID' then
            AnObj.SubSet := 'ByID';
          AnObj.ID := D;
          AnObj.Open;

          if AnObj.EOF then
          begin
            gdcBaseManager.DeleteRUIDbyXID(StrToRUID(RUID).XID,
              StrToRUID(RUID).DBID, ATr);

            Result := InsertRecord(AMapping, AnObj, UpdateList, RUID); 
          end else
          begin
            AddText('Объект найден по РУИДу'#13#10, clBlue);

            if AlwaysOverwrite then
            begin
              AnObj.Edit;
              if CopyRecord(AMapping, AnObj, UpdateList) then
              begin
                AnObj.CheckBrowseMode;

                gdcBaseManager.UpdateRUIDByXID(AnObj.ID,
                  StrToRUID(RUID).XID,
                  StrToRUID(RUID).DBID,
                  now, IBLogin.ContactKey, ATr);
                Result := True;  
              end;
            end else
            begin
              ApplyDelayedUpdates(UpdateList,
                AMapping.ReadString('Properties\RUID'),
                AnObj.ID);
            end;
          end;
        end;

        N := AMapping.FindByName('Set');
        if (N <> nil) and (N is TyamlSequence) then
        begin
          with N as TyamlSequence do
          begin
            for J := 0 to Count - 1 do
              LoadSet(Items[J] as TyamlMapping, AnObj.ID, UpdateList);
          end;
        end;
      finally
        AnObj.BaseState := AnObj.BaseState - [sLoadFromStream];
      end;
    end else
      raise Exception.Create('Invalid fields!');
  finally
    if ULCreated then
      UpdateList.Free;
  end;
end;

class function TgdcNamespaceObject.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'at_object';
end;

class function TgdcNamespaceObject.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'objectname';
end;

class function TgdcNamespaceObject.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + 'ByNamespace;ByObject;ByHeadObject;';
end;

class function TgdcNamespaceObject.GetDialogFormClassName(const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgNamespacePos';
end;

procedure TgdcNamespaceObject.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  if HasSubSet('ByNamespace') then
    S.Add('z.namespacekey = :namespacekey');
  if HasSubSet('ByObject') then
    S.Add('z.namespacekey = :namespacekey and z.xid = :xid and z.dbid = :dbid');
  if HasSubSet('ByHeadObject') then
    S.Add('z.headobjectkey = :headobjectkey');
end;

function TgdcNamespaceObject.GetOrderClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETORDERCLAUSE('TGDCNAMESPACEOBJECT', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCNAMESPACEOBJECT', KEYGETORDERCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETORDERCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCNAMESPACEOBJECT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCNAMESPACEOBJECT',
  {M}          'GETORDERCLAUSE', KEYGETORDERCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETORDERCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TGDCNAMESPACEOBJECT(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCNAMESPACEOBJECT' then
  {M}        begin
  {M}          Result := Inherited GetOrderClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := 'ORDER BY z.objectpos';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCNAMESPACEOBJECT', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCNAMESPACEOBJECT', 'GETORDERCLAUSE', KEYGETORDERCLAUSE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcNamespace.SaveNamespaceToFile(const AFileName: String = '');
var
  FN: String;
  FS: TFileStream;
  SS1251, SSUTF8: TStringStream;
  DidActivate: Boolean;
begin
  DidActivate := not Transaction.InTransaction;
  if DidActivate then
    Transaction.StartTransaction;
  try
    if AFileName > '' then
    begin
      if DirectoryExists(AFileName) then
        FN := IncludeTrailingBackSlash(AFileName) + ObjectName + '.yml'
      else
        FN := AFileName;
    end else
    begin
      FN := QuerySaveFileName('', 'yml', 'Файлы YML|*.yml');
      if FN = '' then
        exit;
    end;

    FS := TFileStream.Create(FN, fmCreate);
    try
      SS1251 := TStringStream.Create('');
      try
        SaveNamespaceToStream(SS1251);
        SSUTF8 := TStringStream.Create(WideStringToUTF8(StringToWideStringEx(
          SS1251.DataString, WIN1251_CODEPAGE)));
        try
          FS.CopyFrom(SSUTF8, 0)
        finally
          SSUTF8.Free;
        end;
      finally
        SS1251.Free;
      end;
    finally
      FS.Free;
    end;

    Edit;
    FieldByName('filename').AsString := FN;
    FieldByName('filetimestamp').AsDateTime := gd_common_functions.GetFileLastWrite(FN);
    Post;
  finally
    if DidActivate and Transaction.InTransaction then
      Transaction.Commit;
  end;
end;

procedure TgdcNamespace._DoOnNewRecord;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCNAMESPACE', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCNAMESPACE', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCNAMESPACE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCNAMESPACE',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCNAMESPACE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCNAMESPACE', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCNAMESPACE', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

procedure TgdcNamespace.DeleteNamespaceWithObjects;
var
  Obj: TgdcNamespaceObject;
  InstID: Integer;
  InstObj: TgdcBase;
  InstClass: TPersistentClass;
begin
  if State <> dsBrowse then
    raise EgdcException.CreateObj('Not in a browse state', Self);

  Obj := TgdcNamespaceObject.Create(nil);
  try
    Obj.SubSet := 'ByNamespace';
    Obj.ParamByName('namespacekey').AsInteger := Self.ID;
    Obj.Open;
    while not Obj.Eof do
    begin
      if Obj.FieldByName('dontremove').AsInteger = 0 then
      begin
        InstID := gdcBaseManager.GetIDByRUID(Obj.FieldByName('xid').AsInteger,
          Obj.FieldByName('dbid').AsInteger);

        InstClass := GetClass(Obj.FieldByName('objectclass').AsString);
        if InstClass <> nil then
        begin
          InstObj := CgdcBase(InstClass).CreateSubType(nil,
            Obj.FieldByName('subtype').AsString, 'ByID');
          try
            InstObj.ID := InstID;
            InstObj.Open;
            if not InstObj.EOF then
              InstObj.Delete;
          finaLLY
            InstObj.Free;
          end;
        end;
      end;
      Obj.Next;
    end;
  finally
    Obj.Free;
  end;

  Delete;
end;

procedure TgdcNamespace.CompareWithData(const AFileName: String);
var
  ScriptComparer: Tprp_ScriptComparer;
  FS: TFileStream;
  SS, SS1251, SSUTF8: TStringStream;
  Tr: TIBTransaction;
  gdcNamespace: TgdcNamespace;
begin
  SSUTF8 := TStringStream.Create('');
  try
    FS := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyNone);
    try
      SSUTF8.CopyFrom(FS, 0);
    finally
      FS.Free;
    end;

    SS1251 := TStringStream.Create(WideStringToStringEx(
      UTF8ToWideString(SSUTF8.DataString), WIN1251_CODEPAGE));
  finally
    SSUTF8.Free;
  end;

  SS := TStringStream.Create('');
  ScriptComparer := Tprp_ScriptComparer.Create(nil);
  try
    if Self.Eof then
    begin
      Tr := TIBTransaction.Create(nil);
      gdcNamespace := TgdcNamespace.Create(nil);
      try
        Tr.DefaultDatabase := gdcBaseManager.Database;
        Tr.StartTransaction;
        gdcNamespace.Transaction := Tr;
        gdcNamespace.ReadTransaction := Tr;
        gdcNamespace.SubSet := 'ByID';
        gdcNamespace.ID := TgdcNamespace.LoadNSInfo(AFileName, Tr);
        gdcNamespace.Open;

        gdcNamespace.SaveNamespaceToStream(SS);
      finally
        if Tr.InTransaction then
          Tr.Rollback;
        Tr.Free;
        gdcNamespace.Free;
      end;
    end else
      SaveNamespaceToStream(SS);


    ScriptComparer.Compare(SS.DataString, SS1251.DataString);
    ScriptComparer.LeftCaption('Текущее состояние в базе данных:');
    ScriptComparer.RightCaption(AFileName);
    ScriptComparer.ShowModal;
  finally
    SS.Free;
    SS1251.Free;
    ScriptComparer.Free;
  end;
end;

procedure TgdcNamespace.SaveNamespaceToStream(St: TStream);
var
  Obj: TgdcNamespaceObject;
  W: TyamlWriter;
  InstID: Integer;
  InstObj: TgdcBase;
  InstClass: TPersistentClass;
  q: TIBSQL;
  HeadObject: String;
begin
  Assert(St <> nil);

  if State <> dsBrowse then
    raise EgdcException.CreateObj('Not in a browse state', Self);

  W := TyamlWriter.Create(St);
  q := TIBSQL.Create(nil);
  try
    if (Transaction = nil) or (not Transaction.InTransaction) then
      q.Transaction := gdcBaseManager.ReadTransaction
    else
      q.Transaction := Transaction;
    W.WriteDirective('YAML 1.1');
    W.StartNewLine;
    W.WriteKey('StructureVersion');
    W.WriteText('1.0', qSingleQuoted);
    W.StartNewLine;
    W.WriteKey('Properties');
    W.IncIndent;
    W.StartNewLine;
    W.WriteKey('RUID');
    W.WriteString(RUIDToStr(GetRUID));
    W.StartNewLine;
    W.WriteKey('Name');
    W.WriteText(FieldByName('name').AsString, qSingleQuoted);
    W.StartNewLine;
    W.WriteKey('Caption');
    W.WriteText(FieldByName('caption').AsString, qSingleQuoted);
    W.StartNewLine;
    W.WriteKey('Version');
    W.WriteString(FieldByName('version').AsString);
    W.StartNewLine;
    W.WriteKey('Optional');
    W.WriteBoolean(FieldByName('optional').AsInteger <> 0);
    W.StartNewLine;
    W.WriteKey('Internal');
    W.WriteBoolean(FieldByName('internal').AsInteger <> 0);
    if FieldByName('dbversion').AsString > '' then
    begin
      W.StartNewLine;
      W.WriteKey('DBVersion');
      W.WriteString(FieldByName('dbversion').AsString);
    end;
    if FieldByName('comment').AsString > '' then
    begin
      W.StartNewLine;
      W.WriteKey('Comment');
      W.WriteText(FieldByName('comment').AsString);
    end;
    W.DecIndent;
    W.StartNewLine;

    q.SQL.Text :=
      'SELECT n.name, (r.xid || ''_'' || r.dbid) as ruid ' +
      'FROM at_namespace_link l JOIN at_namespace n ' +
      '  ON l.useskey = n.id ' +
      '  JOIN gd_ruid r ON r.id = n.id ' +
      'WHERE l.namespacekey = :NK';
    q.ParamByName('NK').AsInteger := Self.ID;
    q.ExecQuery;

    if not q.EOF then
    begin
      W.WriteKey('Uses');
      W.IncIndent;
      while not q.EOF do
      begin
        W.StartNewLine;
        W.WriteSequenceIndicator;
        W.WriteText(GetReferenceString(
          q.FieldByName('ruid').AsString,
          q.FieldByName('name').AsString),
          qSingleQuoted);
        q.Next;
      end;
      W.DecIndent;
      W.StartNewLine;
    end;
    q.Close;
    q.SQL.Text := 'SELECT xid || ''_'' || dbid as ruid FROM at_object WHERE id = :id';

    CheckIncludesiblings;
    Obj := TgdcNamespaceObject.Create(nil);
    try
      Obj.Transaction := Transaction;
      Obj.ReadTransaction := Transaction;
      Obj.SubSet := 'ByNamespace';
      Obj.ParamByName('namespacekey').AsInteger := Self.ID;
      Obj.Open;

      if not Obj.Eof then
      begin
        W.WriteKey('Objects');
        W.IncIndent;
      end;
      while not Obj.Eof do
      begin
        InstID := gdcBaseManager.GetIDByRUID(Obj.FieldByName('xid').AsInteger,
          Obj.FieldByName('dbid').AsInteger);

        InstClass := GetClass(Obj.FieldByName('objectclass').AsString);
        if InstClass <> nil then
        begin
          InstObj := CgdcBase(InstClass).CreateSubType(nil,
            Obj.FieldByName('subtype').AsString, 'ByID');
          try
            InstObj.ID := InstID;
            InstObj.Open;
            if not InstObj.EOF then
            begin
              W.StartNewLine;
              W.WriteSequenceIndicator;
              W.IncIndent;
              try
                W.StartNewLine;
                HeadObject := '';
                if Obj.FieldByName('headobjectkey').AsInteger > 0 then
                begin
                  q.ParamByName('id').AsInteger := Obj.FieldByName('headobjectkey').AsInteger;
                  q.ExecQuery;

                  if not q.Eof then
                    HeadObject := q.FieldByName('ruid').AsString;
                  q.Close;  
                end;
                WriteObject(InstObj, W, HeadObject,
                  Obj.FieldByName('alwaysoverwrite').AsInteger = 1,
                  Obj.FieldByName('dontremove').AsInteger = 1,
                  Obj.FieldByName('includesiblings').AsInteger = 1, Transaction);
              finally
                W.DecIndent;
              end;
            end;
          finaLLY
            InstObj.Free;
          end;
        end;

        Obj.Next;
      end;
    finally
      Obj.Free;
    end;
  finally
    W.Free;
    q.Free;
  end;
end;

class procedure TgdcNamespace.ScanDirectory(ADataSet: TDataSet;
  const APath: String; Log: TNSLog);
var
  I: Integer;
  CurrDir: String;
  NSList: TgsNSList;
  NSNode: TgsNSNode;
  NL: TStringList;
begin
  Assert(ADataSet <> nil);

  NSList := TgsNSList.Create;
  NL := TStringList.Create;
  try
    NSList.Sorted := False;
    NSList.Log := Log;
    NSList.GetFilesForPath(APath);
    NSList.CustomSort(CompareFolder);

    CurrDir := '';

    for I := NSList.Count - 1 downto 0 do
    begin
      NSNode := NSList.Objects[I] as TgsNSNode;

      if ExtractFilePath(NSNode.FileName) <> CurrDir then
      begin
        CurrDir := ExtractFilePath(NSNode.FileName);
        ADataSet.Append;
        ADataSet.FieldByName('filenamespacename').AsString := CurrDir;
        ADataSet.Post;
      end;

      ADataSet.Append;

      ADataSet.FieldByName('filename').AsString := NSNode.FileName;
      ADataSet.FieldByName('filenamespacename').AsString := NSNode.Name;
      ADataSet.FieldByName('fileversion').AsString := NSNode.Version;
      if NSNode.FileTimestamp <> 0 then
        ADataSet.FieldByName('filetimestamp').AsDateTime := NSNode.FileTimestamp;
      ADataSet.FieldByName('filesize').AsInteger := NSNode.Filesize; 

      ADataSet.FieldByName('namespacekey').AsInteger := NSNode.Namespacekey;
      ADataSet.FieldByName('namespacename').AsString := NSNode.NamespaceName;
      ADataSet.FieldByName('namespaceversion').AsString := NSNode.VersionInDB;
      if  NSNode.NamespaceTimestamp <> 0 then
        ADataSet.FieldByName('namespacetimestamp').AsDateTime := NSNode.NamespaceTimestamp;
      case NSNode.GetNSState of
        nsUndefined:
        begin
          if NSNode.VersionInDB > '' then
            ADataSet.FieldByName('operation').AsString := '>>'
          else
            ADataSet.FieldByName('operation').AsString := '';
        end;

        nsNotInstalled, nsNewer: ADataSet.FieldByName('operation').AsString := '<<';
        nsOlder: ADataSet.FieldByName('operation').AsString := '>>';
        nsEqual: ADataSet.FieldByName('operation').AsString := '==';
      end;
      ADataSet.Post;
    end;

    ADataSet.First;
  finally
    NSList.Free;
    NL.Free;
  end;
end;

procedure TgdcNamespace.InstallPackages(ANSList: TStringList;
  const AnAlwaysoverwrite: Boolean = False; const ADontremove: Boolean = False);
var
  AlwaysOverwrite, DontRemove, NSListCreated: Boolean;
begin
  AlwaysOverwrite := AnAlwaysoverwrite;
  DontRemove := ADontremove;
  if ANSList = nil then
  begin
    ANSList := TStringList.Create;
    NSListCreated := True;
  end else
    NSListCreated := False;
  try
    if NSListCreated then
    begin
      with Tat_dlgLoadNamespacePackages.Create(nil) do
      try
        if ShowModal = mrOk then
        begin
          SetFileList(ANSList);
          AlwaysOverwrite := cbAlwaysOverwrite.Checked;
          DontRemove := cbDontRemove.Checked;
        end;
      finally
        Free;
      end;
    end;

    if ANSList.Count > 0 then
      DoLoadNamespace(ANSList, AlwaysOverwrite, DontRemove);
  finally
    if NSListCreated then
      ANSList.Free;
  end;
end;

class procedure TgdcNamespace.SetNamespaceForObject(AnObject: TgdcBase; ANSL: TgdKeyStringAssoc; ATr: TIBTransaction = nil);
var
  q: TIBSQL;
  Index: Integer;
begin
  Assert(AnObject <> nil);
  Assert(ANSL <> nil);

  q := TIBSQL.Create(nil);
  try
    if ATr = nil then
      q.Transaction := gdcBaseManager.ReadTransaction
    else
      q.Transaction := ATr;

    q.SQL.Text :=
      'SELECT n.id, n.name FROM at_object o ' +
      'LEFT JOIN at_namespace n ON o.namespacekey = n.id ' +
      'WHERE o.xid = :xid and o.dbid = :dbid';

    q.ParamByName('xid').AsInteger := AnObject.GetRUID.XID;
    q.ParamByName('dbid').AsInteger := AnObject.GetRUID.DBID;
    q.ExecQuery;
    if not q.EOF then
    begin
      Index := ANSL.Add(q.FieldByName('id').AsInteger);
      ANSL.ValuesByIndex[Index] := q.FieldByName('name').AsString;
    end;
  finally
    q.Free;
  end;
end;


class procedure TgdcNamespace.SetObjectLink(AnObject: TgdcBase; ADataSet: TDataSet; ATr: TIBTransaction);

  procedure GetTableList(Obj: TgdcBase; SL: TStringList);
  var
    LT: TStrings;
    I: Integer;
  begin 
    LT := TStringList.Create;
    try
      (LT as TStringList).Duplicates := dupIgnore;
      GetTablesName(Obj.SelectSQL.Text, LT);
      SL.Clear;
      SL.Add(Obj.GetListTable(Obj.SubType));

      for I := 0 to LT.Count - 1 do
      begin
        if (SL.IndexOf(LT[I]) = -1)
          and (Obj.ClassType.InheritsFrom(GetBaseClassForRelation(LT[I]).gdClass))
        then
          SL.Add(LT[I]);
      end;
    finally
      LT.Free;
    end;
  end; 

  procedure GetBindedObjectsForTable(AnObj: TgdcBase; const ATableName: String);
  const
    NotSavedField = ';CREATORKEY;EDITORKEY;';
  var
    R: TatRelation;
    I, J: Integer;
    C: TgdcFullClass;
    Obj: TgdcBase;
    F: TField;

    SL: TStringList;
    KSA: TgdKeyStringAssoc;
  begin
    R := atDatabase.Relations.ByRelationName(ATableName);
    Assert(R <> nil);

    for I := 0 to R.RelationFields.Count - 1 do
    begin
      if AnsiPos(';' + Trim(R.RelationFields[I].FieldName) + ';', NotSavedField) > 0 then
        continue;

      F := AnObj.FindField(R.RelationName, R.RelationFields[I].FieldName);
      if (F = nil) or F.IsNull or (F.DataType <> ftInteger) then
      begin
        continue;
      end;

      if R.RelationFields[I].gdClass <> nil then
      begin
        C.gdClass := CgdcBase(R.RelationFields[I].gdClass);
        C.SubType := R.RelationFields[I].gdSubType;
      end else
      begin
        C.gdClass := nil;
        C.SubType := '';
      end;

      if (C.gdClass = nil) and (R.RelationFields[I].References <> nil) then
      begin
        C := GetBaseClassForRelationByID(R.RelationFields[I].References.RelationName,
          AnObj.FieldByName(R.RelationName, R.RelationFields[I].FieldName).AsInteger,
          ATr);
      end;

      if (C.gdClass <> nil)
        and
        (F.AsInteger > cstUserIDStart)
        and
        (F.AsInteger <> AnObj.ID) then
      begin
        Obj := C.gdClass.CreateSingularByID(nil,
          ATr.DefaultDatabase,
          ATr,
          F.AsInteger,
          C.SubType);
        try
          if not ADataSet.Locate('id', Obj.ID, []) then
          begin
            ADataSet.Append;
            ADataSet.FieldByName('id').AsInteger := Obj.ID;
            ADataSet.FieldByName('name').AsString := Obj.ObjectName;
            ADataSet.FieldByname('class').AsString := Obj.ClassName;
            ADataSet.FieldByName('subtype').AsString := Obj.SubType;
            ADataSet.FieldByName('headobject').AsString := RUIDToStr(AnObj.GetRUID);
            if Obj.SubType > '' then
              ADataSet.FieldByName('displayname').AsString := Obj.ClassName + '\' + Obj.SubType
            else
              ADataSet.FieldByName('displayname').AsString := Obj.ClassName;
            ADataSet.FieldByName('displayname').AsString := ADataSet.FieldByName('displayname').AsString +
              '/' + Obj.ObjectName;
            KSA := TgdKeyStringAssoc.Create;
            try
              SetNamespaceForObject(Obj, KSA, ATr);
              if KSA.Count > 0 then
              begin
                ADataSet.FieldByName('namespacekey').AsInteger := KSA[0];
                ADataSet.FieldByName('namespace').AsString := KSA.ValuesByIndex[0];
                ADataSet.FieldByName('displayname').AsString := ADataSet.FieldByName('displayname').AsString +
                  '/' + KSA.ValuesByIndex[0];
              end;
            finally
              KSA.Free;
            end;
            ADataSet.Post;

            SL := TStringList.Create;
            try
              GetTableList(Obj, SL);
              for J := 0 to SL.Count - 1 do
                GetBindedObjectsForTable(Obj, SL[J]);
              if Obj.SetTable > '' then
                GetBindedObjectsForTable(Obj, Obj.SetTable);
            finally
              SL.Free;
            end;
          end;
        finally
          Obj.Free;
        end;
      end;
    end;
  end;

var
  LinkTableList: TStringList;
  I: Integer;
begin
  Assert(atDatabase <> nil);
  Assert(ADataSet <> nil);

  if (ATr = nil) or (not ATr.InTransaction) then
    raise Exception.Create('Invalid transaction!');

  LinkTableList := TStringList.Create;
  try
    GetTableList(AnObject, LinkTableList);

    for I := 0 to LinkTableList.Count - 1 do
      GetBindedObjectsForTable(AnObject, LinkTableList[I]);

    if AnObject.SetTable > '' then
      GetBindedObjectsForTable(AnObject, AnObject.SetTable);
  finally
    LinkTableList.Free;
  end;
end;

class procedure TgdcNamespace.AddObject(ANamespacekey: Integer;
  const AName: String; const AClass: String; const ASubType: String;
  xid, dbid: Integer; ATr: TIBTransaction; AnAlwaysoverwrite: Integer = 1;
  ADontremove: Integer = 0; AnIncludesiblings: Integer = 0);
var
  q, SQL: TIBSQL;
begin
  if (ATr = nil) or (not ATr.InTransaction) then
    raise Exception.Create('Invalid transaction!');

  q := TIBSQL.Create(nil);
  SQL := TIBSQL.Create(nil);
  try
    q.Transaction := ATr;

    SQL.Transaction := ATr;
    SQL.SQL.Text :=
      'SELECT * FROM at_object ' +
      'WHERE namespacekey <> :nk and xid = :xid and dbid = :dbid';
    SQL.ParamByName('nk').AsInteger := ANamespacekey;
    SQL.ParamByName('xid').AsInteger := xid;
    SQL.ParamByName('dbid').AsInteger := dbid;
    SQL.ExecQuery;

    if (not SQL.Eof) then
    begin
      q.SQL.Text := 'UPDATE OR INSERT INTO at_namespace_link ' +
        '  (namespacekey, useskey) ' +
        'VALUES (:nk, :uk) ' +
        'MATCHING (namespacekey, useskey)';
      q.ParamByName('nk').AsInteger := ANamespacekey;
      q.ParamByName('uk').AsInteger := SQL.FieldByName('namespacekey').AsInteger;
      q.ExecQuery;
    end else
    begin
      q.SQL.Text :=
        'UPDATE OR INSERT INTO at_object ' +
        '  (namespacekey, objectname, objectclass, subtype, xid, dbid, ' +
        '  alwaysoverwrite, dontremove, includesiblings) ' +
        'VALUES (:NSK, :ON, :OC, :ST, :XID, :DBID, :OW, :DR, :IS) ' +
        'MATCHING (xid, dbid, namespacekey)';
      q.ParamByName('NSK').AsInteger := ANamespacekey;
      q.ParamByName('ON').AsString := AName;
      q.ParamByName('OC').AsString := AClass;
      q.ParamByName('ST').AsString := ASubType;
      q.ParamByName('XID').AsInteger := XID;;
      q.ParamByName('DBID').AsInteger := DBID;
      q.ParamByName('OW').AsInteger := AnAlwaysOverwrite;
      q.ParamByName('DR').AsInteger := ADontRemove;
      q.ParamByName('IS').AsInteger := AnIncludeSiblings;
      q.ExecQuery;
    end;
  finally
    q.Free;
  end;
end;

procedure TgdcNamespace.AddObject2(AnObject: TgdcBase; AnUL: TObjectList;
  const AHeadObjectRUID: String = ''; AnAlwaysOverwrite: Integer = 1;
  ADontRemove: Integer = 0; AnIncludeSiblings: Integer = 0);

  procedure HeadObjectUpdate(UL: TObjectList; SourceRUID: String; TargetKeyValue: Integer);
  var
    I: Integer;
    q: TIBSQL;
  begin
    q := TIBSQL.Create(nil);
    try
      q.Transaction := Transaction;
      q.SQL.Text :=
        'UPDATE at_object SET headobjectkey = :hk ' +
        'WHERE namespacekey = :nk AND xid = :xid AND dbid = :dbid';
      for I := UL.Count - 1 downto 0 do
      begin
        if ((UL[I] as TgdcHeadObjectUpdate).RefRUID = SourceRUID)
          and ((UL[I] as TgdcHeadObjectUpdate).NamespaceKey = Self.ID) then
        begin
          q.ParamByName('hk').AsInteger := TargetKeyValue;
          q.ParamByName('nk').AsInteger := Self.ID;
          q.ParamByName('xid').AsInteger := StrToRUID((UL[I] as TgdcHeadObjectUpdate).RUID).XID;
          q.ParamByName('dbid').AsInteger := StrToRUID((UL[I] as TgdcHeadObjectUpdate).RUID).dbid;
          q.ExecQuery;

          UL.Delete(I);
        end;
      end;
    finally
      q.Free;
    end;
  end; 
var
  q: TIBSQL;
  HO: TgdcHeadObjectUpdate;
  gdcNamespaceObject: TgdcNamespaceObject;
begin
  Assert(AnObject <> nil);
  Assert(not AnObject.Eof);

  q := TIBSQL.Create(nil);
  try
    q.Transaction := Transaction;
    q.SQL.Text :=
      'EXECUTE BLOCK(namespacekey INTEGER = :nk, xid INTEGER = :xid, dbid INTEGER = :dbid) ' +
      'RETURNS (res integer) ' +
      'AS ' +
        'DECLARE VARIABLE tempkey INTEGER; ' +
      'BEGIN ' +
      '  FOR SELECT namespacekey FROM at_object ' +
      '    WHERE namespacekey <> :namespacekey ' +
      '      AND xid = :xid AND dbid = :dbid INTO :tempkey  ' +
      '  DO BEGIN ' +
      '    UPDATE OR INSERT INTO at_namespace_link ' +
      '      (namespacekey, useskey) ' +
      '    VALUES (:namespacekey, :tempkey) ' +
      '    MATCHING (namespacekey, useskey); ' +
      '    res = 1; ' +
      '    SUSPEND; ' +
      '    BREAK; ' +
      '  END ' +
      'END ';
    q.ParamByName('nk').AsInteger := Self.ID;
    q.ParamByName('xid').AsInteger := AnObject.GetRUID.XID;
    q.ParamByName('dbid').AsInteger := AnObject.GetRUID.DBID;
    q.ExecQuery;

    if q.Eof then
    begin
      gdcNamespaceObject := TgdcNamespaceObject.Create(nil);
      try
        gdcNamespaceObject.Transaction := Transaction;
        gdcNamespaceObject.SubSet := 'ByObject';
        gdcNamespaceObject.ParamByName('namespacekey').AsInteger := Self.ID;
        gdcNamespaceObject.ParamByName('xid').AsInteger := AnObject.GetRUID.XID;
        gdcNamespaceObject.ParamByName('dbid').AsInteger := AnObject.GetRUID.DBID;
        gdcNamespaceObject.Open;

        if gdcNamespaceObject.Eof then
        begin
          gdcNamespaceObject.Insert;
          gdcNamespaceObject.FieldByName('namespacekey').AsInteger := Self.ID;
          gdcNamespaceObject.FieldByName('objectname').AsString := AnObject.FieldByName(AnObject.GetListField(AnObject.SubType)).AsString;
          gdcNamespaceObject.FieldByName('objectclass').AsString :=  AnObject.ClassName;
          gdcNamespaceObject.FieldByName('subtype').AsString := AnObject.SubType;
          gdcNamespaceObject.FieldByName('xid').AsInteger := AnObject.GetRUID.XID;
          gdcNamespaceObject.FieldByName('dbid').AsInteger := AnObject.GetRUID.DBID;
          gdcNamespaceObject.FieldByName('alwaysoverwrite').AsInteger := AnAlwaysOverwrite;
          gdcNamespaceObject.FieldByName('dontremove').AsInteger := ADontRemove;
          gdcNamespaceObject.FieldByName('includesiblings').AsInteger := AnIncludeSiblings;
          if Trim(AHeadObjectRUID) <> '' then
          begin
            q.Close;
            q.SQL.Text := 'SELECT * FROM at_object WHERE namespacekey = :nk and xid || ''_'' ||dbid = :r';
            q.ParamByName('nk').AsInteger := Self.ID;
            q.ParamByName('r').AsString := AHeadObjectRUID;
            q.ExecQuery;

            if not q.Eof then
            begin
              gdcNamespaceObject.FieldByName('headobjectkey').AsInteger := q.FieldByName('id').AsInteger;
            end else
            begin
              HO := TgdcHeadObjectUpdate.Create;
              HO.NamespaceKey := Self.ID;
              HO.RUID := RUIDToStr(AnObject.GetRUID);
              HO.RefRUID := AHeadObjectRUID;
              AnUL.Add(HO);
            end;
          end;
          gdcNamespaceObject.Post;
        end;

        HeadObjectUpdate(AnUL, RUIDToStr(AnObject.GetRUID), gdcNamespaceObject.ID);
      finally
        gdcNamespaceObject.Free;
      end;
    end;
  finally
    q.Free;
  end;
end;

procedure TgdcNamespace.DeleteObject(xid, dbid: Integer; RemoveObj: Boolean = True);
var
  gdcNamespaceObject: TgdcNamespaceObject;
  q: TIBSQL;
  InstID: Integer;
  InstObj: TgdcBase;
  InstClass: TPersistentClass;
begin
  gdcNamespaceObject := TgdcNamespaceObject.Create(nil);
  q := TIBSQL.Create(nil);
  try
    q.Transaction := Transaction;
    q.SQL.Text :=
      'SELECT * FROM at_object ' +
      'WHERE namespacekey <> :nk and xid = :xid and dbid = :dbid';
    gdcNamespaceObject.Transaction := Transaction;
    gdcNamespaceObject.SubSet := 'ByObject';
    gdcNamespaceObject.ParamByName('namespacekey').AsInteger := Self.ID;
    gdcNamespaceObject.ParamByName('xid').AsInteger := xid;
    gdcNamespaceObject.ParamByName('dbid').AsInteger := dbid;
    gdcNamespaceObject.Open;

    if not gdcNamespaceObject.Eof  then
    begin
      if RemoveObj then
      begin
        q.ParamByName('nk').AsInteger := Self.ID;
        q.ParamByName('xid').AsInteger := xid;
        q.ParamByName('dbid').AsInteger := dbid;
        q.ExecQuery;

        if q.Eof and (RemoveObj or (gdcNamespaceObject.FieldByName('dontremove').AsInteger = 0)) then
        begin
          InstID := gdcBaseManager.GetIDByRUID(gdcNamespaceObject.FieldByName('xid').AsInteger,
            gdcNamespaceObject.FieldByName('dbid').AsInteger);

          InstClass := GetClass(gdcNamespaceObject.FieldByName('objectclass').AsString);
          if InstClass <> nil then
          begin
            InstObj := CgdcBase(InstClass).CreateSubType(nil,
              gdcNamespaceObject.FieldByName('subtype').AsString, 'ByID');
            try
              InstObj.ID := InstID;
              InstObj.Open;
              if not InstObj.EOF then
                InstObj.Delete;
            finaLLY
              InstObj.Free;
            end;
          end;
        end;
        q.Close;
      end;
      gdcNamespaceObject.Delete;
    end;
  finally
    gdcNamespaceObject.Free;
    q.Free;
  end;
end;

function TgdcNamespace.GetOrderClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETORDERCLAUSE('TGDCNAMESPACE', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCNAMESPACE', KEYGETORDERCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETORDERCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCNAMESPACE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCNAMESPACE',
  {M}          'GETORDERCLAUSE', KEYGETORDERCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETORDERCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TGDCNAMESPACE(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCNAMESPACE' then
  {M}        begin
  {M}          Result := Inherited GetOrderClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if HasSubSet('OrderByName') then
    Result := 'ORDER BY z.name'
  else
    Result := '';  

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCNAMESPACE', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCNAMESPACE', 'GETORDERCLAUSE', KEYGETORDERCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcNamespace.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + 'OrderByName;BySettingRUID;';
end;

procedure TgdcNamespace.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  if HasSubSet('BySettingRUID') then
    S.Add('z.settingruid=:SettingRUID');
end;

initialization
  RegisterGDCClass(TgdcNamespace);
  RegisterGDCClass(TgdcNamespaceObject);

finalization
  UnRegisterGDCClass(TgdcNamespace);
  UnRegisterGDCClass(TgdcNamespaceObject);
end.
