unit gdc_frmPaymentDemand_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmG_unit, Grids, DBGrids, gsDBGrid, gsIBGrid, Db, flt_sqlFilter,
  Menus, ActnList, ComCtrls, ToolWin, ExtCtrls, IBDatabase,
  IBCustomDataSet, gdcBase, gdcClasses, gdcPayment, StdCtrls,
  gsIBLookupComboBox, gd_security, gd_security_body, gdc_frmSGRAccount_unit,
  gsTransaction, TB2Dock, TB2Item, TB2Toolbar, gdcTree, gdcBaseBank,
  gd_MacrosMenu;

type
  Tgdc_frmPaymentDemand = class(Tgdc_frmSGRAccount)
    gdcPaymentDemand: TgdcPaymentDemand;
    procedure FormCreate(Sender: TObject);

  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  gdc_frmPaymentDemand: Tgdc_frmPaymentDemand;

implementation

uses dmDataBase_unit,  gd_ClassList;

{$R *.DFM}

{ Tgdc_frmPaymentDemand }

class function Tgdc_frmPaymentDemand.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gdc_frmPaymentDemand) then
    gdc_frmPaymentDemand := Tgdc_frmPaymentDemand.Create(AnOwner);

  Result := gdc_frmPaymentDemand;
end;

procedure Tgdc_frmPaymentDemand.FormCreate(Sender: TObject);
begin
  gdcObject := gdcPaymentDemand;
  inherited;
end;

initialization
  RegisterFrmClass(Tgdc_frmPaymentDemand);
  //RegisterClass(Tgdc_frmPaymentDemand);

finalization
  UnRegisterFrmClass(Tgdc_frmPaymentDemand);

end.
