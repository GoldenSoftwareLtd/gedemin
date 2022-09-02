// ShlTanya, 30.01.2019

unit bn_frmCurrListAllocation_unit;

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
  Tbn_frmCurrListAllocation = class(Tbn_frmMainCurrForm)
    gdcCurrListAllocation: TgdcCurrListAllocation;
    procedure FormCreate(Sender: TObject);

  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  bn_frmCurrListAllocation: Tbn_frmCurrListAllocation;

implementation

{$R *.DFM}

uses
  gd_security, gd_security_OperationConst,  gd_ClassList;

{ Tbn_frmCurrListAllocation }

class function Tbn_frmCurrListAllocation.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(bn_frmCurrListAllocation) then
    bn_frmCurrListAllocation := Tbn_frmCurrListAllocation.Create(AnOwner);

  Result := bn_frmCurrListAllocation;
end;

procedure Tbn_frmCurrListAllocation.FormCreate(Sender: TObject);
begin
  gdcObject := gdcCurrListAllocation;
  inherited;
end;

initialization
  RegisterFrmClass(Tbn_frmCurrListAllocation);
  //RegisterClass(Tbn_frmCurrListAllocation);


finalization
  UnRegisterFrmClass(Tbn_frmCurrListAllocation);

end.
