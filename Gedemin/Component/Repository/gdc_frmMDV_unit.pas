//

unit gdc_frmMDV_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmMDH_unit, IBDatabase, Db, gsReportManager, flt_sqlFilter, Menus,
  ActnList,  ComCtrls, ToolWin, ExtCtrls, IBCustomDataSet, gdcBase,
  gdcConst, TB2Item, TB2Dock, TB2Toolbar, StdCtrls, gd_MacrosMenu, Grids,
  DBGrids, gsDBGrid, gsIBGrid;

type
  Tgdc_frmMDV = class(Tgdc_frmMDH)
  private
  public
  end;

var
  gdc_frmMDV: Tgdc_frmMDV;

implementation

{$R *.DFM}

uses
  gd_ClassList;

initialization
  RegisterFrmClass(Tgdc_frmMDV, 'Master-detail форма (верт.)').AbstractBaseForm := True;

finalization
  UnRegisterFrmClass(Tgdc_frmMDV);
end.
