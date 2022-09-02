// ShlTanya, 21.02.2019

unit gdc_frmMDVTree2_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmMDV_unit, Db, flt_sqlFilter, Menus, ActnList, ComCtrls, ToolWin,
  ExtCtrls, TB2Item, TB2Dock, TB2Toolbar, StdCtrls, gd_MacrosMenu, Grids,
  DBGrids, gsDBGrid, gsIBGrid;

type
  Tgdc_frmMDVTree2 = class(Tgdc_frmMDV)
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_frmMDVTree2: Tgdc_frmMDVTree2;

implementation

{$R *.DFM}

uses
  gd_ClassList;

initialization
  RegisterFrmClass(Tgdc_frmMDVTree2).AbstractBaseForm := True;

finalization
  UnRegisterFrmClass(Tgdc_frmMDVTree2);
end.
