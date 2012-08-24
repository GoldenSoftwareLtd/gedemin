unit Xuperr;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls,
  xWorld, xMemo;

type
  TErrorsDlg = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    Bevel1: TBevel;
    GroupBox1: TGroupBox;
    Errors: TMemo;
    TableNameLabel: TLabel;
    TableName: TLabel;
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ErrorsDlg: TErrorsDlg;

implementation

{$R *.DFM}

uses
  xUpgrade;

procedure TErrorsDlg.FormActivate(Sender: TObject);
begin
  GroupBox1.Caption := Phrases[lnErrsWars];
  TableNameLabel.Caption := Phrases[lnTableName];
  OkBtn.Caption := Phrases[lnCopy];
  CancelBtn.Caption := Phrases[lnSkip];
end;

end.
