unit gdc_attr_frmMacros_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, gd_MacrosMenu, Db, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  ComCtrls, IBCustomDataSet, gdcBase, gdcMetaData, gdcMacros;

type
  Tgdc_frmMacros = class(Tgdc_frmSGR)
    gdcMacros: TgdcMacros;
    procedure FormCreate(Sender: TObject);

  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  gdc_frmMacros: Tgdc_frmMacros;

implementation

{$R *.DFM}

uses
  gd_ClassList;

class function Tgdc_frmMacros.CreateAndAssign(AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gdc_frmMacros) then
    gdc_frmMacros := Tgdc_frmMacros.Create(AnOwner);
  Result := gdc_frmMacros;
end;

procedure Tgdc_frmMacros.FormCreate(Sender: TObject);
begin
  gdcObject := gdcMacros;
  inherited;
end;


initialization
  RegisterFrmClass(Tgdc_frmMacros);
  //RegisterClass(Tgdc_frmMacros);
finalization
  UnRegisterFrmClass(Tgdc_frmMacros);

end.
