unit at_frmNSRecursion_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_createable_form, dmDatabase_unit, dmImages_unit, IBDatabase, Grids,
  DBGrids, gsDBGrid, gsIBGrid, TB2Dock, TB2Toolbar, ComCtrls, Db,
  IBCustomDataSet;

type
  Tat_frmNSRecursion = class(TCreateableForm)
    sb: TStatusBar;
    TBDock: TTBDock;
    tb: TTBToolbar;
    gsIBGrid: TgsIBGrid;
    ibtr: TIBTransaction;
    ibds: TIBDataSet;
    ds: TDataSource;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  at_frmNSRecursion: Tat_frmNSRecursion;

implementation

{$R *.DFM}

end.
