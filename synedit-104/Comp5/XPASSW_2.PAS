
{
  Part of xPassw.pas
  Copyright (c) 1996-97 by Golden Software
}

unit xPassw_2;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, xStrList;

type
  TPasswordBox = class(TForm)
    Image1: TImage;
    Edit: TEdit;
    btnOk: TButton;
    btnCancel: TButton;
    xStrList: TxStrList;
    procedure btnCancelClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);

  private
    ValidPassword: Boolean;
  end;

var
  PasswordBox: TPasswordBox;

implementation

{$R *.DFM}

uses
  xPassw, xSStart;

procedure TPasswordBox.btnCancelClick(Sender: TObject);
begin
  if SafeStart <> nil then
    SafeStart.ForceNormalShutdown;
  Halt;
end;

procedure TPasswordBox.btnOkClick(Sender: TObject);
var
  T: TPasswordType;
  S: String;
begin
  if Edit.Text = '' then
  begin
    S := xStrList.StrByIndex(5, 0) + #0;
    MessageBox(Handle, @S[1], 'Пароль', MB_ICONINFORMATION or MB_OK);
    Edit.SetFocus;
    exit;
  end;

  for T := ptReadOnly to ptFull do
    if Password.IsPassword(T) and (Edit.Text = Password.GetPassword(T)) then
    begin
      Password.CurrPassword := T;

      case T of
        ptReadOnly: S := xStrList.StrByIndex(1, 0);
        ptRestricted: S := xStrList.StrByIndex(2, 0);
        ptFull: S := xStrList.StrByIndex(3, 0);
      else
        raise Exception.Create('Invalid password type');
      end;

      S := S + #0;
      MessageBox(Handle, @S[1], 'Пароль', MB_ICONINFORMATION or MB_OK);
      ValidPassword := True;
      ModalResult := mrOk;
      exit;
    end;

  S := xStrList.StrByIndex(4, 0) + #0;
  MessageBox(Handle, @S[1], 'Ошибка', MB_ICONHAND or MB_OK);

  Edit.SelectAll;
  Edit.SetFocus;
end;

procedure TPasswordBox.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if not ValidPassword then
  begin
    if SafeStart <> nil then
      SafeStart.ForceNormalShutdown;
    Halt;
  end;
end;

procedure TPasswordBox.FormCreate(Sender: TObject);
begin
  ValidPassword := False;
end;

end.

