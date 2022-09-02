// ShlTanya, 21.02.2019

unit gdc_frmMDVGR2_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmMDV_unit, Db, flt_sqlFilter, Menus, ActnList, ComCtrls, ToolWin,
  ExtCtrls, TB2Item, TB2Dock, TB2Toolbar, gd_MacrosMenu, Grids, DBGrids,
  gsDBGrid, gsIBGrid, StdCtrls;

type
  Tgdc_frmMDVGR2 = class(Tgdc_frmMDV)
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_frmMDVGR2: Tgdc_frmMDVGR2;

implementation

{$R *.DFM}

uses
  gd_ClassList;

initialization
  RegisterFrmClass(Tgdc_frmMDVGR2).AbstractBaseForm := True;

finalization
  UnRegisterFrmClass(Tgdc_frmMDVGR2);
end.
