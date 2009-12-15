unit Bkcmnt2;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls, xWorld;

type
  TSeeComment = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    Bevel1: TBevel;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SeeComment: TSeeComment;

implementation

{$R *.DFM}

uses
  Backup;

procedure TSeeComment.FormActivate(Sender: TObject);
begin
  Caption := Phrases[lnHComment];
  Edit1.SetFocus;
  CancelBtn.Caption := Phrases[lnTerminate];
  Label1.Caption := Phrases[lnGetComment1];
  Label2.Caption := Phrases[lnGetComment2];
end;

end.
