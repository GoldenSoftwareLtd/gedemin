
{++

  Copyright (c) 1998-2000 by Golden Software of Belarus

  Module

    boSecurity.pas

  Abstract

    Visual component for choosing user, user rights and pasword.

  Author

    Andrei Kireev (22-aug-99), Romanovski Denis (04.02.2000)

  Revisions history

  1.00
  1.01    22-aug-99    andreik     ParamsFile now can include metavariables
                                   %d, %s etc. for help see xBasics.pas

  1.02    27-aug-99    andreik     OnAfterLogOn event added.

--}


unit boSecurity;

interface

uses
  Windows,            Messages,           SysUtils,           Classes,
  Graphics,           Controls,           Forms,              Dialogs,
  DB,                 IBDatabase;

type
  TUserRight = (urLoginSubSystem, urAdmin, urBackupData, urRestoreData, urChangeInterface);
  TUserRights = set of TUserRight;

const
  urLoginSubSystemKey   = 0;
  urAdminKey            = 10;
  urBackupDataKey       = 20;
  urRestoreDataKey      = 30;
  urChangeInterfaceKey  = 40;

type
  TboIBSecurity = class(TComponent)
  private
    FDatabase: TIBDatabase; // Компонент подключения к базе данных
    FParamsFile: TFileName; // Файл, содержащий установки для подключения
    FParams: TStrings; // Установки для подключения
    FLogInCancelled: Boolean; // Отменено подключения к базе

    FIBName: String; // Имя пользователя Interbase
    FIBPassw: String; // Пароль пользователя Interbase

    FUserKey: Integer; // Код пользователя
    FUserName: String; // Имя пользователя
    FStartTime: TDateTime; // Начало работы
    FSessionKey: Integer; // Код сессии
    FSubSystemKey: Integer; // Код подсистемы
    FSubSystemName: String; // Название подсистемы

    FUserRights: TUserRights; // Права пользователя при подключении
    FVersionString: String; // Версия базы данных

    procedure SetDatabase(const Value: TIBDatabase);
    procedure SetParamsFile(const Value: TFileName);
    procedure SetParams(const Value: TStrings);

    function GetActive: Boolean;
    function GetDatabaseName: TFileName;
    function GetCharset: String;
    function GetSessionDuration: TDateTime;

    procedure PrepareNewDatabase;

  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    function Login: Boolean;
    function Logoff: Boolean;
    procedure StartDatabase;
    procedure ShowConnectionProp;

    // Продолжительность сессии
    property SessionDuration: TDateTime read GetSessionDuration;
    // Код пользователя
    property UserKey: Integer read FUserKey;
    // Имя пользователя
    property UserName: String read FUserName;
    // Начало работы
    property StartTime: TDateTime read FStartTime;
    // Код сессии
    property SessionKey: Integer read FSessionKey;
    // Код подсистемы
    property SubSystemKey: Integer read FSubSystemKey;
    // Название подсистемы
    property SubSystemName: String read FSubSystemName;
    // Активно ли текущее подключение к базе данных
    property Active: Boolean read GetActive;
    // Отменено ли подключение к базе
    property LogInCancelled: Boolean read FLogInCancelled;
    // Название базы данных
    property DatabaseName: TFileName read GetDatabaseName;
    property CharSet: String read GetCharset;

  published
    // Подключение к базе данных
    property Database: TIBDatabase read FDatabase write SetDatabase;
    // Путь к файлу, содержащему список параметров
    property ParamsFile: TFileName read FParamsFile write SetParamsFile;
    // Параметры подключения к базе данных
    property Params: TStrings read FParams write SetParams;

  end;


// Глобальная переменная общего текущего пользователя всей системы
// ВНИМАНИЕ! Должен быть только один такой компонент
var
  Security: TboIBSecurity;

function UserRight2Str(const UR: TUserRight): String;
function UserRights2Str(const UR: TUserRights): String;

implementation

uses xBasics, IBStoredProc, IBQuery, boSecurity_dlgLogIn, boSecurity_dlgLoginProp;


//////////////////
// Удаляет пробелы

function DeleteSpaces(S: String): String;
var
  Z: Integer;
begin
  Result := S;

  repeat
    Z := AnsiPos(' ', Result);
    if Z > 0 then
      Result := Copy(Result, 1, Z - 1) + Copy(Result, Z + 1, Length(Result));
  until Z = 0;
end;

{
  ////////////////////////////////////////////
  //////      TboIBSecurity  Class      //////
  ////////////////////////////////////////////
}


{
  ***************************
  ****    Public Part    ****
  ***************************
}


{
  Делаем начальные установки.
}

constructor TboIBSecurity.Create(AnOwner: TComponent);
begin
  // Нельзя позволять более одного такого компонента
  Assert(Security = nil);

  inherited Create(AnOwner);

  Security := Self;
  
  FDatabase := nil;
  FParamsFile := '';
  FParams := TStringList.Create;

  FLogInCancelled := False;
  FVersionString := '';

  FIBName := '';
  FIBPassw := '';

  FUserKey := -1;
  FUserName := '';
  FStartTime := 0;
  FSessionKey := -1;
  FSubSystemKey := -1;
  FSubSystemName := '';

  FUserRights := [];
  FVersionString := '';
end;

{
  Высвобождаем память.
}

destructor TboIBSecurity.Destroy;
begin
  FParams.Free;

  inherited Destroy;

  Security := nil;
end;

{
  Подключение к базе данных.
}

function TboIBSecurity.Login: Boolean;
var
  LogInDatabase: TIBDatabase;
  LogInTransaction: TIBTransaction;
  ShowLoginParams: Boolean;
  GetParams: TIBStoredProc;
  RightsSQL: TIBQuery;
begin
  Result := False;

  LogInDatabase := TIBDatabase.Create(Self);
  LogInTransaction := TIBTransaction.Create(Self);

  try
    LogInDatabase.LoginPrompt := False;
    LogInDatabase.Params.Add('user_name=STARTUSER');
    LogInDatabase.Params.Add('password=startuser');
    LogInDatabase.Params.Add('lc_ctype=' + Charset);

    LogInDatabase.DatabaseName := DatabaseName;
    LogInDatabase.DefaultTransaction := LogInTransaction;

    try
      LogInDatabase.Connected := True;
      LogInTransaction.Active := True;

      with TdlgLogIn.Create(Self) do
      try
        tblUser.Database := LogInDatabase;
        spUserLogin.Database := LogInDatabase;
        ibtSecurity.DefaultDatabase := LogInDatabase;
        ibtSecurity.Active := True;

        if ShowModal <> mrOk then
        begin
          FLogInCancelled := True;
          Exit;
        end;

        ShowLoginParams := chbxShowLoginParams.Checked;

        // Считываем пользователя и пароль
        FIBName := spUserLogin.ParamByName('ibname').AsString;
        FIBPassw := spUserLogin.ParamByName('ibpassw').AsString;

        // Считываем и устанавливаем другие данные о подключении
        // к базе данных

        FStartTime := Now;
        FUserKey := spUserLogin.ParamByName('UserKey').AsInteger;
        FUserName := edUser.Text;
        FSessionKey := spUserLogin.ParamByName('Session').AsInteger;
        FSubSystemKey := spUserLogin.ParamByName('SubSystemKey').AsInteger;
        FSubSystemName := edSubSystem.Text;
      finally
        Free;
      end;

      if LogInDatabase.Connected then
      begin
        if ShowLoginParams then
        begin
          GetParams := TIBStoredProc.Create(Self);
          try
            GetParams.Database := LogInDatabase;
            GetParams.StoredProcName := 'fin_p_ver_getdbversion';
            GetParams.Transaction := LogInTransaction;
            GetParams.ExecProc;
            FVersionString := GetParams.ParamByName('VersionString').AsString;
          finally
            GetParams.Free;
          end;

          ShowConnectionProp;
        end;


        ////////////////////////////////
        // Определяем права пользователя

        RightsSQL := TIBQuery.Create(Self);

        try
          RightsSQL.Database := LogInDatabase;
          RightsSQL.SQL.Text := 'SELECT userright FROM fin_p_sec_getrightsforuser(:UK, :SS)';
          RightsSQL.ParamByName('UK').AsInteger := FUserKey;
          RightsSQL.ParamByName('SS').AsInteger := FSubSystemKey;
          RightsSQL.Open;
          RightsSQL.First;
          FUserRights := [];

          while not RightsSQL.EOF do
          begin
            case RightsSQL.Fields[0].AsInteger of
              urLoginSubSystemKey: FUserRights := FUserRights + [urLoginSubSystem];
              urAdminKey: FUserRights := FUserRights + [urAdmin];
              urBackupDataKey: FUserRights := FUserRights + [urBackupData];
              urRestoreDataKey: FUserRights := FUserRights + [urRestoreData];
              urChangeInterfaceKey: FUserRights := FUserRights + [urChangeInterface];
            end;
            RightsSQL.Next;
          end;
          RightsSQL.Close;
        finally
          RightsSQL.Free;
        end;

        if LogInTransaction.InTransaction then LogInTransaction.Commit;
        LogInDatabase.Connected := False;
        Result := True;
      end;

    except
      raise Exception.Create('Ошибка при подключении к базе данных!');
    end;
  finally
    LogInDatabase.Free;
    LogInTransaction.Free;
  end;
end;

{
  Отключение от базы данных.
}

function TboIBSecurity.Logoff: Boolean;
begin
  Result := True;
end;

procedure TboIBSecurity.StartDatabase;
var
  I: Integer;
begin
  Assert(FDatabase <> nil);
  Assert(not FLogInCancelled);

  FDatabase.LoginPrompt := False;
  FDatabase.Params.Clear;

  ///////////////////////////////////////////
  // Добавляем все пользовательские параметры

  for I := 0 to FParams.Count - 1 do
    if
      (AnsiPos('SERVERNAME=', DeleteSpaces(FParams[I])) = 0)
        and
      (AnsiPos('user_name=', DeleteSpaces(FParams[I])) = 0)
        and
      (AnsiPos('password=', DeleteSpaces(FParams[I])) = 0)
    then
      FDatabase.Params.Add(FParams[I]);

  FDatabase.Params.Insert(0, 'password=' + FIBPassw);
  FDatabase.Params.Insert(0, 'user_name=' + FIBName);
  FDatabase.DatabaseName := DatabaseName;
  FDatabase.Connected := True;
  if FDatabase.DefaultTransaction <> nil then
    FDatabase.DefaultTransaction.Active := True;
end;

{
  Показывает параметры поджключения к базе данных.
}

procedure TboIBSecurity.ShowConnectionProp;
begin
  with TdlgLoginProp.Create(Self) do
  try
    lSubSystem.Caption := Format(lSubSystem.Caption, [FSubSystemKey, FSubSystemName]);
    lUser.Caption := Format(lUser.Caption, [FUserKey, FUserName]);
    lUserRights.Caption := Format(lUserRights.Caption, [UserRights2Str(FUserRights)]);
    lSession.Caption := Format(lSession.Caption, [FSessionKey]);
    lStartWork.Caption := Format(lStartWork.Caption, [DateTimeToStr(FStartTime), TimeToStr(SessionDuration)]);
    memoDatabaseParams.Lines.Assign(Database.Params);
    lDBversion.Caption := Format(lDBVersion.Caption, [FVersionString]);

    ShowModal;
  finally
    Free;
  end;
end;

{
  *******************************
  ****    Protected  Part    ****
  *******************************
}

{
  Удаление компонентов.
}

procedure TboIBSecurity.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);

  if Operation = opRemove then
    if (AComponent = FDatabase) then
    begin
      if not (csDesigning in ComponentState) then LogOff;
      FDatabase := nil;
    end;
end;

{
  *****************************
  ****    Private  Part    ****
  *****************************
}

{
  Устанавливаем компонент подключения к базе данных.
}

procedure TboIBSecurity.SetDatabase(const Value: TIBDatabase);
begin
  if FDatabase <> Value then
  begin
    if
      (FDatabase <> nil)
        and
      not (csDesigning in ComponentState)
        and
      Active
    then
      LogOff;

    FDatabase := Value;

    // Избавляемся от настроек дизайн-режима
    // нового компонента подключения
    if not (csDesigning in ComponentState) then
      PrepareNewDatabase;
  end;
end;

{
  Считывает название файла параметров.
}

procedure TboIBSecurity.SetParamsFile(const Value: TFileName);
var
  FileName: TFileName;
begin
  if FParamsFile <> Value then
  begin
    FParamsFile := Value;
    FileName := RealFileName(Value);

    // Если такой файл существует, то считываем его настройки.
    if
      not (csDesigning in ComponentState)
        and
      FileExists(FileName)
    then
      FParams.LoadFromFile(FileName);
  end;
end;

{
  Устанавливает параметры подключения к базе данных.
}

procedure TboIBSecurity.SetParams(const Value: TStrings);
begin
  if Value <> nil then
    FParams.Assign(Value);
end;

{
  Активно ли подключение к базе данных.
}

function TboIBSecurity.GetActive: Boolean;
begin
  Result := Assigned(FDatabase) and FDatabase.Connected;
end;

{
  Поолучаем путь к файлу базы данных.
}

function TboIBSecurity.GetDatabaseName: TFileName;
var
  I, K: Integer;
begin
  Result := '';

  for I := 0 to FParams.Count - 1 do
  begin
    K := AnsiPos('SERVERNAME=', DeleteSpaces(FParams[I]));

    if K > 0 then
    begin
      Result := Copy(DeleteSpaces(FParams[I]), K + 11, Length(DeleteSpaces(FParams[I])));
      Break;
    end;
  end;

  if (Result = '') and (FDatabase <> nil) then
    Result := FDatabase.DatabaseName;
end;

{
  Возвращает CharSet базы данных.
}

function TboIBSecurity.GetCharset: String;
var
  I, K: Integer;
begin
  Result := '';

  for I := 0 to FParams.Count - 1 do
  begin
    K := AnsiPos('lc_ctype=', DeleteSpaces(FParams[I]));

    if K > 0 then
    begin
      Result := Copy(DeleteSpaces(FParams[I]), K + 9, Length(DeleteSpaces(FParams[I])));
      Break;
    end;
  end;

  if (Result = '') and (FDatabase <> nil) then
    Result := FDatabase.DatabaseName;
end;

{
  Возвращает продолжительность сессии.
}

function TboIBSecurity.GetSessionDuration: TDateTime;
begin
  Result := Now - FStartTime;
end;

{
  Производит подготовку компонента подключения
  к базе данных.
}

procedure TboIBSecurity.PrepareNewDatabase;
begin
  FDatabase.LoginPrompt := False;
  FDatabase.DefaultTransaction.Active := False;
  FDatabase.Connected := False;
  FDatabase.DatabaseName := '';
  FDatabase.Params.Clear;
end;


{
  Права пользователя в текстовом виде.
}

function UserRight2Str(const UR: TUserRight): String;
const
  Arr: array[TUserRight] of String = ('Вход в подсистему',
    'Администрирование', 'Сохранение данных', 'Восстановление данных', 'Настройка интерфейса');
begin
  Result := Arr[UR];
end;

{
  Список прав пользователя в текстовом виде.
}

function UserRights2Str(const UR: TUserRights): String;
var
  I: TUserRight;
begin
  Result := '';
  for I := urLoginSubsystem to urChangeInterface do
    if I in UR then
      Result := Result + ', ' + UserRight2Str(I);
  Delete(Result, 1, 2);
end;


{
  Инициализация и удаление значений
  глабольных переменных.
}



initialization

  Security := nil;

finalization

  if Assigned(Security) then Security := nil;

end.

