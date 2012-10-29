
unit gd_DatabasesList_unit;

interface

uses
  Classes, IniFiles, ContNrs, gd_directories_const;

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
    FPort: Integer;
    FFileName: String;
    FUsers: array[1..MaxUserCount] of Tgd_UserRec;
    FUserCount: Integer;
    FDBParams: String;
    FIniFile: String;

  protected
    procedure ReadFromIniFile(AnIniFile: TIniFile; const AnIndex: Integer);
    procedure WriteToIniFile(AnIniFile: TIniFile);

  public
    constructor Create(Collection: TCollection); override;

    function EditInDialog: Boolean;

    property Name: String read FName write FName;
    property Server: String read FServer write FServer;
    property Port: Integer read FPort write FPort;
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

    function ShowViewForm: Boolean;
  end;

var
  gd_DatabasesList: Tgd_DatabasesList;

implementation

uses
  Windows, Forms, Controls, SysUtils, JclFileUtils, gd_common_functions, Registry,
  gd_DatabasesListView_unit, gd_DatabasesListDlg_unit;

{ Tgd_DatabaseItem }

constructor Tgd_DatabaseItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);
end;

function Tgd_DatabaseItem.EditInDialog: Boolean;
var
  P: Integer;
  Dlg: Tgd_DatabasesListDlg;
begin
  Dlg := Tgd_DatabasesListDlg.Create(nil);
  try
    Dlg.edName.Text := Name;
    Dlg.edServer.Text := Server;
    if Port > 0 then
      Dlg.edPort.Text := IntToStr(Port)
    else
      Dlg.edPort.Text := '';
    Dlg.edFileName.Text := FileName;
    Dlg.edDBParams.Text := DBParams;

    Result := Dlg.ShowModal = mrOk;

    if Result then
    begin
      Name := Dlg.edName.Text;
      Server := Dlg.edServer.Text;
      P := StrToIntDef(Dlg.edPort.Text, 0);
      if (P > 0) and (P < 65536) then
        Port := P;
      FileName := Dlg.edFileName.Text;
      DBParams := Dlg.edDBParams.Text;
    end;
  finally
    Dlg.Free;
  end;
end;

procedure Tgd_DatabaseItem.ReadFromIniFile(AnIniFile: TIniFile;
  const AnIndex: Integer);
begin

end;

procedure Tgd_DatabaseItem.WriteToIniFile(AnIniFile: TIniFile);
begin
  if Server > '' then
    AnIniFile.WriteString(Name, 'Server', Server);
  if Port > 0 then
    AnIniFile.WriteInteger(Name, 'Port', Port);
  AnIniFile.WriteString(Name, 'FileName', FileName);
  if DBParams > '' then
    AnIniFile.WriteString(Name, 'DBParams', DBParams);
end;

{ Tgd_DatabasesList }

constructor Tgd_DatabasesList.Create;
begin
  inherited Create(Tgd_DatabaseItem);
  FIniFileName := ExtractFilePath(Application.EXEName) + 'databases.ini';
end;

procedure Tgd_DatabasesList.ReadFromRegistry;
var
  SL: TStringList;
  Reg: TRegistry;
  Path, S, DB: String;
  DI: Tgd_DatabaseItem;
  I, P: Integer;
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
          DI := Self.Add as Tgd_DatabaseItem;
          DI.Name := SL[I];
          DB := Reg.ReadString('Database');
          S := ExtractServerName(DB);
          P := Pos('/', S);
          if P = 0 then
          begin
            DI.Server := S;
            DI.Port := 0;
          end else
          begin
            DI.Server := Copy(S, 1, P - 1);
            DI.Port := StrToIntDef(Copy(S, P + 1, 5), 0);
          end;
          DI.FileName := Copy(DB, Length(S) + 1, 1024);
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
  IniFileName: String;
  Sections: TStringList;
  DI: Tgd_DatabaseItem;
  I: Integer;
begin
  IniFileName := ExtractFilePath(Application.EXEName) + 'databases.ini';

  if FileExists(IniFileName) then
  begin
    IniFile := TIniFile.Create(IniFileName);
    try
      Sections := TStringList.Create;
      try
        IniFile.ReadSections(Sections);
        for I := 0 to Sections.Count - 1 do
        begin
          DI := Self.Add as Tgd_DatabaseItem;
          DI.Name := IniFile.ReadString(Sections[I], 'Name', '');
          DI.Server := IniFile.ReadString(Sections[I], 'Server', '');
          DI.Port := IniFile.ReadInteger(Sections[I], 'Port', 0);
          DI.FileName := IniFile.ReadString(Sections[I], 'FileName', '');
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
  SL: TStringList;
  I: Integer;
begin
  IniFile := TIniFile.Create(FIniFileName);
  SL := TStringList.Create;
  try
    IniFile.ReadSections(SL);
    for I := 0 to SL.Count - 1 do
      IniFile.EraseSection(SL[I]);
    for I := 0 to Count - 1 do
      (Items[I] as Tgd_DatabaseItem).WriteToIniFile(IniFile);  
  finally
    SL.Free;
    IniFile.Free;
  end;
end;

destructor Tgd_DatabasesList.Destroy;
begin
  inherited;
end;

function Tgd_DatabasesList.ShowViewForm: Boolean;
begin
  with Tgd_DatabasesListView.Create(nil) do
  try
    Result := ShowModal = mrOk;
    if Result then
      WriteToIniFile;
  finally
    Free;
  end;
end;

initialization
  gd_DatabasesList := Tgd_DatabasesList.Create;

finalization
  FreeAndNil(gd_DatabasesList);
end.