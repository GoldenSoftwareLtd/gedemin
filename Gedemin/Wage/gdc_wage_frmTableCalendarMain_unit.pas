// ShlTanya, 29.01.2019

unit gdc_wage_frmTableCalendarMain_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmMDVGR_unit, gd_MacrosMenu, Db, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  ComCtrls, gdcTableCalendar, IBCustomDataSet, gdcBase;

type
  Tgdc_wage_frmTableCalendarMain = class(Tgdc_frmMDVGR)
    gdcTableCalendar: TgdcTableCalendar;
    gdcTableCalendarDay: TgdcTableCalendarDay;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_wage_frmTableCalendarMain: Tgdc_wage_frmTableCalendarMain;

implementation

{$R *.DFM}

uses
  gd_ClassList;

procedure Tgdc_wage_frmTableCalendarMain.FormCreate(Sender: TObject);
begin
  gdcObject := gdcTableCalendar;
  gdcDetailObject := gdcTableCalendarDay;
  inherited;
end;

initialization
  RegisterFrmClass(Tgdc_wage_frmTableCalendarMain, 'Графики рабочего времени');

finalization
  UnRegisterFrmClass(Tgdc_wage_frmTableCalendarMain);
end.
