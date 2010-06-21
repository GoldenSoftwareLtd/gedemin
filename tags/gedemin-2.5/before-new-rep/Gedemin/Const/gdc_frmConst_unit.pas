
unit gdc_frmConst_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IBDatabase, gdcConst, Db, IBCustomDataSet, gdcBase, Menus,
  ActnList, Grids, DBGrids, gsDBGrid, gsIBGrid, ComCtrls, ToolWin, ExtCtrls,
  gdc_frmMDVGR_unit, TB2Item, TB2Dock, TB2Toolbar, StdCtrls, gd_MacrosMenu;

type
  Tgdc_frmConst = class(Tgdc_frmMDVGR)
    gdcConst: TgdcConst;
    gdcConstValue: TgdcConstValue;
    procedure FormCreate(Sender: TObject);

  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  gdc_frmConst: Tgdc_frmConst;

implementation

uses
  gd_security,  gd_ClassList;

{$R *.DFM}

class function Tgdc_frmConst.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gdc_frmConst) then
    gdc_frmConst := Tgdc_frmConst.Create(AnOwner);
  Result := gdc_frmConst
end;

procedure Tgdc_frmConst.FormCreate(Sender: TObject);
begin
  gdcObject := gdcConst;
  gdcDetailObject := gdcConstValue;

  inherited;
end;

initialization
  RegisterFrmClass(Tgdc_frmConst);

finalization
  UnRegisterFrmClass(Tgdc_frmConst);
end.
