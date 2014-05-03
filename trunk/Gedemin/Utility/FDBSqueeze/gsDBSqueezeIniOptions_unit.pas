unit gsDBSqueezeIniOptions_unit;

interface

uses
  Classes, SysUtils, IniFiles, Forms, Windows;

const
  iniDatabaseSection = 'DATABASE_CONNECTION';
  iniSqueezeSection = 'SQUEEZE_SETTINGS';
  iniMergeSection = 'CARD_MERGE_SETTINGS';

  {Section: DATABASE_CONNECTION}
  iniDatabase = 'Database';
  iniCharset = 'Charset';

  {Section: SQUEEZE_SETTINGS}
  iniClosingDate = 'ClosingDate';
  iniDoCalculateSaldo = 'DoCalculateSaldo';
  iniDoProcessDocTypes = 'DoProcessDocTypes';
  iniSelectedDocTypeKeys = 'SelectedDocTypeKeys';
  iniSelectedBranchRows = 'SelectedBranchRows';
  iniDoMergeCards = 'DoMergeCards';

  {Section: CARD_MERGE_SETTINGS}
  iniMergeDate = 'MergingDate';
  iniMergeDocTypesKeys = 'MergingDocTypeKeys';
  iniMergeBranchRows = 'MergingDocBranchRows';
  iniMergeCardFeatures = 'MergingCardFeatures';
  iniMergeFeaturesRows = 'MergingFeaturesRows';

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
    FDoMergeCards: Boolean;

    {Section: CARD_MERGE_SETTINGS}
    FMergingDate: TDateTime;
    FMergingDocTypeKeys: String;
    FMergingDocBranchRows: String;
    FMergingCardFeatures: String;
    FMergingFeaturesRows: String;
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
    property DoMergeCards: Boolean               read FDoMergeCards                write FDoMergeCards;

    {Section: CARD_MERGE_SETTINGS}
    property MergingDate: TDateTime             read FMergingDate                  write FMergingDate;
    property MergingDocTypeKeys: String         read FMergingDocTypeKeys           write FMergingDocTypeKeys;
    property MergingBranchRows: String          read FMergingDocBranchRows         write FMergingDocBranchRows;
    property MergingCardFeatures: String        read FMergingCardFeatures          write FMergingCardFeatures;
    property MergingFeaturesRows: string        read FMergingFeaturesRows          write FMergingFeaturesRows;
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
    FDoMergeCards := Ini.ReadBool(iniSqueezeSection, iniDoMergeCards, False);
    {Section: CARD_MERGE_SETTINGS}
    FMergingDate :=  Ini.ReadDate(iniMergeSection, iniMergeDate, Date);
    FMergingDocTypeKeys := Ini.ReadString(iniMergeSection, iniMergeDocTypesKeys, '');
    FMergingDocBranchRows := Ini.ReadString(iniMergeSection, iniMergeBranchRows, '');
    FMergingCardFeatures := Ini.ReadString(iniMergeSection, iniMergeCardFeatures, '');
    FMergingFeaturesRows := Ini.ReadString(iniMergeSection, iniMergeFeaturesRows, '');
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
    Ini.WriteBool(iniSqueezeSection, iniDoMergeCards, FDoMergeCards);
    {Section: CARD_MERGE_SETTINGS}
    Ini.WriteDate(iniMergeSection, iniMergeDate, FMergingDate);
    Ini.WriteString(iniMergeSection, iniMergeDocTypesKeys, FMergingDocTypeKeys);
    Ini.WriteString(iniMergeSection, iniMergeBranchRows, FMergingDocBranchRows);
    Ini.WriteString(iniMergeSection, iniMergeCardFeatures, FMergingCardFeatures);
    Ini.WriteString(iniMergeSection, iniMergeFeaturesRows, FMergingFeaturesRows);
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

