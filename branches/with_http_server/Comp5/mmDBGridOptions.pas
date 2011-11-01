
{++

  Copyright (c) 1999 by Golden Software of Belarus

  Module

    mmDBGridCondition.pas

  Abstract

    A part of a visual component mmDBGrid.
    Common grid options setup.

  Author

    Romanovski Denis (25-01-99)

  Revisions history

    Initial  16-02-99  Dennis  Initial version.

--}

unit mmDBGridOptions;

interface

uses
  Windows,        Messages,       SysUtils,       Classes,        Graphics,
  Controls,       Forms,          Dialogs,        mmDBGrid,       mBitButton,
  ExtCtrls,       Grids,          StdCtrls,       ColCB,
  ExList,         mmCheckBoxEx,   gsMultilingualSupport;

type
  TfrmDBGridOptions = class(TForm)
    btnOk: TmBitButton;
    btnCancel: TmBitButton;
    gbOptions: TGroupBox;
    pnlOptions: TPanel;
    gbTitleOptions: TGroupBox;
    lblTitleColor: TLabel;
    ccbTitleColor: TColorComboBox;
    btnTitleFont: TmBitButton;
    gbTableOptions: TGroupBox;
    lblTableColor: TLabel;
    lblSelectedColor: TLabel;
    btnTableFont: TmBitButton;
    ccbTableColor: TColorComboBox;
    ccbSelectedColor: TColorComboBox;
    gbStripeOptions: TGroupBox;
    lblStripeOne: TLabel;
    lblStripeTwo: TLabel;
    ccbStripeOne: TColorComboBox;
    ccbStripeTwo: TColorComboBox;
    cbUseStripes: TmmCheckBoxEx;
    gbConditionalFormattingOptions: TGroupBox;
    btnChooseConditionalFormatting: TmBitButton;
    cbUseConditionalFormatting: TmmCheckBoxEx;
    cbScaleColumns: TmmCheckBoxEx;
    btnChooseColumns: TmBitButton;
    cbDefault: TmmCheckBoxEx;
    gsMultilingualSupport1: TgsMultilingualSupport;

    procedure btnOkClick(Sender: TObject);
    procedure btnTableFontClick(Sender: TObject);
    procedure btnTitleFontClick(Sender: TObject);
    procedure btnChooseConditionalFormattingClick(Sender: TObject);
    procedure btnChooseColumnsClick(Sender: TObject);
    procedure cbUseStripesClick(Sender: TObject);
    procedure cbUseConditionalFormattingClick(Sender: TObject);

  private
    FGrid: TmmDBGrid; // �������, ��� ������� ������������ ���������.
    TableFont, TitleFont: TFont; // ������ �������, ��������
    FNewConditions: TExList; // ������ ����� ������� ��������������
    FVisibleColumns: TStringList; // ������ ������� �������

    procedure PrepeareOptions;
    procedure ReturnOptions;
    procedure SetDefault;

    procedure SetGrid(const Value: TmmDBGrid);
    
  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    // �������, ������� �������� ���������
    property SetupGrid: TmmDBGrid read FGrid write SetGrid;

  end;

var
  frmDBGridOptions: TfrmDBGridOptions;

implementation

{$R *.DFM}

uses mmDBGridCondition, mmDBGridTree, CheckLst, DB, DBTables;

{
  -----------------------------------
  ---   TfrmDBGridOptions Class   ---
  -----------------------------------
}

{
  ***********************
  ***   Public Part   ***
  ***********************
}

{
  ������ ��������� ���������.
}

constructor TfrmDBGridOptions.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  FGrid := nil;

  TableFont := TFont.Create;
  TitleFont := TFont.Create;
  
  FNewConditions := TExList.Create;
  FVisibleColumns := TStringList.Create;
end;

{
  ������������ ������, ������ �������� ���������.
}

destructor TfrmDBGridOptions.Destroy;
begin
  TableFont.Free;
  TitleFont.Free;

  FNewConditions.Free;
  FVisibleColumns.Free;

  inherited Destroy;
end;

{
  �������������� ��������� ������������.
}

procedure TfrmDBGridOptions.PrepeareOptions;
var
  I: Integer;
  D: TDataSet;
begin
  if FGrid = nil then Exit;

  // ��������� ��� �������
  ccbTableColor.Color := FGrid.Color;
  ccbSelectedColor.Color := FGrid.ColorSelected;
  btnTableFont.Enabled := True;
  TableFont.Assign(FGrid.Font);

  // ��������� ��� ��������
  ccbTitleColor.Color := FGrid.FixedColor;
  btnTitleFont.Enabled := True;
  TitleFont.Assign(FGrid.TitleFont);

  // ��������� ��� �����������
  cbUseStripes.Checked := FGrid.Striped;

  ccbStripeOne.Enabled := FGrid.Striped;
  ccbStripeOne.Color := FGrid.StripeOne;

  ccbStripeTwo.Enabled := FGrid.Striped;
  ccbStripeTwo.Color := FGrid.StripeTwo;

  // ������ ���� ���������� ���� ������
  if Assigned(FGrid.DataSource) and Assigned(FGrid.DataSource.DataSet) then
  begin
    if FGrid is TmmDBGridTree then
      D := (FGrid as TmmDBGridTree).DataSource.DataSet
    else
      D := FGrid.DataSource.DataSet;

    if D is TTable then
      Caption := Caption + ' (' + (D as TTable).TableName + ')'
    else
      Caption := Caption + ' (' + D.Name + ')';

    // ��������� ��� ��������� ��������������
    cbUseConditionalFormatting.Checked := FGrid.ConditionalFormatting;
    btnChooseConditionalFormatting.Enabled := FGrid.ConditionalFormatting;

    // �������� ��� �������� ������� �� ��������� ������
    for I := 0 to FGrid.Conditions.Count - 1 do
      FNewConditions.Add(TCondition(FGrid.Conditions[I]).MakeCopy);

    // ������� ������ ������� ������� �������
    FVisibleColumns.Clear;

    for I := 0 to FGrid.DataSource.DataSet.FieldCount - 1 do
      if FGrid.DataSource.DataSet.Fields[I].Visible then
        FVisibleColumns.Add(FGrid.DataSource.DataSet.Fields[I].FieldName);
  end;

  // ������ ���������
  cbScaleColumns.Checked := FGrid.ScaleColumns;
  cbDefault.Checked := False;
end;

{
  ���������� ����� ��������� ������������.
}

procedure TfrmDBGridOptions.ReturnOptions;
var
  I: Integer;
begin
  if FGrid = nil then Exit;

  // ��������� ��� ��������� ��������������
  FGrid.ConditionalFormatting := cbUseConditionalFormatting.Checked;
  for I := 0 to FGrid.Conditions.Count - 1 do FGrid.Conditions.Delete(0);
  
  // ���������� ��� �������� �������
  for I := 0 to FNewConditions.Count - 1 do
    FGrid.Conditions.Add(TCondition(FNewConditions[I]).MakeCopy);

  // ��������� ������� �������
  if Assigned(FGrid.DataSource) and Assigned(FGrid.DataSource.DataSet) then
    for I := 0 to FGrid.DataSource.DataSet.FieldCount - 1 do
      FGrid.DataSource.DataSet.Fields[I].Visible :=
        FVisibleColumns.IndexOf(FGrid.DataSource.DataSet.Fields[I].FieldName) > -1;

  FGrid.PrepareConditions;
  
  // ������ ���������
  FGrid.ScaleColumns := cbScaleColumns.Checked;

  // ���� ����� ���������� ��������� �� ���������.
  if cbDefault.Checked then
  begin
    SetDefault;
    Exit;
  end;

  // ��������� ��� �������
  FGrid.Color := ccbTableColor.Color;
  FGrid.ColorSelected := ccbSelectedColor.Color;
  FGrid.Font := TableFont;

  for I := 0 to FGrid.Columns.Count - 1 do
    FGrid.Columns[I].Font := FGrid.Font;

  // ��������� ��� ��������
  FGrid.FixedColor := ccbTitleColor.Color;
  FGrid.TitleFont := TitleFont;

  for I := 0 to FGrid.Columns.Count - 1 do
    FGrid.Columns[I].Title.Font := FGrid.TitleFont;

  // ��������� ��� �����������
  FGrid.Striped := cbUseStripes.Checked;
  if cbUseStripes.Checked then FGrid.StripeOne := ccbStripeOne.Color;
  if cbUseStripes.Checked then FGrid.StripeTwo := ccbStripeTwo.Color;
  
  FGrid.Invalidate;
end;

{
  ���������� ��������� �� ���������.
}

procedure TfrmDBGridOptions.SetDefault;
var
  I: Integer;
begin
  if Assigned(FGrid.OnReadDefaults) then
    FGrid.OnReadDefaults(FGrid)
  else begin
    // ��������� ��� �������
    FGrid.Color := clWindow;
    FGrid.ColorSelected := $009CDFF7;

    FGrid.Font.Name := 'Tahoma';
    FGrid.Font.Style := [];
    FGrid.Font.Charset := RUSSIAN_CHARSET;
    FGrid.Font.Size := 8;
    FGrid.Font.Color := clBlack;
    for I := 0 to FGrid.Columns.Count - 1 do
      FGrid.Columns[I].Font := FGrid.Font;

    // ��������� ��� ��������
    FGrid.FixedColor := clBtnFace;
    FGrid.TitleFont := FGrid.Font;
    for I := 0 to FGrid.Columns.Count - 1 do
      FGrid.Columns[I].Title.Font := FGrid.TitleFont;

    // ��������� ��� �����������
    FGrid.Striped := True;

    FGrid.StripeOne := $00D6E7E7;
    FGrid.StripeTwo := $00E7F3F7;
  
    FGrid.Invalidate;
  end;  
end;

{
  ������������� ������� � ������� �� ��� ��� ������� ���������.
}

procedure TfrmDBGridOptions.SetGrid(const Value: TmmDBGrid);
begin
  FGrid := Value;
  Color := FGrid.ColorDialogs;
  PrepeareOptions;
end;

{
  �� ������� ������ ������ ���������� ������ ���� ��������� �������.
}

procedure TfrmDBGridOptions.btnOkClick(Sender: TObject);
begin
  ReturnOptions;
end;

{
  ��������������� ����� ��� �������.
}

procedure TfrmDBGridOptions.btnTableFontClick(Sender: TObject);
begin
  with TFontDialog.Create(Self) do
  try
    Font.Assign(TableFont);
    if Execute then TableFont.Assign(Font);
  finally
    Free;
  end;
end;

{
  ������������� ����� ��� ����������.
}

procedure TfrmDBGridOptions.btnTitleFontClick(Sender: TObject);
begin
  with TFontDialog.Create(Self) do
  try
    Font.Assign(TitleFont);
    if Execute then TitleFont.Assign(Font);
  finally
    Free;
  end;
end;

{
  �������� ������ �������������� �������� ��������.
}

procedure TfrmDBGridOptions.btnChooseConditionalFormattingClick(
  Sender: TObject);
begin
  with TfrmConditionalFormatting.Create(Self) do
  try
    Grid := FGrid;
    OldConditions := FNewConditions;
    Color := FGrid.ColorDialogs;

    ShowModal;
  finally
    Free;
  end;
end;

{
  ���������� ����� ������� �������.
}

procedure TfrmDBGridOptions.btnChooseColumnsClick(Sender: TObject);
var
  btnOk, btnCancel: TmBitButton;
  clbFields: TCheckListBox;
  I: Integer;
begin
  with TForm.Create(Self) do
  try
    Width := 300;
    Height := 140; {80}
    Caption := TranslateText('������������ �������:');
    BorderStyle := bsDialog;
    Position := poScreenCenter;

    Color := FGrid.ColorDialogs;

    clbFields := TCheckListBox.Create(Self);
    clbFields.Color := FGrid.ColorDialogs;
    clbFields.ParentCtl3D := False;
    clbFields.Ctl3D := False;
    clbFields.Left := 4;
    clbFields.Top := 4;
    clbFields.Width := 286;
    clbFields.Height := 80;

    btnOk := TmBitButton.Create(Self);
    btnOk.Left := 4;
    btnOk.Top := 90;
    btnOk.Width := 100;
    btnOk.Height := 20;
    btnOk.Caption := TranslateText('&������');
    btnOk.ModalResult := mrOk;
    btnOk.Default := True;

    btnCancel := TmBitButton.Create(Self);
    btnCancel.Left := 114;
    btnCancel.Top := 90;
    btnCancel.Width := 100;
    btnCancel.Height := 20;
    btnCancel.Caption := TranslateText('&��������');
    btnCancel.ModalResult := mrCancel;
    btnCancel.Cancel := True;

    InsertControl(clbFields);
    InsertControl(btnOk);
    InsertControl(btnCancel);

    for I := 0 to FGrid.DataSource.DataSet.Fields.Count - 1 do
      if not (FGrid.DataSource.DataSet.Fields[I].DataType in [ftUnknown, ftBCD,
        ftBytes, ftVarBytes, ftBlob, ftMemo, ftGraphic,
        ftFmtMemo, ftParadoxOle, ftDBaseOle, ftTypedBinary, ftCursor,
        ftADT, ftArray, ftReference, ftDataSet]) then
      begin
        clbFields.Items.Add(FGrid.DataSource.DataSet.Fields[I].DisplayLabel);
        clbFields.Items.Objects[clbFields.Items.Count - 1] := Pointer(I);

        if FVisibleColumns.IndexOf(FGrid.DataSource.DataSet.Fields[I].FieldName) > -1 then
          clbFields.State[clbFields.Items.Count - 1] := cbChecked;
      end;

    if ShowModal = mrOk then
    begin
      FVisibleColumns.Clear;
      
      for I := 0 to clbFields.Items.Count - 1 do
        if clbFields.State[I] = cbChecked then
          FVisibleColumns.Add(FGrid.DataSource.DataSet.
            Fields[Integer(clbFields.Items.Objects[I])].FieldName);
    end;

  finally
    Free;
  end;
end;

{
  ��������� ���� ��������� �������� ����� �����
}

procedure TfrmDBGridOptions.cbUseStripesClick(Sender: TObject);
begin
  ccbStripeOne.Enabled := cbUseStripes.Checked;
  ccbStripeTwo.Enabled := cbUseStripes.Checked;
end;

{
  ��������� ���� ��������� �������� �������� �������
}

procedure TfrmDBGridOptions.cbUseConditionalFormattingClick(
  Sender: TObject);
begin
  btnChooseConditionalFormatting.Enabled := cbUseConditionalFormatting.Checked;
end;

end.

