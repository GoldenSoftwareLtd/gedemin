
unit gd_GlobalParams_unit;

interface

uses
  Classes, Windows, IniFiles;

type
  Tgd_GlobalParams = class(TObject)
  private
    FLocalAddDataDir: String;
    FNetworkDrive: Boolean;
    FCDROMDrive: Boolean;
    FSecondaryInstance: Boolean;
    FUpdateToken: String;
    FIniFileName: String;
    FIniFile: TIniFile;
    FNeedRestartForUpdate: Boolean;

    function GetAutoUpdate: Boolean;
    procedure SetAutoUpdate(const Value: Boolean);
    procedure ReadFromIniFile;
    function GetCanUpdate: Boolean;
    function GetNamespacePath: String;
    procedure SetNamespacePath(const Value: String);

  public
    constructor Create;
    destructor Destroy; override;

    function GetWebClientActive: Boolean;
    function GetWebClientRemoteServer: String;
    function GetWebClientTimeout: Integer;

    function GetWebServerActive: Boolean;
    function GetWebServerBindings: String;
    function GetWebServerUpdatePath: String;

    function GetExternalEditor(const ALang: String): String;

    property LocalAppDataDir: String read FLocalAddDataDir;
    property NetworkDrive: Boolean read FNetworkDrive;
    property CDROMDrive: Boolean read FCDROMDrive;
    property SecondaryInstance: Boolean read FSecondaryInstance write FSecondaryInstance;
    property UpdateToken: String read FUpdateToken;
    property AutoUpdate: Boolean read GetAutoUpdate write SetAutoUpdate;
    property IniFileName: String read FIniFileName;
    property CanUpdate: Boolean read GetCanUpdate;
    property NeedRestartForUpdate: Boolean read FNeedRestartForUpdate write FNeedRestartForUpdate;
    property NamespacePath: String read GetNamespacePath write SetNamespacePath;
  end;

var
  gd_GlobalParams: Tgd_GlobalParams;

implementation

uses
  Forms, SysUtils, FileCtrl, jclShell, gd_directories_const,
  gd_CmdLineParams_unit;

{ Tgd_GlobalParams }

constructor Tgd_GlobalParams.Create;
const
  CSIDL_LOCAL_APPDATA = $001c;
var
  DriveType: Integer;
begin
  inherited;
  FLocalAddDataDir := IncludeTrailingBackslash(
    GetSpecialFolderLocation(CSIDL_LOCAL_APPDATA)) + 'Gedemin';
  if not DirectoryExists(FLocalAddDataDir) then
    CreateDir(FLocalAddDataDir);
  DriveType := GetDriveType(PChar(
    IncludeTrailingBackslash(ExtractFileDrive(Application.ExeName))));
  FNetworkDrive := DriveType = DRIVE_REMOTE;
  FCDROMDrive := DriveType = DRIVE_CDROM;
  if FNetworkDrive or FCDROMDrive then
    FIniFileName := IncludeTrailingBackslash(FLocalAddDataDir)
  else
    FIniFileName := ExtractFilePath(Application.EXEName);
  FIniFileName := FIniFileName + 'gedemin.ini';
  FIniFile := TIniFile.Create(FIniFileName);
  ReadFromIniFile;
end;

destructor Tgd_GlobalParams.Destroy;
begin
  FIniFile.Free;
  inherited;
end;

function Tgd_GlobalParams.GetWebClientRemoteServer: String;
begin
  if gd_CmdLineParams.RemoteServer > '' then
    Result := gd_CmdLineParams.RemoteServer
  else
    Result := FIniFile.ReadString('WEB CLIENT', 'RemoteServer', '');
end;

function Tgd_GlobalParams.GetWebServerBindings: String;
begin
  Result := FIniFile.ReadString('WEB SERVER', 'Bindings', '');
end;

function Tgd_GlobalParams.GetWebServerActive: Boolean;
begin
  Result := FIniFile.ReadBool('WEB SERVER', 'Active', False)
    and (not gd_GlobalParams.SecondaryInstance)
    and (gd_CmdLineParams.LoadSettingFileName = '');
end;

procedure Tgd_GlobalParams.ReadFromIniFile;
begin
  FUpdateToken := FIniFile.ReadString('WEB CLIENT', 'Token', '');
end;

function Tgd_GlobalParams.GetWebServerUpdatePath: String;
begin
  Result := FIniFile.ReadString('WEB SERVER', 'UpdatePath', '');
end;

function Tgd_GlobalParams.GetWebClientTimeout: Integer;
begin
  Result := FIniFile.ReadInteger('WEB CLIENT', 'Timeout', 20000);
end;

function Tgd_GlobalParams.GetWebClientActive: Boolean;
begin
  Result := FIniFile.ReadBool('WEB CLIENT', 'Active', True)
    and (gd_CmdLineParams.LoadSettingFileName = '')
    and (not gd_GlobalParams.GetWebServerActive);
end;

function Tgd_GlobalParams.GetAutoUpdate: Boolean;
begin
  Result := FIniFile.ReadBool('WEB CLIENT', 'AutoUpdate', True);
end;

procedure Tgd_GlobalParams.SetAutoUpdate(const Value: Boolean);
begin
  FIniFile.WriteBool('WEB CLIENT', 'AutoUpdate', Value);
end;

function Tgd_GlobalParams.GetCanUpdate: Boolean;
begin
  Result := (not NetworkDrive)
    and (not CDROMDrive)
    and (not SecondaryInstance)
    and (not FNeedRestartForUpdate);
end;

function Tgd_GlobalParams.GetExternalEditor(const ALang: String): String;
begin
  Result := FIniFile.ReadString('EXTERNAL EDITOR', ALang, '');
end;

function Tgd_GlobalParams.GetNamespacePath: String;
begin
  Result := FIniFile.ReadString('NAMESPACE', 'Path', '');
end;

procedure Tgd_GlobalParams.SetNamespacePath(const Value: String);
begin
  FIniFile.WriteString('NAMESPACE', 'Path', Value);
end;

initialization
  gd_GlobalParams := Tgd_GlobalParams.Create;

finalization
  FreeAndNil(gd_GlobalParams);
end.
