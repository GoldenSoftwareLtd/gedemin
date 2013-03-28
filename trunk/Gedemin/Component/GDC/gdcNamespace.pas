
unit gdcNamespace;

interface

uses
  SysUtils, gdcBase, gdcBaseInterface, Classes, gd_ClassList, gd_createable_form,
  at_classes, IBSQL, db, yaml_writer, yaml_parser, IBDatabase, gd_security, dbgrids,
  gd_KeyAssoc, contnrs, IB, gsTreeView;

const
  nvNotInstalled = 1;
  nvNewer = 2;
  nvEqual = 3;
  nvOlder = 4;
  nvIndefinite = 5;
  
type
  TgsyamlList = class;
  TgdcNamespace = class(TgdcBase)
  private
    procedure CheckIncludesiblings; 
  protected
    function GetOrderClause: String; override;
    procedure _DoOnNewRecord; override;
    procedure GetWhereClauseConditions(S: TStrings); override;
  public
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetSubSetList: String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;

    class procedure WriteObject(AgdcObject: TgdcBase; AWriter: TyamlWriter; const AHeadObject: String; AnAlwaysoverwrite: Boolean = True;
      ADontremove: Boolean = False; AnIncludesiblings: Boolean = False);
    class procedure LoadObject(AnObj: TgdcBase; AMapping: TyamlMapping; UpdateList: TObjectList; ATr: TIBTransaction);
    class procedure ScanDirectory(ADataSet: TDataSet; const APath: String;
      Messages: TStrings);

    class procedure ScanLinkNamespace(ADataSet: TDataSet; const APath: String);
    class procedure ScanLinkNamespace2(const APath: String);
    class procedure InstallPackages;
    class procedure SetNamespaceForObject(AnObject: TgdcBase; ANSL: TgdKeyStringAssoc; ATr: TIBTransaction = nil);
    class procedure SetObjectLink(AnObject: TgdcBase; ADataSet: TDataSet; ATr: TIBTransaction);
    class procedure AddObject(ANamespacekey: Integer; const AName: String; const AClass: String; const ASubType: String;
      xid, dbid: Integer; ATr: TIBTransaction; AnAlwaysoverwrite: Integer = 1; ADontremove: Integer = 0; AnIncludesiblings: Integer = 0);

    class procedure FillTree(ATreeView: TgsTreeView; AList: TgsyamlList; AnInternal: Boolean);
    procedure AddObject2(AnObject: TgdcBase; AnUL: TObjectList; const AHeadObjectRUID: String = ''; AnAlwaysOverwrite: Integer = 1; ADontRemove: Integer = 0; AnIncludeSiblings: Integer = 0);
    procedure DeleteObject(xid, dbid: Integer; RemoveObj: Boolean = True);
    function MakePos: Boolean;
    procedure LoadFromFile(const AFileName: String = ''); override;
    procedure DoLoadNamespace(ANamespaceList: TStringList);
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

  TgsyamlNode = class(TObject)
  public
    IsCreate: Boolean;
    RUIDUses: TStringList;
    Name: String;
    Caption: String;
    Filename: String;
    Filetimestamp: TDateTime;
    Version: String;
    DBVersion: String;
    Optional: Boolean;
    Internal: Boolean;
    Comment: String;
    Settingruid: String;
    VersionInDB: String;

    constructor Create; virtual;
    destructor Destroy; override;
  end;

  TgsyamlList = class(TStringList)
  private
    function Valid(ANode: TgsyamlNode): Boolean;  
  public
    destructor Destroy; override;
    function AddObject(const S: string; AObject: TObject): Integer; override;
    procedure GetFilesForPath(Path: String);
    procedure Clear; override;
  end;


  procedure Register;


implementation

uses
  Windows, Controls, ComCtrls, gdc_dlgNamespacePos_unit, gdc_dlgNamespace_unit, gdc_frmNamespace_unit,
  at_sql_parser, jclStrings, gdcTree, yaml_common, gd_common_functions,
  prp_ScriptComparer_unit, gdc_dlgNamespaceObjectPos_unit, jclUnicode,
  at_frmSyncNamespace_unit, jclFileUtils, gd_directories_const, gd_FileList_unit,
  gdcClasses, at_sql_metadata, gdcConstants, at_frmSQLProcess, Graphics, IBErrorCodes,
  Storages, gdcMetadata, at_sql_setup, gsDesktopManager, at_dlgLoadNamespacePackages_unit;

const
  cst_str_WithoutName = 'Без наименования';

type
  TgdcReferenceUpdate = class(TObject)
  public
    FieldName: String;
    FullClass: TgdcFullClass;
    ID: TID;
    RefRUID: String;
  end;

  TgdcHeadObjectUpdate = class(TObject)
  public
    Namesapcekey: Integer;
    RUID: String;
    RefRUID: String;
  end;

procedure Register;
begin
  RegisterComponents('gdcNamespace', [TgdcNamespace, TgdcNamespaceObject]);
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

class procedure TgdcNamespace.WriteObject(AgdcObject: TgdcBase; AWriter: TyamlWriter; const AHeadObject: String; AnAlwaysoverwrite: Boolean = True;
  ADontremove: Boolean = False; AnIncludesiblings: Boolean = False);

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
      q.Transaction := gdcBaseManager.ReadTransaction;
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
            q.ParamByName('rf').AsString := AObj.FieldByName(F.ReferencesField.FieldName).AsString;
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
                    AWriter.WriteString(gdcBaseManager.GetRUIDStringByID(q.Fields[0].AsInteger, AObj.Transaction));
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
  PassFieldName = ';ID;EDITIONDATE;CREATIONDATE;CREATORKEY;EDITORKEY;ACHAG;AVIEW;AFULL;LB;RB;RESERVED' +
                  ';ENTEREDPARAMS;BREAKPOINTS;EDITORSTATE;TESTRESULT;RDB$PROCEDURE_BLR;RDB$TRIGGER_BLR;RDB$VIEW_BLR' +
                  ';LASTEXTIME;';
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
                AWriter.WriteString(gdcBaseManager.GetRUIDStringByID(F.AsInteger, AgdcObject.Transaction));
                AWriter.WriteChar(' ');
                AWriter.WriteText(FN, qSingleQuoted);
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
    q.SQL.Text := 'SELECT * FROM at_object WHERE namespacekey = :NK ORDER BY objectpos';
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
    SelectPos.SQL.Text := 'SELECT * FROM at_object WHERE namespacekey = :nk ' +
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

procedure TgdcNamespace.DoLoadNamespace(ANamespaceList: TStringList);
var
  Tr: TIBTransaction;
  RelName: String;

  procedure FillObjectsRUIDInDB(const RUID: String; SL: TStringList);
  var
    q: TIBSQL;
  begin
    Assert(SL <> nil);

    q := TIBSQL.Create(nil);
    try
      q.Transaction := Tr;
      q.SQL.Text := 'SELECT o.xid || ''_'' || o.dbid as ruid ' +
        'FROM at_object o ' +
        '  LEFT JOIN at_namespace n ' +
        '    ON n.id = o.namespacekey ' +
        'WHERE n.settingruid = :r';
      q.ParamByName('r').AsString := RUID;
      q.ExecQuery;

      if not q.Eof then
        SL.Add(q.FieldByName('ruid').AsString);
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

  procedure HeadObjectUpdate(UL: TStringList; NamespaceKey: Integer; SourceRUID: String; TargetKeyValue: Integer);
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
        q.SQL.Text := 'UPDATE at_object SET headobjectkey = :hk WHERE namespacekey = :nk AND xid = :xid AND dbid = :dbid';
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
    I, J: Integer;
    gdcNamespace: TgdcNamespace;
    Temps, RUID: String;
    q: TIBSQL;
  begin
    if Seq.Count > 0 then
    begin
      gdcNamespace := TgdcNamespace.Create(nil);
      q := TIBSQL.Create(nil);
      try
        q.Transaction := Tr;
        q.SQL.Text := 'UPDATE OR INSERT INTO at_namespace_link ' +
          '(namespacekey, useskey) ' +
          'VALUES (:NK, :UK) ' +
          'MATCHING (namespacekey, useskey)';
        gdcNamespace.Transaction := Tr;
        gdcNamespace.ReadTransaction := Tr;
        gdcNamespace.SubSet := 'ByID';
        for I := 0 to Seq.Count - 1 do
        begin
          Temps := (Seq[I] as TyamlString).AsString;
          RUID := '';
          for J := 1 to Length(Temps) do
          begin
            if Temps[J] in ['0'..'9', '_'] then
              RUID := RUID + Temps[J]
            else
              break;
          end;

          if CheckRUID(RUID) then
          begin
            gdcNamespace.Close;
            gdcNamespace.ID := gdcBaseManager.GetIDByRUIDString(RUID, Tr);
            gdcNamespace.Open;
            if gdcNamespace.Eof then
            begin
              gdcBaseManager.DeleteRUIDbyXID(StrToRUID(RUID).XID, StrToRUID(RUID).DBID, Tr);
              gdcNamespace.Insert;
              gdcNamespace.FieldByName('name').AsString := System.Copy(Temps, J + 1, Length(Temps));
              gdcNamespace.FieldByName('settingruid').AsString := RUID;
              gdcNamespace.Post;

              if gdcBaseManager.GetRUIDRecByID(gdcNamespace.ID, Tr).XID = -1 then
              begin
                gdcBaseManager.InsertRUID(gdcNamespace.ID, StrToRUID(gdcNamespace.FieldByName('settingruid').AsString).XID,
                  StrToRUID(gdcNamespace.FieldByName('settingruid').AsString).DBID,
                  Now, IBLogin.ContactKey, Tr);
              end else
              begin
                gdcBaseManager.UpdateRUIDByID(gdcNamespace.ID, StrToRUID(gdcNamespace.FieldByName('settingruid').AsString).XID,
                  StrToRUID(gdcNamespace.FieldByName('settingruid').AsString).DBID,
                  Now, IBLogin.ContactKey, Tr);
              end;

              q.Close;
              q.ParamByName('nk').AsInteger := Namespacekey;
              q.ParamByName('uk').AsInteger := gdcNamespace.ID;
              q.ExecQuery;
            end;
          end;
        end;
      finally
        gdcNamespace.Free;
        q.Free;
      end;
    end;
  end;

  function UpdateNamespace(Source: TgdcNamespace; CurrOL, LoadOL: TStringList): Integer;
  const
    DontCopyList = ';ID;NAME;NAMESPACEKEY;';
  var
    I: Integer;
    gdcNamespaceObj: TgdcNamespaceObject;
    Dest: TgdcNamespace;
    DestObj: TgdcNamespaceObject;
  begin
    Result := -1;
    Dest := TgdcNamespace.Create(nil);
    try
      Dest.Transaction := Tr;
      Dest.ReadTransaction := Tr;
      Dest.SubSet := 'ByID';
      Dest.ID := gdcBaseManager.GetIDByRUIDString(Source.FieldByName('settingruid').AsString, Tr);
      Dest.Open;

      if Dest.Eof then
      begin
        gdcBaseManager.DeleteRUIDbyXID(StrToRUID(Source.FieldByName('settingruid').AsString).XID, StrToRUID(Source.FieldByName('settingruid').AsString).DBID, Tr);
        Dest.Insert;
      end else
        Dest.Edit;

      for I := 0 to Dest.FieldCount - 1 do
      begin
        if (StrIPos(';' + Dest.Fields[I].FieldName + ';', DontCopyList) = 0) then
          Dest.Fields[I].Value := Source.FieldByName(Dest.Fields[I].FieldName).Value;
      end;

      Dest.FieldByName('name').AsString := System.Copy(Source.FieldByName('name').AsString, 6, Length(Source.FieldByName('name').AsString));
      Dest.Post;

      if gdcBaseManager.GetRUIDRecByID(Dest.ID, Tr).XID = -1 then
      begin
        gdcBaseManager.InsertRUID(Dest.ID, StrToRUID(Dest.FieldByName('settingruid').AsString).XID,
          StrToRUID(Dest.FieldByName('settingruid').AsString).DBID,
          Now, IBLogin.ContactKey, Tr);
      end else
      begin
        gdcBaseManager.UpdateRUIDByID(Dest.ID, StrToRUID(Dest.FieldByName('settingruid').AsString).XID,
          StrToRUID(Dest.FieldByName('settingruid').AsString).DBID,
          Now, IBLogin.ContactKey, Tr);
      end;

      for I := 0 to CurrOL.Count - 1 do
      begin
        if LoadOL.IndexOf(CurrOL[I]) = -1 then
          Dest.DeleteObject(StrToRUID(CurrOL[I]).XID, StrToRUID(CurrOL[I]).DBID);
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
              DestObj.ParamByName('xid').AsInteger := gdcNamespaceObj.FieldByName('xid').AsInteger;
              DestObj.ParamByName('dbid').AsInteger := gdcNamespaceObj.FieldByName('dbid').AsInteger;
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
  I, J, Ind: Integer;
  gdcNamespace: TgdcNamespace;
  TempNamespaceID: Integer;
  M, ObjMapping: TyamlMapping;
  N: TyamlNode;
  RUID, HeadRUID: String;
  WasMetaData: Boolean;
  LoadClassName, LoadSubType: String;
  C: TClass;
  ObjList: TStringList;
  Obj: TgdcBase;
  gdcNamespaceObj: TgdcNamespaceObject;
  UpdateList: TObjectList;
  UpdateHeadList: TStringList;
  q: TIBSQL;
  CurrID: Integer;
begin
  LoadNamespace:= TStringlist.Create;
  LoadObjectsRUID := TStringList.Create;
  CurrObjectsRUID := TStringList.Create;
  UpdateList := TObjectList.Create(True);
  ObjList := TStringList.Create;
  UpdateHeadList := TStringList.Create;
  q := TIBSQL.Create(nil);
  Tr := TIBTransaction.Create(nil);
  Parser := TyamlParser.Create;
  try
    Tr.DefaultDatabase := IBLogin.Database;
    Tr.Params.Add('nowait');
    Tr.Params.Add('read_committed');
    Tr.Params.Add('rec_version');
    ConnectDatabase;
    Obj := nil;
    q.Transaction := Tr;
    q.SQL.Text := 'SELECT * FROM at_object WHERE xid || ''_'' || dbid = :r AND namespacekey = :nk';
    try
      if (GlobalStorage <> nil) and GlobalStorage.IsModified then
      GlobalStorage.SaveToDatabase;

      if (UserStorage <> nil) and UserStorage.IsModified then
        UserStorage.SaveToDatabase;

      if (CompanyStorage <> nil) and CompanyStorage.IsModified then
        CompanyStorage.SaveToDatabase;

      DesktopManager.WriteDesktopData('Последний', True);

      for I := 0 to ANamespaceList.Count - 1 do
      begin
        if LoadNamespace.IndexOf(ANamespaceList[I]) > -1 then
          continue;
        WasMetaData := False;
        for J := 0 to UpdateHeadList.Count - 1 do
          UpdateHeadList.Objects[J].Free;
        UpdateHeadList.Clear;
        LoadObjectsRUID.Clear;
        CurrObjectsRUID.Clear;

        Parser.Parse(ANamespaceList[I]);

        if (Parser.YAMLStream.Count > 0)
          and ((Parser.YAMLStream[0] as TyamlDocument).Count > 0)
          and ((Parser.YAMLStream[0] as TyamlDocument)[0] is TyamlMapping) then
        begin
          M := (Parser.YAMLStream[0] as TyamlDocument)[0] as TyamlMapping;
          RUID := M.ReadString('Properties\RUID');


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
            gdcNamespace.FieldByName('settingruid').AsString := RUID;
            gdcNamespace.Post;
            TempNamespaceID := gdcNamespace.ID;
          finally
            gdcNamespace.Free;
          end;

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

                if CgdcBase(C).InheritsFrom(TgdcMetaBase) then
                  WasMetaData := True;

                if (Obj = nil)
                  or (Obj.ClassType <> C)
                  or (LoadSubType <> Obj.SubType) then
                begin
                  Ind := ObjList.IndexOf(LoadClassName + '('+ LoadSubType + ')');
                  if Ind = -1 then
                  begin
                    Obj := CgdcBase(C).CreateWithParams(nil,
                      Tr.DefaultDatabase, Tr, LoadSubType);
                    Obj.ReadTransaction := Tr;
                    Obj.SetRefreshSQLOn(False);
                    ObjList.AddObject(LoadClassName + '('+ LoadSubType + ')', Obj);
                    ObjList.Sort;
                  end else
                    Obj := TgdcBase(ObjList.Objects[Ind]);
                end;

                try
                  if Obj.SubSet <> 'ByID' then
                    Obj.SubSet := 'ByID';
                  Obj.Open;
                except
                  ReconnectDatabase;
                  Obj.Open;
                end;

                LoadObject(Obj, ObjMapping, UpdateList, Tr);
                LoadObjectsRUID.Add(RUIDToStr(Obj.GetRUID));

                if (Obj is TgdcRelationField) then
                  RelName := Obj.FieldByName('relationname').AsString
                else
                  RelName := '';

                RunMultiConnection;

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
                    gdcNamespaceObj.FieldByName('objectname').AsString := Obj.FieldByName(Obj.GetListField(Obj.SubType)).AsString;
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
                  HeadObjectUpdate(UpdateHeadList, TempNamespaceID, RUIDToStr(Obj.GetRUID), gdcNamespaceObj.ID);
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
              CurrID := UpdateNamespace(gdcNamespace, CurrObjectsRUID, LoadObjectsRUID);
              gdcNamespace.Delete;
              N := M.FindByName('USES');
              if (N <> nil) and (N is TyamlSequence) and (CurrID > -1) then
                CheckUses(N as TyamlSequence, CurrID);
            end;
          finally
            gdcNamespace.Free;
          end;

          LoadNamespace.Add(ANamespaceList[I]);

          if WasMetaData then
            ReconnectDatabase;
        end;
      end;

      DisconnectDatabase(True);
    except
      on E: Exception do
      begin
        if Tr.InTransaction then
          Tr.Rollback;
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
      Parser.Free;
      UpdateList.Free;
      q.Free;
      for I := 0 to UpdateHeadList.Count - 1 do
        UpdateHeadList.Objects[I].Free;
      UpdateHeadList.Free;

      for I := 0 to ObjList.Count - 1 do
        ObjList.Objects[I].Free;
      ObjList.Free;
      Tr.Free;
    end;
  end;
end;

class procedure TgdcNamespace.LoadObject(AnObj: TgdcBase; AMapping: TyamlMapping; UpdateList: TObjectList; ATr: TIBTransaction);

  procedure InsertRecord(SourceYAML: TyamlMapping; Obj: TgdcBase; UL: TObjectList; const ID: Integer = -1); forward;
  
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
  begin
    for I := UL.Count - 1 downto 0 do
    begin
      if (UL[I] as TgdcReferenceUpdate).RefRUID = SourceRUID then
      begin
        // На обновление полей в б-о могут быть заданы к-л операции => Сделано через б-о, а не через ibsql
        Obj := (UL[I] as TgdcReferenceUpdate).FullClass.gdClass.CreateSubType(nil,
          (UL[I] as TgdcReferenceUpdate).FullClass.SubType, 'ByID');
        try
          // Транзакция должна быть открыта
          Obj.Transaction := ATr;
          Obj.ReadTransaction := ATr;
          Obj.ID := (UL[I] as TgdcReferenceUpdate).ID;
          Obj.Open;
          if Obj.RecordCount > 0 then
          begin
            Obj.BaseState := Obj.BaseState + [sLoadNamespace, sLoadFromStream];
            Obj.Edit;
            Obj.FieldByName((UL[I] as TgdcReferenceUpdate).FieldName).AsInteger := TargetKeyValue;
            Obj.Post;
          end;
        finally
          Obj.Free;
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

  function ExtractRUID(const ARUID: String): String;
  var
    I: Integer;
  begin
    Result := '';
    for I := 1 to Length(ARUID) do
    begin
      if ARUID[I] in ['0'..'9', '_'] then
        Result := Result + ARUID[I]
      else
        break;
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
    RUID, RefRUID: String;
  begin
    Result := False;
    RUOL := nil;
    try
      Fields := SourceYAML.FindByName('Fields') as TyamlMapping;
      RUID := SourceYAML.ReadString('Properties\RUID');
      for I := 0 to Obj.Fields.Count - 1 do
      begin
        TargetField := Obj.Fields[I];

        N := Fields.FindByName(TargetField.FieldName);
        if (N <> nil) and (TargetField <> nil) then
        begin
          if not (N is TyamlScalar) then
            raise Exception.Create('Invalid yaml data type!');

          R := atDatabase.Relations.ByRelationName(Obj.RelationByAliasName(TargetField.FieldName));
          if R = nil then
          begin
            if (AnsiCompareText(TargetField.FieldName, Obj.GetKeyField(Obj.SubType)) = 0) then
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

          if (AnsiCompareText(TargetField.FieldName, Obj.GetKeyField(Obj.SubType)) = 0) then
          begin
            if (F <> nil) and (F.References <> nil) then
            begin
              if not (N is TyamlString) then
                raise Exception.Create('Invalid YAML data type!');

              RefRUID := ExtractRUID(TyamlString(N).AsString);

              if CheckRUID(RefRUID) then
              begin
                Key := gdcBaseManager.GetIDByRUIDString(RefRUID, ATr);
                if Key > -1 then
                  Obj.FieldByName(F.FieldName).AsInteger := Key;
              end;
            end;
            Continue;
          end;

          if (F <> nil) and (F.References <> nil) then
          begin
            if not (N is TyamlScalar) then
              raise Exception.Create('Invalid YAML data type!');

            if not TyamlScalar(N).IsNull then
              RefRUID := ExtractRUID(TyamlString(N).AsString)
            else
              IsNull := True;

            if not IsNull then
            begin
              if (RUID = RefRUID) and
                (Obj.FieldByName(Obj.GetKeyField(Obj.SubType)).AsInteger > 0)
              then
                Key := Obj.FieldByName(Obj.GetKeyField(Obj.SubType)).AsInteger
              else
              begin
                Key := gdcBaseManager.GetIDByRUIDString(RefRUID, ATr);
                IsNull := Key = -1;
              end;

              if (Key = -1) and
                (RefRUID <> RUID) then
              begin
                if not Assigned(RUOL) then
                  RUOL := TList.Create;

                RU := TgdcReferenceUpdate.Create;
                RU.FieldName := F.FieldName;
                RU.FullClass.gdClass := CgdcBase(Obj.ClassType);
                RU.FullClass.SubType := Obj.SubType;
                RU.ID := -1;
                RU.RefRUID := RefRUID;
                UL.Add(RU);
                RUOL.Add(RU);
                IsNull := True;
              end else if (Key = -1) and (StrToRUID(RefRUID).XID >= cstUserIDStart) then
              begin
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
                InsertRecord(SourceYAML, Obj, UL, StrToRUID(RUID).XID);
              end else
                raise;
            end;
          end;
        end
        else if not Obj.CheckTheSame(true) then
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

  procedure InsertRecord(SourceYAML: TyamlMapping; Obj: TgdcBase; UL: TObjectList; const ID: Integer = -1);
  var
    RR: TRUIDRec;
    RUID: String;
  begin
    Obj.Insert;
    if (ID > - 1) and (ID < cstUserIDStart) then
      Obj.FieldByName(Obj.GetKeyField(Obj.SubType)).AsInteger := ID;
    if CopyRecord(SourceYAML, Obj, UL) then
    begin
      Obj.CheckBrowseMode;
      RR := gdcBaseManager.GetRUIDRecByID(Obj.ID, ATr);
      RUID := SourceYAML.ReadString('Properties\RUID');
      if RR.XID = -1 then
      begin
        gdcBaseManager.InsertRUID(Obj.ID, StrToRUID(RUID).XID, StrToRUID(RUID).DBID,
          now, IBLogin.ContactKey, ATr);
      end else
      begin
        gdcBaseManager.UpdateRUIDByID(Obj.ID, StrToRUID(RUID).XID, StrToRUID(RUID).DBID,
          now, IBLogin.ContactKey, ATr);
      end;
    end;
  end;

  procedure LoadSet(AValue: TyamlMapping; AnID: Integer; ATransaction: TIBTransaction);
  var
    RN: String;
    J: Integer;
    q: TIBSQL;
    R: TatRelation;
    N: TyamlNode;
    ID: Integer;
  begin
    q := TIBSQL.Create(nil);
    try
      q.Transaction := ATransaction;

      RN := AValue.ReadString('Table');
      if RN <> '' then
      begin
        N := AValue.FindByName('Items');
        if (N <> nil) and (N is TyamlSequence) then
        begin
          R := atDatabase.Relations.ByRelationName(RN);
          if Assigned(R) then
          begin
            q.SQL.Text := 'DELETE FROM ' + RN + ' WHERE ' + R.PrimaryKey.ConstraintFields[0].FieldName + ' = :id';

            q.ParamByName('id').AsInteger := AnID;
            q.ExecQuery;
            q.Close;

            q.SQl.Text := 'INSERT INTO ' + RN + '(' + R.PrimaryKey.ConstraintFields[0].FieldName +
              ', ' + R.PrimaryKey.ConstraintFields[1].FieldName + ') VALUES(:id1, :id2)';

            with N as TyamlSequence do
            begin
              for J := 0 to Count - 1 do
              begin
                if not (Items[J] is TyamlScalar) then
                  raise Exception.Create('Invalid data!');

                ID := gdcBaseManager.GetIDByRUIDString((Items[J] as TyamlScalar).AsString, ATransaction);
                if ID > 0 then
                begin
                  q.ParamByName('id1').AsInteger := AnID;
                  q.ParambyName('id2').AsInteger := ID;
                  q.ExecQuery;
                  q.Close;
                end else
                  raise Exception.Create('Id not found! Error load set!');
              end;
            end;
          end else
            raise Exception.Create('Table ''' +  RN + ''' not found in databese!');
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

  RUID := AMapping.ReadString('Properties\RUID');
  AlwaysOverwrite := AMapping.ReadBoolean('Properties\AlwaysOverwrite');

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
        AddText('Начата загрузка объекта ' + AMapping.ReadString('Properties\Class') + ' ' + AMapping.ReadString('Properties\RUID'), clBlack);
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
          InsertRecord(AMapping, AnObj, UpdateList, StrToRUID(RUID).XID);
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

            InsertRecord(AMapping, AnObj, UpdateList, D);
          end else
          begin
            AddText('Объект найден по РУИДу'#13#10, clBlue);

            if AlwaysOverwrite then
            begin
              AnObj.Edit;
              if CopyRecord(AMapping, AnObj, UpdateList) then
              begin
                AnObj.CheckBrowseMode;

                gdcBaseManager.UpdateRUIDByXID(AnObj.ID, StrToRUID(RUID).XID, StrToRUID(RUID).DBID,
                  now, IBLogin.ContactKey, ATr);
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
              LoadSet(Items[J] as TyamlMapping, AnObj.ID, ATr);
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
  Result := inherited GetSubSetList + 'ByNamespace;ByObject;';
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
begin
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
    q.Transaction := gdcBaseManager.ReadTransaction;
    W.WriteDirective('YAML 1.1');
    W.StartNewLine;
    W.WriteKey('StructureVersion');
    W.WriteString('1.0');
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
        W.WriteString(q.FieldByName('ruid').AsString);
        W.WriteChar(' ');
        W.WriteText(q.FieldByName('name').AsString, qSingleQuoted);
        q.Next;
      end;
      W.DecIndent;
      W.StartNewLine;
    end;
    q.Close;
    q.SQL.Text := 'SELECT xid || ''_'' || dbid as ruid FROM at_object WHERE id = :id';

    W.WriteKey('Objects');
    W.IncIndent;

    CheckIncludesiblings;
    Obj := TgdcNamespaceObject.Create(nil);
    try
      Obj.SubSet := 'ByNamespace';
      Obj.ParamByName('namespacekey').AsInteger := Self.ID;
      Obj.Open;
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
                WriteObject(InstObj, W, HeadObject, Obj.FieldByName('alwaysoverwrite').AsInteger = 1, Obj.FieldByName('dontremove').AsInteger = 1,
                  Obj.FieldByName('includesiblings').AsInteger = 1);
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
  const APath: String; Messages: TStrings);

  procedure FillInNamespace(AnObj: TgdcBase; const AnInsert: Boolean);
  begin
    if AnInsert then
      ADataSet.Insert
    else
      ADataSet.Edit;
    ADataSet.FieldByName('namespacekey').AsInteger := AnObj.ID;
    ADataSet.FieldByName('namespacename').AsString := AnObj.ObjectName;
    ADataSet.FieldByName('namespaceversion').AsString := AnObj.FieldByName('version').AsString;
    if not AnObj.FieldByName('filetimestamp').IsNull then
      ADataSet.FieldByName('namespacetimestamp').AsDateTime := AnObj.FieldByName('filetimestamp').AsDateTime;
    ADataSet.Post;
  end;

  procedure FillInNamespaceFile(const S: String);
  var
    Parser: TyamlParser;
    M: TyamlMapping;
  begin
    Parser := TyamlParser.Create;
    try
      Parser.Parse(S, 'Objects', 1024);

      if (Parser.YAMLStream.Count > 0)
        and ((Parser.YAMLStream[0] as TyamlDocument).Count > 0)
        and ((Parser.YAMLStream[0] as TyamlDocument)[0] is TyamlMapping) then
      begin
        M := (Parser.YAMLStream[0] as TyamlDocument)[0] as TyamlMapping;

        if M.ReadString('Properties\Name') = '' then
        begin
          Messages.Add('Неверный формат файла ' + S);
        end else
        begin
          if ADataSet.Locate('filenamespacename', M.ReadString('Properties\Name'), [loCaseInsensitive]) then
          begin
            Messages.Add('Пространство имен: "' + M.ReadString('Properties\Name') + '" содержится в файлах:');
            Messages.Add('1: ' + ADataSet.FieldByName('filename').AsString);
            Messages.Add('2: ' + S);
            Messages.Add('Только первый файл будет обработан!');
          end else
          begin
            ADataSet.Append;
            ADataSet.FieldByName('filename').AsString := S;
            ADataSet.FieldByName('filenamespacename').AsString := M.ReadString('Properties\Name');
            ADataSet.FieldByName('fileversion').AsString := M.ReadString('Properties\Version');
            ADataSet.FieldByName('filetimestamp').AsDateTime := gd_common_functions.GetFileLastWrite(S);
            ADataSet.FieldByName('filesize').AsInteger := FileGetSize(S);
            ADataSet.Post;
          end;
        end;                       
      end;
    finally
      Parser.Free;
    end;
  end;

var
  SL: TStringList;
  Obj: TgdcNamespace;
  I, R: Integer;
  CurrDir, Bm: String;
begin
  Assert(ADataSet <> nil);
  Assert(Messages <> nil);

  Obj := TgdcNamespace.Create(nil);
  SL := TStringList.Create;
  try
    SL.Sorted := True;
    SL.Duplicates := dupError;

    if AdvBuildFileList(IncludeTrailingBackslash(APath) + '*.yml',
      faAnyFile, SL, amAny,  [flFullNames, flRecursive], '*.*', nil) then
    begin
      CurrDir := '';

      for I := 0 to SL.Count - 1 do
      begin
        if ExtractFilePath(SL[I]) <> CurrDir then
        begin
          CurrDir := ExtractFilePath(SL[I]);
          ADataSet.Append;
          ADataSet.FieldByName('filenamespacename').AsString := CurrDir;
          ADataSet.Post;
        end;
        FillInNamespaceFile(SL[I]);
      end;

      ADataSet.First;

      Obj.SubSet := 'OrderByName';
      Obj.Open;

      while not Obj.EOF do
      begin
        Bm := ADataSet.Bookmark;
        if ADataSet.Locate('filenamespacename', Obj.ObjectName, [loCaseInsensitive]) then
        begin
          FillInNamespace(Obj, False);
          ADataSet.Bookmark := Bm
        end else
        begin
          FillInNamespace(Obj, True);
          ADataSet.Next;
        end;
        Obj.Next;
      end;

      ADataSet.First;

      while not ADataSet.EOF do
      begin
        R := TFLItem.CompareVersionStrings(
              ADataSet.FieldByName('namespaceversion').AsString,
              ADataSet.FieldByName('fileversion').AsString);

        ADataSet.Edit;

        if ADataSet.FieldByName('namespaceversion').AsString > '' then
        begin
          if R < 0 then
            ADataSet.FieldByName('operation').AsString := '<<'
          else if R > 0 then
            ADataSet.FieldByName('operation').AsString := '>>'
          else
            ADataSet.FieldByName('operation').AsString := '==';
        end
        else if ADataSet.FieldByName('fileversion').AsString > '' then
          ADataSet.FieldByName('operation').AsString := '<<'
        else
          ADataSet.FieldByName('operation').AsString := '';

        ADataSet.Post;  
        ADataSet.Next;
      end;

      ADataSet.First;
    end;
  finally
    SL.Free;
    Obj.Free;
  end;
end;

class procedure TgdcNamespace.InstallPackages;
var
  I: Integer;
  Obj: TgdcNamespace;
  SL: TStringList;
begin
  SL := TStringList.Create;
  try
    with Tat_dlgLoadNamespacePackages.Create(nil) do
    try
      if ShowModal = mrOk then
      begin
        SetFileList(SL);
      end;
    finally
      Free;
    end;

    if SL.Count > 0 then
    begin
      Obj := TgdcNamespace.Create(nil);
      try
        for I := 0 to SL.Count - 1 do
          Obj.LoadFromFile(SL[I]);
      finally
        Obj.Free;
      end;
    end;
  finally
    SL.Free;
  end;
end;

class procedure TgdcNamespace.ScanLinkNamespace(ADataSet: TDataSet; const APath: String);
var
  SL: TStringList;

  function GetVerInfo(const AName, AVersion: String): Byte;
  var
    gdcNamespace: TgdcNamespace;
    R: Integer;
  begin
    Result := nvIndefinite;
    gdcNamespace := TgdcNamespace.Create(nil);
    try
      gdcNamespace.SubSet := 'ByName';
      gdcNamespace.ParamByName(gdcNamespace.GetListField(gdcNamespace.SubType)).AsString := Trim(AName);
      gdcNamespace.Open;
      if not gdcNamespace.Eof then
      begin
        R := TFLItem.CompareVersionStrings(gdcNamespace.FieldByName('version').AsString, AVersion, 4);
        if R > 0 then
          Result := nvOlder
        else
          if R < 0 then
            Result := nvNewer
          else
            Result := nvEqual;
      end else
        Result := nvNotInstalled;
    finally
      gdcNamespace.Free;
    end;
  end;

  function IsMatching(const ADBVersion: String): Boolean;
  var
    CurDBVersion: String;
  begin
    Result := False;
    Assert(IBLogin <> nil);
    CurDBVersion := IBLogin.DBVersion;

    Result := not (ADBVersion > '') or not (TFLItem.CompareVersionStrings(ADBVersion, CurDBVersion) > 0);
  end;

  function FindFile(const AName: String): String;
  var
    I: Integer;
  begin
    Assert(SL <> nil);
    Result := '';
    for I := 0 to SL.Count - 1 do
    begin
      if AnsiCompareText(ExtractFileName(SL[I]), AName + '.yml') = 0 then
      begin
        Result := SL[I];
        break;
      end;
    end;
  end;

  function SetLinkToNamespace(const S: String; parent: integer; Required: Boolean = False): Boolean;
  var
    Parser: TyamlParser;
    M: TyamlMapping;
    N: TyamlNode;
    I, K: Integer;
    Temps: String;
    RUID, FN: String;
    Add: Boolean;
    Currparent: Integer;
  begin
    Result := True; 
    Parser := TyamlParser.Create;
    try
      Parser.Parse(S, 'Objects', 4096);

      if (Parser.YAMLStream.Count > 0)
        and ((Parser.YAMLStream[0] as TyamlDocument).Count > 0)
        and ((Parser.YAMLStream[0] as TyamlDocument)[0] is TyamlMapping) then
      begin
        M := (Parser.YAMLStream[0] as TyamlDocument)[0] as TyamlMapping;
        N := M.FindByName('USES');

        Add := (N <> nil) and (N is TyamlSequence) and ((N as TyamlSequence).Count > 0);
        if Add or Required then
        begin
          if not ADataSet.Locate('NamespaceName', M.ReadString('Properties\Name'), [loCaseInsensitive])
            or ((ADataSet.FieldByName('parent').AsInteger > 0) and Required)
          then
          begin
            ADataSet.Append;
            ADataSet.FieldByName('parent').AsInteger := parent;
            ADataSet.FieldByName('NamespaceName').AsString := M.ReadString('Properties\Name');
            ADataSet.FieldByName('Version').AsString := M.ReadString('Properties\Version');
            ADataSet.FieldByName('RUID').AsString := M.ReadString('Properties\RUID');
            ADataSet.FieldByName('DBVersion').AsString := M.ReadString('Properties\DBVersion');
            ADataSet.FieldByName('VersionInfo').AsInteger := GetVerInfo(Trim(ADataSet.FieldByName('NamespaceName').AsString), Trim(ADataSet.FieldByName('Version').AsString));
            ADataSet.FieldByName('DBVersionInfo').AsBoolean := IsMatching(Trim(ADataSet.FieldByName('DBVersion').AsString));
            ADataSet.FieldByName('filename').AsString := S;
            ADataSet.FieldByName('filetimestamp').AsDateTime := gd_common_functions.GetFileLastWrite(S);
            ADataSet.FieldByName('CorrectPack').AsBoolean := True;
            ADataSet.Post;

            Currparent := ADataSet.FieldByName('id').AsInteger;

            if Add then
            begin
              with N as TyamlSequence do
              begin
                for I := 0 to Count - 1 do
                begin
                  if not (Items[I] is TyamlScalar) or not (Items[I] is TyamlString) then
                    raise Exception.Create('Invalid data! FileName = ' + S + ';ClassNaem=' + IntToStr((Items[I] as TyamlScalar).AsInteger));

                  Temps := (Items[I] as TyamlScalar).AsString;
                  RUID := '';
                  FN := '';
                  for K := 1 to Length(Temps) do
                  begin
                    if not CharIsDigit(Temps[K]) and (Temps[K] <> '_') then
                      break;
                    RUID := RUID + Temps[K];
                  end;
                  Temps := Trim(System.Copy(Temps, K, Length(TempS)));
                  Temps := StrTrimQuotes(Temps);

                  FN := FindFile(Temps);
                  if FN <> '' then
                    SetLinkToNamespace(FN, Currparent, True)
                   { begin
                      ADataSet.Locate('id', currentparent, []);
                      ADataSet.Edit;
                      ADataSet.FieldByName('CorrectPack').AsBoolean := False;
                      ADataSet.FieldByName('ErrMessage').AsString := errmessage;
                      ADataSet.Post;
                      Result := False;
                      break;
                    end; }
                  else
                  begin
                    ADataSet.Edit;
                    ADataSet.FieldByName('CorrectPack').AsBoolean := False; 
                    ADataSet.FieldByName('ErrMessage').AsString := 'Не найдена промежуточная настройка или пакет, от которого зависит данный.' +
                      ' Имя пакета: ''' + Temps + ''' (RUID = ' + RUID + ')';
                    ADataSet.Post;
                    break;
                  end;
                end;
              end;
            end;
          end else
          if (ADataSet.FieldByName('parent').AsInteger <= 0) and Required then
          begin
            ADataSet.Edit;
            ADataSet.FieldByName('parent').AsInteger := parent;
            ADataSet.Post;
          end;
        end;
      end;
    finally
      Parser.Free;
    end;
  end;

var
  I: Integer; 
begin
  Assert(ADataSet <> nil);

  SL := TStringList.Create;
  try
    SL.Duplicates := dupError;
    if AdvBuildFileList(IncludeTrailingBackslash(APath) + '*.yml',
      faAnyFile, SL, amAny,  [flFullNames, flRecursive], '*.*', nil) then
    begin
      for I := 0 to SL.Count - 1 do
        SetLinkToNamespace(SL[I], 0);
    end; 
  finally
    SL.Free;
  end;
end;

class procedure TgdcNamespace.ScanLinkNamespace2(const APath: String);

  function CompareVer(const V1: String; const V2: String): Integer;
  var
    R: Integer;
  begin
    Result := nvIndefinite;
    R := TFLItem.CompareVersionStrings(V1, V2);
    
    if V1 > '' then
    begin
      if R < 0 then
        Result := nvNewer
      else if R > 0 then
        Result := nvOlder
      else
        Result := nvEqual;
    end
    else if V2 > '' then
      Result := nvNotInstalled;
  end;

  procedure SetLinkToNamespace(const S: String);
  var
    Parser: TyamlParser;
    q, SQL: TIBSQL;
    Tr: TIBTransaction;
    M: TyamlMapping;
    N: TyamlNode;
    K, I: Integer;
    Temps, RUID: String;
  begin
    Tr := TIBTransaction.Create(nil);
    q := TIBSQL.Create(nil);
    SQL := TIBSQL.Create(nil);
    try
      Tr.DefaultDatabase := gdcBaseManager.Database;
      Tr.StartTransaction;
      q.Transaction := Tr;
      SQL.Transaction := Tr;
      q.SQL.Text := 'UPDATE OR INSERT INTO at_namespace_gtt ' +
        '  (name, caption, filename, filetimestamp, version, dbversion, ' +
        '  optional, internal, comment, settingruid, operation) ' +
        'VALUES (:N, :Cap, :FN, :FT, :V, :DBV, :O, :I, :C, :SR, :OP) ' +
        'MATCHING (settingruid) ';
      SQL.SQL.Text := 'SELECT * FROM at_namespace WHERE settingruid = :sr';


      Parser := TyamlParser.Create;
      try
        Parser.Parse(S, 'Objects', 4096);

        if (Parser.YAMLStream.Count > 0)
          and ((Parser.YAMLStream[0] as TyamlDocument).Count > 0)
          and ((Parser.YAMLStream[0] as TyamlDocument)[0] is TyamlMapping) then
        begin
          M := (Parser.YAMLStream[0] as TyamlDocument)[0] as TyamlMapping;

          q.Close;
          q.ParamByName('N').AsString := M.ReadString('Properties\Name');
          q.ParamByName('Cap').AsString := M.ReadString('Properties\Caption');
          q.ParamByName('FN').AsString := S;
          q.ParamByName('FT').AsDateTime := gd_common_functions.GetFileLastWrite(S);
          q.ParamByName('V').AsString := M.ReadString('Properties\Version');
          q.ParamByName('DBV').AsString := M.ReadString('Properties\DBVersion');
          q.ParamByName('O').AsInteger := Integer(M.ReadBoolean('Properties\Optional'));
          q.ParamByName('I').AsInteger := Integer(M.ReadBoolean('Properties\Internal'));
          q.ParamByName('C').AsString := M.ReadString('Properties\Comment');
          q.ParamByName('SR').AsString := M.ReadString('Properties\RUID');
          SQL.ParamByName('sr').AsString := M.ReadString('Properties\RUID');
          SQL.ExecQuery;
          if not SQL.Eof then
            q.ParamByName('OP').AsInteger := CompareVer(SQl.FieldByName('version').AsString, M.ReadString('Properties\Version'))
          else
            q.ParamByName('OP').AsInteger := CompareVer('', M.ReadString('Properties\Version'));

          q.ExecQuery;
          q.Close;
          SQL.Close;

          N := M.FindByName('USES');
          if (N <> nil) and (N is TyamlSequence) and ((N as TyamlSequence).Count > 0) then
          begin
            q.SQL.Text := 'UPDATE OR INSERT INTO at_namespace_link_gtt ' +
              '  (namespaceruid, usesruid) ' +
              'VALUES (:NSR, :UR) ' +
              'MATCHING (namespaceruid, usesruid) ';

            with N as TyamlSequence do
            begin
              for I := 0 to Count - 1 do
              begin
                if not (Items[I] is TyamlScalar) then
                  raise Exception.Create('Invalid data!');

                Temps := (Items[I] as TyamlScalar).AsString;
                RUID := '';

                for K := 1 to Length(Temps) do
                begin
                  if Temps[K] in ['0'..'9', '_'] then
                    RUID := RUID + Temps[K]
                  else
                    Break;
                end;

                if CheckRUID(RUID) then
                begin
                  q.Close;
                  q.ParamByName('NSR').AsString :=  M.ReadString('Properties\RUID');
                  q.ParamByName('UR').AsString := RUID;
                  q.ExecQuery;
                end;
              end;
            end;
          end;
          Tr.Commit;
        end;
      finally
        Parser.Free;
      end;
    finally
      Tr.Free;
      q.Free;
    end;
  end;

var
  SL: TStringList;
  I: Integer;
begin
  SL := TStringList.Create;
  try
    SL.Duplicates := dupError;
    if AdvBuildFileList(IncludeTrailingBackslash(APath) + '*.yml',
      faAnyFile, SL, amAny,  [flFullNames, flRecursive], '*.*', nil) then
    begin
      for I := 0 to SL.Count - 1 do
        SetLinkToNamespace(SL[I]);
    end;
  finally
    SL.Free;
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

    q.SQL.Text := 'SELECT n.id, n.name FROM at_object o ' +
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
              ' "' + Obj.ObjectName + '"';
            KSA := TgdKeyStringAssoc.Create;
            try        
              SetNamespaceForObject(Obj, KSA, ATr);
              if KSA.Count > 0 then
              begin
                ADataSet.FieldByName('namespacekey').AsInteger := KSA[0];
                ADataSet.FieldByName('namespace').AsString := KSA.ValuesByIndex[0];
                ADataSet.FieldByName('displayname').AsString := ADataSet.FieldByName('displayname').AsString +
                  ' "' + KSA.ValuesByIndex[0] + '"';
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

class procedure TgdcNamespace.AddObject(ANamespacekey: Integer; const AName: String; const AClass: String; const ASubType: String;
  xid, dbid: Integer; ATr: TIBTransaction; AnAlwaysoverwrite: Integer = 1; ADontremove: Integer = 0; AnIncludesiblings: Integer = 0);  
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
    SQL.SQL.Text := 'SELECT * FROM at_object WHERE namespacekey <> :nk and xid = :xid and dbid = :dbid';
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

procedure TgdcNamespace.AddObject2(AnObject: TgdcBase; AnUL: TObjectList; const AHeadObjectRUID: String = ''; AnAlwaysOverwrite: Integer = 1; ADontRemove: Integer = 0; AnIncludeSiblings: Integer = 0);

  procedure HeadObjectUpdate(UL: TObjectList; SourceRUID: String; TargetKeyValue: Integer);
  var
    I: Integer;
    q: TIBSQL;
  begin
    q := TIBSQL.Create(nil);
    try
      q.Transaction := Transaction;
      q.SQL.Text := 'UPDATE at_object SET headobjectkey = :hk WHERE namespacekey = :nk AND xid = :xid AND dbid = :dbid';
      for I := UL.Count - 1 downto 0 do
      begin
        if ((UL[I] as TgdcHeadObjectUpdate).RefRUID = SourceRUID)
          and ((UL[I] as TgdcHeadObjectUpdate).Namesapcekey = Self.ID) then
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
      '  FOR SELECT namespacekey FROM at_object WHERE namespacekey <> :namespacekey AND xid = :xid AND dbid = :dbid INTO :tempkey  ' + 
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
              HO.Namesapcekey := Self.ID;
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
    q.SQL.Text := 'SELECT * FROM at_object WHERE namespacekey <> :nk and xid = :xid and dbid = :dbid';
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

class procedure TgdcNamespace.FillTree(ATreeView: TgsTreeView; AList: TgsyamlList; AnInternal: Boolean);

  procedure AddNode(Node: TTreeNode; yamlNode: TgsyamlNode);
  var
    Temp: TTreeNode;
    I, Ind: Integer;
  begin
    Temp := Node;
    if AnInternal or not yamlNode.Internal then
    begin
      Temp := ATreeView.Items.AddChildObject(Node, yamlNode.Caption, yamlNode);
      Temp.StateIndex := 2;
    end;
    
    for I := 0 to yamlNode.RUIDUses.Count - 1 do
    begin
      Ind := AList.IndexOf(yamlNode.RUIDUses[I]);
      if (Ind = -1) or not (AList.Objects[Ind] as TgsyamlNode).IsCreate then
        raise Exception.Create('Файл ' + (AList.Objects[Ind] as TgsyamlNode).Name + '(RUID=' + (AList.Objects[Ind] as TgsyamlNode).settingruid + ') не найден!')
      else
        AddNode(Temp, AList.Objects[Ind] as TgsyamlNode);
    end;
  end;

var
  I, K: Integer;
  Link: Boolean;
  Parent: TList;
begin
  Assert(ATreeView <> nil);
  Assert(AList <> nil);

  Parent := TList.Create;
  try
    for I := 0 to AList.Count - 1 do
    begin
      Link := False;
      for K := 0 to AList.Count - 1 do
      begin
        if (I <> K) and
          ((AList.Objects[K] as TgsyamlNode).RUIDUses.IndexOf(AList[I]) > -1)
         // ((AList.Objects[K] as TgsyamlNode).IDUses.IndexOf(AList.Objects[I]) > -1)
        then
        begin
          Link := True;
          break;
        end;
      end;
      
      if not Link then
        Parent.Add(AList.Objects[I]);
    //    AddNode(nil, AList.Objects[I] as TgsyamlNode, RUIDList);
    end;

    for I := 0 to Parent.Count - 1 do
      AddNode(nil, TgsyamlNode(Parent[I]));
  finally
    Parent.Free;  
  end;
end;

constructor TgsyamlNode.Create;
begin
  inherited;
  
  IsCreate := False;
  RUIDUses := TStringList.Create;
end;

destructor TgsyamlNode.Destroy;
begin
  RUIDUses.Free;

  inherited;
end;

procedure TgsyamlList.GetFilesForPath(Path: String);

  function GetYAMLNode(const Name: String; var IsCreate: Boolean): TgsyamlNode;
  var
    Parser: TyamlParser;
    M: TyamlMapping;
    N: TyamlNode;
    Ind, I, K: Integer;
    Temps, RUID: String;
  begin
    Assert(Name <> '');

    Result := nil;
    Parser := TyamlParser.Create;
    try
      Parser.Parse(Name, 'Objects', 4096);

      if (Parser.YAMLStream.Count > 0)
        and ((Parser.YAMLStream[0] as TyamlDocument).Count > 0)
        and ((Parser.YAMLStream[0] as TyamlDocument)[0] is TyamlMapping) then
      begin
        M := (Parser.YAMLStream[0] as TyamlDocument)[0] as TyamlMapping;

        Ind := Self.IndexOf(M.ReadString('Properties\RUID'));
        if Ind > -1 then
        begin
          Result := Self.Objects[Ind] as TgsyamlNode;
          IsCreate := False;
        end else
          Result := TgsyamlNode.Create;
        Result.Name := M.ReadString('Properties\Name');
        Result.Caption := M.ReadString('Properties\Caption');
        Result.Filename := Name;
        Result.Filetimestamp := gd_common_functions.GetFileLastWrite(Name);
        Result.Version := M.ReadString('Properties\Version');
        Result.DBVersion := M.ReadString('Properties\DBVersion');
        Result.Optional := M.ReadBoolean('Properties\Optional');
        Result.Internal := M.ReadBoolean('Properties\Internal');
        Result.Comment := M.ReadString('Properties\Comment');
        Result.Settingruid :=  M.ReadString('Properties\RUID');
        Result.IsCreate := True;

        N := M.FindByName('USES');
        if (N <> nil) and (N is TyamlSequence) and ((N as TyamlSequence).Count > 0) then
        begin
          with N as TyamlSequence do
          begin
            for I := 0 to Count - 1 do
            begin
              if not (Items[I] is TyamlScalar) then
                raise Exception.Create('Invalid data!');

              Temps := (Items[I] as TyamlScalar).AsString;
              RUID := '';

              for K := 1 to Length(Temps) do
              begin
                if Temps[K] in ['0'..'9', '_'] then
                  RUID := RUID + Temps[K]
                else
                  Break;
              end;

              if CheckRUID(RUID) then
              begin
                Ind := Self.IndexOf(RUID);
                if Ind > -1 then
                begin
                  if Valid(Self.Objects[Ind] as TgsyamlNode) then
                    Result.RUIDUses.Add(RUID)
                  else
                    raise Exception.Create('Not valid object ' + (Self.Objects[Ind] as TgsyamlNode).Caption + '!');
                end else
                begin
                  Ind := Self.AddObject(RUID, TgsyamlNode.Create);
                  (Self.Objects[Ind] as TgsyamlNode).settingruid := RUID;
                  (Self.Objects[Ind] as TgsyamlNode).Name := Copy(Temps, K + 1, Length(Temps));
                  Result.RUIDUses.Add(RUID);
                end;
              end;
            end;
          end;
        end;
      end;
    finally
      Parser.Free;
    end;
  end;
var
  SL: TStringList;
  I: Integer;
  Node: TgsyamlNode;
  IsCreate: Boolean;
begin
  SL := TStringList.Create;
  try
    SL.Duplicates := dupError;
    if AdvBuildFileList(IncludeTrailingBackslash(Path) + '*.yml',
      faAnyFile, SL, amAny,  [flFullNames, flRecursive], '*.*', nil) then
    begin
      for I := 0 to SL.Count - 1 do
      begin
        IsCreate := True;
        Node := GetYAMLNode(SL[I], IsCreate);
        if IsCreate then
          Self.AddObject(Node.Settingruid, Node);
      end;
    end;
  finally
    SL.Free;
  end;
end;

procedure TgsyamlList.Clear;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    if Assigned(Objects[I]) then
      (Objects[I] as TgsyamlNode).Free;

  inherited;
end;

destructor TgsyamlList.Destroy;
begin
  Clear;

  inherited;
end;

function TgsyamlList.AddObject(const S: string; AObject: TObject): Integer;
begin
  Result := Self.IndexOf(S);
  if Result > -1 then
  begin
    raise Exception.Create('Дубликат!')
  end
  else
    Result := inherited AddObject(S, AObject);
end;

function TgsyamlList.Valid(ANode: TgsyamlNode): Boolean;

  function Acyclic(Obj: TgsyamlNode): Boolean;
  var
    I, Ind: Integer;
  begin
    Result := True;

    if Obj = ANode then
      Result := False
    else
    begin
      for I := 0 to Obj.RUIDUses.Count - 1 do
      begin
        Ind := Self.IndexOf(Obj.RUIDUses[I]);
        Result := Acyclic(Self.Objects[Ind] as TgsyamlNode);
        if not Result then
          break;
      end;
    end;
  end;
  
var
  I, Ind: Integer;
begin
  Result := True;
  for I := 0 to ANode.RUIDUses.Count - 1 do
  begin
    Ind := Self.IndexOf(ANode.RUIDUses[I]);
    Result := Acyclic(Self.Objects[Ind] as TgsyamlNode);
    if not Result then
      break;
  end; 
end;

initialization
  RegisterGDCClass(TgdcNamespace);
  RegisterGDCClass(TgdcNamespaceObject);

finalization
  UnRegisterGDCClass(TgdcNamespace);
  UnRegisterGDCClass(TgdcNamespaceObject);
end.
