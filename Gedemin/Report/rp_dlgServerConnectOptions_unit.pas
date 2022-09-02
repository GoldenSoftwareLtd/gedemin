// ShlTanya, 27.02.2019

unit rp_dlgServerConnectOptions_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TdlgServerConnectOptions = class(TForm)
    Label1: TLabel;
    edUser: TEdit;
    Label2: TLabel;
    edPass: TEdit;
    Label3: TLabel;
    edConPass: TEdit;
    btnOk: TButton;
    btnCancel: TButton;
    procedure btnOkClick(Sender: TObject);
  private
    { Private declarations }
  public
    function SetServerParam(var AnUser, AnPassword: String): Boolean;
  end;

var
  dlgServerConnectOptions: TdlgServerConnectOptions;

implementation

uses
  gd_Cipher_unit, gd_SetDatabase;

{$R *.DFM}

function TdlgServerConnectOptions.SetServerParam(var AnUser, AnPassword: String): Boolean;
begin
  Result := False;
  edUser.Text := AnUser;
  edPass.Text := AnPassword;
  edConPass.Text := edPass.Text;
  if ShowModal = mrOk then
  begin
    AnUser := edUser.Text;
    AnPassword := edPass.Text;
    Result := True;
  end;
end;

procedure TdlgServerConnectOptions.btnOkClick(Sender: TObject);
begin
  if edPass.Text <> edConPass.Text then
  begin
    MessageBox(Handle, 'Не верно подтвержден пароль.', 'Внимание', MB_OK or MB_ICONWARNING);
    edPass.SetFocus;
    ModalResult := mrNone;
  end;
end;

end.
