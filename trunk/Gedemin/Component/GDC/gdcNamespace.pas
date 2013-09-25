
unit gdcNamespace;

interface

uses
  SysUtils, gdcBase, gdcBaseInterface, Classes, gd_ClassList, JclStrHashMap,
  gd_createable_form, at_classes, IBSQL, db, yaml_writer, yaml_parser,
  IBDatabase, gd_security, dbgrids, gd_KeyAssoc, contnrs, IB;

type
  TnsOverwrite = (ovOverwriteIfNewer, ovAlwaysOverwrite);
  TnsRemove = (rmRemove, rmDontRemove);
  TnsIncludeSiblings = (isDontInclude, isInclude);

  TgdcNamespace = class(TgdcBase)
  private
    procedure CheckIncludesiblings;

  protected
    function GetOrderClause: String; override;
    procedure GetWhereClauseConditions(S: TStrings); override;

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

    class procedure UpdateCurrModified(ATr: TIBTRansaction; const ANamespaceKey: Integer = -1);
    class procedure ParseReferenceString(const AStr: String; out ARUID: TRUID; out AName: String);

    function MakePos: Boolean;
    procedure LoadFromFile(const AFileName: String = ''); override;
    procedure SaveNamespaceToStream(St: TStream; const AnAnswer: Integer = 0);
    function SaveNamespaceToFile(const AFileName: String = '';
      const AnIncBuildVersion: Boolean = False): Boolean;
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
  Windows, Controls, ComCtrls, IBHeader, IBErrorCodes, Graphics,
  gdc_dlgNamespacePos_unit, gdc_dlgNamespace_unit, gdc_frmNamespace_unit,
  at_sql_parser, jclStrings, gdcTree, yaml_common, gd_common_functions,
  prp_ScriptComparer_unit, gdc_dlgNamespaceObjectPos_unit, jclUnicode,
  at_frmSyncNamespace_unit, jclFileUtils, gd_directories_const,
  gd_FileList_unit, gdcClasses, at_sql_metadata, gdcConstants, at_frmSQLProcess,
  Storages, gdcMetadata, at_sql_setup, gsDesktopManager, at_Classes_body,
  at_dlgCompareNSRecords_unit, gdcNamespaceLoader;

type
  TgdcReferenceUpdate = class(TObject)
  public
    FieldName: String;
    FullClass: TgdcFullClass;
    ID: TID;
    RefRUID: String;
    SQL: String;
  end;

  TgdcAt_Object = class(TObject)
  public
    ID: Integer;
    RUID: String;
    ObjectName: String;
    NamespaceKey: Integer; 
    ObjectClass: String;
    SubType: String;
    Modified: TDateTime;
    Curr_modified: TDateTime;
    FileTimestamp: TDateTime;
    HeadObjectKey: Integer;
  end;

procedure Register;
begin
  RegisterComponents('gdcNamespace', [TgdcNamespace, TgdcNamespaceObject]);
end;

function GetReferenceString(AnIDField: TField; AnObjectNameField: TField; ATr: TIBTransaction): String; overload;
begin
  Result := GetReferenceString(AnIDField, AnObjectNameField.AsString, ATr);
end;

function GetReferenceString(AnIDField: TField; const AnObjectName: String; ATr: TIBTransaction): String; overload
begin
  if AnIDField.IsNull then
    Result := '~'
  else begin
    Result := gdcBaseManager.GetRUIDStringByID(AnIDField.AsInteger, ATr);
    if AnObjectName > '' then
      Result := Result + ' ' + AnObjectName;
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

const
  PassFieldName =
    ';ID;CREATORKEY;EDITORKEY;ACHAG;AVIEW;AFULL;LB;RB;RESERVED' +
    ';BREAKPOINTS;EDITORSTATE;TESTRESULT;LASTEXTIME;PARENTINDEX' +
    ';RDB$TRIGGER_BLR;RDB$PROCEDURE_BLR;RDB$VIEW_BLR;RDB$SECURITY_CLASS;';

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
                    if Pos(';' + R.RelationFields[J].FieldName + ';', PassFieldName) > 0 then
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

      if F.FieldKind <> fkData then
        continue;

      if StrIPos(';' + F.FieldName + ';', PassFieldName) > 0 then
        continue;

      if AgdcObject is TgdcMetaBase then
      begin
        if Pos('RDB$', AgdcObject.ObjectName) = 1 then
          continue;

        if (F.FieldName = 'FIELDSOURCE') and (Pos('RDB$', F.AsString) = 1) then
          continue;

        if (F.FieldName = 'FIELDSOURCEKEY') and (AgdcObject.FindField('FIELDSOURCE') <> nil)
          and (Pos('RDB$', AgdcObject.FieldByName('FIELDSOURCE').AsString) = 1) then
            continue;
      end;

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

                ObjName := '';

                C := GetBaseClassForRelation(RF.References.RelationName);
                if C.gdClass <> nil then
                begin
                  Obj := nil;
                  MustFreeObj := False;

                  if (AnObjCache = nil) or (not AnObjCache.Find(C.gdClass.ClassName + C.SubType, Obj))
                    or (Obj = nil) or Obj.Active then
                  begin
                    Obj := C.gdClass.Create(nil);
                    Obj.SubType := C.SubType;
                    Obj.ReadTransaction := AgdcObject.ReadTransaction;
                    Obj.Transaction := AgdcObject.Transaction;
                    Obj.SubSet := 'ByID';

                    if (AnObjCache = nil) or AnObjCache.Has(C.gdClass.ClassName + C.SubType) then
                      MustFreeObj := True
                    else
                      AnObjCache.Add(C.gdClass.ClassName + C.SubType, Obj);
                  end;

                  try
                    Obj.ID := F.AsInteger;
                    Obj.Open;
                    if not Obj.EOF then
                    begin
                      if Obj is TgdcTree then
                        ObjName := TgdcTree(Obj).GetPath
                      else
                        ObjName := Obj.ObjectName;
                    end;
                  finally
                    if MustFreeObj then
                      Obj.Free
                    else
                      Obj.Close;
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

class procedure TgdcNamespace.UpdateCurrModified(ATr: TIBTRansaction;
  const ANamespaceKey: Integer = -1);
var
  Tr: TIBTransaction;
  qList, q: TIBSQL;
  C: TPersistentClass;
  RN: String;
begin
  Assert(gdcBaseManager <> nil);


  if ATr = nil then
    Tr := TIBTransaction.Create(nil)
  else
    Tr := ATr;

  qList := TIBSQL.Create(nil);
  q := TIBSQL.Create(nil);
  try
    if ATr = nil then
    begin
      Tr.DefaultDatabase := gdcBaseManager.Database;
      Tr.StartTransaction;
    end;

    q.Transaction := Tr;

    qList.Transaction := Tr;
    qList.SQL.Text :=
      'SELECT DISTINCT o.objectclass, o.subtype ' +
      'FROM at_object o ';
    if ANamespaceKey > -1 then
    begin
      qList.SQL.Text := qList.SQL.Text + 'WHERE o.namespacekey = :nk';
      qList.ParamByName('nk').AsInteger := ANamespaceKey;
    end;
    qList.ExecQuery;

    while not qList.EOF do
    begin
      C := GetClass(qList.FieldByName('objectclass').AsString);
      if (C <> nil) and C.InheritsFrom(TgdcBase)
        and (tiEditionDate in CgdcBase(C).GetTableInfos(qList.FieldByName('subtype').AsString)) then
      begin
        RN := UpperCase(CgdcBase(C).GetListTable(qList.FieldByName('subtype').AsString));
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

      qList.Next;
    end;

    q.SQL.Text := 'DELETE FROM at_object WHERE xid >= 147000000 ';
    if ANamespaceKey > -1 then
      q.SQL.Text := q.SQL.Text + 'AND namespacekey = :nk ';
    q.SQL.Text := q.SQL.Text +
      'AND id IN ( ' +
      '  SELECT o.id FROM at_object o ' +
      '    LEFT JOIN gd_ruid r ON r.xid = o.xid AND r.dbid = o.dbid ' +
      '  WHERE r.xid IS NULL AND o.xid >= 147000000 ';
    if ANamespaceKey > -1 then
    begin
      q.SQL.Text := q.SQL.Text + 'AND o.namespacekey = :nk)';
      q.ParamByName('nk').AsInteger := ANamespaceKey;
    end else
      q.SQL.Text := q.SQL.Text + ')';
    q.ExecQuery;
  finally
    q.Free;
    qList.Free;

    if ATr = nil then
    begin
      if Tr.InTransaction then
        Tr.Commit;
      Tr.Free;
    end;
  end;
end;

class procedure TgdcNamespace.ParseReferenceString(const AStr: String;
  out ARUID: TRUID; out AName: String);
var
  P: Integer;
begin
  P := Pos(' ', AStr);
  if P = 0 then
  begin
    ARUID := StrToRUID(AStr);
    AName := '';
  end else
  begin
    ARUID := StrToRUID(System.Copy(AStr, 1, P - 1));
    AName := System.Copy(AStr, P + 1, MaxInt);
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
      TgdcNamespaceLoader.LoadDelayed(SL, False, False);
    finally
      SL.Free;
    end;
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

function TgdcNamespace.SaveNamespaceToFile(const AFileName: String = '';
  const AnIncBuildVersion: Boolean = False): Boolean;
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
  begin
    Result := False;
    exit;
  end;

  DidActivate := not Transaction.InTransaction;
  if DidActivate then
    Transaction.StartTransaction;
  try
    if AnIncBuildVersion then
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
    Result := True;
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
            try
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
            finally
              InstObj.Close;
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
