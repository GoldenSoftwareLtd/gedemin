// ShlTanya, 09.03.2019

unit gdc_frmAcctGeneralLedger_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, gd_MacrosMenu, Db, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  ComCtrls, IBCustomDataSet, gdcBase, gdcLedger, gd_ClassList,
  gdcAcctConfig;

type
  Tgdc_frmAcctGeneralLedger = class(Tgdc_frmSGR)
    gdcAcctGeneralLedgerConfig: TgdcAcctGeneralLedgerConfig;
    procedure FormCreate(Sender: TObject);
  private
  public
  end;

var
  gdc_frmAcctGeneralLedger: Tgdc_frmAcctGeneralLedger;

implementation

{$R *.DFM}
procedure Tgdc_frmAcctGeneralLedger.FormCreate(Sender: TObject);
begin
  inherited;
  gdcObject := gdcAcctGeneralLedgerConfig;
  gdcObject.Open;
end;

initialization
  RegisterFrmClass(Tgdc_frmAcctGeneralLedger);
finalization
  UnRegisterFrmClass(Tgdc_frmAcctGeneralLedger);

end.
