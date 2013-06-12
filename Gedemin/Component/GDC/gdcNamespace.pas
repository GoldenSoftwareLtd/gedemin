
unit gdcNamespace;

interface

uses                        
  SysUtils, gdcBase, gdcBaseInterface, Classes, gd_ClassList,
  gd_createable_form, at_classes, IBSQL, db, yaml_writer, yaml_parser,
  IBDatabase, gd_security, dbgrids, gd_KeyAssoc, contnrs, IB, gsNSObjects;

type
  TLoadedStatus = (lsNone, lsUnModified, lsModified, lsInsert);

  TgdcNamespace = class(TgdcBase)
  private
    FIncBuildVersion: Boolean;
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
      ADontremove: Boolean = False; AnIncludesiblings: Boolean = False;
      const ATr: TIBTransaction = nil);
    class function LoadObject(AnObj: TgdcBase; AMapping: TyamlMapping;
      UpdateList: TObjectList; RUIDList: TStringList; ATr: TIBTransaction;
      const AnAlwaysoverwrite: Boolean = False): TLoadedStatus;
    class procedure ScanDirectory(ADataSet: TDataSet; ANSList: TgsNSList;
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
    class procedure UpdateCurrModified(const ANamespaceKey: Integer = -1);
    class procedure FillSet(AnObj: TgdcBase; AnOL: TObjectList; ATr: TIBTransaction); 

    procedure AddObject2(AnObject: TgdcBase; AnUL: TObjectList;
      const AHeadObjectRUID: String = ''; AnAlwaysOverwrite: Integer = 1;
      ADontRemove: Integer = 0; AnIncludeSiblings: Integer = 0);
    procedure DeleteObject(xid, dbid: Integer; RemoveObj: Boolean = True);
    procedure InstallPackages(ANSList: TStringList;
      const AnAlwaysoverwrite: Boolean = False; const ADontremove: Boolean = False);
    function MakePos: Boolean;
    procedure LoadFromFile(const AFileName: String = ''); override;
    procedure SaveNamespaceToStream(St: TStream; const AnAnswer: Integer = 0);
    procedure SaveNamespaceToFile(const AFileName: String = '');
    procedure CompareWithData(const AFileName: String);
    procedure DeleteNamespaceWithObjects;

    property IncBuildVersion: Boolean read FIncBuildVersion write FIncBuildVersion
      default False;
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

    procedure ShowObject;
  end;

  function GetReferenceString(const ARUID: String; const AName: String): String;
  function ParseReferenceString(const AStr: String; out ARUID: String; out AName: String): Boolean;
  function IncVersion(const V: String; const TermChar: Char): String;

  procedure Register;

implementation

uses
  Windows, Controls, ComCtrls, gdc_dlgNamespacePos_unit, gdc_dlgNamespace_unit,
  gdc_frmNamespace_unit, at_sql_parser, jclStrings, gdcTree, yaml_common,
  gd_common_functions, prp_ScriptComparer_unit, gdc_dlgNamespaceObjectPos_unit,
  jclUnicode, at_frmSyncNamespace_unit, jclFileUtils, gd_directories_const,
  gd_FileList_unit, gdcClasses, at_sql_metadata, gdcConstants, at_frmSQLProcess,
  Graphics, IBErrorCodes, Storages, gdcMetadata, at_sql_setup, gsDesktopManager,
  at_Classes_body, dbclient, at_dlgCompareNSRecords_unit;

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

  TgdcAt_Object = class(TObject)
  public
    ID: Integer;
    RUID: String;
    ObjectName: String;
    NamespaceKey: Integer; 
    Objectclass: String;
    SubType: String;
    Modified: TDateTime;
    Curr_modified: TDateTime;
    Filetimestamp: TDateTime;
    Headobjectkey: Integer;
  end;

  TgdcSetAttr = class(TObject)
  public
    SQL: String;
    RefFieldName: String;
    RefTableName: String;
    ClassName: String;
    SubType: String;
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

function IncVersion(const V: String; const TermChar: Char): String;
var
  E, Ver: Integer;
begin
  E := Length(V);
  while (E > 0) and (V[E] <> TermChar) do
    Dec(E);
  Ver := StrToIntDef(System.Copy(V, E + 1, MaxInt), 0);
  Inc(Ver);
  if E > 0 then
    Result := System.Copy(V, 1, E) + IntToStr(Ver)
  else
    Result := IntToStr(Ver);
end;

function CompareFolder(List: TStringList; Index1, Index2: Integer): Integer;
begin
  Result := AnsiCompareText(
    (List.Objects[Index1] as TgsNSNode).GetDisplayFolder,
    (List.Objects[Index2] as TgsNSNode).GetDisplayFolder);
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
    OL: TObjectList;
    I: Integer;
    q: TIBSQL;
    SetAttr: TgdcSetAttr;
    AddedTitle: Boolean;
    InstObj: TgdcBase;
    InstClass: TPersistentClass;
    FN: String;
  begin
    OL := TObjectList.Create;
    q := TIBSQL.Create(nil);
    try
      if (ATr = nil) or (not ATr.InTransaction) then
        q.Transaction := gdcBaseManager.ReadTransaction
      else
        q.Transaction := ATr;
      AddedTitle := False;
      FillSet(AObj, OL, AObj.Transaction);

      for I := 0 to OL.Count - 1 do
      begin
        SetAttr := OL[I] as TgdcSetAttr;
        InstObj := nil;
        if SetAttr.SubType <> 'NULL' then
          InstClass := GetClass(SetAttr.ClassName)
        else
          InstClass := nil; 

        q.Close;
        q.SQL.Text := SetAttr.SQL;
        q.ParamByName('rf').AsInteger := AObj.FieldByName(SetAttr.RefFieldName).AsInteger;
        q.ExecQuery;

        if not q.Eof then
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
            AWriter.WriteText(SetAttr.RefTableName, qDoubleQuoted);

            AWriter.StartNewLine;
            AWriter.WriteKey('Items');

            AWriter.IncIndent;
            try
              if InstClass <> nil then
              begin
                InstObj := CgdcBase(InstClass).CreateSubType(nil,
                  SetAttr.SubType, 'ByID');
                InstObj.Transaction := AObj.Transaction;
              end;
              try
                while not q.Eof do
                begin
                  AWriter.StartNewLine;
                  AWriter.WriteSequenceIndicator;
                  InstObj.Close;
                  InstObj.ID := q.Fields[0].AsInteger;
                  InstObj.Open;
                  if not InstObj.EOF then
                    FN := InstObj.FieldByName(InstObj.GetListField(InstObj.SubType)).AsString
                  else
                    FN := '';

                  AWriter.WriteText(GetReferenceString(
                    gdcBaseManager.GetRUIDStringByID(
                      q.Fields[0].AsInteger, AObj.Transaction),
                    FN), qDoubleQuoted);  
                  q.Next;
                end;
              finally
                InstObj.Free;
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
      OL.Free;
      q.Free;
    end;
  end;  

const
  PassFieldName =
    ';ID;CREATORKEY;EDITORKEY;ACHAG;AVIEW;AFULL;LB;RB;RESERVED' +
    ';BREAKPOINTS;EDITORSTATE;TESTRESULT' +
    ';RDB$PROCEDURE_BLR;RDB$TRIGGER_BLR;RDB$VIEW_BLR;LASTEXTIME' +
    ';PARENTINDEX;';
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
  AWriter.WriteText(AgdcObject.Classname, qDoubleQuoted);
  if AgdcObject.SubType > '' then
  begin
    AWriter.StartNewLine;
    AWriter.WriteKey('SubType');
    AWriter.WriteText(AgdcObject.SubType, qDoubleQuoted);
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
  if AgdcObject.FindField('editiondate') <> nil then
  begin
    AWriter.StartNewLine;
    AWriter.WriteKey('Modified');
    AWriter.WriteTimestamp(AgdcObject.FieldByName('editiondate').AsDateTime);
  end;
  AWriter.DecIndent;
  AWriter.StartNewLine;
  AWriter.WriteKey('Fields');
  AWriter.IncIndent;

  try
    for I := 0 to AgdcObject.Fields.Count - 1 do
    begin
      F := AgdcObject.Fields[I];

      if StrIPos(';' + F.FieldName + ';', PassFieldName) > 0 then
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
                  FN), qDoubleQuoted);
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
          ftBCD:
          begin
            if DecimalSeparator <> '.' then
              AWriter.WriteText(StringReplace(F.AsString, DecimalSeparator, '.', []), qDoubleQuoted)
            else
              AWriter.WriteText(F.AsString, qDoubleQuoted);
          end;
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
          AWriter.WriteText(F.AsString, qDoubleQuoted);
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
  begin
    Result := nsfNone;
    q := TIBSQL.Create(nil);
    try
      q.Transaction := Tr;
      q.SQL.Text := 'SELECT * FROM at_namespace n ' +
        'LEFT JOIN gd_ruid r ON n.id = r.id ' +
        'WHERE r.xid || ''_'' || r.dbid = :ruid';
      q.ParamByName('ruid').AsString := RUID;
      q.ExecQuery;

      if not q.Eof then
      begin
        Result := nsfByRUID;
      end else
      begin
        RUID := '';
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
    At_Obj: TgdcAt_Object;
  begin
    Assert(SL <> nil);

    if RUID = '' then
      exit;

    q := TIBSQL.Create(nil);
    try
      q.Transaction := Tr;
      q.SQL.Text :=
        'SELECT o.xid || ''_'' || o.dbid as ruid, o.modified, o.curr_modified, o.objectclass, o.subtype, n.filetimestamp, ' +
        ' n.id, o.id, o.headobjectkey, o.objectname ' +
        'FROM at_object o ' +
        '  LEFT JOIN at_namespace n ' +
        '    ON o.namespacekey = n.id ' +
        '  LEFT JOIN gd_ruid r' +
        '    ON  n.id = r.id ' +
        'WHERE r.xid || ''_'' || r.dbid = :ruid ' +
        'ORDER BY o.objectpos asc';
      q.ParamByName('ruid').AsString := RUID;
      q.ExecQuery;

      while not q.Eof do
      begin
        At_Obj := TgdcAt_Object.Create;
        At_Obj.RUID := q.Fields[0].AsString;
        At_Obj.Objectclass := q.Fields[3].AsString;
        At_Obj.SubType := q.Fields[4].AsString;
        At_Obj.Modified := q.Fields[1].AsDateTime;
        At_Obj.Curr_modified := q.Fields[2].AsDateTime;
        At_Obj.Filetimestamp := q.Fields[5].AsDateTime;
        At_Obj.NamespaceKey := q.Fields[6].AsInteger;
        At_Obj.ID := q.Fields[7].AsInteger;
        At_Obj.Headobjectkey := q.Fields[8].AsInteger;
        At_Obj.ObjectName := q.Fields[9].AsString;
        SL.AddObject(q.Fields[0].AsString, At_Obj);
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

  procedure DeleteObject(At_Obj: TgdcAt_Object; OL: TStringList);

    function CanDeleteObj(Obj: TgdcBase; var Error: String): Boolean;
    var
      TempTr: TIBTransaction;
      q: TIBSQL;
    begin
      Result := True;
      Error := '';
      TempTr := TIBTransaction.Create(nil);
      q := TIBSQL.Create(nil);
      try
        TempTr.DefaultDatabase := gdcBaseManager.Database;
        TempTr.StartTransaction;
        try
          q.Transaction := TempTr;
          q.SQL.Text := Format('DELETE FROM %0:s WHERE %1:s = :id',
            [Obj.GetListTable(Obj.SubType), Obj.GetKeyField(Obj.SubType)]);
          q.ParamByName('id').AsInteger := Obj.ID;
          q.ExecQuery;
        except
          on Ex: EIBError do
          begin
            if (Ex.IBErrorCode = isc_foreign_key) or ((Ex.IBErrorCode = isc_except) and (
              StrIPos('GD_E_FKMANAGER', Ex.Message) > 0)) then
            begin
              Result := False;
              Error := 'Запись "' + Obj.FieldByName(Obj.GetListField(Obj.SubType)).AsString + '" невозможно удалить так как на нее ссылаются другие записи.';
            end;
          end;
        end;
      finally
        if TempTr.InTransaction then
          TempTr.Rollback;
        q.Free;
        TempTr.Free;
      end;
    end;

  var
    J: Integer;  
    InstObj: TgdcBase;
    InstClass: TPersistentClass;
    q: TIBSQL;
    Error: String;
    CanDelete: Boolean;
  begin
    q := TIBSQL.Create(nil);
    try
      q.Transaction := Tr;
      q.SQl.Text := 'DELETE FROM at_object WHERE namespacekey = :nsk and xid = :xid and dbid = :dbid';
      CanDelete := False; 
      InstClass := GetClass(At_Obj.Objectclass);
      if InstClass <> nil then
      begin
        InstObj := CgdcBase(InstClass).CreateSubType(nil,
          At_Obj.SubType, 'ByID');
        try
          InstObj.Transaction := Tr;
          InstObj.ID := gdcBaseManager.GetRUIDRecByXID(StrToRUID(At_Obj.RUID).XID, StrToRUID(At_Obj.RUID).DBID, Tr).ID;
          InstObj.Open;
          if not InstObj.Eof then
          begin
            if (At_Obj.Filetimestamp > 0)
              and (At_Obj.Curr_modified > 0)
              and (At_Obj.Filetimestamp >= At_Obj.Curr_modified)
            then
              CanDelete := True
            else
              if MessageBox(0,
                PChar(
                  'В базе данных найден объект "' + InstObj.FieldByName(InstObj.GetListField(InstObj.SubType)).AsString + '"'#13#10 +
                  'RUID: ' +  At_Obj.RUID + #13#10 +
                  'Класс: ' + At_Obj.Objectclass + At_Obj.SubType + #13#10#13#10 +
                  'Удалить объект из базы данных?'),
                'Внимание',
                MB_ICONQUESTION or MB_YESNO or MB_TASKMODAL) = IDYES
              then
                CanDelete := True;

              if CanDelete then
              begin
                if CanDeleteObj(InstObj, Error) then
                begin
                  InstObj.Delete;
                  q.Close;
                  q.ParamByName('nsk').AsInteger := At_Obj.NamespaceKey;
                  q.ParamByName('xid').AsInteger := StrToRUID(At_Obj.RUID).XID;
                  q.ParamByName('dbid').AsInteger := StrToRUID(At_Obj.RUID).DBID;
                  q.ExecQuery;
                  AddText('Объект ''' + At_Obj.ObjectName + ''' удален в процессе загрузки нового пространства имен.', clBlack);
                  for J := 0 to OL.Count - 1 do
                  begin
                    if (OL.Objects[J] as TgdcAt_Object).Headobjectkey = At_Obj.ID then
                      DeleteObject(OL.Objects[J] as TgdcAt_Object, OL);
                  end;
                end else
                  AddMistake(Error, clRed);
              end;
          end else
          begin
            q.Close;
            q.ParamByName('nsk').AsInteger := At_Obj.NamespaceKey;
            q.ParamByName('xid').AsInteger := StrToRUID(At_Obj.RUID).XID;
            q.ParamByName('dbid').AsInteger := StrToRUID(At_Obj.RUID).DBID;
            q.ExecQuery;
          end;
        finally
          InstObj.Free;
        end;
      end;
    finally
      q.Free;
    end;
  end;

  procedure UpdateObject(CurrOL, LoadOL: TStringList);
  var
    I: Integer;
  begin
    for I := CurrOL.Count - 1 downto 0 do
    begin
      if LoadOL.IndexOf(CurrOL[I]) = -1 then
        DeleteObject(CurrOL.Objects[I] as TgdcAt_Object, CurrOL);
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
  RUID, HeadRUID, LoadNSRUID, CurrNSRuid: String;
  WasMetaData, WasMetaDataInSetting, SubTypeFound: Boolean;
  LoadClassName, LoadSubType: String;
  C: TClass;
  ObjList: TStringList;
  Obj: TgdcBase;
  gdcNamespaceObj: TgdcNamespaceObject;
  UpdateList: TObjectList;
  UpdateHeadList, SubTypes: TStringList;
  q: TIBSQL; 
  gdcFullClass: TgdcFullClass;
  IsLoad: TLoadedStatus;
  TimeStamp: TDateTime;
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

      ConnectDatabase;
      for I := 0 to ANamespaceList.Count - 1 do
      begin
        if LoadNamespace.IndexOf(ANamespaceList[I]) > -1 then
          continue;

        for J := 0 to UpdateHeadList.Count - 1 do
          UpdateHeadList.Objects[J].Free;
        UpdateHeadList.Clear;

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
            CurrNSRuid := LoadNSRUID;
            LoadedNS(M.ReadString('Properties\Name'), CurrNSRuid);
            AddText('Начата загрузка пространства имен ' + M.ReadString('Properties\Name'), clBlack);
            gdcNamespace := TgdcNamespace.Create(nil);
            try
              gdcNamespace.ReadTransaction := Tr;
              gdcNamespace.Transaction := Tr;
              gdcNamespace.SubSet := 'ByID';
              gdcNamespace.ID := gdcBaseManager.GetIDByRUIDString(CurrNSRuid, Tr);
              gdcNamespace.Open;
              if gdcNamespace.Eof then
              begin
                gdcBaseManager.DeleteRUIDbyXID(StrToRUID(CurrNSRuid).XID, StrToRUID(CurrNSRuid).DBID, Tr);
                gdcNamespace.Insert;
              end else
                gdcNamespace.Edit;

              gdcNamespace.FieldByName('name').AsString := M.ReadString('Properties\Name');
              gdcNamespace.FieldByName('caption').AsString := M.ReadString('Properties\Caption');
              gdcNamespace.FieldByName('version').AsString := M.ReadString('Properties\Version');
              gdcNamespace.FieldByName('dbversion').AsString := M.ReadString('Properties\DBversion');
              gdcNamespace.FieldByName('optional').AsInteger := Integer(M.ReadBoolean('Properties\Optional', False));
              gdcNamespace.FieldByName('internal').AsInteger := Integer(M.ReadBoolean('Properties\internal', True));
              gdcNamespace.FieldByName('comment').AsString := M.ReadString('Properties\Comment');
              TimeStamp := gd_common_functions.GetFileLastWrite(ANamespaceList[I]);
              if TimeStamp > Now then
                gdcnamespace.FieldByName('filetimestamp').AsDateTime := Now
              else
                gdcnamespace.FieldByName('filetimestamp').AsDateTime := TimeStamp;
              gdcNamespace.FieldByName('filename').AsString := ANamespaceList[I];
              gdcNamespace.Post;
              TempNamespaceID := gdcNamespace.ID;

              if gdcBaseManager.GetRUIDRecByID(gdcNamespace.ID, Tr).XID = -1 then
              begin
                gdcBaseManager.InsertRUID(gdcNamespace.ID,
                  StrToRUID(LoadNSRUID).XID,
                  StrToRUID(LoadNSRUID).DBID,
                  Now, IBLogin.ContactKey, Tr);
              end else
              begin
                gdcBaseManager.UpdateRUIDByID(gdcNamespace.ID,
                  StrToRUID(LoadNSRUID).XID,
                  StrToRUID(LoadNSRUID).DBID,
                  Now, IBLogin.ContactKey, Tr);
              end;
            finally
              gdcNamespace.Free;
            end;

            if gdcBaseManager.GetIDByRUIDString(CurrNSRuid, Tr) > -1 then
            begin
              UpdateCurrModified(gdcBaseManager.GetIDByRUIDString(CurrNSRuid, Tr));
              FillObjectsRUIDInDB(CurrNSRuid, CurrObjectsRUID);
            end;

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

                  IsLoad := LoadObject(Obj, ObjMapping, UpdateList, CurrObjectsRUID, Tr);

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
                      gdcNamespaceObj.Insert
                    else
                      gdcNamespaceObj.Edit;
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
                    if Obj.FindField('editiondate') <> nil then
                      gdcNamespaceObj.FieldByName('modified').Value := Obj.FieldByName('editiondate').Value
                    else
                      gdcNamespaceObj.FieldByName('modified').Clear;
                    gdcNamespaceObj.FieldByName('curr_modified').Clear;

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

                    HeadObjectUpdate(UpdateHeadList, TempNamespaceID,
                      RUIDToStr(Obj.GetRUID), gdcNamespaceObj.ID);

                    if IsLoad <> lsNone then
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

            N := M.FindByName('USES');
            if (N <> nil) and (N is TyamlSequence) and (TempNamespaceID > -1) then
              CheckUses(N as TyamlSequence, TempNamespaceID);

            LoadNamespace.Add(ANamespaceList[I]);
            RunMultiConnection;

            AddText('Закончена загрузка пространства имен ' + M.ReadString('Properties\Name'), clBlack);
          end;
        finally
          Parser.Free;
        end;
      end;

      UpdateObject(CurrObjectsRUID, LoadObjectsRUID);

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
      for I := 0 to CurrObjectsRUID.Count - 1 do
        CurrObjectsRUID.Objects[I].Free;
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


class procedure TgdcNamespace.FillSet(AnObj: TgdcBase; AnOL: TObjectList; ATr: TIBTransaction);
var
  I, K: Integer;
  F, FD: TatRelationField;  
  q: TIBSQL;
  RL, LT: TStrings;
  SetAttr: TgdcSetAttr;
  C: TgdcFullClass;
begin
  Assert(AnOL <> nil);
  q := TIBSQL.Create(nil);
  try
    if (ATr = nil) or (not ATr.InTransaction) then
      q.Transaction := gdcBaseManager.ReadTransaction
    else
      q.Transaction := ATr;

    RL := TStringList.Create;
    try
      if AnObj.GetListTable(AnObj.SubType) <> '' then
        RL.Add(AnsiUpperCase(AnObj.GetListTable(AnObj.SubType)));

      LT := TStringList.Create;
      try
        (LT as TStringList).Duplicates := dupIgnore;
        GetTablesName(AnObj.SelectSQL.Text, LT);
        for I := 0 to LT.Count - 1 do
        begin
          if (RL.IndexOf(LT[I]) = -1)
            and AnObj.ClassType.InheritsFrom(GetBaseClassForRelation(LT[I]).gdClass)
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

          SetAttr := TgdcSetAttr.Create;
          C := GetBaseClassForRelation(FD.References.RelationName);
          if Assigned(C.gdClass) then
          begin
            SetAttr.ClassName := C.gdClass.ClassName;
            SetAttr.SubType := C.SubType;
          end else
          begin
            SetAttr.ClassName := FD.References.RelationName;
            SetAttr.SubType := 'NULL';
          end;

          SetAttr.SQL := 'SELECT ' + FD.FieldName +
            ' FROM ' + FD.Relation.RelationName +
            ' WHERE ' + F.FieldName + ' = :rf';
          SetAttr.RefFieldName := F.ReferencesField.FieldName;
          SetAttr.RefTableName := FD.Relation.RelationName;
          AnOL.Add(SetAttr);                    
        end;
    finally
      RL.Free;
    end;
  finally
    q.Free;
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

                  if gdcNamespaceObj.Eof and (gdcBaseManager.GetIDByRUIDString(RUID) > 0) then
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
  UpdateList: TObjectList; RUIDList: TStringList; ATr: TIBTransaction;
  const AnAlwaysoverwrite: Boolean = False): TLoadedStatus;  

  function InsertRecord(SourceYAML: TyamlMapping; Obj: TgdcBase;
    UL: TObjectList; const RUID: String): TLoadedStatus; forward;

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
    I: Integer;
  begin
    if TyamlScalar(N).IsNull then
      Field.Clear
    else
    begin
      CheckDataType(Field, N);
      case Field.DataType of
        ftDateTime, ftTime: Field.AsDateTime := TyamlDateTime(N).AsDateTime;
        ftDate: Field.AsDateTime := TyamlDate(N).AsDate;
        ftInteger, ftSmallint, ftWord: Field.AsInteger := TyamlScalar(N).AsInteger;
        ftFloat, ftCurrency: Field.AsFloat := TyamlScalar(N).AsFloat;
        ftBoolean: Field.AsBoolean := TyamlBoolean(N).AsBoolean;
        ftBCD:
        begin
          Temps := TyamlString(N).AsString;
          for I := 1 to Length(Temps) do
            if (Temps[I] in ['.', ',']) and (Temps[I] <> DecimalSeparator) then
              Temps[I] := DecimalSeparator;
          Field.AsString := TempS;
        end;
        ftBlob, ftGraphic:
        begin
          Flag := False;

          if
            (AnObj.ClassName = 'TgdcStorageValue')
            and
            (N is TyamlString) then
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
            (N is TyamlString) then
          begin
            Field.AsString := TyamlScalar(N).AsString;
            Flag := True;
          end;
          if not Flag and (N is TyamlBinary) then
          begin  
            TBlobField(Field).LoadFromStream(TyamlBinary(N).AsStream);
          end;
        end;
      else  
        Field.AsString := TyamlString(N).AsString;
      end;
    end;
  end;

  function CopyRecord(SourceYAML: TyamlMapping; Obj: TgdcBase; UL: TObjectList): TLoadedStatus;
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
    
    Result := lsNone;
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
            Result := lsModified;
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
        begin
          Obj.Post;
          Result := lsInsert;
        end else
        begin
          if Obj.DSModified then
            Result := lsModified
          else
            Result := lsUnModified;
        end;

        if Assigned(RUOL) then
        begin
          for I := 0 to RUOL.Count - 1 do
            TgdcReferenceUpdate(RUOL[I]).ID := Obj.ID;
        end;

        ApplyDelayedUpdates(UL,
          RUID,
          Obj.ID);

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

          AddMistake(ErrorSt, clRed);
          Obj.Cancel;
        end;
      end;
    finally
      if Assigned(RUOL) then
        RUOL.Free;
    end;
  end;

  function InsertRecord(SourceYAML: TyamlMapping; Obj: TgdcBase;
    UL: TObjectList; const RUID: String): TLoadedStatus;
  begin 
    Obj.Insert;
    if StrToRUID(RUID).XID < cstUserIDStart then
      Obj.ID := StrToRUID(RUID).XID;
    Result := CopyRecord(SourceYAML, Obj, UL);
    if  Result <> lsNone then
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
    Name, RUID: String;
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

                if ParseReferenceString((Items[J] as TyamlScalar).AsString, RUID, Name) then
                begin
                  ID := gdcBaseManager.GetIDByRUIDString(RUID, ATr);
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
                end else
                  AddWarning(#13#10 + 'Запись ''' + (Items[J] as TyamlScalar).AsString + ''' в таблицу ' + RN + ' не добавлена! RUID некорректен!'#13#10, clRed);
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

  procedure FillDataSet(CDS: TClientDataSet; Obj: TgdcBase; Fields: TyamlMapping);
  const
    PassFieldName = ';ID;EDITIONDATE;CREATIONDATE;CREATORKEY;EDITORKEY;ACHAG;AVIEW;AFULL;LB;RB;RESERVED;';
  var
    FN: String;
    F: TField;
    R: TatRelation;
    RF: TatRelationField;
    RefList: TStringList;
    RUID, Name: String;
    I: Integer;
    N: TyamlNode;
  begin
    RefList := TStringList.Create;
    try
      CDS.FieldDefs.Add('LR_FieldName', ftString, 255, False); 
      CDS.FieldDefs.Add('LR_Ref', ftInteger, 0, False);
      CDS.FieldDefs.Add('LR_NewValue', ftInteger, 0 , False);
      for I := 0 to Obj.FieldDefs.Count - 1 do
      begin
        if (Obj.FieldDefs[I].DataType in [ftBlob, ftGraphic])
          or Obj.FieldDefs[I].InternalCalcField
          or (StrIPos(';' + Obj.FieldDefs[I].Name + ';', PassFieldName) > 0)
        then
          continue;
          
        R := atDatabase.Relations.ByRelationName(Obj.RelationByAliasName(Obj.FieldDefs[I].Name));
        if R <> nil then
        begin
          RF := R.RelationFields.ByFieldName(Obj.FieldNameByAliasName(Obj.FieldDefs[I].Name));

          if (RF <> nil)
            and (RF.References <> nil)
            and (Obj.FieldDefs[I].DataType in [ftSmallint, ftInteger, ftWord, ftLargeint]) then
          begin
            RefList.Add(AnObj.FieldDefs[I].Name);
            CDS.FieldDefs.Add('L_' + Obj.FieldDefs[I].Name, ftString, 21, False);
            CDS.FieldDefs.Add('R_' + Obj.FieldDefs[I].Name, ftString, 21, False);
          end else
          begin
            CDS.FieldDefs.Add('L_' + Obj.FieldDefs[I].Name, Obj.FieldDefs[I].DataType, Obj.FieldDefs[I].Size, False);
            CDS.FieldDefs.Add('R_' + Obj.FieldDefs[I].Name, Obj.FieldDefs[I].DataType, Obj.FieldDefs[I].Size, False);
          end;
        end else
        begin
          CDS.FieldDefs.Add('L_' + Obj.FieldDefs[I].Name, Obj.FieldDefs[I].DataType, Obj.FieldDefs[I].Size, False);
          CDS.FieldDefs.Add('R_' + Obj.FieldDefs[I].Name, Obj.FieldDefs[I].DataType, Obj.FieldDefs[I].Size, False);
        end;
      end;
      CDS.CreateDataSet;
      CDS.Open;
      try
        for I := 0 to  Obj.Fields.Count - 1 do
        begin
          FN := Obj.Fields[I].FieldName;
          if CDS.FindField('L_' + FN) = nil then
            continue;
          CDS.Insert;
          CDS.FieldByName('LR_FieldName').AsString := FN;
          CDS.FieldByName('LR_NewValue').AsInteger := 1;
          if RefList.IndexOf(FN) > -1 then
          begin
            CDS.FieldByName('LR_Ref').AsInteger := 1;
            CDS.FieldByName('L_' + FN).AsString := gdcBaseManager.GetRUIDStringByID(AnObj.Fields[I].AsInteger, ATr);
            N := Fields.FindByName(FN);
            if (N <> nil) and (N is TyamlString) then
            begin
              if ParseReferenceString(TyamlString(N).AsString, RUID, Name) then
                CDS.FieldByName('R_' + FN).AsString := RUID;
            end;
          end else
          begin 
            if (Obj.Fields[I].AsString > '')
              and (Trim(Obj.Fields[I].AsString) = '')
            then
              CDS.FieldByName('L_' + FN).AsString := Obj.Fields[I].AsString
            else
              CDS.FieldByName('L_' + FN).AsString := Trim(Obj.Fields[I].AsString);

            N := Fields.FindByName(FN);
            F := CDS.FieldByName('R_' + FN);
            if (N <> nil) and (F <> nil) then
              SetValue(F, N, Fields);
          end;
          CDS.Post;
        end;
      except
        if CDS.State in dsEditModes then
          CDS.Cancel;
        raise;
      end;
    finally
      RefList.Free;
    end;
  end;

var
  D, J, I: Integer;
  RUID: String;
  RuidRec: TRuidRec;
  AlwaysOverwrite, ULCreated: Boolean;
  N: TyamlNode;
  Ind: Integer;
  Modify: TDateTime;
  at_obj: TgdcAt_Object;
  Compare: Boolean; 
  CDS: TClientDataSet;
  TempID: Integer;
begin
  Assert(ATr <> nil);
  Assert(gdcBaseManager <> nil);
  Assert(AMapping <> nil);

  Result := lsNone;
  RUID := AMapping.ReadString('Properties\RUID');
  Modify := AMapping.ReadDateTime('Properties\Modified');
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

            Ind := RUIDList.IndexOf(RUID);
            if (Ind > -1) then
            begin
              at_obj := RUIDList.Objects[Ind] as TgdcAt_Object;
              if (AnObj.FindField('editiondate') <> nil) then
              begin
                if at_obj.modified = AnObj.FieldByName('editiondate').AsDateTime then
                begin
                  AlwaysOverwrite := AlwaysOverwrite or (Modify > AnObj.FieldByName('editiondate').AsDateTime);
                end else
                begin
                  Compare := (AnObj.FieldByName('editiondate').AsDateTime > at_obj.modified)
                    and
                    (
                      ((Modify = at_obj.modified) and AlwaysOverwrite)
                      or
                      (Modify > at_obj.modified)
                    );
                  if Compare then
                  begin
                    CDS := TClientDataSet.Create(nil);
                    try
                      FillDataSet(CDS, AnObj, AMapping.FindByName('Fields') as TyamlMapping);
                      with TdlgCompareNSRecords.Create(nil) do
                      try
                        Records := CDS;
                        lblClassname.Caption := AnObj.GetDisplayName(AnObj.SubType);
                        lblName.Caption := AnObj.FieldByName(AnObj.GetListField(AnObj.SubType)).AsString;
                        lblID.Caption := IntToStr(AnObj.ID);
                        if ShowModal = mrOK then
                        begin
                          CDS.First;
                          AnObj.Edit;
                          for I := 0 to AnObj.Fields.Count - 1 do
                          begin
                            if CDS.Locate('LR_FieldName',  AnObj.Fields[I].FieldName, []) then
                            begin
                              if CDS.FieldByName('LR_NewValue').AsInteger = 1 then
                              begin
                                if CDS.FieldByName('LR_Ref').AsInteger = 1 then
                                begin
                                  TempID := gdcBaseManager.GetIDByRUIDString(CDS.FieldByName('R_' + AnObj.Fields[I].FieldName).AsString, ATr);
                                  if TempID > 0 then
                                    AnObj.Fields[I].AsInteger := TempID
                                  else
                                    AddWarning(#13#10 + 'При обновлении данных, объект (RUID =  ''' + CDS.FieldByName('R_' + AnObj.Fields[I].FieldName).AsString + ''') в базе не найден! '#13#10, clRed);
                                end else
                                  AnObj.Fields[I].Value := CDS.FieldByName('R_' + AnObj.Fields[I].FieldName).Value;
                              end;
                            end;
                          end;
                          AnObj.Post;
                          Result := lsModified;
                        end else
                          Result := lsUnModified;
                      finally
                        Free;
                      end;
                    finally
                      CDS.Free;
                    end;
                  end;
                end;
              end;
            end;

            if (Result = lsNone) and (AlwaysOverwrite) then
            begin
              AnObj.Edit;
              AnObj.ModifyFromStream := AlwaysOverwrite;
              Result := CopyRecord(AMapping, AnObj, UpdateList);
              if Result <> lsNone then
              begin
                AnObj.CheckBrowseMode;
                gdcBaseManager.UpdateRUIDByXID(AnObj.ID,
                  StrToRUID(RUID).XID,
                  StrToRUID(RUID).DBID,
                  now, IBLogin.ContactKey, ATr);
              end;
            end;   

            if Result in [lsNone, lsUnModified] then
            begin
              ApplyDelayedUpdates(UpdateList,
                AMapping.ReadString('Properties\RUID'),
                AnObj.ID);
              Result := lsUnModified;
            end;
          end;
        end;

        if Result in [lsModified, lsInsert] then
        begin
          N := AMapping.FindByName('Set');
          if (N <> nil) and (N is TyamlSequence) then
          begin
            with N as TyamlSequence do
            begin
              for J := 0 to Count - 1 do
                LoadSet(Items[J] as TyamlMapping, AnObj.ID, UpdateList);
            end;
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
        if FIncBuildVersion then
        begin
          Edit;
          FieldByName('Version').AsString := IncVersion(FieldByName('Version').AsString, '.');
          Post; 
        end;
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

        gdcNamespace.SaveNamespaceToStream(SS, IDCANCEL);
      finally
        gdcNamespace.Free;
        Tr.Free;
      end;
    end else
      SaveNamespaceToStream(SS, IDCANCEL);

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

procedure TgdcNamespace.SaveNamespaceToStream(St: TStream; const AnAnswer: Integer = 0);
var
  Obj: TgdcNamespaceObject;
  W: TyamlWriter;
  InstID: Integer;
  InstObj: TgdcBase;
  InstClass: TPersistentClass;
  q: TIBSQL;
  HeadObject: String;
  WasDelete: Boolean;
  Answer: Integer;
begin
  Assert(St <> nil);

  if State <> dsBrowse then
    raise EgdcException.CreateObj('Not in a browse state', Self);

  Answer := AnAnswer;
  W := TyamlWriter.Create(St);
  q := TIBSQL.Create(nil);
  try
    if (Transaction = nil) or (not Transaction.InTransaction) then
      q.Transaction := gdcBaseManager.ReadTransaction
    else
      q.Transaction := Transaction;
    W.WriteDirective(dirYAML11);
    W.StartNewLine;
    W.WriteKey('StructureVersion');
    W.WriteText('1.0', qDoubleQuoted);
    W.StartNewLine;
    W.WriteKey('Properties');
    W.IncIndent;
    W.StartNewLine;
    W.WriteKey('RUID');
    W.WriteString(RUIDToStr(GetRUID));
    W.StartNewLine;
    W.WriteKey('Name');
    W.WriteText(FieldByName('name').AsString, qDoubleQuoted);
    W.StartNewLine;
    W.WriteKey('Caption');
    W.WriteText(FieldByName('caption').AsString, qDoubleQuoted);
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
          qDoubleQuoted);
        q.Next;
      end;
      W.DecIndent;
      W.StartNewLine;
    end;
    q.Close;
    q.SQL.Text :=
      'SELECT xid || ''_'' || dbid as ruid FROM at_object WHERE id = :id';

    CheckIncludesiblings;
    WasDelete := False;
    Obj := TgdcNamespaceObject.Create(nil);
    try
      if Transaction.InTransaction then
      begin
        Obj.Transaction := Transaction;
        Obj.ReadTransaction := Transaction;
      end;  
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

                if InstObj.FindField('editiondate') <> nil then
                begin
                  Obj.Edit;
                  Obj.FieldByName('modified').Value := InstObj.FindField('editiondate').Value;
                  Obj.Post;
                end;
              finally
                W.DecIndent;
              end;
            end else
            begin
              if Answer = mrNone then
                Answer := MessageBox(0,
                  PChar(
                    'В базе данных не найден объект "' + Obj.FieldByName('objectname').AsString + '"'#13#10 +
                    'RUID: XID = ' +  Obj.FieldByName('xid').AsString + ', DBID = ' + Obj.FieldByName('dbid').AsString + #13#10 +
                    'Класс: ' + Obj.FieldByName('objectclass').AsString + Obj.FieldByName('subtype').AsString + #13#10#13#10 +
                    'Удалить запись об объекте из пространства имен?'),
                  'Ошибка',
                  MB_ICONQUESTION or MB_YESNO or MB_TASKMODAL);
              if Answer = IDYES then
              begin
                Obj.Delete;
                WasDelete := True;
              end;
            end;
          finally
            InstObj.Free;
          end;
        end;

        if WasDelete then
          WasDelete := False
        else
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
  ANSList: TgsNSList; Log: TNSLog);
var
  I: Integer;
  CurrDir: String;
  NSNode: TgsNSNode;
  NL: TStringList;  
  NSTreeNode: TgsNSTreeNode;
begin
  Assert(ADataSet <> nil);
  Assert(ANSList <> nil);

  NL := TStringList.Create;
  try
    ANSList.CustomSort(CompareFolder);
    CurrDir := '';

    for I := ANSList.Count - 1 downto 0 do
    begin
      NSNode := ANSList.Objects[I] as TgsNSNode;

      if NSNode.GetDisplayFolder <> CurrDir then
      begin
        CurrDir := NSNode.GetDisplayFolder;
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
      ADataSet.FieldByName('fileruid').AsString := NSNode.RUID;
      ADataSet.FieldByName('fileinternal').AsInteger := Integer(NSNode.Internal);

      ADataSet.FieldByName('namespacekey').AsInteger := NSNode.Namespacekey;
      ADataSet.FieldByName('namespacename').AsString := NSNode.NamespaceName;
      ADataSet.FieldByName('namespaceversion').AsString := NSNode.VersionInDB;
      ADataSet.FieldByName('namespaceinternal').AsInteger := Integer(NSNode.NamespaceInternal);
      if NSNode.NamespaceTimestamp <> 0 then
        ADataSet.FieldByName('namespacetimestamp').AsDateTime := NSNode.NamespaceTimestamp;
      ADataSet.FieldByName('operation').AsString := NSNode.GetOperation;
      if ADataSet.FieldByName('operation').AsString = '!' then
      begin
        NSTreeNode := ANSList.NSTree.GetTreeNodeByRUID(NSNode.RUID);
        if (NSTreeNode <> nil)
          and (NSTreeNode.Parent <> nil)
          and (NSTreeNode.Parent.YamlNode <> nil)
        then
          ADataSet.FieldByName('filenamespacename').AsString := NSNode.Name + ' (' + NSTreeNode.Parent.YamlNode.Name + ')';
      end;
      ADataSet.Post;
    end;

    ADataSet.First;
  finally 
    NL.Free;
  end;
end;

procedure TgdcNamespace.InstallPackages(ANSList: TStringList;
  const AnAlwaysoverwrite: Boolean = False; const ADontremove: Boolean = False);
begin
  Assert(ANSList <> nil);

  if ANSList.Count > 0 then
    DoLoadNamespace(ANSList, AnAlwaysOverwrite, ADontRemove);
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

  procedure FillRecord(AnObj: TgdcBase; const AHeadObj: String = '');
  var
    KSA: TgdKeyStringAssoc;
  begin
    ADataSet.Append;
    ADataSet.FieldByName('id').AsInteger := AnObj.ID;
    ADataSet.FieldByName('name').AsString := AnObj.ObjectName;
    ADataSet.FieldByname('class').AsString := AnObj.GetCurrRecordClass.gdClass.ClassName;
    ADataSet.FieldByName('subtype').AsString := AnObj.SubType;
    ADataSet.FieldByName('headobject').AsString := AHeadObj;
    if AnObj.SubType > '' then
      ADataSet.FieldByName('displayname').AsString := AnObj.ClassName + '\' + AnObj.SubType
    else
      ADataSet.FieldByName('displayname').AsString := AnObj.GetCurrRecordClass.gdClass.ClassName;
    ADataSet.FieldByName('displayname').AsString := ADataSet.FieldByName('displayname').AsString +
      '/' + AnObj.ObjectName;
    KSA := TgdKeyStringAssoc.Create;
    try
      SetNamespaceForObject(AnObj, KSA, ATr);
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
  end;

  procedure GetSetAttr(AnObj: TgdcBase);
  var
    OL: TObjectList;
    InstObj: TgdcBase;
    InstClass: TPersistentClass;
    SetAttr: TgdcSetAttr;
    q: TIBSQL;
    I: Integer;
  begin
    OL := TObjectList.Create;
    q := TIBSQL.Create(nil);
    try
      q.Transaction := ATr;
      FillSet(AnObject, OL, ATr);

      for I := 0 to OL.Count - 1 do
      begin
        SetAttr := OL[I] as TgdcSetAttr;
        if SetAttr.SubType <> 'NULL' then
        begin
          InstClass := GetClass(SetAttr.ClassName);
          if (InstClass <> nil) then
          begin
            q.Close;
            q.SQL.Text := SetAttr.SQL;
            q.ParamByName('rf').AsInteger := AnObject.FieldByName(SetAttr.RefFieldName).AsInteger;
            q.ExecQuery;

            if not q.Eof then
            begin
              InstObj := CgdcBase(InstClass).CreateSubType(nil,
                SetAttr.SubType, 'ByID');
              try
                while not q.Eof do
                begin
                  InstObj.Close;
                  InstObj.ID := q.Fields[0].AsInteger;
                  InstObj.Open;
                  if not InstObj.EOF then
                  begin
                    if not ADataSet.Locate('id', InstObj.ID, []) then
                      FillRecord(InstObj);
                  end;
                  q.Next;
                end;
              finally
                InstObj.Free;
              end;
            end;
          end;
        end;
      end;
    finally
      OL.Free;
      q.Free;
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
            GetSetAttr(Obj);
            
            FillRecord(Obj, RUIDToStr(AnObj.GetRUID));

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

     GetSetAttr(AnObject);
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
          gdcNamespaceObject.FieldByName('objectclass').AsString :=  AnObject.GetCurrRecordClass.gdClass.ClassName;
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

  function CanDeleteObj(Obj: TgdcBase; var Error: String): Boolean;
  var
    Tr: TIBTransaction;
    q: TIBSQL;
  begin
    
    Result := True;
    Error := '';
    Tr := TIBTransaction.Create(nil);
    q := TIBSQL.Create(nil);
    try
      Tr.DefaultDatabase := gdcBaseManager.Database;
      Tr.StartTransaction;
      try
        q.Transaction := Tr;
        q.SQL.Text := Format('DELETE FROM %0:s WHERE %1:s = :id',
          [Obj.GetListTable(Obj.SubType), Obj.GetKeyField(Obj.SubType)]);
        q.ParamByName('id').AsInteger := Obj.ID;
        q.ExecQuery;
      except
        on Ex: EIBError do
        begin
          if (Ex.IBErrorCode = isc_foreign_key) or ((Ex.IBErrorCode = isc_except) and (
            StrIPos('GD_E_FKMANAGER', Ex.Message) > 0)) then
          begin
            Result := False;
            Error := 'Запись "' + Obj.FieldByName(Obj.GetListField(Obj.SubType)).AsString + '" невозможно удалить так как на нее ссылаются другие записи.';
          end;
        end;
      end;
    finally
      if Tr.InTransaction then
        Tr.Rollback;
      q.Free;
      Tr.Free;
    end;
  end;

var
  gdcNamespaceObject: TgdcNamespaceObject;
  q: TIBSQL;
  InstObj: TgdcBase;
  InstClass: TPersistentClass;
  Error: String;
  WasDelete: Boolean;
  RUIDRec: TRUIDRec;
begin
  WasDelete := True;
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
          RUIDRec := gdcBaseManager.GetRUIDRecByXID(gdcNamespaceObject.FieldByName('xid').AsInteger,
            gdcNamespaceObject.FieldByName('dbid').AsInteger, Transaction);

          InstClass := GetClass(gdcNamespaceObject.FieldByName('objectclass').AsString);
          if InstClass <> nil then
          begin
            InstObj := CgdcBase(InstClass).CreateSubType(nil,
              gdcNamespaceObject.FieldByName('subtype').AsString, 'ByID');
            try
              InstObj.ID := RUIDRec.ID;
              InstObj.Open;
              if (not InstObj.EOF) then
              begin
                if CanDeleteObj(InstObj, Error) then
                begin
                  InstObj.Delete;
                end else
                begin
                  WasDelete := False;
                  AddMistake(Error, clRed);
                end;
              end;
            finaLLY
              InstObj.Free;
            end;
          end;
        end;
        q.Close;
      end;
      if WasDelete then
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

class procedure TgdcNamespace.UpdateCurrModified(const ANamespaceKey: Integer = -1);
var
  Tr: TIBTransaction;
  qList, q: TIBSQL;
  C: TPersistentClass;
  LT: String;
  SL: TStringList;
begin
  Assert(IBLogin <> nil);
  Assert(IBLogin.Database <> nil);

  Tr := TIBTransaction.Create(nil);
  qList := TIBSQL.Create(nil);
  q := TIBSQL.Create(nil);
  SL := TStringList.Create;
  try
    SL.Sorted := True;

    Tr.DefaultDatabase := IBLogin.Database;
    Tr.StartTransaction;

    q.Transaction := Tr;

    qList.Transaction := Tr;
    qList.SQL.Text :=
      'SELECT DISTINCT o.objectclass, o.subtype ' +
      'FROM at_object o ';
    if ANamespaceKey > -1 then
      qList.SQL.Text := qList.SQL.Text +
        'WHERE o.namespacekey = ' + IntToStr(ANamespaceKey);
    qList.ExecQuery;

    while not qList.EOF do
    begin
      C := GetClass(qList.FieldByName('objectclass').AsString);
      if (C <> nil) and C.InheritsFrom(TgdcBase) then
      begin
        LT := CgdcBase(C).GetListTable(qList.FieldByName('subtype').AsString);

        if SL.IndexOf(LT) = -1 then
        begin
          SL.Add(LT);

          q.Close;
          q.SQL.Text :=
            'SELECT rdb$relation_name FROM rdb$relation_fields ' +
            'WHERE rdb$relation_name = :RN AND rdb$field_name = ''EDITIONDATE'' ';
          q.ParamByName('RN').AsString := UpperCase(LT);
          q.ExecQuery;

          if not q.EOF then
          begin
            q.Close;
            q.SQL.Text :=
              'merge into at_object o '#13#10 +
              '  using (select r.xid, r.dbid, d.editiondate '#13#10 +
              '    from ' + LT + ' d join gd_ruid r '#13#10 +
              '    on r.id = d.id '#13#10 +
              '  union all '#13#10 +
              '    select d.id as xid, 17 as dbid, d.editiondate '#13#10 +
              '    from ' + LT + ' d '#13#10 +
              '    where d.id < 147000000) de '#13#10 +
              '  on o.xid=de.xid and o.dbid=de.dbid and ((o.curr_modified IS NULL) or (o.curr_modified < de.editiondate))'#13#10 +
              'when matched then '#13#10 +
              '  update set o.curr_modified = de.editiondate';
            q.ExecQuery;
          end;
        end;
      end;

      qList.Next;
    end;

    Tr.Commit;
  finally
    SL.Free;
    q.Free;
    qList.Free;
    Tr.Free;
  end;
end;

procedure TgdcNamespaceObject.ShowObject;
var
  ObjID: Integer;
  Obj: TgdcBase;
  Cl: TPersistentClass;
begin
  Obj := nil;
  try
    ObjID := gdcBaseManager.GetIDByRUID(FieldByName('xid').AsInteger,
      FieldByName('dbid').AsInteger);
    if ObjID <> -1 then
    begin
      Cl := GetClass(FieldByName('objectclass').AsString);
      if (Cl <> nil) and Cl.InheritsFrom(TgdcBase) then
      begin
        Obj := CgdcBase(Cl).CreateWithID(nil, nil, nil,
          ObjID,
          FieldByName('subtype').AsString);
        Obj.Open;
        if not Obj.IsEmpty then
          Obj.EditDialog;
      end;
    end;
  finally
    Obj.Free;
  end;
end;

initialization
  RegisterGDCClass(TgdcNamespace);
  RegisterGDCClass(TgdcNamespaceObject);

finalization
  UnRegisterGDCClass(TgdcNamespace);
  UnRegisterGDCClass(TgdcNamespaceObject);
end.
