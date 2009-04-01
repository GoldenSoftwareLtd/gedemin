unit ct_viewer_main_form;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, ExtCtrls, Db, IBCustomDataSet, IBQuery, IBDatabase, Grids,
  DBGrids, gsDBGrid, StdCtrls, DBCtrls;

type
  TForm1 = class(TForm)
    ControlBar1: TControlBar;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    gsDBGrid1: TgsDBGrid;
    IBDatabase: TIBDatabase;
    IBTransaction: TIBTransaction;
    qryUnit: TIBQuery;
    dsUnit: TDataSource;
    TabSheet2: TTabSheet;
    gsDBGrid2: TgsDBGrid;
    qryVar: TIBQuery;
    dsVars: TDataSource;
    Button1: TButton;
    DBMemo1: TDBMemo;
    DBMemo2: TDBMemo;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

uses
  ct_frmblob;

procedure TForm1.FormCreate(Sender: TObject);
begin
  IBDatabase.Connected := True;
  qryUnit.Open;
  qryVar.Open;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  with TfrmBlob.Create(Self) do
  begin
    dsMemo.DataSet := qryUnit;
    dbmemo.DataField := 'source';
    Caption := qryUnit.FieldByName('name').AsString;
    Show;
  end;
end;

end.
