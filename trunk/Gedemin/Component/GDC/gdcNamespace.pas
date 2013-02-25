
unit gdcNamespace;

interface

uses
  SysUtils, gdcBase, gdcBaseInterface, Classes, gd_ClassList, gd_createable_form,
  at_classes, IBSQL, db, yaml_writer, yaml_parser, IBDatabase, gd_security, dbgrids, gd_KeyAssoc;

const
  nvNotInstalled = 1;
  nvNewer = 2;
  nvEqual = 3;
  nvOlder = 4;
  nvIndefinite = 5;
  
type
  TgdcNamespace = class(TgdcBase)
  private
    procedure CheckUses(AValue: TyamlSequence; AList: TStringList);
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

    class procedure WriteObject(AgdcObject: TgdcBase; AWriter: TyamlWriter; AnAlwaysoverwrite: Boolean = True;
      ADontremove: Boolean = False; AnIncludesiblings: Boolean = False);
    class procedure LoadObject(AMapping: TyamlMapping; ANamespacekey: Integer; ATr: TIBTransaction);
    class procedure ScanDirectory(ADataSet: TDataSet; const APath: String;
      Messages: TStrings);

    class procedure ScanLinkNamespace(ADataSet: TDataSet; const APath: String); 
    class procedure ScanLinkNamespace2(const APath: String);
    class procedure InstallPackages(SL: TStringList);
    class procedure DeleteObjectsFromNamespace(ANamespacekey: Integer; AnObjectIDList: TgdKeyArray; ATr: TIBTransaction);
    class procedure SetNamespaceForObject(AnObject: TgdcBase; ANSL: TgdKeyStringAssoc; ATr: TIBTransaction = nil);
    class procedure SetObjectLink(AnObject: TgdcBase; ADataSet: TDataSet; ATr: TIBTransaction);
    class procedure AddObject(ANamespacekey: Integer; const AName: String; const AClass: String; const ASubType: String;
      xid, dbid: Integer; ATr: TIBTransaction; AnAlwaysoverwrite: Integer = 1; ADontremove: Integer = 0; AnIncludesiblings: Integer = 0);
    
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

  procedure Register;

implementation

uses
  Windows, Controls, ComCtrls, gdc_dlgNamespacePos_unit, gdc_dlgNamespace_unit, gdc_frmNamespace_unit,
  at_sql_parser, jclStrings, gdcTree, yaml_common, gd_common_functions,
  prp_ScriptComparer_unit, gdc_dlgNamespaceObjectPos_unit, jclUnicode,
  at_frmSyncNamespace_unit, jclFileUtils, gd_directories_const, gd_FileList_unit,
  gdcClasses;

const
  cst_str_WithoutName = 'Без наименования';

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

class procedure TgdcNamespace.WriteObject(AgdcObject: TgdcBase; AWriter: TyamlWriter; AnAlwaysoverwrite: Boolean = True;
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
  AWriter.StartNewLine;
  AWriter.WriteKey('Alwaysoverwrite');
  AWriter.WriteBoolean(AnAlwaysoverwrite);
  AWriter.StartNewLine;
  AWriter.WriteKey('Dontremove');
  AWriter.WriteBoolean(ADontremove);
  AWriter.StartNewLine;
  AWriter.WriteKey('Includesiblings');
  AWriter.WriteBoolean(AnIncludesiblings);
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

procedure TgdcNamespace.CheckUses(AValue: TyamlSequence; AList: TStringList);
var
  q: TIBSQL;
  I, J: Integer;
  RUID, Temps: String;
begin
  Assert(gdcBaseManager <> nil);
  Assert(AList <> nil);
  
  if AValue.Count > 0 then
  begin
    q := TIBSQL.Create(nil);
    try
      q.Transaction := gdcBaseManager.ReadTransaction;
      q.SQL.Text := 'SELECT * FROM at_namespace WHERE settingruid = :sr';

      for I := 0 to AValue.Count - 1 do
      begin
        if not (AValue[I] is TyamlString) then
          raise Exception.Create('Invalid uses value!');

        Temps := (AValue[I] as TyamlString).AsString;
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
          q.Close;
          q.ParamByName('sr').AsString := RUID;
          q.ExecQuery;

          if not q.Eof then
            AList.Add(RUID)
          else
            raise Exception.Create('Uses ''' + (AValue[I] as TyamlString).AsString + ''' not found!');
        end else
          raise Exception.Create('Invalid RUID ''' + RUID + '''');
      end;
    finally
      q.Free;
    end;
  end;
end;

procedure TgdcNamespace.LoadFromFile(const AFileName: String = '');
var
  FN: String;
  Parser: TyamlParser;
  Temps: String;
  I: Integer;
  M: TyamlMapping;
  N: TyamlNode;
  SL: TStringList;
  q: TIBSQL;
  Tr: TIBTransaction;
  Obj: TgdcNamespace;  
begin
  if AFileName = '' then
    FN := QueryLoadFileName(AFileName, 'yml', 'Модули|*.yml')
  else
    FN := AFileName;

  if FN > '' then
  begin
    Tr := TIBTransaction.Create(nil);
    try
      Tr.DefaultDatabase := gdcBaseManager.Database;
      Tr.StartTransaction;

      Parser := TyamlParser.Create;
      SL := TStringList.Create;
      try
        Parser.Parse(FN);

        M := (Parser.YAMLStream[0] as TyamlDocument)[0] as TyamlMapping;
        Temps := M.ReadString('Properties\RUID');
        if not CheckRUID(Temps) then
          raise Exception.Create('Invalid namespace name!');

        Obj := TgdcNamespace.Create(nil);
        try
          Obj.Transaction := Tr;
          Obj.SubSet := 'ByID';
          Obj.ID := gdcBaseManager.GetIDByRUIDString(Temps, Tr);
          Obj.Open;
          if Obj.Eof then
          begin
            gdcBaseManager.DeleteRUIDbyXID(StrToRUID(Temps).XID, StrToRUID(Temps).DBID, Tr);
            Obj.Insert;
          end else
            Obj.Edit;

          Obj.FieldByName('name').AsString := M.ReadString('Properties\Name');
          Obj.FieldByName('caption').AsString := M.ReadString('Properties\Caption');
          Obj.FieldByName('version').AsString := M.ReadString('Properties\Version');
          Obj.FieldByName('dbversion').AsString := M.ReadString('Properties\DBversion');
          Obj.FieldByName('optional').AsInteger := Integer(M.ReadBoolean('Properties\Optional', False));
          Obj.FieldByName('internal').AsInteger := Integer(M.ReadBoolean('Properties\internal', True));

          N := M.FindByName('Uses');
          if N <> nil then
          begin
            if not (N is TyamlSequence) then
              raise Exception.Create('Invalid uses object!');
            CheckUses(N as TyamlSequence, SL);
          end;

          Obj.Post;

          if gdcBaseManager.GetRUIDRecByID(Obj.ID, Tr).XID = -1 then
          begin
            gdcBaseManager.InsertRUID(Obj.ID, StrToRUID(Temps).XID,
              StrToRUID(Temps).DBID,
              Now, IBLogin.ContactKey, Tr);
          end else
          begin
            gdcBaseManager.UpdateRUIDByID(Obj.ID, StrToRUID(Temps).XID,
              StrToRUID(Temps).DBID,
              Now, IBLogin.ContactKey, Tr);
          end;


          q := TIBSQL.Create(nil);
          try
            q.Transaction := Tr;
            q.SQL.Text := 'UPDATE OR INSERT INTO at_namespace_link ' +
              ' (namespacekey, useskey) ' +
              'VALUES (:nk, :uk) '+
              'MATCHING (namespacekey, useskey) ';
            for I := 0 to SL.Count - 1 do
            begin
              q.Close;
              q.ParamByName('nk').AsInteger := Obj.ID;
              q.ParamByName('uk').AsInteger := gdcBaseManager.GetIDByRUIDString(SL[I], Tr);
              q.ExecQuery;
            end;
          finally
            q.Free;
          end;

          N := M.FindByName('Objects');
          if N <> nil then
          begin
            if not (N is TyamlSequence) then
              raise Exception.Create('Invalid objects!');
            with N as TyamlSequence do
            begin
              for I := 0 to Count - 1 do
                LoadObject(Items[I] as TyamlMapping, Obj.ID, Tr);
            end;
          end;
        finally
          Obj.Free;
        end;
      finally
        Parser.Free;
        SL.Free;
      end;

      if Tr.InTransaction then
        Tr.Commit;
    except
      on E: Exception do
      begin
        if Tr.InTransaction then
          Tr.Rollback;
        raise;
      end;
    end;
  end;
end;


class procedure TgdcNamespace.LoadObject(AMapping: TyamlMapping; ANamespacekey: Integer; ATr: TIBTransaction);

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
                  raise Exception.Create('Id not found!');
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

  procedure CheckDataType(F: TField; Value: TyamlNode);
  var
    Flag: Boolean;
  begin
    Flag := False;
    case F.DataType of
      ftDateTime, ftTime: Flag := Value is TyamlDateTime;
      ftDate: Flag := Value is TyamlDate;
      ftInteger, ftLargeint, ftSmallint, ftWord: Flag := Value is TyamlInteger;
      ftFloat, ftCurrency, ftBCD: Flag := Value is TyamlNumeric;
      ftBlob, ftGraphic: Flag := Value is TyamlBinary;
      ftString, ftMemo: Flag := Value is TyamlString;
      ftBoolean: Flag := Value is TyamlBoolean;
    end;
    if not Flag then
      raise Exception.Create('Invalid data type');
  end;

var
  I, K, J: Integer;
  SubType, ClassName: string;
  Obj: TgdcBase;
  RN, Temps: String;
  ID: Integer;
  F: TField;
  L: Integer;
  R: TatRelation;
  RF: TatRelationField;
  N: TyamlNode;
  RUID: String;
  AtObj: TgdcNamespaceObject;
  OV: OleVariant;
  RuidRec: TRuidRec;
  Fields: TyamlMapping;
  AlwaysOverwrite, Flag: Boolean;
begin
  Assert(ATr <> nil);
  Assert(gdcBaseManager <> nil);
  Assert(AMapping <> nil);

  ClassName := AMapping.ReadString('Properties\Class');
  SubType := AMapping.ReadString('Properties\SubType');
  RUID := AMapping.ReadString('Properties\RUID');
  AlwaysOverwrite := AMapping.ReadBoolean('Properties\Alwaysoverwrite');

  if (ClassName = '') or (RUID = '') then
    raise Exception.Create('Invalid object!');

  Fields := AMapping.FindByName('Fields') as TyamlMapping;
  if Fields <> nil then
  begin
    Obj := CgdcBase(GetClass(ClassName)).CreateWithParams(nil, ATr.DefaultDatabase, ATr, SubType);
    try
      RuidRec := gdcBaseManager.GetRUIDRecByXID(StrToRUID(RUID).XID, StrToRUID(RUID).DBID, ATr);
      Obj.Subset := 'ByID';
      Obj.ID := RuidRec.ID;
      Obj.Open;
      if Obj.RecordCount = 0 then
      begin
        gdcBaseManager.DeleteRUIDbyXID(RuidRec.XID, RuidRec.DBID, ATr);
        Obj.Insert;
      end else
      begin
        if AlwaysOverwrite then
          Obj.Edit;
      end;

      if Obj.State in [dsInsert, dsEdit] then
      begin
        for I := 0 to Obj.Fields.Count - 1 do
        begin
          F := Obj.Fields[I];
          N := Fields.FindByName(F.FieldName);
          if N <> nil then
          begin
            if not (N is TyamlScalar) then
              raise Exception.Create('Invalid data!');

            if (F.Origin > '') and not TyamlScalar(N).IsNull then
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
                    Temps := TyamlScalar(N).AsString;
                    RUID := '';
                    for K := 1 to Length(Temps) do
                    begin
                      if Temps[K] in ['0'..'9', '_'] then
                        RUID := RUID + Temps[K]
                      else
                        break;
                    end;

                    if CheckRUID(RUID) then
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

            if TyamlScalar(N).IsNull then
              Obj.FieldByName(F.FieldName).Clear
            else begin
              CheckDataType(F, N);
              case F.DataType of
                ftDateTime, ftTime: Obj.FieldByName(F.FieldName).AsDateTime := TyamlDateTime(N).AsDateTime;
                ftDate: Obj.FieldByName(F.FieldName).AsDateTime := TyamlDate(N).AsDate;
                ftInteger, ftLargeint, ftSmallint, ftWord: Obj.FieldByName(F.FieldName).AsInteger := TyamlScalar(N).AsInteger;
                ftFloat, ftCurrency, ftBCD: Obj.FieldByName(F.FieldName).AsFloat := TyamlScalar(N).AsFloat;
                ftBoolean: Obj.FieldByName(F.FieldName).AsBoolean := TyamlBoolean(N).AsBoolean;
                ftBlob, ftGraphic:
                begin
                  Flag := False;

                  if
                    (ClassName = 'TgdcStorageValue')
                    and
                    (
                      (Fields.ReadString('name') = 'dfm')
                      or
                      CheckRUID(Fields.ReadString('name'))
                    ) then
                  begin
                    TempS := TyamlScalar(N).AsString;
                    if TryObjectTextToBinary(TempS) then
                    begin
                      Obj.FieldByName(F.FieldName).AsString := TempS;
                      Flag := True;
                    end;
                  end else if
                    (ClassName = 'TgdcTemplate')
                    and
                    (Fields.ReadString('templatetype') = 'FR4')
                    and
                    (F.FieldName = 'TEMPLATEDATA') then
                  begin
                    Obj.FieldByName(F.FieldName).AsString := TyamlScalar(N).AsString;
                    Flag := True;
                  end;
                  if not Flag then TBlobField(F).LoadFromStream(TyamlBinary(N).AsStream);
                end;
              else
                Obj.FieldByName(F.FieldName).AsString := Trim(TyamlScalar(N).AsString);
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

        N := AMapping.FindByName('Set');
        if (N <> nil) and (N is TyamlSequence) then
        begin
          with N as TyamlSequence do
          begin
            for J := 0 to Count - 1 do
              LoadSet(Items[J] as TyamlMapping, Obj.ID, ATr);
          end;
        end;  
      end;

      AtObj := TgdcNamespaceObject.CreateWithParams(nil, ATr.DefaultDatabase, ATr);
      try
        gdcBaseManager.ExecSingleQueryResult(
          'SELECT id FROM at_object WHERE namespacekey = :ns and xid = ' + IntToStr(RuidRec.XID) +
          ' and dbid = ' + IntToStr(RuidRec.dbid),
          ANamespacekey,
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

        AtObj.FieldByName('namespacekey').AsInteger := ANamespacekey;
        AtObj.FieldByName('xid').AsInteger := RuidRec.XID;
        AtObj.FieldByName('dbid').AsInteger := RuidRec.DBID;
        AtObj.FieldByName('objectname').AsString := Obj.FieldByName(Obj.GetListField(Obj.SubType)).AsString;
        AtObj.FieldByName('objectclass').AsString := ClassName;
        AtObj.FieldByName('subtype').AsString := SubType;
        AtObj.FieldByName('alwaysoverwrite').AsInteger := Integer(AMapping.ReadBoolean('Properties\Alwaysoverwrite'));
        AtObj.FieldByName('dontremove').AsInteger := Integer(AMapping.ReadBoolean('Properties\Dontremove'));
        AtObj.FieldByName('includesiblings').AsInteger := Integer(AMapping.ReadBoolean('Properties\Includesiblings'));
        AtObj.Post;
      finally
        AtObj.Free;
      end;
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

class function TgdcNamespaceObject.GetDialogFormClassName(const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgNamespacePos';
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
begin
  Assert(St <> nil);

  if State <> dsBrowse then
    raise EgdcException.CreateObj('Not in a browse state', Self);

  W := TyamlWriter.Create(St);
  try
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

    q := TIBSQL.Create(nil);
    try
      q.Transaction := gdcBaseManager.ReadTransaction;
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
    finally
      q.Free;
    end;

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
                WriteObject(InstObj, W, Obj.FieldByName('alwaysoverwrite').AsInteger = 1, Obj.FieldByName('dontremove').AsInteger = 1,
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

class procedure TgdcNamespace.InstallPackages(SL: TStringList);
var
  I: Integer;
  Obj: TgdcNamespace;
begin
  Obj := TgdcNamespace.Create(nil);
  try
    for I := 0 to SL.Count - 1 do
      Obj.LoadFromFile(SL[I]);
  finally
    Obj.Free;
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

  procedure SetLinkToNamespace(const S: String);
  var
    Parser: TyamlParser;
    q: TIBSQL;
    Tr: TIBTransaction;
    M: TyamlMapping;
    N: TyamlNode;
    K, I: Integer;
    Temps, RUID: String;
  begin
    Tr := TIBTransaction.Create(nil);
    q := TIBSQL.Create(nil);
    try
      Tr.DefaultDatabase := gdcBaseManager.Database;
      Tr.StartTransaction;
      q.Transaction := Tr;
      q.SQL.Text := 'UPDATE OR INSERT INTO at_namespace_gtt ' +
      '  (name, caption, filename, filetimestamp, version, dbversion, ' +
      '  optional, internal, comment, settingruid) ' +
      'VALUES (:N, :Cap, :FN, :FT, :V, :DBV, :O, :I, :C, :SR) ' +
      'MATCHING (settingruid) ';


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
          q.ExecQuery;
          q.Close;

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

class procedure TgdcNamespace.DeleteObjectsFromNamespace(ANamespacekey: Integer; AnObjectIDList: TgdKeyArray; ATr: TIBTransaction);
var
  q: TIBSQL;
  I: Integer;
  XID, DBID: TID;
begin
  if (ATr = nil) or (not ATr.InTransaction) then
    raise Exception.Create('Invalid transaction!');

  q := TIBSQL.Create(nil);
  try
    q.Transaction := ATr;
    q.SQL.Text := 'DELETE FROM at_object WHERE xid = :xid and dbid = :dbid and namespacekey = :nk';

    for I := 0 to AnObjectIDList.Count - 1 do
    begin
      q.Close;
      gdcBaseManager.GetRUIDByID(AnObjectIDList[I], XID, DBID, ATr);
      q.ParamByName('xid').AsInteger := XID;
      q.ParamByName('dbid').AsInteger := DBID;
      q.ParamByName('nk').AsInteger := ANamespacekey;
      q.ExecQuery;
    end; 
  finally
    q.Free;
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
      SL.Add(AnObject.GetListTable(Obj.SubType));

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
        (F.AsInteger <> AnObject.ID) then
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
  q: TIBSQL;
begin
  if (ATr = nil) or (not ATr.InTransaction) then
    raise Exception.Create('Invalid transaction!');

  q := TIBSQL.Create(nil);
  try
    q.Transaction := ATr;
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
  finally
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
