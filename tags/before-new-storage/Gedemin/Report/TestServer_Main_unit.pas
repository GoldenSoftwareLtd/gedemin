unit TestServer_Main_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, rp_BaseReport_unit, IBDatabase, Db, IBCustomDataSet, IBQuery;

type
  TForm1 = class(TForm)
    Button1: TButton;
    IBDatabase1: TIBDatabase;
    IBTransaction1: TIBTransaction;
    IBQuery1: TIBQuery;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    FReportList: TReportList;

    procedure HHH;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.Button1Click(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to 10 do
    FReportList.Refresh;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  IBDatabase1.Connected := True;
//  IBTransaction1.StartTransaction;
  FReportList := TReportList.Create;
  FReportList.Database := IBDatabase1;
  FReportList.Transaction := IBTransaction1;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FReportList.Free;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  HHH;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  FreeAndNil(FReportList);
  FReportList := TReportList.Create;
  FReportList.Database := IBDatabase1;
  FReportList.Transaction := IBTransaction1;
end;

procedure TForm1.Button4Click(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to 100 do
  begin
    IBQuery1.SQL.Text := 'SELECT * FROM rp_reportlist';
    IBQuery1.Open;
    IBQuery1.Last;
    IBQuery1.Close;
  end;
end;

procedure TForm1.HHH;
var
  I: Integer;
  ibqryT: TDataSet;
begin
  for I := 0 to 10000 do
  begin
    ibqryT := TIBQuery.Create(nil);
    try
{      ibqryT.SQL.Text := 'SELECT * FROM rp_reportlist';
      ibqryT.Database := IBDatabase1;
      ibqryT.Transaction := IBTransaction1;
      ibqryT.Open;
      ibqryT.Last;
      ibqryT.Close;}
    finally
      ibqryT.Free;
    end;
  end;
end;

end.
