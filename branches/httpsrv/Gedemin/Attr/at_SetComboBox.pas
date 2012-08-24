
{++


  Copyright (c) 2000-2004 by Golden Software of Belarus

  Module

    at_SetComboBox

  Abstract

    Combo box to choose several records of dataset into a table
    taken from structure at_Classes

  Author

    Romanovski Denis  (11.11.2000)

  Revisions history

    Initial  11.11.2000     Basic functionality created.

    1.0      14.11.2000     Everything works.

    2.0      08.02.2001     Tree combo added.

    3.0      18.03.2002     Julie  Установлено соответствие между SetLookupComboBox и
                                   доменом, по которому создается лукап
--}


unit at_SetComboBox;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, DB, Menus, Grids, DBGrids, gsDBGrid, gsIBGrid,
  IBDatabase, IBCustomDataSet, IBQuery, IBUpdateSQL, at_Classes, at_sql_parser,
  Comctrls, gsIBLargeTreeView;

type
  TatSetLookupComboBox = class;
  TatSetLookupLink = class;

  TCrackIBDataSet = class(TIBCustomDataSet)
  end;

  TatSetBase = class(TForm)
  protected
    FTargetDataSet: TIBDataSet;

    procedure ClearCheckBoxes; virtual; abstract;
  end;

  TatSetList = class(TatSetBase)
  private
    FGrid: TgsIBGrid;
    FSourceDataSet: TIBDataSet;
    FDataSource: TDataSource;
    FMenu: TPopupMenu;

    FTableKeyField, FSourceKeyField: TField;
    FTargetKeyField, FTargetSetKeyField: TField;
    FTargetTextField, FSetTextField: TField;

    procedure WMActivateApp(var Message: TWMActivateApp);
      message WM_ACTIVATEAPP;

    procedure GridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CheckBoxSet(Sender: TObject; CheckID: String; var Checked: Boolean);

    function GetCombo: TatSetLookupComboBox;

    procedure SelectAll(Sender: TObject);
    procedure RemoveAll(Sender: TObject);

  protected
    procedure DoShow; override;
    procedure DoHide; override;

    procedure Open;
    procedure Close;

    procedure SetupCheckBoxes;
    procedure ClearCheckBoxes; override;

    procedure ApplyChanges;
    procedure CancelChanges; 

    property Combo: TatSetLookupComboBox read GetCombo;

  public
    constructor CreateNew(AOwner: TComponent; Dummy: Integer = 0); override;
    destructor Destroy; override;

    function CloseQuery: Boolean; override;
    function ShowModal: Integer; override;

  end;


  TatSetTree = class(TatSetBase)
  private
    FTree: TgsIBLargeTreeView;

    FTableKeyField: TField;
    FTargetKeyField, FTargetSetKeyField: TField;
    FTargetTextField: TField;

    FList, FNames: TStringList;
    FMenu: TPopupMenu;

    procedure WMActivateApp(var Message: TWMActivateApp);
      message WM_ACTIVATEAPP;

    procedure TreeKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CheckedChanged(Sender: TObject; Node: TTreeNode);
    procedure OnNewNode(Sender: TObject; Node: TTreeNode);

    function GetCombo: TatSetLookupComboBox;

    procedure SelectAll(Sender: TObject);
    procedure RemoveAll(Sender: TObject);

  protected
    procedure DoShow; override;
    procedure DoHide; override;

    procedure Open;
    procedure Close;

    procedure SetupCheckBoxes;
    procedure ClearCheckBoxes; override;

    procedure ApplyChanges;
    procedure CancelChanges; 

    property Combo: TatSetLookupComboBox read GetCombo;

  public
    constructor CreateNew(AOwner: TComponent; Dummy: Integer = 0); override;
    destructor Destroy; override;

    function CloseQuery: Boolean; override;
    function ShowModal: Integer; override;

  end;


  TatSetLookupLink = class(TDataLink)
  private
    FCombo: TatSetLookupComboBox;

    function GetCrossFieldValue: String;

  protected
    procedure ActiveChanged; override;
    procedure CheckBrowseMode; override;
    procedure EditingChanged; override;
    procedure DataSetChanged; override;
    procedure UpdateData; override;
    procedure DataSetScrolled(Distance: Integer); override;

    function GetTableName(out TableName: String): Boolean;
    function GetDatabase: TIBDatabase;
    function GetTransaction: TIBTransaction;
    function GetReadTransaction: TIBTransaction;

    property Combo: TatSetLookupComboBox read FCombo;

  public
    constructor Create(ACombo: TatSetLookupComboBox);
    destructor Destroy; override;
  end;

  TatSetLookupComboBox = class(TCustomControl)
  private
    FEditor: TEdit;
    FButton: TSpeedButton;
    FBitmap: TBitmap;
    FList: TatSetBase;
    FDataLink: TatSetLookupLink;
    FDataField: String;
    FDropDownCount: Integer;

    FTableName: String;
    FRelation: TatRelation;
    FOldKey: Integer;

    procedure AdjustChildren;
    procedure ButtonClick(Sender: TObject);
    procedure EditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);

    function GetDataSource: TDataSource;
    procedure SetDataSource(const Value: TDataSource);
    procedure SetDataField(const Value: String);
    procedure SetBitmap(const Value: TBitmap);

  protected
    procedure Resize; override;
    procedure ActiveChanged;
    procedure InitializeList;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;

    procedure DropDown; dynamic;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

  published
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property DataField: String read FDataField write SetDataField;
    property DropDownCount: Integer read FDropDownCount write FDropDownCount;
    property Bitmap: TBitmap read FBitmap write SetBitmap;

    property Visible;
    property Enabled;
    property TabOrder;
    property TabStop;

    property Anchors;
  end;

  EatSetComboError = Class(Exception);

implementation

uses
  gdc_dlgG_unit, gdcBase
  {$IFDEF LOCALIZATION}
  {must be placed after Windows unit!}
   ,gd_localization_stub
  {$ENDIF}
  ;

var
  gsCOMBOHOOK: HHOOK = 0;

function gsComboHookProc(nCode: Integer; wParam: Integer; lParam: Integer): LResult;
  stdcall;
var
  P: TPoint;
begin
  Result := CallNextHookEx(gsCOMBOHOOK, nCode, wParam, lParam);
  with PMouseHookStruct(lParam)^ do
  begin
    case wParam of
      WM_LBUTTONDOWN, WM_NCLBUTTONDOWN, WM_LBUTTONUP:
      begin
        if
          (Screen.ActiveCustomForm <> nil) and
          (
            (Screen.ActiveCustomForm is TatSetList) or
            (Screen.ActiveCustomForm is TatSetTree)
          )
            and
          (GetForegroundWindow = Screen.ActiveCustomForm.Handle)
        then
        with Screen.ActiveCustomForm do
        begin
          P := ScreenToClient(pt);
          if (P.X < 0) or (P.X > Width) or
            (P.Y < 0) or (P.Y > Height) then
          begin
            ModalResult := mrOk;
            Result := 1;
          end else
          begin
            Result := 0;
          end;
        end
      end;
    end;
  end;
end;

type
  TatSetLookupPrepare = class
  private
    FCombo: TatSetLookupComboBox;

    FCrossTable, FSetTable: TatRelation;
    FMainField, FSetField: TatRelationField;

    FSourceSQL, FTargetSQL: String;

    function GetEditKeyValue: String;
    function GetSourceFields: String;
    function GetCrossKeyFields: String;
    function GetCrossField: String;

    procedure PrepareSourceSQL;
    procedure PrepareTargetSQL;
    procedure PrepareCondition;

    procedure PrepareGrid;
    procedure PrepareTree;

  protected
    function PrepareInsertSQL: String;
    function PrepareModifySQL: String;
    function PrepareRefreshSQL: String;
    function PrepareDeleteSQL: String;

    property SourceSQL: String read FSourceSQL;
    property TargetSQL: String read FTargetSQL;

  public
    constructor Create(ACombo: TatSetLookupComboBox);
    destructor Destroy; override;

    procedure Prepare;

  end;

{ TatSetLookupPrepare }

constructor TatSetLookupPrepare.Create(ACombo: TatSetLookupComboBox);
begin
  FCombo := ACombo;
end;

destructor TatSetLookupPrepare.Destroy;
begin
  inherited Destroy;
end;

procedure TatSetLookupPrepare.Prepare;
begin
  //////////////////////////////////////////////////////////////////////////////
  //  Получаем указатели на необходимые таблицы
  //////////////////////////////////////////////////////////////////////////////

  FMainField := FCombo.FRelation.RelationFields.ByFieldName(
    FCombo.FDataField);

  if not Assigned(FMainField) then
    raise EatSetComboError.Create('Can''t get attributes data!');

  FCrossTable := FMainField.CrossRelation;
  FSetTable := FMainField.Field.SetTable;
  FSetField := FMainField.Field.SetListField;

  if not Assigned(FSetField) then
    FSetField := FSetTable.ListField;

  if not Assigned(FCrossTable) or not Assigned(FSetTable) then
    raise EatSetComboError.Create('Can''t get attributes data!');

  PrepareSourceSQL;
  PrepareTargetSQL;

  if FSetTable.IsStandartTreeRelation then
  begin
    FCombo.FList := TatSetTree.CreateNew(FCombo);
    PrepareTree;
  end else begin
    FCombo.FList := TatSetList.CreateNew(FCombo);
    PrepareGrid;
  end;
end;

procedure TatSetLookupPrepare.PrepareGrid;
var
  I: Integer;
  F: TField;
begin
  with FCombo.FDataLink, FCombo.FList as TatSetList do
  begin
    Close;

    FSourceDataSet.SelectSQL.Text := SourceSQL;
    FSourceDataSet.Database := GetDatabase;
    FSourceDataSet.Transaction := GetTransaction;
    FSourceDataSet.ReadTransaction := GetReadTransaction;

    FTargetDataSet.SelectSQL.Text := TargetSQL;
    FTargetDataSet.Database := GetDatabase;
    FTargetDataSet.Transaction := GetTransaction;
    FTargetDataSet.ReadTransaction := GetReadTransaction;

    FTargetDataSet.RefreshSQL.Text := PrepareRefreshSQL;
    FTargetDataSet.ModifySQL.Text := PrepareModifySQL;
    FTargetDataSet.InsertSQL.Text := PrepareInsertSQL;
    FTargetDataSet.DeleteSQL.Text := PrepareDeleteSQL;

    FSourceDataSet.DisableControls;

    try

      Open;

      for I := 0 to FSourceDataSet.FieldCount - 1 do
      begin
        FSourceDataSet.Fields[I].Visible := False;
        FSourceDataSet.Fields[I].Required := False;
      end;

      for I := 0 to FTargetDataSet.FieldCount - 1 do
        FTargetDataSet.Fields[I].Required := False;

      F := FSourceDataSet.FindField(FSetField.FieldName);
      if Assigned(F) then
      begin
        F.Visible := True;
        FGrid.CheckBox.DisplayField := F.FieldName;
      end;

      if Assigned(FSetTable.PrimaryKey) and Assigned(FSetTable.PrimaryKey.ConstraintFields[0]) then
        FGrid.CheckBox.FieldName := FSetTable.PrimaryKey.ConstraintFields[0].FieldName
      else
        raise EatSetComboError.Create('У таблицы ' + FSetTable.RelationName +
          ' отсутствует первичный ключ!');

      FSourceKeyField := FSourceDataSet.
        FindField(FSetTable.PrimaryKey.ConstraintFields[0].FieldName);

      FTargetKeyField := FTargetDataSet.FindField(FCrossTable.PrimaryKey.
        ConstraintFields[0].FieldName);

      FTargetSetKeyField := FTargetDataSet.FindField(FCrossTable.PrimaryKey.
        ConstraintFields[1].FieldName);

      FTableKeyField := DataSet.FindField(FCombo.FRelation.PrimaryKey.
        ConstraintFields[0].FieldName);

      FTargetTextField := FTargetDataSet.FindField(FCombo.FRelation.
        RelationFields.ByFieldName(FCombo.DataField).CrossRelationFieldName);

      FSetTextField := FSourceDataSet.FindField(FCombo.FRelation.
        RelationFields.ByFieldName(FCombo.DataField).CrossRelationFieldName);

      FGrid.CheckBox.CheckBoxEvent := nil;
      SetupCheckBoxes;
      FGrid.CheckBox.CheckBoxEvent := CheckBoxSet;

      FGrid.CheckBox.Visible := True;
      FGrid.ScaleColumns := True;
      FGrid.FinishDrawing := True;
    finally
      FSourceDataSet.EnableControls;
    end;
  end;
end;

procedure TatSetLookupPrepare.PrepareTree;
var
  I: Integer;
begin
  with FCombo.FDataLink, FCombo.FList as TatSetTree do
  begin
    Close;

    FTargetDataSet.SelectSQL.Text := TargetSQL;
    FTargetDataSet.Database := GetDatabase;
    FTargetDataSet.Transaction := GetTransaction;
    FTargetDataSet.ReadTransaction := GetReadTransaction;

    FTargetDataSet.RefreshSQL.Text := PrepareRefreshSQL;
    FTargetDataSet.ModifySQL.Text := PrepareModifySQL;
    FTargetDataSet.InsertSQL.Text := PrepareInsertSQL;
    FTargetDataSet.DeleteSQL.Text := PrepareDeleteSQL;

    FTree.IDField := 'ID';
    FTree.ParentField := 'PARENT';
    FTree.ListField := FMainField.CrossRelationFieldName;
    FTree.RelationName := FSetTable.Relationname;
    FTree.TopBranchID := 'NULL';
    FTree.ShowTopBranch := False;
    FTree.Database := GetDatabase;
    FTree.CheckBoxes := True;
    FTree.Condition := FMainField.Field.SetCondition;

    Open;

    FTargetKeyField := FTargetDataSet.FindField(FCrossTable.PrimaryKey.
      ConstraintFields[0].FieldName);

    FTargetSetKeyField := FTargetDataSet.FindField(FCrossTable.PrimaryKey.
      ConstraintFields[1].FieldName);

    FTableKeyField := DataSet.FindField(FCombo.FRelation.PrimaryKey.
      ConstraintFields[0].FieldName);

    FTargetTextField := FTargetDataSet.FindField(FCombo.FRelation.
      RelationFields.ByFieldName(FCombo.DataField).CrossRelationFieldName);

    SetupCheckBoxes;
    FTree.LoadFromDatabase;

    for I := 0 to FTargetDataSet.FieldCount - 1 do
      FTargetDataSet.Fields[I].Required := False;

  end;
end;

function TatSetLookupPrepare.PrepareInsertSQL: String;
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

function TatSetLookupPrepare.PrepareModifySQL: String;
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

function TatSetLookupPrepare.PrepareRefreshSQL: String;
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

function TatSetLookupPrepare.PrepareDeleteSQL: String;
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


function TatSetLookupPrepare.GetEditKeyValue: String;
begin
  Result := FCombo.FDataLink.DataSet.FieldByName(FCombo.FRelation.
    PrimaryKey.ConstraintFields[0].FieldName).AsString;

  if Result = '' then
    raise EatSetComboError.Create('Can''t get id value!');
end;

function TatSetLookupPrepare.GetSourceFields: String;
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

procedure TatSetLookupPrepare.PrepareSourceSQL;
begin
  FSourceSQL := Format
  (
    'SELECT %s FROM %s C',
    [
      GetSourceFields,
      FSetTable.RelationName
    ]
  );

  if FMainField.Field.SetCondition > '' then
    PrepareCondition;

  if Assigned(FSetField) then
  begin
    FSourceSQL := FSourceSQL + ' ORDER BY C.' + FSetField.FieldName;
  end;
end;

procedure TatSetLookupPrepare.PrepareTargetSQL;
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

procedure TatSetLookupPrepare.PrepareCondition;
var
  Parser: TsqlParser;
  I: Integer;
  S: String;

  procedure ProcessCondition(Condition: TsqlCondition);
  var
    Z: Integer;
  begin
    for Z := 0 to Condition.Statements.Count - 1 do
      if Condition.Statements[Z] is TsqlCondition then
        ProcessCondition(Condition.Statements[Z] as TsqlCondition)
      else

      if Condition.Statements[Z] is TsqlField then
      with Condition.Statements[Z] as TsqlField do
      begin
        FieldAttrs := FieldAttrs + [eoAlias];
        FieldAlias := 'C';
      end;
  end;

begin
  S := FSourceSQL + ' WHERE ' + FMainField.Field.SetCondition;
  Parser := TsqlParser.Create(S);

  try
    Parser.Parse;

    if (Parser.Statements.Count > 0) and
      (Parser.Statements[0] is TsqlFull) then
    begin
      with (Parser.Statements[0] as TsqlFull).Where do
      for I := 0 to Conditions.Count - 1 do
        if Conditions[I] is TsqlCondition then
          ProcessCondition(Conditions[I] as TsqlCondition)
    end else
      raise EatSetComboError.Create('Invalid condition!');

    Parser.Build(FSourceSQL);
  finally
    Parser.Free;
  end;
end;

function TatSetLookupPrepare.GetCrossKeyFields: String;
begin
  if Assigned(FCrossTable.PrimaryKey) and
    Assigned(FCrossTable.PrimaryKey.ConstraintFields)
  then
    Result :=
      'b.' + FCrossTable.PrimaryKey.ConstraintFields[0].FieldName +
      ', ' +
      'b.' + FCrossTable.PrimaryKey.ConstraintFields[1].FieldName
  else
    raise EatSetComboError.Create('В таблице ' + FCrossTable.RelationName +
     ' некорректный первичный ключ!');
end;

function TatSetLookupPrepare.GetCrossField: String;
begin
  Result := 'c.' + FCombo.FRelation.RelationFields.ByFieldName(FCombo.DataField).
    CrossRelationFieldName;
end;

{ TatSetList }

constructor TatSetList.CreateNew(AOwner: TComponent; Dummy: Integer = 0);
var
  Item: TMenuItem;
begin
  inherited CreateNew(AOwner, Dummy);

  FGrid := TgsIBGrid.Create(Self);
  FGrid.ShowTotals := False;
  FGrid.Align := alClient;
  FGrid.Options := [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgRowSelect,
    dgAlwaysShowSelection];
  FGrid.OnKeyDown := GridKeyDown;
  FGrid.CheckBox.CheckBoxEvent := CheckBoxSet;
  FGrid.Striped := True;
  FGrid.ScaleColumns := True;
  FGrid.SaveSettings := False;
  InsertControl(FGrid);

  FDataSource := TDataSource.Create(Self);

  FSourceDataSet := TIBDataSet.Create(Self);

  FTargetDataSet := TIBDataSet.Create(Self);

  FDataSource.DataSet := FSourceDataSet;
  FGrid.DataSource := FDataSource;

  FMenu := TPopupMenu.Create(Self);

  Item := TMenuItem.Create(FMenu);
  Item.Caption := 'Выбрать все';
  Item.OnClick := SelectAll;
  FMenu.Items.Add(Item);

  Item := TMenuItem.Create(FMenu);
  Item.Caption := 'Очистить все';
  Item.OnClick := RemoveAll;
  FMenu.Items.Add(Item);

  FGrid.PopupMenu := FMenu;

  BorderStyle := bsNone;
  BorderIcons := [biSystemMenu, biMinimize, biMaximize];
end;

destructor TatSetList.Destroy;
begin
  FreeAndNil(FMenu);
  FreeAndNil(FSourceDataSet);
  FreeAndNil(FTargetDataSet);

  inherited Destroy;
end;

function TatSetList.CloseQuery: Boolean;
begin
  Result := inherited CloseQuery;
end;

function TatSetList.ShowModal: Integer;
begin
  Result := inherited ShowModal;

  case ModalResult of
    mrOk: ApplyChanges;
    mrCancel: CancelChanges;
  end;
end;

procedure TatSetList.DoShow;
begin
  inherited DoShow;

  if gsCOMBOHOOK = 0 then
  begin
    gsCOMBOHOOK := SetWindowsHookEx(WH_MOUSE, @gsComboHookProc, HINSTANCE,
      GetCurrentThreadID);
  end;
end;

procedure TatSetList.DoHide;
begin
  inherited DoHide;

  if gsCOMBOHOOK <> 0 then
  begin
    UnhookWindowsHookEx(gsCOMBOHOOK);
    gsCOMBOHOOK := 0;
  end;
end;

procedure TatSetList.WMActivateApp(var Message: TWMActivateApp);
begin
  inherited;
  ModalResult := mrCancel;
end;

procedure TatSetList.GridKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_RETURN: ModalResult := mrOk;
    VK_ESCAPE: ModalResult := mrCancel;
  end;
end;

procedure TatSetList.CheckBoxSet(Sender: TObject; CheckID: String;
  var Checked: Boolean);
begin
  if Checked then
  begin
    try
      FTargetDataSet.Insert;

      FTargetKeyField.AsString := FTableKeyField.AsString;
      FTargetTextField.AsString := FSetTextField.AsString;
      FTargetSetKeyField.AsString := CheckID;

      FTargetDataSet.Post;
    except
      FTargetDataSet.Cancel;
      raise;
    end;
  end else begin
    if
      FTargetDataSet.Locate
      (
        FTargetKeyField.FieldName + ';' + FTargetSetKeyField.FieldName,
        VarArrayOf([FTableKeyField.AsString, CheckID]),
        []
      )
    then
      FTargetDataSet.Delete;
  end;
end;

function TatSetList.GetCombo: TatSetLookupComboBox;
begin
  if Assigned(Owner) then
    Result := Owner as TatSetLookupComboBox
  else
    Result := nil;
end;

procedure TatSetList.Open;
begin
  if not FTargetDataSet.Active then
    FTargetDataSet.CachedUpdates := True;
    
  FSourceDataSet.Open;
  FTargetDataSet.Open;
end;

procedure TatSetList.Close;
begin
  FSourceDataSet.Close;
  FTargetDataSet.Close;
  ClearCheckBoxes;
end;

procedure TatSetList.SetupCheckBoxes;
begin
  FGrid.CheckBox.BeginUpdate;
  try
    FTargetDataSet.First;
    //FGrid.CheckBox.Clear;

    while not FTargetDataSet.EOF do
    begin
      FGrid.CheckBox.AddCheck(FTargetSetKeyField.AsString);
      FTargetDataSet.Next;
    end;
  finally
    FGrid.CheckBox.EndUpdate;
  end;
end;

procedure TatSetList.ClearCheckBoxes;
begin
  FGrid.CheckBox.Clear;
end;

procedure TatSetList.ApplyChanges;
begin
  Combo.FEditor.Text := '';
  FTargetDataSet.First;

  while not FTargetDataSet.EOF do
  begin
    Combo.FEditor.Text := Combo.FEditor.Text + FTargetTextField.AsString;
    FTargetDataSet.Next;
    if not FTargetDataSet.EOF then
      Combo.FEditor.Text := Combo.FEditor.Text + ' ';
  end;

  FTargetDataSet.ApplyUpdates;
end;

procedure TatSetList.CancelChanges;
begin
  FTargetDataSet.CancelUpdates;
  ClearCheckBoxes;

  FGrid.CheckBox.CheckBoxEvent := nil;
  SetupCheckBoxes;
  FGrid.CheckBox.CheckBoxEvent := CheckBoxSet;
end;

procedure TatSetList.SelectAll(Sender: TObject);
var
  Mark: TBookmark;
  I: Integer;
begin
  Mark := FSourceDataSet.GetBookmark;
  FSourceDataSet.DisableControls;
  FGrid.CheckBox.BeginUpdate;

  try
    FSourceDataSet.First;
    I := 0;

    while not FSourceDataSet.EOF do
    begin
      if not FGrid.CheckBox.RecordChecked then
        FGrid.CheckBox.AddCheck(FSourceKeyField.AsString);

      Inc(I);

      if (I mod 300 = 0) and (MessageBox(Handle, 'Обработано 300 записей. Продолжить?',
        'Внимание!', MB_ICONINFORMATION or MB_YESNO) = mrNo)
      then
        Break;

      FSourceDataSet.Next;
    end;

  finally
    FSourceDataSet.EnableControls;
    if FSourceDataSet.BookmarkValid(Mark) then
      FSourceDataSet.GotoBookmark(Mark);
    FGrid.CheckBox.EndUpdate;
  end;
end;

procedure TatSetList.RemoveAll(Sender: TObject);
var
  I: Integer;
begin
  FGrid.CheckBox.BeginUpdate;
  try
    for I := 0 to FGrid.CheckBox.CheckCount - 1 do
      FGrid.CheckBox.DeleteCheck(FGrid.CheckBox.StrCheck[0]);
  finally
    FGrid.CheckBox.EndUpdate;
  end;
end;

{ TatSetTree }

constructor TatSetTree.CreateNew(AOwner: TComponent; Dummy: Integer = 0);
var
  Item: TMenuItem;
begin
  inherited CreateNew(AOwner, Dummy);

  FList := TStringList.Create;
  FNames := TStringList.Create;

  FTree := TgsIBLargeTreeView.Create(Self);
  FTree.Align := alClient;
  FTree.OnKeyDown := TreeKeyDown;
  FTree.OnCheckStateChaged := CheckedChanged;
  FTree.OnNewNode := OnNewNode;
  InsertControl(FTree);

  FTargetDataSet := TIBDataSet.Create(Self);

  BorderStyle := bsNone;
  BorderIcons := [biSystemMenu, biMinimize, biMaximize];

  FMenu := TPopupMenu.Create(Self);

  Item := TMenuItem.Create(FMenu);
  Item.Caption := 'Выбрать все считанные записи.';
  Item.OnClick := SelectAll;
  FMenu.Items.Add(Item);

  Item := TMenuItem.Create(FMenu);
  Item.Caption := 'Очистить все считанные записи.';
  Item.OnClick := RemoveAll;
  FMenu.Items.Add(Item);

  FTree.PopupMenu := FMenu;

end;

destructor TatSetTree.Destroy;
begin
  FreeAndNil(FList);
  FreeAndNil(FNames);
  FreeAndNil(FTargetDataSet);

  inherited Destroy;
end;

function TatSetTree.CloseQuery: Boolean;
begin
  Result := inherited CloseQuery;
end;

function TatSetTree.ShowModal: Integer;
begin
  Result := inherited ShowModal;

  case ModalResult of
    mrOk: ApplyChanges;
    mrCancel: CancelChanges;
  end;
end;

procedure TatSetTree.DoShow;
begin
  inherited DoShow;

  if gsCOMBOHOOK = 0 then
  begin
    gsCOMBOHOOK := SetWindowsHookEx(WH_MOUSE, @gsComboHookProc, HINSTANCE,
      GetCurrentThreadID);
  end;
end;

procedure TatSetTree.DoHide;
begin
  inherited DoHide;

  if gsCOMBOHOOK <> 0 then
  begin
    UnhookWindowsHookEx(gsCOMBOHOOK);
    gsCOMBOHOOK := 0;
  end;
end;

procedure TatSetTree.WMActivateApp(var Message: TWMActivateApp);
begin
  inherited;
  ModalResult := mrCancel;
end;

procedure TatSetTree.TreeKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_RETURN: ModalResult := mrOk;
    VK_ESCAPE: ModalResult := mrCancel;
  end;
end;

procedure TatSetTree.CheckedChanged(Sender: TObject; Node: TTreeNode);
var
  I: Integer;
begin
  with Node as TgsIBTreeNode do
  begin
    if Checked then
    begin
      try
        FTargetDataSet.Insert;

        FTargetKeyField.AsString := FTableKeyField.AsString;
        FTargetSetKeyField.AsString := ID;

        FTargetDataSet.Post;
      except
        FTargetDataSet.Cancel;
        raise;
      end;
    end else begin
      if
        FTargetDataSet.Locate
        (
          FTargetKeyField.FieldName + ';' + FTargetSetKeyField.FieldName,
          VarArrayOf([FTableKeyField.AsString, ID]),
          []
        )
      then
        FTargetDataSet.Delete;

      I := FList.IndexOf(ID);
      if I <> -1 then
      begin
        FList.Delete(I);
        FNames.Delete(I);
      end;
    end;
  end;
end;

function TatSetTree.GetCombo: TatSetLookupComboBox;
begin
  if Assigned(Owner) then
    Result := Owner as TatSetLookupComboBox
  else
    Result := nil;
end;

procedure TatSetTree.SelectAll(Sender: TObject);
var
  I: Integer;
begin
  FTree.Items.BeginUpdate;
  
  for I := 0 to FTree.Items.Count - 1 do
    (FTree.Items[I] as TgsIBTreeNode).Checked := True;

  FTree.Items.EndUpdate;
end;

procedure TatSetTree.RemoveAll(Sender: TObject);
var
  I: Integer;
begin
  FTree.Items.BeginUpdate;
  
  for I := 0 to FTree.Items.Count - 1 do
    (FTree.Items[I] as TgsIBTreeNode).Checked := False;

  FTree.Items.EndUpdate;
end;

procedure TatSetTree.Open;
begin
  if not FTargetDataSet.Active then
    FTargetDataSet.CachedUpdates := True;

  FTargetDataSet.Open;
end;

procedure TatSetTree.Close;
begin
  FTargetDataSet.Close;
  ClearCheckBoxes;
  FTree.Clear;
end;

procedure TatSetTree.SetupCheckBoxes;
begin
  FTargetDataSet.First;

  while not FTargetDataSet.EOF do
  begin
    FList.Add(FTargetSetKeyField.AsString);
    FNames.Add(FTargetTextField.AsString);
    FTargetDataSet.Next;
  end;
end;

procedure TatSetTree.ClearCheckBoxes;
begin
  FTree.ClearCheckBoxes;
end;

procedure TatSetTree.ApplyChanges;
var
  I, K: Integer;
  Node: TgsIBTreeNode;
begin
  Combo.FEditor.Text := '';
  FTargetDataSet.First;

  for I := 0 to FTree.Items.Count - 1 do
  begin
    Node := FTree.Items[I] as TgsIBTreeNode;
    if not Node.Checked then Continue;

    Combo.FEditor.Text := Combo.FEditor.Text + Node.Text;
    K := FList.IndexOf(Node.ID);
    if K <> -1 then
    begin
      FList.Delete(K);
      FNames.Delete(K);
    end;

    if I < FTree.Items.Count - 1 then
      Combo.FEditor.Text := Combo.FEditor.Text + ' ';
  end;

  for I := 0 to FList.Count - 1 do
  begin
    if Combo.FEditor.Text > '' then
      Combo.FEditor.Text := Combo.FEditor.Text + FNames[I] + ' ';
  end;

  FTargetDataSet.ApplyUpdates;
end;

procedure TatSetTree.CancelChanges;
begin
  FTargetDataSet.CancelUpdates;
  ClearCheckBoxes;

  SetupCheckBoxes;
end;

procedure TatSetTree.OnNewNode(Sender: TObject; Node: TTreeNode);
begin
  FTree.OnCheckStateChaged := nil;

  with Node as TgsIBTreeNode do
    Checked := FList.IndexOf(ID) <> - 1;

  FTree.OnCheckStateChaged := CheckedChanged;
end;

{ TatSetLookupLink }

constructor TatSetLookupLink.Create(ACombo: TatSetLookupComboBox);
begin
  inherited Create;

  FCombo := ACombo;
end;

destructor TatSetLookupLink.Destroy;
begin
  inherited Destroy;
end;

procedure TatSetLookupLink.ActiveChanged;
begin
  if Active then
    Combo.FEditor.Text := GetCrossFieldValue
  else begin
    Combo.FEditor.Text := '';
  end;

  Combo.ActiveChanged;
end;

procedure TatSetLookupLink.CheckBrowseMode;
begin
  Combo.FEditor.Text := GetCrossFieldValue;
end;

procedure TatSetLookupLink.EditingChanged;
begin
  Combo.FEditor.Text := GetCrossFieldValue;
end;

procedure TatSetLookupLink.DataSetChanged;
begin
  Combo.FEditor.Text := GetCrossFieldValue;
end;

procedure TatSetLookupLink.UpdateData;
begin
  Combo.FEditor.Text := GetCrossFieldValue;
end;

procedure TatSetLookupLink.DataSetScrolled(Distance: Integer);
begin
  Combo.FEditor.Text := GetCrossFieldValue;
  if Assigned(Combo.FList) then FreeAndNil(Combo.FList);
end;

function TatSetLookupLink.GetCrossFieldValue: String;
begin
  if Active and Assigned(DataSet.FindField(FCombo.DataField)) then
    Result := DataSet.FindField(FCombo.DataField).AsString
  else
    Result := '';
end;

function TatSetLookupLink.GetTableName(out TableName: String): Boolean;
(*var
  Parser: TsqlParser;
  TheSQL: TStringList;*)
begin
  if not Active then
  begin
    Result := False;
    Exit;
  end;

  //Origin = "Tablename"."fieldname"
  TableName := Copy(DataSet.FieldByName(Combo.DataField).Origin, 2,
    AnsiPos('.', DataSet.FieldByName(Combo.DataField).Origin) - 3);
  Result := TableName > '';  

(*  if DataSet is TIBQuery then
  begin
    with DataSet as TIBQuery do
    begin
      if Assigned(UpdateObject) and (UpdateObject is TIBUpdateSQL) then
        TheSQL := (UpdateObject as TIBUpdateSQL).ModifySQL as TStringList
      else
        TheSQL := nil;
    end;
  end else

  if DataSet is TIBCustomDataSet then
{ TODO 1 -oМиша -cпожелание : Изменено мною для поддержки IBCustomDataSet. Если есть другие варианты надо изменить }
    TheSQL := TCrackIBDataSet(DataSet).ModifySQL as TStringList
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
  end;*)
end;

function TatSetLookupLink.GetDatabase: TIBDatabase;
begin
  if DataSet is TIBCustomDataSet then
    Result := (DataSet as TIBCustomDataSet).Database
  else
    Result := nil;
end;

function TatSetLookupLink.GetTransaction: TIBTransaction;
begin
  if DataSet is TIBCustomDataSet then
    Result := (DataSet as TIBCustomDataSet).Transaction
  else
    Result := nil;
end;

function TatSetLookupLink.GetReadTransaction: TIBTransaction;
begin
  if DataSet is TIBCustomDataSet then
    Result := (DataSet as TIBCustomDataSet).ReadTransaction
  else
    Result := nil;
end;

{ TatSetLookupComboBox }

constructor TatSetLookupComboBox.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  FOldKey := -1;
  FDropDownCount := 15;

  FEditor := TEdit.Create(Self);
  with (FEditor as TEdit) do
  begin
    ReadOnly := True;
    OnKeyDown := EditKeyDown;
  end;

  InsertControl(FEditor);

  FButton := TSpeedButton.Create(Self);
  with FButton do
  begin
    Caption := '';
    OnClick := ButtonClick;
  end;
  InsertControl(FButton);

  Width := 200;
  Height := 21;

  FDataLink := TatSetLookupLink.Create(Self);

  FList := nil;

  FButton.Glyph.Handle := LoadBitmap(0, MAKEINTRESOURCE(OBM_COMBO));

  TabStop := False;

  FTableName := '';
  FRelation := nil;
end;

destructor TatSetLookupComboBox.Destroy;
begin
  FDataLink.Free;
  inherited Destroy;
end;

procedure TatSetLookupComboBox.AdjustChildren;
begin
  FEditor.SetBounds(0, 0, Width - 20, Height);
  FButton.SetBounds(Width - 20, 0, 20, Height);
end;

procedure TatSetLookupComboBox.Resize;
begin
  inherited Resize;
  AdjustChildren;
end;

procedure TatSetLookupComboBox.ActiveChanged;
begin
  if Assigned(FList) then
    FreeAndNil(FList);
end;

procedure TatSetLookupComboBox.InitializeList;
begin
  with TatSetLookupPrepare.Create(Self) do
  try
    if not FCombo.FDataLink.GetTableName(FTableName) then
    begin
      Exit;
      FRelation := nil;
    end else
      FRelation := atDatabase.Relations.ByRelationName(FTableName);

    if not Assigned(FRelation) then
      Exit;

    Prepare;
  finally
    Free;
  end;
end;

procedure TatSetLookupComboBox.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);

  if Key = VK_DOWN then
    DropDown;
end;

procedure TatSetLookupComboBox.ButtonClick(Sender: TObject);
begin
  DropDown;
end;

procedure TatSetLookupComboBox.EditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_DOWN: DropDown;
    VK_BACK:
    begin
      if not Assigned(FList) then
        InitializeList;
      if FDataLink.DataSet is TgdcBase then
      begin
        Assert(FList.FTargetDataset <> nil);
        
        FList.FTargetDataset.First;
        while not FList.FTargetDataSet.EOF do
          FList.FTargetDataSet.Delete;
        FList.ClearCheckBoxes;

        FList.FTargetDataSet.ApplyUpdates;

        if not (FDataLink.DataSet.State in [dsEdit, dsInsert]) then
          FDataLink.DataSet.Edit;

        FEditor.Text := '';

        FDataLink.DataSet.FieldByName(DataField).Assign(FDataLink.DataSet.
          FieldByName(DataField));
      end;
    end;
  end;
end;

function TatSetLookupComboBox.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TatSetLookupComboBox.SetDataSource(const Value: TDataSource);
begin
  if DataSource <> Value then
  begin
    FDataLink.DataSource := Value;
  end;
end;


procedure TatSetLookupComboBox.DropDown;
var
  P: TPoint;
  NewHeight: Integer;
  R: TRect;
begin
  Assert(Assigned(FDataLink));
  Assert(Assigned(FDataLink.DataSet));

  if FDataLink.DataSet.State = dsInsert then
  begin
    if (Owner is Tgdc_dlgG)
      and (Tgdc_dlgG(Owner).gdcObject = FDataLink.DataSet) then
    begin
      Tgdc_dlgG(Owner).actApply.Execute;
      if FDataLink.DataSet.State = dsInsert then
        exit;
    end else
    begin
      MessageBox(0,
        'Запись находится в состоянии вставки. Для добавления элементов множества необходимо сохранить ее и перевести в состояние редактирования.',
        'Внимание',
        MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
      exit;
    end;
  end;

  if not Assigned(FList) then
    InitializeList
  else if FDataLink.DataSet is TgdcBase then
  begin
    Assert(FList.FTargetDataset <> nil);

    if FOldKey <> TgdcBase(FDataLink.DataSet).ID then
    begin
      FList.FTargetDataset.First;
      while not FList.FTargetDataSet.EOF do
        FList.FTargetDataSet.Delete;
      FList.ClearCheckBoxes;
    end;
  end;

  FOldKey := TgdcBase(FDataLink.DataSet).ID;
  
  P := ClientToScreen(Point(0, 0));
  NewHeight := (FDropDownCount + 1) * Canvas.TextHeight('Ag');
  Windows.GetClientRect(GetDesktopWindow, R);

  if P.Y + NewHeight + Height < R.Bottom then
    FList.SetBounds
    (
      P.X,
      P.Y + Height,
      Width,
      NewHeight
    )
  else
    FList.SetBounds
    (
      P.X,
      P.Y - NewHeight,
      Width,
      NewHeight
    );

  if not (FDataLink.DataSet.State in [dsEdit, dsInsert]) then
    FDataLink.DataSet.Edit;

  if FList.ShowModal = mrOk then
  begin
    FDataLink.DataSet.FieldByName(DataField).Assign(FDataLink.DataSet.
      FieldByName(DataField));
  end;    
end;

procedure TatSetLookupComboBox.SetDataField(const Value: String);
begin
  if FDataField <> Value then
  begin
    FDataField := Value;
    FDataLink.UpdateData;
  end;
end;

procedure TatSetLookupComboBox.SetBitmap(const Value: TBitmap);
begin
  if Value <> nil then
    FButton.Glyph.Assign(Value);

  if not (csDesigning in ComponentState) and Assigned(FBitmap) and FBitmap.Empty then
    FButton.Glyph.Handle := LoadBitmap(0, MAKEINTRESOURCE(OBM_COMBO));
end;

end.

