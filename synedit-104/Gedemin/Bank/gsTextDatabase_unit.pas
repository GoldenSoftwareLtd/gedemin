unit gsTextDataBase_unit;

interface
uses classes, dbClient, db,  contnrs, Gedemin_TLB, ComObj, Comserv;

type
TgsTextDatabaseTable = class;
TgsTextDatabaseArea = class;
TgsTextDatabase = class;

TgsTextDatabase = class(TAutoObject, IgsTextDatabase)
private
  FAreasList: TList;

  function GetArea(const Index: Integer): TgsTextDatabaseArea;
  function GetAreasCount: Integer;

protected
  function  Get_AreasCount: Integer; safecall;
  function  Get_Areas(Index: Integer): IgsTextDatabaseAreas; safecall;

public
  constructor Create;
  destructor Destroy; override;

  property Areas[const Index: Integer]: TgsTextDatabaseArea read GetArea;
  property AreasCount: Integer read GetAreasCount;

  function AddArea(Item: TgsTextDatabaseArea): Integer;
  procedure DeleteArea(const Index: Integer);
  procedure Clear;
end;

TgsTextDatabaseArea = class(TAutoObject, IgsTextDatabaseAreas)
private
  FAreaName: String;
  FTablesList: TList;
  FAreaFields: TClientDataSet;
  function GetTable(const Index: Integer): TgsTextDatabaseTable;
  function GetTablesCount: integer;

protected
  function  Get_Name: WideString; safecall;
  function  Get_AreaFields: IgsClientDataSet; safecall;
  function  Get_TableCount: Integer; safecall;
  function  Get_Tables(Index: Integer): IgsTextDatabaseTable; safecall;

public
  constructor Create;
  destructor Destroy; override;

  property Name: String read FAreaName write FAreaName;
  property AreaFields: TClientDataSet read FAreaFields;
  property TableCount: Integer read GetTablesCount;
  property Tables[const Index: Integer]: TgsTextDatabaseTable read GetTable;

  function AddTable(Item: TgsTextDatabaseTable): Integer;
  procedure DeleteTable(const Index: Integer);

  procedure FillFields(Fld: TClientDataset);
end;

TgsTextDatabaseTable = class(TAutoObject, IgsTextDatabaseTable)
private
  FTableName: String;
  FTableRecords: TClientDataSet;

protected
  function  Get_Name: WideString; safecall;
  function  Get_Records: IgsClientDataSet; safecall;

public
  constructor Create;
  destructor Destroy; override;

  property Name: String read FTableName write FTableName;
  property Records: TClientDataSet read FTableRecords write FTableRecords;

  procedure FillFields(Fld: TClientDataset);
end;

implementation
uses Windows, gdcOLEClassList;

{TgsTextDatabase}

constructor TgsTextDatabase.Create;
begin
  inherited;
  FAreasList := TList.Create;
end;

destructor TgsTextDatabase.Destroy;
begin
  FAreasList.Free;
  inherited;
end;

function TgsTextDatabase.AddArea(Item: TgsTextDatabaseArea): Integer;
begin
  Result := -1;
  if not Assigned(Item) then Exit;
  Result := FAreasList.Add(nil);
  FAreasList.Items[Result] := Item;
  TgsTextDatabaseArea(FAreasList.Items[Result])._AddRef;
end;

procedure TgsTextDatabase.DeleteArea(const Index: Integer);
begin
  TgsTextDatabaseArea(FAreasList.Items[Index])._Release;
  FAreasList.Items[Index] := nil;
  FAreasList.Delete(Index);
end;

function TgsTextDatabase.GetArea(const Index: Integer): TgsTextDatabaseArea;
begin
  Result := TgsTextDatabaseArea(FAreasList[Index]);
end;

function TgsTextDatabase.GetAreasCount: Integer;
begin
  Result := FAreasList.Count;
end;

function TgsTextDatabase.Get_Areas(Index: Integer): IgsTextDatabaseAreas;
begin
  Result := TgsTextDatabaseArea(FAreasList[Index]);
end;

function TgsTextDatabase.Get_AreasCount: Integer;
begin
  Result := FAreasList.Count;
end;

procedure TgsTextDatabase.Clear;
var
  I: Integer;
begin
  for  I := FAreasList.Count - 1 downto 0 do
    DeleteArea(I);
end;

{TgsTextDatabaseArea}

constructor TgsTextDatabaseArea.Create;
begin
  inherited Create;
  FTablesList := TList.Create;
  FAreaFields := TClientDataSet.Create(nil);
end;

destructor TgsTextDatabaseArea.Destroy;
begin
  FTablesList.Free;
  FAreaFields := nil;
  inherited;
end;

function TgsTextDatabaseArea.AddTable(Item: TgsTextDatabaseTable): Integer;
begin
  Result := -1;
  if not Assigned(Item) then Exit;
  Result := FTablesList.Add(nil);
  FTablesList.Items[Result] := Item;
  TgsTextDatabaseTable(FTablesList.Items[Result])._AddRef;
end;

procedure TgsTextDatabaseArea.DeleteTable(const Index: Integer);
begin
  TgsTextDatabaseTable(FTablesList.Items[Index])._Release;
  FTablesList.Items[Index] := nil;
  FTablesList.Delete(Index);
end;

procedure TgsTextDatabaseArea.FillFields(Fld: TClientDataset);
begin
  if Fld = nil then Exit;
  FAreaFields.FieldDefs.Clear;
  FAreaFields.FieldDefs := Fld.FieldDefs;
  FAreaFields.IndexDefs.Clear;
  FAreaFields.Data := NULL;
  FAreaFields.CreateDataSet;
  FAreaFields.Data := Fld.Data;
end;

function TgsTextDatabaseArea.GetTable(const Index: Integer): TgsTextDatabaseTable;
begin
  Result := TgsTextDatabaseTable(FTablesList[Index]);
end;

function TgsTextDatabaseArea.GetTablesCount: Integer;
begin
  Result := FTablesList.Count;
end;

function TgsTextDatabaseArea.Get_AreaFields: IgsClientDataSet;
begin
  Result := GetGdcOLEObject(FAreaFields) as IgsClientDataSet;
end;

function TgsTextDatabaseArea.Get_Name: WideString;
begin
  Result := FAreaName;
end;

function TgsTextDatabaseArea.Get_TableCount: Integer;
begin
  Result := FTablesList.Count;
end;

function TgsTextDatabaseArea.Get_Tables(Index: Integer): IgsTextDatabaseTable;
begin
  Result := TgsTextDatabaseTable(FTablesList[Index]);
end;

{TgsTextDatabaseTable}

constructor TgsTextDatabaseTable.Create;
begin
  inherited Create;
  FTableRecords := TClientDataSet.Create(nil);
end;

destructor TgsTextDatabaseTable.Destroy;
begin
  FTableRecords := nil;
  inherited;
end;

procedure TgsTextDatabaseTable.FillFields(Fld: TClientDataset);
begin
  if Fld = nil then exit;
  FTableRecords.FieldDefs.Clear;
  FTableRecords.FieldDefs := Fld.FieldDefs;
  FTableRecords.IndexDefs.Clear;
  FTableRecords.Data := NULL;
  FTableRecords.CreateDataSet;
  FTableRecords.Data := Fld.Data;
end;

function TgsTextDatabaseTable.Get_Name: WideString;
begin
  Result := FTableName;
end;

function TgsTextDatabaseTable.Get_Records: IgsClientDataSet;
begin
  Result := GetGdcOLEObject(FTableRecords) as IgsClientDataSet;
end;

initialization
  TAutoObjectFactory.Create(ComServer, TgsTextDatabase, CLASS_gs_TextDatabase,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TgsTextDataBaseArea, CLASS_gs_TextDataBaseAreas,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TgsTextDataBaseTable, CLASS_gs_TextDataBaseTable,
    ciMultiInstance, tmApartment);

end.
