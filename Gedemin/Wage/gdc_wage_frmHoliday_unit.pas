// ShlTanya, 29.01.2019

unit gdc_wage_frmHoliday_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, gd_MacrosMenu, Db, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  ComCtrls, IBCustomDataSet, gdcBase, gdcTableCalendar;

type
  Tgdc_wage_frmHoliday = class(Tgdc_frmSGR)
    gdcHoliday: TgdcHoliday;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_wage_frmHoliday: Tgdc_wage_frmHoliday;

implementation

{$R *.DFM}

uses
  gd_ClassList;

procedure Tgdc_wage_frmHoliday.FormCreate(Sender: TObject);
begin
  gdcObject := gdcHoliday;
  inherited;
end;

initialization
  RegisterFrmClass(Tgdc_wage_frmHoliday);

finalization
  UnRegisterFrmClass(Tgdc_wage_frmHoliday);

end.
 
