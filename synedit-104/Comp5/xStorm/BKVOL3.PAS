unit Bkvol3;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls, Dialogs, xWorld;

type
  TVolumeRpDlg = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    Bevel1: TBevel;
    Memo1: TMemo;
    Edit: TEdit;
    Button1: TButton;
    OpenDialog: TOpenDialog;
    BitBtn1: TBitBtn;
    procedure Button1Click(Sender: TObject);
    procedure EditChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  VolumeRpDlg: TVolumeRpDlg;

implementation

{$R *.DFM}

uses
  Backup;

procedure TVolumeRpDlg.Button1Click(Sender: TObject);
begin
  OpenDialog.FileName := Edit.Text;
  if OpenDialog.Execute then
    Edit.text := OpenDialog.FileName;
end;

procedure TVolumeRpDlg.EditChange(Sender: TObject);
begin
  OkBtn.Enabled := false;
end;

procedure TVolumeRpDlg.FormActivate(Sender: TObject);
begin
  Caption := Phrases[lnHVolExists];
  Memo1.Lines.Clear;
  Memo1.Text := Phrases[lnReplaceMsg];
  Button1.Caption := Phrases[lnBrowse];
  BitBtn1.Caption := Phrases[lnTerminate];
  OKBtn.Enabled := true;
  Edit.SetFocus;
end;

end.
