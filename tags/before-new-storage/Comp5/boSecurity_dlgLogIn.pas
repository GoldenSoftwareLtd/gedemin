
{++

  Copyright (c) 1998-2000 by Golden Software of Belarus

  Module

    boSecurity_dlgLogIn.pas

  Abstract

    A Part of visual component for choosing user, user rights and pasword.
    Dialog window for loggin to database.

  Author

    Andrei Kireev (22-aug-99), Romanovski Denis (04.02.2000)

  Revisions history

--}


unit boSecurity_dlgLogIn;

interface

uses
  Windows,          Messages,         SysUtils,         Classes,
  Graphics,         Controls,         Forms,            Dialogs,
  ExtCtrls,         mBitButton,       StdCtrls,         Db,
  ActnList,         xAppReg,          xLabel,           IBTable,
  gsMultilingualSupport,              mmCheckBoxEx,     IBDatabase,
  IBStoredProc,     IBCustomDataSet;

type
  TdlgLogIn = class(TForm)
    imgSecurity: TImage;
    pnlLoginParams: TPanel;
    lblUser: TLabel;
    lblPassword: TLabel;
    edPassword: TEdit;
    ActionList: TActionList;
    actLogin: TAction;
    lblInfo: TxLabel;
    lblSubSystem: TLabel;
    edSubSystem: TEdit;
    edUser: TEdit;
    mbbOk: TmBitButton;
    mbbCancel: TmBitButton;
    mbbEditData: TmBitButton;
    gsMultilingualSupport: TgsMultilingualSupport;
    chbxShowLoginParams: TmmCheckBoxEx;
    tblUser: TIBTable;
    spUserLogin: TIBStoredProc;
    ibtSecurity: TIBTransaction;

    procedure actLoginUpdate(Sender: TObject);
    procedure actLoginExecute(Sender: TObject);

    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);

    procedure mbbCancelClick(Sender: TObject);
    procedure mbbEditDataClick(Sender: TObject);

  private

  public
  
  end;

var
  dlgLogIn: TdlgLogIn;

implementation

{$R *.DFM}

uses
  ShellAPI, boSecurity;

{
  Активация кнопки разрешения на вход.
}
procedure TdlgLogIn.actLoginUpdate(Sender: TObject);
begin
  actLogin.Enabled := (edUser.Text > '') and (edSubSystem.Text > '');
end;

{
  Активация подключения к базе данных.
}

procedure TdlgLogIn.actLoginExecute(Sender: TObject);
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

{
  Сохраняем установки.
}

procedure TdlgLogIn.FormDestroy(Sender: TObject);
begin
  AppRegistry.WriteString('Login', 'SubSystem', edSubSystem.Text);
  AppRegistry.WriteString('Login', 'User', edUser.Text);
end;

{
  Загружаем настройки.
}

procedure TdlgLogIn.FormCreate(Sender: TObject);
begin
  edSubSystem.Text := AppRegistry.ReadString('Login', 'SubSystem', '');
  edUser.Text := AppRegistry.ReadString('Login', 'User', '');
end;

{
 Отмена подключения.
}

procedure TdlgLogIn.mbbCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

{
  Вызов редактирования параметоров загрузки.
}

procedure TdlgLogIn.mbbEditDataClick(Sender: TObject);
var
  FileName: ShortString;
begin
  FileName := 'NOTEPAD ' + ExtractFilePath(Application.EXEName)+ Security.ParamsFile + #0;
  WinExec(@FileName[1], SW_SHOW);
end;

end.

