unit gdc_frmInvRemainsOption_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, gd_MacrosMenu, Db, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  ComCtrls, IBCustomDataSet, gdcBase, gdcInvMovement;

type
  Tgdc_frmInvRemainsOption = class(Tgdc_frmSGR)
    gdcInvRemainsOption: TgdcInvRemainsOption;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_frmInvRemainsOption: Tgdc_frmInvRemainsOption;

implementation

{$R *.DFM}

uses
  gd_ClassList;

procedure Tgdc_frmInvRemainsOption.FormCreate(Sender: TObject);
begin
  gdcObject := gdcInvRemainsOption;
  inherited;
end;

initialization
  RegisterFrmClass(Tgdc_frmInvRemainsOption);

finalization
  UnRegisterFrmClass(Tgdc_frmInvRemainsOption);


end.
