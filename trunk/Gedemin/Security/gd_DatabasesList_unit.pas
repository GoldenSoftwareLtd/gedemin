
unit gd_DatabasesList_unit;

interface

uses
  IniFiles, ContNrs;

type
  Tgd_DatabaseItem = class(TObject)
  private
    FAlias: String;
    FServer: String;
    FPort: Integer;
    FFileName: String;

  public
    constructor Create;

    property Alias: String read FAlias write FAlias;
    property Server: String read FServer write FServer;
    property Port: Integer read FPort write FPort;
    property FileName: String read FFileName write FFileName;
  end;

  Tgd_DatabasesList = class(TObject)
  private
    FDatabaseFolder: String;
    FIniFile: TIniFile;
    FList: TObjectList;

  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromIniFile;
    procedure WriteToIniFile;
    procedure ReadFromRegistry;
    procedure ScanDirectory;
  end;

implementation

uses
  Windows, Classes, Forms, SysUtils, JclFileUtils, gd_directories_const,
  gd_common_functions, Registry;

{ Tgd_DatabaseItem }

constructor Tgd_DatabaseItem.Create;
begin
  inherited;
  FPort := 3050;
end;

{ Tgd_DatabasesList }

constructor Tgd_DatabasesList.Create;
begin
  inherited;

  FDatabaseFolder := ExtractFilePath(Application.EXEName) + '..\..\Data\Database';
  if not DirectoryExists(FDatabaseFolder) then
    FDatabaseFolder := ExtractFilePath(Application.EXEName);
  FIniFile := TIniFile.Create(FDatabaseFolder + '\databases.ini');
  FList := TObjectList.Create(True);
end;

procedure Tgd_DatabasesList.ReadFromRegistry;
var
  SL: TStringList;
  Reg: TRegistry;
  Path: String;
  DI: Tgd_DatabaseItem;
  I: Integer;
begin
  SL := TStringList.Create;
  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := ClientRootRegistryKey;
    if Reg.OpenKey(ClientAccessRegistrySubKey, False) then
    begin
      Reg.GetKeyNames(SL);
      Path := Reg.CurrentPath;
      for I := 0 to SL.Count - 1 do
      begin
        if Reg.OpenKey(SL[I], False) then
        begin
          DI := Tgd_DatabaseItem.Create;
          DI.Alias := SL[I];
          DI.Server := ExtractServerName(Reg.ReadString('Database'));
          DI.FileName := Copy(Reg.ReadString('Database'), Length(DI.Server) + 1, 1024);
          Reg.CloseKey;
          Reg.OpenKey(Path, False);
        end;
      end;
    end;
  finally
    SL.Free;
    Reg.Free;
  end;
end;

procedure Tgd_DatabasesList.ReadFromIniFile;
begin

end;

procedure Tgd_DatabasesList.ScanDirectory;
var
  L: TStringList;
begin
  if FDatabaseFolder = '' then
    exit;

  L := TStringList.Create;
  try
    BuildFileList(FDatabaseFolder + '\*.fdb;' + FDatabaseFolder + '\*.gdb',
      faArchive, L);
  finally
    L.Free;
  end;
end;

procedure Tgd_DatabasesList.WriteToIniFile;
begin

end;

destructor Tgd_DatabasesList.Destroy;
begin
  FList.Free;
  FIniFile.Free;
  inherited;
end;

end.