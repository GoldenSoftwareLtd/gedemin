
unit gd_DatabasesList_unit;

interface

uses
  Classes, SysUtils, IniFiles, ContNrs, gd_directories_const;

type
  Tgd_DIType = (ditINI, ditCmdLine, ditSilent);

  Tgd_DatabaseItem = class(TCollectionItem)
  private
    FName: String;
    FServer: String;
    FFileName: String;
    FUsers: TStringList;
    FSelected: Boolean;
    FRememberPassword: Boolean;
    FEnteredLogin: String;
    FEnteredPassword: String;
    FDIType: Tgd_DIType;

    procedure SetName(const Value: String);
    procedure SetSelected(const Value: Boolean);
    procedure SetRememberPassword(const Value: Boolean);

    function ConvertString(const S: String): String;
    function RestoreString(const S: String): String;
    function GetCryptoKey: String;
    function GetDatabaseName: String;
    function GetIsAdminLogin: Boolean;

  protected
    procedure ReadFromIniFile(AnIniFile: TIniFile);
    procedure WriteToIniFile(AnIniFile: TIniFile);

  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;
    function EditInDialog: Boolean;
    procedure AddUser(ALogin: String; APassword: String);
    procedure GetUsers(S: TStrings);
    function GetPassword(ALogin: String): String;

    property Name: String read FName write SetName;
    property Server: String read FServer write FServer;
    property FileName: String read FFileName write FFileName;
    property Selected: Boolean read FSelected write SetSelected;
    property RememberPassword: Boolean read FRememberPassword write SetRememberPassword;
    property EnteredLogin: String read FEnteredLogin write FEnteredLogin;
    property EnteredPassword: String read FEnteredPassword write FEnteredPassword;
    property DatabaseName: String read GetDatabaseName;
    property IsAdminLogin: Boolean read GetIsAdminLogin;
    property DIType: Tgd_DIType read FDIType write FDIType;
  end;

  Tgd_DatabasesList = class(TCollection)
  private
    FIniFileName: String;

    procedure ReadFromIniFile;
    procedure WriteToIniFile;
    procedure ReadFromCmdLine;

  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromRegistry(const CanClear: Boolean);
    procedure ScanDirectory;
    function FindByName(const AName: String): Tgd_DatabaseItem;
    function FindSelected: Tgd_DatabaseItem;

    function ShowViewForm(const ChangeSelected: Boolean): Boolean;
    function LoginDlg(out WithoutConnection, SingleUserMode: Boolean;
      out DI: Tgd_DatabaseItem): Boolean;

    property IniFileName: String read FIniFileName;  
  end;

  Egd_DatabasesList = class(Exception);

var
  gd_DatabasesList: Tgd_DatabasesList;

implementation

uses
  Windows, Wcrypt2, Forms, Controls, JclFileUtils, gd_common_functions,
  Registry, gd_DatabasesListView_unit, gd_DatabasesListDlg_unit,
  gd_security_dlgLogIn2, gd_CmdLineParams_unit, gd_GlobalParams_unit;

const
  MaxUserCount = 10;

{ Tgd_DatabaseItem }

procedure Tgd_DatabaseItem.AddUser(ALogin, APassword: String);
var
  I: Integer;
begin
  ALogin := ConvertString(ALogin);
  APassword := ConvertString(APassword);
  I := FUsers.IndexOfName(ALogin);
  if I > -1 then
    FUsers.Delete(I);
  FUsers.Insert(0, ALogin + '=' + APassword);
  while FUsers.Count > MaxUserCount do
    FUsers.Delete(FUsers.Count - 1);
end;

procedure Tgd_DatabaseItem.Assign(Source: TPersistent);
begin
  FServer := (Source as Tgd_DatabaseItem).Server;
  FFileName := (Source as Tgd_DatabaseItem).FileName;
end;

function Tgd_DatabaseItem.ConvertString(const S: String): String;
begin
  Result := StringReplace(S, '=', '&eq;', [rfReplaceAll]);
end;

constructor Tgd_DatabaseItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FUsers := TStringList.Create;
  FDIType := ditINI;
end;

destructor Tgd_DatabaseItem.Destroy;
begin
  FUsers.Free;
  inherited;
end;

function Tgd_DatabaseItem.EditInDialog: Boolean;
var
  Dlg: Tgd_DatabasesListDlg;
begin
  Dlg := Tgd_DatabasesListDlg.Create(nil);
  try
    Dlg.DI := Self;
    Result := Dlg.ShowModal = mrOk;
  finally
    Dlg.Free;
  end;
end;

function Tgd_DatabaseItem.GetCryptoKey: String;
var
  CompName: array[0..MAX_COMPUTERNAME_LENGTH] of Char;
  CompNameSize: DWORD;
begin
  CompNameSize := MAX_COMPUTERNAME_LENGTH + 1;
  if not GetComputerName(CompName, CompNameSize) then
    CompName[0] := #0;
  Result := CompName + Name + Server;
end;

function Tgd_DatabaseItem.GetDatabaseName: String;
begin
  if Server > '' then
    Result := Server + ':' + FileName
  else
    Result := FileName;
end;

function Tgd_DatabaseItem.GetIsAdminLogin: Boolean;
begin
  Result := AnsiCompareText(FEnteredLogin, 'Administrator') = 0;
end;

function Tgd_DatabaseItem.GetPassword(ALogin: String): String;
begin
  ALogin := ConvertString(ALogin);
  if FUsers.IndexOfName(ALogin) > -1 then
    Result := RestoreString(FUsers.Values[ALogin])
  else
    Result := '';
end;

procedure Tgd_DatabaseItem.GetUsers(S: TStrings);
var
  I: Integer;
begin
  S.Clear;
  for I := 0 to FUsers.Count - 1 do
    S.Add(RestoreString(FUsers.Names[I]));
end;

procedure Tgd_DatabaseItem.ReadFromIniFile(AnIniFile: TIniFile);
var
  S: String;
  hProv: HCRYPTPROV;
  Key: HCRYPTKEY;
  Hash: HCRYPTHASH;
  CryptoKey, PassHex: String;
  Len, I, P: Integer;
begin
  Assert(FDIType = ditINI);
  Assert(Assigned(AnIniFile));
  Server := AnIniFile.ReadString(Name, 'Server', '');
  FileName := AnIniFile.ReadString(Name, 'FileName', '');
  Selected := AnIniFile.ReadBool(Name, 'Selected', False);
  RememberPassword := AnIniFile.ReadBool(Name, 'RememberPassword', False);

  FUsers.Clear;
  PassHex :=
    AnIniFile.ReadString(Name, 'Data0', '') +
    AnIniFile.ReadString(Name, 'Data1', '') +
    AnIniFile.ReadString(Name, 'Data2', '') +
    AnIniFile.ReadString(Name, 'Data3', '');
  Len := Length(PassHex) div 2;
  SetLength(S, Len);
  I := 1; P := 1;
  while P <= Len do
  begin
    try
      S[P] := HexToAnsiChar(PassHex, I);
    except
      S := '';
      break;
    end;
    Inc(I, 2);
    Inc(P);
  end;

  if S > '' then
  begin
    CryptAcquireContext(@hProv, nil, nil, PROV_RSA_FULL, CRYPT_VERIFYCONTEXT);
    try
      CryptCreateHash(hProv, CALG_SHA, 0, 0, @Hash);
      try
        CryptoKey := GetCryptoKey;
        CryptHashData(Hash, @CryptoKey[1], Length(CryptoKey), 0);
        CryptDeriveKey(hProv, CALG_RC4, Hash, 0, @Key);
        CryptDecrypt(Key, 0, True, 0, @S[1], @Len);
      finally
        CryptDestroyHash(Hash);
      end;
    finally
      CryptReleaseContext(hProv, 0);
    end;

    if Copy(S, 1, 4) = '0001' then
    begin
      if Pos(#00, S) > 0 then
        SetLength(S, Pos(#00, S) - 1);
      FUsers.CommaText := Copy(S, 5, 1024);
    end;
  end;
end;

function Tgd_DatabaseItem.RestoreString(const S: String): String;
begin
  Result := StringReplace(S, '&eq;', '=', [rfReplaceAll]);
end;

procedure Tgd_DatabaseItem.SetName(const Value: String);
var
  V: String;
  DI: Tgd_DatabaseItem;
begin
  V := Trim(Value);

  if V = '' then
    raise Egd_DatabasesList.Create('Empty name');

  if V <> FName then
  begin
    DI := (Collection as Tgd_DatabasesList).FindByName(V);
    if (DI <> nil) and (DI <> Self) then
      raise Egd_DatabasesList.Create('Duplicate name');
    FName := V;
  end;  
end;

procedure Tgd_DatabaseItem.SetRememberPassword(const Value: Boolean);
var
  I: Integer;
begin
  FRememberPassword := Value;
  if not FRememberPassword then
    for I := 0 to FUsers.Count - 1 do
      FUsers[I] := FUsers.Names[I] + '=';
end;

procedure Tgd_DatabaseItem.SetSelected(const Value: Boolean);
var
  I: Integer;
begin
  FSelected := Value;
  if FSelected then
    for I := 0 to Collection.Count - 1 do
      if Collection.Items[I] <> Self then
        (Collection.Items[I] as Tgd_DatabaseItem).Selected := False;
end;

procedure Tgd_DatabaseItem.WriteToIniFile(AnIniFile: TIniFile);
const
  HexInARow    = 64;
  MaxDataBlock = HexINARow * 4;
var
  S: String;
  hProv: HCRYPTPROV;
  Key: HCRYPTKEY;
  Hash: HCRYPTHASH;
  CryptoKey, PassHex: String;
  Len, I: Integer;
begin
  if FDIType <> ditINI then
    exit;

  Assert(Assigned(AnIniFile));
  Assert(Name > '');
  if AnIniFile.SectionExists(Name) then
    AnIniFile.EraseSection(Name);
  AnIniFile.WriteString(Name, 'Server', Server);
  AnIniFile.WriteString(Name, 'FileName', FileName);
  AnIniFile.WriteBool(Name, 'Selected', Selected);
  AnIniFile.WriteBool(Name, 'RememberPassword', RememberPassword);

  if FUsers.Count > 0 then
  begin
    S := '0001' + FUsers.CommaText;
    if Length(S) > MaxDataBlock then
    begin
      Len := MaxDataBlock;
      SetLength(S, Len)
    end else
    begin
      Len := (Length(S) div HexInARow + 1) * HexInARow;
      S := S + StringOfChar(#00, Len - Length(S));
    end;

    CryptAcquireContext(@hProv, nil, nil, PROV_RSA_FULL, CRYPT_VERIFYCONTEXT);
    try
      CryptCreateHash(hProv, CALG_SHA, 0, 0, @Hash);
      try
        CryptoKey := GetCryptoKey;
        CryptHashData(Hash, @CryptoKey[1], Length(CryptoKey), 0);
        CryptDeriveKey(hProv, CALG_RC4, Hash, 0, @Key);
        CryptEncrypt(Key, 0, True, 0, @S[1], @Len, Len);
      finally
        CryptDestroyHash(Hash);
      end;
    finally
      CryptReleaseContext(hProv, 0);
    end;

    PassHex := '';
    I := 1;
    while I <= Len do
    begin
      PassHex := PassHex + AnsiCharToHex(S[I]);
      if (I mod HexInARow = 0) or (I = Len) then
      begin
        if PassHex > '' then
          AnIniFile.WriteString(Name, 'Data' + IntToStr(I div HexInARow - 1), PassHex);
        PassHex := '';
      end;
      Inc(I);
    end;
  end;
end;

{ Tgd_DatabasesList }

constructor Tgd_DatabasesList.Create;
var
  LocalIniFileName: String;
begin
  inherited Create(Tgd_DatabaseItem);

  FIniFileName := ExtractFilePath(Application.EXEName) + 'databases.ini';

  if
    (
      gd_GlobalParams.NetworkDrive
      or
      gd_GlobalParams.CDROMDrive
      or
      gd_GlobalParams.TerminalSession)
    and
    (
      gd_GlobalParams.LocalAppDataDir > ''
    ) then
  begin
    LocalIniFileName := IncludeTrailingBackslash(gd_GlobalParams.LocalAppDataDir) +
      'databases.ini';

    if not FileExists(LocalIniFileName) then
      CopyFile(PChar(FIniFileName), PChar(LocalIniFileName), True);

    FIniFileName := LocalIniFileName;
  end;

  ReadFromIniFile;
  ReadFromCmdLine;
end;

procedure Tgd_DatabasesList.ReadFromRegistry(const CanClear: Boolean);

  procedure ClearRegistry;

    procedure DeleteSubKeys(Reg: TRegistry);
    var
      SL: TStringList;
      I: Integer;
    begin
      SL := TStringList.Create;
      try
        if Reg.OpenKey(ClientAccessRegistrySubKey, False) then
        begin
          Reg.GetKeyNames(SL);
          for I := 0 to SL.Count - 1 do
            Reg.DeleteKey(SL[I]);
          Reg.CloseKey;
        end;

        Reg.DeleteKey(ClientAccessRegistrySubKey);
      finally
        SL.Free;
      end;
    end;

  var
    Reg: TRegistry;
  begin
    try
      Reg := TRegistry.Create(KEY_ALL_ACCESS);
      try
        Reg.RootKey := HKEY_LOCAL_MACHINE;
        if Reg.OpenKey(ClientRootRegistrySubKey, False) then
        begin
          Reg.DeleteValue('ServerName');
          Reg.CloseKey;
        end;
        DeleteSubKeys(Reg);

        Reg.RootKey := HKEY_CURRENT_USER;
        DeleteSubKeys(Reg);
      finally
        Reg.Free;
      end;
    except
      MessageBox(0,
        'Недостаточно прав для удаления информации из системного реестра.',
        'Внимание',
        MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
    end;
  end;

var
  SL: TStringList;
  Reg: TRegistry;
  Path, FileName, Server, DefDB: String;
  DI: Tgd_DatabaseItem;
  I, Port: Integer;
begin
  SL := TStringList.Create;
  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := ClientRootRegistryKey;

    if Reg.OpenKey(ClientRootRegistrySubKey, False) then
    begin
      DefDB := Reg.ReadString('ServerName');
      Reg.CloseKey;
    end else
      DefDB := '';

    if Reg.OpenKey(ClientAccessRegistrySubKey, False) then
    begin
      Reg.GetKeyNames(SL);
      Path := Reg.CurrentPath;
      for I := 0 to SL.Count - 1 do
      begin
        if Reg.OpenKey(SL[I], False) then
        begin
          if FindByName(SL[I]) = nil then
          begin
            DI := Self.Add as Tgd_DatabaseItem;
            DI.Name := SL[I];
            ParseDatabaseName(Reg.ReadString('Database'), Server, Port, FileName);
            DI.Server := Server;
            DI.FileName := FileName;
            DI.Selected := (DefDB > '') and (Reg.ReadString('Database') = DefDB);
          end;
          Reg.CloseKey;
          Reg.OpenKey(Path, False);
        end;
      end;
    end;
  finally
    SL.Free;
    Reg.Free;
  end;

  if CanClear then
  begin
    WriteToIniFile;
    ClearRegistry;
  end;
end;

procedure Tgd_DatabasesList.ReadFromIniFile;
var
  IniFile: TIniFile;
  Sections: TStringList;
  DI: Tgd_DatabaseItem;
  I: Integer;
begin
  if not FileExists(FIniFileName) then
    ReadFromRegistry(True)
  else begin
    IniFile := TIniFile.Create(FIniFileName);
    try
      Sections := TStringList.Create;
      try
        IniFile.ReadSections(Sections);
        for I := 0 to Sections.Count - 1 do
        begin
          DI := FindByName(Sections[I]);
          if DI = nil then
          begin
            DI := Self.Add as Tgd_DatabaseItem;
            DI.Name := Sections[I];
          end;
          DI.ReadFromIniFile(IniFile);
        end;

        if (Count > 0) and (FindSelected = nil) then
          (Items[0] as Tgd_DatabaseItem).Selected := True;
      finally
        Sections.Free;
      end;
    finally
      IniFile.Free;
    end;
  end;
end;

procedure Tgd_DatabasesList.ScanDirectory;
begin
end;

procedure Tgd_DatabasesList.WriteToIniFile;
var
  IniFile: TIniFile;
  I: Integer;
  Sections: TStringList;
begin
  IniFile := TIniFile.Create(FIniFileName);
  try
    Sections := TStringList.Create;
    try
      IniFile.ReadSections(Sections);
      for I := 0 to Sections.Count - 1 do
        IniFile.EraseSection(Sections[I]);
    finally
      Sections.Free;
    end;

    for I := 0 to Count - 1 do
    try
      (Items[I] as Tgd_DatabaseItem).WriteToIniFile(IniFile);
    except
      MessageBox(0,
        PChar('Невозможно записать данные в файл ' + FIniFileName + '.'#13#10#13#10 +
        'Возможно, недостаточно прав доступа или установлен атрибут "только для чтения".'),
        'Ошибка',
        MB_ICONHAND or MB_OK or MB_TASKMODAL);
      break;
    end;
  finally
    IniFile.Free;
  end;
end;

destructor Tgd_DatabasesList.Destroy;
begin
  inherited;
end;

function Tgd_DatabasesList.ShowViewForm(const ChangeSelected: Boolean): Boolean;
begin
  with Tgd_DatabasesListView.Create(nil) do
  try
    Result := ShowModal = mrOk;
    if Result then
    begin
      if ChangeSelected and (Chosen <> nil) then
        Chosen.Selected := True;
      WriteToIniFile;
    end else begin
      Clear;
      ReadFromIniFile;
    end;
  finally
    Free;
  end;
end;

function Tgd_DatabasesList.FindByName(const AName: String): Tgd_DatabaseItem;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if AnsiCompareText((Items[I] as Tgd_DatabaseItem).Name, Trim(AName)) = 0 then
    begin
      Result := Items[I] as Tgd_DatabaseItem;
      break;
    end;
end;

function Tgd_DatabasesList.FindSelected: Tgd_DatabaseItem;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if (Items[I] as Tgd_DatabaseItem).Selected then
    begin
      Result := Items[I] as Tgd_DatabaseItem;
      break;
    end;
  if (Result = nil) and (Count > 0) then
  begin
    Result := Items[0] as Tgd_DatabaseItem;
    Result.Selected := True;
  end;
end;

function Tgd_DatabasesList.LoginDlg(out WithoutConnection, SingleUserMode: Boolean;
  out DI: Tgd_DatabaseItem): Boolean;
var
  Path: String;
  SL: TStringList;
  I: Integer;
begin
  DI := FindSelected;

  if DI = nil then
  begin
    Path := ExtractFilePath(Application.ExeName) + 'Database';
    if DirectoryExists(Path) then
    begin
      SL := TStringList.Create;
      try
        if BuildFileList(IncludeTrailingBackslash(Path) + '*.fdb', faAnyFile, SL) then
        begin
          for I := 0 to SL.Count - 1 do
          begin
            DI := Add as Tgd_DatabaseItem;
            DI.FileName := 'Database\' + SL[I];
            if AnsiCompareText(SL[I], 'devel.fdb') = 0 then
              DI.Name := 'Разработчик'
            else if AnsiCompareText(SL[I], 'plat.fdb') = 0 then
              DI.Name := 'Платежные документы'
            else if AnsiCompareText(SL[I], 'business.fdb') = 0 then
              DI.Name := 'Комплексная автоматизация'
            else if AnsiCompareText(SL[I], 'ip.fdb') = 0 then
              DI.Name := 'Индивидуальный предприниматель'
            else
              DI.Name := DI.FileName;
            DI.Selected := True;  
          end;
        end;
      finally
        SL.Free;
      end;
    end;
  end;

  if (DI = nil) and ShowViewForm(True) then
    DI := FindSelected;

  if DI = nil then
    Result := False
  else begin
    with TdlgSecLogin2.Create(nil) do
    try
      Result := ShowModal = mrOk;

      if Result then
      begin
        WriteToINIFile;
        WithoutConnection := chbxWithoutConnection.Checked;
        SingleUserMode := actSingleUser.Enabled and actSingleUser.Checked;
        DI := FindSelected;
      end;
    finally
      Free;
    end;
  end;  
end;

procedure Tgd_DatabasesList.ReadFromCmdLine;
var
  Server, FileName: String;
  Port: Integer;
  DI: Tgd_DatabaseItem;
begin
  ParseDatabaseName(gd_CmdLineParams.ServerName, Server, Port, FileName);

  if FileName > '' then
  begin
    while FindByName(FileName) <> nil do
      FileName := FileName + '_';
    DI := Self.Add as Tgd_DatabaseItem;
    DI.Name := FileName;
    DI.Server := Server;
    DI.FileName := FileName;
    DI.FEnteredLogin := gd_CmdLineParams.UserName;
    DI.FEnteredPassword := gd_CmdLineParams.UserPassword;
    DI.DIType := ditCmdLine;
    DI.Selected := True;
  end;
end;

initialization
  gd_DatabasesList := Tgd_DatabasesList.Create;

finalization
  FreeAndNil(gd_DatabasesList);
end.