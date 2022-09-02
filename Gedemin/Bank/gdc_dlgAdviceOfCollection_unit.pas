// ShlTanya, 30.01.2019

unit gdc_dlgAdviceOfCollection_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgG_unit, Db, ActnList, StdCtrls, xCalculatorEdit, DBCtrls, Mask,
  xDateEdits, gsIBLookupComboBox, ExtCtrls, ComCtrls, IBSQL, gd_security_operationconst,
  gdcBase, gd_security, gd_security_body, gdcPayment,
  gdc_dlgCustomPayment_unit, at_Container, gsTransactionComboBox,
  gdc_dlgCustomDemand_unit, gdc_dlgDemandOrder_unit, IBCustomDataSet,
  gdcContacts, IBDatabase, gdcTree, Menus;

type
  Tgdc_dlgAdviceOfCollection = class(Tgdc_dlgDemandOrder)
  private
  protected
  public
  end;

var
  gdc_dlgAdviceOfCollection: Tgdc_dlgAdviceOfCollection;

implementation

uses dmDataBase_unit,  gd_ClassList;

{$R *.DFM}


initialization
  RegisterFrmClass(Tgdc_dlgAdviceOfCollection);

finalization
  UnRegisterFrmClass(Tgdc_dlgAdviceOfCollection);

end.
