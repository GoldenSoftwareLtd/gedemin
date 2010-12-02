unit gd_setup_dlgEnterSysdbaPassword;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TdlgEnterSysdbaPassword = class(TForm)
    edPassword1: TEdit;
    edPassword2: TEdit;
    btnOk: TButton;
    btnCancel: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Memo: TMemo;
    Bevel1: TBevel;
    procedure edPassword1Change(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dlgEnterSysdbaPassword: TdlgEnterSysdbaPassword;

implementation

{$R *.DFM}

procedure TdlgEnterSysdbaPassword.edPassword1Change(Sender: TObject);
begin
  btnOk.Enabled := (edPassword1.Text = edPassword2.Text) and
    (edPassword1.Text > '');
end;

procedure TdlgEnterSysdbaPassword.btnCancelClick(Sender: TObject);
begin
  if MessageBox(Handle,
    'Вы действительно хотите прервать установку и выйти из программы?',
    'Внимание',
    MB_YESNO or MB_ICONQUESTION) = IDYES then ModalResult := mrCancel;
end;

end.
