// ShlTanya, 30.01.2019

unit gdc_frmPaymentOrder_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmG_unit, Grids, DBGrids, gsDBGrid, gsIBGrid, Db, flt_sqlFilter,
  Menus, ActnList, ComCtrls, ToolWin, ExtCtrls, IBDatabase,
  IBCustomDataSet, gdcBase, gdcClasses, gdcPayment, StdCtrls,
  gsIBLookupComboBox, gd_security, gd_security_body, gsTransaction,
  gdc_frmSGRAccount_unit, TB2Dock, TB2Item, TB2Toolbar, gdcBaseBank,
  gdcTree, gd_MacrosMenu;


type
  Tgdc_frmPaymentOrder = class(Tgdc_frmSGRAccount)
    gdcPaymentOrder: TgdcPaymentOrder;
    actOptionsExport: TAction;
    tbiOptionsExport: TTBItem;
    procedure FormCreate(Sender: TObject);
    procedure actOptionsExportExecute(Sender: TObject);
  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  gdc_frmPaymentOrder: Tgdc_frmPaymentOrder;

implementation

uses dmDataBase_unit
  {$IFDEF DEPARTMENT}
   , dp_dlgImportExportOptions_unit
  {$ENDIF},  gd_ClassList;

{$R *.DFM}

{ Tgdc_frmPaymentOrder }

class function Tgdc_frmPaymentOrder.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gdc_frmPaymentOrder) then
    gdc_frmPaymentOrder := Tgdc_frmPaymentOrder.Create(AnOwner);

  Result := gdc_frmPaymentOrder;
end;

procedure Tgdc_frmPaymentOrder.FormCreate(Sender: TObject);
begin
  gdcObject := gdcPaymentOrder;

  inherited;
  gdcObject.Open;

  {$IFDEF DEPARTMENT}
    actOptionsExport.Visible := True;
  {$ELSE}
    actOptionsExport.Visible := False;
  {$ENDIF}

end;

procedure Tgdc_frmPaymentOrder.actOptionsExportExecute(Sender: TObject);
begin
 {$IFDEF DEPARTMENT}
 //Настройки ипморта/экспорта выписок
  with TdlgImportExportOptions.Create(Self) do
    try
      ShowModal;
    finally
      Free;
    end;
 {$ENDIF}   
end;

initialization
  RegisterFrmClass(Tgdc_frmPaymentOrder);
  //RegisterClass(Tgdc_frmPaymentOrder);

finalization
  UnRegisterFrmClass(Tgdc_frmPaymentOrder);

end.
