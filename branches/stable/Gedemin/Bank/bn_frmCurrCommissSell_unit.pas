unit bn_frmCurrCommissSell_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_frmSIBF_unit, gsReportManager, flt_sqlFilter, Db, IBCustomDataSet,
  IBDatabase, Menus, ActnList, ComCtrls,
  ToolWin, ExtCtrls, Grids, DBGrids, gsDBGrid, gsIBGrid, dmDatabase_unit,
  gdcBase, gdcClasses, gdcCurrSellContract, gd_frmG_unit,
  bn_frmMainCurrForm_unit, gdcTree, StdCtrls, TB2Item, TB2Dock, TB2Toolbar,
  gd_MacrosMenu;

type
  Tbn_frmCurrCommissSell = class(Tbn_frmMainCurrForm)
    gdcCurrCommissSell: TgdcCurrCommissSell;
    procedure FormCreate(Sender: TObject);

  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  bn_frmCurrCommissSell: Tbn_frmCurrCommissSell;

implementation

{$R *.DFM}

uses
  gd_security, gd_security_OperationConst,  gd_ClassList;

{ Tbn_frmCurrCommissSell }

class function Tbn_frmCurrCommissSell.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(bn_frmCurrCommissSell) then
    bn_frmCurrCommissSell := Tbn_frmCurrCommissSell.Create(AnOwner);

  Result := bn_frmCurrCommissSell;
end;

procedure Tbn_frmCurrCommissSell.FormCreate(Sender: TObject);
begin
  gdcObject := gdcCurrCommissSell;
  inherited;
end;

initialization
  RegisterFrmClass(Tbn_frmCurrCommissSell);
  //RegisterClass(Tbn_frmCurrCommissSell);


finalization
  UnRegisterFrmClass(Tbn_frmCurrCommissSell);

end.
