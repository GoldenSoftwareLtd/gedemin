unit Bkvol1;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls, Dialogs,
  xWorld;

type
  TVolumeDlg = class(TForm)
    OKBtn: TBitBtn;
    Bevel1: TBevel;
    Memo1: TMemo;
    Edit: TEdit;
    Button1: TButton;
    OpenDialog: TOpenDialog;
    BitBtn1: TBitBtn;
    procedure Button1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  VolumeDlg: TVolumeDlg;

implementation

{$R *.DFM}

uses
  Backup;

procedure TVolumeDlg.Button1Click(Sender: TObject);
begin
  OpenDialog.FileName := Edit.Text;
  if OpenDialog.Execute then
    Edit.text := OpenDialog.FileName;
end;

procedure TVolumeDlg.FormActivate(Sender: TObject);
begin
  Caption := Phrases[lnHVol];
  Edit.SetFocus;
  Memo1.Lines.Clear;
  Memo1.Text := Phrases[lnNextVol];
  Button1.Caption := Phrases[lnBrowse];
  BitBtn1.Caption := Phrases[lnTerminate];
end;

end.
