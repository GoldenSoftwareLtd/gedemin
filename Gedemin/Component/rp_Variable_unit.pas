// ShlTanya, 20.02.2019

unit rp_Variable_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, Grids, DBGrids, gsDBGrid, StdCtrls, ExtCtrls;

type
  TfrmVariable = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Splitter1: TSplitter;
    Panel3: TPanel;
    Memo: TMemo;
    dbgVariable: TgsDBGrid;
    dsVariable: TDataSource;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmVariable: TfrmVariable;

implementation

{$R *.DFM}

end.
