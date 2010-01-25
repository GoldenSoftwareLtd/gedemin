unit gdc_frmSQLHistory_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, gd_MacrosMenu, Db, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  ComCtrls, IBCustomDataSet, gdcBase, gdcSQLHistory;

type
  Tgdc_frmSQLHistory = class(Tgdc_frmSGR)
    gdcSQLHistory: TgdcSQLHistory;
    procedure FormCreate(Sender: TObject);
  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  gdc_frmSQLHistory: Tgdc_frmSQLHistory;

implementation

{$R *.DFM}

uses
  gd_ClassList;

class function Tgdc_frmSQLHistory.CreateAndAssign(AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gdc_frmSQLHistory) then
    gdc_frmSQLHistory := Tgdc_frmSQLHistory.Create(AnOwner);
  Result := gdc_frmSQLHistory;
end;

procedure Tgdc_frmSQLHistory.FormCreate(Sender: TObject);
begin
  gdcObject := gdcSQLHistory;
  inherited;
end;

initialization
  RegisterFrmClass(Tgdc_frmSQLHistory);

finalization
  UnRegisterFrmClass(Tgdc_frmSQLHistory);

end.
