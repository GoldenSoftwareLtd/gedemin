// ShlTanya, 30.01.2019

unit bn_frmCurrConvContract_unit;

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
  Tbn_frmCurrConvContract = class(Tbn_frmMainCurrForm)
    gdcCurrConvContract: TgdcCurrConvContract;
    procedure FormCreate(Sender: TObject);

  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  bn_frmCurrConvContract: Tbn_frmCurrConvContract;

implementation

{$R *.DFM}

uses
  gd_security, gd_security_OperationConst,  gd_ClassList;

{ Tbn_frmCurrConvContract }

class function Tbn_frmCurrConvContract.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(bn_frmCurrConvContract) then
    bn_frmCurrConvContract := Tbn_frmCurrConvContract.Create(AnOwner);

  Result := bn_frmCurrConvContract;
end;


procedure Tbn_frmCurrConvContract.FormCreate(Sender: TObject);
begin
  gdcObject := gdcCurrConvContract;
  inherited;
end;

initialization
  RegisterFrmClass(Tbn_frmCurrConvContract);
  //RegisterClass(Tbn_frmCurrConvContract);


finalization
  UnRegisterFrmClass(Tbn_frmCurrConvContract);

end.
