unit Bkcmnt1;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls, xWorld;

type
  TNewComment = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    Bevel1: TBevel;
    Memo1: TMemo;
    Edit1: TEdit;
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  NewComment: TNewComment;

implementation

{$R *.DFM}

uses
  backup;

procedure TNewComment.FormActivate(Sender: TObject);
begin
  Caption := Phrases[lnHComment];
  Edit1.SetFocus;
  CancelBtn.Caption := Phrases[lnTerminate];
  Memo1.Lines.Clear;
  Memo1.Text := Phrases[lnSetComment];
end;

end.
