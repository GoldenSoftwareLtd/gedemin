unit MainForm3_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  flt_sqlFilter, IBCustomDataSet, Db, IBQuery, ExtCtrls, Grids, DBGrids,
  Menus, gsDBGrid, gsIBGrid, StdCtrls, gd_security;

type
  TForm1 = class(TForm)
    Splitter1: TSplitter;
    DataSource1: TDataSource;
    DataSource2: TDataSource;
    IBQuery1: TIBQuery;
    IBDataSet1: TIBDataSet;
    gsQueryFilter1: TgsQueryFilter;
    gsQueryFilter2: TgsQueryFilter;
    PopupMenu1: TPopupMenu;
    PopupMenu2: TPopupMenu;
    gsIBGrid1: TgsIBGrid;
    gsIBGrid2: TgsIBGrid;
    Panel1: TPanel;
    Edit1: TEdit;
    Edit2: TEdit;
    Button1: TButton;
    boAccess1: TboAccess;
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

uses dmDataBase_unit, gd_security_OperationConst;

{$R *.DFM}

procedure TForm1.FormCreate(Sender: TObject);
begin
  IBLogin.SubSystemKey := GD_SYS_GADMIN;
  if not IBLogin.Login then
    Application.Terminate
  else
  begin
    if not dmDatabase.ibtrAttr.InTransaction then
      dmDatabase.ibtrAttr.StartTransaction;
    IBQuery1.Params[0].AsInteger := 1;
    IBQuery1.Params[1].AsInteger := 500;
    IBQuery1.Open;
    IBDataSet1.Params[0].AsInteger := 1;
    IBDataSet1.Params[1].AsInteger := 500;
    IBDataSet1.Open;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  IBQuery1.Close;
  try
    IBQuery1.Params[0].AsString := Edit1.Text;
    IBQuery1.Params[1].AsString := Edit2.Text;
  finally
    IBQuery1.Open;
  end;
  IBDataSet1.Close;
  try
    IBDataSet1.Params[0].AsString := Edit1.Text;
    IBDataSet1.Params[1].AsString := Edit2.Text;
  finally
    IBDataSet1.Open;
  end;
end;

end.
