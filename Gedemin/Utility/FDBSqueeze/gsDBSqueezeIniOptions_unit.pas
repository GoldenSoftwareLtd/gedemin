unit gsDBSqueezeIniOptions_unit;

interface

uses
  Classes, SysUtils, IniFiles, Forms, Windows;

const
  iniDatabaseSection = 'DATABASE_CONNECTION';
  iniSqueezeSection = 'SQUEEZE_SETTINGS';

  {Section: DATABASE_CONNECTION}
  iniDatabase = 'Database';
  iniCharset = 'Charset';
  
  {Section: SQUEEZE_SETTINGS}
  iniClosingDate = 'ClosingDate';
  iniDoCalculateSaldo = 'DoCalculateSaldo';
  iniDoProcessDocTypes = 'DoProcessDocTypes';
  iniSelectedDocTypeKeys = 'SelectedDocTypeKeys';
  iniSelectedBranchRows = 'SelectedBranchRows';

type
  TgsIniOptions = class(TObject)
  private
    {Section: DATABASE_CONNECTION}
    FDatabase: String;
    FCharset: String;

    {Section: SQUEEZE_SETTINGS}
    FClosingDate: TDateTime;   
    FDoProcessDocTypes: Boolean;
    FDoCalculateSaldo: Boolean;
    FSelectedDocTypeKeys: String;
    FSelectedBranchRows: String;
  public
    procedure LoadSettings(Ini: TIniFile);
    procedure SaveSettings(Ini: TIniFile);
    
    procedure LoadFromFile(const FileName: String);
    procedure SaveToFile(const FileName: String);

    {Section: DATABASE_CONNECTION}
    property Database: String                    read FDatabase                    write FDatabase;
    property Charset: String                     read FCharset                     write FCharset;

    {Section: SQUEEZE_SETTINGS}
    property ClosingDate: TDateTime              read FClosingDate                 write FClosingDate;
    property DoCalculateSaldo: Boolean           read FDoCalculateSaldo            write FDoCalculateSaldo;
    property DoProcessDocTypes: Boolean          read FDoProcessDocTypes           write FDoProcessDocTypes;
    property SelectedDocTypeKeys: String         read FSelectedDocTypeKeys         write FSelectedDocTypeKeys;
    property SelectedBranchRows: String          read FSelectedBranchRows          write FSelectedBranchRows;
  end;

var
  gsIniOptions: TgsIniOptions = nil;

implementation

procedure TgsIniOptions.LoadSettings(Ini: TIniFile);
begin
  if Ini <> nil then
  begin
    {Section: DATABASE_CONNECTION}
    FDatabase := Ini.ReadString(iniDatabaseSection, iniDatabase, '');
    FCharset := Ini.ReadString(iniDatabaseSection, iniCharset, '');
    {Section: SQUEEZE_SETTINGS}
    FClosingDate := Ini.ReadDate(iniSqueezeSection, iniClosingDate, Date);
    FDoProcessDocTypes := Ini.ReadBool(iniSqueezeSection, iniDoProcessDocTypes, False);
    FDoCalculateSaldo := Ini.ReadBool(iniSqueezeSection, iniDoCalculateSaldo, False);
    FSelectedDocTypeKeys := Ini.ReadString(iniSqueezeSection, iniSelectedDocTypeKeys, '');
    FSelectedBranchRows := Ini.ReadString(iniSqueezeSection, iniSelectedBranchRows, '');
  end;
end;

procedure TgsIniOptions.SaveSettings(Ini: TIniFile);
begin
  if Ini <> nil then
  begin
    {Section: DATABASE_CONNECTION}
    Ini.WriteString(iniDatabaseSection, iniDatabase, FDatabase);
    Ini.WriteString(iniDatabaseSection, iniCharset, FCharset);
    {Section: SQUEEZE_SETTINGS}
    Ini.WriteDate(iniSqueezeSection, iniClosingDate, FClosingDate);
    Ini.WriteBool(iniSqueezeSection, iniDoProcessDocTypes, FDoProcessDocTypes);
    Ini.WriteBool(iniSqueezeSection, iniDoCalculateSaldo, FDoCalculateSaldo);
    Ini.WriteString(iniSqueezeSection, iniSelectedDocTypeKeys, FSelectedDocTypeKeys);
    Ini.WriteString(iniSqueezeSection, iniSelectedBranchRows, FSelectedBranchRows);
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

