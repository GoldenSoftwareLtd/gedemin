unit gsDBSqueezeIniOptions_unit;

interface

uses
  Classes, SysUtils, IniFiles, Forms, Windows;

const
  iniSection = 'SQUEEZE_SETTINGS';

  {Section: SQUEEZE_SETTINGS}
  iniDoCalculateOnlyCompanySaldo = 'DoCalculateOnlyCompanySaldo';
  iniSelectedCompanyName = 'SelectedCompanyName';
  iniSelectedCompanyKey = 'SelectedCompanyKey';
  iniDoEnterOstatkyAccount = 'DoEnterOstatkyAccount';
  iniDoProcessDocTypes = 'DoProcessDocTypes';
  iniSelectedDocTypeKeys = 'SelectedDocTypeKeys';

type
  TgsIniOptions = class(TObject)
  private
    {Section: SQUEEZE_SETTINGS}
    FDoCalculateOnlyCompanySaldo: Boolean;
    FSelectedCompanyName: String;
    FSelectedCompanyKey: Integer;
    FDoEnterOstatkyAccount: Boolean;
    FDoProcessDocTypes: Boolean;
    FSelectedDocTypeKeys: String;
  public
    procedure LoadSettings(Ini: TIniFile);
    procedure SaveSettings(Ini: TIniFile);
    
    procedure LoadFromFile(const FileName: String);
    procedure SaveToFile(const FileName: String);

    {Section: SQUEEZE_SETTINGS}
    property DoCalculateOnlyCompanySaldo: Boolean read FDoCalculateOnlyCompanySaldo write FDoCalculateOnlyCompanySaldo;
    property SelectedCompanyName: String          read FSelectedCompanyName         write FSelectedCompanyName;
    property SelectedCompanyKey: Integer          read FSelectedCompanyKey          write FSelectedCompanyKey;
    property DoEnterOstatkyAccount: Boolean       read FDoEnterOstatkyAccount       write FDoEnterOstatkyAccount;
    property DoProcessDocTypes: Boolean           read FDoProcessDocTypes           write FDoProcessDocTypes;
    property SelectedDocTypeKeys: String          read FSelectedDocTypeKeys         write FSelectedDocTypeKeys;
  end;

var
  gsIniOptions: TgsIniOptions = nil;

implementation

procedure TgsIniOptions.LoadSettings(Ini: TIniFile);
begin
  if Ini <> nil then
  begin
    {Section: SQUEEZE_SETTINGS}
    FDoCalculateOnlyCompanySaldo := Ini.ReadBool(iniSection, iniDoCalculateOnlyCompanySaldo, False);
    FSelectedCompanyName := Ini.ReadString(iniSection, iniSelectedCompanyName, '');
    FSelectedCompanyKey := Ini.ReadInteger(iniSection, iniSelectedCompanyKey, 0);
    FDoEnterOstatkyAccount := Ini.ReadBool(iniSection, iniDoEnterOstatkyAccount, False);
    FDoProcessDocTypes := Ini.ReadBool(iniSection, iniDoProcessDocTypes, False);
    FSelectedDocTypeKeys := Ini.ReadString(iniSection, iniSelectedDocTypeKeys, '');
  end;
end;

procedure TgsIniOptions.SaveSettings(Ini: TIniFile);
begin
  if Ini <> nil then
  begin
    {Section: SQUEEZE_SETTINGS}
    Ini.WriteBool(iniSection, iniDoCalculateOnlyCompanySaldo, FDoCalculateOnlyCompanySaldo);
    Ini.WriteString(iniSection, iniSelectedCompanyName, FSelectedCompanyName);
    Ini.WriteInteger(iniSection, iniSelectedCompanyKey, FSelectedCompanyKey);
    Ini.WriteBool(iniSection, iniDoEnterOstatkyAccount, FDoEnterOstatkyAccount);
    Ini.WriteBool(iniSection, iniDoProcessDocTypes, FDoProcessDocTypes);
    Ini.WriteString(iniSection, iniSelectedDocTypeKeys, FSelectedDocTypeKeys);
  end;
end;

procedure TgsIniOptions.LoadFromFile(const FileName: String);
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(FileName);
  try
    LoadSettings(Ini);
  finally
    Ini.Free;
  end;
end;

procedure TgsIniOptions.SaveToFile(const FileName: String);
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(FileName);
  try
    SaveSettings(Ini);
  finally
    Ini.Free;
  end;
end;

initialization
  gsIniOptions := TgsIniOptions.Create;

finalization
  gsIniOptions.Free;

end.

