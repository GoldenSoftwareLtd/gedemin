unit Test_gdClassListSubTypes_unit;

interface

uses
  TestFrameWork,
  gsTestFrameWork,
  gdcBase,
  classes;

type
  TgsGdClassListSubTypes = class(TgsDBTestCase)
  protected
    procedure ReadFromDocumentType(ASL: TStringList);
    procedure ReadFromStorage(ASL: TStringList);
    procedure ReadFromRelation(ASL: TStringList);
    procedure ReadFromGdClassList(ASL: TStringList);
	
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
  gdc_createable_form,
  gd_ClassList;

{ TgsGdClassListSubTypes }

procedure TgsGdClassListSubTypes.ReadFromDocumentType(ASL: TStringList);
var
  LSubType: String;
  LComment: String;
begin
  FQ.SQL.Text :=
    'SELECT '#13#10 +
    '  dt.name AS comment, '#13#10 +
    '  dt.classname AS classname, '#13#10 +
    '  dt.ruid AS subtype, '#13#10 +
    '  dt1.ruid AS parentsubtype '#13#10 +
    'FROM gd_documenttype dt '#13#10 +
    'LEFT JOIN gd_documenttype dt1 '#13#10 +
    '  ON dt1.id = dt.parent '#13#10 +
    '  AND dt1.documenttype = ''D'' '#13#10 +
    'WHERE '#13#10 +
    '  dt.documenttype = ''D'' '#13#10 +
    '  and (dt.classname = ''TgdcInvDocumentType'' '#13#10 +
    '  or dt.classname = ''TgdcUserDocumentType'' '#13#10 +
    '  or dt.classname = ''TgdcInvPriceListType'') '#13#10 +
    'ORDER BY dt.parent';

  FQ.ExecQuery;

  while not FQ.EOF do
  begin
    LSubType := FQ.FieldByName('subtype').AsString;
    LComment := FQ.FieldByName('comment').AsString;

    ASL.Add(LComment + '=' + LSubType);

    FQ.Next;
  end;

  FQ.Close;

  FQ.SQL.Text :=
    'SELECT NAME, RUID FROM INV_BALANCEOPTION ';

  FQ.ExecQuery;

  while not FQ.EOF do
  begin
    LSubType := FQ.FieldByName('RUID').AsString;
    LComment := FQ.FieldByName('NAME').AsString;

    ASL.Add(LComment + '=' + LSubType);
    FQ.Next;
  end;
end;

procedure TgsGdClassListSubTypes.ReadFromStorage(ASL: TStringList);
var
  F: TgsStorageFolder;
  V: TgsStorageValue;
  ValueName: String;
  I, J: Integer;
  SL: TStringList;
begin
  Assert(GlobalStorage <> nil);

  SL := TStringList.Create;
  try
    F := GlobalStorage.OpenFolder('SubTypes', False, False);
    try
      if F <> nil then
      begin
        for I := 0 to F.ValuesCount - 1 do
        begin
          V := F.Values[I];
          if V is TgsStringValue then
            SL.CommaText := V.AsString
          else if V <> nil then
            F.DeleteValue(ValueName);
          for J := 0 to SL.Count - 1 do
          begin
            ASL.Add(SL.Names[I] + '=' + AnsiUpperCase(SL.Values[SL.Names[I]]));
          end;
        end;
      end;
    finally
      GlobalStorage.CloseFolder(F, False);
    end;
  finally
    SL.Free;
  end;
end;

procedure TgsGdClassListSubTypes.ReadFromRelation(ASL: TStringList);
var
  I: Integer;
begin
  Assert(atDatabase.Relations <> nil);
  
  with atDatabase.Relations do
    for I := 0 to Count - 1 do
      if Items[I].IsUserDefined
        and Assigned(Items[I].PrimaryKey)
        and Assigned(Items[I].PrimaryKey.ConstraintFields)
        and (Items[I].PrimaryKey.ConstraintFields.Count = 1)
        and (AnsiCompareText(Items[I].PrimaryKey.ConstraintFields[0].FieldName, 'ID') = 0) then
      begin
        ASL.Add(Items[I].LName + '=' + Items[I].RelationName);
      end;
end;

function BuildClassTree(ACE: TgdClassEntry; AData1: Pointer;
  AData2: Pointer): Boolean;
begin
  if ACE.SubType > '' then
      TStringList(AData1^).Add(ACE.Comment + '=' + ACE.SubType);
  Result := True;
end;

procedure TgsGdClassListSubTypes.ReadFromGdClassList(ASL: TStringList);
begin
  gdClassList.Traverse(TgdcBase, '', BuildClassTree, @ASL, nil, True, False);
  gdClassList.Traverse(TgdcCreateableForm, '', BuildClassTree, @ASL, nil, True, False);
end;

procedure TgsGdClassListSubTypes.DoTest;
var
  SubTypeList: TstringList;
  SubTypeList2: TstringList;
  I: Integer;
begin
  SubTypeList := TstringList.Create;
  SubTypeList2 := TstringList.Create;
  try
    SubTypeList.Sorted := True;
    SubTypeList2.Sorted := True;
    SubTypeList.Duplicates := dupIgnore;
    SubTypeList2.Duplicates := dupIgnore;
    ReadFromDocumentType(SubTypeList);
    ReadFromStorage(SubTypeList);
    ReadFromRelation(SubTypeList);
    ReadFromGdClassList(SubTypeList2);

    Check(SubTypeList.Count = SubTypeList2.Count, 'количество подтипов не совпадает');

    for I := 0 to SubTypeList.Count - 1 do
      Check(SubTypeList2.IndexOf(SubTypeList[i]) > -1, 'подтипы не совпадают');

  finally
    SubTypeList.Free;
    SubTypeList2.Free;
  end;
end;

initialization
  RegisterTest('DB', TgsGdClassListSubTypes.Suite);

end.
