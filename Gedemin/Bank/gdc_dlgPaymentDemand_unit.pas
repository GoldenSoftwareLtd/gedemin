// ShlTanya, 30.01.2019

unit gdc_dlgPaymentDemand_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgG_unit, Db, ActnList, StdCtrls, xCalculatorEdit, DBCtrls, Mask,
  xDateEdits, gsIBLookupComboBox, ExtCtrls, ComCtrls, IBSQL, gd_security_operationconst,
  gdcBase, gd_security, gd_security_body, gdcPayment,
  gdc_dlgCustomPayment_unit, at_Container, gsTransactionComboBox,
  gdc_dlgCustomDemand_unit, IBCustomDataSet, gdcContacts, IBDatabase,
  gdcTree, Menus;

type
  Tgdc_dlgPaymentDemand = class(Tgdc_dlgCustomDemand)
  private
  protected
  public
  end;

var
  gdc_dlgPaymentDemand: Tgdc_dlgPaymentDemand;

implementation

uses dmDataBase_unit,  gd_ClassList;

{$R *.DFM}


initialization
  RegisterFrmClass(Tgdc_dlgPaymentDemand);

finalization
  UnRegisterFrmClass(Tgdc_dlgPaymentDemand);

end.
