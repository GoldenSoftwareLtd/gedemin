// ShlTanya, 09.03.2019

unit gdc_frmAcctLedger_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, gd_MacrosMenu, Db, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  ComCtrls, IBCustomDataSet, gdcBase, gdcLedger, gd_ClassList,
  gdcAcctConfig;

type
  Tgdc_frmAcctLedger = class(Tgdc_frmSGR)
    gdcAcctLedgerConfig: TgdcAcctLedgerConfig;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_frmAcctLedger: Tgdc_frmAcctLedger;

implementation

{$R *.DFM}

procedure Tgdc_frmAcctLedger.FormCreate(Sender: TObject);
begin
  inherited;
  gdcObject := gdcAcctLedgerConfig;
  gdcObject.Open;
end;
initialization
  RegisterFrmClass(Tgdc_frmAcctLedger);
finalization
  UnRegisterFrmClass(Tgdc_frmAcctLedger);
end.
