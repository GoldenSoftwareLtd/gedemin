{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    ctl_dlgSetupReceipt_unit.pas

  Abstract

    Dialog window.

  Author

    Denis Romanosvki  (01.04.2001)

  Revisions history

    1.0    01.04.2001    Denis    Initial version.


--}

unit ctl_dlgSetupReceipt_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_dlgG_unit, ActnList, StdCtrls, Grids, DBGrids, gsDBGrid, gsIBGrid,
  ComCtrls, ToolWin, ExtCtrls, Db, IBCustomDataSet, IBDatabase, IBSQL,
  Contnrs,  xCalc, ctl_CattleConstants_unit, gsIBLookupComboBox;

type
  TCalculation = class;
  TCalculationList = class;

  Tctl_dlgSetupReceipt = class(Tgd_dlgG)
    pnlMain: TPanel;
    cbMain: TControlBar;
    tbMain: TToolBar;
    tbtNew: TToolButton;
    tbtEdit: TToolButton;
    tbtDelete: TToolButton;
    tbtDuplicate: TToolButton;
    dsCalculation: TDataSource;
    ibdsCalculation: TIBDataSet;
    ibtrCalculation: TIBTransaction;
    sgCalculate: TStringGrid;
    ibsqlCalculate: TIBSQL;
    cbVariables: TComboBox;
    ToolButton1: TToolButton;
    Calculator: TxFoCal;
    Label1: TLabel;
    iblcTransaction: TgsIBLookupComboBox;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

    procedure actOkExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure sgCalculateSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure cbVariablesClick(Sender: TObject);

  private
    FCalculations: TCalculationList;

    procedure PrepareCalculationGrid;
    procedure UpdateCalculationsList;

    function FindCalculation(LShortName: String): TCalculation;
    function FindTotalCalculation: TCalculation;

  protected
    procedure CheckConsistency;

  public
    function Execute: Boolean;

  end;

  Ectl_dlgSetupReceipt = class(Exception);


  TCalculation = class
  private
    FFieldName: String;
    FVariableName: String;
    FFormula: String;
    FDescription: String;

    FCalculation: Currency;

  public
    constructor Create;
    destructor Destroy; override;

    property FieldName: String read FFieldName;
    property VariableName: String read FVariableName;
    property Formula: String read FFormula;
    property Description: String read FDescription;
    property Calculation: Currency read FCalculation write FCalculation;

  end;


  TCalculationList = class
  private
    FCalculations: TObjectList;

    function GetItem(Index: Integer): TCalculation;
    function GetCount: Integer;

  protected

  public
    constructor Create;
    destructor Destroy; override;

    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream);

    property Count: Integer read GetCount;
    property Item[Index: Integer]: TCalculation read GetItem; default;

  end;


var
  ctl_dlgSetupReceipt: Tctl_dlgSetupReceipt;

implementation

uses
  dmDataBase_unit, gsStorage, Storages, at_classes;

{$R *.DFM}

function ChangeSpaces(const Text: String): String;
var
  I: Integer;
begin
  Result := Text;
  for I := 1 to Length(Result) do
    if Result[I] = ' ' then
      Result[I] := '_';
end;

{ TCalculation }

constructor TCalculation.Create;
begin
  FFieldName := '';
  FVariableName := '';
  FFormula := '';
  FDescription := '';

  FCalculation := 0;
end;

destructor TCalculation.Destroy;
begin
  inherited;
end;


{ Tctl_dlgSetupReceipt }

procedure Tctl_dlgSetupReceipt.FormCreate(Sender: TObject);
begin
  inherited;

  FCalculations := TCalculationList.Create;

  sgCalculate.Cells[0, 0] := '№';
  sgCalculate.Cells[1, 0] := 'Поле:';
  sgCalculate.Cells[2, 0] := 'Формула расчета';
  sgCalculate.Cells[3, 0] := 'Описание';

  cbVariables.ItemIndex := 0;
end;

procedure Tctl_dlgSetupReceipt.FormDestroy(Sender: TObject);
begin
  FCalculations.Free;

  inherited;
end;

procedure Tctl_dlgSetupReceipt.actOkExecute(Sender: TObject);
begin
  inherited;

  CheckConsistency;
end;

procedure Tctl_dlgSetupReceipt.actCancelExecute(Sender: TObject);
begin
  inherited;
//
end;

function Tctl_dlgSetupReceipt.Execute: Boolean;
var
  F: TgsStorageFolder;
  ReadStream: TStream;
  WriteStream: TMemoryStream;
begin

  //
  //  Считвание формулы из потока

  F := GlobalStorage.OpenFolder(FOLDER_CATTLE_SETTINGS, True);
  ReadStream := TMemoryStream.Create;
  try


    F.ReadStream(VALUE_RECEIPT_FORMULA, ReadStream);

    if Assigned(ReadStream) then
      FCalculations.LoadFromStream(ReadStream);

    iblcTransaction.CurrentKey := F.ReadString(VALUE_RECEIPT_TRANSACTION, '');
  finally
    GlobalStorage.CloseFolder(F, True);
    ReadStream.Free;
  end;

  //
  //  Настройка

  if sgCalculate.Col = 1 then
    sgCalculate.Options := sgCalculate.Options - [goEditing{, goAlwaysShowEditor}]
  else
    sgCalculate.Options := sgCalculate.Options + [goEditing{, goAlwaysShowEditor}];

  PrepareCalculationGrid;

  //
  //  Запуск окна

  Result := ShowModal = mrOk;

  //
  //  Сохранение настроек

  if Result then
  begin
    UpdateCalculationsList;

    //
    //  Сохранение формулы в поток

    F := GlobalStorage.OpenFolder(FOLDER_CATTLE_SETTINGS, True);
    try
      WriteStream := TMemoryStream.Create;

      try
        FCalculations.SaveToStream(WriteStream);
        F.WriteStream(VALUE_RECEIPT_FORMULA, WriteStream);
        F.WriteString(VALUE_RECEIPT_TRANSACTION, iblcTransaction.CurrentKey);
      finally
        WriteStream.Free;
      end;
    finally
      GlobalStorage.CloseFolder(F, True);
    end;
  end;
end;

procedure Tctl_dlgSetupReceipt.PrepareCalculationGrid;
var
  I, K: Integer;
  Relation: TatRelation;
  Field: TatRelationField;
  Calculation: TCalculation;
begin
  //
  //  Создаем таблицу расчета

  Relation := atDatabase.Relations.ByRelationName('CTL_RECEIPT');

  if not Assigned(Relation) then
    raise Ectl_dlgSetupReceipt.Create('Relation CTL_RECEIPT not found!');

  K := 0;

  for I := 0 to Relation.RelationFields.Count - 1 do
  begin
    Field := Relation.RelationFields[I];
    if
      not Field.IsUserDefined
        or
      ([Field.Field.FieldType] * [ftFloat, ftBCD] = [])
    then
      Continue;

    if sgCalculate.RowCount - 2 < K then
      sgCalculate.RowCount := sgCalculate.RowCount + 1;

    sgCalculate.Cells[0, K + 1] := IntToStr(K + 1);
    sgCalculate.Cells[1, K + 1] := ChangeSpaces(Field.LShortName);
    sgCalculate.Cells[3, K + 1] := Field.Description;

    Calculation := FindCalculation(ChangeSpaces(Field.LShortName));

    if Assigned(Calculation) then
    begin
      sgCalculate.Cells[2, K + 1] := Calculation.FFormula;
      sgCalculate.Cells[3, K + 1] := Calculation.FDescription;
    end else
    begin
      Calculation := TCalculation.Create;
      FCalculations.FCalculations.Add(Calculation);

      Calculation.FVariableName := sgCalculate.Cells[1, K + 1];
      Calculation.FFormula := sgCalculate.Cells[2, K + 1];
      Calculation.FDescription := sgCalculate.Cells[3, K + 1];
    end;

    Calculation.FFieldName := Field.FieldName;

    Inc(K);
  end;

  //
  //  Итоговая строчка:

  if sgCalculate.RowCount - 2 < K then
    sgCalculate.RowCount := sgCalculate.RowCount + 1;

  sgCalculate.Cells[1, K + 1] := 'ИТОГО:';
  sgCalculate.Cells[3, K + 1] := 'ИТОГОВАЯ СУММА НА КВИТАНЦИИ';

  Calculation := FindTotalCalculation;
  if Assigned(Calculation) then
  begin
    sgCalculate.Cells[2, K + 1] := Calculation.FFormula;
    sgCalculate.Cells[3, K + 1] := Calculation.FDescription;
  end else begin
    Calculation := TCalculation.Create;
    FCalculations.FCalculations.Add(Calculation);

    Calculation.FFieldName := '';
    Calculation.FVariableName := sgCalculate.Cells[1, K + 1];
    Calculation.FFormula := sgCalculate.Cells[2, K + 1];
    Calculation.FDescription := sgCalculate.Cells[3, K + 1];
  end;
end;

procedure Tctl_dlgSetupReceipt.sgCalculateSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
  if (ACol = 1) or (sgCalculate.Cells[1, ARow] = '') then
    sgCalculate.Options := sgCalculate.Options - [goEditing{, goAlwaysShowEditor}]
  else
    sgCalculate.Options := sgCalculate.Options + [goEditing{, goAlwaysShowEditor}];
end;

function Tctl_dlgSetupReceipt.FindCalculation(
  LShortName: String): TCalculation;
var
  I: Integer;
begin
  for I := 0 to FCalculations.Count - 1 do
    if AnsiCompareText((FCalculations[I] as TCalculation).VariableName,
      LShortName) = 0 then
    begin
      Result := FCalculations[I] as TCalculation;
      Exit;
    end;

  Result := nil;
end;

procedure Tctl_dlgSetupReceipt.UpdateCalculationsList;
var
  I: Integer;
  Calculation: TCalculation;
  NewList: TObjectList;
begin
  NewList := TObjectList.Create(False);

  try
    //
    //  Сохраняем расчет

    for I := 1 to sgCalculate.RowCount - 1 do
    begin
      Calculation := FindCalculation(sgCalculate.Cells[1, I]);

      if Assigned(Calculation) then
      begin
        FCalculations.FCalculations.OwnsObjects := False;
        NewList.Add(Calculation);
        FCalculations.FCalculations.Remove(Calculation);
        FCalculations.FCalculations.OwnsObjects := True;

        Calculation.FVariableName := sgCalculate.Cells[1, I];
        Calculation.FFormula := sgCalculate.Cells[2, I];
        Calculation.FDescription := sgCalculate.Cells[3, I];
      end else

      if sgCalculate.Cells[1, I] > '' then
      begin
        Calculation := TCalculation.Create;
        NewList.Add(Calculation);

        Calculation.FVariableName := sgCalculate.Cells[1, I];
        Calculation.FFormula := sgCalculate.Cells[2, I];
        Calculation.FDescription := sgCalculate.Cells[3, I];
      end;

    end;

    //
    //  Сохраняем итого

    Calculation := FindTotalCalculation;
    if Assigned(Calculation) then
    begin
      FCalculations.FCalculations.OwnsObjects := False;
      NewList.Add(Calculation);
      FCalculations.FCalculations.Remove(Calculation);
      FCalculations.FCalculations.OwnsObjects := True;
    end;

    //
    //  Остальное удаляем

    FCalculations.FCalculations.Clear;
    while NewList.Count > 0 do
      FCalculations.FCalculations.Add(NewList.Extract(NewList[0]));

  finally
    NewList.Free;
  end;
end;

function Tctl_dlgSetupReceipt.FindTotalCalculation: TCalculation;
begin
  Result := FindCalculation('ИТОГО:');
end;

procedure Tctl_dlgSetupReceipt.CheckConsistency;
var
  I: Integer;
begin
  Calculator.ClearVariablesList;
  //
  //  Добавляем список переменных
  //  страндартных

  Calculator.AssignVariable('Сумма_Общая', 1);
  Calculator.AssignVariable('Масса_Убойная', 1);
  Calculator.AssignVariable('Масса_Живая', 1);
  Calculator.AssignVariable('Масса_Живая_Скидка', 1);
  Calculator.AssignVariable('Количество_Голов', 1);
  Calculator.AssignVariable('Количество_Голов_Порочных', 1);
  Calculator.AssignVariable('Сумма_Транспорт', 1);
  Calculator.AssignVariable('Процент_Скидка_СХ', 1);
  Calculator.AssignVariable('Процент_НДС', 1);
  Calculator.AssignVariable('Процент_НДС_Трансп', 1);
  Calculator.AssignVariable('Орг_Накл_Расх_Коэфф', 1);

  for I := 1 to sgCalculate.RowCount - 1 do
  begin
    Calculator.Expression := sgCalculate.Cells[2, I];

    if AnsiCompareText(Calculator.Expression, 'Error') = 0 then
    begin
      ModalResult := mrNone;
      sgCalculate.SetFocus;
      raise Ectl_dlgSetupReceipt.Create('Ошибка в формуле!');
    end;

    Calculator.AssignVariable(sgCalculate.Cells[1, I], 1);
  end;
end;

procedure Tctl_dlgSetupReceipt.cbVariablesClick(Sender: TObject);
begin
  if cbVariables.ItemIndex > 1 then
  with sgCalculate do
  begin
    if Cells[1, sgCalculate.Row] > '' then
      Cells[2, sgCalculate.Row] := Cells[2, Row] + ' ' + cbVariables.Text
    else
      Cells[2, Row] := Cells[2, Row] + cbVariables.Text;
  end;

  cbVariables.ItemIndex := 0;
  sgCalculate.SetFocus;
end;

{ TCalculationList }

constructor TCalculationList.Create;
begin
  FCalculations := TObjectList.Create;
end;

destructor TCalculationList.Destroy;
begin
  FreeAndNil(FCalculations);
end;

function TCalculationList.GetCount: Integer;
begin
  Result := FCalculations.Count;
end;

function TCalculationList.GetItem(Index: Integer): TCalculation;
begin
  Result := FCalculations[Index] as TCalculation;
end;

procedure TCalculationList.LoadFromStream(Stream: TStream);
var
  Reader: TReader;
  Calculation: TCalculation;
begin
  Reader := TReader.Create(Stream, 1024);
  try
    try
      Reader.ReadListBegin;

      while not Reader.EndOfList do
      begin
        Calculation := TCalculation.Create;

        Calculation.FFieldName := Reader.ReadString;
        Calculation.FVariableName := Reader.ReadString;
        Calculation.FFormula := Reader.ReadString;
        Calculation.FDescription := Reader.ReadString;

        FCalculations.Add(Calculation);
      end;

      Reader.ReadListEnd;
    except
      FCalculations.Clear;
    end;
  finally
    Reader.Free;
  end;
end;

procedure TCalculationList.SaveToStream(Stream: TStream);
var
  Writer: TWriter;
  Calculation: TCalculation;
  I: Integer;
begin
  Writer := TWriter.Create(Stream, 1024);
  try
    Writer.WriteListBegin;

    for I := 0 to FCalculations.Count - 1 do
    begin
      Calculation := FCalculations[I] as TCalculation;
      if
        (Calculation.FFieldName = '') and (Calculation.FVariableName = '')
          or
        (Calculation.FVariableName = '')
      then
        Continue;
       
      Writer.WriteString(Calculation.FFieldName);
      Writer.WriteString(Calculation.FVariableName);
      Writer.WriteString(Calculation.FFormula);
      Writer.WriteString(Calculation.FDescription);
    end;

    Writer.WriteListEnd;
  finally
    Writer.Free;
  end;
end;

end.

