// ShlTanya, 30.01.2019

unit rp_dlgReducePayment_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Mask, xDateEdits, StdCtrls, ExtCtrls;

type
  TdlgReducePayment = class(TForm)
    Bevel1: TBevel;
    btnOk: TButton;
    Label1: TLabel;
    edNumber: TEdit;
    Bevel2: TBevel;
    Label2: TLabel;
    xdeDate: TxDateEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
  public
  end;

var
  dlgReducePayment: TdlgReducePayment;

implementation

uses
  dmDataBase_unit;

{$R *.DFM}

procedure TdlgReducePayment.FormCreate(Sender: TObject);
begin
  xdeDate.Date := SysUtils.Date;
  edNumber.Text := GlobalStorage.ReadString('\Payment', 'LastReduceNumber', edNumber.Text);
end;

procedure TdlgReducePayment.FormDestroy(Sender: TObject);
begin
  GlobalStorage.WriteString('\Demand', 'LastReduceNumber', IntToStr(StrToInt(edNumber.Text) + 1));
end;

end.
