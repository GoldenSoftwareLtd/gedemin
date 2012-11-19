unit gsIBLogin;

interface

uses
  Classes, ComServ, ComObj, Gedemin_TLB;

type
  TgsIBLogin = class(TAutoObject, IgsBoLogin)
  protected
    function  Get_ServerName: WideString; safecall;
    function  Get_Database: IgsIBDatabase; safecall;
    function  Get_DBID: Integer; safecall;
    function  Get_CompanyName: WideString; safecall;
    function  Get_CompanyKey: Integer; safecall;
    function  Get_ContactName: WideString; safecall;
    function  Get_ContactKey: Integer; safecall;
    function  Get_UserName: WideString; safecall;
    function  Get_UserKey: Integer; safecall;
    function  Get_AllowUserAudit: WordBool; safecall;
    function  Get_AuditMaxDays: Integer; safecall;
    function  Get_AuditCache: Integer; safecall;
    function  Get_AuditLevel: TgsAuditLevel; safecall;
    function  Get_DBVersionComment: WideString; safecall;
    function  Get_DBVersionID: Integer; safecall;
    function  Get_DBReleaseDate: TDateTime; safecall;
    function  Get_DBVersion: WideString; safecall;
    function  Get_DatabaseName: WideString; safecall;
    function  Get_SubSystemName: WideString; safecall;
    function  Get_SubSystemKey: Integer; safecall;
    function  Get_IsShutDown: WordBool; safecall;
    function  Get_IsIBUserAdmin: WordBool; safecall;
    function  Get_IsUserAdmin: WordBool; safecall;
    function  Get_GroupName: WideString; safecall;
    function  Get_Ingroup: Integer; safecall;
    function  Get_SessionKey: Integer; safecall;
    function  Get_StartTime: TDateTime; safecall;
    function  Get_SessionDuration: TDateTime; safecall;
    function  Get_IBPassword: WideString; safecall;
    function  Get_IBName: WideString; safecall;
    function  Get_ShutDownRequested: WordBool; safecall;
    function  Get_ShutDown: WordBool; safecall;
    function  Get_LoggedIn: WordBool; safecall;
    function  Get_CompanyOpened: WordBool; safecall;
    function  Get_ComputerName: WideString; safecall;
    function  Get_LoginParam(const ParamName: WideString): WideString; safecall;

    procedure CloneDatabase(const ADatabase: IgsIBDatabase); safecall;
    function  OpenCompany(ShowDialogAnyway: WordBool): WordBool; safecall;
    procedure UpdateCompanyData; safecall;
    procedure UpdateUserData; safecall;
    procedure SetSubSystemKey(Value: Integer); safecall;
    function  Logoff: WordBool; safecall;
    function  Login: WordBool; safecall;
    procedure Set_Ingroup(Value: Integer); safecall;

    function  Get_IsHolding: WordBool; safecall;
    function  Get_HoldingList: WideString; safecall;
    function  LoginSingle: WordBool; safecall;
    function  BringOnLine: WordBool; safecall;
    procedure ConnectionLost; safecall;
    procedure ConnectionLostMessage; safecall;
    function  LoginSilent(const AnUserName: WideString; const APassword: WideString): WordBool; safecall;
    procedure AddEvent(const AData: WideString; const ASourse: WideString; AnObjectID: Integer;
                       const ATransaction: IgsIBTransaction); safecall;
    function  LoginWithParams(ReadParams: WordBool; ReLogin: WordBool): WordBool; safecall;
    procedure ClearHoldingListCache; safecall;
    procedure ChangeUser(AUserKey: Integer; ACheckMultipleConnections: WordBool); safecall;

  end;

implementation

uses
  gd_security, gdcOLEClassList, prp_methods, IBDatabase, IBSQL;

{ TgsIBLogin }

procedure TgsIBLogin.CloneDatabase(const ADatabase: IgsIBDatabase);
begin
  IBLogin.CloneDatabase(InterfaceToObject(ADatabase) as TIBDatabase); 
end;

function TgsIBLogin.Get_AllowUserAudit: WordBool;
begin
  Result := IBLogin.AllowUserAudit
end;

function TgsIBLogin.Get_AuditCache: Integer;
begin
  Result := IBLogin.AuditCache
end;

function TgsIBLogin.Get_AuditLevel: TgsAuditLevel;
begin
  Result := TgsAuditLevel(IBLogin.AuditLevel)
end;

function TgsIBLogin.Get_AuditMaxDays: Integer;
begin
  Result := IBLogin.AuditMaxDays;
end;

function TgsIBLogin.Get_CompanyKey: Integer;
begin
  Result := IBLogin.CompanyKey
end;

function TgsIBLogin.Get_CompanyName: WideString;
begin
  Result := IBLogin.CompanyName;
end;

function TgsIBLogin.Get_CompanyOpened: WordBool;
begin
  Result := IBLogin.CompanyOpened;
end;

function TgsIBLogin.Get_ComputerName: WideString;
begin
  Result := IBLogin.ComputerName;
end;

function TgsIBLogin.Get_ContactKey: Integer;
begin
  Result := IBLogin.ContactKey;
end;

function TgsIBLogin.Get_ContactName: WideString;
begin
  Result := IBLogin.ContactName;
end;

function TgsIBLogin.Get_Database: IgsIBDatabase;
begin
  Result := GetGdcOLEObject(IBLogin.Database) as IgsIBDatabase;
end;

function TgsIBLogin.Get_DatabaseName: WideString;
begin
  Result := IBLogin.DatabaseName;
end;

function TgsIBLogin.Get_DBID: Integer;
begin
  Result := IBLogin.DBID;
end;

function TgsIBLogin.Get_DBReleaseDate: TDateTime;
begin
  Result := IBLogin.DBReleaseDate;
end;

function TgsIBLogin.Get_DBVersion: WideString;
begin
  Result := IBLogin.DBVersion;
end;

function TgsIBLogin.Get_DBVersionComment: WideString;
begin
  Result := IBLogin.DBVersionComment;
end;

function TgsIBLogin.Get_DBVersionID: Integer;
begin
  Result := IBLogin.DBVersionID;
end;

function TgsIBLogin.Get_GroupName: WideString;
begin
  Result := IBLogin.GroupName;
end;

function TgsIBLogin.Get_IBName: WideString;
begin
  Result := IBLogin.IBName;
end;

function TgsIBLogin.Get_IBPassword: WideString;
begin
  Result := IBLogin.IBPassword;
end;

function TgsIBLogin.Get_Ingroup: Integer;
begin
  Result := IBLogin.Ingroup;
end;

function TgsIBLogin.Get_IsIBUserAdmin: WordBool;
begin
  Result := IBLogin.IsIBUserAdmin;
end;

function TgsIBLogin.Get_IsShutDown: WordBool;
begin
  Result := IBLogin.ShutDown;
end;

function TgsIBLogin.Get_IsUserAdmin: WordBool;
begin
  Result := IBLogin.IsUserAdmin;
end;

function TgsIBLogin.Get_LoggedIn: WordBool;
begin
  Result := IBLogin.LoggedIn;
end;

function TgsIBLogin.Get_LoginParam(
  const ParamName: WideString): WideString;
begin
  Result := IBLogin.LoginParam[ParamName];
end;

function TgsIBLogin.Get_ServerName: WideString;
begin
  Result := IBLogin.ServerName;
end;

function TgsIBLogin.Get_SessionDuration: TDateTime;
begin
  Result := IBLogin.SessionDuration;
end;

function TgsIBLogin.Get_SessionKey: Integer;
begin
  Result := IBLogin.SessionKey;
end;

function TgsIBLogin.Get_ShutDown: WordBool;
begin
  Result := IBLogin.ShutDown;
end;

function TgsIBLogin.Get_ShutDownRequested: WordBool;
begin
  Result := IBLogin.ShutDownRequested;
end;

function TgsIBLogin.Get_StartTime: TDateTime;
begin
  Result := IBLogin.StartTime;
end;

function TgsIBLogin.Get_SubSystemKey: Integer;
begin
  Result := IBLogin.SubSystemKey;
end;

function TgsIBLogin.Get_SubSystemName: WideString;
begin
  Result := IBLogin.SubSystemName;
end;

function TgsIBLogin.Get_UserKey: Integer;
begin
  Result := IBLogin.UserKey;
end;

function TgsIBLogin.Get_UserName: WideString;
begin
  Result := IBLogin.UserName;
end;

function TgsIBLogin.Login: WordBool; safecall;
begin
  IBLogin.Login;
end;

function TgsIBLogin.Logoff: WordBool; safecall;
begin
  IBLogin.Logoff;
end;

function TgsIBLogin.OpenCompany(ShowDialogAnyway: WordBool): WordBool;
begin
  Result := IBLogin.OpenCompany(ShowDialogAnyway);
end;

procedure TgsIBLogin.Set_Ingroup(Value: Integer);
begin
  IBLogin.Ingroup := Value;
end;

procedure TgsIBLogin.SetSubSystemKey(Value: Integer);
begin
  IBLogin.SetSubSystemKey(Value);
end;

procedure TgsIBLogin.UpdateCompanyData;
begin
  IBLogin.UpdateCompanyData;
end;

procedure TgsIBLogin.UpdateUserData;
begin
  IBLogin.UpdateUserData;
end;

procedure TgsIBLogin.AddEvent(const AData, ASourse: WideString;
  AnObjectID: Integer; const ATransaction: IgsIBTransaction);
begin
  IBLogin.AddEvent(AData, ASourse, AnObjectID, InterfaceToObject(ATransaction))
end;

function TgsIBLogin.BringOnLine: WordBool;
begin
  Result := IBLogin.BringOnLine;
end;

procedure TgsIBLogin.ConnectionLost;
begin
  IBLogin.ConnectionLost;
end;

procedure TgsIBLogin.ConnectionLostMessage;
begin
  IBLogin.ConnectionLostMessage;
end;

function TgsIBLogin.Get_HoldingList: WideString;
begin
  Result := IBLogin.HoldingList;
end;

function TgsIBLogin.Get_IsHolding: WordBool;
begin
  Result := IBLogin.IsHolding;
end;

function TgsIBLogin.LoginSilent(const AnUserName,
  APassword: WideString): WordBool;
begin
  Result := IBLogin.LoginSilent(AnUserName, APassword);
end;

function TgsIBLogin.LoginSingle: WordBool;
begin
  Result := IBLogin.LoginSingle;
end;

function TgsIBLogin.LoginWithParams(ReadParams,
  ReLogin: WordBool): WordBool;
begin
  if ReLogin then
    Result := IBLogin.Relogin
  else
    Result := IBLogin.Login;
end;

procedure TgsIBLogin.ClearHoldingListCache;
begin
  IBLogin.ClearHoldingListCache;
end;

procedure TgsIBLogin.ChangeUser(AUserKey: Integer; ACheckMultipleConnections: WordBool);
begin
  IBLogin.ChangeUser(AUserKey, ACheckMultipleConnections);
end;

initialization
  TAutoObjectFactory.Create(ComServer, TgsIBLogin, CLASS_gs_BoLogin,
    ciMultiInstance, tmApartment);
end.
