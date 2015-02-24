unit TestForm2_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, IBDatabase, Grids, DBGrids, Db, IBCustomDataSet, IBQuery,
  flt_sqlFilter, Menus;

type
  TForm1 = class(TForm)
    IBDatabase1: TIBDatabase;
    IBQuery1: TIBQuery;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    IBTransaction1: TIBTransaction;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    PopupMenu1: TPopupMenu;
    gsQueryFilter1: TgsQueryFilter;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.Button1Click(Sender: TObject);
begin
  IBDatabase1.Connected := False;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  IBTransaction1.Commit;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  IBTransaction1.CommitRetaining;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  IBDatabase1.Connected := True;
  IBQuery1.Open;
end;

end.
