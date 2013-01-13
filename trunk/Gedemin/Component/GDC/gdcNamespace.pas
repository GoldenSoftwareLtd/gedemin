unit gdcNamespace;

interface

uses
  SysUtils, gdcBase, gdcBaseInterface, Classes, gd_ClassList, gd_createable_form,
  at_classes, IBSQL, db, yaml_writer, yaml_parser, IBDatabase, gd_security, dbgrids;

type
  TgdcNamespace = class(TgdcBase)
  private
    procedure LoadObject(AMapping: TyamlMapping; ATr: TIBTransaction);
    procedure LoadSet(AValue: TyamlMapping; AnID: Integer; ATransaction: TIBTransaction);
    procedure CheckUses(AValue: TyamlSequence; AWriter: TyamlWriter);

  protected
    function GetOrderClause: String; override;
    procedure _DoOnNewRecord; override;

  public
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetSubSetList: String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;

    class procedure WriteObject(AgdcObject: TgdcBase; AWriter: TyamlWriter);
    class procedure ScanDirectory(ADataSet: TDataSet; const APath: String);

    function MakePos: Boolean;
    procedure LoadFromFile(const AFileName: String = ''); override;

    procedure SaveNamespaceToStream(St: TStream);
    procedure SaveNamespaceToFile(const AFileName: String = '');
    procedure CompareWithData(const AFileName: String);
  end;

  TgdcNamespaceObject = class(TgdcBase)
  protected
    function GetOrderClause: String; override;
    procedure GetWhereClauseConditions(S: TStrings); override;

  public
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetSubSetList: String; override;
  end;

  procedure Register;

implementation

uses
  Controls, ComCtrls, gdc_dlgNamespace_unit, gdc_frmNamespace_unit,
  at_sql_parser, jclStrings, gdcTree, yaml_common, gd_common_functions,
  prp_ScriptComparer_unit, gdc_dlgNamespaceObjectPos_unit, at_frmSyncNamespace_unit,
  jclFileUtils;

const
  cst_str_WithoutName = 'Без наименования';

procedure Register;
begin
  RegisterComponents('gdcNamespace', [TgdcNamespace, TgdcNamespaceObject]);
end; 

function AddSpaces(const Name: String): String;
begin
  Result := Name + StringOfChar(' ', 20 - Length(Name));
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

class procedure TgdcNamespace.WriteObject(AgdcObject: TgdcBase; AWriter: TyamlWriter);

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
                ' WHERE ' + F.FieldName + ' = ' + AObj.FieldByName(F.ReferencesField.FieldName).AsString;
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
                AWriter.WriteKey('Table');
                AWriter.WriteText(FD.Relation.RelationName, qSingleQuoted);

                AWriter.StartNewLine;
                AWriter.WriteKey('Items');

                AWriter.IncIndent;
                while not q.Eof do
                begin
                  AWriter.StartNewLine;
                  AWriter.WriteSequenceIndicator;
                  AWriter.WriteString(gdcBaseManager.GetRUIDStringByID(q.Fields[0].AsInteger, AObj.Transaction));
                  q.Next;
                end;
                AWriter.DecIndent;
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
                  ';ENTEREDPARAMS;BREAKPOINTS;EDITORSTATE;TESTRESULT;RDB$PROCEDURE_BLR;RDB$TRIGGER_BLR;RDB$VIEW_BLR;';
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
                AWriter.WriteKey(AddSpaces(F.FieldName));
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
      AWriter.WriteKey(AddSpaces(F.FieldName));
      if not F.IsNull then
      begin
        case F.DataType of
          ftDate: AWriter.WriteDate(F.AsDateTime);
          ftDateTime: AWriter.WriteTimestamp(F.AsDateTime);
          ftMemo: AWriter.WriteText(F.AsString, qPlain, sLiteral);
          ftBlob, ftGraphic:
          begin
            Flag := False;

            if (AgdcObject.ClassName = 'TgdcStorageValue') and (AgdcObject.FieldByName('name').AsString = 'dfm') then
            begin
              TempS := F.AsString;
              if TryObjectBinaryToText(TempS) then
              begin
                AWriter.WriteText(TempS, qPlain, sLiteral);
                Flag := True;
              end;
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
          ftInteger, ftLargeint, ftSmallint, ftWord: AWriter.WriteInteger(F.AsInteger);
          ftBoolean: AWriter.WriteBoolean(F.AsBoolean);
          ftFloat, ftCurrency: AWriter.WriteFloat(F.AsFloat);
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

procedure TgdcNamespace.CheckUses(AValue: TyamlSequence; AWriter: TyamlWriter);
var
  q: TIBSQL;
  I: Integer;
begin
  Assert(gdcBaseManager <> nil);
  Assert(AWriter <> nil);

  
  if AValue.Count > 0 then
  begin
    AWriter.WriteKey('Uses');
    AWriter.IncIndent;

    q := TIBSQL.Create(nil);
    try
      q.Transaction := gdcBaseManager.ReadTransaction;
      q.SQL.Text := 'SELECT * FROM at_namespace WHERE UPPER(Trim(name)) = UPPER(Trim(:n))';

      for I := 0 to AValue.Count - 1 do
      begin
        if not (AValue[I] is TyamlScalar) then
          raise Exception.Create('Invalid uses value!');

        q.Close;
        q.ParamByName('n').AsString := (AValue[I] as TyamlString).AsString;
        q.ExecQuery;

        if q.RecordCount <> 0 then
        begin
          AWriter.StartNewLine;
          AWriter.WriteSequenceIndicator;
          AWriter.WriteString((AValue[I] as TyamlString).AsString);
        end else
          raise Exception.Create('Uses ''' + (AValue[I] as TyamlString).AsString + ''' not found!');

      end;
    finally
      q.Free;
    end;

    AWriter.DecIndent;
    AWriter.StartNewLine;
  end;
end;

procedure TgdcNamespace.LoadFromFile(const AFileName: String = '');
var
  FN: String;
  FS: TFileStream;
  Parser: TyamlParser; 
  SS: TStringStream;
  Temps: String;
  I: Integer;
  DidActivate: Boolean; 
  M: TyamlMapping;
  N: TyamlNode;
  Writer: TyamlWriter;
begin
  if AFileName = '' then
    FN := QueryLoadFileName(AFileName, 'yml', 'Модули|*.yml')
  else
    FN := AFileName;

  if FN > '' then
  begin
    FS := TFileStream.Create(FN,fmOpenRead);
    try
      DidActivate := False;
      try
        DidActivate := not Transaction.InTransaction;
        if DidActivate then
          Transaction.StartTransaction;
        Parser := TyamlParser.Create;
        try
          Parser.Parse(FS);
          M := (Parser.YAMLStream[0] as TyamlDocument)[0] as TyamlMapping;
          Temps := M.ReadString('Name');
          if Temps = '' then
            raise Exception.Create('Invalid namespace name!');

          if Active then Close;
          SubSet := 'ByName';
          ParamByName(GetListField(SubType)).AsString := Temps;
          Open;

          if not Eof then
            Edit
          else
          begin
            Insert;
            FieldByName('name').AsString := Temps;
          end;


          N := M.FindByName('Properties');
          if N <> nil then
          begin
            SS := TStringStream.Create('');
            try
              Writer := TyamlWriter.Create(SS);
              try
                Writer.WriteKey('Properties');
                Writer.IncIndent;

                N := (N as TyamlMapping).FindByName('Version');
                if N <> nil then
                begin
                  Writer.StartNewLine;
                  Writer.WriteKey('Version');
                  Writer.WriteString(FloatToStr((N as TyamlFloat).AsFloat));
                end;
                Writer.DecIndent;
                Writer.StartNewLine;

                N := M.FindByName('Uses');
                if N <> nil then
                begin
                 if not (N is TyamlSequence) then
                   raise Exception.Create('Invalid uses object!');

                 CheckUses(N as TyamlSequence, Writer);
                end;
              finally
                Writer.Free;
              end;
            finally
              SS.Free;
            end;
          end;

          Post;

          N := M.FindByName('Objects');
          if N <> nil then
          begin
            if not (N is TyamlSequence) then
              raise Exception.Create('Invalid objects!');
            with N as TyamlSequence do
            begin
              for I := 0 to Count - 1 do
                LoadObject(Items[I] as TyamlMapping, Transaction)
            end;
          end;
        finally
          Parser.Free;
        end;

        if DidActivate and Transaction.InTransaction then
          Transaction.Commit;
      except
        on E: Exception do
        begin
          if DidActivate and Transaction.InTransaction then
            Transaction.Rollback;
          raise;
        end;
      end;
    finally
      FS.Free;
    end;
  end;
end;

procedure TgdcNamespace.LoadSet(AValue: TyamlMapping; AnID: Integer; ATransaction: TIBTransaction);
var
  RN: String;
  I, J: Integer;
  q, SQL: TIBSQL;
  R: TatRelation;
  Items: TyamlSequence;
  ID: Integer;
begin
  q := TIBSQL.Create(nil);
  SQL := TIBSQL.Create(nil);
  try
    q.Transaction := ATransaction;
    SQL.Transaction := ATransaction;

    RN := '';
    for I := 0 to AValue.Count - 1 do
    begin
      if (AValue[I] as TyamlKeyValue).Key = 'Table' then
      begin
        RN := ((AValue[I] as TyamlKeyValue).Value as TyamlScalar).AsString;
        if RN = '' then
          raise Exception.Create('Table not found!');
        continue;
      end else
      if (AValue[I] as TyamlKeyValue).Key = 'Items' then
      begin
        R := atDatabase.Relations.ByRelationName(RN);
        if Assigned(R) then
        begin
          q.SQl.Text := 'INSERT INTO ' + RN + '(' + R.PrimaryKey.ConstraintFields[0].FieldName +
            ', ' + R.PrimaryKey.ConstraintFields[1].FieldName + ') VALUES(:id1, :id2)';
          SQl.SQL.Text := 'SELECT * FROM ' + RN + ' WHERE ' +
            R.PrimaryKey.ConstraintFields[0].FieldName + ' = :value1 AND ' +
            R.PrimaryKey.ConstraintFields[1].FieldName + ' = :value2 ';


          if not ((AValue[I] as TyamlKeyValue).Value is TyamlSequence) then
            raise Exception.Create('Invalid set object!');

          Items := (AValue[I] as TyamlKeyValue).Value as TyamlSequence;

          for J := 0 to Items.Count - 1 do
          begin
            if not (Items[J] is TyamlScalar) then
              raise Exception.Create('Invalid data!');

            ID := gdcBaseManager.GetIDByRUIDString((Items[J] as TyamlScalar).AsString, ATransaction);
            if ID > 0 then
            begin
              SQL.ParamByName('value1').AsInteger := AnID;
              SQL.ParamByName('value2').AsInteger := ID;
              SQL.ExecQuery;
              if SQL.EOF then
              begin
                q.ParamByName('id1').AsInteger := AnID;
                q.ParambyName('id2').AsInteger := ID;
                q.ExecQuery;
                q.Close;
              end;
              SQL.Close;
            end else
              raise Exception.Create('Id not found!');
          end;
        end else
          raise Exception.Create('Table ''' +  RN + ''' not found in databese!');

        RN := '';
      end;
    end;
  finally
    q.Free;
  end;
end;

procedure TgdcNamespace.LoadObject(AMapping: TyamlMapping; ATr: TIBTransaction);

  procedure CheckDataType(F: TField; Value: TyamlNode);
  var
    Flag: Boolean;
  begin
    Flag := False;
    case F.DataType of
      ftDateTime: Flag := Value is TyamlDateTime;
      ftDate: Flag := Value is TyamlDate;
      ftInteger, ftLargeint, ftSmallint, ftWord: Flag := Value is TyamlInteger;
      ftFloat, ftCurrency: Flag := Value is TyamlNumeric;
      ftBlob, ftGraphic: Flag := Value is TyamlBinary;
    end;
    if not Flag then
      raise Exception.Create('Invalid data type');
  end;

var
  I, K: Integer;
  SubType, ClassName: string;
  Obj: TgdcBase;
  RN, Temps: String;
  ID: Integer;
  F: TField;
  L: Integer;
  R: TatRelation;
  RF: TatRelationField;
  Value: TyamlNode;
  RUID: String;
  AtObj: TgdcNamespaceObject;
  OV: OleVariant;
  RuidRec: TRuidRec;
  Fields: TyamlMapping;
begin
  Assert(ATr <> nil);
  Assert(gdcBaseManager <> nil);
  Assert(AMapping <> nil);

  Value := AMapping.FindByName('Properties');

  if Value <> nil then
  begin
    ClassName := (Value as TyamlMapping).ReadString('Class');
    SubType := (Value as TyamlMapping).ReadString('SubType');
    RUID := (Value as TyamlMapping).ReadString('RUID');
  end else
    raise Exception.Create('Invalid properties');

  if (ClassName = '') or (RUID = '') then
    raise Exception.Create('Invalid object!');

  Fields := AMapping.FindByName('Fields') as TyamlMapping;
  if Fields <> nil then
  begin
    Obj := CgdcBase(GetClass(ClassName)).CreateWithParams(nil, ATr.DefaultDatabase, ATr, SubType);
    try
      RuidRec := gdcBaseManager.GetRUIDRecByXID(StrToRUID(RUID).XID, StrToRUID(RUID).DBID, ATr);
      if RuidRec.ID > 0 then
      begin
        Obj.Subset := 'ByID';
        Obj.ID := RuidRec.ID;
        Obj.Open;
        if Obj.RecordCount = 0 then
        begin
          gdcBaseManager.DeleteRUIDbyXID(RuidRec.XID, RuidRec.DBID, ATr);
          Obj.Insert;
        end else
          Obj.Edit;
      end else
      begin
        Obj.Open;
        Obj.Insert;
      end;

      for I := 0 to Obj.Fields.Count - 1 do
      begin
        F := Obj.Fields[I];
        Value := Fields.FindByName(F.FieldName);
        if Value <> nil then
        begin
          if not (Value is TyamlScalar) then
            raise Exception.Create('Invalid data!');

          if (F.Origin > '') and not TyamlScalar(Value).IsNull then
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
                if Assigned(RF) and Assigned(RF.ForeignKey) then
                begin
                  Temps := TyamlScalar(Value).AsString;
                  RUID := '';
                  for K := 1 to Length(Temps) do
                  begin
                    if not CharIsDigit(Temps[K]) and (Temps[K] <> '_') then
                      break;
                    RUID := RUID + Temps[K];
                  end;

                  if (RUID > '') and (CheckRUID(RUID)) then
                  begin
                    ID := gdcBaseManager.GetIDByRUIDString(RUID, ATr);
                    if ID > 0 then
                    begin
                      Obj.FieldByName(F.FieldName).AsInteger := ID;
                      continue;
                    end else
                      raise Exception.Create('Id not found!');
                  end else
                    raise Exception.Create('Invalid RUID!');
                end;
              end;
            end;
          end;

          if TyamlScalar(Value).IsNull then
            Obj.FieldByName(F.FieldName).Clear
          else begin
            CheckDataType(F, Value);
            case F.DataType of
              ftDateTime: Obj.FieldByName(F.FieldName).AsDateTime := TyamlDateTime(Value).AsDateTime;
              ftDate: Obj.FieldByName(F.FieldName).AsDateTime := TyamlDate(Value).AsDate;
              ftInteger, ftLargeint, ftSmallint, ftWord: Obj.FieldByName(F.FieldName).AsInteger := TyamlScalar(Value).AsInteger;
              ftFloat, ftCurrency: Obj.FieldByName(F.FieldName).AsFloat := TyamlScalar(Value).AsFloat;
              ftBlob, ftGraphic: TBlobField(F).LoadFromStream(TyamlBinary(Value).AsStream);
            else
              Obj.FieldByName(F.FieldName).AsString := Trim(TyamlScalar(Value).AsString);
            end;
          end;
        end;
      end;

      Obj.Post;

      if gdcBaseManager.GetRUIDRecByID(Obj.ID, ATr).XID = -1 then
      begin
        gdcBaseManager.InsertRUID(Obj.ID, RuidRec.XID,
          RuidRec.DBID,
          Now, IBLogin.ContactKey, ATr);
      end else
      begin
        gdcBaseManager.UpdateRUIDByID(Obj.ID, RuidRec.XID,
          RuidRec.DBID,
          Now, IBLogin.ContactKey, ATr);
      end;

      AtObj := TgdcNamespaceObject.CreateWithParams(nil, ATr.DefaultDatabase, ATr);
      try
        gdcBaseManager.ExecSingleQueryResult(
          'SELECT id FROM at_object WHERE namespacekey = :ns and xid = ' + IntToStr(RuidRec.XID) +
          ' and dbid = ' + IntToStr(RuidRec.dbid),
          Self.ID,
          OV,
          ATr);

        if not VarIsEmpty(OV) then
        begin
          AtObj.Subset := 'ByID';
          AtObj.ID := OV[0, 0];
          AtObj.Open;
          AtObj.Edit;
        end else
        begin
          AtObj.Open;
          AtObj.Insert;
        end;

        AtObj.FieldByName('namespacekey').AsInteger := Self.ID;
        AtObj.FieldByName('xid').AsInteger := RuidRec.XID;
        AtObj.FieldByName('dbid').AsInteger := RuidRec.DBID;
        AtObj.FieldByName('objectname').AsString := Obj.FieldByName(Obj.GetListField(Obj.SubType)).AsString;
        AtObj.FieldByName('objectclass').AsString := ClassName;
        AtObj.FieldByName('subtype').AsString := SubType;
        AtObj.Post;
      finally
        AtObj.Free;
      end;

      Value := AMapping.FindByName('Set');
      if (Value <> nil) and (Value is TyamlMapping) then
       LoadSet(Value as TyamlMapping, Obj.ID, ATr);

    finally
      Obj.Free;
    end;
  end else
    raise Exception.Create('Invalid fields!');
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
  Result := inherited GetSubSetList + 'ByNamespace;';
end;

procedure TgdcNamespaceObject.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  if HasSubSet('ByNamespace') then
    S.Add('z.namespacekey = :namespacekey');
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
begin
  if AFileName > '' then
    FN := AFileName
  else
    FN := QuerySaveFileName('', 'yml', 'Файлы YML|*.yml');

  if FN > '' then
  begin
    FS := TFileStream.Create(FN, fmCreate);
    try
      SaveNamespaceToStream(FS);
      Edit;
      try
        FS.Position := 0;
      finally
        Post;
      end;
    finally
      FS.Free;
    end;
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

procedure TgdcNamespace.CompareWithData(const AFileName: String);
var
  ScriptComparer: Tprp_ScriptComparer;
  S1, S2: TStringStream;
  FS: TFileStream;
begin
  FS := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyNone);
  S1 := TStringStream.Create('');
  S2 := TStringStream.Create('');
  ScriptComparer := Tprp_ScriptComparer.Create(nil);
  try
    SaveNamespaceToStream(S1);
    S2.CopyFrom(FS, 0);

    ScriptComparer.Compare(S1.DataString, S2.DataString);
    ScriptComparer.LeftCaption('Текущее состояние в базе данных:');
    ScriptComparer.RightCaption(AFileName);
    ScriptComparer.ShowModal;
  finally
    FS.Free;
    S1.Free;
    S2.Free;
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
begin
  Assert(St <> nil);

  if State <> dsBrowse then
    raise EgdcException.CreateObj('Not in a browse state', Self);

  W := TyamlWriter.Create(St);
  try
    W.WriteKey('StructureVersion');
    W.WriteString('1.0');
    W.StartNewLine;
    W.WriteKey('Name');
    W.WriteString(FieldByName('name').AsString);
    W.StartNewLine;
  finally
    W.Free;
  end;

  W := TyamlWriter.Create(St);
  try
    W.WriteKey('Objects');
    W.IncIndent;

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
                WriteObject(InstObj, W);
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
  end;
end;

class procedure TgdcNamespace.ScanDirectory(ADataSet: TDataSet;
  const APath: String);
var
  SL: TStringList;
  Obj: TgdcNamespace;
  I: Integer;
  S1, S2: String;
begin
  Obj := TgdcNamespace.Create(nil);
  SL := TStringList.Create;
  try
    SL.Sorted := True;
    SL.Duplicates := dupError;

    if AdvBuildFileList(IncludeTrailingBackslash(APath) + '*.yml',
      faAnyFile, SL, amAny,  [flFullNames, flRecursive], '*.*', nil) then
    begin
      I := 0;

      Obj.SubSet := 'OrderByName';
      Obj.Open;

      while (not Obj.EOF) or (I < SL.Count) do
      begin
        ADataSet.Append;

        if not Obj.EOF then
          S1 := Obj.ObjectName
        else
          S1 := '';

        if (I < SL.Count) then
          S2 := ExtractFileName(SL[I])
        else
          S2 := '';

        if AnsiCompareText(S1, S2) > 0 then
        begin
          ADataSet.FieldByName('namespacename').AsString := S1;
          Obj.Next;
        end
        else if AnsiCompareText(S1, S2) < 0 then
        begin
          ADataSet.FieldByName('filenamespacename').AsString := S2;
          Inc(I);
        end else
        begin
          ADataSet.FieldByName('namespacename').AsString := S1;
          ADataSet.FieldByName('filenamespacename').AsString := S2;
          Obj.Next;
          Inc(I);
        end;

        ADataSet.Post;
      end;
    end;
  finally
    SL.Free;
    Obj.Free;
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
  Result := inherited GetSubSetList + 'OrderByName;';
end;

initialization
  RegisterGDCClass(TgdcNamespace);
  RegisterGDCClass(TgdcNamespaceObject);

finalization
  UnRegisterGDCClass(TgdcNamespace);
  UnRegisterGDCClass(TgdcNamespaceObject);
end.
