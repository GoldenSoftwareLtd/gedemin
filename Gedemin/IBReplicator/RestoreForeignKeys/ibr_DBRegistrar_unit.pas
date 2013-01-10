unit ibr_DBRegistrar_unit;

interface
uses ibr_BaseTypes_unit, Registry, SysUtils,
     Classes, ibr_const;

type
  TDBAliasList = class(TStringList)
  public
    procedure LoadFromRegister;
  end;

  TServerList = class(TStringList)
  public
    procedure LoadFromRegister;
    procedure SaveToRegister;
  end;

  TDBRegistrar = class(TObject)
  private
    FDescription: string;
    FProtocol: string;
    FPassword: string;
    FCharSet: string;
    FDBAlias: string;
    FRole: string;
    FAdditional: string;
    FUser: string;
    FFileName: string;
    FServerName: string;
    FAlias: string;
    FOnLoad: TNotifyEvent;
    FServerList: TServerList;
    FDBAliasList: TDBAliasList;
    procedure SetAdditional(const Value: string);
    procedure SetCharSet(const Value: string);
    procedure SetDBAlias(const Value: string);
    procedure SetDescription(const Value: string);
    procedure SetFileName(const Value: string);
    procedure SetPassword(const Value: string);
    procedure SetProtocol(const Value: string);
    procedure SetRole(const Value: string);
    procedure SetServerName(const Value: string);
    procedure SetUser(const Value: string);
    procedure SetAlias(const Value: string);
    procedure SetOnLoad(const Value: TNotifyEvent);

    procedure DoChange;
    function GetServerList: TServerList;
    function GetDBAliasList: TDBAliasList;
  public
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream);
    procedure LoadFromRegister;
    procedure SaveToRegister;
    function CheckRegisterInfo: Boolean;
    function CheckRegisterInfoErrorMessage: string;
    function DataBaseName: string;
    procedure Delete;

    property DBAlias: string read FDBAlias write SetDBAlias;
    property ServerName: string read FServerName write SetServerName;
    property Protocol: string read FProtocol write SetProtocol;
    property FileName: string read FFileName write SetFileName;
    property Description: string read FDescription write SetDescription;
    property User: string read FUser write SetUser;
    property Password: string read FPassword write SetPassword;
    property Role: string read FRole write SetRole;
    property CharSet: string read FCharSet write SetCharSet;
    property Additional: string read FAdditional write SetAdditional;
    property Alias: string read FAlias write SetAlias;

    property ServerList: TServerList read GetServerList;
    property DBAliasList: TDBAliasList read GetDBAliasList;
    property OnLoad: TNotifyEvent read FOnLoad write SetOnLoad;
  end;

const
  cAliasPath = '\Alias';
  cServerPath = 'Server';
implementation

{ TDBRegistrar }

function TDBRegistrar.CheckRegisterInfo: Boolean;
begin
  Result := ((FServerName > '') or (FProtocol = prLocal)) and (FProtocol > '') and
    (FUser > '') and (FPassword > '') and (FFileName > '') and
    (FCharSet > '');
end;

function TDBRegistrar.CheckRegisterInfoErrorMessage: string;
begin
  Result := '';
  if (FServerName = '') and (FProtocol <> prLocal) then
    Result := EnterServerName
  else
  if FProtocol = '' then
    Result := EnterProtocol
  else
  if FFileName = '' then
    Result := EnterDataBaseFileName
  else
  if FUser = '' then
    Result := EnterUserName
  else
  if FPassword = '' then
    Result := EnterPassword
  else
  if FCharSet = '' then
    Result := EnterCharset;
end;

function TDBRegistrar.DataBaseName: string;
begin
  Result := GetDataBaseName(FServerName, FFileName, FProtocol); 
end;

procedure TDBRegistrar.Delete;
var
  R: TRegistry;
begin
  R := TRegistry.Create;
  try
    if R.OpenKey(RootPath + cAliasPath, True) then
    begin
      if (FAlias = '') or not R.ValueExists(FAlias) then
        Exit
      else
        R.DeleteValue(FAlias);
    end else
      raise Exception.Create(CantLoadRegistryInfo);
  finally
    R.Free;
  end;
end;

procedure TDBRegistrar.DoChange;
begin
  if Assigned(FOnLoad) then
    FOnLoad(Self);
end;

function TDBRegistrar.GetDBAliasList: TDBAliasList;
begin
  if FDBAliasList =  nil then
  begin
    FDBAliasList := TDBAliasList.Create;
  end;

  FDBAliasList.LoadFromRegister;
  Result := FDBAliasList;
end;

function TDBRegistrar.GetServerList: TServerList;
begin
  if FServerList = nil then
  begin
    FServerList := TServerList.Create;
    FServerList.LoadFromRegister;
  end;
  Result := FServerList;
end;

procedure TDBRegistrar.LoadFromRegister;
var
  R: TRegistry;
  Stream: TMemoryStream;
  Info: TRegDataInfo;
begin
  R := TRegistry.Create;
  try
    if R.OpenKey(RootPath + cAliasPath, True) then
    begin
      if (FAlias = '') or not R.ValueExists(FAlias) then
        raise Exception.Create(CantLoadRegistryInfo);
      Stream := TMemoryStream.Create;
      try
        R.GetDataInfo(FAlias, Info);
        Stream.Size := Info.DataSize;
        R.ReadBinaryData(FAlias, Stream.Memory^, Info.DataSize);
        LoadFromStream(Stream);
      finally
        Stream.Free;
        R.CloseKey;
      end;
    end else
      raise Exception.Create(CantLoadRegistryInfo);
  finally
    R.Free;
  end;
end;

procedure TDBRegistrar.LoadFromStream(Stream: TStream);
begin
  FDBAlias := ReadStringFromStream(Stream);
  FServerName := ReadStringFromStream(Stream);
  FProtocol := ReadStringFromStream(Stream);
  FFileName := ReadStringFromStream(Stream);
  FDescription := ReadStringFromStream(Stream);
  FUser := ReadStringFromStream(Stream);
  FPassword := ReadStringFromStream(Stream);
  FRole := ReadStringFromStream(Stream);
  FCharSet := ReadStringFromStream(Stream);
  FAdditional := ReadStringFromStream(Stream);
  DoChange;
end;

procedure TDBRegistrar.SaveToRegister;
var
  R: TRegistry;
  Stream: TMemoryStream;
begin
  R := TRegistry.Create;
  try
    if R.OpenKey(RootPath + cAliasPath, True) then
    begin
      if FDescription = '' then
        FDescription := DataBaseName;
      FAlias := FDescription;
      Stream := TMemoryStream.Create;
      try
        SaveToStream(Stream);
        R.WriteBinaryData(FDescription, Stream.Memory^, Stream.Size);
      finally
        Stream.Free;
        R.CloseKey;
      end;
    end else
      raise Exception.Create(CantSaveRigistryInfo);
    //Сохраняем имя сервера
    if ServerList.IndexOf(FServerName) = - 1 then
    begin
      FServerList.Insert(0, FServerName);
      FServerList.SaveToRegister;
    end;

    if DBAliasList.IndexOf(FAlias) = - 1 then
    begin
      FDBAliasList.Add(FAlias);
    end;
  finally
    R.Free;
  end;
end;

procedure TDBRegistrar.SaveToStream(Stream: TStream);
begin
  SaveStringToStream(FDBAlias, Stream);
  SaveStringToStream(FServerName, Stream);
  SaveStringToStream(FProtocol, Stream);
  SaveStringToStream(FFileName, Stream);
  SaveStringToStream(FDescription, Stream);
  SaveStringToStream(FUser, Stream);
  SaveStringToStream(FPassword, Stream);
  SaveStringToStream(FRole, Stream);
  SaveStringToStream(FCharSet, Stream);
  SaveStringToStream(FAdditional, Stream);
end;

procedure TDBRegistrar.SetAdditional(const Value: string);
begin
  FAdditional := Trim(Value);
end;

procedure TDBRegistrar.SetAlias(const Value: string);
begin
  if FAlias <> Value then
  begin
    FAlias := Value;
    LoadFromRegister;
  end;
end;

procedure TDBRegistrar.SetCharSet(const Value: string);
begin
  FCharSet := Trim(Value);
end;

procedure TDBRegistrar.SetDBAlias(const Value: string);
begin
  FDBAlias := Trim(Value);
end;

procedure TDBRegistrar.SetDescription(const Value: string);
begin
  FDescription := Value;
end;

procedure TDBRegistrar.SetFileName(const Value: string);
begin
  FFileName := Trim(Value);
end;

procedure TDBRegistrar.SetOnLoad(const Value: TNotifyEvent);
begin
  FOnLoad := Value;
end;

procedure TDBRegistrar.SetPassword(const Value: string);
begin
  FPassword := Value;
end;

procedure TDBRegistrar.SetProtocol(const Value: string);
begin
  FProtocol := Trim(Value);
end;

procedure TDBRegistrar.SetRole(const Value: string);
begin
  FRole := Trim(Value);
end;

procedure TDBRegistrar.SetServerName(const Value: string);
begin
  FServerName := Trim(Value);
end;

procedure TDBRegistrar.SetUser(const Value: string);
begin
  FUser := Value;
end;

{ TDBAliasList }

procedure TDBAliasList.LoadFromRegister;
var
  R: TRegistry;
begin
  Clear;
  R := TRegistry.Create;
  try
    if R.OpenKey(RootPath + cAliasPath, True) then
    begin
      R.GetValueNames(Self);
    end else
      raise Exception.Create(CantLoadRegistryInfo);
  finally
    R.Free;
  end;
end;

{ TServerList }

procedure TServerList.LoadFromRegister;
var
  R: TRegistry;
  Stream: TMemoryStream;
  Info: TRegDataInfo;
begin
  Clear;
  R := TRegistry.Create;
  try
    if R.OpenKey(RootPath, True) then
    begin
      Stream := TMemoryStream.Create;
      try
        R.GetDataInfo(cServerPath, Info);
        Stream.Size := Info.DataSize;
        R.ReadBinaryData(cServerPath, Stream.Memory^, Info.DataSize);
        Clear;
        LoadFromStream(Stream);
      finally
        Stream.Free;
        R.CloseKey;
      end;
    end else
      raise Exception.Create(CantLoadRegistryInfo);
  finally
    R.Free;
  end;
end;

procedure TServerList.SaveToRegister;
var
  R: TRegistry;
  Stream: TMemoryStream;
begin
  R := TRegistry.Create;
  try
    if R.OpenKey(RootPath, True) then
    begin
      Stream := TMemoryStream.Create;
      try
        SaveToStream(Stream);
        R.WriteBinaryData(cServerPath, Stream.Memory^, Stream.Size);
      finally
        Stream.Free;
        R.CloseKey;
      end;
    end else
      raise Exception.Create(CantSaveRigistryInfo);
  finally
    R.Free;
  end;
end;

end.
