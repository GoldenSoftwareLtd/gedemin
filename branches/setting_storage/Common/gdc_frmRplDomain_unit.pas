unit gdc_frmRplDomain_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmMDVGR_unit, gd_MacrosMenu, Db, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  ComCtrls, IBCustomDataSet, gdcBase, gdcReplication;

type
  Tgdc_frmRplDomain = class(Tgdc_frmMDVGR)
    gdcRplDomain: TgdcRplDomain;
    gdcRplDomainClass: TgdcRplDomainClass;
    procedure FormCreate(Sender: TObject);
  public
    { Public declarations }
  end;

var
  gdc_frmRplDomain: Tgdc_frmRplDomain;

implementation

{$R *.DFM}

uses
  gd_ClassList, gdcBaseInterface;

procedure Tgdc_frmRplDomain.FormCreate(Sender: TObject);
begin
  gdcObject := gdcRplDomain;
  gdcDetailObject := gdcRplDomainClass;
  inherited;
end;

initialization
  RegisterFrmClass(Tgdc_frmRplDomain);

finalization
  UnRegisterFrmClass(Tgdc_frmRplDomain);
end.
