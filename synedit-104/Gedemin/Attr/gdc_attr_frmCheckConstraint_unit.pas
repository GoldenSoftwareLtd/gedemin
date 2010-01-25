unit gdc_attr_frmCheckConstraint_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, gd_MacrosMenu, Db, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  ComCtrls, gdcMetaData, IBCustomDataSet, gdcBase;

type
  Tgdc_frmCheckConstraint = class(Tgdc_frmSGR)
    gdcCheckConstraint: TgdcCheckConstraint;
    procedure FormCreate(Sender: TObject);
  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  gdc_frmCheckConstraint: Tgdc_frmCheckConstraint;

implementation

{$R *.DFM}

uses gdcBaseInterface, gd_ClassList, gd_security;

{ Tgdc_attr_frmCheckConstraint }

class function Tgdc_frmCheckConstraint.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gdc_frmCheckConstraint) then
    gdc_frmCheckConstraint := Tgdc_frmCheckConstraint.Create(AnOwner);

  Result := gdc_frmCheckConstraint;
end;

procedure Tgdc_frmCheckConstraint.FormCreate(Sender: TObject);
begin
  gdcObject := gdcCheckConstraint;
  inherited;
end;

initialization
  RegisterFrmClass(Tgdc_frmCheckConstraint);

finalization
  UnRegisterFrmClass(Tgdc_frmCheckConstraint);

end.
