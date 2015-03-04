
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
    UserStorage.ObjectKey := -1;

  if Assigned(CompanyStorage) then
    CompanyStorage.ObjectKey := -1;

  {.$ENDIF}
end;

initialization
  GlobalStorage := TgsGlobalStorage.Create;
  CompanyStorage := TgsCompanyStorage.Create;
  UserStorage := TgsUserStorage.Create;
  AdminStorage := nil;

finalization
  FreeAndNil(GlobalStorage);
  FreeAndNil(CompanyStorage);
  FreeAndNil(UserStorage);
  FreeAndNil(AdminStorage);
end.
