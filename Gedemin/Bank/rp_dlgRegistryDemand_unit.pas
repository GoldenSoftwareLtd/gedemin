// ShlTanya, 30.01.2019

unit rp_dlgRegistryDemand_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Mask, xDateEdits, StdCtrls, ExtCtrls;

type
  TdlgRegistryDemand = class(TForm)
    Bevel1: TBevel;
    btnOk: TButton;
    Label1: TLabel;
    edNumber: TEdit;
    Bevel2: TBevel;
    Label2: TLabel;
    xdeDate1: TxDateEdit;
    Label3: TLabel;
    xdeDate2: TxDateEdit;
    Label4: TLabel;
    xdeDate3: TxDateEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
  public
  end;

var
  dlgRegistryDemand: TdlgRegistryDemand;

implementation

uses
  dmDataBase_unit;

{$R *.DFM}

procedure TdlgRegistryDemand.FormCreate(Sender: TObject);
begin
  xdeDate1.Date := SysUtils.Date;
  xdeDate2.Date := SysUtils.Date;
  xdeDate3.Date := SysUtils.Date;
  edNumber.Text := GlobalStorage.ReadString('\Demand', 'LastRegistryNumber', edNumber.Text);
end;

procedure TdlgRegistryDemand.FormDestroy(Sender: TObject);
begin
  GlobalStorage.WriteString('\Demand', 'LastRegistryNumber', IntToStr(StrToInt(edNumber.Text) + 1));
end;

end.
