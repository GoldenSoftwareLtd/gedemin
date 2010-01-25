
unit UserLoginDlg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, mBitButton, StdCtrls, Db, DBTables, ActnList, xAppReg, xLabel,
  gsMultilingualSupport;

type
  TUserLoginDialog = class(TForm)
    Image1: TImage;
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    edPassword: TEdit;
    ActionList: TActionList;
    actLogin: TAction;
    xLabel1: TxLabel;
    Label3: TLabel;
    edSubSystem: TEdit;
    edUser: TEdit;
    spUserLogin: TStoredProc;
    chbxShowLoginParams: TCheckBox;
    mbbOk: TmBitButton;
    mbbCancel: TmBitButton;
    mbbEditData: TmBitButton;
    tblUser: TTable;
    gsMultilingualSupport: TgsMultilingualSupport;
    procedure actLoginUpdate(Sender: TObject);
    procedure actLoginExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure mbbCancelClick(Sender: TObject);
    procedure mbbEditDataClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  UserLoginDialog: TUserLoginDialog;

implementation

{$R *.DFM}

uses
  UserLogin, ShellAPI;

procedure TUserLoginDialog.actLoginUpdate(Sender: TObject);
begin
  actLogin.Enabled := (edUser.Text > '') and (edSubSystem.Text > '');
end;

procedure TUserLoginDialog.actLoginExecute(Sender: TObject);
begin
  spUserLogin.ParamByName('subsystem').AsString := edSubSystem.Text;
  spUserLogin.ParamByName('username').AsString := edUser.Text;
  spUserLogin.ParamByName('passw').AsString := edPassword.Text;
  spUserLogin.ExecProc;

  if spUserLogin.ParamByName('result').AsInteger = -4 then
  begin
    MessageBox(Handle, 'Неверно введена подсистема.', 'Внимание',
      MB_OK or MB_ICONEXCLAMATION);
    edSubSystem.SetFocus;
    exit;
  end;

  if spUserLogin.ParamByName('result').AsInteger = -1 then
  begin
    MessageBox(Handle, 'Неверно введен пользователь.', 'Внимание',
      MB_OK or MB_ICONEXCLAMATION);
    edUser.SetFocus;
    exit;
  end;

  if spUserLogin.ParamByName('result').AsInteger = -2 then
  begin
    MessageBox(Handle, 'Неверно введен пароль.', 'Внимание',
      MB_OK or MB_ICONEXCLAMATION);
    edPassword.SetFocus;
    exit;
  end;

  if spUserLogin.ParamByName('result').AsInteger = -3 then
  begin
    MessageBox(Handle, 'У указанного пользователя нет права на вход в подсистему.', 'Внимание',
      MB_OK or MB_ICONEXCLAMATION);
    edSubSystem.SetFocus;
    exit;
  end;

  if spUserLogin.ParamByName('result').AsInteger = 0 then
    ModalResult := mrOk;
end;

procedure TUserLoginDialog.FormDestroy(Sender: TObject);
begin
  AppRegistry.WriteString('Login', 'SubSystem', edSubSystem.Text);
  AppRegistry.WriteString('Login', 'User', edUser.Text);
end;

procedure TUserLoginDialog.FormCreate(Sender: TObject);
begin
  edSubSystem.Text := AppRegistry.ReadString('Login', 'SubSystem', '');
  edUser.Text := AppRegistry.ReadString('Login', 'User', '');
end;

procedure TUserLoginDialog.mbbCancelClick(Sender: TObject);
begin
//  Halt;
  ModalResult := mrCancel;
end;

procedure TUserLoginDialog.mbbEditDataClick(Sender: TObject);
var
  FileName: ShortString;
begin
  FileName := 'NOTEPAD ' + ExtractFilePath(Application.EXEName)+ CurrentUser.ParamsFile + #0;
  WinExec(@FileName[1], SW_SHOW);
end;

end.





