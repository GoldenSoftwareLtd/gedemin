
unit Storages;

interface

uses
  gsStorage;

var
  GlobalStorage: TgsGlobalStorage;
  CompanyStorage: TgsCompanyStorage;
  UserStorage: TgsUserStorage;
  AdminStorage: TgsUserStorage;

procedure SaveStorages;

implementation

uses
  SysUtils, gd_security, gd_directories_const;

procedure SaveStorages;
begin
  {.$IFDEF GEDEMIN}

  if not IBLogin.LoggedIn then
    exit;

  if Assigned(GlobalStorage) then
    GlobalStorage.SaveToDataBase;

  if Assigned(UserStorage) then
  begin
    //UserStorage.SaveToDataBase;
    // сохранит при смене пользователя на -1
    UserStorage.UserKey := -1;
  end;

  if Assigned(CompanyStorage) then
  begin
    CompanyStorage.CompanyKey := -1;
  end;

  {.$ENDIF}
end;

initialization
  GlobalStorage := TgsGlobalStorage.Create(st_root_Global);
  CompanyStorage := TgsCompanyStorage.Create(st_root_Company);
  UserStorage := TgsUserStorage.Create(st_root_User);
  AdminStorage := nil;

finalization
  FreeAndNil(GlobalStorage);
  FreeAndNil(CompanyStorage);
  FreeAndNil(UserStorage);
  FreeAndNil(AdminStorage);
end.
