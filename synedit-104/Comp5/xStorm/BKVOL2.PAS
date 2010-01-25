unit Bkvol2;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls, Dialogs, xWorld;

type
  TVolumeErDlg = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    Bevel1: TBevel;
    Memo1: TMemo;
    Edit: TEdit;
    Button1: TButton;
    OpenDialog: TOpenDialog;
    procedure Button1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  VolumeErDlg: TVolumeErDlg;

implementation

{$R *.DFM}

uses
  Backup;

procedure TVolumeErDlg.Button1Click(Sender: TObject);
begin
  OpenDialog.FileName := Edit.Text;
  if OpenDialog.Execute then
    Edit.text := OpenDialog.FileName;
end;

procedure TVolumeErDlg.FormActivate(Sender: TObject);
begin
  Caption := Phrases[lnHVolEr];
  Edit.SetFocus;
  Memo1.Lines.Clear;
  Memo1.Text := Phrases[lnAccessError];
  Button1.Caption := Phrases[lnBrowse];
  CancelBtn.Caption := Phrases[lnterminate];
end;

end.
