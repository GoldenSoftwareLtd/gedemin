// ShlTanya, 03.02.2019

unit gdc_frmSMTP_Unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, gd_MacrosMenu, Db, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  ComCtrls, IBCustomDataSet, gdcBase, gdcSMTP;

type
  Tgdc_frmSMTP = class(Tgdc_frmSGR)
    gdcSMTP: TgdcSMTP;
    procedure FormCreate(Sender: TObject);
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
  RegisterFrmClass(Tgdc_frmSMTP, 'Учетные записи SMTP');

finalization
  UnRegisterFrmClass(Tgdc_frmSMTP);
end.
