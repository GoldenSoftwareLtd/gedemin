unit gdc_frmField_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, Db, Menus, ActnList, Grids, DBGrids, gsDBGrid, gsIBGrid,
  ToolWin, ComCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  IBCustomDataSet, gdcBase, gdcMetaData, gd_MacrosMenu, StdCtrls;

type
  Tgdc_frmField = class(Tgdc_frmSGR)
    gdcField: TgdcField;
    TBItem1: TTBItem;
    procedure FormCreate(Sender: TObject);

  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  gdc_frmField: Tgdc_frmField;

implementation

{$R *.DFM}

uses
  gd_ClassList, gdcBaseInterface, at_classes, gd_security;

class function Tgdc_frmField.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gdc_frmField) then
    gdc_frmField := Tgdc_frmField.Create(AnOwner);
  Result := gdc_frmField
end;

procedure Tgdc_frmField.FormCreate(Sender: TObject);
begin
  gdcObject := gdcField;

  inherited;

end;

initialization
  RegisterFrmClass(Tgdc_frmField);

finalization
  UnRegisterFrmClass(Tgdc_frmField);

end.
