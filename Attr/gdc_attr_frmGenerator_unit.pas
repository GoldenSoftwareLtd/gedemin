unit gdc_attr_frmGenerator_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, gd_MacrosMenu, Db, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  ComCtrls, IBCustomDataSet, gdcBase, gdcMetaData;

type
  Tgdc_frmGenerator = class(Tgdc_frmSGR)
    gdcGenerator: TgdcGenerator;
    procedure FormCreate(Sender: TObject);
  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  gdc_frmGenerator: Tgdc_frmGenerator;

implementation

{$R *.DFM}

uses gdcBaseInterface,  gd_ClassList, gd_security;

procedure Tgdc_frmGenerator.FormCreate(Sender: TObject);
begin
  gdcObject := gdcGenerator;
  inherited;
end;

class function Tgdc_frmGenerator.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gdc_frmGenerator) then
    gdc_frmGenerator := Tgdc_frmGenerator.Create(AnOwner);

  Result := gdc_frmGenerator;
end;

initialization
  RegisterFrmClass(Tgdc_frmGenerator);

finalization
  UnRegisterFrmClass(Tgdc_frmGenerator);

end.
