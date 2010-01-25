unit at_SetEditor;

interface

uses
  Windows,          Messages,         SysUtils,         Classes,
  Graphics,         Controls,         Forms,            Dialogs,
  StdCtrls,         DB,               Contnrs,          IBDatabase,
  IBCustomDataSet,  IBQuery,          IBSQL,            IBUpdateSQL,
  Buttons,          at_Classes;

type
  TatSetEditor = class;


  TatSetEditorLink = class(TDataLink)
  private
    FSetEditor: TatSetEditor;

    function GetCrossFieldValue: String;

  protected
    procedure ActiveChanged; override;
    procedure CheckBrowseMode; override;
    procedure EditingChanged; override;
    procedure DataSetChanged; override;
    procedure UpdateData; override;

    function GetTableName(out TableName: String): Boolean;
    function GetDatabase: TIBDatabase;
    function GetTransaction: TIBTransaction;

  public
    constructor Create(ASetEditor: TatSetEditor);
    destructor Destroy; override;

  end;


  TatSetEditor = class(TWinControl)
  private
    FEditor: TCustomEdit;
    FButton: TSpeedButton;

    FDataLink: TatSetEditorLink;

    FDataField: String;

    FatDatabase: TatDatabase;

    function GetDataSource: TdataSource;
    procedure SetDataSource(Value: TDataSource);
    procedure SetDataField(const Value: String);
    procedure SetFont(Value: TFont);

    procedure SetatDatabase(AnatDatabase: TatDatabase);

    procedure AdjustChildren;
    procedure ButtonClick(Sender: TObject);

  protected
    procedure Resize; override;

    function Choose: Boolean;
    procedure CheckAttributes;

    procedure SetValue(const Value: String);

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    property atDatabase: TatDatabase read FatDatabase write SetatDatabase;

  published
    property Font write SetFont;
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property DataField: String read FDataField write SetDataField;

  end;

  EatSetEditorError = class(Exception);

implementation

uses at_sql_parser, at_SetEditor_dlgChoose;


type
  TatSetEditPrepare = class
  private
    FSetEditor: TatSetEditor;
    FTable, FCrossTable, FSetTable: TatRelation;

    FSourceSQL, FTargetSQL: String;

    function GetEditKeyValue: String;
    function GetCrossKeyFields: String;
    function GetSourceFields: String;
    function GetCrossField: String;

    procedure PrepareSourceSQL;
    procedure PrepareTargetSQL;

  protected
    function PrepareInsertSQL: String;
    function PrepareModifySQL: String;
    function PrepareRefreshSQL: String;
    function PrepareDeleteSQL: String;

  public
    constructor Create(ASetEditor: TatSetEditor);
    destructor Destroy; override;

    function EditSet: Boolean;

  published

  end;

  
{ TatSetEditPrepare }

constructor TatSetEditPrepare.Create(ASetEditor: TatSetEditor);
begin
  FSetEditor := ASetEditor;
end;

destructor TatSetEditPrepare.Destroy;
begin
  inherited Destroy;
end;

function TatSetEditPrepare.EditSet: Boolean;
var
  TableName: String;
begin
  with FSetEditor do
  begin
    CheckAttributes;

    if not FDataLink.GetTableName(TableName) then
      raise EatSetEditorError.Create('Data set should be TIBDataSet or should have Update SQL!');

    FTable := FatDatabase.Relations.ByRelationName(TableName);

    if Assigned(FTable.RelationFields.ByFieldName(DataField)) then
      FCrossTable := FTable.RelationFields.ByFieldName(DataField).CrossRelation;

    if Assigned(FCrossTable) then
      FSetTable := FCrossTable.PrimaryKey.ConstraintFields[1].References;

    if not Assigned(FTable) or not Assigned(FCrossTable) then
      raise EatSetEditorError.Create('Can not get attributes data!');
  end;

  PrepareSourceSQL;
  PrepareTargetSQL;

  with TdlgChoose.Create(FSetEditor) do
  try
    qryResult.SQL.Text := FTargetSQL;
    qryReference.SQL.Text := FSourceSQL;

    updResult.InsertSQL.Text := PrepareInsertSQL;
    updResult.ModifySQL.Text := PrepareModifySQL;
    updResult.RefreshSQL.Text := PrepareRefreshSQL;
    updResult.DeleteSQL.Text := PrepareDeleteSQL;

    qryResult.Transaction := FSetEditor.FDataLink.GetTransaction;
    qryResult.Database := FSetEditor.FDataLink.GetDatabase;
    qryReference.Transaction := FSetEditor.FDataLink.GetTransaction;
    qryReference.Database := FSetEditor.FDataLink.GetDatabase;

    qfReference.Database := FSetEditor.FDataLink.GetDatabase;

    Table := Self.FTable;
    CrossTable := Self.FCrossTable;
    SetTable := Self.FSetTable;
    EditKey := GetEditKeyValue;
    TheSetEditor := Self.FSetEditor;

    Result := ShowModal = mrOk;

    if Result then
      FSetEditor.SetValue(Value);
  finally
    Free;
  end;
end;

function TatSetEditPrepare.PrepareInsertSQL: String;
var
  I: Integer;
  FField: TatRelationField;
  F, V: String;
begin
  F := '';
  V := '';

  for I := 0 to FCrossTable.RelationFields.Count - 1 do
  begin
    FField := FCrossTable.RelationFields[I];

    F := F + FField.FieldName;
    V := V + ':' + FField.FieldName;

    if I < FCrossTable.RelationFields.Count - 1 then
    begin
      F := F + ', ';
      V := V + ', ';
    end;
  end;

  Result := Format('INSERT INTO %s (%s) VALUES (%s)',
    [FCrossTable.RelationName, F, V]);
end;

function TatSetEditPrepare.PrepareModifySQL: String;
var
  I: Integer;
  FField: TatRelationField;
  F, W: String;
begin
  F := '';
  W := '';

  for I := 0 to FCrossTable.RelationFields.Count - 1 do
  begin
    FField := FCrossTable.RelationFields[I];
    F := F + FField.FieldName + ' = :' + FField.FieldName;

    if I < FCrossTable.RelationFields.Count - 1 then
      F := F + ', ';
  end;

  for I := 0 to FCrossTable.PrimaryKey.ConstraintFields.Count - 1 do
  begin
    W := W + FCrossTable.PrimaryKey.ConstraintFields[I].FieldName + ' = ' +
      ':OLD_' + FCrossTable.PrimaryKey.ConstraintFields[I].FieldName;

    if I < FCrossTable.PrimaryKey.ConstraintFields.Count - 1 then
      W := W + ' AND ';
  end;

  Result := Format('UPDATE %s SET %s WHERE %s',
    [FCrossTable.RelationName, F, W]);
end;

function TatSetEditPrepare.PrepareRefreshSQL: String;
var
  I: Integer;
  FField: TatRelationField;
  F, W: String;
begin
  F := '';
  W := '';

  for I := 0 to FCrossTable.RelationFields.Count - 1 do
  begin
    FField := FCrossTable.RelationFields[I];
    F := F + 'B.' + FField.FieldName;

    if I < FCrossTable.RelationFields.Count - 1 then
      F := F + ', ';
  end;

  F := F + ', ' + GetCrossField;

  for I := 0 to FCrossTable.PrimaryKey.ConstraintFields.Count - 1 do
  begin
    W := W + 'B.' + FCrossTable.PrimaryKey.ConstraintFields[I].FieldName + ' = ' +
      ':OLD_' + FCrossTable.PrimaryKey.ConstraintFields[I].FieldName;

    if I < FCrossTable.PrimaryKey.ConstraintFields.Count - 1 then
      W := W + ' AND ';
  end;

  W := W + ' AND ' + 'B.' + FCrossTable.PrimaryKey.ConstraintFields[1].FieldName +
    ' = ' + 'C.' + FSetTable.PrimaryKey.ConstraintFields[0].FieldName;

  Result := Format('SELECT %s FROM %s B, %s C WHERE %s',
    [F, FCrossTable.RelationName, FSetTable.RelationName, W]);
end;

function TatSetEditPrepare.PrepareDeleteSQL: String;
var
  I: Integer;
  W: String;
begin
  for I := 0 to FCrossTable.PrimaryKey.ConstraintFields.Count - 1 do
  begin
    W := W + FCrossTable.PrimaryKey.ConstraintFields[I].FieldName + ' = ' +
      ':OLD_' + FCrossTable.PrimaryKey.ConstraintFields[I].FieldName;

    if I < FCrossTable.PrimaryKey.ConstraintFields.Count - 1 then
      W := W + ' AND ';
  end;

  Result := Format('DELETE FROM %s WHERE %s', [FCrossTable.RelationName, W]);
end;

function TatSetEditPrepare.GetEditKeyValue: String;
begin
  Result := FSetEditor.FDataLink.DataSet.FieldByName(FTable.
    PrimaryKey.ConstraintFields[0].FieldName).AsString;
end;

function TatSetEditPrepare.GetCrossKeyFields: String;
begin
  Result :=
    'B.' + FCrossTable.RelationFields[0].FieldName +
    ', ' +
    'B.' + FCrossTable.RelationFields[1].FieldName;
end;

function TatSetEditPrepare.GetSourceFields: String;
var
  I: Integer;
begin
  Result := '';

  for I := 0 to FSetTable.RelationFields.Count - 1 do
  begin
    Result := Result + 'C.' + FSetTable.RelationFields.Items[I].FieldName;

    if I < FSetTable.RelationFields.Count - 1 then
      Result := Result + ', ';
  end;
end;

function TatSetEditPrepare.GetCrossField: String;
begin
  Result := 'C.' + FTable.RelationFields.ByFieldName(FSetEditor.DataField).
    CrossRelationFieldName;
end;

procedure TatSetEditPrepare.PrepareSourceSQL;
begin
  FSourceSQL := Format
  (
    'SELECT %s FROM %s C',
    [
      GetSourceFields,
      FSetTable.RelationName
    ]
  );
end;

procedure TatSetEditPrepare.PrepareTargetSQL;
begin
  FTargetSQL := Format
  (
    'SELECT %s FROM %s B, %s C WHERE B.%s = C.%s AND B.%s = %s',
    [
      GetCrossKeyFields + ', ' + GetCrossField,
      FCrossTable.RelationName,
      FSetTable.RelationName,
      FCrossTable.PrimaryKey.ConstraintFields[1].FieldName,
      FSetTable.PrimaryKey.ConstraintFields[0].FieldName,
      FCrossTable.PrimaryKey.ConstraintFields[0].FieldName,
      GetEditKeyValue
    ]
  );
end;

{ TatSetEditorLink }

constructor TatSetEditorLink.Create(ASetEditor: TatSetEditor);
begin
  inherited Create;

  FSetEditor := ASetEditor;
end;

destructor TatSetEditorLink.Destroy;
begin
  inherited Destroy;
end;

procedure TatSetEditorLink.ActiveChanged;
begin
  if Active then
    FSetEditor.FEditor.Text := GetCrossFieldValue
  else
    FSetEditor.FEditor.Text := '';
end;

procedure TatSetEditorLink.CheckBrowseMode;
begin
  FSetEditor.FEditor.Text := GetCrossFieldValue;
end;

procedure TatSetEditorLink.EditingChanged;
begin
  FSetEditor.FEditor.Text := GetCrossFieldValue;
end;

procedure TatSetEditorLink.DataSetChanged;
begin
  FSetEditor.FEditor.Text := GetCrossFieldValue;
end;

procedure TatSetEditorLink.UpdateData;
begin
  FSetEditor.FEditor.Text := GetCrossFieldValue;
end;

function TatSetEditorLink.GetTableName(out TableName: String): Boolean;
var
  Parser: TsqlParser;
  TheSQL: TStringList;
begin
  if not Active then
  begin
    Result := False;
    Exit;
  end;

  if DataSet is TIBQuery then
  begin
    with DataSet as TIBQuery do
    begin
      if Assigned(UpdateObject) and (UpdateObject is TIBUpdateSQL) then
        TheSQL := (UpdateObject as TIBUpdateSQL).ModifySQL as TStringList
      else
        TheSQL := nil;
    end;
  end else

  if DataSet is TIBDataSet then
    TheSQL := (DataSet as TIBdataSet).ModifySQL as TStringList
  else
    TheSQL := nil;

  Result := Assigned(TheSQL) and (TheSQL.Text > '');

  if Result then
  begin
    Parser := TsqlParser.Create(TheSQL.Text);

    try
      Parser.Parse;

      if (Parser.Statements.Count > 0) and (Parser.Statements[0] is TsqlUpdate) and
        Assigned((Parser.Statements[0] as TsqlUpdate).Table)
      then
        TableName := (Parser.Statements[0] as TsqlUpdate).Table.TableName
      else
        Result := False;
    finally
      Parser.Free;
    end;
  end;
end;

function TatSetEditorLink.GetDatabase: TIBDatabase;
begin
  if DataSet is TIBCustomDataSet then
    Result := (DataSet as TIBCustomDataSet).Database
  else
    Result := nil;
end;

function TatSetEditorLink.GetTransaction: TIBTransaction;
begin
  if DataSet is TIBCustomDataSet then
    Result := (DataSet as TIBCustomDataSet).Transaction
  else
    Result := nil;
end;

function TatSetEditorLink.GetCrossFieldValue: String;
var
  Table: TatRelation;
  Field: TatRelationField;
  F: TField;
  TableName: String;
begin
  if not Assigned(FSetEditor.FatDatabase) then FSetEditor.CheckAttributes;

  if Assigned(FSetEditor.FatDatabase) and GetTableName(TableName) then
  begin
    Table := FSetEditor.FatDatabase.Relations.ByRelationName(TableName);

    if Assigned(Table) then
    begin
      Field := Table.RelationFields.ByFieldName(FSetEditor.DataField);

      if Assigned(Field) then
        F := DataSet.FindField(Field.FieldName)
      else
        F := nil;

      if Assigned(F) and (Field.Field.FieldType = ftString) then
        Result := F.AsString
      else
        Result := '';
    end else
      Result := '';
  end else
    Result := '';
end;

{ TatSetEditor }

constructor TatSetEditor.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  FEditor := TMemo.Create(Self);
  with (FEditor as TMemo) do
  begin
    ScrollBars := ssVertical;
    ReadOnly := True;
  end;

  InsertControl(FEditor);

  FButton := TSpeedButton.Create(Self);
  FButton.Caption := '...';
  FButton.OnClick := ButtonClick;
  InsertControl(FButton);

  Width := 200;
  Height := 34;

  AdjustChildren;

  FDataLink := TatSetEditorLink.Create(Self);
end;

destructor TatSetEditor.Destroy;
begin
  FDataLink.Free;

  inherited Destroy;
end;

procedure TatSetEditor.Resize;
begin
  inherited Resize;
  AdjustChildren;
end;

function TatSetEditor.Choose: Boolean;
var
  FPrepare: TatSetEditPrepare;
begin
  FPrepare := TatSetEditPrepare.Create(Self);
  try
    Result := FPrepare.EditSet;
  finally
    FPrepare.Free;
  end;
end;

procedure TatSetEditor.CheckAttributes;
begin
  if not Assigned(FatDatabase) then
    FatDatabase := at_Classes.atDatabase;
end;

procedure TatSetEditor.SetValue(const Value: String);
begin
  FEditor.Text := Value;
end;

function TatSetEditor.GetDataSource: TdataSource;
begin
  Result := FDataLink.DataSource;
  FDataLink.UpdateData;
end;

procedure TatSetEditor.SetDataSource(Value: TDataSource);
begin
  FDataLink.DataSource := Value;
  FDataLink.UpdateData;
end;

procedure TatSetEditor.SetDataField(const Value: String);
begin
  FDataField := Value;
  FDataLink.UpdateData;
end;

procedure TatSetEditor.SetFont(Value: TFont);
begin
  FButton.Font := Value;
  (FEditor as TMemo).Font := Value;
  inherited Font := Value;
  AdjustChildren;
end;

procedure TatSetEditor.SetatDatabase(AnatDatabase: TatDatabase);
begin
  Fatdatabase := AnatDatabase;
  FDataLink.UpdateData;
end;

procedure TatSetEditor.AdjustChildren;
begin
  FEditor.SetBounds(0, 0, Width - 20, Height);
  FButton.SetBounds(Width - 20, 0, 20, Height);
end;

procedure TatSetEditor.ButtonClick(Sender: TObject);
begin
  if FDataLink.Active then
  begin
    if not (FDataLink.DataSet.State in [dsEdit, dsInsert]) then
      FDataLink.DataSet.Edit;

    if Choose then
      FDataLink.DataSet.FieldByName(DataField).
        Assign(FDataLink.DataSet.FieldByName(DataField));
  end;
end;

end.

