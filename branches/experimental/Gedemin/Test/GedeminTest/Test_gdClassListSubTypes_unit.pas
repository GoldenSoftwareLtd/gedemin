unit Test_gdClassListSubTypes_unit;

interface

uses
  TestFrameWork,
  gsTestFrameWork,
  gdcBase,
  classes,
  gd_ClassList;

type
  TgsGdClassListSubTypes = class(TgsDBTestCase)
  protected
    procedure ReadFromDocumentType(ASL: TStringList;
      const AgdClassKind: TgdClassKind; const ASubType: String);
    procedure ReadFromStorage(ACE: TgdClassEntry; ASL: TStringList);
    procedure ReadFromRelation(ASL: TStringList;
      const AgdClassKind: TgdClassKind; const ASubType: String);
    function BuildClassTree(ACE: TgdClassEntry; AData1: Pointer;
      AData2: Pointer): Boolean;
  published
    procedure DoTest;
  end;
implementation

uses
  Sysutils,
  windows,
  gsStorage,
  Storages,
  at_classes,
  gdc_createable_form;

{ TgsGdClassListSubTypes }

procedure TgsGdClassListSubTypes.ReadFromDocumentType(ASL: TStringList;
  const AgdClassKind: TgdClassKind; const ASubType: String);
var
  SL: TStringList;
  I: Integer;
  ClassName: String;
begin
  if AgdClassKind = ctUserDocument then
    ClassName := 'TgdcUserDocumentType'
  else
    if (AgdClassKind = ctInvDocument) or (AgdClassKind = ctInvRemains) then
      ClassName := 'TgdcInvDocumentType'
    else
      if AgdClassKind = ctInvPriceList then
        ClassName := 'TgdcInvPriceListType';

  SL := TStringList.Create;
  try
    FQ.Close;
    if ASubType = '' then
    begin
      FQ.SQL.Text :=
        'SELECT '#13#10 +
        '  dt.name AS caption, '#13#10 +
        '  dt.ruid AS subtype '#13#10 +
        'FROM gd_documenttype dt '#13#10 +
        'LEFT JOIN gd_documenttype dt1 '#13#10 +
        '  ON dt1.id = dt.parent '#13#10 +
        'WHERE '#13#10 +
        '  dt.documenttype = ''D'' '#13#10 +
        '  and dt.classname = ''' + ClassName + ''' '#13#10 +
        '  and dt1.documenttype = ''B'' '
    end
    else
    begin
      FQ.SQL.Text :=
        'SELECT '#13#10 +
        '  dt.name AS caption, '#13#10 +
        '  dt.ruid AS subtype '#13#10 +
        'FROM gd_documenttype dt '#13#10 +
        'LEFT JOIN gd_documenttype dt1 '#13#10 +
        '  ON dt1.id = dt.parent '#13#10 +
        'WHERE '#13#10 +
        '  dt.documenttype = ''D'' '#13#10 +
        '  and dt1.ruid = ''' + ASubType + ''' '#13#10 +
        '  and dt1.documenttype = ''D'' '
    end;

    FQ.ExecQuery;

    while not FQ.EOF do
    begin
      SL.Add(FQ.FieldByName('caption').AsString + '=' + FQ.FieldByName('subtype').AsString);
      FQ.Next;
    end;

    for I := 0 to SL.Count - 1 do
    begin
      ASL.Add(SL[I]);
      ReadFromDocumentType(ASL, AgdClassKind, SL.Values[SL.Names[I]]);
    end;

    if (AgdClassKind = ctInvRemains) and (ASubType = '') then
    begin
      FQ.Close;
      FQ.SQL.Text :=
        'SELECT NAME, RUID FROM INV_BALANCEOPTION ';
      FQ.ExecQuery;

      while not FQ.EOF do
      begin
        ASL.Add(FQ.FieldByName('NAME').AsString + '=' + FQ.FieldByName('RUID').AsString);
        FQ.Next;
      end;
    end;
  finally
    SL.Free;
  end;
end;

procedure TgsGdClassListSubTypes.ReadFromStorage(ACE: TgdClassEntry; ASL: TStringList);

  procedure ReadSubTypes(ASL: TStringList; AClassName: String; ASubType: String; APath: String);
  var
    Path: String;
    SL: TStringList;
    I: Integer;
    F: TgsStorageFolder;
    V: TgsStorageValue;
  begin
    Path := APath + '\' + AClassName + ASubType;

    SL := TStringList.Create;
    try
      F := GlobalStorage.OpenFolder(Path, False, False);
      try
        if F <> nil then
        begin
          for I := 0 to F.ValuesCount - 1 do
          begin
            V := F.Values[I];
            if V is TgsStringValue then
              SL.Add(V.AsString + '=' + V.Name)
            else if V <> nil then
              F.DeleteValue(V.Name);
          end;

          for I := 0 to SL.Count - 1 do
          begin
            ASL.Add(SL[I]);
            ReadSubTypes(ASL, AClassName, SL.Values[ASL.Names[I]], Path);

          end;
        end;
      finally
        GlobalStorage.CloseFolder(F, False);
      end;
    finally
      SL.Free;
    end;
  end;
  
var
  F: TgsStorageFolder;
  V: TgsStorageValue;
  ValueName: String;
  I: Integer;
  SL: TStringList;
begin
  Assert(GlobalStorage <> nil);

  if ACE.Path = '' then
    raise Exception.Create('классу не назначен путь в хранилище');

  if ACE.gdClassKind <> ctStorage then
    raise Exception.Create('это не класс хранилища');

  SL := TStringList.Create;
  try
    F := GlobalStorage.OpenFolder(ACE.Path, False, False);
    try
      if F <> nil then
      begin
        for I := 0 to F.ValuesCount - 1 do
        begin
          V := F.Values[I];
          if V is TgsStringValue then
            SL.Add(V.AsString + '=' + V.Name)
          else if V <> nil then
            F.DeleteValue(ValueName);
        end;

        for I := 0 to SL.Count - 1 do
        begin
          ASL.Add(SL[I]);
          ReadSubTypes(ASL, ACE.TheClass.ClassName, ASL.Values[ASL.Names[I]], ACE.Path);
        end;
      end;
    finally
      GlobalStorage.CloseFolder(F, False);
    end;
  finally
    SL.Free;
  end;
end;

procedure TgsGdClassListSubTypes.ReadFromRelation(ASL: TStringList;
  const AgdClassKind: TgdClassKind; const ASubType: String);
var
  SL: TStringList;
  I: Integer;
begin
  if (not Assigned(atDatabase)) and (not Assigned(atDatabase.Relations)) then
    exit;

  SL := TStringList.Create;
  try
    if ASubType > '' then
    begin
      with atDatabase.Relations do
      for I := 0 to Count - 1 do
      if Items[I].IsUserDefined
        and Assigned(Items[I].PrimaryKey)
        and Assigned(Items[I].PrimaryKey.ConstraintFields)
        and (Items[I].PrimaryKey.ConstraintFields.Count = 1)
        and (AnsiCompareText(Items[I].PrimaryKey.ConstraintFields[0].FieldName, 'INHERITEDKEY') = 0)
        and (AnsiCompareText(Items[I].RelationFields.ByFieldName('INHERITEDKEY').ForeignKey.ReferencesRelation.RelationName,
          ASubType) = 0) then
      begin
        SL.Add(Items[I].LName + '=' + Items[I].RelationName);
      end;
    end
    else
      if AgdClassKind = ctUserDefined then
      begin
        with atDatabase.Relations do
          for I := 0 to Count - 1 do
            if Items[I].IsUserDefined
              and Assigned(Items[I].PrimaryKey)
              and Assigned(Items[I].PrimaryKey.ConstraintFields)
              and (Items[I].PrimaryKey.ConstraintFields.Count = 1)
              and (AnsiCompareText(Items[I].PrimaryKey.ConstraintFields[0].FieldName, 'ID') = 0)
              and not Assigned(Items[I].RelationFields.ByFieldName('PARENT'))
              and not Assigned(Items[I].RelationFields.ByFieldName('INHERITEDKEY'))then
            begin
              SL.Add(Items[I].LName + '=' + Items[I].RelationName);
            end;
      end
      else
        if AgdClassKind = ctUserDefinedTree then
        begin
          with atDatabase.Relations do
            for I := 0 to Count - 1 do
              if Items[I].IsUserDefined
                and Assigned(Items[I].PrimaryKey)
                and Assigned(Items[I].PrimaryKey.ConstraintFields)
                and (Items[I].PrimaryKey.ConstraintFields.Count = 1)
                and (AnsiCompareText(Items[I].PrimaryKey.ConstraintFields[0].FieldName, 'ID') = 0)
                and Assigned(Items[I].RelationFields.ByFieldName('PARENT'))
                and not Assigned(Items[I].RelationFields.ByFieldName('LB'))
                and not Assigned(Items[I].RelationFields.ByFieldName('INHERITEDKEY'))then
              begin
                SL.Add(Items[I].LName + '=' + Items[I].RelationName);
              end;
        end
        else
          if AgdClassKind = ctUserDefinedLBRBTree then
          begin
            with atDatabase.Relations do
              for I := 0 to Count - 1 do
                if Items[I].IsUserDefined
                  and Assigned(Items[I].PrimaryKey)
                  and Assigned(Items[I].PrimaryKey.ConstraintFields)
                  and (Items[I].PrimaryKey.ConstraintFields.Count = 1)
                  and (AnsiCompareText(Items[I].PrimaryKey.ConstraintFields[0].FieldName, 'ID') = 0)
                  and Assigned(Items[I].RelationFields.ByFieldName('PARENT'))
                  and Assigned(Items[I].RelationFields.ByFieldName('LB'))
                  and not Assigned(Items[I].RelationFields.ByFieldName('INHERITEDKEY'))then
                begin
                  SL.Add(Items[I].LName + '=' + Items[I].RelationName);
                end;
          end
          else
            if AgdClassKind = ctDlgUserDefinedTree then
            begin
              with atDatabase.Relations do
                for I := 0 to Count - 1 do
                  if Items[I].IsUserDefined
                    and Assigned(Items[I].PrimaryKey)
                    and Assigned(Items[I].PrimaryKey.ConstraintFields)
                    and (Items[I].PrimaryKey.ConstraintFields.Count = 1)
                    and (AnsiCompareText(Items[I].PrimaryKey.ConstraintFields[0].FieldName, 'ID') = 0)
                    and Assigned(Items[I].RelationFields.ByFieldName('PARENT'))
                    and not Assigned(Items[I].RelationFields.ByFieldName('INHERITEDKEY'))then
                  begin
                    SL.Add(Items[I].LName + '=' + Items[I].RelationName);
                  end;
            end
            else
              raise Exception.Create('Not a relation class.');

    for I := 0 to SL.Count - 1 do
    begin
      ASL.Add(SL[I]);
      ReadFromRelation(ASL, AgdClassKind, SL.Values[SL.Names[I]]);
    end;

  finally
    SL.Free;
  end;
end;

function TgsGdClassListSubTypes.BuildClassTree(ACE: TgdClassEntry; AData1: Pointer;
  AData2: Pointer): Boolean;
var
  SL1, SL2: TStringList;
  I: Integer;
begin
  SL1 := TStringList.Create;
  SL2 := TStringList.Create;
  try
    if (ACE.gdClassKind = ctUserDocument)
      or (ACE.gdClassKind = ctInvDocument)
      or (ACE.gdClassKind = ctInvPriceList)
      or (ACE.gdClassKind = ctInvRemains) then
    begin
      gdClassList.GetSubTypeList(ACE.TheClass, ACE.SubType, SL1, False);
      ReadFromDocumentType(SL2, ACE.gdClassKind, ACE.SubType);
    end
    else
      if (ACE.gdClassKind = ctUserDefined)
        or (ACE.gdClassKind = ctUserDefinedTree)
        or (ACE.gdClassKind = ctUserDefinedLBRBTree)
        or (ACE.gdClassKind = ctDlgUserDefinedTree) then
      begin
        gdClassList.GetSubTypeList(ACE.TheClass, ACE.SubType, SL1, False);
        ReadFromRelation(SL2, ACE.gdClassKind, ACE.SubType);
      end
      else
        if (ACE.gdClassKind = ctStorage)
          and (ACE.TheClass.InheritsFrom(TgdcBase)
          or ACE.TheClass.InheritsFrom(TgdcCreateableForm)) then
        begin
          gdClassList.GetSubTypeList(ACE.TheClass, ACE.SubType, SL1, False);
          ReadFromStorage(ACE, SL2);
        end
        else
          raise Exception.Create('unknown classtype.');

    Check(SL1.Count = SL2.Count, 'количество подтипов не совпадает');

    for I := 0 to SL1.Count - 1 do
      Check(SL2.IndexOf(SL1[I]) >= 0, 'подтип не найден')

  finally
    SL1.Free;
    SL2.Free;
  end;

  Result := True;
end;

procedure TgsGdClassListSubTypes.DoTest;
begin
  gdClassList.Traverse(TgdcBase, '', BuildClassTree, nil, nil, True, False);
end;

initialization
  RegisterTest('DB', TgsGdClassListSubTypes.Suite);

end.
