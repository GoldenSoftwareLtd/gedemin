unit gdc_frmInvCardConfig_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, gd_MacrosMenu, Db, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  ComCtrls, IBCustomDataSet, gdcBase, gdcInvMovement;

type
  Tgdc_frmInvCardConfig = class(Tgdc_frmSGR)
    gdcInvCardConfig: TgdcInvCardConfig;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_frmInvCardConfig: Tgdc_frmInvCardConfig;

implementation

{$R *.DFM}

uses
  gd_ClassList;

procedure Tgdc_frmInvCardConfig.FormCreate(Sender: TObject);
begin
  gdcObject := gdcInvCardConfig;
  inherited;
end;

initialization
  RegisterFrmClass(Tgdc_frmInvCardConfig);

finalization
  UnRegisterFrmClass(Tgdc_frmInvCardConfig);

end.
