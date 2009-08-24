
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
    FGrid: TmmDBGrid; // Таблица, для которой производятся установки.
    TableFont, TitleFont: TFont; // Шрифты таблицы, заглавий
    FNewConditions: TExList; // Список новых условий форматирования
    FVisibleColumns: TStringList; // Список видимых колонок

    procedure PrepeareOptions;
    procedure ReturnOptions;
    procedure SetDefault;

    procedure SetGrid(const Value: TmmDBGrid);
    
  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    // Таблица, которой делаются установки
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
  Делаем начальные установки.
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
  Высвобождаем память, делаем конечные установки.
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
  Приготавливаем установки пользователя.
}

procedure TfrmDBGridOptions.PrepeareOptions;
var
  I: Integer;
  D: TDataSet;
begin
  if FGrid = nil then Exit;

  // Установки для таблицы
  ccbTableColor.Color := FGrid.Color;
  ccbSelectedColor.Color := FGrid.ColorSelected;
  btnTableFont.Enabled := True;
  TableFont.Assign(FGrid.Font);

  // Установки для заглавий
  ccbTitleColor.Color := FGrid.FixedColor;
  btnTitleFont.Enabled := True;
  TitleFont.Assign(FGrid.TitleFont);

  // Установки для полосатости
  cbUseStripes.Checked := FGrid.Striped;

  ccbStripeOne.Enabled := FGrid.Striped;
  ccbStripeOne.Color := FGrid.StripeOne;

  ccbStripeTwo.Enabled := FGrid.Striped;
  ccbStripeTwo.Color := FGrid.StripeTwo;

  // Только если подключена база данных
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

    // Установки для условного форматирования
    cbUseConditionalFormatting.Checked := FGrid.ConditionalFormatting;
    btnChooseConditionalFormatting.Enabled := FGrid.ConditionalFormatting;

    // Копируем все условные форматы во временный список
    for I := 0 to FGrid.Conditions.Count - 1 do
      FNewConditions.Add(TCondition(FGrid.Conditions[I]).MakeCopy);

    // Создаем список видимых колонок таблицы
    FVisibleColumns.Clear;

    for I := 0 to FGrid.DataSource.DataSet.FieldCount - 1 do
      if FGrid.DataSource.DataSet.Fields[I].Visible then
        FVisibleColumns.Add(FGrid.DataSource.DataSet.Fields[I].FieldName);
  end;

  // Другие установки
  cbScaleColumns.Checked := FGrid.ScaleColumns;
  cbDefault.Checked := False;
end;

{
  Возвращаем новые установки пользователю.
}

procedure TfrmDBGridOptions.ReturnOptions;
var
  I: Integer;
begin
  if FGrid = nil then Exit;

  // Установки для условного форматирования
  FGrid.ConditionalFormatting := cbUseConditionalFormatting.Checked;
  for I := 0 to FGrid.Conditions.Count - 1 do FGrid.Conditions.Delete(0);
  
  // Возвращаем все условные форматы
  for I := 0 to FNewConditions.Count - 1 do
    FGrid.Conditions.Add(TCondition(FNewConditions[I]).MakeCopy);

  // Установка видимых колонок
  if Assigned(FGrid.DataSource) and Assigned(FGrid.DataSource.DataSet) then
    for I := 0 to FGrid.DataSource.DataSet.FieldCount - 1 do
      FGrid.DataSource.DataSet.Fields[I].Visible :=
        FVisibleColumns.IndexOf(FGrid.DataSource.DataSet.Fields[I].FieldName) > -1;

  FGrid.PrepareConditions;
  
  // Другие установки
  FGrid.ScaleColumns := cbScaleColumns.Checked;

  // Если нужно произвести установки по умолчанию.
  if cbDefault.Checked then
  begin
    SetDefault;
    Exit;
  end;

  // Установки для таблицы
  FGrid.Color := ccbTableColor.Color;
  FGrid.ColorSelected := ccbSelectedColor.Color;
  FGrid.Font := TableFont;

  for I := 0 to FGrid.Columns.Count - 1 do
    FGrid.Columns[I].Font := FGrid.Font;

  // Установки для заглавий
  FGrid.FixedColor := ccbTitleColor.Color;
  FGrid.TitleFont := TitleFont;

  for I := 0 to FGrid.Columns.Count - 1 do
    FGrid.Columns[I].Title.Font := FGrid.TitleFont;

  // Установки для полосатости
  FGrid.Striped := cbUseStripes.Checked;
  if cbUseStripes.Checked then FGrid.StripeOne := ccbStripeOne.Color;
  if cbUseStripes.Checked then FGrid.StripeTwo := ccbStripeTwo.Color;
  
  FGrid.Invalidate;
end;

{
  Возвращает установки по умолчанию.
}

procedure TfrmDBGridOptions.SetDefault;
var
  I: Integer;
begin
  if Assigned(FGrid.OnReadDefaults) then
    FGrid.OnReadDefaults(FGrid)
  else begin
    // Установки для таблицы
    FGrid.Color := clWindow;
    FGrid.ColorSelected := $009CDFF7;

    FGrid.Font.Name := 'Tahoma';
    FGrid.Font.Style := [];
    FGrid.Font.Charset := RUSSIAN_CHARSET;
    FGrid.Font.Size := 8;
    FGrid.Font.Color := clBlack;
    for I := 0 to FGrid.Columns.Count - 1 do
      FGrid.Columns[I].Font := FGrid.Font;

    // Установки для заглавий
    FGrid.FixedColor := clBtnFace;
    FGrid.TitleFont := FGrid.Font;
    for I := 0 to FGrid.Columns.Count - 1 do
      FGrid.Columns[I].Title.Font := FGrid.TitleFont;

    // Установки для полосатости
    FGrid.Striped := True;

    FGrid.StripeOne := $00D6E7E7;
    FGrid.StripeTwo := $00E7F3F7;
  
    FGrid.Invalidate;
  end;  
end;

{
  Устанавливаем табличу и изымает из нее все текущие установки.
}

procedure TfrmDBGridOptions.SetGrid(const Value: TmmDBGrid);
begin
  FGrid := Value;
  Color := FGrid.ColorDialogs;
  PrepeareOptions;
end;

{
  По нажатию кнопки Готово производим запись всех установок таблицы.
}

procedure TfrmDBGridOptions.btnOkClick(Sender: TObject);
begin
  ReturnOptions;
end;

{
  Устанавливается шрифт для таблицы.
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
  Устанавливает шрифт для заголовков.
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
  Вызывает диалог редактирования условных форматов.
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
  Производит выбор видимых колонок.
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
    Caption := TranslateText('Отображаемые колонки:');
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
    btnOk.Caption := TranslateText('&Готово');
    btnOk.ModalResult := mrOk;
    btnOk.Default := True;

    btnCancel := TmBitButton.Create(Self);
    btnCancel.Left := 114;
    btnCancel.Top := 90;
    btnCancel.Width := 100;
    btnCancel.Height := 20;
    btnCancel.Caption := TranslateText('&Отменить');
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
  Разрешаем либо запрещаем изменять цвета полос
}

procedure TfrmDBGridOptions.cbUseStripesClick(Sender: TObject);
begin
  ccbStripeOne.Enabled := cbUseStripes.Checked;
  ccbStripeTwo.Enabled := cbUseStripes.Checked;
end;

{
  Разрешаем либо запрещаем задавать условные форматы
}

procedure TfrmDBGridOptions.cbUseConditionalFormattingClick(
  Sender: TObject);
begin
  btnChooseConditionalFormatting.Enabled := cbUseConditionalFormatting.Checked;
end;

end.

