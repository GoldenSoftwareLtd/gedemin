unit Bkover;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls, xWorld;

type
  TOverDlg = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    Bevel1: TBevel;
    Memo1: TMemo;
    Edit1: TEdit;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  OverDlg: TOverDlg;

implementation

{$R *.DFM}

uses
  backup;

procedure TOverDlg.FormActivate(Sender: TObject);
begin
  Caption := Phrases[lnHOver];
  Edit1.SetFocus;
  Memo1.Lines.Clear;
  Memo1.Text := Phrases[lnOverWriteMsg];
  OkBtn.CAption := Phrases[lnOverwrite];
  BitBtn1.Caption := Phrases[lnOverwriteAll];
  BitBtn2.Caption := Phrases[lnterminate];
  CancelBtn.CAption := Phrases[lnSkipFile];
end;

end.
