unit gdc_frmDemandOrder_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmG_unit, Grids, DBGrids, gsDBGrid, gsIBGrid, Db, flt_sqlFilter,
  Menus, ActnList, ComCtrls, ToolWin, ExtCtrls, IBDatabase,
  IBCustomDataSet, gdcBase, gdcClasses, gdcPayment, StdCtrls,
  gd_security, gd_security_body, gsTransaction, gdc_frmSGRAccount_unit,
  gsIBLookupComboBox, FrmPlSvr, TB2Dock, TB2Item, TB2Toolbar, gdcTree,
  gdcBaseBank, gd_MacrosMenu;

type
  Tgdc_frmDemandOrder = class(Tgdc_frmSGRAccount)
    gdcDemandOrder: TgdcDemandOrder;
    procedure FormCreate(Sender: TObject);

  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  gdc_frmDemandOrder: Tgdc_frmDemandOrder;

implementation

uses dmDataBase_unit,  gd_ClassList;

{$R *.DFM}

{ Tgdc_frmDemandOrder }

class function Tgdc_frmDemandOrder.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gdc_frmDemandOrder) then
    gdc_frmDemandOrder := Tgdc_frmDemandOrder.Create(AnOwner);

  Result := gdc_frmDemandOrder;
end;

procedure Tgdc_frmDemandOrder.FormCreate(Sender: TObject);
begin
  gdcObject := gdcDemandOrder;

  inherited;
  gdcObject.Open;
end;

initialization
  RegisterFrmClass(Tgdc_frmDemandOrder);
  //RegisterClass(Tgdc_frmDemandOrder);

finalization
  UnRegisterFrmClass(Tgdc_frmDemandOrder);

end.
