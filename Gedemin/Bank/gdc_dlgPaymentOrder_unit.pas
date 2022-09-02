// ShlTanya, 30.01.2019

unit gdc_dlgPaymentOrder_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgG_unit, Db, ActnList, StdCtrls, at_Container,
  gsTransactionComboBox, xCalculatorEdit, DBCtrls, Mask, xDateEdits,
  gsIBLookupComboBox, ExtCtrls, ComCtrls, gsDocNumerator, IBSQL, gd_security,
  gd_security_body, gsTransaction, gdcPayment, gdc_dlgCustomPayment_unit,
  IBDatabase, gdcBase, Menus;

type
  Tgdc_dlgPaymentOrder = class(Tgdc_dlgCustomPayment)
    Label13: TLabel;
    Label9: TLabel;
    Label21: TLabel;
    dbeSecondAccount: TDBEdit;
    dbeSecondAmount: TxDBCalculatorEdit;
    dbeMidCorrBank: TDBEdit;
    Label19: TLabel;
    dbeReceive: TDBEdit;
    Label14: TLabel;
    dbcSpecification: TDBComboBox;
    Label15: TLabel;
    cmbKind: TComboBox;
    procedure dbeCorrAccountCreateNewObject(Sender: TObject;
      ANewObject: TgdcBase);

  protected
    procedure BeforePost; override;  

  public
    procedure SetupRecord; override;
  end;

var
  gdc_dlgPaymentOrder: Tgdc_dlgPaymentOrder;

implementation

uses dmDataBase_unit,  gd_ClassList;

{$R *.DFM}

procedure Tgdc_dlgPaymentOrder.dbeCorrAccountCreateNewObject(
  Sender: TObject; ANewObject: TgdcBase);
begin
  if (ANewObject <> nil) and (ANewObject.State = dsInsert) then
    ANewObject.FieldByName('companykey').AsString := dbeCorrCompany.CurrentKey;
end;

procedure Tgdc_dlgPaymentOrder.BeforePost;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGPAYMENTORDER', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGPAYMENTORDER', KEYBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGPAYMENTORDER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGPAYMENTORDER',
  {M}          'BEFOREPOST', KEYBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGPAYMENTORDER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  with gdcObject do
  begin
    case cmbKind.ItemIndex of
      0: FieldByName('KIND').Value := 'C';
      1: FieldByName('KIND').Value := 'P';
    end;
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGPAYMENTORDER', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGPAYMENTORDER', 'BEFOREPOST', KEYBEFOREPOST);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgPaymentOrder.SetupRecord;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGPAYMENTORDER', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGPAYMENTORDER', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGPAYMENTORDER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGPAYMENTORDER',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGPAYMENTORDER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  if gdcObject.FieldByName('KIND').AsString = 'P' then
    cmbKind.ItemIndex := 1
  else
    cmbKind.ItemIndex := 0;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGPAYMENTORDER', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGPAYMENTORDER', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;

initialization
  RegisterFrmClass(Tgdc_dlgPaymentOrder);

finalization
  UnRegisterFrmClass(Tgdc_dlgPaymentOrder);

end.
