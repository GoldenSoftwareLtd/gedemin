unit TestPeriodEdit_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gsPeriodEdit, StdCtrls, Buttons, xCalculatorEdit, DBCtrls;

type
  TForm1 = class(TForm)
    gsPeriodEdit: TgsPeriodEdit;
    Edit1: TEdit;
    SpeedButton1: TSpeedButton;
    Label1: TLabel;
    Label2: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure gsPeriodEditChange(Sender: TObject);
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
  gsDatePeriod, gdAccessGrid;

procedure TForm1.FormCreate(Sender: TObject);
begin
  with TgdAccessGrid.Create(Self) do
  begin
    Parent := Self;
    Left := 20;
    Top := 100;
  end;
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
begin
  gsPeriodEditChange(nil);
end;

procedure TForm1.gsPeriodEditChange(Sender: TObject);
var
  P: TgsDatePeriod;
begin
  P := TgsDatePeriod.Create;
  try
    Label1.Caption := gsPeriodEdit.DatePeriod.EncodeString;
    P.Assign(gsPeriodEdit.DatePeriod);
    P.Kind := dpkFree;
    Label2.Caption := P.EncodeString;
  finally
    P.Free;
  end;
end;

end.
