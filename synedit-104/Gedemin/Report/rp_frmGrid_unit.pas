unit rp_frmGrid_unit;

interface

uses 
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, Grids, DBGrids, gsDBGrid;

type
  TfrmGrid = class(TFrame)
    dbgSource: TgsDBGrid;
    dsSource: TDataSource;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.DFM}

end.
