//

unit gdc_frmMDVGR_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmMDH_unit, Db, Menus, ActnList, ComCtrls, ToolWin, ExtCtrls,
  gdc_frmMDHGR_unit, Grids, DBGrids, gsDBGrid, gsIBGrid, IBCustomDataSet,
  gdcBase, gdcConst, TB2Item, TB2Dock, TB2Toolbar, StdCtrls, gd_MacrosMenu;

type
  Tgdc_frmMDVGR = class(Tgdc_frmMDHGR)
  private
  public
  end;

var
  gdc_frmMDVGR: Tgdc_frmMDVGR;

implementation

{$R *.DFM}

uses
  gd_ClassList;

initialization
  RegisterFrmClass(Tgdc_frmMDVGR, 'Master-detail ����� � ��������');

finalization
  UnRegisterFrmClass(Tgdc_frmMDVGR);

end.
