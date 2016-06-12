
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

    class function SkipField(const AFieldName: String): Boolean;
    class procedure WriteObject(AgdcObject: TgdcBase; AWriter: TyamlWriter;
      const AHeadObject: String; const AnAlwaysOverwrite: Boolean;
      const ADontRemove: Boolean; const AnIncludeSiblings: Boolean;
      const AModified: TDateTime; const ASubstituteEditionDate: Boolean;
      AnObjCache: TStringHashMap);

    class procedure UpdateCurrModified(ATr: TIBTRansaction; const ANamespaceKey: Integer = -1);
    class procedure ParseReferenceString(const AStr: String; out ARUID: TRUID; out AName: String);

    function MakePos: Boolean;
    procedure LoadFromFile(const AFileName: String = ''); override;
    procedure SaveNamespaceToStream(St: TStream; out HashString: String;
      const AnAnswer: Integer = 0; const ASubstituteEditionDate: Boolean = False);
    function SaveNamespaceToFile(const AFileName: String = '';
      const AnIncBuildVersion: Boolean = False;
      const ASubstituteEditionDate: Boolean = False): Boolean;
    procedure CompareWithData(const AFileName: String; const A3Way: Boolean);
    procedure DeleteNamespaceWithObjects;
  end;

  TgdcNamespaceObject = class(TgdcBase)
  protected
    function GetOrderClause: String; override;
    procedure GetWhereClauseConditions(S: TStrings); override;
    procedure DoBeforeDelete; override;

  public
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetSubSetList: String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;

    procedure ShowObject;
    procedure ShowNSDialog;
  end;

  function GetReferenceString(AnIDField: TField; AnObjectNameField: TField; ATr: TIBTransaction): String; overload;
  function GetReferenceString(AnIDField: TField; const AnObjectName: String; ATr: TIBTransaction): String; overload;
  function GetReferenceString(AnIDField: TIBXSQLVAR; AnObjectNameField: TIBXSQLVAR; ATr: TIBTransaction): String; overload;
  function ParseReferenceString(const AStr: String; out ARUID: String; out AName: String): Boolean;
  function IncVersion(const V: String; const Divider: Char = '.'): String;

  procedure Register;

implementation

uses
  Windows, Controls, ComCtrls, IBHeader, IBErrorCodes, Graphics, wcrypt2,
  gdc_dlgNamespacePos_unit, gdc_dlgNamespace_unit, gdc_frmNamespace_unit,
  at_sql_parser, jclStrings, gdcTree, yaml_common, gd_common_functions,
  prp_ScriptComparer_unit, gdc_dlgNamespaceObjectPos_unit, jclUnicode,
  at_frmSyncNamespace_unit, jclFileUtils, gd_directories_const,
  gd_FileList_unit, gdcClasses, at_sql_metadata, gdcConstants, at_frmSQLProcess,
  Storages, gdcMetadata, at_sql_setup, gsDesktopManager, at_Classes_body,
  at_dlgCompareNSRecords_unit, gdcNamespaceLoader, gd_GlobalParams_unit,
  gdcClasses_Interface, at_dlgNamespaceDeleteDependencies_unit,
  {$IFDEF WITH_INDY}
  gdccClient_unit, at_Log, gdccConst,
  {$ENDIF}
  at_AddToSetting;

procedure Register;
begin
  RegisterComponents('gdcNamespace', [TgdcNamespace, TgdcNamespaceObject]);
end;

type
  TSortedFields = class(TObjectList)
  private
    function _Compare(F1, F2: TField): Integer;
    function _Find(AField: TField; out Index: Integer): Boolean;

  public
    procedure AddField(AField: TField);
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
  const AModified: TDateTime; const ASubstituteEditionDate: Boolean;
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
                    if SkipField(R.RelationFields[J].FieldName) then
                      continue;
                    F := q.FieldByName(R.RelationFields[J].FieldName);
                    if (F.Data <> nil) and (F.Data^.sqlname = 'ID') then
                      continue;
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
  ObjDerived: Boolean;
  RF: TatRelationField;
  FK: TatForeignKey;
  RelationName, FieldName: String;
  Obj: TgdcBase;
  C: TgdcFullClass;
  BlobStream: TStream;
  TempS: String;
  Flag, MustFreeObj: Boolean;
  Flds: TSortedFields;
begin
  Assert(gdcBaseManager <> nil);
  Assert(atDatabase <> nil);
  Assert(AgdcObject <> nil);
  Assert(not AgdcObject.EOF);

  if AgdcObject is TgdcStoredProc then
    (AgdcObject as TgdcStoredProc).PrepareToSaveToStream(True);

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

  Flds := TSortedFields.Create(False);
  try
    for I := 0 to AgdcObject.Fields.Count - 1 do
    begin
      F := AgdcObject.Fields[I];

      if F.FieldKind <> fkData then
        continue;

      // поля, которые вычисляются прямо в запросе
      if F.Origin = '' then
        continue;

      if SkipField(F.FieldName) then
        continue;

      if ('"INV_CARD"."FROMCARDKEY"' = F.Origin)
        or ('"INV_CARD"."TOCARDKEY"' = F.Origin)
        or (Pos('"."ID"', F.Origin) > 0) then
      begin
        continue;
      end;

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

      {
      if (F.Origin = '"GD_DOCUMENTTYPE"."OPTIONS"') and (AgdcObject is TgdcDocumentType) then
      begin
        if not gdClassList.OldOptions then
          continue;
      end;
      }

      Flds.AddField(F);
    end;

    for I := 0 to Flds.Count - 1 do
    begin
      F := Flds[I] as TField;

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
                ObjDerived := False;

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
                      if (Obj is TgdcMetaBase) and TgdcMetaBase(Obj).IsDerivedObject then
                        ObjDerived := True
                      else if Obj is TgdcTree then
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

                if ObjDerived then
                  AWriter.WriteNullValue(F.FieldName)
                else
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
          ftDateTime, ftTime:
          begin
            if ASubstituteEditionDate and (F.FieldName = 'EDITIONDATE') then
              AWriter.WriteTimeStamp(AModified)
            else
              AWriter.WriteTimeStamp(F.AsDateTime);
          end;
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
    Flds.Free;
    AWriter.DecIndent;

    if AgdcObject is TgdcStoredProc then
      (AgdcObject as TgdcStoredProc).PrepareToSaveToStream(False);
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
          LI.Caption := q.FieldByName('objectpos').AsString + ': ' +
            q.FieldByName('objectname').AsString +
            ' (' +
            q.FieldByName('objectclass').AsString +
            q.FieldByName('subtype').AsString +
            ') ' +
            q.FieldByName('xid').AsString + '_' +
            q.FieldByName('dbid').AsString;
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
      TgdcNamespaceLoader.LoadDelayed(SL, False, False, False, False, True);
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
  const AnIncBuildVersion: Boolean = False;
  const ASubstituteEditionDate: Boolean = False): Boolean;
var
  FN, HashString: String;
  FS: TFileStream;
  SS1251, SSUTF8: TStringStream;
  Tr: TIBTransaction;
  NS: TgdcNamespace;
begin
  Result := False;

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

  if Transaction.InTransaction then
    Tr := Transaction
  else begin
    Tr := TIBTransaction.Create(nil);
    Tr.DefaultDatabase := Self.Database;
    Tr.StartTransaction;
  end;

  NS := TgdcNamespace.Create(nil);
  try
    NS.Transaction := Tr;
    NS.ReadTransaction := Tr;
    NS.SubSet := 'ByID';
    NS.ID := Self.ID;
    NS.Open;

    if NS.EOF then
      raise Exception.Create('Can not open namespace object.');

    if AnIncBuildVersion then
    begin
      NS.Edit;
      NS.FieldByName('Version').AsString := IncVersion(NS.FieldByName('Version').AsString, '.');
      NS.Post;
    end;

    FS := TFileStream.Create(FN, fmCreate);
    try
      SS1251 := TStringStream.Create('');
      try
        NS.SaveNamespaceToStream(SS1251, HashString, 0, ASubstituteEditionDate);
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

    NS.Edit;
    NS.FieldByName('filename').AsString := FN;
    NS.FieldByName('filetimestamp').AsDateTime := gd_common_functions.GetFileLastWrite(FN);
    NS.FieldByName('changed').AsInteger := 0;
    if HashString > '' then
      NS.FieldByName('md5').AsString := HashString;
    NS.Post;

    NS.Close;

    if (Tr <> Transaction) and Tr.InTransaction then
      Tr.Commit;

    Result := True;
  finally
    NS.Free;
    if Tr <> Transaction then
    begin
      if Tr.InTransaction then
        Tr.Rollback;
      Tr.Free;
    end;
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

procedure TgdcNamespace.CompareWithData(const AFileName: String; const A3Way: Boolean);

  procedure SubstFileName(var ACmdLine: String; const AMeta: String; const AFileName: String);
  begin
    if AFileName > '' then
    begin
      if Pos(' ', AFileName) > 0 then
        ACmdLine := StringReplace(ACmdLine, AMeta, '"' + AFileName + '"', [rfIgnoreCase, rfReplaceAll])
      else
        ACmdLine := StringReplace(ACmdLine, AMeta, AFileName, [rfIgnoreCase, rfReplaceAll])
    end else
      ACmdLine := StringReplace(ACmdLine, AMeta, '', [rfIgnoreCase, rfReplaceAll]);
  end;

  procedure CallExternal(const ACmdLine: String);
  var
    StartupInfo: TStartupInfo;
    ProcessInfo: TProcessInformation;
  begin
    FillChar(StartupInfo, SizeOf(TStartupInfo), #0);
    StartupInfo.cb := SizeOf(TStartupInfo);
    if not CreateProcess(nil,
      PChar(ACmdLine),
      nil, nil, False, NORMAL_PRIORITY_CLASS, nil, nil,
      StartupInfo, ProcessInfo) then
    begin
      raise Exception.Create('Ошибка при запуске внешней утилиты сравнения файлов.'#13#10 +
        'Командная строка: ' + ACmdLine + #13#10 +
        SysErrorMessage(GetLastError));
    end;

    WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
  end;

var
  ScriptComparer: Tprp_ScriptComparer;
  FS: TFileStream;
  SS, SS1251, SSUTF8: TStringStream;
  FTemp, FBase, CmdLine, HashString: String;
  TempPath: array[0..1023] of Char;
begin
  if FieldByName('filedata').IsNull or (not A3Way) then
    CmdLine := gd_GlobalParams.GetExternalDiff('DIFF2')
  else
    CmdLine := gd_GlobalParams.GetExternalDiff('DIFF3');

  if CmdLine > '' then
  begin
    if GetTempPath(SizeOf(TempPath), TempPath) = 0 then
    begin
      raise Exception.Create('Ошибка при определении имени временного файла. ' +
        SysErrorMessage(GetLastError));
    end;

    FTemp := ChangeFileExt(IncludeTrailingBackslash(TempPath) + ExtractFileName(AFileName), '.mine.yml');
    FBase := '';

    if Pos('%%', CmdLine) > 0 then
    begin
      if A3Way and (StrIPos('%%ancestor_file', CmdLine) > 0) then
      begin
        if not FieldByName('filedata').IsNull then
        begin
          FBase := ChangeFileExt(IncludeTrailingBackslash(TempPath) + ExtractFileName(AFileName), '.base.yml');
          (FieldByName('filedata') as TBlobField).SaveToFile(FBase);
        end;
      end;

      SubstFileName(CmdLine, '%%ancestor_file', FBase);
      SubstFileName(CmdLine, '%%my_file', FTemp);
      SubstFileName(CmdLine, '%%their_file', AFileName);
      SubstFileName(CmdLine, '%%merged_file', AFileName);
    end else
      CmdLine := CmdLine + ' "' + FTemp + '"' + ' "' + AFileName + '"';

    SaveNamespaceToFile(FTemp, False, FBase > '');
    try
      CallExternal(CmdLine);
    finally
      if FBase > '' then
        SysUtils.DeleteFile(FBase);
      SysUtils.DeleteFile(FTemp);
    end;
  end else
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
      SaveNamespaceToStream(SS, HashString, IDCANCEL);

      if SS.DataString = SS1251.DataString then
        gdcBaseManager.ExecSingleQuery(
          'UPDATE at_namespace SET changed = 0, md5 = :md5 WHERE id = ' +
          IntToStr(ID), HashString);

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
end;

procedure TgdcNamespace.SaveNamespaceToStream(St: TStream; out HashString: String;
  const AnAnswer: Integer = 0; const ASubstituteEditionDate: Boolean = False);
var
  Obj: TgdcNamespaceObject;
  W: TyamlWriter;
  InstObj: TgdcBase;
  InstClass: TPersistentClass;
  q: TIBSQL;
  HeadObject, SWarn: String;
  Deleted: Boolean;
  Answer: Integer;
  ObjCache: TStringHashMap;
  DidActivate: Boolean;
  MS: TMemoryStream;
  hProv: HCRYPTPROV;
  Hash: HCRYPTHASH;
  HashValue: array[0..15] of Byte;
  HashValueSize: DWORD;
  I: Integer;
begin
  Assert(St <> nil);
  Assert(Transaction <> nil);

  if State <> dsBrowse then
    raise EgdcException.CreateObj('Not in a browse state', Self);

  MS := TMemoryStream.Create;
  try
    DidActivate := not Transaction.InTransaction;
    if DidActivate then
      Transaction.StartTransaction;

    Answer := AnAnswer;
    W := TyamlWriter.Create(MS);
    q := TIBSQL.Create(nil);
    try
      q.Transaction := Transaction;

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
                      Obj.FieldByName('modified').AsDateTime,
                      ASubstituteEditionDate,
                      ObjCache);

                    if (InstObj.FindField('editiondate') <> nil)
                      and (not InstObj.FieldByName('editiondate').IsNull)
                      and (Obj.FieldByName('modified').AsDateTime <> InstObj.FieldByName('editiondate').AsDateTime) then
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
                  SWarn :=
                    'В базе данных не найден объект "' + Obj.FieldByName('objectname').AsString + '"'#13#10 +
                    'RUID: XID = ' +  Obj.FieldByName('xid').AsString + ', DBID = ' + Obj.FieldByName('dbid').AsString + #13#10 +
                    'Класс: ' + Obj.FieldByName('objectclass').AsString + Obj.FieldByName('subtype').AsString;
                  {$IFDEF WITH_INDY}
                  gdccClient.AddLogRecord('ns', SWarn, gdcc_lt_Warning);
                  {$ENDIF}
                  if Answer = 0 then
                    Answer := MessageBox(0,
                      PChar(SWarn + #13#10#13#10 + 'Удалить запись об объекте из пространства имен?'),
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

    HashString := '';

    CryptAcquireContext(@hProv, nil, nil, PROV_RSA_FULL, CRYPT_VERIFYCONTEXT);
    try
      CryptCreateHash(hProv, CALG_MD5, 0, 0, @Hash);
      try
        HashValueSize := SizeOf(HashValue);
        if CryptHashData(Hash, MS.Memory, MS.Size, 0) and
          CryptGetHashParam(Hash, HP_HASHVAL, @HashValue, @HashValueSize, 0) then
        begin
          for I := 0 to HashValueSize - 1 do
            HashString := HashString + IntToHex(HashValue[I], 2);
        end;
      finally
        CryptDestroyHash(Hash);
      end;
    finally
      CryptReleaseContext(hProv, 0);
    end;

    W := TyamlWriter.Create(St);
    try
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
      if FieldByName('settingruid').AsString > '' then
        W.WriteStringValue('SettingRUID', FieldByName('settingruid').AsString);
      if FieldByName('dbversion').AsString > '' then
        W.WriteStringValue('DBVersion', FieldByName('dbversion').AsString);
      if FieldByName('comment').AsString > '' then
        W.WriteTextValue('Comment', FieldByName('comment').AsString, qDoubleQuoted);
      if HashString > '' then
        W.WriteStringValue('MD5', HashString);
      W.DecIndent;
      W.StartNewLine;
    finally
      W.Free;
    end;

    St.CopyFrom(MS, 0);
  finally
    MS.Free;
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
  CE: TgdClassEntry;
begin
  Obj := nil;
  try
    ObjID := gdcBaseManager.GetIDByRUID(FieldByName('xid').AsInteger,
      FieldByName('dbid').AsInteger);
    if ObjID <> -1 then
    begin
      CE := gdClassList.Get(TgdBaseEntry, FieldByName('objectclass').AsString,
        FieldByName('subtype').AsString);
      Obj := TgdBaseEntry(CE).gdcClass.CreateWithID(nil, nil, nil,
        ObjID,
        FieldByName('subtype').AsString);
      Obj.Open;
      if not Obj.IsEmpty then
        Obj.EditDialog;
    end;
  finally
    Obj.Free;
  end;
end;

class function TgdcNamespace.SkipField(const AFieldName: String): Boolean;
const
  PassFieldName  =
    ';ID;CREATORKEY;EDITORKEY;ACHAG;AVIEW;AFULL;LB;RB;RESERVED;IBNAME;IBPASSWORD' +
    ';BREAKPOINTS;EDITORSTATE;TESTRESULT;LASTEXTIME;PARENTINDEX' +
    ';RDB$TRIGGER_BLR;RDB$PROCEDURE_BLR;RDB$VIEW_BLR;RDB$SECURITY_CLASS' +
    ';RDB$PROCEDURE_NAME;RDB$PROCEDURE_ID;RDB$PROCEDURE_INPUTS;RDB$PROCEDURE_OUTPUTS' +
    ';RDB$PROCEDURE_OUTPUTS;RDB$PROCEDURE_SOURCE;RDB$OWNER_NAME;RDB$RUNTIME' +
    ';RDB$SYSTEM_FLAG;RDB$INDEX_ID;LASTNUMBER;READCOUNT;RDB$FIELD_POSITION;' +
    ';FROMCARDKEY;TOCARDKEY;PRINTDATE;EXCEPTIONNUMBER;RUNONLOGIN;REMAINS;';
begin
  Result := (StrIPos(AFieldName, PassFieldName) > 0) and
    (StrIPos(';' + AFieldName + ';', PassFieldName) > 0);
end;

{ TSortedFields }

procedure TSortedFields.AddField(AField: TField);
var
  Index: Integer;
begin
  if not _Find(AField, Index) then
    Insert(Index, AField);
end;

function TSortedFields._Compare(F1, F2: TField): Integer;

  function AdjustName(const AName: String; const ABlob: Boolean): String;
  begin
    if AName = 'PARENT' then
      Result := '1'
    else if AName = 'NAME' then
      Result := '2'
    else if AName = 'USR$NAME' then
      Result := '3'
    else if AName = 'CREATIONDATE' then
      Result := '{'
    else if AName = 'EDITIONDATE' then
      Result := '|'
    else if AName = 'DISABLED' then
      Result := '}'
    else if ABlob then
      Result := '~' + AName
    else
      Result := AName;
  end;

begin
  Result := CompareStr(AdjustName(F1.FieldName, F1 is TBlobField),
    AdjustName(F2.FieldName, F2 is TBlobField));
end;

function TSortedFields._Find(AField: TField; out Index: Integer): Boolean;
var
  L, H, C: Integer;
begin
  Result := False;
  L := 0;
  H := Count - 1;
  while L <= H do
  begin
    Index := (L + H) shr 1;
    C := _Compare(Items[Index] as TField, AField);
    if C < 0 then
      L := Index + 1
    else if C > 0 then
      H := Index - 1
    else begin
      Result := True;
      exit;
    end;
  end;
  Index := L;
end;

procedure TgdcNamespaceObject.DoBeforeDelete;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  q: TIBSQL;
  Dlg: Tat_dlgNamespaceDeleteDependencies;
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCNAMESPACEOBJECT', 'DOBEFOREDELETE', KEYDOBEFOREDELETE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCNAMESPACEOBJECT', KEYDOBEFOREDELETE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREDELETE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCNAMESPACEOBJECT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCNAMESPACEOBJECT',
  {M}          'DOBEFOREDELETE', KEYDOBEFOREDELETE, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCNAMESPACEOBJECT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if FDataTransfer then
    exit;

  if (sView in BaseState) and (not (sSubProcess in BaseState)) then
  begin
    q := TIBSQL.Create(nil);
    try
      q.Transaction := ReadTransaction;
      q.SQL.Text :=
        'WITH RECURSIVE '#13#10 +
        '  group_tree AS ( '#13#10 +
        '    SELECT id, headobjectkey, objectname, '#13#10 +
        '      CAST('''' AS VARCHAR(255)) AS indent '#13#10 +
        '    FROM at_object '#13#10 +
        '    WHERE id = :id '#13#10 +
        ' '#13#10 +
        '    UNION ALL '#13#10 +
        ' '#13#10 +
        '    SELECT g.id, g.headobjectkey, g.objectname, '#13#10 +
        '      h.indent || rpad('''', 4) '#13#10 +
        '    FROM at_object g JOIN group_tree h '#13#10 +
        '    ON g.headobjectkey = h.id '#13#10 +
        ') '#13#10 +
        'SELECT '#13#10 +
        '  gt.indent || gt.objectname '#13#10 +
        'FROM '#13#10 +
        '  group_tree gt '#13#10 +
        'WHERE gt.id <> :id';
      q.ParamByName('id').AsInteger := ID;
      q.ExecQuery;

      if not q.EOF then
      begin
        Dlg := Tat_dlgNamespaceDeleteDependencies.Create(ParentForm);
        try
          while not q.EOF do
          begin
            Dlg.mObjects.Lines.Append(q.Fields[0].AsString);
            q.Next;
          end;

          Dlg.Caption := 'Удаление объекта "' + ObjectName + '"';
          if Dlg.ShowModal = mrCancel then
            Abort;

          if Dlg.rbDeleteOne.Checked then
            ExecSingleQuery('UPDATE at_object SET headobjectkey = NULL ' +
              'WHERE headobjectkey = :ID', ID);
        finally
          Dlg.Free;
        end;
      end;
    finally
      q.Free;
    end;
  end;

  inherited;


  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCNAMESPACEOBJECT', 'DOBEFOREDELETE', KEYDOBEFOREDELETE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCNAMESPACEOBJECT', 'DOBEFOREDELETE', KEYDOBEFOREDELETE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcNamespaceObject.ShowNSDialog;
var
  ObjID: Integer;
  Obj: TgdcBase;
  CE: TgdClassEntry;
begin
  Obj := nil;
  try
    ObjID := gdcBaseManager.GetIDByRUID(FieldByName('xid').AsInteger,
      FieldByName('dbid').AsInteger);
    if ObjID <> -1 then
    begin
      CE := gdClassList.Get(TgdBaseEntry, FieldByName('objectclass').AsString,
        FieldByName('subtype').AsString);
      Obj := TgdBaseEntry(CE).gdcClass.CreateWithID(nil, nil, nil,
        ObjID,
        FieldByName('subtype').AsString);
      Obj.Open;
      if not Obj.IsEmpty then
        AddToSetting(False, '', '', Obj, nil);
    end;
  finally
    Obj.Free;
  end;
end;

initialization
  RegisterGDCClass(TgdcNamespace);
  RegisterGDCClass(TgdcNamespaceObject);

finalization
  UnregisterGdcClass(TgdcNamespace);
  UnregisterGdcClass(TgdcNamespaceObject);
end.
