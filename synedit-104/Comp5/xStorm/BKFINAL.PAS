unit Bkfinal;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls, xWorld;

type
  TFinalDlg = class(TForm)
    OKBtn: TBitBtn;
    Bevel1: TBevel;
    Memo1: TMemo;
    Image1: TImage;
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FinalDlg: TFinalDlg;

implementation

{$R *.DFM}

uses
  backup;

procedure TFinalDlg.FormActivate(Sender: TObject);
begin
  Caption := Phrases[lnHCreated];
  Memo1.Lines.Clear;
  Memo1.Text := Phrases[lnFinalCreate];
end;

end.
