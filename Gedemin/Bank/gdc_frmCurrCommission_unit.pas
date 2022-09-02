// ShlTanya, 30.01.2019

unit gdc_frmCurrCommission_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmG_unit, Grids, DBGrids, gsDBGrid, gsIBGrid, Db, flt_sqlFilter,
  Menus, ActnList, ComCtrls, ToolWin, ExtCtrls, IBDatabase,
  IBCustomDataSet, gdcBase, gdcClasses, gdcCurrCommission, StdCtrls,
  gsIBLookupComboBox, gd_security, gd_security_body, gdc_frmSGRAccount_unit,
  gdcPayment, gsTransaction, TB2Dock, TB2Item, TB2Toolbar, gdcTree,
  gdcBaseBank, gd_MacrosMenu;

type
  Tgdc_frmCurrCommission = class(Tgdc_frmSGRAccount)
    gdcCurrCommission: TgdcCurrCommission;
    Panel1: TPanel;
    Label2: TLabel;
    lblCurrency: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure gdcCurrCommissionAfterScroll(DataSet: TDataSet);

  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  gdc_frmCurrCommission: Tgdc_frmCurrCommission;

implementation

uses dmDataBase_unit,  gd_ClassList;

{$R *.DFM}

{ Tgdc_frmCurrCommission }

class function Tgdc_frmCurrCommission.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gdc_frmCurrCommission) then
    gdc_frmCurrCommission := Tgdc_frmCurrCommission.Create(AnOwner);

  Result := gdc_frmCurrCommission;
end;

procedure Tgdc_frmCurrCommission.FormCreate(Sender: TObject);
begin
  gdcObject := gdcCurrCommission;
  inherited;
end;

procedure Tgdc_frmCurrCommission.gdcCurrCommissionAfterScroll(
  DataSet: TDataSet);
begin
  inherited;
  lblCurrency.Caption := gdcCurrCommission.GetCurrencyByAccount(ibcmbAccount.CurrentKeyInt);
end;

initialization
  RegisterFrmClass(Tgdc_frmCurrCommission);
  //RegisterClass(Tgdc_frmCurrCommission);

finalization
  UnRegisterFrmClass(Tgdc_frmCurrCommission);

end.
