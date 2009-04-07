unit Bklist;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, xWorld;

type
  TListDlg = class(TForm)
    OKBtn: TBitBtn;
    Memo1: TMemo;
    xx: TLabel;
    Edit1: TEdit;
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ListDlg: TListDlg;

implementation

{$R *.DFM}

uses
  backup;

procedure TListDlg.FormActivate(Sender: TObject);
begin
  Caption := Phrases[lnHFiles];
  Memo1.SetFocus;
  xx.Caption := Phrases[lnFilesIn];
end;

end.
