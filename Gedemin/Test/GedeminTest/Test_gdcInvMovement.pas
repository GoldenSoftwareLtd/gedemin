unit Test_gdcInvMovement;

interface

uses
  TestFrameWork, gsTestFrameWork, IBDatabase, gdcBase, classes;

type
  TgsInvMovementDocuments = class(TgsDBTestCase)
  protected 
    FCompanyID1, FCompanyID2, FGoodId1, FGoodId2: Integer;
    FDeptID1, FDeptID2: Integer;
    FCurrRemainsDept1, FCurrRemainsDept2: Integer;
    FDocID: TStringList;

    procedure SetUp; override;
    procedure TearDown; override;

    procedure CreateCompany;
    procedure CreateGoods;
    procedure CreateDepartments;

    procedure CreateWayBill(ACompanyID: Integer; ADeptID: Integer; AGoodID: Integer; out ARemains: Integer);
    procedure CreateDocReturn(ACompanyID: Integer; ADeptID: Integer; AGoodID: Integer; out ARemains: Integer);
    procedure CreateDocDebitItems(ACompanyID: Integer; ADeptID: Integer; AGoodID: Integer; out ARemains: Integer);
    procedure DeleteDoc(const ASubType: String);
    procedure DeleteDocLine(const ASubType: String);
    procedure Merge;
    procedure Delete;
  published
    procedure DoTest;
  end;

implementation

uses
  gdcInvDocument_unit, gdcContacts, gdcGood, gdcInvMovement, Db,
  gdcBaseInterface, Forms, Sysutils, windows, gsDBReduction;

const
  ItemsGood = 30;
  Delta = 10;

procedure TgsInvMovementDocuments.SetUp;
begin
  inherited;

  FDocID := TStringList.Create;
  FCurrRemainsDept1 := 0;
  FCurrRemainsDept2 := 0;
end;

procedure TgsInvMovementDocuments.TearDown;
begin
  FreeAndNil(FDocID);
  inherited;
end;


procedure TgsInvMovementDocuments.CreateDocReturn(ACompanyID: Integer; ADeptID: Integer; AGoodID: Integer; out ARemains: Integer);
var
  Obj: TgdcInvDocument;
  Obj2: TgdcInvDocumentLine;
  dsMain: TDataSource;
  Remains: TgdcInvGoodRemains;
  I: Integer;
begin
  FQ.Close;
  FQ.SQL.Text := 'SELECT * FROM gd_documenttype WHERE ruid = ''147013038_109092844''';
  FQ.ExecQuery;

  Check(not FQ.Eof);

  Obj := TgdcInvDocument.Create(nil);
  try
    Obj.SubType := '147013038_109092844';
    Obj.Open;
    Obj.Insert;
    Obj.FieldbyName('usr$contactkey').AsInteger := ACompanyID;
    Obj.FieldByName('usr$maindepotkey').AsInteger := ADeptID;
    Obj.Post;
    FDocID.Add('147013038_109092844=' + IntToStr(Obj.ID));

    dsMain := TDataSource.Create(nil);
    Obj2 :=  TgdcInvDocumentLine.Create(nil);
    try
      dsMain.Dataset := Obj;
      Obj2.SubSet := 'ByParent';
      Obj2.MasterField := 'id';
      Obj2.DetailField := 'parent';
      Obj2.MasterSource := dsMain;
      Obj2.SubType := '147013038_109092844';
      Obj2.Open;

      Remains := TgdcInvGoodRemains.Create(nil);
      try
        Remains.gdcDocumentLine := Obj2;
        Remains.Close;
        Remains.GoodKey := AGoodID;
        Remains.Open;
        Remains.SetDepartmentKeys([ADeptID]);
        
        Check(Remains.FieldByname('remains').AsInteger = ARemains, '1');
        Obj2.Insert;
        Obj2.FieldByName('parent').AsInteger := Obj.ID;
        Obj2.FieldbyName('goodkey').AsInteger := AGoodID;
        for  I := 0 to Remains.ViewFeatures.Count - 1 do
          Obj2.FieldByName('FROM_' + Remains.ViewFeatures[I]).AsVariant :=
            Remains.FieldByName(Remains.ViewFeatures[I]).AsVariant;
        Obj2.FieldByName('quantity').AsInteger := Delta;
        Obj2.Post;
        FDocID.Add('147013038_109092844p=' + IntToStr(Obj2.ID));
        ARemains := ARemains - Delta;
        Remains.CloseOpen;

        Check(Remains.FieldByname('remains').AsInteger = ARemains, '2');
      finally
        Remains.Free;
      end;
    finally
      Obj2.Free;
      dsMain.Free;
    end;
  finally
    Obj.Free;
  end;
end;

procedure TgsInvMovementDocuments.CreateWayBill(ACompanyID: Integer; ADeptID: Integer; AGoodID: Integer; out ARemains: Integer);
var
  Obj: TgdcInvDocument;
  Obj2: TgdcInvDocumentLine;
  dsMain: TDataSource;
begin
  FQ.Close;
  FQ.SQL.Text := 'SELECT * FROM gd_documenttype WHERE ruid = ''147010993_109092844''';
  FQ.ExecQuery;

  Check(not FQ.Eof);
  Obj := TgdcInvDocument.Create(nil);
  try
    Obj.SubType := '147010993_109092844';
    Obj.Open;
    Obj.Insert;
    Obj.FieldbyName('usr$contactkey').AsInteger := ACompanyID;
    Obj.FieldByName('usr$deptkey').AsInteger := ADeptID;
    Obj.Post;
    FDocID.Add('147010993_109092844=' + IntToStr(Obj.ID));

    dsMain := TDataSource.Create(nil);
    Obj2 :=  TgdcInvDocumentLine.Create(nil);
    try
      dsMain.Dataset := Obj;
      Obj2.SubSet := 'ByParent';
      Obj2.MasterField := 'id';
      Obj2.DetailField := 'parent';
      Obj2.MasterSource := dsMain;
      Obj2.SubType := '147010993_109092844';
      Obj2.Open;
      Obj2.Insert;
      Obj2.FieldByName('parent').AsInteger := Obj.ID;
      Obj2.FieldbyName('goodkey').AsInteger := AGoodID;
      Obj2.FieldbyName('to_usr$inv_costbuyncu').AsInteger := 15000;

      Obj2.FieldByName('quantity').AsInteger := ItemsGood;
      Obj2.UpdateGoodNames;
      Obj2.Post;
      FDocID.Add('147010993_109092844p=' + IntToStr(Obj2.ID));
      ARemains := ARemains + ItemsGood;

      FQ2.Close;
      FQ2.SQL.Text := 'SELECT id FROM inv_card WHERE goodkey = :g AND documentkey = :d';
      FQ2.ParamByName('g').AsInteger := AGoodID;
      FQ2.ParamByName('d').AsInteger := Obj2.ID;
      FQ2.ExecQuery;
      Check(not FQ2.EOF, 'Отсутствует запись в таблице inv_card');

      FQ.Close;
      FQ.SQL.Text := 'SELECT balance FROM inv_balance WHERE cardkey = :c ' +
        'AND contactkey = :con AND goodkey = :g';
      FQ.ParamByName('c').AsInteger := FQ2.FieldByName('id').AsInteger;
      FQ.ParamByName('con').AsInteger := ADeptID;
      FQ.ParamByName('g').AsInteger := AGoodID;
      FQ.ExecQuery;

      Check(not FQ.EOF);
      Check(FQ.FieldByName('balance').AsInteger = ARemains);

    finally
      Obj2.Free;
      dsMain.Free;
    end;
  finally
    Obj.Free;
  end;
end;

procedure TgsInvMovementDocuments.CreateDocDebitItems(ACompanyID: Integer; ADeptID: Integer; AGoodID: Integer; out ARemains: Integer);
var
  Obj: TgdcInvDocument;
  Obj2: TgdcInvDocumentLine;
  dsMain: TDataSource;
  Remains: TgdcInvGoodRemains;
  I: Integer;
begin
  FQ.Close;
  FQ.SQL.Text := 'SELECT * FROM gd_documenttype WHERE ruid = ''147013043_109092844''';
  FQ.ExecQuery;

  Check(not FQ.Eof);

  Obj := TgdcInvDocument.Create(nil);
  try
    Obj.SubType := '147013043_109092844';
    Obj.Open;
    Obj.Insert;
    Obj.FieldbyName('usr$contactkey').AsInteger := ACompanyID;
    Obj.FieldByName('usr$deptkey').AsInteger := ADeptID;
    Obj.Post;
    FDocID.Add('147013043_109092844=' + IntToStr(Obj.ID));

    dsMain := TDataSource.Create(nil);
    Obj2 := TgdcInvDocumentLine.Create(nil);
    try
      dsMain.Dataset := Obj;
      Obj2.SubSet := 'ByParent';
      Obj2.MasterField := 'id';
      Obj2.DetailField := 'parent';
      Obj2.MasterSource := dsMain;
      Obj2.SubType := '147013043_109092844';
      Obj2.Open;

      Remains := TgdcInvGoodRemains.Create(nil);
      try
        Remains.gdcDocumentLine := Obj2;
        Remains.Close;
        Remains.GoodKey := AGoodID;
        Remains.SetDepartmentKeys([ADeptID]);
        Remains.Open;

        Check(Remains.FieldByname('remains').AsInteger = ARemains);
        Obj2.Insert;
        Obj2.FieldByName('parent').AsInteger := Obj.ID;
        Obj2.FieldbyName('goodkey').AsInteger := AGoodID;
        for  I := 0 to Remains.ViewFeatures.Count - 1 do
          Obj2.FieldByName('FROM_' + Remains.ViewFeatures[I]).AsVariant :=
            Remains.FieldByName(Remains.ViewFeatures[I]).AsVariant;
        Obj2.FieldByName('quantity').AsInteger := Delta;
        Obj2.Post;
        FDocID.Add('147013043_109092844p=' + IntToStr(Obj2.ID));
        ARemains := ARemains - Delta;
        Remains.CloseOpen;

        Check(Remains.FieldByname('remains').AsInteger = ARemains);
      finally
        Remains.Free;
      end;
    finally
      Obj2.Free;
      dsMain.Free;
    end;
  finally
    Obj.Free;
  end;
end;

procedure TgsInvMovementDocuments.Merge;
var
  Company: TgdcCompany;
begin
  Company := TgdcCompany.Create(nil);
  try
    Company.Open;
    Check(Company.InternalReduction(FCompanyID1, FCompanyID2));
  finally
    Company.Free;
  end;

  FQ.Close;
  FQ.SQL.Text := 'SELECT SUM(CREDIT) as S FROM inv_movement ' +
    'WHERE goodkey = :gk AND contactkey = :ck';
  FQ.ParamByName('gk').AsInteger := FGoodID1;
  FQ.ParamByName('ck').AsInteger := FCompanyID2;
  FQ.ExecQuery;
  Check(FQ.FieldByName('S').AsInteger = 2 * ItemsGood);

  FQ.Close;
  FQ.SQL.Text := 'SELECT SUM(DEBIT) as S FROM inv_movement ' +
    'WHERE goodkey = :gk AND contactkey = :ck';
  FQ.ParamByName('gk').AsInteger := FGoodID1;
  FQ.ParamByName('ck').AsInteger := FCompanyID2;
  FQ.ExecQuery;
  Check(FQ.FieldByName('S').AsInteger = 2 * ItemsGood - FCurrRemainsDept1 - FCurrRemainsDept2);
end;

procedure TgsInvMovementDocuments.DoTest;
begin
  CreateDepartments;
  CreateCompany;
  CreateGoods;

  CreateWayBill(FCompanyID1, FDeptID1, FGoodID1, FCurrRemainsDept1);
  CreateDocReturn(FCompanyID1, FDeptID1, FGoodID1, FCurrRemainsDept1);
  CreateDocDebitItems(FCompanyID1, FDeptID1, FGoodID1, FCurrRemainsDept1);

  CreateWayBill(FCompanyID2, FDeptID2, FGoodID1, FCurrRemainsDept2);
  CreateDocReturn(FCompanyID2, FDeptID2, FGoodID1, FCurrRemainsDept2);
  CreateDocDebitItems(FCompanyID2, FDeptID2, FGoodID1, FCurrRemainsDept2);
  Merge;

  Delete;
end;

procedure TgsInvMovementDocuments.CreateCompany;
var
  Company: TgdcCompany;
  R: OleVariant;
begin
  gdcBaseManager.ExecSingleQueryResult('SELECT id FROM gd_contact where contacttype = 0 and UPPER(name) = UPPER(:name)',
    'ОРГАНИЗАЦИИ', R, FTr);

  Company := TgdcCompany.Create(nil);
  try
    Company.Open;
    Company.Insert;
    Company.FieldByName('Name').AsString := 'Test_Компания1';
    Company.FieldByName('Parent').AsInteger := R[0, 0];
    Company.Post;
    FCompanyId1 := Company.ID;

    Company.Insert;
    Company.FieldByName('Name').AsString := 'Test_Компания2';
    Company.FieldByName('Parent').AsInteger := R[0, 0];
    Company.Post;
    FCompanyId2 := Company.ID;
  finally
    Company.Free;
  end;
end;

procedure TgsInvMovementDocuments.CreateGoods;
var
  Good: TgdcGood;
  R: OleVariant;
begin
  gdcBaseManager.ExecSingleQueryResult('SELECT id FROM gd_goodgroup where UPPER(name) = UPPER(:name)',
    'ВСЕ ТМЦ', R, FTr);

  Good := TgdcGood.Create(nil);
  try
    Good.Open;
    Good.Insert;
    Good.FieldByName('Name').AsString := 'Test_Товар1';
    Good.FieldByname('ValueKey').AsInteger := 3000001;
    Good.FieldByname('GROUPKEY').AsInteger := R[0, 0];
    Good.Post;
    FGoodId1 := Good.ID;

    Good.Insert;
    Good.FieldByName('Name').AsString := 'Test_Товар2';
    Good.FieldByname('ValueKey').AsInteger := 3000001;
    Good.FieldByname('GROUPKEY').AsInteger := R[0, 0];
    Good.Post;
    FGoodId2 := Good.ID;
  finally
    Good.Free;
  end;
end;

procedure TgsInvMovementDocuments.CreateDepartments;
var
  Dept: TgdcDepartment;
  R: OleVariant;
begin
  gdcBaseManager.ExecSingleQueryResult(
    'SELECT id FROM gd_contact where contacttype = 4 and UPPER(name) = UPPER(:name)',
    'ВСЕ ПОДРАЗДЕЛЕНИЯ', R, FTr); 

  Dept := TgdcDepartment.Create(nil);
  try
    Dept.Open;
    Dept.Insert;
    Dept.FieldByName('name').AsString := 'Test_склад1';
    Dept.FieldByName('parent').AsInteger := R[0, 0];
    Dept.Post;
    FDeptID1 := Dept.ID;

    Dept.Insert;
    Dept.FieldByName('name').AsString := 'Test_склад2';
    Dept.FieldByName('parent').AsInteger := R[0, 0];
    Dept.Post;
    FDeptID2 := Dept.ID;
  finally
    Dept.Free;
  end;
end;

procedure TgsInvMovementDocuments.DeleteDoc(const ASubType: String);
var
  Obj: TgdcInvDocument;
  I: Integer;
begin
  I := FDocID.IndexOfName(ASubType);
  if I <> - 1 then
  begin
    Obj := TgdcInvDocument.Create(nil);
    try
      Obj.SubType := ASubType;
      Obj.SubSet := 'ByID';
    while I <> -1 do
    begin
      Obj.Close;
      Obj.ParamByName('id').AsString := FDocID.Values[FDocID.Names[I]];
      Obj.Open;
      Obj.Delete;

      FDocID.Delete(I);
      I := FDocID.IndexOfName(ASubType);
    end;
    finally
      Obj.Free;
    end;
  end;
end;

procedure TgsInvMovementDocuments.DeleteDocLine(const ASubType: String);
var
  Obj: TgdcInvDocumentLine;
  I: Integer;
begin
  I := FDocID.IndexOfName(ASubType + 'p');
  if I <> - 1 then
  begin
    Obj := TgdcInvDocumentLine.Create(nil);
    try
      Obj.SubType := ASubType;
      Obj.SubSet := 'ByID';
    while I <> -1 do
    begin
      Obj.Close;
      Obj.ParamByName('id').AsString := FDocID.Values[FDocID.Names[I]];
      Obj.Open;
      Obj.Delete;

      FDocID.Delete(I);
      I := FDocID.IndexOfName(ASubType + 'p');
    end;
    finally
      Obj.Free;
    end;
  end;
end;

procedure TgsInvMovementDocuments.Delete;
var
  Dept: TgdcDepartment;
  Company: TgdcCompany;
  Good: TgdcGood;
begin

  DeleteDocLine('147013038_109092844');
  DeleteDoc('147013038_109092844');
  DeleteDocLine('147013043_109092844');
  DeleteDoc('147013043_109092844');
  DeleteDocLine('147010993_109092844');
  DeleteDoc('147010993_109092844');

  Dept := TgdcDepartment.Create(nil);
  try
    Dept.SubSet := 'ByID';
    Dept.ParamByName('id').AsInteger :=  FDeptID1;
    Dept.Open;
    Dept.Delete;

    Dept.Close;
    Dept.ParamByName('id').AsInteger :=  FDeptID2;
    Dept.Open;
    Dept.Delete;
  finally
    Dept.Free;
  end;

  Company := TgdcCompany.Create(nil);
  try
    Company.SubSet := 'ByID';
    Company.ParamByName('id').AsInteger := FCompanyID1;
    Company.Open;
    if not Company.Eof then
      Company.Delete;

    Company.Close;
    Company.ParamByName('id').AsInteger := FCompanyID2;
    Company.Open;
    if not Company.Eof then
      Company.Delete;
  finally
    Company.Free;
  end;

  Good := TgdcGood.Create(nil);
  try 
    Good.Subset := 'ByID';
    Good.ParamByName('id').AsInteger := FGoodId1;
    Good.Open;
    Good.Delete;

    Good.Close;
    Good.ParamByName('id').AsInteger := FGoodId2;
    Good.Open;
    Good.Delete;
  finally
    Good.Free;
  end;
end;

initialization
  RegisterTest('DB', TgsInvMovementDocuments.Suite);
end.
