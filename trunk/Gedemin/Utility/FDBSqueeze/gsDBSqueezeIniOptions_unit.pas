unit gsDBSqueezeIniOptions_unit;

interface

uses
  Classes, SysUtils, IniFiles, Forms, Windows;

const
  iniSection = 'SQUEEZE_SETTINGS';

  {Section: SQUEEZE_SETTINGS}
  iniDoEnterOstatkyAccount = 'DoEnterOstatkyAccount';
  iniDoProcessDocTypes = 'DoProcessDocTypes';
  iniSelectedDocTypeKeys = 'SelectedDocTypeKeys';
  iniSelectedBranchRows = 'SelectedBranchRows';

type
  TgsIniOptions = class(TObject)
  private
    {Section: SQUEEZE_SETTINGS}
    FDoEnterOstatkyAccount: Boolean;
    FDoProcessDocTypes: Boolean;
    FSelectedDocTypeKeys: String;
    FSelectedBranchRows: String;
  public
    procedure LoadSettings(Ini: TIniFile);
    procedure SaveSettings(Ini: TIniFile);
    
    procedure LoadFromFile(const FileName: String);
    procedure SaveToFile(const FileName: String);

    {Section: SQUEEZE_SETTINGS}
    property DoEnterOstatkyAccount: Boolean       read FDoEnterOstatkyAccount       write FDoEnterOstatkyAccount;
    property DoProcessDocTypes: Boolean           read FDoProcessDocTypes           write FDoProcessDocTypes;
    property SelectedDocTypeKeys: String          read FSelectedDocTypeKeys         write FSelectedDocTypeKeys;
    property SelectedBranchRows: String           read FSelectedBranchRows          write FSelectedBranchRows;
  end;

var
  gsIniOptions: TgsIniOptions = nil;

implementation

procedure TgsIniOptions.LoadSettings(Ini: TIniFile);
begin
  if Ini <> nil then
  begin
    {Section: SQUEEZE_SETTINGS}
    FDoEnterOstatkyAccount := Ini.ReadBool(iniSection, iniDoEnterOstatkyAccount, False);
    FDoProcessDocTypes := Ini.ReadBool(iniSection, iniDoProcessDocTypes, False);
    FSelectedDocTypeKeys := Ini.ReadString(iniSection, iniSelectedDocTypeKeys, '');
    FSelectedBranchRows := Ini.ReadString(iniSection, iniSelectedBranchRows, '');
  end;
end;

procedure TgsIniOptions.SaveSettings(Ini: TIniFile);
begin
  if Ini <> nil then
  begin
    {Section: SQUEEZE_SETTINGS}
    Ini.WriteBool(iniSection, iniDoEnterOstatkyAccount, FDoEnterOstatkyAccount);
    Ini.WriteBool(iniSection, iniDoProcessDocTypes, FDoProcessDocTypes);
    Ini.WriteString(iniSection, iniSelectedDocTypeKeys, FSelectedDocTypeKeys);
    Ini.WriteString(iniSection, iniSelectedBranchRows, FSelectedBranchRows);
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

