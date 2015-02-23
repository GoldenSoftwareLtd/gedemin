unit Bkfinal1;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls, xWorld;

type
  TFinal1Dlg = class(TForm)
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
  Final1Dlg: TFinal1Dlg;

implementation

{$R *.DFM}

uses
  backup;

procedure TFinal1Dlg.FormActivate(Sender: TObject);
begin
  Caption := Phrases[lnHExtracted];
  Memo1.Lines.Clear;
  Memo1.TExt := Phrases[lnReadFinal];
end;

end.
