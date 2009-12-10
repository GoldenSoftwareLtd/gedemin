unit gd_security_dlgChangePass;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TdlgChangePass = class(TForm)
    edPassword: TEdit;
    lblUse: TLabel;
    Label1: TLabel;
    edPasswordDouble: TEdit;
    Label2: TLabel;
    lblUser: TLabel;
    btnOk: TButton;
    btnCancel: TButton;

    procedure btnOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private
    procedure SetUserName(const Value: String);

  public
    function Execute: Boolean;

    property UserName: String write SetUserName;

  end;

var
  dlgChangePass: TdlgChangePass;

implementation

{$R *.DFM}

  {$IFDEF LOCALIZATION}
uses
  {must be placed after Windows unit!}
  gd_localization_stub, gd_localization
  ;
  {$ENDIF}

procedure TdlgChangePass.btnOkClick(Sender: TObject);
begin
  if (edPassword.Text <> edPasswordDouble.Text) or (edPassword.Text = '') then
  begin
    MessageBox(Self.Handle, 'Неверно подтвержден пароль', 'Внимание', MB_OK or MB_ICONEXCLAMATION);
    edPasswordDouble.SetFocus;
    ModalResult := mrNone;
  end;
end;

function TdlgChangePass.Execute: Boolean;
begin
  MessageBox(Handle, 'Вам необходимо сменить пароль.',
    'Внимание', MB_OK or MB_ICONEXCLAMATION);

  Result := ShowModal = mrOk;
end;

procedure TdlgChangePass.FormCreate(Sender: TObject);
begin
  lblUser.Caption := '';
  edPassword.Text := '';
  edPasswordDouble.Text := '';

  {$IFDEF LOCALIZATION}
  LocalizeComponent(Self);
  {$ENDIF}
end;

procedure TdlgChangePass.SetUserName(const Value: String);
begin
  lblUser.Caption := Value;
end;

end.

