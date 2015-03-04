unit Xupbfin;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls,
  xWorld;

type
  TBadFinal = class(TForm)
    OKBtn: TBitBtn;
    GroupBox1: TGroupBox;
    Stat: TMemo;
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  BadFinal: TBadFinal;

implementation

{$R *.DFM}
  uses
    xUpgrade;

procedure TBadFinal.FormActivate(Sender: TObject);
begin
  GroupBox1.Caption := Phrases[ lnBadFinal ];
end;

end.
