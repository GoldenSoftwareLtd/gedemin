unit gd_setup_dlgInputPassword;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TdlgInputPassword = class(TForm)
    btnOk: TButton;
    btnCancel: TButton;
    Label1: TLabel;
    Label2: TLabel;
    edPassword: TEdit;
    Memo: TMemo;
    Timer1: TTimer;
    lbKL: TLabel;
    procedure edPasswordChange(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dlgInputPassword: TdlgInputPassword;

implementation

{$R *.DFM}

procedure TdlgInputPassword.edPasswordChange(Sender: TObject);
begin
  btnOk.Enabled := Length(edPassword.Text) > 0;
end;

procedure TdlgInputPassword.btnCancelClick(Sender: TObject);
begin
  if MessageBox(Handle,
    'Вы действительно хотите прервать установку и выйти из программы?',
    'Внимание',
    MB_YESNO or MB_ICONQUESTION) = IDYES then ModalResult := mrCancel;
end;

procedure TdlgInputPassword.Timer1Timer(Sender: TObject);
const
  KL: Integer = -1;
var
  Ch: array[0..KL_NAMELENGTH] of Char;
begin
  GetKeyboardLayoutName(Ch);
  if KL <> StrToInt('$' + StrPas(Ch)) then
  begin
    KL := StrToInt('$' + StrPas(Ch));
    case (KL and $3ff) of
      LANG_BELARUSIAN: lbKL.Caption := 'БЕЛ';
      LANG_RUSSIAN: lbKL.Caption := 'РУС';
      LANG_ENGLISH: lbKL.Caption := 'АНГ';
      LANG_GERMAN: lbKL.Caption := 'НЕМ';
      LANG_UKRAINIAN: lbKL.Caption := 'УКР';
    else
      lbKL.Caption := '';
    end;
  end;
end;

procedure TdlgInputPassword.FormActivate(Sender: TObject);
begin
  Timer1.Enabled := True;
end;

procedure TdlgInputPassword.FormDeactivate(Sender: TObject);
begin
  Timer1.Enabled := False;
end;

end.
