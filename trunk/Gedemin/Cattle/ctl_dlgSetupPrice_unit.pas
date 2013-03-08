{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    ctl_dlgSetupPrice_unit.pas

  Abstract

    Dialog window.

  Author

    Denis Romanosvki  (01.04.2001)

  Revisions history

    1.0    01.04.2001    Denis    Initial version.


--}

unit ctl_dlgSetupPrice_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_dlgG_unit, ActnList, StdCtrls, gd_security_body, gsIBLookupComboBox,
  IBDatabase, ctl_CattleConstants_unit,  ComCtrls;

type
  Tctl_dlgSetupPrice = class(Tgd_dlgG)
    ibtrPriceField: TIBTransaction;
    pcSetup: TPageControl;
    tsPriceList: TTabSheet;
    tsSuppliers: TTabSheet;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    Label3: TLabel;
    luCompanyCattle: TgsIBLookupComboBox;
    luCompanyMeatCattle: TgsIBLookupComboBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label4: TLabel;
    luFaceCattle: TgsIBLookupComboBox;
    luFaceMeatCattle: TgsIBLookupComboBox;
    GroupBox3: TGroupBox;
    Label5: TLabel;
    Label6: TLabel;
    luVAT: TgsIBLookupComboBox;
    luFarmTax: TgsIBLookupComboBox;
    GroupBox4: TGroupBox;
    Label7: TLabel;
    luDistance: TgsIBLookupComboBox;
    tsOther: TTabSheet;
    GroupBox5: TGroupBox;
    Label8: TLabel;
    luCoefficient: TgsIBLookupComboBox;
    Label9: TLabel;
    luNDSTrans: TgsIBLookupComboBox;

    procedure FormCreate(Sender: TObject);
    procedure actOkExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actCancelExecute(Sender: TObject);

  private

  public
    function Execute: Boolean;

  end;

  Ectl_dlgSetupPriceError = class(Exception);

var
  ctl_dlgSetupPrice: Tctl_dlgSetupPrice;

implementation

uses
  dmDataBase_unit, Storages, gsStorage;

{$R *.DFM}

procedure Tctl_dlgSetupPrice.FormCreate(Sender: TObject);
begin
  inherited;

  pcSetup.ActivePage := tsPriceList;

  if not ibtrPriceField.Active then
    ibtrPriceField.StartTransaction;
end;

procedure Tctl_dlgSetupPrice.actOkExecute(Sender: TObject);
var
  F: TgsStorageFolder;
begin
  inherited;

  if luCompanyCattle.CurrentKey = '' then
  begin
    ModalResult := mrNone;
    pcSetup.ActivePage := tsPriceList;
    luCompanyCattle.SetFocus;
    raise Ectl_dlgSetupPriceError.Create('Укажите поле для живого веса!');
  end;

  if luCompanyMeatCattle.CurrentKey = '' then
  begin
    ModalResult := mrNone;
    pcSetup.ActivePage := tsPriceList;
    luCompanyCattle.SetFocus;
    raise Ectl_dlgSetupPriceError.Create('Укажите поле для мяса!');
  end;

  if luFaceCattle.CurrentKey = '' then
  begin
    ModalResult := mrNone;
    pcSetup.ActivePage := tsPriceList;
    luFaceCattle.SetFocus;
    raise Ectl_dlgSetupPriceError.Create('Укажите поле для живого веса!');
  end;

  if luFaceMeatCattle.CurrentKey = '' then
  begin
    ModalResult := mrNone;
    pcSetup.ActivePage := tsPriceList;
    luFaceMeatCattle.SetFocus;
    raise Ectl_dlgSetupPriceError.Create('Укажите поле для мяса!');
  end;

  if luVAT.CurrentKey = '' then
  begin
    ModalResult := mrNone;
    pcSetup.ActivePage := tsSuppliers;
    luVAT.SetFocus;
    raise Ectl_dlgSetupPriceError.Create('Укажите поле ставки НДС!');
  end;

  if luFarmTax.CurrentKey = '' then
  begin
    ModalResult := mrNone;
    pcSetup.ActivePage := tsSuppliers;
    luFarmTax.SetFocus;
    raise Ectl_dlgSetupPriceError.Create('Укажите поле отчисления для с/х!');
  end;

  if luNDSTrans.CurrentKey = '' then
  begin
    ModalResult := mrNone;
    pcSetup.ActivePage := tsSuppliers;
    luNDSTrans.SetFocus;
    raise Ectl_dlgSetupPriceError.Create('Укажите поле процент НДС транспортный!');
  end;

  if luDistance.CurrentKey = '' then
  begin
    ModalResult := mrNone;
    pcSetup.ActivePage := tsSuppliers;
    luDistance.SetFocus;
    raise Ectl_dlgSetupPriceError.Create('Укажите поле отчисления для с/х!');
  end;

  if luCoefficient.CurrentKey = '' then
  begin
    ModalResult := mrNone;
    pcSetup.ActivePage := tsOther;
    luCoefficient.SetFocus;
    raise Ectl_dlgSetupPriceError.Create('Укажите поле % пересчета!!');
  end;

  //
  // Сохраняем в глобальном хранилище!

  F := GlobalStorage.OpenFolder(FOLDER_CATTLE_SETTINGS, False);
  try
    //
    //  Настройки прайс-листа

    F.WriteString(VALUE_PRICELIST_COMPANYCATTLE, luCompanyCattle.CurrentKey);
    F.WriteString(VALUE_PRICELIST_COMPANYMEATCATTLE, luCompanyMeatCattle.CurrentKey);

    F.WriteString(VALUE_PRICELIST_FACECATTLE, luFaceCattle.CurrentKey);
    F.WriteString(VALUE_PRICELIST_FACEMEATCATTLE, luFaceMeatCattle.CurrentKey);

    //
    //  Настройки Поставщиков

    F.WriteString(VALUE_SUPPLIER_VAT, luVAT.CurrentKey);
    F.WriteString(VALUE_SUPPLIER_FARMTAX, luFarmTax.CurrentKey);
    F.WriteString(VALUE_SUPPLIER_NDSTRANS, luNDSTrans.CurrentKey);
    F.WriteString(VALUE_SUPPLIER_DISTANCE, luDistance.CurrentKey);

    //
    //  Группы товаров

    F.WriteString(VALUE_GOODGROUP_COEFFICIENT, luCoefficient.CurrentKey);
  finally
    GlobalStorage.CloseFolder(F, True);
  end;
end;

procedure Tctl_dlgSetupPrice.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;
//
end;

procedure Tctl_dlgSetupPrice.actCancelExecute(Sender: TObject);
begin
  inherited;
//
end;

function Tctl_dlgSetupPrice.Execute: Boolean;
var
  F: TgsStorageFolder;
begin
  //
  // Воостанавливаем из хранилища

  F := GlobalStorage.OpenFolder(FOLDER_CATTLE_SETTINGS, True, False);
  try
    //
    //  Настройки Прайс-листа

    luCompanyCattle.CurrentKey := F.ReadString(VALUE_PRICELIST_COMPANYCATTLE);
    luCompanyMeatCattle.CurrentKey := F.ReadString(VALUE_PRICELIST_COMPANYMEATCATTLE);

    luFaceCattle.CurrentKey := F.ReadString(VALUE_PRICELIST_FACECATTLE);
    luFaceMeatCattle.CurrentKey := F.ReadString(VALUE_PRICELIST_FACEMEATCATTLE);

    //
    //  Настройки Поставщиков

    luVAT.CurrentKey := F.ReadString(VALUE_SUPPLIER_VAT);
    luFarmTax.CurrentKey := F.ReadString(VALUE_SUPPLIER_FARMTAX);
    luNDSTrans.CurrentKey := F.ReadString(VALUE_SUPPLIER_NDSTRANS);
    luDistance.CurrentKey := F.ReadString(VALUE_SUPPLIER_DISTANCE);

    //
    //  Группы товаров

    luCoefficient.CurrentKey := F.ReadString(VALUE_GOODGROUP_COEFFICIENT);
  finally
    GlobalStorage.CloseFolder(F, False);
  end;

  Result := ShowModal = mrOk;
end;

end.
