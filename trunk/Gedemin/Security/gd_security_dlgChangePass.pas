unit gd_security_dlgChangePass;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TdlgChangePass = class(TForm)
    edPassword: TEdit;
    lblUse: TLabel;
    lblMsg: TLabel;
    edPasswordDouble: TEdit;
    Label2: TLabel;
    btnOk: TButton;
    btnCancel: TButton;

    procedure btnOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private
    procedure SetUserName(const Value: String);

  public
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
  if Trim(edPassword.Text) = '' then
  begin
    MessageBox(Self.Handle,
      'Введен пустой пароль!',
      'Внимание',
      MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
    edPassword.SetFocus;
    ModalResult := mrNone;
  end
  else if edPassword.Text <> edPasswordDouble.Text then
  begin
    MessageBox(Self.Handle,
      'Неверно подтвержден пароль!',
      'Внимание',
      MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
    edPasswordDouble.SetFocus;
    ModalResult := mrNone;
  end;
end;

procedure TdlgChangePass.FormCreate(Sender: TObject);
begin
  edPassword.Text := '';
  edPasswordDouble.Text := '';

  {$IFDEF LOCALIZATION}
  LocalizeComponent(Self);
  {$ENDIF}
end;

procedure TdlgChangePass.SetUserName(const Value: String);
begin
  lblMsg.Caption := StringReplace(lblMsg.Caption, '%user%', Value, []);
end;

end.

