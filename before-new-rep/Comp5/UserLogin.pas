
{

  1.00
  1.01    22-aug-99    andreik     ParamsFile now can include metavariables
                                   %d, %s etc. for help see xBasics.pas

  1.02    27-aug-99    andreik     OnAfterLogOn event added.

  Known problems

  OnAfterLogon calls before Database is started.
}


unit UserLogin;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  UserLoginDlg, UserInGroupsDlg, DBTables;

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
  TUserLogin = class(TComponent)
  private
    FUserKey: Integer;
    FUserName: String;
    FIBPassw: String;
    FIBName: String;
    FParams: TStrings;
    FUserRights: TUserRights;
    FStartTime: TDateTime;
    FSessionKey: Integer;
    FSubSystemKey: Integer;
    FSubSystemName: String;
    FParamsFile: String;
    FCancelLogOn: Boolean;
    FPeopleKey: Integer;
    FPeopleActivated: Boolean;
    FOnAfterLogon: TNotifyEvent;
    procedure SetUserKey(const Value: Integer);
    procedure SetIBName(const Value: String);
    procedure SetIBPassw(const Value: String);
    procedure SetParams(const Value: TStrings);
    function GetParams: TStrings;
    procedure SetUserRights(const Value: TUserRights);
    procedure SetStartTime(const Value: TDateTime);
    function GetSessionDuration: TDateTime;
    procedure SetSessionDuration(const Value: TDateTime);
    procedure SetSessionKey(const Value: Integer);
    procedure SetSubSystemKey(const Value: Integer);
    procedure SetSubSystemName(const Value: String);
    procedure SetUserName(const Value: String);
    procedure SetPeopleKey(const Value: Integer);
    function GetPeopleKey: Integer;

  protected
    procedure Loaded; override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure Login;
    procedure Logoff;
    procedure UserInGroups;
    procedure StartDatabase;
    procedure ShutdownDatabase;
    procedure ShowConnectionProp;

    // Поле для сувязі карыстальніка з чалавекам у базе (сувязь на табліцу ph_people)
    property PeopleKey: Integer read GetPeopleKey write SetPeopleKey;
    // Паколькі табліцы зь людзьмі можа не існаваць, то патрэбна поле
    // якое б паказвала ці даступен PeopleKey
    property PeopleActivated: Boolean read FPeopleActivated;

  published
    property UserKey: Integer read FUserKey write SetUserKey stored False;
    property UserName: String read FUserName write SetUserName stored False;
    property IBName: String read FIBName write SetIBName stored False;
    property IBPassw: String read FIBPassw write SetIBPassw stored False;
    property Params: TStrings read GetParams write SetParams stored True;
    property UserRights: TUserRights read FUserRights write SetUserRights stored False;
    property StartTime: TDateTime read FStartTime write SetStartTime stored False;
    property SessionDuration: TDateTime read GetSessionDuration write SetSessionDuration stored False;
    property SessionKey: Integer read FSessionKey write SetSessionKey stored False;
    property SubSystemKey: Integer read FSubSystemKey write SetSubSystemKey stored False;
    property SubSystemName: String read FSubSystemName write SetSubSystemName stored False;
    property ParamsFile: String read FParamsFile write FParamsFile;
    property CancelLogOn: Boolean read FCancelLogOn;
    property OnAfterLogon: TNotifyEvent read FOnAfterLogon write FOnAfterLogon;
  end;

type
  TSecItem = class(TObject)
  private
    FUserKey: Integer;
    FUserGroupKey: Integer;
    function GetIsUser: Boolean;
    procedure SetIsUser(const Value: Boolean);
    procedure SetUserGroupKey(const Value: Integer);
    procedure SetUserKey(const Value: Integer);

  public
    constructor Create(const AUserKey, AUserGroupKey: Integer);

    property IsUser: Boolean read GetIsUser write SetIsUser;
    property UserKey: Integer read FUserKey write SetUserKey;
    property UserGroupKey: Integer read FUserGroupKey write SetUserGroupKey;
  end;

function UserRight2Str(const UR: TUserRight): String;
function UserRights2Str(const UR: TUserRights): String;

var
  CurrentUser: TUserLogin;
  Database: TDatabase;

implementation

uses
  LoginPropDlg, Operation, xBasics;

{ TUserLogin }

constructor TUserLogin.Create(AnOwner: TComponent);
begin
  Assert(CurrentUser = nil);

  inherited Create(AnOwner);
  CurrentUser := Self;
  FParams := TStringList.Create;
  FCancelLogOn := False;
  FPeopleActivated := False;
end;

destructor TUserLogin.Destroy;
begin
  inherited Destroy;
  FParams.Free;
  CurrentUser := nil;
end;

function TUserLogin.GetParams: TStrings;
begin
  Result := FParams;
end;

function TUserLogin.GetPeopleKey: Integer;
begin
  Assert(FPeopleActivated);
  Result := FPeopleKey;
end;

function TUserLogin.GetSessionDuration: TDateTime;
begin
  Result := Now - FStartTime;
end;

procedure TUserLogin.Loaded;
var
  FileName: String;
begin
  inherited Loaded;

//  FileName := ExtractFilePath(Application.EXEName) + FParamsFile;
  FileName := RealFileName(FParamsFile);
  if FileExists(FileName) then
    FParams.LoadFromFile(FileName);
end;

procedure TUserLogin.Login;
var
  Qry: TQuery;
  ShowLoginParams: Boolean;
begin
  Assert(Database = nil);
  Assert(FParams <> nil);

  Database := TDatabase.Create(Application);
  try
    Database.Connected := False;
    Database.DriverName := 'INTRBASE';
    Database.DatabaseName := 'xxx';
    Database.LoginPrompt := False;
    Database.KeepConnection := False;
    Database.Params := FParams;
    Database.Params.Add('USER NAME=STARTUSER');//SYSDBA');
    Database.Params.Add('PASSWORD=startuser');//masterkey');
    try
      Database.Connected := True;
    except
      ShowMessage('DataBase user for this program is not create');
      FCancelLogOn := True;
      Exit;
    end;

    with TUserLoginDialog.Create(Self) do
    try
      if ShowModal = mrCancel then
      begin
        FCancelLogOn := True;
        exit;
      end;

      FStartTime := Now;
      FUserKey := spUserLogin.ParamByName('userkey').AsInteger;
      FUserName := edUser.Text;
      FIBName := spUserLogin.ParamByName('ibname').AsString;
      FIBPassw := spUserLogin.ParamByName('ibpassw').AsString;
      FSessionKey := spUserLogin.ParamByName('session').AsInteger;
      FSubSystemKey := spUserLogin.ParamByName('subsystemkey').AsInteger;
      FSubSystemName := edSubSystem.Text;

      try
        tblUser.Open;

        if tblUser.FindKey([FUserKey]) then
        begin
          FPeopleKey := tblUser.FieldByName('peoplekey').AsInteger;
          FPeopleActivated := True;
        end else
          FPeopleActivated := False;
        tblUser.Close;
      except
        FPeopleActivated := False;
      end;

      ShowLoginParams := chbxShowLoginParams.Checked;
    finally
      Free;
    end;

    // определяем права пользователя
    Qry := TQuery.Create(Self);
    try
      Qry.DatabaseName := 'xxx';
      Qry.SQL.Text := 'SELECT userright FROM fin_p_sec_getrightsforuser(:UK, :SS)';
      Qry.ParamByName('UK').AsInteger := FUserKey;
      Qry.ParamByName('SS').AsInteger := FSubSystemKey;
      Qry.Open;
      Qry.First;
      FUserRights := [];
      while not Qry.EOF do
      begin
        case Qry.Fields[0].AsInteger of
          urLoginSubSystemKey: FUserRights := FUserRights + [urLoginSubSystem];
          urAdminKey: FUserRights := FUserRights + [urAdmin];
          urBackupDataKey: FUserRights := FUserRights + [urBackupData];
          urRestoreDataKey: FUserRights := FUserRights + [urRestoreData];
          urChangeInterfaceKey: FUserRights := FUserRights + [urChangeInterface];
        end;
        Qry.Next;
      end;
      Qry.Close;
    finally
      Qry.Free;
    end;

    if ShowLoginParams then
      ShowConnectionProp;

    if Assigned(FOnAfterLogon) then
      FOnAfterLogon(Self);  

  finally
    Database.Free;
    Database := nil;
  end;
end;

procedure TUserLogin.Logoff;
begin
  //
end;

procedure TUserLogin.SetIBName(const Value: String);
begin
  //
end;

procedure TUserLogin.SetIBPassw(const Value: String);
begin
  //
end;

procedure TUserLogin.SetParams(const Value: TStrings);
begin
  FParams.Assign(Value);
end;

procedure TUserLogin.SetPeopleKey(const Value: Integer);
begin
  //...
end;

procedure TUserLogin.SetSessionDuration(const Value: TDateTime);
begin
  //
end;

procedure TUserLogin.SetSessionKey(const Value: Integer);
begin
//  FSessionKey := Value;
end;

procedure TUserLogin.SetStartTime(const Value: TDateTime);
begin
//  FStartTime := Value;
end;

procedure TUserLogin.SetSubSystemKey(const Value: Integer);
begin
//  FSubSystemKey := Value;
end;

procedure TUserLogin.SetSubSystemName(const Value: String);
begin
//  FSubSystemName := Value;
end;

procedure TUserLogin.SetUserKey(const Value: Integer);
begin
  //
end;

procedure TUserLogin.SetUserName(const Value: String);
begin
  FUserName := Value;
end;

procedure TUserLogin.SetUserRights(const Value: TUserRights);
begin
//  FUserRights := Value;
end;

procedure TUserLogin.ShowConnectionProp;
var
  spDBV: TStoredProc;
begin
  with TLoginPropDialog.Create(Self) do
  try
    lSubSystem.Caption := Format(lSubSystem.Caption, [FSubSystemKey, FSubSystemName]);
    lUser.Caption := Format(lUser.Caption, [FUserKey, FUserName]);
    lUserRights.Caption := Format(lUserRights.Caption, [UserRights2Str(FUserRights)]);
    lSession.Caption := Format(lSession.Caption, [FSessionKey]);
    lStartWork.Caption := Format(lStartWork.Caption, [DateTimeToStr(FStartTime), TimeToStr(SessionDuration)]);
    memoDatabaseParams.Lines.Assign(Database.Params);

    spDBV := TStoredProc.Create(Self);
    try
      spDBV.DatabaseName := 'xxx';
      spDBV.StoredProcName := 'fin_p_ver_getdbversion';
      spDBV.ExecProc;
      lDBversion.Caption := Format(lDBVersion.Caption, [spDBV.ParamByName('VersionString').AsString]);
    finally
      spDBV.Free;
    end;

    ShowModal;
  finally
    Free;
  end;
end;

procedure TUserLogin.ShutdownDatabase;
begin
  if Database = nil then
    exit;

  //!!!
  CurrentOperation := TOperation.Create;
  CurrentOperation.OpType := 30;
  CurrentOperation.Post;

  Database.Connected := False;
  Database.Free;
  Database := nil;
end;

procedure TUserLogin.StartDatabase;
begin
  Assert(Database = nil);
  Assert(not FCancelLogOn);

  Database := TDatabase.Create(nil);
  Database.DriverName := 'INTRBASE';
  Database.DatabaseName := 'xxx';
  Database.Params := FParams;
  Database.Params.Add('USER NAME=' + FIBName);
  Database.Params.Add('PASSWORD=' + FIBPassw);
  Database.KeepConnection := True;
  Database.LoginPrompt := False;
  Database.Connected := True;
end;

procedure TUserLogin.UserInGroups;
begin
  with TUserInGroupsDialog.Create(Self, FUserKey) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

{ TSecItem }

constructor TSecItem.Create(const AUserKey, AUserGroupKey: Integer);
begin
  Assert((AUserKey = -1) or (AUserGroupKey = -1));
  inherited Create;
  FUserKey := AUserKey;
  FUserGroupKey := AUserGroupKey;
end;

function TSecItem.GetIsUser: Boolean;
begin
  Result := FUserKey <> -1;
end;

procedure TSecItem.SetIsUser(const Value: Boolean);
begin
  //...
end;

procedure TSecItem.SetUserGroupKey(const Value: Integer);
begin
  FUserGroupKey := Value;
  if FUserGroupKey <> -1 then
    FUserKey := -1;
end;

procedure TSecItem.SetUserKey(const Value: Integer);
begin
  FUserKey := Value;
  if FUserKey <> -1 then
    FUserGroupKey := -1;
end;

function UserRight2Str(const UR: TUserRight): String;
const
  Arr: array[TUserRight] of String = ('Вход в подсистему',
    'Администрирование', 'Сохранение данных', 'Восстановление данных', 'Настройка интерфейса');
begin
  Result := Arr[UR];
end;

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

initialization
  CurrentUser := nil;

finalization
  if Assigned(Database) then
    Database.Free;
end.

