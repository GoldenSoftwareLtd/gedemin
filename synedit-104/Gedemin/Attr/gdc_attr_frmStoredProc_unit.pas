unit gdc_attr_frmStoredProc_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, Db, Menus, ActnList, Grids, DBGrids, gsDBGrid, gsIBGrid,
  ToolWin, ComCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar, at_Classes,
  IBCustomDataSet, gdcBase, gdcMetaData, gd_MacrosMenu, StdCtrls;

type
  Tgdc_attr_frmStoredProc = class(Tgdc_frmSGR)
    gdcStoredProc: TgdcStoredProc;
    procedure FormCreate(Sender: TObject);

  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  gdc_attr_frmStoredProc: Tgdc_attr_frmStoredProc;

implementation

{$R *.DFM}

uses gdcBaseInterface,  gd_ClassList, gd_security;

procedure Tgdc_attr_frmStoredProc.FormCreate(Sender: TObject);
begin
  gdcObject := gdcStoredProc;
  inherited;
end;

class function Tgdc_attr_frmStoredProc.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gdc_attr_frmStoredProc) then
    gdc_attr_frmStoredProc := Tgdc_attr_frmStoredProc.Create(AnOwner);

  Result := gdc_attr_frmStoredProc;

end;

initialization
  RegisterFrmClass(Tgdc_attr_frmStoredProc);

finalization
  UnRegisterFrmClass(Tgdc_attr_frmStoredProc);

end.
