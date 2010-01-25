unit Bkdir;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls, xWorld;

type
  TCreateDirDlg = class(TForm)
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
  CreateDirDlg: TCreateDirDlg;

implementation

{$R *.DFM}

uses
  backup;

procedure TCreateDirDlg.FormActivate(Sender: TObject);
begin
  Caption := Phrases[lnHCreateDir];
  Edit1.SetFocus;
  Memo1.Lines.Clear;
  Memo1.Text := Phrases[lnNoDir];
  OkBtn.Caption := Phrases[lnCreate];
  BitBtn1.Caption := Phrases[lnCreateAll];
  BitBtn2.Caption := Phrases[lnterminate];
  CancelBtn.Caption := Phrases[lnSkipFile];
end;

end.
