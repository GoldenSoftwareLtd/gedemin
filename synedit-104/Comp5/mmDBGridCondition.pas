
{++

  Copyright (c) 1999 by Golden Software of Belarus

  Module

    mmDBGridCondition.pas

  Abstract

    A part of a visual component mmDBGrid.
    Conditional formatting setup is provided here.

  Author

    Romanovski Denis (25-01-99)

  Revisions history

    Initial  25-01-99  Dennis  Initial version.

    betal    26-01-99  Dennis  Everything Works.

    beta2    01-02-99  Dennis  Now we use all the fields. It doesn't matter if a field
                               is't visible.

    beta3    25-03-99  Dennis  Formulaes supported.

--}

unit mmDBGridCondition;

interface

uses
  Windows,        Messages,       SysUtils,       Classes,        Graphics,
  Controls,       Forms,          Dialogs,        StdCtrls,       ExtCtrls,
  mBitButton,     ExList,         DBGrids,        CheckLst,       mmComboBox,
  mmCheckBoxEx, gsMultilingualSupport;

type
  TfrmConditionalFormatting = class(TForm)
    gbConditionalFormatting: TGroupBox;
    btnAdd: TmBitButton;
    btnDelete: TmBitButton;
    lblColumn: TLabel;
    lblOperation: TLabel;
    edCondition1: TEdit;
    lblAnd: TLabel;
    edCondition2: TEdit;
    btnCancel: TmBitButton;
    btnOk: TmBitButton;
    pnlFormat: TPanel;
    lblFormat: TLabel;
    chColor: TmmCheckBoxEx;
    chFont: TmmCheckBoxEx;
    btnColor: TmBitButton;
    btnFont: TmBitButton;
    btnPrev: TmBitButton;
    btnNext: TmBitButton;
    lblCondition: TLabel;
    btnShow: TmBitButton;
    chFormula: TmmCheckBoxEx;
    cbColumn: TmmComboBox;
    cbOperation: TmmComboBox;
    gsMultilingualSupport1: TgsMultilingualSupport;

    procedure btnOkClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure chFontClick(Sender: TObject);
    procedure chColorClick(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure btnPrevClick(Sender: TObject);
    procedure btnFontClick(Sender: TObject);
    procedure btnColorClick(Sender: TObject);
    procedure cbOperationChange(Sender: TObject);
    procedure btnShowClick(Sender: TObject);

  private
    FNewConditions: TExList; // Новые условия форматирования
    FOldConditions: TExList; // Старые условия форматирования
    FGrid: TDBGrid; // Таблица, для которой устанавливаются условия форматирования

    CurrCondition: Integer; // Текущее условие

    procedure SetOldConditions(const Value: TExList);

    procedure SetCurrCondition;
    procedure EnableControls(DoEnable: Boolean);
    procedure ClearControls;
    procedure SaveCondition;
  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    // Новые условия
    property NewConditions: TExList read FNewConditions;
    // Старые условия
    property OldConditions: TExList read FOldConditions write SetOldConditions;
    // Таблица, для которой устанавливаются условия форматирования
    property Grid: TDBGrid read FGrid write FGrid;
    
  end;

var
  frmConditionalFormatting: TfrmConditionalFormatting;

implementation

{$R *.DFM}

uses mmDBGrid;

{
  ***********************
  ***   Public Part   ***
  ***********************
}

{
  Делаем начальные установки в конструкторе формочки.
}

constructor TfrmConditionalFormatting.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  FNewConditions := TExList.Create;
  FOldConditions := nil;
  
  CurrCondition := 0;
  FGrid := nil;
end;

{
  Высвобождаем память.
}

destructor TfrmConditionalFormatting.Destroy;
begin
  FNewConditions.Free;

  inherited Destroy;
end;

{
  ************************
  ***   Private Part   ***
  ************************
}

procedure TfrmConditionalFormatting.SetOldConditions(const Value: TExList);
var
  I: Integer;
begin
  // Удаляем старую информацию
  FNewConditions.Free;
  FNewConditions := TExList.Create;

  // Добавляем новые данные
  FOldConditions := Value;

  for I := 0 to FOldConditions.Count - 1 do
    FNewConditions.Add(TCondition(FOldConditions[I]).MakeCopy);

  CurrCondition := 0;
  SetCurrCondition;
end;

{
  Устанавливает параметры текущего условия в диалоге.
}

procedure TfrmConditionalFormatting.SetCurrCondition;
var
  Condition: TCondition;

  // Устанавливает названия колонок и выбирает текущую.
  procedure SetColumns;
  var
    K: Integer;
    SelIndex: Integer;
  begin
    cbColumn.Items.Clear;
    SelIndex := -1;

    for K := 0 to FGrid.DataSource.DataSet.FieldCount - 1 do
    begin
      cbColumn.Items.Add(FGrid.DataSource.DataSet.Fields[K].DisplayName);
      
      if AnsiCompareText(FGrid.DataSource.DataSet.Fields[K].FieldName,
        Condition.FieldName) = 0
      then
        SelIndex := K;
    end;

    if (SelIndex = -1) then 
    begin
      if Condition.FieldName <> '' then
        MessageDlg(TranslateText('Не найдено поле ') + Condition.FieldName + '. ' +
        TranslateText('При нажатии кнопки Готово условия могут быть сохранены неправильно!'),
        mtWarning, [mbOk], 0);
         
      SelIndex := 0;
    end;
    cbColumn.ItemIndex := SelIndex;
  end;

  // Устанавливаем операции
  procedure SetOperations;
  var
    T: TConditionOperation;
    SelIndex: Integer;
  begin
    cbOperation.Items.Clear;
    SelIndex := 0;

    for T := coEqual to coPos do
    begin
      cbOperation.Items.Add(TranslateText(ConditionText[T]));
      if Condition.Operation = T then
        SelIndex := cbOperation.Items.Count - 1;
    end;

    cbOperation.ItemIndex := SelIndex;
  end;

begin
  if FNewConditions.Count = 0 then
  begin
    ClearControls;
    EnableControls(False);
    Exit;
  end;

  Condition := FNewConditions[CurrCondition];

  SetColumns;
  SetOperations;

  edCondition1.Text := (FGrid as TmmDBGrid).ConvertFormulaToDisplays(Condition.Condition1);
  edCondition2.Text := (FGrid as TmmDBGrid).ConvertFormulaToDisplays(Condition.Condition2);

  chFormula.Checked := Condition.Formula;

  edCondition2.Visible := DoubleConditionInterval[Condition.Operation];
  lblAnd.Visible := DoubleConditionInterval[Condition.Operation];

  if Condition.UseColor then
    pnlFormat.Color := Condition.Color
  else
    pnlFormat.ParentColor := True;

  if Condition.UseFont then
    pnlFormat.Font := Condition.Font
  else
    pnlFormat.ParentFont := True;

  chColor.Checked := Condition.UseColor;
  btnColor.Enabled := Condition.UseColor;

  chFont.Checked := Condition.UseFont;
  btnFont.Enabled := Condition.UseFont;

  if Condition.UseFont or Condition.UseColor then
    pnlFormat.Caption := 'AaBbБбЯя'
  else
    pnlFormat.Caption := TranslateText('Формат не задан');

  btnNext.Enabled := CurrCondition <> FNewConditions.Count - 1;
  btnPrev.Enabled := CurrCondition <> 0;
end;

{
  Позволяет или запрещает работу с контролами редактирования текста.
}

procedure TfrmConditionalFormatting.EnableControls(DoEnable: Boolean);
begin
  cbColumn.Enabled := DoEnable;
  cbOperation.Enabled := DoEnable;

  edCondition1.Enabled := DoEnable;
  edCondition2.Enabled := DoEnable;
  chFormula.Enabled := DoEnable;

  chColor.Enabled := DoEnable;
  btnColor.Enabled := DoEnable;
  chFont.Enabled := DoEnable;
  btnFont.Enabled := DoEnable;

  btnNext.Enabled := DoEnable;
  btnPrev.Enabled := DoEnable;
  btnDelete.Enabled := DoEnable;

  btnShow.Enabled := DoEnable;

  if not DoEnable then
  begin
    pnlFormat.Caption := TranslateText('Формат не задан');
    pnlFormat.ParentColor := True;
    pnlFormat.ParentFont := True;
  end;
end;

{
  Очищает контролы от данных.
}

procedure TfrmConditionalFormatting.ClearControls;
begin
  edCondition1.Text := '';
  edCondition2.Text := '';

  chColor.Checked := False;
  chFont.Checked := False;

  pnlFormat.Caption := TranslateText('Формат не задан');
end;

{
  Сохраняет текущее условие.
}

procedure TfrmConditionalFormatting.SaveCondition;
var
  Condition: TCondition;
begin
  if FNewConditions.Count = 0 then Exit;
  Condition := FNewConditions[CurrCondition];

  Condition.FieldName := FGrid.DataSource.DataSet.Fields[cbColumn.ItemIndex].FieldName;
  Condition.Operation := OperationByIndex[cbOperation.ItemIndex];

  Condition.Condition1 := edCondition1.Text;
  Condition.Condition2 := edCondition2.Text;
  Condition.Formula := chFormula.Checked;

  Condition.UseColor := chColor.Checked;
  Condition.UseFont := chFont.Checked;

  Condition.Color := pnlFormat.Color;
  Condition.Font := pnlFormat.Font;
end;

{
  По нажатию кноки Готово производим передачу измененных данных в
  соответствующую таблицу.
}

procedure TfrmConditionalFormatting.btnOkClick(Sender: TObject);
var
  I: Integer;
  D: Double;
begin
  SaveCondition;
  for I := FOldConditions.Count - 1 downto 0 do FOldConditions.DeleteAndFree(I);

  for I := 0 to FNewConditions.Count - 1 do
  begin
    if TCondition(FNewConditions[I]).DisplayFields.Count = 0 then
    begin
      if not FGrid.DataSource.DataSet.FieldByName(TCondition(FNewConditions[I]).
        FieldName).Visible then
      begin
        MessageDlg(TranslateText('Выбранная колонка') + ' "' + TCondition(FNewConditions[I]).FieldName +
          '" ' + TranslateText('условия не является видимой в таблице!') +
          TranslateText('Необходимо выбрать отображаемое поле!'), mtWarning, [mbOk], 0);
        CurrCondition := I;
        SetCurrCondition;
        ModalResult := mrNone;
        Exit;
      end else
        TCondition(FNewConditions[I]).DisplayFields.Add(
          TCondition(FNewConditions[I]).FieldName);
    end;

    if TCondition(FNewConditions[I]).Formula then
    begin
      TCondition(FNewConditions[I]).Condition1 :=
        (FGrid as TmmDBGrid).ConvertFormulaToFields(TCondition(FNewConditions[I]).Condition1);
      TCondition(FNewConditions[I]).Condition2 :=
       (FGrid as TmmDBGrid).ConvertFormulaToFields(TCondition(FNewConditions[I]).Condition2);

      if not (FGrid as TmmDBGrid).CheckFormula(TCondition(FNewConditions[I]).Condition1, D) or
        (DoubleConditionInterval[TCondition(FNewConditions[I]).Operation] and not
        (FGrid as TmmDBGrid).CheckFormula(TCondition(FNewConditions[I]).Condition2, D)) then
      begin
        MessageDlg(TranslateText('Ошибка в формуле!'), mtWarning, [mbOk], 0);
        CurrCondition := I;
        SetCurrCondition;
        ModalResult := mrNone;
        Exit;
      end;
    end;

    FOldConditions.Add(TCondition(FNewConditions[I]).MakeCopy);
  end;
end;

{
  Производим добавление дополнительного условия.
}

procedure TfrmConditionalFormatting.btnAddClick(Sender: TObject);
begin
  SaveCondition;
  FNewConditions.Add(TCondition.Create);
  CurrCondition := FNewConditions.Count - 1;
  ClearControls;
  EnableControls(True);
  SetCurrCondition;
end;

{
  Производим удаление текущего условия.
}

procedure TfrmConditionalFormatting.btnDeleteClick(Sender: TObject);
begin
  if MessageDlg(TranslateText('Удалить условие?'), mtWarning, [mbYes, mbNo], 0) <> mrYes then Exit;

  FNewConditions.DeleteAndFree(CurrCondition);

  if FNewConditions.Count = 0 then
  begin
    ClearControls;
    EnableControls(False);
  end else begin
    if CurrCondition > FNewConditions.Count - 1 then
      CurrCondition := FNewConditions.Count - 1;
    SetCurrCondition;
  end;
end;

{
  Позволяем или запрещаем устанавливать шрифт.
}

procedure TfrmConditionalFormatting.chFontClick(Sender: TObject);
var
  Condition: TCondition;
begin
  btnFont.Enabled := chFont.Checked;
  if FNewConditions.Count = 0 then Exit;

  Condition := FNewConditions[CurrCondition];

  if btnFont.Enabled then
    pnlFormat.Font := Condition.Font
  else
    pnlFormat.ParentFont := True;

  if btnFont.Enabled or btnColor.Enabled then
    pnlFormat.Caption := 'AaBbБбЯя'
  else
    pnlFormat.Caption := TranslateText('Формат не задан');
end;

{
  Позволяем или запрещаем устанавливать цвет.
}

procedure TfrmConditionalFormatting.chColorClick(Sender: TObject);
var
  Condition: TCondition;
begin
  btnColor.Enabled := chColor.Checked;
  if FNewConditions.Count = 0 then Exit;

  Condition := FNewConditions[CurrCondition];

  if btnColor.Enabled then
    pnlFormat.Color := Condition.Color
  else
    pnlFormat.ParentColor := True;

  if btnFont.Enabled or btnColor.Enabled then
    pnlFormat.Caption := 'AaBbБбЯя'
  else
    pnlFormat.Caption := TranslateText('Формат не задан');
end;

{
  Выбираем следующее условие для редактирования.
}

procedure TfrmConditionalFormatting.btnNextClick(Sender: TObject);
begin
  SaveCondition;
  Inc(CurrCondition);
  SetCurrCondition;
end;

{
  Выбираем предудыщее условие для редактирования.
}

procedure TfrmConditionalFormatting.btnPrevClick(Sender: TObject);
begin
  SaveCondition;
  Dec(CurrCondition);
  SetCurrCondition;
end;

{
  Выбор шрифта для условия.
}

procedure TfrmConditionalFormatting.btnFontClick(Sender: TObject);
var
  Condition: TCondition;
begin
  Condition := FNewConditions[CurrCondition];

  with TFontDialog.Create(Self) do
  try
    Font := Condition.Font;

    if Execute then
    begin
      Condition.Font := Font;
      pnlFormat.Font := Condition.Font;
    end;
  finally
    Free;
  end;
end;

{
  Выбор цвета для условия.
}

procedure TfrmConditionalFormatting.btnColorClick(Sender: TObject);
var
  Condition: TCondition;
begin
  Condition := FNewConditions[CurrCondition];

  with TColorDialog.Create(Self) do
  try
    Color := Condition.Color;

    if Execute then
    begin
      Condition.Color := Color;
      pnlFormat.Color := Condition.Color;
    end;
  finally
    Free;
  end;
end;

{
  По изменению вида операции производим визуальные изменения.
}

procedure TfrmConditionalFormatting.cbOperationChange(Sender: TObject);
begin
  edCondition2.Visible := DoubleConditionIntervalInt[cbOperation.ItemIndex];
  lblAnd.Visible := DoubleConditionIntervalInt[cbOperation.ItemIndex];
end;

{
  Производим выбор полей, для которых будут отображаться визуальные изменения.
}

procedure TfrmConditionalFormatting.btnShowClick(Sender: TObject);
var
  btnOk, btnCancel: TmBitButton;
  clbFields: TCheckListBox;
  I: Integer;
  Condition: TCondition;
begin
  if FNewConditions.Count = 0 then Exit;
  Condition := FNewConditions[CurrCondition];

  with TForm.Create(Self) do
  try
    Width := 300;
    Height := 140; {80}
    Caption := TranslateText('Отображение условия в колонках:');
    BorderStyle := bsDialog;
    Position := poScreenCenter;

    Color := Self.Color;

    clbFields := TCheckListBox.Create(Self);
    clbFields.Color := Self.Color;
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

    for I := 0 to FGrid.DataSource.DataSet.FieldCount - 1 do
    begin
      clbFields.Items.Add(FGrid.DataSource.DataSet.Fields[I].DisplayName);
      if Condition.DisplayFields.IndexOf(FGrid.DataSource.DataSet.Fields[I].FieldName) >= 0 then
        clbFields.State[clbFields.Items.Count - 1] := cbChecked;
    end;

    if ShowModal = mrOk then
    begin
      Condition.DisplayFields.Clear;

      for I := 0 to clbFields.Items.Count - 1 do
      begin
        if clbFields.State[I] = cbChecked then
          Condition.DisplayFields.Add(FGrid.DataSource.DataSet.Fields[I].FieldName);
      end;
    end;
  finally
    Free;
  end;
end;

end.

