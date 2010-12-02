unit tsf_MaimForm_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, IBDatabase, Db, IBCustomDataSet, IBQuery, Grids, DBGrids,
  flt_sqlFilter;

type
  TForm1 = class(TForm)
    DBGrid1: TDBGrid;
    DataSource1: TDataSource;
    IBDatabase1: TIBDatabase;
    IBQuery1: TIBQuery;
    IBTransaction1: TIBTransaction;
    Button1: TButton;
    gsQueryFilter1: TgsQueryFilter;
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

procedure TForm1.FormCreate(Sender: TObject);
begin
  IBDatabase1.Connected := True;
  IBQuery1.Open;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  gsQueryFilter1.PopupMenu;
end;

end.
