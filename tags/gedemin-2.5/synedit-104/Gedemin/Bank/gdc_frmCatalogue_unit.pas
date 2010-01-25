unit gdc_frmCatalogue_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmMDHGRAccount_unit, Db, flt_sqlFilter, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, ComCtrls, ToolWin, ExtCtrls, gdcClasses,
  IBCustomDataSet, gdcBase, StdCtrls, gsIBLookupComboBox, gd_security,
  gd_security_body, IBDatabase, gdc_frmMDHGR_unit, gdcStatement, TB2Item,
  TB2Dock, TB2Toolbar, gdcTree, gdcBaseBank, gd_MacrosMenu;

type
  Tgdc_frmCatalogue = class(Tgdc_frmMDHGRAccount)
    gdcBankCatalogue: TgdcBankCatalogue;
    gdcBankCatalogueLine: TgdcBankCatalogueLine;
    procedure FormCreate(Sender: TObject);

  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  gdc_frmCatalogue: Tgdc_frmCatalogue;

implementation

uses dmDataBase_unit,  gd_ClassList;

{$R *.DFM}


{ Tgdc_frmCatalogue }

class function Tgdc_frmCatalogue.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gdc_frmCatalogue) then
    gdc_frmCatalogue := Tgdc_frmCatalogue.Create(AnOwner);

  Result := gdc_frmCatalogue;
end;

procedure Tgdc_frmCatalogue.FormCreate(Sender: TObject);
begin
  gdcObject := gdcBankCatalogue;
  gdcDetailObject := gdcBankCatalogueLine;

  inherited;
end;

initialization
  RegisterFrmClass(Tgdc_frmCatalogue);
  //RegisterClass(Tgdc_frmCatalogue);

finalization
  UnRegisterFrmClass(Tgdc_frmCatalogue);

end.
