// ShlTanya, 29.01.2019

{
  Драгоценные металы
  ViewForm для TgdcMetal

  Revisions history

    1.00    01.11.01    sai        Initial version.
}

unit gdc_frmMetal_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, Db, Menus, ActnList, Grids, DBGrids, gsDBGrid, gsIBGrid,
  ToolWin, ComCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  IBCustomDataSet, gdcBase, gdcGood, gd_MacrosMenu, StdCtrls;

type
  Tgdc_frmMetal = class(Tgdc_frmSGR)
    gdcMetal: TgdcMetal;
    procedure FormCreate(Sender: TObject);
  private
  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  gdc_frmMetal: Tgdc_frmMetal;

implementation

{$R *.DFM}

uses
  gd_ClassList;

class function Tgdc_frmMetal.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gdc_frmMetal) then
    gdc_frmMetal := Tgdc_frmMetal.Create(AnOwner);
  Result := gdc_frmMetal
end;

procedure Tgdc_frmMetal.FormCreate(Sender: TObject);
begin
  gdcObject := gdcMetal;

  inherited;
  
  gdcObject.Open;
end;

initialization
  RegisterFrmClass(Tgdc_frmMetal);
  //RegisterClass(Tgdc_frmMetal);

finalization
  UnRegisterFrmClass(Tgdc_frmMetal);

end.
