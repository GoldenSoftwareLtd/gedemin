
unit gdcNamespace;

interface

uses
  SysUtils, gdcBase, gdcBaseInterface, Classes, gd_ClassList, JclStrHashMap,
  gd_createable_form, at_classes, IBSQL, db, yaml_writer, yaml_parser,
  IBDatabase, gd_security, dbgrids, gd_KeyAssoc, contnrs, IB, gsNSObjects;

type
  TnsLoadedStatus = (lsNone, lsUnModified, lsModified, lsInsert);
  TnsOverwrite = (ovOverwriteIfNewer, ovAlwaysOverwrite);
  TnsRemove = (rmRemove, rmDontRemove);
  TnsIncludeSiblings = (isDontInclude, isInclude);

  TgdcNamespace = class(TgdcBase)
  private
    FIncBuildVersion: Boolean;

    procedure CheckIncludesiblings;

  protected
    function GetOrderClause: String; override;
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
      const AHeadObject: String; const AnAlwaysOverwrite: Boolean;
      const ADontRemove: Boolean; const AnIncludeSiblings: Boolean;
      AnObjCache: TStringHashMap);
    class function LoadObject(AnObj: TgdcBase; AMapping: TyamlMapping;
      UpdateList: TObjectList; RUIDList: TStringList; ATr: TIBTransaction;
      const AnAlwaysoverwrite: Boolean = False): TnsLoadedStatus;
    class procedure ScanDirectory(ADataSet: TDataSet; ANSList: TgsNSList;
      Log: TNSLog);

    class procedure AddObject(const ANamespaceKey: Integer;
      const AName: String; const AClass: String; const ASubType: String;
      const XID, DBID: Integer; const AHeadObjectKey: Integer;
      const AnAlwaysoverwrite: TnsOverwrite;
      const ADontRemove: TnsRemove;
      const AnIncludeSiblings: TnsIncludeSiblings;
      ATr: TIBTransaction);
    class function LoadNSInfo(const Path: String; ATr: TIBTransaction): Integer;
    class function CompareObj(ADataSet: TDataSet): Boolean;
    class procedure UpdateCurrModified(const ANamespaceKey: Integer = -1);
    class procedure WriteChanges(ADataSet: TDataSet; AnObj: TgdcBase; ATr: TIBTransaction);

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

  function GetReferenceString(AnIDField: TField; AnObjectNameField: TField; ATr: TIBTransaction): String; overload;
  function GetReferenceString(AnIDField: TField; const AnObjectName: String; ATr: TIBTransaction): String; overload;
  function GetReferenceString(AnIDField: TIBXSQLVAR; AnObjectNameField: TIBXSQLVAR; ATr: TIBTransaction): String; overload;
  function ParseReferenceString(const AStr: String; out ARUID: String; out AName: String): Boolean;
  function IncVersion(const V: String; const Divider: Char = '.'): String;

  procedure Register;

implementation

uses
  Windows, Controls, ComCtrls, IBHeader, IBErrorCodes, Graphics, DBClient,
  gdc_dlgNamespacePos_unit, gdc_dlgNamespace_unit, gdc_frmNamespace_unit,
  at_sql_parser, jclStrings, gdcTree, yaml_common, gd_common_functions,
  prp_ScriptComparer_unit, gdc_dlgNamespaceObjectPos_unit, jclUnicode,
  at_frmSyncNamespace_unit, jclFileUtils, gd_directories_const,
  gd_FileList_unit, gdcClasses, at_sql_metadata, gdcConstants, at_frmSQLProcess,
  Storages, gdcMetadata, at_sql_setup, gsDesktopManager, at_Classes_body,
  at_dlgCompareNSRecords_unit;

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

procedure Register;
begin
  RegisterComponents('gdcNamespace', [TgdcNamespace, TgdcNamespaceObject]);
end;

function GetReferenceString(AnIDField: TField; AnObjectNameField: TField; ATr: TIBTransaction): String; overload;
begin
  if AnIDField.IsNull then
    Result := '~'
  else begin
    Result := gdcBaseManager.GetRUIDStringByID(AnIDField.AsInteger, ATr) + ' ' +
      AnObjectNameField.AsString;
  end;
end;

function GetReferenceString(AnIDField: TField; const AnObjectName: String; ATr: TIBTransaction): String; overload
begin
  if AnIDField.IsNull then
    Result := '~'
  else begin
    Result := gdcBaseManager.GetRUIDStringByID(AnIDField.AsInteger, ATr) + ' ' +
      AnObjectName;
  end;
end;

function GetReferenceString(AnIDField: TIBXSQLVAR; AnObjectNameField: TIBXSQLVAR; ATr: TIBTransaction): String; overload;
begin
  if AnIDField.IsNull then
    Result := '~'
  else begin
    Result := gdcBaseManager.GetRUIDStringByID(AnIDField.AsInteger, ATr) + ' ' +
      AnObjectNameField.AsString;
  end;
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

function IncVersion(const V: String; const Divider: Char = '.'): String;
var
  E: Integer;
begin
  E := Length(V);
  while (E > 0) and (V[E] <> Divider) do
    Dec(E);
  Result := Copy(V, 1, E) + IntToStr(StrToIntDef(Copy(V, E + 1, 255), 0) + 1);
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
  const AHeadObject: String; const AnAlwaysOverwrite: Boolean;
  const ADontRemove: Boolean; const AnIncludeSiblings: Boolean;
  AnObjCache: TStringHashMap);

  procedure WriteSet(AnObj: TgdcBase; AWriter: TyamlWriter);
  var
    I, J: Integer;
    q: TIBSQL;
    SectionAdded: Boolean;
    R: TatRelation;
    F: TIBXSQLVAR;
    MS: TMemoryStream;
  begin
    Assert(AnObj <> nil);
    Assert(AWriter <> nil);

    SectionAdded := False;
    q := TIBSQL.Create(nil);
    try
      if AnObj.Transaction.InTransaction then
        q.Transaction := AnObj.Transaction
      else
        q.Transaction := AnObj.ReadTransaction;
      for I := 0 to AnObj.SetAttributesCount - 1 do
      begin
        if AnsiCompareText(AnObj.SetAttributes[I].CrossRelationName, 'GD_LASTNUMBER') = 0 then
          continue;

        if AnsiCompareText(AnObj.SetAttributes[I].CrossRelationName, 'FLT_LASTFILTER') = 0 then
          continue;

        q.SQL.Text := AnObj.SetAttributes[I].SQL;
        q.ParamByName('rf').AsInteger := AnObj.ID;
        q.ExecQuery;

        if not q.Eof then
        begin
          if not SectionAdded then
          begin
            AWriter.DecIndent;
            AWriter.StartNewLine;
            AWriter.WriteKey('Set');
            AWriter.IncIndent;
            SectionAdded := True;
          end;

          if AnObj.SetAttributes[I].HasAdditionalFields then
            R := atDatabase.Relations.ByRelationName(AnObj.SetAttributes[I].CrossRelationName)
          else
            R := nil;

          AWriter.StartNewLine;
          AWriter.WriteSequenceIndicator;
          AWriter.IncIndent;
          try
            AWriter.WriteTextValue('Table',
              AnObj.SetAttributes[I].CrossRelationName, qDoubleQuoted);

            AWriter.StartNewLine;
            AWriter.WriteKey('Items');

            AWriter.IncIndent;
            try
              while not q.Eof do
              begin
                AWriter.StartNewLine;
                AWriter.WriteSequenceIndicator;
                AWriter.IncIndent;
                AWriter.WriteTextValue(AnObj.SetAttributes[I].ReferenceLinkFieldName,
                  GetReferenceString(q.FieldByName(AnObj.SetAttributes[I].ReferenceLinkFieldName),
                    q.FieldByName(AnObj.SetAttributes[I].ReferenceObjectNameFieldName), AnObj.Transaction),
                  qDoubleQuoted);
                if R <> nil then
                begin
                  for J := 0 to R.RelationFields.Count - 1 do
                  begin
                    if R.RelationFields[J] = R.PrimaryKey.ConstraintFields[0] then
                      continue;
                    if R.RelationFields[J] = R.PrimaryKey.ConstraintFields[1] then
                      continue;
                    F := q.FieldByName(R.RelationFields[J].FieldName);
                    if F.IsNull then
                      AWriter.WriteNullValue(R.RelationFields[J].FieldName)
                    else
                      case F.SQLType of
                        SQL_BLOB:
                          if F.AsXSQLVar.sqlsubtype = 1 then
                            AWriter.WriteTextValue(R.RelationFields[J].FieldName, F.AsString, qPlain, sLiteral)
                          else begin
                            MS := TMemoryStream.Create;
                            try
                              F.SaveToStream(MS);
                              MS.Position := 0;
                              AWriter.WriteBinaryValue(R.RelationFields[J].FieldName, MS);
                            finally
                              MS.Free;
                            end;
                          end;
                        SQL_INT64:
                          if F.AsXSQLVAR.sqlscale = 0 then
                            AWriter.WriteLargeIntValue(R.RelationFields[J].FieldName, F.AsInt64)
                          else
                            AWriter.WriteCurrencyValue(R.RelationFields[J].FieldName, F.AsCurrency);
                        SQL_FLOAT, SQL_D_FLOAT, SQL_DOUBLE:
                          AWriter.WriteFloatValue(R.RelationFields[J].FieldName, F.AsFloat);
                        SQL_LONG, SQL_SHORT:
                          if F.AsXSQLVAR.sqlscale = 0 then
                            AWriter.WriteIntegerValue(R.RelationFields[J].FieldName, F.AsInteger)
                          else
                            AWriter.WriteCurrencyValue(R.RelationFields[J].FieldName, F.AsCurrency);
                        SQL_TIMESTAMP, SQL_TYPE_TIME:
                          AWriter.WriteTimeStampValue(R.RelationFields[J].FieldName, F.AsDateTime);
                        SQL_TYPE_DATE:
                          AWriter.WriteDateValue(R.RelationFields[J].FieldName, F.AsDate);
                        SQL_TEXT:
                          AWriter.WriteTextValue(R.RelationFields[J].FieldName,
                            F.AsTrimString, qDoubleQuoted);
                      else
                        AWriter.WriteTextValue(R.RelationFields[J].FieldName,
                          F.AsString, qDoubleQuoted);
                      end;
                  end;
                end;
                AWriter.DecIndent;
                q.Next;
              end;
            finally
              AWriter.DecIndent;
            end;
          finally
            AWriter.DecIndent;
          end;
        end;

        q.Close;
      end;
    finally
      q.Free;
    end;
  end;

const
  PassFieldName =
    ';ID;CREATORKEY;EDITORKEY;ACHAG;AVIEW;AFULL;LB;RB;RESERVED' +
    ';BREAKPOINTS;EDITORSTATE;TESTRESULT;LASTEXTIME;PARENTINDEX' +
    ';RDB$TRIGGER_BLR;RDB$PROCEDURE_BLR;RDB$VIEW_BLR;RDB$SECURITY_CLASS;';
var
  I: Integer;
  R: TatRelation;
  F: TField;
  ObjName: String;
  RF: TatRelationField;
  FK: TatForeignKey;
  RelationName, FieldName: String;
  Obj: TgdcBase;
  C: TgdcFullClass;
  BlobStream: TStream;
  TempS: String;
  Flag, MustFreeObj: Boolean;
begin
  Assert(gdcBaseManager <> nil);
  Assert(atDatabase <> nil);
  Assert(AgdcObject <> nil);
  Assert(not AgdcObject.EOF);

  AWriter.WriteKey('Properties');
  AWriter.IncIndent;
  AWriter.WriteTextValue('Class', AgdcObject.ClassName, qDoubleQuoted);
  if AgdcObject.SubType > '' then
    AWriter.WriteTextValue('SubType', AgdcObject.SubType, qDoubleQuoted);
  AWriter.WriteStringValue('RUID', RUIDToStr(AgdcObject.GetRUID));
  AWriter.WriteBooleanValue('AlwaysOverwrite', AnAlwaysoverwrite);
  AWriter.WriteBooleanValue('DontRemove', ADontremove);
  AWriter.WriteBooleanValue('IncludeSiblings', AnIncludesiblings);
  if AHeadObject > '' then
    AWriter.WriteStringValue('HeadObject', AHeadObject);
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

      if (F.Origin > '') and not F.IsNull then
      begin
        ParseFieldOrigin(F.Origin, RelationName, FieldName);

        if RelationName > '' then
        begin
          R := atDatabase.Relations.ByRelationName(RelationName);
          if Assigned(R) then
          begin
            RF := R.RelationFields.ByFieldName(FieldName);
            if Assigned(RF) then
            begin
              if Assigned(RF.CrossRelation) then
                continue;

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
                  Obj := nil;
                  MustFreeObj := False;

                  if (AnObjCache = nil) or (not AnObjCache.Find(C.gdClass.ClassName + C.SubType, Obj)) then
                  begin
                    Obj := C.gdClass.Create(nil);
                    Obj.SubType := C.SubType;
                    Obj.ReadTransaction := AgdcObject.ReadTransaction;
                    Obj.Transaction := AgdcObject.Transaction;
                    Obj.SubSet := 'ByID';

                    if AnObjCache = nil then
                      MustFreeObj := True
                    else
                      AnObjCache.Add(C.gdClass.ClassName + C.SubType, Obj);
                  end;

                  try
                    Obj.Close;
                    Obj.ID := F.AsInteger;
                    Obj.Open;
                    if Obj.EOF then
                      ObjName := ''
                    else begin
                      if Obj is TgdcTree then
                        ObjName := TgdcTree(Obj).GetPath
                      else
                        ObjName := Obj.ObjectName;
                    end;
                  finally
                    if MustFreeObj then
                      Obj.Free;
                  end;
                end;

                AWriter.WriteTextValue(F.FieldName,
                  GetReferenceString(F, ObjName, AgdcObject.Transaction), qDoubleQuoted);
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
          ftDateTime, ftTime: AWriter.WriteTimeStamp(F.AsDateTime);
          ftMemo: AWriter.WriteText(F.AsString, qPlain, sLiteral);
          ftInteger, ftSmallint, ftWord: AWriter.WriteInteger(F.AsInteger);
          ftBoolean: AWriter.WriteBoolean(F.AsBoolean);
          ftFloat: AWriter.WriteFloat(F.AsFloat);
          ftCurrency: AWriter.WriteCurrency(F.AsCurrency);
          ftLargeint: AWriter.WriteString(F.AsString);
          ftBCD: AWriter.WriteBCD(F.AsString);
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
    Tr.Free;
  end;
end;

class procedure TgdcNamespace.WriteChanges(ADataSet: TDataSet; AnObj: TgdcBase; ATr: TIBTransaction);
var
  I, TempID: Integer;
begin
  Assert(ADataSet <> nil);
  Assert(AnObj <> nil);
  Assert(ATr <> nil);
  Assert(ATr.InTransaction);

  ADataSet.DisableControls;
  try
    ADataSet.First;
    AnObj.Edit;
    try
      for I := 0 to AnObj.Fields.Count - 1 do
      begin
        if ADataSet.Locate('LR_FieldName',  AnObj.Fields[I].FieldName, [])
          and (ADataSet.FieldByName('LR_NewValue').AsInteger = 1) then
        begin
          if ADataSet.FieldByName('R_' + AnObj.Fields[I].FieldName).IsNull then
          begin
            AnObj.Fields[I].Clear;
            continue;
          end;

          if (ADataSet.FieldByName('LR_Ref').AsInteger = 1) then
          begin
            TempID := gdcBaseManager.GetIDByRUIDString(ADataSet.FieldByName('R_' + AnObj.Fields[I].FieldName).AsString, ATr);
            if TempID > 0 then
              AnObj.Fields[I].AsInteger := TempID
            else
              AddWarning('При обновлении данных, объект (RUID = ' +
                ADataSet.FieldByName('R_' + AnObj.Fields[I].FieldName).AsString +
                ') в базе не найден!', clRed);
          end else
            AnObj.Fields[I].Value := ADataSet.FieldByName('R_' + AnObj.Fields[I].FieldName).Value;
        end;
      end;
      AnObj.Post
    finally
      if AnObj.State in dsEditModes then
        AnObj.Cancel;
    end;
  finally
    ADataSet.EnableControls;
  end;
end;

procedure TgdcNamespace.CheckIncludesiblings;
var
  Obj: TgdcNamespaceObject;
  Cl: TPersistentClass;
  ClTree: TgdcFullClass;
  q, qCheck: TIBSQL;
  ListObj: TgdcBase;
begin
  Assert(not EOF);
  Assert(Transaction.InTransaction);

  Obj := nil;
  ListObj := nil;
  q := TIBSQL.Create(nil);
  qCheck := TIBSQL.Create(nil);
  try
    qCheck.Transaction := Transaction;
    qCheck.SQL.Text :=
      'SELECT id FROM at_object ' +
      'WHERE namespacekey = :nk AND xid = :xid AND dbid = :dbid';

    q.Transaction := Transaction;
    q.SQL.Text :=
      'SELECT * FROM at_object ' +
      'WHERE namespacekey = :nk AND includesiblings <> 0 ' +
      'ORDER BY objectpos DESC ';
    q.ParamByName('nk').AsInteger := ID;
    q.ExecQuery;
    while not q.EOF do
    begin
      Cl := GetClass(q.FieldByName('objectclass').AsString);

      if (Cl <> nil) and Cl.InheritsFrom(TgdcTree) then
      begin
        ClTree := GetBaseClassForRelation(CgdcTree(Cl).GetListTable(
          q.FieldByName('subtype').AsString));

        if (ClTree.gdClass <> nil) and ClTree.gdClass.InheritsFrom(TgdcTree) then
        begin
          if (ListObj <> nil) and ((ListObj.ClassName <> ClTree.gdClass.ClassName)
            or (ListObj.SubType <> ClTree.SubType)) then
          begin
            FreeAndNil(ListObj);
          end;

          if ListObj = nil then
          begin
            ListObj := ClTree.gdClass.Create(nil);
            ListObj.ReadTransaction := Transaction;
            ListObj.Transaction := Transaction;
            ListObj.SubType := ClTree.SubType;
            ListObj.SubSet := 'ByRootID';
          end else
            ListObj.Close;

          ListObj.ParamByName('RootID').AsInteger := gdcBaseManager.GetIDByRUID(
            q.FieldByName('xid').AsInteger, q.FieldByName('dbid').AsInteger, Transaction);
          ListObj.Open;
          while not ListObj.Eof do
          begin
            qCheck.Close;
            qCheck.ParamByName('nk').AsInteger := ID;
            qCheck.ParamByName('xid').AsInteger := ListObj.GetRUID.XID;
            qCheck.ParamByName('dbid').AsInteger := ListObj.GetRUID.DBID;
            qCheck.ExecQuery;

            if qCheck.EOF then
            begin
              if Obj = nil then
              begin
                Obj := TgdcNamespaceObject.Create(nil);
                Obj.ReadTransaction := Transaction;
                Obj.Transaction := Transaction;
                Obj.Open;
              end;

              Obj.Insert;
              try
                Obj.FieldByName('namespacekey').AsInteger := ID;
                Obj.FieldByName('objectname').AsString := ListObj.ObjectName;
                Obj.FieldByName('objectclass').AsString := ListObj.GetCurrRecordClass.gdClass.ClassName;
                Obj.FieldByName('subtype').AsString := ListObj.GetCurrRecordClass.SubType;
                Obj.FieldByName('xid').AsInteger := ListObj.GetRUID.XID;
                Obj.FieldByName('dbid').AsInteger := ListObj.GetRUID.DBID;
                Obj.FieldByName('objectpos').AsInteger := q.FieldByName('objectpos').AsInteger + 1;
                Obj.FieldByName('alwaysoverwrite').AsInteger := q.FieldByName('alwaysoverwrite').AsInteger;
                Obj.FieldByName('dontremove').AsInteger := q.FieldByName('dontremove').AsInteger;
                Obj.FieldByName('includesiblings').AsInteger := 1;
                Obj.FieldByName('headobjectkey').AsInteger := q.FieldByName('id').AsInteger;
                Obj.Post;
              except
                if Obj.State = dsInsert then
                  Obj.Cancel;
                raise;
              end;
            end;

            ListObj.Next;
          end;
        end;
      end;

      q.Next;
    end;
  finally
    Obj.Free;
    ListObj.Free;
    q.Free;
    qCheck.Free;
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
    T_RUID: TRUID;
  begin
    Result := nsfNone;

    q := TIBSQL.Create(nil);
    try
      q.Transaction := Tr;
      q.SQL.Text :=
        'SELECT * ' +
        'FROM at_namespace n ' +
        '  JOIN gd_ruid r ON n.id = r.id ' +
        'WHERE r.xid = :xid and r.dbid = :dbid';
      T_RUID := StrToRUID(RUID);
      q.ParamByName('xid').AsInteger := T_RUID.XID;
      q.ParamByName('dbid').AsInteger := T_RUID.DBID;
      q.ExecQuery;

      if not q.Eof then
        Result := nsfByRUID
      else begin
        RUID := '';
        q.Close;
        q.SQL.Text :=
          'SELECT r.xid || ''_'' || r.dbid as ruid ' +
          'FROM at_namespace n ' +
          '  JOIN gd_ruid r ON n.id = r.id ' +
          'WHERE UPPER(n.name) = UPPER(:name)';
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

  procedure FillObjectsRUIDInDB(const RUID: TRUID; SL: TStringList);
  var
    q: TIBSQL;
    At_Obj: TgdcAt_Object;
  begin
    Assert(SL <> nil);

    if (RUID.XID = -1) or (RUID.DBID = -1) then
      exit;

    q := TIBSQL.Create(nil);
    try
      q.Transaction := Tr;
      q.SQL.Text :=
        'SELECT o.xid || ''_'' || o.dbid as ruid, o.modified, o.curr_modified, ' +
        '  o.objectclass, o.subtype, n.filetimestamp, ' +
        '  n.id, o.id, o.headobjectkey, o.objectname ' +
        'FROM at_object o ' +
        '  JOIN at_namespace n ' +
        '    ON o.namespacekey = n.id ' +
        '  JOIN gd_ruid r' +
        '    ON  n.id = r.id ' +
        'WHERE r.xid = :xid and r.dbid = :dbid ' +
        'ORDER BY o.objectpos asc';
      q.ParamByName('xid').AsInteger := RUID.XID;
      q.ParamByName('dbid').AsInteger := RUID.DBID;
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
      gdcNamespace.ReadTransaction := Tr;
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
  var
    J: Integer;  
    InstObj: TgdcBase;
    InstClass: TPersistentClass;
    q: TIBSQL; 
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
          InstObj.ReadTransaction := Tr;
          InstObj.Transaction := Tr;
          InstObj.ID := gdcBaseManager.GetRUIDRecByXID(StrToRUID(At_Obj.RUID).XID, StrToRUID(At_Obj.RUID).DBID, Tr).ID;
          InstObj.Open;
          if (not InstObj.Eof)
            and (InstObj.ID >= cstUserIDStart)
            and (InstObj.CanDelete) then
          begin
            if (At_Obj.Filetimestamp > 0)
              and (At_Obj.Curr_modified > 0)
              and (At_Obj.Filetimestamp >= At_Obj.Curr_modified)
            then
              CanDelete := True
            else
              if MessageBox(0,
                PChar(
                  'В базе данных найден объект "' + InstObj.ObjectName + '"'#13#10 +
                  'RUID: ' +  At_Obj.RUID + #13#10 +
                  'Класс: ' + At_Obj.Objectclass + At_Obj.SubType + #13#10#13#10 +
                  'Удалить объект из базы данных?'),
                'Внимание',
                MB_ICONQUESTION or MB_YESNO or MB_TASKMODAL) = IDYES
              then
                CanDelete := True;

              if CanDelete then
              begin
                try
                  InstObj.Delete;
                  AddText('Удален объект: ' +
                    At_Obj.ObjectClass +
                    At_Obj.SubType + ' ' +
                    At_Obj.RUID + ' "' + At_Obj.ObjectName + '"');
                except
                  on Ex: EIBError do
                  begin
                    if (Ex.IBErrorCode = isc_foreign_key) or ((Ex.IBErrorCode = isc_except) and (
                      StrIPos('GD_E_FKMANAGER', Ex.Message) > 0))
                    then
                      AddWarning('Запись "' + InstObj.ObjectName +
                        '" невозможно удалить так как на нее ссылаются другие записи.', clRed)
                    else
                      AddMistake(Ex.Message);
                  end;
                end;

                q.Close;
                q.ParamByName('nsk').AsInteger := At_Obj.NamespaceKey;
                q.ParamByName('xid').AsInteger := StrToRUID(At_Obj.RUID).XID;
                q.ParamByName('dbid').AsInteger := StrToRUID(At_Obj.RUID).DBID;
                q.ExecQuery;

                for J := OL.Count - 1 downto 0 do 
                begin
                  if (OL.Objects[J] as TgdcAt_Object).Headobjectkey = At_Obj.ID then
                    DeleteObject(OL.Objects[J] as TgdcAt_Object, OL);
                end;
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
    I, Ind: Integer;
    q: TIBSQL;
    at_obj: TgdcAt_Object;
  begin
    q := TIBSQL.Create(nil);
    try
      q.Transaction := Tr;
      q.SQL.Text := 'DELETE FROM at_object WHERE namespacekey = :nsk and xid = :xid and dbid = :dbid';
      for I := CurrOL.Count - 1 downto 0 do
      begin
        Ind := LoadOL.IndexOf(CurrOL[I]);
        if (Ind = -1) and not ADontRemove then
        begin
          DeleteObject(CurrOL.Objects[I] as TgdcAt_Object, CurrOL);
        end else
        begin
          at_obj := CurrOL.Objects[I] as TgdcAt_Object;  
          if ((LoadOL.Objects[Ind] as TgdcAt_Object).Namespacekey <> at_obj.NamespaceKey) or ADontRemove then
          begin
            q.ParamByName('nsk').AsInteger := at_obj.NamespaceKey;
            q.ParamByName('xid').AsInteger := StrToRUID(at_obj.RUID).XID;
            q.ParamByName('dbid').AsInteger := StrToRUID(at_obj.RUID).DBID;
            q.ExecQuery;
            q.Close;
          end;
        end;
      end;
    finally
      q.Free;
    end;
  end;
  
var
  LoadNamespace: TStringList;
  LoadObjectsRUID: TStringList;
  CurrObjectsRUID: TStringList;
  Parser: TyamlParser;
  I, J, Ind, K, LoadPos, ID: Integer;
  gdcNamespace: TgdcNamespace;
  TempNamespaceID: Integer;
  M, ObjMapping: TyamlMapping;
  N: TyamlNode;
  RecRUID, RUID: TRUID;
  HeadRUID, CurrNSRUID, LoadNSRUID: String;
  WasMetaData, WasMetaDataInSetting: Boolean;
  LoadClassName, LoadSubType: String;
  C: TClass;
  ObjList: TStringList;
  Obj: TgdcBase;
  gdcNamespaceObj: TgdcNamespaceObject;
  UpdateList: TObjectList;
  UpdateHeadList, SubTypes: TStringList;
  q: TIBSQL; 
  gdcFullClass: TgdcFullClass;
  IsLoad: TnsLoadedStatus;
  TimeStamp: TDateTime;
  at_obj: TgdcAt_Object;
begin
  Assert(atDatabase <> nil);
  Assert(IBLogin.Database <> nil);

  LoadNamespace:= TStringlist.Create;
  LoadObjectsRUID := TStringList.Create;
  CurrObjectsRUID := TStringList.Create;
  UpdateList := TObjectList.Create(True);
  ObjList := TStringList.Create;
  UpdateHeadList := TStringList.Create;
  q := TIBSQL.Create(nil);
  Tr := TIBTransaction.Create(nil);
  try
    ObjList.Sorted := True;
    ObjList.Duplicates := dupError;

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
      'WHERE xid = :xid and dbid = :dbid AND namespacekey = :nk';
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
            LoadPos := 0;
            LoadNSRUID := M.ReadString('Properties\RUID');
            CurrNSRuid := LoadNSRUID;
            LoadedNS(M.ReadString('Properties\Name'), CurrNSRuid);
            AddText('Загрузка пространства имен "' + M.ReadString('Properties\Name') + '"');
            gdcNamespace := TgdcNamespace.Create(nil);
            try
              gdcNamespace.ReadTransaction := Tr;
              gdcNamespace.Transaction := Tr;
              gdcNamespace.SubSet := 'ByID';
              gdcNamespace.ID := gdcBaseManager.GetIDByRUIDString(CurrNSRuid, Tr);
              gdcNamespace.Open;
              if gdcNamespace.Eof then
              begin
                RecRUID := StrToRUID(CurrNSRuid);
                gdcBaseManager.DeleteRUIDbyXID(RecRUID.XID, RecRUID.DBID, Tr);
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

              RecRUID := StrToRUID(LoadNSRUID);
              if gdcBaseManager.GetRUIDRecByID(gdcNamespace.ID, Tr).XID = -1 then
              begin
                gdcBaseManager.InsertRUID(gdcNamespace.ID,
                  RecRUID.XID,
                  RecRUID.DBID,
                  Now, IBLogin.ContactKey, Tr);
              end else
              begin
                gdcBaseManager.UpdateRUIDByID(gdcNamespace.ID,
                  RecRUID.XID,
                  RecRUID.DBID,
                  Now, IBLogin.ContactKey, Tr);
              end;
            finally
              gdcNamespace.Free;
            end;

            RecRUID := StrToRUID(CurrNSRuid);
            ID := gdcBaseManager.GetRUIDRecByXID(RecRUID.XID, RecRUID.DBID, Tr).ID;
            if  ID > -1 then
            begin
              UpdateCurrModified(ID);
              FillObjectsRUIDInDB(RecRUID, CurrObjectsRUID);
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
                  RUID := StrToRUID(ObjMapping.ReadString('Properties\RUID'));

                  if (LoadClassName = '')
                    or (RUID.XID = -1)
                    or (RUID.DBID = -1)
                  then
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
                      if not CgdcBase(C).CheckSubType(LoadSubType) then
                         ReconnectDatabase;

                      Obj := CgdcBase(C).CreateWithParams(nil,
                        Tr.DefaultDatabase, Tr, LoadSubType);

                      Obj.ReadTransaction := Tr;
                      Obj.SetRefreshSQLOn(False);
                      ObjList.AddObject(LoadClassName + '('+ LoadSubType + ')', Obj);
                    end else
                      Obj := ObjList.Objects[Ind] as TgdcBase;
                  end;

                  if Obj.SubSet <> 'ByID' then
                    Obj.SubSet := 'ByID';
                  Obj.Open;

                  IsLoad := LoadObject(Obj, ObjMapping, UpdateList, CurrObjectsRUID, Tr, AnAlwaysoverwrite);

                  if (Obj is TgdcRelationField) then
                    RelName := Obj.FieldByName('relationname').AsString
                  else
                    RelName := '';

                  gdcNamespaceObj :=  TgdcNamespaceObject.Create(nil);
                  try
                    gdcNamespaceObj.ReadTransaction := Tr;
                    gdcNamespaceObj.Transaction := Tr;
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
                    if Obj.ObjectName <> '' then
                      gdcNamespaceObj.FieldByName('objectname').AsString := Obj.ObjectName
                    else
                      gdcNamespaceObj.FieldByName('objectname').AsString := RUIDToStr(Obj.GetRUID);
                    gdcNamespaceObj.FieldByName('objectclass').AsString := Obj.ClassName;
                    gdcNamespaceObj.FieldByName('objectpos').AsInteger := LoadPos;
                    gdcNamespaceObj.FieldByName('subtype').AsString := Obj.SubType;
                    gdcNamespaceObj.FieldByName('xid').AsInteger := Obj.GetRUID.XID;
                    gdcNamespaceObj.FieldByName('dbid').AsInteger := Obj.GetRUID.DBID;
                    gdcNamespaceObj.FieldByName('alwaysoverwrite').AsInteger := Integer(ObjMapping.ReadBoolean('Properties\AlwaysOverwrite'));
                    gdcNamespaceObj.FieldByName('dontremove').AsInteger := Integer(ObjMapping.ReadBoolean('Properties\DontRemove'));
                    gdcNamespaceObj.FieldByName('includesiblings').AsInteger := Integer(ObjMapping.ReadBoolean('Properties\IncludeSiblings'));
                    if IsLoad in [lsModified, lsInsert] then
                    begin
                      if Obj.FindField('editiondate') <> nil then
                      begin
                        gdcNamespaceObj.FieldByName('modified').Value := Obj.FieldByName('editiondate').Value;
                        gdcNamespaceObj.FieldByName('curr_modified').Value := Obj.FieldByName('editiondate').Value;
                      end else
                      begin
                        gdcNamespaceObj.FieldByName('modified').AsDateTime := Now;
                        gdcNamespaceObj.FieldByName('curr_modified').Value := gdcNamespaceObj.FieldByName('modified').AsDateTime;
                      end;
                    end;
                    Inc(LoadPos);

                    HeadRUID := ObjMapping.ReadString('Properties\HeadObject');
                    RecRUID := StrToRUID(HeadRUID);
                    if HeadRUID <> '' then
                    begin
                      q.Close;
                      q.ParamByName('xid').AsInteger := RecRUID.XID;
                      q.ParamByName('dbid').AsInteger := RecRUID.DBID;
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
                      at_obj := TgdcAt_Object.Create;
                      at_obj.NamespaceKey := TempNamespaceID;
                      at_obj.RUID := RUIDToStr(Obj.GetRUID);
                      LoadObjectsRUID.AddObject(at_obj.RUID, at_obj);
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

            AddText('Окончена загрузка пространства имен "' + M.ReadString('Properties\Name') + '"');
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

        AddMistake(E.Message);
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
      for I := 0 to LoadObjectsRUID.Count - 1 do
        LoadObjectsRUID.Objects[I].Free;
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
    gdcNamespace.ReadTransaction := ATr;
    gdcNamespace.Transaction := ATr;
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
              gdcNamespaceObj.ReadTransaction := ATr;
              gdcNamespaceObj.Transaction := ATr;
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
  const AnAlwaysoverwrite: Boolean = False): TnsLoadedStatus;

  function InsertRecord(ASourceYAML: TyamlMapping; AnObj: TgdcBase;
    AnUL: TObjectList; const ARUID: TRUID): TnsLoadedStatus; forward;

  procedure CheckDataType(F: TField; Value: TyamlNode);
  var
    Flag: Boolean;
  begin
    Flag := False;
    case F.DataType of
      ftDateTime, ftTime: Flag := Value is TyamlDateTime;
      ftDate: Flag := Value is TyamlDate;
      ftInteger, ftSmallint, ftWord: Flag := Value is TyamlInteger;
      ftFloat, ftCurrency: Flag := Value is TyamlNumeric;
      ftBlob, ftGraphic: Flag := (Value is TyamlBinary) or (Value is TyamlString);
      ftString, ftMemo, ftBCD: Flag := Value is TyamlString;
      ftBoolean: Flag := Value is TyamlBoolean;
      ftLargeint: Flag := Value is TyamlInt64;
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
            Obj.ReadTransaction := ATr;
            Obj.Transaction := ATr;
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
        ftLargeint: TLargeintField(Field).AsLargeInt := TyamlInt64(N).AsInt64;
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

  function CopyRecord(SourceYAML: TyamlMapping; Obj: TgdcBase; UL: TObjectList): TnsLoadedStatus;
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
                AddWarning('Неверный RUID ' + RefRUID, clRed);
            end;
            continue;
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
              AddWarning('Неверный RUID ' + RefRUID, clRed);

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
            Result := lsModified;
            AddText('Обновлен объект: ' +
              Obj.ClassName +
              Obj.SubType + ' ' +
              RUID +
              ' "' + Obj.ObjectName + '"');
          except
            on E: EIBError do
            begin
              if (E.IBErrorCode = isc_no_dup) or (E.IBErrorCode = isc_except) then
              begin
                Obj.Cancel;
                AddText('РУИД не определен. Поиск объекта по уникальному ключу.');
                gdcBaseManager.DeleteRUIDByXID(StrToRUID(RUID).XID,
                  StrToRUID(RUID).XID, ATr);
                InsertRecord(SourceYAML, Obj, UL, StrToRUID(RUID));
              end else
                raise;
            end;
          end;
        end
        else if not Obj.CheckTheSame(True) then
        begin
          Obj.Post;
          Result := lsInsert;
          AddText('Создан объект: ' +
            Obj.ClassName +
            Obj.SubType + ' ' +
            RUIDToStr(Obj.GetRUID) +
            ' "' + Obj.ObjectName + '"');
        end else
        begin
          if Obj.DSModified then
          begin
            Result := lsModified;
            AddText(RUIDToStr(Obj.GetRUID) + ' -> ' + RUID);
          end else
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

          AddMistake(ErrorSt);
          Obj.Cancel;
        end;
      end;
    finally
      if Assigned(RUOL) then
        RUOL.Free;
    end;
  end;

  function InsertRecord(ASourceYAML: TyamlMapping; AnObj: TgdcBase;
    AnUL: TObjectList; const ARUID: TRUID): TnsLoadedStatus;
  var
    OldRUID, CurrRUID: TRUIDRec;
    q: TIBSQL;
  begin
    AnObj.Insert;
    try
      if IsGedeminSystemID(ARUID.XID) then
        AnObj.ID := ARUID.XID;
      Result := CopyRecord(ASourceYAML, AnObj, AnUL);
      if Result <> lsNone then
      begin
        if AnObj.State in [dsInsert, dsEdit] then
          AnObj.Post;

        OldRUID := gdcBaseManager.GetRUIDRecByID(AnObj.ID, ATr);

        if OldRUID.XID = -1 then
          gdcBaseManager.InsertRUID(AnObj.ID, ARUID.XID, ARUID.DBID, Now,
            IBLogin.ContactKey, ATr)
        else begin
          gdcBaseManager.UpdateRUIDByID(AnObj.ID, ARUID.XID, ARUID.DBID, Now,
            IBLogin.ContactKey, ATr);
          CurrRUID := gdcBaseManager.GetRUIDRecByID(AnObj.ID, ATr);
          if (OldRUID.XID <> CurrRUID.XID) or (OldRUID.DBID <> CurrRUID.DBID) then
          begin
            q := TIBSQL.Create(nil);
            try
              q.Transaction := ATr;
              q.SQL.Text := 'UPDATE at_object SET xid = :xid, dbid = :dbid ' +
                'WHERE xid = :xid2 and dbid = :dbid2';
              q.ParamByName('xid').AsInteger := CurrRUID.XID;
              q.ParamByName('dbid').AsInteger := CurrRUID.DBID;
              q.ParamByName('xid2').AsInteger := OldRUID.XID;
              q.ParamByName('dbid2').AsInteger := OldRUID.DBID;
              q.ExecQuery;
              AddText(RUIDToStr(RUID(OldRUID.XID, OldRUID.DBID)) + ' -> ' +
                RUIDToStr(RUID(CurrRUID.XID, CurrRUID.DBID)));
            finally
              q.Free;
            end;
          end;
        end;
      end;
    finally
      if AnObj.State in [dsInsert, dsEdit] then
        AnObj.Cancel;
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
                  AddWarning('Запись "' + (Items[J] as TyamlScalar).AsString +
                    '" в таблицу ' + RN + ' не добавлена! RUID некорректен!', clRed);
              end;
            end;
          end else
             AddWarning('Данные множества ' + RN + ' не были добавлены!', clRed);
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
      CDS.FieldDefs.Add('LR_Equal', ftInteger, 0, False);
      for I := 0 to Obj.FieldDefs.Count - 1 do
      begin
        if (StrIPos('RDB$', Obj.FieldDefs[I].Name) = 1)
          or (StrIPos(';' + Obj.FieldDefs[I].Name + ';', PassFieldName) > 0)
          or Obj.FieldDefs[I].InternalCalcField
          or (Obj.FieldDefs[I].DataType in [ftBlob, ftGraphic])
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
          CDS.FieldByName('LR_Equal').AsInteger := 1;
          if RefList.IndexOf(FN) > -1 then
          begin
            CDS.FieldByName('LR_Ref').AsInteger := 1;
            if not AnObj.Fields[I].IsNull then
              CDS.FieldByName('L_' + FN).AsString := gdcBaseManager.GetRUIDStringByID(AnObj.Fields[I].AsInteger, ATr)
            else
              CDS.FieldByName('L_' + FN).Clear;
              
            N := Fields.FindByName(FN);
            if (N <> nil)
              and (N is TyamlString)
              and (not TyamlString(N).IsNull) then
            begin
              if ParseReferenceString(TyamlString(N).AsString, RUID, Name) then
                CDS.FieldByName('R_' + FN).AsString := RUID;
            end else
              CDS.FieldByName('R_' + FN).Clear;
          end else
          begin
            CDS.FieldByName('L_' + FN).Value := Obj.Fields[I].Value;
            CDS.FieldByName('R_' + FN).Clear;

            N := Fields.FindByName(FN);
            F := CDS.FieldByName('R_' + FN);
            if (N <> nil)
              and (N is TyamlScalar)
              and (not TyamlScalar(N).IsNull)
              and (F <> nil)
            then
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
  D, J: Integer;
  RUID: TRUID;
  RuidRec: TRuidRec;
  AlwaysOverwrite, ULCreated: Boolean;
  N: TyamlNode;
  Ind: Integer;
  Modify: TDateTime;
  at_obj: TgdcAt_Object;
  Compare: Boolean;
  CDS: TClientDataSet; 
  Overwrite: Boolean;
  CreateDate: TDateTime;
begin
  Assert(ATr <> nil);
  Assert(gdcBaseManager <> nil);
  Assert(AMapping <> nil);

  Result := lsNone;
  RUID := StrToRUID(AMapping.ReadString('Properties\RUID'));
  Modify := AMapping.ReadDateTime('Fields\EDITIONDATE', Now);
  CreateDate := AMapping.ReadDateTime('Fields\CREATIONDATE', Now);
  AlwaysOverwrite := AMapping.ReadBoolean('Properties\AlwaysOverwrite');
  Overwrite := AlwaysOverwrite or AnAlwaysoverwrite;

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
        AnObj.BaseState := AnObj.BaseState + [sLoadFromStream];
        AnObj.ModifyFromStream := Overwrite;

        RuidRec := gdcBaseManager.GetRUIDRecByXID(RUID.XID,
          RUID.DBID, ATr);

        D := RuidRec.ID;

        if (D = -1) and (RUID.XID < cstUserIDStart) then
        begin
          if AnObj.SubSet <> 'ByID' then
            AnObj.SubSet := 'ByID';
          AnObj.ID := RUID.XID;
          AnObj.Open;

          if not AnObj.EOF then
          begin
            gdcBaseManager.InsertRUID(RUID.XID,
              RUID.XID,
              RUID.DBID, Now, IBLogin.ContactKey, ATr);
            D := RUID.XID;
          end;
        end;

        if D = -1 then
          Result := InsertRecord(AMapping, AnObj, UpdateList, RUID)
        else begin
          if AnObj.SubSet <> 'ByID' then
            AnObj.SubSet := 'ByID';
          AnObj.ID := D;
          AnObj.Open;

          if AnObj.EOF then
          begin
            gdcBaseManager.DeleteRUIDbyXID(RUID.XID,
              RUID.DBID, ATr);

            Result := InsertRecord(AMapping, AnObj, UpdateList, RUID);
          end else
          begin 
            Ind := RUIDList.IndexOf(RUIDToStr(RUID));
            if (Ind > -1) then
            begin
              at_obj := RUIDList.Objects[Ind] as TgdcAt_Object;
              if (AnObj.FindField('editiondate') <> nil) then
              begin
                if at_obj.modified = AnObj.FieldByName('editiondate').AsDateTime then
                begin
                  Overwrite := AlwaysOverwrite or AnAlwaysoverwrite or (Modify > AnObj.FieldByName('editiondate').AsDateTime);
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
                      if CompareObj(CDS) then
                      begin
                        with TdlgCompareNSRecords.Create(nil) do
                        try
                          Records := CDS;
                          lblClassname.Caption := AnObj.ClassName + AnObj.SubType;
                          lblName.Caption := AnObj.ObjectName;
                          lblID.Caption := IntToStr(AnObj.ID);
                          if ShowModal = mrOK then
                          begin
                            if CDS.Locate('LR_Equal', 0, []) then
                            begin
                              WriteChanges(CDS, AnObj, ATr);
                              Result := lsModified;
                            end else
                              Result := lsUnModified;
                          end else
                            Result := lsUnModified;
                        finally
                          Free;
                        end;
                      end else
                      begin
                        Result := lsUnModified;
                        if (AnObj.FindField('editiondate') <> nil)
                          and (Modify <> AnObj.FieldByName('editiondate').AsDateTime) then
                        begin
                          AnObj.Edit;
                          AnObj.FieldByName('editiondate').AsDateTime := Modify;
                          AnObj.Post;
                          Result := lsModified;
                        end;
                        
                        if (AnObj.FindField('creationdate') <> nil)
                          and (CreateDate <> AnObj.FieldByName('creationdate').AsDateTime) then
                        begin
                          AnObj.Edit;
                          AnObj.FieldByName('editiondate').AsDateTime := CreateDate;
                          AnObj.Post;
                          Result := lsModified;
                        end;
                      end;
                    finally
                      CDS.Free;
                    end;
                  end;
                end;
              end;
            end;

            if (Result = lsNone) and (Overwrite) then
            begin
              AnObj.Edit;
              AnObj.ModifyFromStream := Overwrite;
              Result := CopyRecord(AMapping, AnObj, UpdateList);
              if Result <> lsNone then
              begin
                AnObj.CheckBrowseMode;
                gdcBaseManager.UpdateRUIDByXID(AnObj.ID,
                  RUID.XID,
                  RUID.DBID,
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
  CheckBrowseMode;

  if AFileName > '' then
  begin
    if DirectoryExists(AFileName) then
      FN := IncludeTrailingBackSlash(AFileName) + ObjectName + '.yml'
    else
      FN := AFileName;
  end else
    FN := QuerySaveFileName('', 'yml', 'Файлы YML|*.yml');

  if FN = '' then
    exit;

  DidActivate := not Transaction.InTransaction;
  if DidActivate then
    Transaction.StartTransaction;
  try
    if FIncBuildVersion then
    begin
      Edit;
      FieldByName('Version').AsString := IncVersion(FieldByName('Version').AsString, '.');
      Post;
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

    if DidActivate and Transaction.InTransaction then
      Transaction.Commit;
  finally
    if DidActivate and Transaction.InTransaction then
      Transaction.Rollback;
  end;
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

class function TgdcNamespace.CompareObj(ADataSet: TDataSet): Boolean;
var
  FN, Str1, Str2: String;
begin
  Result := False;
  ADataSet.DisableControls;
  try
    ADataSet.First;
    while not ADataSet.Eof do
    begin
      FN := ADataSet.FieldByName('LR_FieldName').AsString;
      Str1 := ADataSet.FieldByName('L_' + FN).AsString;
      Str2 := ADataSet.FieldByName('R_' + FN).AsString;
      if (Trim(Str1) <> '') then
        Str1 := Trim(Str1);
      if (Trim(Str2) <> '') then
        Str2 := Trim(Str2);
      if AnsiCompareStr(Str1, Str2) <> 0 then
      begin
        ADataSet.Edit;
        try
          ADataSet.FieldByName('LR_Equal').AsInteger := 0;
          ADataSet.Post;
          Result := True;
        finally
          if ADataSet.State in dsEditModes then
            ADataSet.Cancel;
        end;
      end;
      ADataSet.Next;
    end;
  finally
    ADataSet.EnableControls;
  end;
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
        gdcNamespace.ReadTransaction := Tr;
        gdcNamespace.Transaction := Tr;
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
  InstObj: TgdcBase;
  InstClass: TPersistentClass;
  q: TIBSQL;
  HeadObject: String;
  Deleted: Boolean;
  Answer: Integer;
  ObjCache: TStringHashMap;
  DidActivate: Boolean;
begin
  Assert(St <> nil);
  Assert(Transaction <> nil);

  if State <> dsBrowse then
    raise EgdcException.CreateObj('Not in a browse state', Self);

  DidActivate := not Transaction.InTransaction;
  if DidActivate then
    Transaction.StartTransaction;

  Answer := AnAnswer;
  W := TyamlWriter.Create(St);
  q := TIBSQL.Create(nil);
  try
    q.Transaction := Transaction;

    W.WriteDirective(dirYAML11);
    W.StartNewLine;
    W.WriteDocumentStart;
    W.WriteTextValue('StructureVersion', '1.0', qDoubleQuoted);
    W.StartNewLine;
    W.WriteKey('Properties');
    W.IncIndent;
    W.WriteStringValue('RUID', RUIDToStr(GetRUID));
    W.WriteTextValue('Name', FieldByName('name').AsString, qDoubleQuoted);
    W.WriteTextValue('Caption', FieldByName('caption').AsString, qDoubleQuoted);
    W.WriteTextValue('Version', FieldByName('version').AsString, qDoubleQuoted);
    W.WriteBooleanValue('Optional', FieldByName('optional').AsInteger);
    W.WriteBooleanValue('Internal', FieldByName('internal').AsInteger);
    if FieldByName('dbversion').AsString > '' then
      W.WriteStringValue('DBVersion', FieldByName('dbversion').AsString);
    if FieldByName('comment').AsString > '' then
      W.WriteTextValue('Comment', FieldByName('comment').AsString);
    W.DecIndent;
    W.StartNewLine;

    q.SQL.Text :=
      'SELECT n.id, n.name ' +
      'FROM at_namespace_link l JOIN at_namespace n ' +
      '  ON l.useskey = n.id ' +
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
        W.WriteText(
          GetReferenceString(q.FieldByName('id'), q.FieldByName('name'), Transaction),
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
    Deleted := False;
    Obj := TgdcNamespaceObject.Create(nil);
    try
      Obj.ReadTransaction := Transaction;
      Obj.Transaction := Transaction;
      Obj.SubSet := 'ByNamespace';
      Obj.ParamByName('namespacekey').AsInteger := Self.ID;
      Obj.Open;

      if not Obj.Eof then
      begin
        ObjCache := TStringHashMap.Create(CaseInsensitiveTraits, 1024);
        try
          W.WriteKey('Objects');
          W.IncIndent;

          while not Obj.Eof do
          begin
            if not ObjCache.Find(Obj.FieldByName('objectclass').AsString +
              Obj.FieldByName('subtype').AsString, InstObj) then
            begin
              InstObj := nil;
              InstClass := GetClass(Obj.FieldByName('objectclass').AsString);
              if (InstClass <> nil) and InstClass.InheritsFrom(TgdcBase) then
              begin
                InstObj := CgdcBase(InstClass).Create(nil);
                InstObj.ReadTransaction := Obj.Transaction;
                InstObj.Transaction := Obj.Transaction;
                InstObj.SubType := Obj.FieldByName('subtype').AsString;
                InstObj.SubSet := 'ByID';
                ObjCache.Add(Obj.FieldByName('objectclass').AsString +
                  Obj.FieldByName('subtype').AsString, InstObj);
              end;
            end;

            if InstObj <> nil then
            begin
              InstObj.Close;
              InstObj.ID := gdcBaseManager.GetIDByRUID(Obj.FieldByName('xid').AsInteger,
                Obj.FieldByName('dbid').AsInteger, Transaction);
              InstObj.Open;

              if not InstObj.EOF then
              begin
                W.StartNewLine;
                W.WriteSequenceIndicator;
                W.IncIndent;
                try
                  W.StartNewLine;
                  HeadObject := '';
                  if not Obj.FieldByName('headobjectkey').IsNull then
                  begin
                    q.ParamByName('id').AsInteger := Obj.FieldByName('headobjectkey').AsInteger;
                    q.ExecQuery;
                    if not q.Eof then
                      HeadObject := q.FieldByName('ruid').AsString;
                    q.Close;
                  end;
                  WriteObject(InstObj, W, HeadObject,
                    Obj.FieldByName('alwaysoverwrite').AsInteger <> 0,
                    Obj.FieldByName('dontremove').AsInteger <> 0,
                    Obj.FieldByName('includesiblings').AsInteger <> 0,
                    ObjCache);

                  if (InstObj.FindField('editiondate') <> nil)
                    and (not InstObj.FieldByName('editiondate').IsNull) then
                  begin
                    Obj.Edit;
                    Obj.FieldByName('modified').AsDateTime := InstObj.FieldByName('editiondate').AsDateTime;
                    Obj.Post;
                  end;
                finally
                  W.DecIndent;
                end;
              end else
              begin
                if Answer = 0 then
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
                  Deleted := True;
                end;
              end;
            end;

            if Deleted then
              Deleted := False
            else
              Obj.Next;
          end;
        finally
          ObjCache.Iterate(nil, Iterate_FreeObjects);
          ObjCache.Free;
        end;
      end;
    finally
      Obj.Free;
    end;
  finally
    W.Free;
    q.Free;

    if DidActivate and Transaction.InTransaction then
      Transaction.Commit;
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

class procedure TgdcNamespace.AddObject(const ANamespaceKey: Integer;
  const AName: String; const AClass: String; const ASubType: String;
  const XID, DBID: Integer; const AHeadObjectKey: Integer;
  const AnAlwaysoverwrite: TnsOverwrite;
  const ADontRemove: TnsRemove;
  const AnIncludeSiblings: TnsIncludeSiblings;
  ATr: TIBTransaction);
var
  q, qFind: TIBSQL;
begin
  Assert(Assigned(ATr));
  Assert(ATr.InTransaction);

  q := TIBSQL.Create(nil);
  qFind := TIBSQL.Create(nil);
  try
    q.Transaction := ATr;

    qFind.Transaction := ATr;
    qFind.SQL.Text :=
      'SELECT namespacekey FROM at_object ' +
      'WHERE namespacekey <> :nk and xid = :xid and dbid = :dbid';
    qFind.ParamByName('nk').AsInteger := ANamespaceKey;
    qFind.ParamByName('xid').AsInteger := XID;
    qFind.ParamByName('dbid').AsInteger := DBID;
    qFind.ExecQuery;

    if not qFind.EOF then
    begin
      q.SQL.Text :=
        'UPDATE OR INSERT INTO at_namespace_link ' +
        '  (namespacekey, useskey) ' +
        'VALUES (:nk, :uk) ' +
        'MATCHING (namespacekey, useskey)';
      q.ParamByName('nk').AsInteger := ANamespaceKey;
      q.ParamByName('uk').AsInteger := qFind.FieldByName('namespacekey').AsInteger;
    end else
    begin
      q.SQL.Text :=
        'UPDATE OR INSERT INTO at_object ' +
        '  (namespacekey, objectname, objectclass, subtype, xid, dbid, headobjectkey, ' +
        '  alwaysoverwrite, dontremove, includesiblings) ' +
        'VALUES ' +
        '  (:namespacekey, :objectname, :objectclass, :subtype, :xid, :dbid, :headobjectkey, ' +
        '  :alwaysoverwrite, :dontremove, :includesiblings) ' +
        'MATCHING ' +
        '  (xid, dbid, namespacekey)';
      q.ParamByName('namespacekey').AsInteger := ANamespaceKey;
      q.ParamByName('objectname').AsString := AName;
      q.ParamByName('objectclass').AsString := AClass;
      q.ParamByName('subtype').AsString := ASubType;
      q.ParamByName('xid').AsInteger := XID;;
      q.ParamByName('dbid').AsInteger := DBID;
      if AHeadObjectKey = 0 then
        q.ParamByName('headobjectkey').Clear
      else
        q.ParamByName('headobjectkey').AsInteger := AHeadObjectKey;
      if AnAlwaysOverwrite = ovAlwaysOverwrite then
        q.ParamByName('alwaysoverwrite').AsInteger := 1
      else
        q.ParamByName('alwaysoverwrite').AsInteger := 0;
      if ADontRemove = rmDontRemove then
        q.ParamByName('dontremove').AsInteger := 1
      else
        q.ParamByName('dontremove').AsInteger := 0;
      if AnIncludeSiblings = isInclude then
        q.ParamByName('includesiblings').AsInteger := 1
      else
        q.ParamByName('includesiblings').AsInteger := 0;
    end;

    q.ExecQuery;
  finally
    qFind.Free;
    q.Free;
  end;
end;

procedure TgdcNamespace.DeleteObject(xid, dbid: Integer; RemoveObj: Boolean = True);
var
  gdcNamespaceObject: TgdcNamespaceObject;
  q: TIBSQL;
  InstObj: TgdcBase;
  InstClass: TPersistentClass;
  RUIDRec: TRUIDRec;
begin
  gdcNamespaceObject := TgdcNamespaceObject.Create(nil);
  q := TIBSQL.Create(nil);
  try
    q.Transaction := Transaction;
    q.SQL.Text :=
      'SELECT * FROM at_object ' +
      'WHERE namespacekey <> :nk and xid = :xid and dbid = :dbid';

    gdcNamespaceObject.ReadTransaction := Transaction;
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

class procedure TgdcNamespace.UpdateCurrModified(const ANamespaceKey: Integer = -1);
var
  Tr: TIBTransaction;
  qList, q: TIBSQL;
  C: TPersistentClass;
  RN: String;
begin
  Assert(IBLogin <> nil);
  Assert(IBLogin.Database <> nil);

  Tr := TIBTransaction.Create(nil);
  qList := TIBSQL.Create(nil);
  q := TIBSQL.Create(nil);
  try
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
        RN := UpperCase(CgdcBase(C).GetListTable(qList.FieldByName('subtype').AsString));

        q.Close;
        q.SQL.Text :=
          'SELECT rdb$relation_name FROM rdb$relation_fields ' +
          'WHERE rdb$relation_name = :RN AND rdb$field_name = ''EDITIONDATE'' ';
        q.ParamByName('RN').AsString := RN;
        q.ExecQuery;

        if not q.EOF then
        begin
          q.Close;
          q.SQL.Text :=
            'merge into at_object o '#13#10 +
            '  using (select r.xid, r.dbid, d.editiondate '#13#10 +
            '    from ' + RN + ' d join gd_ruid r '#13#10 +
            '    on r.id = d.id '#13#10 +
            '  union all '#13#10 +
            '    select d.id as xid, 17 as dbid, d.editiondate '#13#10 +
            '    from ' + RN + ' d '#13#10 +
            '    where d.id < 147000000) de '#13#10 +
            '  on o.xid=de.xid and o.dbid=de.dbid '#13#10 +
            '    and o.objectclass = :OC and o.subtype IS NOT DISTINCT FROM :ST'#13#10 +
            '    and ((o.curr_modified IS NULL) '#13#10 +
            '      or (o.curr_modified IS DISTINCT FROM de.editiondate))'#13#10 +
            'when matched then '#13#10 +
            '  update set o.curr_modified = de.editiondate';
          q.ParamByName('OC').AsString := qList.FieldByName('objectclass').AsString;
          if qList.FieldByName('subtype').IsNull then
            q.ParamByName('ST').Clear
          else
            q.ParamByName('ST').AsString := qList.FieldByName('subtype').AsString;
          q.ExecQuery;
        end;
      end;

      qList.Next;
    end;

    Tr.Commit;
  finally
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
