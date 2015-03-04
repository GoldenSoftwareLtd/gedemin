unit rplDBGrid;

interface

uses
  SysUtils, Classes, Controls, Grids, DBGrids, xpDBGrid, rpl_ReplicationManager_unit,
  rpl_mnRelations_unit, rpl_BaseTypes_unit, DB, rpl_ResourceString_unit,
  DBCtrls, Windows, Messages, Variants, xp_frmDropDown_unit, IBCustomDataSet,
  IBDataBase, rpl_const, xp_DBComboBoxResouceSring_unit;

type
  TrplDBGrid = class(TxpCustomDBGrid)
  private
    FRelationName: string;
    procedure SetRelationName(const Value: string);
  protected
    function GetEditStyle(ACol, ARow: Longint): TEditStyle; override;
    function  CreateEditor: TInplaceEdit; override;
  public
    property Canvas;
    property SelectedRows;
    property RelationName: string read FRelationName write SetRelationName;
  published
    property Align;
    property Anchors;
    property BiDiMode;
    property BorderStyle;
    property Color;
    property Columns stored False; //StoreColumns;
    property Constraints;
    property Ctl3D;
    property DataSource;
    property DefaultDrawing;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property FixedColor;
    property Font;
    property ImeMode;
    property ImeName;
    property Options;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property TitleFont;
    property Visible;
    property OnCellClick;
    property OnColEnter;
    property OnColExit;
    property OnColumnMoved;
    property OnDrawDataCell;  { obsolete }
    property OnDrawColumnCell;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEditButtonClick;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
    property OnTitleClick;
  end;

  TrplDBGridInplaceEdit = class(TInplaceEditList)
  private
    FDataList: TDBLookupListBox;
    FUseDataList: Boolean;
    FLookupSource: TDatasource;
    FForm: TfrmDropDown;
    FDataSet: TIBDataSet;
    FTransaction: TIBTransaction;
    FDidActivate: Boolean;
  protected
    procedure CloseUp(Accept: Boolean); override;
    procedure DoEditButtonClick; override;
    procedure DropDown; override;
    procedure UpdateContents; override;
    procedure InitDropDownBounds(ChangeClientRect: Boolean); virtual;
  public
    constructor Create(Owner: TComponent); override;
    property  DataList: TDBLookupListBox read FDataList;
  end;

procedure Register;

implementation
uses xp_frmFKDropDown_unit, xp_frmCalcDropDown_unit, xp_frmMemoDropDown_unit,
  xp_frmDateTimeDropDown_unit;
procedure Register;
begin
  RegisterComponents('Replication', [TrplDBGrid]);
end;

{ TrplDBGrid }

function TrplDBGrid.CreateEditor: TInplaceEdit;
begin
  Result := TrplDBGridInplaceEdit.Create(Self);
end;

function TrplDBGrid.GetEditStyle(ACol, ARow: Integer): TEditStyle;
var
  R: TmnRelation;
  FieldName: String;
  F: TField;
  Index: Integer;
begin
  F := GetColField(ACol - 1);
  if F <> nil then
  begin
    FieldName := F.FieldName;
//    OriginNames(F.Origin, RelationName, FieldName);
    R := ReplicationManager.Relations.FindRelation(RelationName);
    if R <> nil then
    begin
      Index := R.Fields.IndexOfField(FieldName);
      if Index > - 1 then
      begin
        Result := esPickList;
      end else
        raise Exception.Create(InvalidFieldName);
    end else
      raise Exception.Create(Format(InvalidRelationName ,[RelationName]))
  end else
    Result := inherited GetEditStyle(ACol, ARow);
end;

procedure TrplDBGrid.SetRelationName(const Value: string);
begin
  FRelationName := Value;
end;

{ TrplDBGridInplaceEdit }

procedure TrplDBGridInplaceEdit.CloseUp(Accept: Boolean);
var
  MasterField: TField;
  ListValue: Variant;
begin
  if ListVisible then
  begin
    if GetCapture <> 0 then SendMessage(GetCapture, WM_CANCELMODE, 0, 0);
    if ActiveList = DataList then
      ListValue := DataList.KeyValue
    else
      if PickList.ItemIndex <> -1 then
        ListValue := PickList.Items[Picklist.ItemIndex];
    SetWindowPos(ActiveList.Handle, 0, 0, 0, 0, 0, SWP_NOZORDER or
      SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE or SWP_HIDEWINDOW);
    ListVisible := False;
    if Assigned(FDataList) then
      FDataList.ListSource := nil;
    FLookupSource.Dataset := nil;
    Invalidate;
    if Accept then
      if ActiveList = DataList then
        with TrplDBGrid(Grid), Columns[SelectedIndex].Field do
        begin
          MasterField := DataSet.FieldByName(KeyFields);
          if MasterField.CanModify and DataLink.Edit then
            MasterField.Value := ListValue;
        end
      else
        if (not VarIsNull(ListValue)) and EditCanModify then
          with TrplDBGrid(Grid), Columns[SelectedIndex].Field do
            Text := ListValue;
  end;
end;

constructor TrplDBGridInplaceEdit.Create(Owner: TComponent);
begin
  inherited Create(Owner);
  FLookupSource := TDataSource.Create(Self);
end;

procedure TrplDBGridInplaceEdit.DoEditButtonClick;
begin
  TrplDBGrid(Grid).EditButtonClick;
end;

procedure TrplDBGridInplaceEdit.DropDown;
var
  R: TmnRelation;
  Field: TmnField;
  RelationName, FieldName: String;
  F: TField;
  Index: Integer;
  Column: TColumn;
begin
  if not ListVisible then
  begin
    with TrplDBGrid(Grid) do
      Column := Columns[SelectedIndex];

    F := Column.Field;
    RelationName := TrplDBGrid(Grid).RelationName;
    FieldName := F.FieldName;
//    OriginNames(F.Origin, RelationName, FieldName);
    R := ReplicationManager.Relations.FindRelation(RelationName);
    if R <> nil then
    begin
      Index := R.Fields.IndexOfField(FieldName);
      if Index > - 1 then
      begin
        Field := TmnField(R.Fields[Index]);
        if Field.IsForeign then
        begin
          FForm := TfrmFKDropDown.Create(Self);
          with FForm as TfrmFKDropDown do
          begin
            FTransaction := ReplDataBase.Transaction;
            if FDataSet = nil then
            begin
              FDataSet := TIBDataSet.Create(nil);
              FDataSet.Transaction := FTransaction;
            end;

            if FTransaction <> nil then
            begin
              FDidActivate := not FTransaction.InTransaction;
              if FDidActivate then
                FTransaction.StartTransaction;
            end;

            if FDataSet.Active then
              FDataSet.Close;

            FDataSet.SelectSQL.Text := Format('SELECT * FROM %s', [Field.ReferenceField.Relation.RelationName]);
            FDataSet.Open;

            KeyField := Field.ReferenceField.FieldName;
            DataSet := FDataSet;
            pCaption.Caption := ' ' + Format(DataOF, [Field.ReferenceField.Relation.RelationName]);
          end;
        end else
        begin
          case Field.FieldType of
            tfInteger, tfInt64, tfSmallInt, tfQuard, tfD_Float,
            tfDouble, tfFloat:
            begin
              FForm := TfrmCalcDropDown.Create(Self);
              TfrmCalcDropDown(FForm).EditWindow := Handle;
            end;
            tfChar, tfCString, tfVarChar:
            begin
              FForm := TfrmMemoDropDown.Create(Self);
            end;
            tfDate:
            begin
              FForm := TfrmDateTimeDropDown.Create(Self);
            end;
            tfTime:
            begin
              FForm := TfrmDateTimeDropDown.Create(Self);
            end;
            tfTimeStamp:
            begin
              FForm := TfrmDateTimeDropDown.Create(Self);
            end;
            tfBlob:
            begin
              if Field.FieldSubType = 1 then
                FForm := TfrmMemoDropDown.Create(Self)
              else
                FForm := TfrmDropDown.Create(Self);
            end;
          end;
        end;

        InitDropDownBounds(True);
        FForm.Value := F.Value;
        if FForm.ShowModal = mrOk then
        begin
          TrplDBGrid(Grid).DataLink.Edit;
          F.Value := FForm.Value;
          FreeAndNil(FForm);
        end;
      end else
        inherited;
    end else
      inherited;
  end;
end;

procedure TrplDBGridInplaceEdit.InitDropDownBounds(
  ChangeClientRect: Boolean);
var
  R: TRect;
begin
  R := GetClientRect;
  R.TopLeft := ClientToScreen(R.TopLeft);
  R.BottomRight := ClientToScreen(R.BottomRight);

  FForm.InitBounds(R.left, R.Top, R.Right - R.Left, R.Bottom - R.Top, ChangeClientRect);
end;

procedure TrplDBGridInplaceEdit.UpdateContents;
var
  Column: TColumn;
begin
  inherited UpdateContents;
  if FUseDataList then
  begin
    if FDataList = nil then
    begin
      FDataList := TPopupDataList.Create(Self);
      FDataList.Visible := False;
      FDataList.Parent := Self;
      FDataList.OnMouseUp := ListMouseUp;
    end;
    ActiveList := FDataList;
  end;
  with TrplDBGrid(Grid) do
    Column := Columns[SelectedIndex];
  Self.ReadOnly := Column.ReadOnly;
  Font.Assign(Column.Font);
  ImeMode := Column.ImeMode;
  ImeName := Column.ImeName;
end;

end.
