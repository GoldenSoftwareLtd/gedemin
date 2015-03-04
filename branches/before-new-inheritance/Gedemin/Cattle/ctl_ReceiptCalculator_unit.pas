{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    ctl_ReceiptCalculator_unit.pas

  Abstract

    Class to calculate cattle receipts.

  Author

    Denis Romanosvki  (01.04.2001)

  Revisions history

    1.0    01.04.2001    Denis    Initial version.


--}

unit ctl_ReceiptCalculator_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IBDatabase, IBSQL, xCalc, ctl_CattleConstants_unit, ctl_dlgSetupReceipt_unit;

type
  Tctl_ReceiptCalculator = class
  private
    FDatabase: TIBDatabase;
    FTransaction: TIBTransaction;

    FTotalAmount: Currency;
    FSumNCU: Currency;

    FMeatWeight: Currency;
    FRealWeight: Currency;
    FLiveWeight: Currency;
    FNDSTrans: Currency;

    FQuantity: Integer;
    FWasteCount: Integer;

    FSupplierKey: Integer;
    FDistance: Currency;
    FDeliveryKind: Char;

    FVATField, FFarmTaxField, FDistanceField, FNDSTransField: String;

    FCalculator: TxFoCal;
    FTariffSQL: TIBSQL;
    FContactPropsSQL: TIBSQL;

    FCalculationList: TCalculationList;
    FOnCostsCoeff: Currency;

  protected
    function GetContactPropsSQL: String;
    function GetTariffSQL: String;

    function CountTransport: Currency;
    function CountTotalAmount: Currency;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Compute;

    property Database: TIBDatabase read FDatabase write FDatabase;
    property Transaction: TIBTransaction read FTransaction write FTransaction;

    property TotalAmount: Currency read FTotalAmount write FTotalAmount;
    property SumNCU: Currency read FSumNCU;
    property Quantity: Integer read FQuantity write FQuantity;

    property MeatWeight: Currency read FMeatWeight write FMeatWeight;
    property LiveWeight: Currency read FLiveWeight write FLiveWeight;
    property RealWeight: Currency read FRealWeight write FRealWeight;
    property NDSTrans: Currency read FNDSTrans write FNDSTrans;

    property WasteCount: Integer read FWasteCount write FWasteCount;
    property OnCostsCoeff: Currency read FOnCostsCoeff write FOnCostsCoeff;

    property SupplierKey: Integer read FSupplierKey write FSupplierKey;
    property DeliveryKind: Char read FDeliveryKind write FDeliveryKind;

    property CalculationList: TCalculationList read FCalculationList;

  end;

  EctlReceiptCalculator = class(Exception);

implementation

uses
  gd_security, gsStorage, gd_security_OperationConst, at_classes,
  dmDatabase_unit, Storages;

const
  CoeffTransport = 1;


function Round3(const Value: Double): Double;
begin
  Result := Round(Value * 1000) / 1000;
end;

function GetDateOnly(const D: TdateTime): TDateTime;
begin
  Result := D;
  ReplaceTime(Result, 0);
end;

function IsPriceListSetup: Boolean;
var
  F: TgsStorageFolder;
  S1, S2, S3, S4: String;
begin
  F := GlobalStorage.OpenFolder(FOLDER_CATTLE_SETTINGS, True, False);
  try
    S1 := F.ReadString(VALUE_PRICELIST_COMPANYCATTLE, '');
    S2 := F.ReadString(VALUE_PRICELIST_COMPANYMEATCATTLE, '');

    S3 := F.ReadString(VALUE_PRICELIST_FACECATTLE, '');
    S4 := F.ReadString(VALUE_PRICELIST_FACEMEATCATTLE, '');
  finally
    GlobalStorage.CloseFolder(F, False);
  end;

  Result := (S1 > '') and (S2 > '') and (S3 > '') and (S4 > '');
end;

procedure ReadPriceListSetup(out Field1, Field2, Field3, Field4: String);
var
  F: TgsStorageFolder;
begin
  F := GlobalStorage.OpenFolder(FOLDER_CATTLE_SETTINGS, True, False);
  try
    Field1 := F.ReadString(VALUE_PRICELIST_COMPANYCATTLE, '');
    Field2 := F.ReadString(VALUE_PRICELIST_COMPANYMEATCATTLE, '');

    Field3 := F.ReadString(VALUE_PRICELIST_FACECATTLE, '');
    Field4 := F.ReadString(VALUE_PRICELIST_FACEMEATCATTLE, '');
  finally
    GlobalStorage.CloseFolder(F, False);
  end;
end;

procedure ReadContactProps(out VAT, FarmTax, Distance, NDS: String);
var
  F: TgsStorageFolder;
begin
  F := GlobalStorage.OpenFolder(FOLDER_CATTLE_SETTINGS, True, False);
  try
    VAT := Trim(F.ReadString(VALUE_SUPPLIER_VAT, ''));
    FarmTax := Trim(F.ReadString(VALUE_SUPPLIER_FARMTAX, ''));
    Distance := Trim(F.ReadString(VALUE_SUPPLIER_DISTANCE, ''));
    NDS := Trim(F.ReadString(VALUE_SUPPLIER_NDSTRANS, ''));
  finally
    GlobalStorage.CloseFolder(F, False);
  end;
end;

function ReadFormulaStream: TStream;
var
  F: TgsStorageFolder;
begin
  F := GlobalStorage.OpenFolder(FOLDER_CATTLE_SETTINGS, True, False);
  try
    Result := TMemoryStream.Create;
    F.ReadStream(VALUE_RECEIPT_FORMULA, Result);
  finally
    GlobalStorage.CloseFolder(F, False);
  end;
end;

{ Tctl_ReceiptCalculator }

procedure Tctl_ReceiptCalculator.Compute;
begin
  //
  //  Производим подготовку запроса

  if not FContactPropsSQL.Prepared then
  begin
    FContactPropsSQL.Database := FDatabase;
    FContactPropsSQL.Transaction := FTransaction;
    FContactPropsSQL.SQL.Text := GetContactPropsSQL;
    FContactPropsSQL.Prepare;
  end;

  //
  //  Производим поиск дополнительных свойств клиента:
  //  расстояние, НДС, СХ скидку

  FContactPropsSQL.Prepare;
  FContactPropsSQL.ParamByName('CONTACTKEY').AsInteger := FSupplierKey;

  FContactPropsSQL.ExecQuery;

  //
  //  Добавляем переменные для расчета

  FCalculator.ClearVariablesList;

  FCalculator.AssignVariable('Процент_НДС',
    FContactPropsSQL.FieldByName(FVATField).AsFloat);
  FCalculator.AssignVariable('Процент_Скидка_СХ',
    FContactPropsSQL.FieldByName(FFarmTaxField).AsFloat);
  FCalculator.AssignVariable('Процент_НДС_Трансп',
    FContactPropsSQL.FieldByName(FNDSTransField).AsFloat);

  FDistance := FContactPropsSQL.FieldByName(FDistanceField).AsFloat;

  FCalculator.AssignVariable('Сумма_Транспорт', CountTransport);

  FContactPropsSQL.Close;

  FCalculator.AssignVariable('Сумма_Общая', FTotalAmount);

  FCalculator.AssignVariable('Количество_Голов', FQuantity);
  FCalculator.AssignVariable('Количество_Голов_Порочных', FWasteCount);

  FCalculator.AssignVariable('Масса_Убойная', FMeatWeight);
  FCalculator.AssignVariable('Масса_Живая', FLiveWeight);
  FCalculator.AssignVariable('Масса_Живая_Скидка', FRealWeight);
  FCalculator.AssignVariable('Орг_Накл_Расх_Коэфф', FOnCostsCoeff);

  FSumNCU := CountTotalAmount;
end;

function Tctl_ReceiptCalculator.GetContactPropsSQL: String;
begin
  //
  //  Подготовка данных о клиенте

  ReadContactProps(FVATField, FFarmTaxField, FDistanceField, FNDSTransField);

  Result := Format(
    'SELECT '#13#10 +
    '  P.%s, P.%s, P.%s, P.%s '#13#10 +
    ' '#13#10 +
    'FROM '#13#10 +
    '  GD_CONTACTPROPS P '#13#10 +
    ' '#13#10 +
    'WHERE '#13#10 +
    '  P.CONTACTKEY = :CONTACTKEY ',
    [Trim(FVATField), Trim(FFarmTaxField), Trim(FDistanceField), Trim(FNDSTransField)]);
end;

function Tctl_ReceiptCalculator.CountTransport: Currency;
var
  Dist, Dist2: Currency; // Расстояние
  Coefficient, Coefficient1: Double;
  Weight: Currency;
  Amount2, CoeffTariff: Currency;

begin
  // самовызов, самовывоз разгрузочный пост
  if (FDeliveryKind = 'C') then
  begin
    Result := 0;
    Exit;
  end;

  with GlobalStorage.OpenFolder(FOLDER_CATTLE_SETTINGS, True, False) do
    CoeffTariff := ReadCurrency(VALUE_RECEIPT_CoeffTariff, Def_CoeffTariff);

  //
  //  Определяем переменные по расстоянию

  if FDistance < 200 then
  begin
    Dist := FDistance;
    Dist2 := 0;
  end else begin
    Dist := 200;
    Dist2 := FDistance - 200;
  end;

  { TODO 1 -oденис -cсделать : Сделать проверку на спецавтотранспорт }
  if True then
    Weight := FRealWeight
  else
    Weight := FRealWeight;

  //
  //  Выбираем запись по расстоянию

  if not FTariffSQL.Prepared then
  begin
    FTariffSQL.SQL.Text := GetTariffSQL;
    FTariffSQL.Database := FDatabase;
    FTariffSQL.Transaction := FTransaction;
    FTariffSQL.Prepare;
  end;

  FTariffSQL.ParamByName('DISTANCE').AsFloat := Dist;
  FTariffSQL.ExecQuery;

  if FTariffSQL.RecordCount = 0 then
    raise EctlReceiptCalculator.Create('Transport tariff record not found!');

  // Вес меньше 500
  if Weight < 500 then
    Coefficient := FTariffSQL.FieldByName('TARIFF_500').AsCurrency else

  // Вес меньше 1000
  if Weight < 1000 then
    Coefficient := FTariffSQL.FieldByName('TARIFF_1000').AsCurrency else

  // Вес меньше 1500
  if Weight < 1500 then
    Coefficient := FTariffSQL.FieldByName('TARIFF_1500').AsCurrency else

  // Вес меньше 2000
  if Weight < 2000 then
    Coefficient := FTariffSQL.FieldByName('TARIFF_2000').AsCurrency else

  // Вес меньше 5000
  if Weight < 5000 then
    Coefficient := FTariffSQL.FieldByName('TARIFF_5000').AsCurrency

  // Вес больше 5000
  else
    Coefficient := FTariffSQL.FieldByName('TARIFF_S5000').AsCurrency;

  FTariffSQL.Close;

  Coefficient1 := 0;

  if Weight < 5000 then
  begin
    Coefficient := Coefficient + Round3(Dist2 * Coefficient);
  end else
  begin
    Coefficient := Coefficient + Round3(Dist2 * Coefficient);
    Coefficient1 := Coefficient + Round3(Dist2 * Coefficient);
  end;

  Coefficient := Coefficient * CoeffTariff;
  Coefficient1 := Coefficient1 * CoeffTariff;

  // Вес меньше 2000
  if Weight < 2000 then
    Amount2 := Coefficient else

  // Вес меньше 5000
  if Weight < 5000 then
    Amount2:= Round3(Coefficient * Weight / 1000)

  // Вес больше 5000
  else
    Amount2 := Round3(Coefficient * 5000 / 1000 + (Weight - 5000) * Coefficient1 / 1000);

  Result := Amount2 * CoeffTransport;

end;

constructor Tctl_ReceiptCalculator.Create;
begin
  FCalculator := TxFoCal.Create(nil);

  FTariffSQL := TIBSQL.Create(nil);
  FContactPropsSQL := TIBSQL.Create(nil);

  FCalculationList := TCalculationList.Create;

  FDeliveryKind := #0;
end;

destructor Tctl_ReceiptCalculator.Destroy;
begin
  FCalculator.Free;

  FTariffSQL.Free;
  FContactPropsSQL.Free;

  FCalculationList.Free;

  inherited;
end;

function Tctl_ReceiptCalculator.GetTariffSQL: String;
begin
  Result :=
    'SELECT '#13#10 +
    '  A.* '#13#10 +
    ' '#13#10 +
    'FROM '#13#10 +
    '  CTL_AUTOTARIFF A '#13#10 +
    ' '#13#10 +
    'WHERE '#13#10 +
    '  A.DISTANCE = :DISTANCE '
end;

function Tctl_ReceiptCalculator.CountTotalAmount: Currency;
var
  I: Integer;
  ReadStream: TStream;
begin
  FCalculator.Expression := '';
  Result := 0;
  //
  //  Считываем настройки формулы

  ReadStream := ReadFormulaStream;
  try
    if ReadStream <> nil then
      FCalculationList.LoadFromStream(ReadStream)
    else
      raise EctlReceiptCalculator.Create(
        'Невозможно создать квитанцию без настроек полей!');

    //
    //  Осуществляем подсчет показателей

    for I := 0 to FCalculationList.Count - 1 do
    begin
      FCalculator.Expression := FCalculationList[I].Formula;

      if AnsiCompareText(FCalculator.Expression, 'Error') = 0 then
        raise EctlReceiptCalculator.Create('Ошибка в формуле расчета!');

      FCalculator.AssignVariable(FCalculationList[I].VariableName, FCalculator.Value);
      FCalculationList[I].Calculation := FCalculator.Value;
    end;

    Result := FCalculator.Value;
  finally
    ReadStream.Free;
  end;
end;

end.
