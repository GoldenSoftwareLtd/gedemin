
unit gd_GlobalParams_unit;

interface

uses
  Classes, Windows;

type
  Tgd_GlobalParams = class(TObject)
  private
    FLocalAddDataDir: String;
    FNetworkDrive: Boolean;
    FCDROMDrive: Boolean;
    FSecondaryInstance: Boolean;

  public
    constructor Create;

    property LocalAppDataDir: String read FLocalAddDataDir;
    property NetworkDrive: Boolean read FNetworkDrive;
    property CDROMDrive: Boolean read FCDROMDrive;
    property SecondaryInstance: Boolean read FSecondaryInstance write FSecondaryInstance;
  end;

var
  gd_GlobalParams: Tgd_GlobalParams;

implementation

uses
  Forms, SysUtils, FileCtrl, jclShell, gd_directories_const;

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
end;

initialization
  gd_GlobalParams := Tgd_GlobalParams.Create;

finalization
  FreeAndNil(gd_GlobalParams);
end.
