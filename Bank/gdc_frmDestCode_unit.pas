unit gdc_frmDestCode_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, Db, Menus, ActnList, Grids, DBGrids, gsDBGrid, gsIBGrid,
  ToolWin, ComCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  IBCustomDataSet, gdcBase, gdcPayment, StdCtrls, gd_MacrosMenu;

type
  Tgdc_frmDestCode = class(Tgdc_frmSGR)
    gdcDestCode: TgdcDestCode;
    procedure FormCreate(Sender: TObject);
  private
  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  gdc_frmDestCode: Tgdc_frmDestCode;

implementation

{$R *.DFM}

uses
  gd_ClassList;

class function Tgdc_frmDestCode.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gdc_frmDestCode) then
    gdc_frmDestCode := Tgdc_frmDestCode.Create(AnOwner);

  Result := gdc_frmDestCode;
end;

procedure Tgdc_frmDestCode.FormCreate(Sender: TObject);
begin
  gdcObject := gdcDestCode;

  inherited;
  gdcObject.Open;
end;

initialization
  RegisterFrmClass(Tgdc_frmDestCode);
  //RegisterClass(Tgdc_frmDestCode);

finalization
  UnRegisterFrmClass(Tgdc_frmDestCode);

end.
