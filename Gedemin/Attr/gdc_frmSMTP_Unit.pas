unit gdc_frmSMTP_Unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, gd_MacrosMenu, Db, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  ComCtrls, IBCustomDataSet, gdcBase, gdc_SMTP;

type
  Tgdc_frmSMTP = class(Tgdc_frmSGR)
    gdcSMTP: TgdcSMTP;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_frmSMTP: Tgdc_frmSMTP;

implementation

{$R *.DFM}

uses
  gd_ClassList;

procedure Tgdc_frmSMTP.FormCreate(Sender: TObject);
begin
  gdcObject := gdcSMTP;

  inherited;
end;

initialization
  RegisterFrmClass(Tgdc_frmSMTP, 'Почтовые ящики');

finalization
  UnRegisterFrmClass(Tgdc_frmSMTP);

end.
