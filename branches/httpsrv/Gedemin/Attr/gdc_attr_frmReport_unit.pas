unit gdc_attr_frmReport_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, gd_MacrosMenu, Db, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  ComCtrls, IBCustomDataSet, gdcBase, gdcMetaData, gdcReport;

type
  Tgdc_frmReport = class(Tgdc_frmSGR)
    gdcReport: TgdcReport;
    procedure FormCreate(Sender: TObject);

  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  gdc_frmReport: Tgdc_frmReport;

implementation

{$R *.DFM}

uses
  gd_ClassList;

class function Tgdc_frmReport.CreateAndAssign(AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gdc_frmReport) then
    gdc_frmReport := Tgdc_frmReport.Create(AnOwner);
  Result := gdc_frmReport;
end;

procedure Tgdc_frmReport.FormCreate(Sender: TObject);
begin
  gdcObject := gdcReport;
  inherited;
end;


initialization
  RegisterFrmClass(Tgdc_frmReport);
  //RegisterClass(Tgdc_frmReport);
finalization
  UnRegisterFrmClass(Tgdc_frmReport);

end.
