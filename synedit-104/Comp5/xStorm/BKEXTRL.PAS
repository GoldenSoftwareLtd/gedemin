unit Bkextrl;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls, Dialogs, SysUtils, xWorld;

type
  TExtractListDlg = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    Bevel1: TBevel;
    Memo1: TMemo;
    Edit1: TEdit;
    Button1: TButton;
    SaveDialog1: TSaveDialog;
    procedure Button1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ExtractListDlg: TExtractListDlg;

implementation

{$R *.DFM}

uses
  backup;

procedure TExtractListDlg.Button1Click(Sender: TObject);
begin
  SaveDialog1.FileName := Edit1.text;
  if SaveDialog1.Execute then
    Edit1.Text := SaveDialog1.FileName;
end;

procedure TExtractListDlg.FormActivate(Sender: TObject);
begin
  Caption := Phrases[lnHReadList];
  Edit1.SetFocus;
  Memo1.Lines.Clear;
  Memo1.Text := Phrases[lnExtrList];
  Button1.Caption := Phrases[lnBrowse];
  CancelBtn.Caption := Phrases[lnTerminate];
end;

procedure TExtractListDlg.FormCloseQuery(Sender: TObject;
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
