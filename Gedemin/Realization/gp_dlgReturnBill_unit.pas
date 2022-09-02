// ShlTanya, 11.03.2019

unit gp_dlgReturnBill_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gp_dlgRealizationBill_unit, FrmPlSvr, Menus,  boCurrency,
  gsTransaction, xCalc, at_sql_setup, IBSQL, ActnList, Db,
  IBDatabase, IBCustomDataSet, ComCtrls, StdCtrls, ToolWin, Grids, DBGrids,
  gsDBGrid, gsIBGrid, gsIBCtrlGrid, at_Container, DBCtrls,
  gsTransactionComboBox, ExtCtrls, gsIBLookupComboBox, Mask, xDateEdits,
  Buttons, gp_dlgBill_unit;

type
  TdlgReturnBill = class(Tgp_dlgBill)
  private
    { Private declarations }
  public
    { Public declarations }
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;    
  end;

var
  dlgReturnBill: TdlgReturnBill;

implementation

{$R *.DFM}

{ TdlgReturnBill }

class function TdlgReturnBill.CreateAndAssign(AnOwner: TComponent): TForm;
begin
  if not FormAssigned(dlgReturnBill) then
  begin
    dlgReturnBill := TdlgReturnBill.Create(AnOwner);
    dlgReturnBill.DocumentType := 802003;
  end;  

  Result := dlgReturnBill;
end;

initialization
  dlgReturnBill := nil;


end.
