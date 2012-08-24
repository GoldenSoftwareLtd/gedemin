
{++

  Copyright (c) 1998-2012 by Golden Software of Belarus

  Module

    boSecurity_dlgLogIn.pas

  Abstract

    A Part of visual component for choosing user, user rights and pasword.
    Dialog window for loggin to database.

  Author

    Andrei Kireev (22-aug-99), Romanovski Denis (04.02.2000)

  Revisions history

--}


unit gd_security_dlgLogIn;

interface

uses
  Windows, IBDatabase, Db, IBCustomDataSet, IBStoredProc, Classes,
  ActnList, StdCtrls, Controls, ExtCtrls, Graphics, Forms, Registry,
  SysUtils, Messages;

type
  TdlgSecLogIn = class(TForm)
    imgSecurity: TImage;
    pnlLoginParams: TPanel;
    lblUser: TLabel;
    lblPassword: TLabel;
    edPassword: TEdit;
    ActionList: TActionList;
    actLogin: TAction;
    spUserLogin: TIBStoredProc;
    ibtSecurity: TIBTransaction;
    btnOk: TButton;
    btnCancel: TButton;
    lblSubSystem: TLabel;
    actCancel: TAction;
    Label1: TLabel;
    Label2: TLabel;
    lSubSystemName: TLabel;
    lServerName: TLabel;
    Bevel1: TBevel;
    lKL: TLabel;
    Timer: TTimer;
    cbUser: TComboBox;
    cbDBFileName: TComboBox;
    actHelp: TAction;
    chbxRememberPassword: TCheckBox;
    actVer: TAction;
    btnVer: TButton;

    procedure actLoginUpdate(Sender: TObject);
    procedure actLoginExecute(Sender: TObject);

    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);

    procedure actCancelExecute(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure cbDBFileNameChange(Sender: TObject);
    procedure actHelpExecute(Sender: TObject);
    procedure cbUserChange(Sender: TObject);
    procedure actVerExecute(Sender: TObject);

  private
    KL: Integer;
    FChangePass: Boolean;
    FSubSystemKey: Integer;
    FOnConnectionParams: TNotifyEvent;
    FAdminRightsRequest: Boolean;
    FFirstLogin: Boolean;
    FSL: TStringList;
    FDatabaseChanged: Boolean;
    FAutoCloseCounter: Integer;

    function RunLoginProc(const AUser, APassw: String;
      const ASubS: Integer; const ASilent: Boolean): Boolean;
    procedure ReadConnectionData;

    procedure SetDatabase(const Value: TIBDatabase);
    function GetDatabase: TIBDatabase;
    procedure SetPassword(const Value: String);
    procedure SetUserName(const Value: String);
    function GetPassword: String;
    function GetUserName: String;
    procedure GetPasswordFromRegistry;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure PrepareSelf;

    function DoLogin: Boolean;
    function TryAdminLogin: Boolean;

    property Database: TIBDatabase read GetDatabase write SetDatabase;
    property ChangePass: Boolean read FChangePass;

    property OnConnectionParams: TNotifyEvent read FOnConnectionParams
      write FOnConnectionParams;

    property UserName: String read GetUserName write SetUserName;
    property Password: String read GetPassword write SetPassword;

    property SubSystemKey: Integer write FSubSystemKey;
    property AdminRightsRequest: Boolean write FAdminRightsRequest;

  end;

var
  dlgSecLogIn: TdlgSecLogIn;

implementation

{$R *.DFM}

uses
  gd_Security, gd_resourcestring, gd_directories_const, inst_const,
  gd_security_dlgDatabases_unit, jclStrings, IBSQL, gdcBaseInterface,
  IBServices, IB, DBLogDlg, gsDatabaseShutdown, Wcrypt2, dmLogin_unit,
  gd_common_functions, gd_CmdLineParams_unit, gd_dlgAbout_unit
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub, gd_localization
  {$ENDIF}
  ;

{
  Активация кнопки разрешения на вход.
}
procedure TdlgSecLogIn.actLoginUpdate(Sender: TObject);
begin
  actLogin.Enabled := (cbUser.Text > '');
end;

procedure TdlgSecLogIn.GetPasswordFromRegistry;

  function HexToByte(const St: String): Byte;
  const
    HexDigits: array[0..15] of Char = '0123456789ABCDEF';
  begin
    Result := (Pos(St[1], HexDigits) - 1) * 16 + (Pos(St[2], HexDigits) - 1);
  end;

var
  Reg: TRegistry;
  hProv: HCRYPTPROV;
  Key: HCRYPTKEY;
  Hash: HCRYPTHASH;
  CryptoKey, Pass, UnHexPass: String;
  Len, I: Integer;
begin
  if UserParamExists or PasswordParamExists
    or IBLogin.ReLogining then
  begin
    chbxRememberPassword.Checked := False;
    chbxRememberPassword.Enabled := False;
    exit;
  end else
    chbxRememberPassword.Enabled := True;

  if cbDBFilename.Text = '' then
    exit;

  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey(ClientAccessRegistrySubKey + '\' + cbDBFilename.Text, False)
      and (Reg.GetDataType(cbUser.Text) = rdString) then
    begin
      Pass := Reg.ReadString(cbUser.Text);
      if Copy(Pass, 1, 2) = '01' then
      begin
        Delete(Pass, 1, 2);
      end
      else if (Copy(Pass, 1, 2) = '02') and (not Odd(Length(Pass))) then
      begin
        UnHexPass := '';
        I := 3;
        while I < Length(Pass) do
        begin
          UnHexPass := UnHexPass + Chr(HexToByte(Copy(Pass, I, 2)));
          Inc(I, 2);
        end;
        Pass := UnHexPass;
      end else
        Pass := '';
    end else
      Pass := '';
  finally
    Reg.Free;
  end;

  if Pass > '' then
  begin
    CryptAcquireContext(@hProv, nil, nil, PROV_RSA_FULL, CRYPT_VERIFYCONTEXT);
    try
      CryptCreateHash(hProv, CALG_SHA, 0, 0, @Hash);
      try
        CryptoKey := cbDBFilename.Text;
        CryptHashData(Hash, @CryptoKey[1], Length(CryptoKey), 0);
        CryptDeriveKey(hProv, CALG_RC4, Hash, 0, @Key);
        Len := Length(Pass);
        CryptDecrypt(Key, 0, True, 0, @Pass[1], @Len);
      finally
        CryptDestroyHash(Hash);
      end;
    finally
      CryptReleaseContext(hProv, 0);
    end;
    edPassword.Text := Pass;

    chbxRememberPassword.Checked := True;
  end else
    chbxRememberPassword.Checked := False;
end;

{
  Активация подключения к базе данных.
}

procedure TdlgSecLogIn.actLoginExecute(Sender: TObject);

  function ByteToHex(const B: Byte): String;
  const
    HexDigits: array[0..15] of Char = '0123456789ABCDEF';
  begin
    Result := HexDigits[B div 16] + HexDigits[B mod 16];
  end;

var
  Reg: TRegistry;
  hProv: HCRYPTPROV;
  Key: HCRYPTKEY;
  Hash: HCRYPTHASH;
  CryptoKey, Pass, PassHex: String;
  Len, I: Integer;
begin
  FAutoCloseCounter := MaxInt;

  if RunLoginProc(Copy(cbUser.Text, 1, max_username_length),
    Copy(edPassword.Text, 1, max_password_length),
    FSubSystemKey,
    False) then
  begin
    {if FDatabaseChanged and (MessageBox(Handle,
      'Подключаться к выбранной базе данных при следующем входе?',
      'Внимание',
      MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL) = IDYES) then
    begin}
      Reg := TRegistry.Create(KEY_WRITE);
      try
        Reg.RootKey := ClientRootRegistryKey;

        if Reg.OpenKey(ClientRootRegistrySubKey, False) then
        begin
          //
          //  Наименование сервера
          Reg.WriteString(ServerNameValue, Database.DatabaseName);
          Reg.CloseKey;
        end;

        if chbxRememberPassword.Enabled and (cbDBFileName.Text > '') then
        begin
          Reg.RootKey := HKEY_CURRENT_USER;

          if chbxRememberPassword.Checked then
          begin
            Pass := edPassword.Text;
            Len := Length(Pass);

            if Len > 0 then
            begin
              CryptAcquireContext(@hProv, nil, nil, PROV_RSA_FULL, CRYPT_VERIFYCONTEXT);
              try
                CryptCreateHash(hProv, CALG_SHA, 0, 0, @Hash);
                try
                  CryptoKey := cbDBFileName.Text;
                  CryptHashData(Hash, @CryptoKey[1], Length(CryptoKey), 0);
                  CryptDeriveKey(hProv, CALG_RC4, Hash, 0, @Key);
                  CryptEncrypt(Key, 0, True, 0, @Pass[1], @Len, Len);
                finally
                  CryptDestroyHash(Hash);
                end;
              finally
                CryptReleaseContext(hProv, 0);
              end;
            end;

            if Reg.OpenKey(ClientAccessRegistrySubKey + '\' + cbDBFilename.Text, True) then
            begin
              if Len > 0 then
              begin
                PassHex := '';
                for I := 1 to Len do
                  PassHex := PassHex + ByteToHex(Ord(Pass[I]));
                Reg.WriteString(cbUser.Text, '02' + PassHex);

                //Reg.WriteString(cbUser.Text, '01' + Pass);
              end else
                Reg.DeleteValue(cbUser.Text);
              Reg.CloseKey;
            end;
          end else
          begin
            if Reg.OpenKey(ClientAccessRegistrySubKey + '\' + cbDBFilename.Text, False) then
            begin
              Reg.DeleteValue(cbUser.Text);
              Reg.CloseKey;
            end;
          end;
        end;

      finally
        Reg.Free;
      end;
    {end;}

    ModalResult := mrOk;
  end;
end;

{
  Сохраняем установки.
}

procedure TdlgSecLogIn.FormDestroy(Sender: TObject);
var
  R: TRegistry;
  S: String;
begin
  if ModalResult = mrOk then
  begin
    R := TRegistry.Create;
    try
      R.RootKey := ClientRootRegistryKey;

      if R.OpenKey(ClientAccessRegistrySubKey, True) then
      begin
        S := cbUser.Text;
        cbUser.Items.Delete(cbUser.Items.IndexOf(S));
        cbUser.Items.Insert(0, S);
        if cbUser.Items.Count > 10 then // сохраняем не более десяти имен пользователей
          cbUser.Items.Delete(10);
        R.WriteString('UserName', cbUser.Items.CommaText);
        R.CloseKey;
      end;
    finally
      R.Free;
    end;
  end;  
end;

{
  Загружаем настройки.
}

procedure TdlgSecLogIn.FormCreate(Sender: TObject);
var
  R: TRegistry;
  S: String;
begin
  cbUser.MaxLength := max_username_length;
  edPassword.MaxLength := max_password_length;

  FChangePass := False;
  FFirstLogin := False;

  R := TRegistry.Create(KEY_READ);
  try
    R.RootKey := ClientRootRegistryKey;
    if R.OpenKeyReadOnly(ClientAccessRegistrySubKey) and R.ValueExists('UserName') then
    begin
      S := Trim(R.ReadString('UserName'));
      if Pos(',', S) > 0 then
        cbUser.Items.CommaText := S
      else
        cbUser.Items.Text := S;
      FFirstLogin := cbUser.Items.CommaText = '';
      R.CloseKey;
    end else
      FFirstLogin := True;
    if cbUser.Items.IndexOf('Administrator') = -1 then
      cbUser.Items.Add('Administrator');
    cbUser.ItemIndex := 0;
  finally
    R.Free;
  end;

  ActiveControl := edPassword;

  {$IFDEF LOCALIZATION}
  LocalizeComponent(Self);
  {$ENDIF}
end;

{
 Отмена подключения
}

procedure TdlgSecLogIn.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TdlgSecLogIn.TimerTimer(Sender: TObject);
var
  Ch: array[0..KL_NAMELENGTH] of Char;
begin
  GetKeyboardLayoutName(Ch);
  if KL <> StrToInt('$' + StrPas(Ch)) then
  begin
    KL := StrToInt('$' + StrPas(Ch));
    case (KL and $3ff) of
      LANG_BELARUSIAN: lKL.Caption := 'БЕЛ';
      LANG_RUSSIAN: lKL.Caption := 'РУС';
      LANG_ENGLISH: lKL.Caption := 'АНГ';
      LANG_GERMAN: lKL.Caption := 'НЕМ';
      LANG_UKRAINIAN: lKL.Caption := 'УКР';
    else
      lKL.Caption := '';
    end;
  end;

  Dec(FAutoCloseCounter);
  if FAutoCloseCounter < 0 then
  begin
    ModalResult := mrCancel;
  end;
end;

function TdlgSecLogIn.DoLogin: Boolean;
begin
  if TryAdminLogin then
  begin
    MessageBox(0,
      'Здравствуйте!'#13#10#13#10 +
      'Это ваше первое подключение к базе данных.'#13#10 +
      'Для него будет использована учетная запись'#13#10 +
      'Administrator и пароль Administrator.'#13#10#13#10 +
      'После входа в систему рекомендуется изменить'#13#10 +
      'стандартный пароль для Администратора.'#13#10#13#10 +
      'Это можно сделать в Исследователе, в разделе'#13#10 +
      'Сервис\Администратор\Пользователи.'#13#10 +
      'Там же можно создать новые учетные записи'#13#10 +
      'для пользователей системы.'#13#10#13#10 +
      'Не рекомендуется осуществлять повседневную'#13#10 +
      'работу с системой под учетной записью Администратора.' +
      '' +
      '' +
      '',
      'Внимание',
      MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);
    Result := True;
  end else
  begin
    if (cbUser.Text > '') and (edPassword.Text > '')
      and (not chbxRememberPassword.Checked) then
    begin
      Result := RunLoginProc(Copy(cbUser.Text, 1, max_username_length),
        Copy(edPassword.Text, 1, max_password_length),
        FSubSystemKey,
        False);

      if not Result then
        Result := ShowModal = mrOk;
    end else
      Result := ShowModal = mrOk;
  end;

  {if Result then
    ReadConnectionData;}
end;

function TdlgSecLogIn.RunLoginProc(const AUser, APassw: String; const ASubS: Integer;
  const ASilent: Boolean): Boolean;
var
  ErrorString: String;
  q: TIBSQL;
begin
  Result := False;

  Database.Connected := True;

  ibtSecurity.StartTransaction;
  try
    // каждая база данных должна иметь свой уникальный
    // идентификатор, который содержится в генераторе
    // GD_G_DBID
    // сгенерированная, эталонная база имеет идентификатор
    // равный нулю.
    // при каждом подключении мы проверяем, если идентификатор
    // базы равен нулю, то это первое подключение к чистой базе
    // и надо установить ей уникальный идентификатор.
    {$IFDEF DEBUG} OutputDebugString(PChar('Begin DBID: ' + IntToStr(GetTickCount))); {$ENDIF}
    Assert(Assigned(gdcBaseManager));
    q := TIBSQL.Create(nil);
    try
      q.Transaction := ibtSecurity;
      q.SQL.Text := 'SELECT GEN_ID(gd_g_dbid, 0) FROM rdb$database';
      q.ExecQuery;
      if (q.Fields[0].AsInteger = 0) {or FFirstLogin} then
      begin
        q.Close;
        q.SQL.Text := 'SET GENERATOR gd_g_dbid TO ' + IntToStr(gdcBaseManager.GenerateNewDBID);
        q.ExecQuery;
      end;
      q.Close;
    finally
      q.Free;
    end;
    {$IFDEF DEBUG} OutputDebugString(PChar('End DBID: ' + IntToStr(GetTickCount))); {$ENDIF}

    if not spUserLogin.Prepared then
      spUserLogin.Prepare;

    spUserLogin.ParamByName('username').AsString := AUser;
    spUserLogin.ParamByName('passw').AsString := APassw;
    spUserLogin.ParamByName('subsystem').AsInteger := ASubS;

    try
      spUserLogin.ExecProc;
      if spUserLogin.ParamByName('result').IsNull then
        raise Exception.Create('Ошибка проверки прав доступа');
    except
      on E: Exception do
      begin
        spUserLogin.Close;
        if not ASilent then
          MessageBox(Handle,
            PChar('Произошел системный сбой при проверке прав пользователя. '#13#10 +
              'Возможно, необходимо выполнить архивное копирование и восстановление базы.'#13#10 +
              'Сообщение: ' + E.Message),
              'Внимание',
            MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
        exit;
      end;
    end;

    ErrorString := '';

    case spUserLogin.ParamByName('result').AsInteger of
      GD_LGN_UNKNOWN_SUBSYSTEM:
        ErrorString := 'Код подсистемы задан неверно.';
      GD_LGN_SUBSYSTEM_DISABLED:
        ErrorString := 'Подсистема заблокирована. Вход запрещен.';
      GD_LGN_UNKNOWN_USER:
      begin
        ErrorString := 'Имя пользователя задано неверно.';
        ActiveControl := cbUser;
      end;
      GD_LGN_INVALID_PASSWORD:
      begin
        ErrorString := sIncorrectPassword;
        ActiveControl := edPassword;
      end;
      GD_LGN_USER_DISABLED:
        ErrorString := 'Учетная запись пользователя заблокирована.'#13#10 +
          'Обратитесь к администратору системы.';
      GD_LGN_WORK_TIME_VIOLATION:
        ErrorString := 'Вход не в рабочее время запрещен.';
      GD_LGN_USER_ACCESS_DENIED:
        ErrorString := 'Пользователь не имеет прав на вход в подсистему.';
      GD_LGN_GROUP_DISABLED:
        ErrorString := 'Группы, используемые пользователем, заблокированы.';
      GD_LGN_OK:
        Result := True;
      GD_LGN_OK_CHANGE_PASSWORD:
      begin
        FChangePass := True;
        Result := True;
      end;
    end;

    //
    //  Если необходимы права администратора

    if
      Result and
      FAdminRightsRequest and
      (
        (AnsiComparetext(spUserLogin.ParamByName('ibname').AsString, SysDBAUserName) <> 0)
      )
    then begin
      Result := False;
      ErrorString := 'Подключение в однопользовательском режиме ' +
        'возможно только под учетной записью Administrator!';
    end;

    if not Result then
    begin
      if not ASilent then
        MessageBox(Handle,
          PChar(ErrorString),
          'Внимание',
          MB_OK or MB_ICONHAND or MB_TASKMODAL);
    end else
      ReadConnectionData;

  finally
    if spUserLogin.Prepared then
      spUserLogin.UnPrepare;

    if ibtSecurity.InTransaction then
      ibtSecurity.Commit;
  end;
end;

procedure TdlgSecLogIn.SetDatabase(const Value: TIBDatabase);
begin
  spUserLogin.Database := Value;
  ibtSecurity.DefaultDatabase := Value;
end;

procedure TdlgSecLogIn.PrepareSelf;
var
  Reg: TRegistry;
  SL: TStringList;
  I: Integer;
  Path: String;
begin
  lServerName.Caption := ExtractServerName(Database.DatabaseName);

  FSL.Clear;
  cbDBFileName.Items.Clear;

  SL := TStringList.Create;
  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey(ClientAccessRegistrySubKey, False) then
    begin
      Reg.GetKeyNames(SL);
      Path := Reg.CurrentPath;
      for I := 0 to SL.Count - 1 do
      begin
        if cbDBFileName.Items.IndexOf(SL[I]) = -1 then
        begin
          if Reg.OpenKey(SL[I], False) then
          begin
            cbDBFileName.Items.AddObject(SL[I], Pointer(FSL.Add(Reg.ReadString('Database'))));
            Reg.CloseKey;
            Reg.OpenKey(Path, False);
          end;
        end;
      end;
    end;
  finally
    SL.Free;
    Reg.Free;
  end;

  cbDBFileName.Items.AddObject('<Зарегистрировать>',
    Pointer(FSL.Add('<Зарегистрировать>')));

  for I := 0 to cbdbFileName.Items.Count - 1 do
  begin
    if FSL.Count > 0 then
    begin
      if AnsiCompareText(Database.DatabaseName, FSL[Integer(cbdbFileName.Items.Objects[I])]) = 0 then
      begin
        cbdbFileName.ItemIndex := I;
        break;
      end;
    end;  
    if I = (cbdbFileName.Items.Count - 1) then
      cbDBFileName.ItemIndex := cbDBFileName.Items.AddObject(ExtractFileName(Database.DatabaseName),
        Pointer(FSL.Add(Database.DatabaseName)));
  end;

  lSubSystemName.Caption := Application.Title;

  GetPasswordFromRegistry;
end;

function TdlgSecLogIn.GetDatabase: TIBDatabase;
begin
  Result := ibtSecurity.DefaultDatabase;
end;

procedure TdlgSecLogIn.ReadConnectionData;
begin
  if Assigned(FOnConnectionParams) then
    FOnConnectionParams(Self);
end;

procedure TdlgSecLogIn.SetPassword(const Value: String);
begin
  edPassword.Text := Value;
end;

procedure TdlgSecLogIn.SetUserName(const Value: String);
begin
  cbUser.Text := Value;
end;

function TdlgSecLogIn.GetPassword: String;
begin
  Result := edPassword.Text;
end;

function TdlgSecLogIn.GetUserName: String;
begin
  Result := cbUser.Text;
end;

function TdlgSecLogIn.TryAdminLogin: Boolean;
begin
  Result := False;

  if gd_CmdLineParams.ServerName > '' then
    exit;

  if FFirstLogin then
  begin
    if RunLoginProc('Administrator', 'Administrator', FSubSystemKey, True) then
    begin
      Result := True;
      ModalResult := mrOk;
    end;
  end;
end;

procedure TdlgSecLogIn.cbDBFileNameChange(Sender: TObject);
var
  OldK: Boolean;
  OldD: String;
  I: Integer;
  IBSS: TIBSecurityService;
  FSysDBAUserName, FSysDBAPassword: String;
  //DbShut: TgsDatabaseShutdown;
begin
  FAutoCloseCounter := MaxInt;
  edPassword.Text := '';

  if cbDBFileName.Text = '<Зарегистрировать>' then
  begin
    OldK := Database.Connected;

    with Tgd_security_dlgDatabases.Create(Self) do
    try
      Database.Connected := False;

      // если базы к которой мы пытаемся подключиться нет
      // в списке, то добавим ее туда
      for I := 0 to lv.Items.Count - 1 do
      begin
        if (lv.Items[I].SubItems.Count > 0) and (AnsiCompareText(lv.Items[I].SubItems[0], Database.DatabaseName) = 0) then
          break;
        if I = lv.Items.Count - 1 then
        begin
          with lv.Items.Add do
          begin
            Caption := ExtractFileName(Database.DatabaseName);
            SubItems.Text := Database.DatabaseName;
          end;
        end;
      end;

      if ShowModal = mrOk then
      begin
        PrepareSelf;
        if lv.Selected <> nil then
        begin
          cbDBFileName.ItemIndex :=
            cbDBFileName.Items.IndexOf(lv.Selected.Caption);
          GetPasswordFromRegistry;
        end;
      end else
      begin
        PrepareSelf;
        exit;
      end;
    finally
      Free;

      Database.Connected := OldK;
    end;
  end;

  if cbdbFileName.ItemIndex >= 0 then
  begin
    OldD := Database.DatabaseName;
    OldK := Database.Connected;
    Database.Connected := False;
    Database.DatabaseName := FSL[Integer(cbDBFileName.Items.Objects[cbdbFileName.ItemIndex])];
    try
      try
        Database.Connected := OldK;
      except
        on E: EIBError do
        begin
          {if E.IBErrorCode = 335544528 then
          begin
            if MessageBox(Handle,
              'Выбранная база данных находится в однопользовательском режиме.'#13#10 +
              'Перевести ее в многопользовательский режим?',
              'Внимание',
              MB_YESNO or MB_ICONQUESTION) = IDNO then
            begin
              raise;
            end;

            DbShut := TgsDatabaseShutdown.Create(Self);
            try
              DbShut.Database := Database;
              if DbShut.IsShutDowned then
                DbShut.BringOnline;
            finally
              DbShut.Free;
            end;

            Abort;

          end
          else} if (E.IBErrorCode = 335544472) then
          begin
            // сервер есть но старт юзера нет
            if MessageBox(Handle,
              'Указанный сервер Interbase/Firebird/Yaffil не сконфигурирован для работы с системой Гедымин.'#13#10 +
              'Произвести его настройку прямо сейчас?',
              'Ошибка',
              MB_YESNO or MB_ICONEXCLAMATION or MB_TASKMODAL) = IDNO then
            begin
              raise;
            end;

            //...
            FSysDBAPassword := 'masterkey';
            FSysDBAUserName := SysDBAUserName;

            if not LoginDialogEx(ExtractServerName(Database.DatabaseName), FSysDBAUserName, FSysDBAPassword, True) then
              raise;

            IBSS := TIBSecurityService.Create(Self);
            try
              IBSS.ServerName := ExtractServerName(Database.DatabaseName);
              IBSS.LoginPrompt := False;
              IBSS.Protocol := TCP;
              IBSS.Params.Add('user_name=' + SysDBAUserName);
              IBSS.Params.Add('password=' + FSysDBAPassword);
              IBSS.Active := True;
              try
                IBSS.UserName := 'STARTUSER';
                IBSS.FirstName := ''; //FieldByName('fullname').AsString;
                IBSS.MiddleName := '';
                IBSS.LastName := '';
                IBSS.UserID := 0;
                IBSS.GroupID := 0;
                IBSS.Password := 'startuser';
                IBSS.AddUser;
                while IBSS.IsServiceRunning do
                  Sleep(100);
              finally
                IBSS.Active := False;
              end;
            finally
              IBSS.Free;
            end;
          end else
            raise;
        end;
      end;

      GetPasswordFromRegistry;
      
      if gd_CmdLineParams.ServerName = '' then
      begin
        FDatabaseChanged := True;
      end;
    except
      on E: Exception do
      begin
        Application.ShowException(E);
        Database.Connected := False;
        Database.DatabaseName := OldD;
        Database.Connected := OldK;
        PrepareSelf;
      end;
    end;
  end;
end;

constructor TdlgSecLogIn.Create(AnOwner: TComponent);
begin
  inherited;
  FSL := TStringList.Create;
  FDatabaseChanged := False;
  KL := -1;
  FAutoCloseCounter := 180; // 3 minutes. set in correspondence with Timer.Interval
end;

destructor TdlgSecLogIn.Destroy;
begin
  FSL.Free;
  inherited;
end;

procedure TdlgSecLogIn.actHelpExecute(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure TdlgSecLogIn.cbUserChange(Sender: TObject);
begin
  GetPasswordFromRegistry;
end;

procedure TdlgSecLogIn.actVerExecute(Sender: TObject);
begin
  with Tgd_dlgAbout.Create(Self) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

end.

