unit bn_frmCurrSellContract_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  bn_frmMainCurrForm_unit, IBDatabase, Db, gsReportManager, flt_sqlFilter,
  Menus, ActnList,  Grids, DBGrids, gsDBGrid, gsIBGrid,
  ComCtrls, ToolWin, ExtCtrls, IBCustomDataSet, gdcBase, gdcClasses,
  gdcCurrSellContract, gdcTree, StdCtrls, TB2Item, TB2Dock, TB2Toolbar,
  gd_MacrosMenu;

type
  Tbn_frmCurrSellContract = class(Tbn_frmMainCurrForm)
    gdcCurrSellContract: TgdcCurrSellContract;
    procedure FormCreate(Sender: TObject);

  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  bn_frmCurrSellContract: Tbn_frmCurrSellContract;

implementation

{$R *.DFM}

{ Tbn_frmCurrSellContract }

uses
  gd_ClassList;

class function Tbn_frmCurrSellContract.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(bn_frmCurrSellContract) then
    bn_frmCurrSellContract := Tbn_frmCurrSellContract.Create(AnOwner);

  Result := bn_frmCurrSellContract;

end;

procedure Tbn_frmCurrSellContract.FormCreate(Sender: TObject);
begin
  gdcObject := gdcCurrSellContract;
  inherited;
end;

initialization
  RegisterFrmClass(Tbn_frmCurrSellContract);

  //RegisterClass(Tbn_frmCurrSellContract);

finalization
  UnRegisterFrmClass(Tbn_frmCurrSellContract);

end.
