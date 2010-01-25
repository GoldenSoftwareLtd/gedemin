unit Bkcreate;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls, Dialogs, xWorld;

type
  TCreateDlg = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    Bevel1: TBevel;
    Memo1: TMemo;
    Edit1: TEdit;
    Button1: TButton;
    SaveDialog1: TSaveDialog;
    procedure Button1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    isFirst: Boolean;
  public
    { Public declarations }
  end;

var
  CreateDlg: TCreateDlg;

implementation

{$R *.DFM}

uses
  backup;

procedure TCreateDlg.Button1Click(Sender: TObject);
begin
{  Application.NormalizeTopMosts;}
  SaveDialog1.FileName := Edit1.text;
  if SaveDialog1.Execute then
    Edit1.Text := SaveDialog1.FileName;
{  Application.RestoreTopMosts;
  SetFocus;}
end;

procedure TCreateDlg.FormActivate(Sender: TObject);
begin
  if not isFirst then exit;
  Caption := Phrases[lnHCreate];
  Edit1.SetFocus;
  Memo1.Lines.Clear;
  Memo1.Text := Phrases[lnCreateMsg];
  Button1.Caption := Phrases[lnBrowse];
  CancelBtn.Caption := Phrases[lnTerminate];
  isFirst:= False;
end;

procedure TCreateDlg.FormCreate(Sender: TObject);
begin
  isFirst:= True;
end;

end.
