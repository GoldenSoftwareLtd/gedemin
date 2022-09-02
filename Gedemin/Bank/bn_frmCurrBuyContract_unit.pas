// ShlTanya, 30.01.2019

unit bn_frmCurrBuyContract_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_frmSIBF_unit, gsReportManager, flt_sqlFilter, Db, IBCustomDataSet,
  IBDatabase, Menus, ActnList, ComCtrls,
  ToolWin, ExtCtrls, Grids, DBGrids, gsDBGrid, gsIBGrid, dmDatabase_unit,
  gdcBase, gdcClasses, gdcCurrSellContract, gd_frmG_unit,
  bn_frmMainCurrForm_unit, TB2Item, TB2Dock, TB2Toolbar, gdcTree, StdCtrls,
  gd_MacrosMenu;

type
  Tbn_frmCurrBuyContract = class(Tbn_frmMainCurrForm)
    gdcCurrBuyContract: TgdcCurrBuyContract;
    procedure FormCreate(Sender: TObject);

  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  bn_frmCurrBuyContract: Tbn_frmCurrBuyContract;

implementation

{$R *.DFM}

{ Tbn_frmCurrBuyContract }

uses
  gd_ClassList;

class function Tbn_frmCurrBuyContract.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(bn_frmCurrBuyContract) then
    bn_frmCurrBuyContract := Tbn_frmCurrBuyContract.Create(AnOwner);

  Result := bn_frmCurrBuyContract;
end;

procedure Tbn_frmCurrBuyContract.FormCreate(Sender: TObject);
begin
  gdcObject := gdcCurrBuyContract;
  inherited;
end;

initialization
  RegisterFrmClass(Tbn_frmCurrBuyContract);
  //RegisterClass(Tbn_frmCurrBuyContract);


finalization
  UnRegisterFrmClass(Tbn_frmCurrBuyContract);

end.
