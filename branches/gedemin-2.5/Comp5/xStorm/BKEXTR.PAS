unit Bkextr;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls, Dialogs, SysUtils, xWorld;

type
  TExtractDlg = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    Bevel1: TBevel;
    Memo1: TMemo;
    Edit1: TEdit;
    Button1: TButton;
    SaveDialog1: TSaveDialog;
    Label1: TLabel;
    Label2: TLabel;
    Edit2: TEdit;
    Button2: TButton;
    SaveDialog2: TSaveDialog;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ExtractDlg: TExtractDlg;

implementation

{$R *.DFM}

uses
  Backup;

procedure TExtractDlg.Button1Click(Sender: TObject);
begin
  SaveDialog1.FileName := Edit1.text;
  if SaveDialog1.Execute then
    Edit1.Text := SaveDialog1.FileName;
end;

procedure TExtractDlg.Button2Click(Sender: TObject);
var
  s: string;
begin
  s := Edit2.text;
  if s[length(s)] <> '\' then
    s:= s + '\';
  SaveDialog2.FileName := s + '*.*';
  if SaveDialog2.Execute then
    Edit2.Text := ExtractFilePath(SaveDialog2.FileName);
end;

procedure TExtractDlg.FormActivate(Sender: TObject);
begin
  Caption := Phrases[lnHExtract];
  Edit1.SetFocus;
  Button1.Caption := Phrases[lnBrowse];
  Button2.Caption := Phrases[lnBrowse];
  CancelBtn.Caption := Phrases[lnTerminate];
  Label1.Caption := Phrases[lnArcName];
  Label2.Caption := Phrases[lnExtractDir];
  Memo1.Lines.Clear;
  Memo1.Text := Phrases[lnReadMsg]
end;

procedure TExtractDlg.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if ModalResult = mrOk then
    begin
      if not(FileExists(Edit1.Text)) then
        begin
          MessageDlg(Phrases[lnNoExtractFile], mtError, [mbOk], 0);
          Edit1.SetFocus;
          CanClose := false;
        end;
    end;
end;

end.
