
{
  Part of xPassw.pas
  Copyright (c) 1996 by Golden Software
}

unit xPassw_1;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, TabNotBk, xPassw, FrmPlSvr, ComCtrls;

type
  TChangePasswBox = class(TForm)
    TabbedNotebook: TTabbedNotebook;
    Panel1: TPanel;
    OldPasswLbl: TLabel;
    NewPasswLbl: TLabel;
    ReentPasswLbl: TLabel;
    OldPasswEdit: TEdit;
    NewPasswEdit: TEdit;
    ReentPasswEdit: TEdit;
    OkButton: TButton;
    CancelButton: TButton;
    RemoveButton: TButton;
    FormPlaceSaver: TFormPlaceSaver;
    procedure OldPasswEditChange(Sender: TObject);
    procedure OkButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure RemoveButtonClick(Sender: TObject);
    procedure NewPasswEditChange(Sender: TObject);
    procedure TabbedNotebookChange(Sender: TObject; NewTab: Integer;
      var AllowChange: Boolean);

  private
    T: TPasswordType;
    FirstCall: Boolean;
  end;

var
  ChangePasswBox: TChangePasswBox;

implementation

{$R *.DFM}

procedure TChangePasswBox.OldPasswEditChange(Sender: TObject);
var
  B: Boolean;
begin
  if Password.IsPassword(T) then
  begin
    B := OldPasswEdit.Text = Password.GetPassword(T);

    NewPasswEdit.Enabled := B;
    ReentPasswEdit.Enabled := B;
    NewPasswLbl.Enabled := B;
    ReentPasswLbl.Enabled := B;

    RemoveButton.Enabled := B and (Password.IsCurrPassword)
      and (Password.CurrPassword = ptFull);
  end;
end;

procedure TChangePasswBox.OkButtonClick(Sender: TObject);
var
  K: TPasswordType;
begin
  if Password.IsCurrPassword and (Password.CurrPassword <> ptFull) then
  begin
    MessageBox(Handle, 'Для изменения пароля необходимо иметь ' +
      'полный доступ к системе.', 'Ошибка', MB_ICONHAND or MB_OK);
    exit;
  end;

  for K := ptReadOnly to ptFull do
    if (K <> T) and (Password.IsPassword(K))
      and (Password.GetPassword(K) = NewPasswEdit.Text) then
    begin
      MessageBox(Handle, 'Введенный пароль совпадает с паролем другого ' +
        'уровня доступа.', 'Ошибка', MB_ICONHAND or MB_OK);
      exit;
    end;

  Password.SetPassword(T, NewPasswEdit.Text);

  if not Password.IsCurrPassword then
    Password.CurrPassword := ptFull;

  MessageBox(Handle, 'Новый пароль установлен.', 'Пароль', MB_OK or MB_ICONINFORMATION);
  CancelButton.Caption := 'Закрыть';

  ModalResult := mrOk;
end;

procedure TChangePasswBox.FormCreate(Sender: TObject);
begin
  FirstCall := True;

  TabbedNoteBook.PageIndex := 1;
  FirstCall := True;

  if not Password.IsPassword(ptFull) then
    TabbedNotebook.PageIndex := 2
  else
    TabbedNotebook.PageIndex := 0;
end;

procedure TChangePasswBox.RemoveButtonClick(Sender: TObject);
begin
  if (T = ptFull) and (Password.IsPassword(ptReadOnly)
    or Password.IsPassword(ptRestricted)) then
  begin
    MessageBox(Handle, 'Нельзя удалить пароль для полного доступа,' +
      ' если установлены пароли для других уровней доступа.', 'Пароль',
      MB_OK or MB_ICONEXCLAMATION);
    exit;
  end;

  Password.RemovePassword(T);

  MessageBox(Handle, 'Пароль удален.', 'Пароль', MB_OK or MB_ICONINFORMATION);

  OkButton.Enabled := False;
  CancelButton.Caption := 'Закрыть';
  RemoveButton.Enabled := False;

  NewPasswEdit.Enabled := True;
  NewPasswEdit.Text := '';
  NewPasswLbl.Enabled := True;
  NewPasswEdit.SetFocus;

  OldPasswEdit.Text := '';
  OldPasswEdit.Enabled := False;
  OldPasswLbl.Enabled := False;

  ReentPasswEdit.Enabled := True;
  ReentPasswEdit.Text := '';
  ReentPasswLbl.Enabled := True;
end;

procedure TChangePasswBox.NewPasswEditChange(Sender: TObject);
begin
  OkButton.Enabled := (NewPasswEdit.Text <> '') and
    (NewPasswEdit.Text = ReentPasswEdit.Text);
end;

procedure TChangePasswBox.TabbedNotebookChange(Sender: TObject;
  NewTab: Integer; var AllowChange: Boolean);
var
  B: Boolean;
begin
  if (not FirstCall) and OkButton.Enabled then
    OkButtonClick(Self);

  case NewTab of
    0: T := ptReadOnly;
    1: T := ptRestricted;
    2: T := ptFull;
  else
    raise Exception.Create('Invalid page index');
  end;

  OldPasswEdit.Text := '';
  NewPasswEdit.Text := '';
  ReentPasswEdit.Text := '';

  B := Password.IsPassword(T);

  OldPasswEdit.Enabled := B;
  OldPasswLbl.Enabled := B;
  NewPasswEdit.Enabled := not B;
  ReentPasswEdit.Enabled := not B;
  NewPasswLbl.Enabled := not B;
  ReentPasswLbl.Enabled := not B;

  RemoveButton.Enabled := False;
  OkButton.Enabled := False;

  if B then WinProcs.SetFocus(OldPasswEdit.Handle) else
    WinProcs.SetFocus(NewPasswEdit.Handle);

  if (not FirstCall) and (not Password.IsPassword(ptFull)) then
  begin
    MessageBox(Handle, 'Пароль для полного доступа должен быть ' +
      'обязательно введен.', 'Ошибка', MB_ICONHAND or MB_OK);
    AllowChange := False;
    exit;
  end;

  FirstCall := False;
end;

end.
