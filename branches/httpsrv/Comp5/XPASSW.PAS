
{++

  Copyright (c) 1996-97 by Golden Software of Belarus

  Module

    xpassw.pas

  Abstract

    Password protection for an application.

  Author

    Andrei Kireev (20-Apr-96)

  Contact address

    andreik@gs.minsk.by

  Revisions history

    1.00    21-Apr-96    andreik    Initial version.
    1.01     5-May-96    andreik    Read only, restricted and full passwords
                                    added.
    1.02     6-May-96    andreik    Published events added.
    1.03    16-May-96    andreik    Minor bug fixed.
    1.04    20-Jul-97    andreik    Some changes.

--}

unit xPassw;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls;

type
  TPasswordType = (ptReadOnly, ptRestricted, ptFull);
  TPasswords = set of TPasswordType;

type
  TChangePasswordEvent = procedure(ASender: TObject;
    APasswordType: TPasswordType) of object;

type
  TxPassword = class(TComponent)
  private
    FCurrPassword: TPasswordType;
    FIsCurrPassword: Boolean;
    FOnSetCurrPassword: TNotifyEvent;
    FOnChangePassword: TChangePasswordEvent;

    OldOnCreate: TNotifyEvent;

    function GetCurrPassword: TPasswordType;
    procedure SetCurrPassword(APasswordType: TPasswordType);

    procedure DoOnCreate(Sender: TObject);

  protected
    function KeyName(APasswordType: TPasswordType): String; virtual;
    function Encrypt(const S: String): String; virtual;
    function Decrypt(const S: String): String; virtual;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    function GetPassword(APasswordType: TPasswordType): String;
    procedure SetPassword(APasswordType: TPasswordType; ANewPassword: String);
    procedure ChangePasswords; virtual;
    function IsPassword(APasswordType: TPasswordType): Boolean;
    function GetPasswords: TPasswords;
    procedure RemovePassword(APasswordType: TPasswordType);
    procedure RemovePasswords;

    property CurrPassword: TPasswordType read GetCurrPassword
      write SetCurrPassword stored False;
    property IsCurrPassword: Boolean read FIsCurrPassword stored False;

  published
    property OnSetCurrPassword: TNotifyEvent read FOnSetCurrPassword
      write FOnSetCurrPassword;
    property OnChangePassword: TChangePasswordEvent read FOnChangePassword
      write FOnChangePassword;
  end;

  ExPasswordError = class(Exception);

procedure Register;

var
  Password: TxPassword;

implementation

uses
  ShellAPI, xPassw_1, xPassw_2;

{ TxPassword ---------------------------------------------}

constructor TxPassword.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  if Assigned(Password) then
    raise ExPasswordError.Create('Only one instance of TxPassword allowed');

  FIsCurrPassword := False;

  if not (Owner is TForm) then
    raise ExPasswordError.Create('Owner must be a TForm');

  { because of loosing event handler we should not }
  { assign our handler while in design mode        }
  if not (csDesigning in ComponentState) then
  begin
    OldOnCreate := TForm(Owner).OnCreate;
    TForm(Owner).OnCreate := DoOnCreate;
  end;

  Password := Self;

  if (not IsPassword(ptFull)) and (IsPassword(ptReadOnly)
    or IsPassword(ptRestricted)) then
  begin
    MessageBox(0, 'Ошибка в системном реестре.', 'Ошибка',
      MB_OK or MB_ICONEXCLAMATION);
    RemovePasswords;
  end;
end;

destructor TxPassword.Destroy;
begin
  if (not (csDesigning in ComponentState)) and (Owner <> nil) then
    (Owner as TForm).OnCreate := OldOnCreate;

  Password := nil;
  inherited Destroy;
end;

function TxPassword.GetPassword(APasswordType: TPasswordType): String;
var
  PasswKey: HKey;
  S: array[0..255] of Char;
  L: LongInt;
begin
  StrPCopy(S, KeyName(APasswordType));
  if RegOpenKey(HKEY_CLASSES_ROOT, S, PasswKey) <> ERROR_SUCCESS then
    raise ExPasswordError.Create('Can''t open key in registry');
  try
    L := SizeOf(S);
    if RegQueryValue(PasswKey, nil, S, L) <> ERROR_SUCCESS then
      raise ExPasswordError.Create('Can''t read value from registry');
    Result := Decrypt(StrPas(S));
  finally
    RegCloseKey(PasswKey);
  end;
end;

procedure TxPassword.SetPassword(APasswordType: TPasswordType; ANewPassword: String);
var
  PasswKey: HKey;
  S: array[0..63] of Char;
begin
  StrPCopy(S, KeyName(APasswordType));
  if RegCreateKey(HKEY_CLASSES_ROOT, S, PasswKey) <> ERROR_SUCCESS then
    raise ExPasswordError.Create('Can''t create key in registry');
  try
    ANewPassword := Encrypt(ANewPassword) + #0;
    if RegSetValue(PasswKey, nil, REG_SZ, @ANewPassword[1],
        Length(ANewPassword)) <> ERROR_SUCCESS then
      raise ExPasswordError.Create('Can''t set value in registry');
  finally
    RegCloseKey(PasswKey);
  end;

  if Assigned(FOnChangePassword) then
    FOnChangePassword(Self, APasswordType);
end;

procedure TxPassword.ChangePasswords;
begin
  if IsCurrPassword and (CurrPassword <> ptFull) then
  begin
    MessageBox(0, 'Для изменения паролей необходимо иметь ' +
      'полный доступ к системе.', 'Пароль', MB_OK or MB_ICONHAND);
    exit;
  end;

  ChangePasswBox := TChangePasswBox.Create(Self);
  try
    ChangePasswBox.ShowModal;
  finally
    ChangePasswBox.Free;
  end;
end;

function TxPassword.IsPassword(APasswordType: TPasswordType): Boolean;
var
  PasswKey: HKey;
  S: array[0..255] of Char;
  L: LongInt;
begin
  StrPCopy(S, KeyName(APasswordType));

  if RegOpenKey(HKEY_CLASSES_ROOT, S, PasswKey) <> ERROR_SUCCESS then
  begin
    Result := False;
    exit;
  end;

  try
    L := SizeOf(S);
    Result := (RegQueryValue(PasswKey, nil, S, L) = ERROR_SUCCESS) and (L > 0);
  finally
    RegCloseKey(PasswKey);
  end;
end;

function TxPassword.GetPasswords: TPasswords;
var
  T: TPasswordType;
begin
  Result := [];
  for T := ptReadOnly to ptFull do
    if IsPassword(T) then Include(Result, T);
end;

procedure TxPassword.RemovePassword(APasswordType: TPasswordType);
var
  S: array[0..255] of Char;
begin
  StrPCopy(S, KeyName(APasswordType));
  if RegDeleteKey(HKEY_CLASSES_ROOT, S) <> ERROR_SUCCESS then
    raise ExPasswordError.Create('Can''t delete key in registry');
end;

procedure TxPassword.RemovePasswords;
var
  T: TPasswordType;
begin
  for T := ptReadOnly to ptFull do
    if IsPassword(T) then RemovePassword(T);
end;

function TxPassword.KeyName(APasswordType: TPasswordType): String;
var
  I: Integer;
begin
  Result := Application.ExeName;

  for I := Length(Result) downto 1 do
    if Result[I] = '\' then
    begin
      Delete(Result, 1, I);
      break;
    end;

  for I := Length(Result) downto 1 do
    if Result[I] = '.' then
    begin
      Result := Copy(Result, 1, I - 1);
      break;
    end;

  Result := Result + '\Passwords\';
  case APasswordType of
    ptReadOnly: Result := Result + 'ReadOnly';
    ptRestricted: Result := Result + 'Restricted';
    ptFull: Result := Result + 'Full';
  end;
end;

function TxPassword.Encrypt(const S: String): String;
var
  I: Integer;
begin
  if Length(S) = 0 then
    raise ExPasswordError.Create('Invalid password');

  Result := S;
  for I := 1 to Length(Result) - 1 do
    Result[I] := Chr(Byte(Result[I]) xor
      Byte((Ord(Result[I + 1]) + I * 8 * Length(Result)) mod 256));
  Result[Length(Result)] := Chr(Byte(Result[Length(Result)]) xor $FE);
end;

function TxPassword.Decrypt(const S: String): String;
var
  I: Integer;
begin
  if Length(S) = 0 then
    raise ExPasswordError.Create('Invalid password');

  Result := S;
  Result[Length(Result)] := Chr(Byte(Result[Length(Result)]) xor $FE);
  for I := Length(Result) downto 2 do
    Result[I - 1] := Chr(Byte(Result[I - 1]) xor
      ((Ord(Result[I]) + (I - 1) * 8 * Length(Result)) mod 256));
end;

function TxPassword.GetCurrPassword: TPasswordType;
begin
  if FIsCurrPassword then
    Result := FCurrPassword
  else
    raise ExPasswordError.Create('Current password is not set');
end;

procedure TxPassword.SetCurrPassword(APasswordType: TPasswordType);
begin
  if not IsPassword(APasswordType) then
    raise ExPasswordError.Create('Invalid password type');
  FCurrPassword := APasswordType;
  FIsCurrPassword := True;
  if Assigned(FOnSetCurrPassword) then
    FOnSetCurrPassword(Self);
end;

procedure TxPassword.DoOnCreate(Sender: TObject);
var
  PasswordBox: TPasswordBox;
begin
  if Password.GetPasswords <> [] then
  begin
    PasswordBox := TPasswordBox.Create(Self);
    try
      PasswordBox.ShowModal;
    finally
      PasswordBox.Free;
    end;
  end;

  if Assigned(OldOnCreate) then OldOnCreate(Sender);
end;

{ Registration -------------------------------------------}

procedure Register;
begin
  RegisterComponents('xTool-2', [TxPassword]);
end;

var
  OldExit: Pointer;

procedure MyExit; far;
begin
  ExitProc := OldExit;
  if Assigned(Password) then Password.Free;
end;

initialization
  Password := nil;

  OldExit := ExitProc;
  ExitProc := @MyExit;
end.

