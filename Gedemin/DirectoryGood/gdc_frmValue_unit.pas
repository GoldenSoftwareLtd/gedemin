// ShlTanya, 29.01.2019

{
  Единицы измерения
  ViewForm для TgdcValue

  Revisions history

    1.00    01.11.01    sai        Initial version.
}
unit gdc_frmValue_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, Db, Menus, ActnList, Grids, DBGrids, gsDBGrid, gsIBGrid,
  ToolWin, ComCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  IBCustomDataSet, gdcBase, gdcGood, gd_MacrosMenu, StdCtrls;

type
  Tgdc_frmValue = class(Tgdc_frmSGR)
    gdcValue: TgdcValue;
    procedure FormCreate(Sender: TObject);
  private
  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  gdc_frmValue: Tgdc_frmValue;

implementation

{$R *.DFM}

uses
  gd_ClassList;

class function Tgdc_frmValue.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gdc_frmValue) then
    gdc_frmValue := Tgdc_frmValue.Create(AnOwner);
  Result := gdc_frmValue
end;

procedure Tgdc_frmValue.FormCreate(Sender: TObject);
begin
  gdcObject := gdcValue;

  inherited;
  gdcValue.Open;
end;

initialization
  RegisterFrmClass(Tgdc_frmValue);
  //RegisterClass(Tgdc_frmValue);

finalization
  UnRegisterFrmClass(Tgdc_frmValue);

end.
