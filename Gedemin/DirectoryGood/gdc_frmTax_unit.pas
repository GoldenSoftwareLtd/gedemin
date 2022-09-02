// ShlTanya, 29.01.2019

{
  Налоги
  ViewForm для TgdcTax

  Revisions history

    1.00    01.11.01    sai        Initial version.
}
unit gdc_frmTax_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, Db, Menus, ActnList, Grids, DBGrids, gsDBGrid, gsIBGrid,
  ToolWin, ComCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  IBCustomDataSet, gdcBase, gdcGood, gd_MacrosMenu, StdCtrls;

type
  Tgdc_frmTax = class(Tgdc_frmSGR)
    gdcTax: TgdcTax;
    procedure FormCreate(Sender: TObject);
  private
  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  gdc_frmTax: Tgdc_frmTax;

implementation

{$R *.DFM}

uses
  gd_ClassList;

class function Tgdc_frmTax.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gdc_frmTax) then
    gdc_frmTax := Tgdc_frmTax.Create(AnOwner);
  Result := gdc_frmTax
end;

procedure Tgdc_frmTax.FormCreate(Sender: TObject);
begin
  gdcObject := gdcTax;

  inherited;

  gdcObject.Open;
end;

initialization
  RegisterFrmClass(Tgdc_frmTax);
  //RegisterClass(Tgdc_frmTax);

finalization
  UnRegisterFrmClass(Tgdc_frmTax);

end.
