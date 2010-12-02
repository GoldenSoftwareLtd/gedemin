unit gdc_frmAcctBaseConfig_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, gd_MacrosMenu, Db, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  ComCtrls, IBCustomDataSet, gdcBase, gdcLedger, gd_ClassList;

type
  Tgdc_frmAcctBaseConfig = class(Tgdc_frmSGR)
    gdcAcctBaseConfig: TgdcAcctBaseConfig;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_frmAcctBaseConfig: Tgdc_frmAcctBaseConfig;

implementation

{$R *.DFM}

procedure Tgdc_frmAcctBaseConfig.FormCreate(Sender: TObject);
begin
  inherited;
  gdcObject := gdcAcctBaseConfig;
  gdcObject.Open;
end;

initialization
  RegisterFrmClass(Tgdc_frmAcctBaseConfig);
finalization
  UnRegisterFrmClass(Tgdc_frmAcctBaseConfig);
end.
