{
  Form for the intern.pas
  (C) Golden Software of Belarus
  Author: Vladimir Belyi
  1996, August-September
}

unit xWo_add;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls, Dialogs;

type
  TNewLang = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    Bevel1: TBevel;
    Label1: TLabel;
    Edit1: TEdit;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    ALanguage: string;
  end;

var
  NewLang: TNewLang;

implementation

{$R *.DFM}

uses xWorld;

procedure TNewLang.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if (ModalResult = mrOk) and (Edit1.Text <> '') then
   if Phrases.FindLanguage( Edit1.Text ) <> -1 then
     begin
       MessageDlg('Language ' + Edit1.Text +
                  ' already exists and can not be added',
                  mtError, [mbOk], 0);
       CanClose := false;
     end
   else
     begin
       Phrases.RegisterLanguage( Edit1.Text );
       ALanguage := Edit1.Text;
     end;
end;

procedure TNewLang.FormActivate(Sender: TObject);
begin
  ALanguage := '';
  Edit1.SetFocus;
end;

end.
