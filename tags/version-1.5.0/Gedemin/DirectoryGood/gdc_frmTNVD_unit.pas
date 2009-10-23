
unit gdc_frmTNVD_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, gd_MacrosMenu, Db, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  ComCtrls, IBCustomDataSet, gdcBase, gdcGood;

type
  Tgdc_frmTNVD = class(Tgdc_frmSGR)
    gdcTNVD: TgdcTNVD;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_frmTNVD: Tgdc_frmTNVD;

implementation

{$R *.DFM}

uses
  gd_ClassList;

procedure Tgdc_frmTNVD.FormCreate(Sender: TObject);
begin
  gdcObject := gdcTNVD;
  inherited;
end;

initialization
  RegisterFRMClass(Tgdc_frmTNVD);

finalization
  UnRegisterFRMClass(Tgdc_frmTNVD);
end.

