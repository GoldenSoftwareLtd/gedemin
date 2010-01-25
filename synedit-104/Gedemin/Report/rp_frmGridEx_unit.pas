unit rp_frmGridEx_unit;

interface

uses 
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, DBGrids, gsDBGrid, Db;

type
  TfrmGridEx = class(TFrame)
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
