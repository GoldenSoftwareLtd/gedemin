
unit gd_DatabasesList_unit;

interface

uses
  Classes, SysUtils, IniFiles, ContNrs, gd_directories_const;

const
  MaxUserCount = 4;

type
  Tgd_UserRec = record
    Login: String[60];
    Password: String[60];
  end;

  Tgd_DatabaseItem = class(TCollectionItem)
  private
    FName: String;
    FServer: String;
    FFileName: String;
    FUsers: array[1..MaxUserCount] of Tgd_UserRec;
    FUserCount: Integer;
    FDBParams: String;
    FIniFile: String;

    procedure SetName(const Value: String);

  protected
    procedure ReadFromIniFile(AnIniFile: TIniFile);
    procedure WriteToIniFile(AnIniFile: TIniFile);

  public
    constructor Create(Collection: TCollection); override;

    function EditInDialog: Boolean;

    property Name: String read FName write SetName;
    property Server: String read FServer write FServer;
    property FileName: String read FFileName write FFileName;
    property DBParams: String read FDBParams write FDBParams;
  end;

  Tgd_DatabasesList = class(TCollection)
  private
    FIniFileName: String;

  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromIniFile;
    procedure WriteToIniFile;
    procedure ReadFromRegistry;
    procedure ScanDirectory;
    function FindByName(const AName: String): Tgd_DatabaseItem;

    function ShowViewForm: Boolean;
  end;

  Egd_DatabasesList = class(Exception);

var
  gd_DatabasesList: Tgd_DatabasesList;

implementation

uses
  Windows, Forms, Controls, JclFileUtils, gd_common_functions, Registry,
  gd_DatabasesListView_unit, gd_DatabasesListDlg_unit;

{ Tgd_DatabaseItem }

constructor Tgd_DatabaseItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);
end;

function Tgd_DatabaseItem.EditInDialog: Boolean;
var
  Dlg: Tgd_DatabasesListDlg;
begin
  Dlg := Tgd_DatabasesListDlg.Create(nil);
  try
    Dlg.edName.Text := Name;
    Dlg.edServer.Text := Server;
    Dlg.edFileName.Text := FileName;
    Dlg.edDBParams.Text := DBParams;

    Result := Dlg.ShowModal = mrOk;

    if Result then
    begin
      Name := Dlg.edName.Text;
      Server := Dlg.edServer.Text;
      FileName := Dlg.edFileName.Text;
      DBParams := Dlg.edDBParams.Text;
    end;
  finally
    Dlg.Free;
  end;
end;

procedure Tgd_DatabaseItem.ReadFromIniFile(AnIniFile: TIniFile);
begin
  Assert(Assigned(AnIniFile));
  Server := AnIniFile.ReadString(Name, 'Server', '');
  FileName := AnIniFile.ReadString(Name, 'FileName', '');
  DBParams := AnIniFile.ReadString(Name, 'DBParams', '');
end;

procedure Tgd_DatabaseItem.SetName(const Value: String);
var
  V: String;
begin
  V := Trim(Value);

  if V = '' then
    raise Egd_DatabasesList.Create('Empty name');

  if V <> FName then
  begin
    if (Collection as Tgd_DatabasesList).FindByName(V) <> nil then
      raise Egd_DatabasesList.Create('Duplicate name');
    FName := V;
  end;  
end;

procedure Tgd_DatabaseItem.WriteToIniFile(AnIniFile: TIniFile);
begin
  Assert(Assigned(AnIniFile));
  Assert(Name > '');
  if AnIniFile.SectionExists(Name) then
    AnIniFile.EraseSection(Name);
  if Server > '' then
    AnIniFile.WriteString(Name, 'Server', Server);
  AnIniFile.WriteString(Name, 'FileName', FileName);
  if DBParams > '' then
    AnIniFile.WriteString(Name, 'DBParams', DBParams);
end;

{ Tgd_DatabasesList }

constructor Tgd_DatabasesList.Create;
begin
  inherited Create(Tgd_DatabaseItem);
  FIniFileName := ExtractFilePath(Application.EXEName) + 'databases.ini';
  ReadFromIniFile;
end;

procedure Tgd_DatabasesList.ReadFromRegistry;
var
  SL: TStringList;
  Reg: TRegistry;
  Path, FileName, Server: String;
  DI: Tgd_DatabaseItem;
  I, Port: Integer;
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
          if FindByName(SL[I]) = nil then
          begin
            DI := Self.Add as Tgd_DatabaseItem;
            DI.Name := SL[I];
            ParseDatabaseName(Reg.ReadString('Database'), Server, Port, FileName);
            DI.Server := Server;
            DI.FileName := FileName;
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
end;

procedure Tgd_DatabasesList.ReadFromIniFile;
var
  IniFile: TIniFile;
  Sections: TStringList;
  DI: Tgd_DatabaseItem;
  I: Integer;
begin
  if FileExists(FIniFileName) then
  begin
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
begin
  IniFile := TIniFile.Create(FIniFileName);
  try
    for I := 0 to Count - 1 do
      (Items[I] as Tgd_DatabaseItem).WriteToIniFile(IniFile);
  finally
    IniFile.Free;
  end;
end;

destructor Tgd_DatabasesList.Destroy;
begin
  WriteToIniFile;
  inherited;
end;

function Tgd_DatabasesList.ShowViewForm: Boolean;
begin
  with Tgd_DatabasesListView.Create(nil) do
  try
    Result := ShowModal = mrOk;
    if Result then
      WriteToIniFile
    else begin
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

initialization
  gd_DatabasesList := Tgd_DatabasesList.Create;

finalization
  FreeAndNil(gd_DatabasesList);
end.