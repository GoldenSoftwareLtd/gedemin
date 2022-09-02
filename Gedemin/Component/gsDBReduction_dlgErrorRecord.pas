// ShlTanya, 17.02.2019

unit gsDBReduction_dlgErrorRecord;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Db, IBCustomDataSet, IBQuery, Grids, DBGrids,
  gsDBGrid, gsIBGrid;

type
  TdlgErrorRecord = class(TForm)
    Panel2: TPanel;
    Panel1: TPanel;
    Panel3: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Panel4: TPanel;
    btnDel: TButton;
    btnCancel: TButton;
    dbgErrorRecord: TgsIBGrid;
    qryErrorRecord: TIBQuery;
    dsErrorRecord: TDataSource;
    lbTable: TLabel;
  private
  public
  end;

var
  dlgErrorRecord: TdlgErrorRecord;

implementation

{$R *.DFM}

end.
