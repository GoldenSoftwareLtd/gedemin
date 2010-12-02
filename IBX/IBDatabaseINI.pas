{*************************************************************}
{                                                             }
{       Borland Delphi Visual Component Library               }
{       InterBase Express core components                     }
{                                                             }
{       Copyright (c) 2001 Jeff Overcash                      }
{                                                             }
{*************************************************************}

unit IBDatabaseINI;

interface

uses
  SysUtils, Windows, Classes, IBDatabase;

const
  PathSeparator = '\'; {do not localize}
  NL = #13#10;   {do not localize}
  SWrapLine = '<br>' + NL;       {do not localize}

type

  TIniFilePathOpt = (ipoPathNone, ipoPathToServer, ipoPathRelative);

  TIBDatabaseINI = class(TComponent)
  private
    FDatabaseName: String;
    FDatabase: TIBDatabase;
    FPassword: String;
    FUsername: String;
    FFileName: String;
    FSQLRole: String;
    FAppPath: TIniFilePathOpt;
    FSection: String;
    FCharacterSet: String;
    procedure SetDatabaseName(const Value: String);
    procedure SetDatabase(const Value: TIBDatabase);
    procedure SetFileName(const Value: String);
    procedure SetPassword(const Value: String);
    procedure SetUsername(const Value: String);
    { Private declarations }
    function GetParam(Name: string): string;
    procedure AssignParam(Name, Value: string);
    procedure DeleteParam(Name: string);
    procedure SetSQLRole(const Value: String);
    procedure SetSection(const Value: String);
    procedure SetCharacterSet(const Value: String);
  protected
    { Protected declarations }
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    { Public declarations }
    constructor Create(AOwner : Tcomponent); override;
    procedure SaveToINI;
    procedure ReadFromINI;
    procedure WriteToDatabase(ADatabase : TIBDatabase);
    procedure ReadFromDatabase;
    function IniFileName : string;
  published
    { Published declarations }
    property Database : TIBDatabase read FDatabase write SetDatabase;
    property DatabaseName : String read FDatabaseName write SetDatabaseName;
    property Username : String read FUsername write SetUsername;
    property Password : String read FPassword write SetPassword;
    property SQLRole : String read FSQLRole write SetSQLRole;
    property CharacterSet : String read FCharacterSet write SetCharacterSet;
    property FileName : String read FFileName write SetFileName;
    property UseAppPath : TIniFilePathOpt read FAppPath write FAppPath;
    property Section : String read FSection write SetSection;
  end;

  function SlashPath( sPath : string ) : string;
  function LocalServerPath( sFile : string = '') : string;

implementation

uses inifiles;

const
  SIniDatabase = 'database';
  SIniUserName = 'user_name';
  SIniPassword = 'password';
  SIniSQLRole = 'sql_role';
  SIniCharacterSet = 'lc_ctype';

function LocalServerPath(sFile: string): string;
var
  FN: array[0..MAX_PATH- 1] of char;
  sPath : shortstring;
begin
  SetString(sPath, FN, GetModuleFileName(hInstance, FN, SizeOf(FN)));
  Result := ExtractFilePath( sPath ) + LowerCase( ExtractFileName( sFile ) );
end;

function SlashPath( sPath : string ) : string;
begin
  if ( sPath <> '' ) and ( sPath[ Length( sPath ) ] <> PathSeparator ) then
    sPath := sPath + PathSeparator;
  Result := sPath;
end;

{ TIBDatabaseINI }

procedure TIBDatabaseINI.AssignParam(Name, Value: string);
var
  i: Integer;
  found: boolean;
begin
  found := False;
  if FDatabase = nil then
    exit;
  if Trim(Value) <> '' then
  begin
    for i := 0 to FDatabase.Params.Count - 1 do
    begin
      if (Pos(Name, LowerCase(FDatabase.Params.Names[i])) = 1) then {mbcs ok}
      begin
        FDatabase.Params.Values[FDatabase.Params.Names[i]] := Value;
        found := True;
        break;
      end;
    end;
    if not found then
      FDatabase.Params.Add(Name + '=' + Value);
  end
  else
    DeleteParam(Name);
end;

procedure TIBDatabaseINI.WriteToDatabase(ADatabase: TIBDatabase);
begin
  if Assigned(ADatabase) then
  begin
    if FDatabaseName <> '' then
      ADatabase.DatabaseName := FDatabaseName;
    if FUserName <> '' then
      AssignParam(SIniUserName, FUserName);
    if FPassword <> '' then
      AssignParam(SIniPassword, FPassword);
    if FSQLRole <> '' then
      AssignParam(SIniSQLRole, FSQLRole);
    if FCharacterSet <> '' then
      AssignParam(SIniCharacterSet, FCharacterSet);
  end;
end;

procedure TIBDatabaseINI.DeleteParam(Name: string);
var
  i: Integer;
begin
  if FDatabase = nil then
    exit;
  for i := 0 to FDatabase.Params.Count - 1 do
  begin
    if (Pos(Name, LowerCase(FDatabase.Params.Names[i])) = 1) then {mbcs ok}
    begin
      FDatabase.Params.Delete(i);
      break;
    end;
  end;
end;

function TIBDatabaseINI.GetParam(Name: string): string;
var
  i: Integer;
begin
  Result := '';
  if FDatabase = nil then
    exit;
  for i := 0 to FDatabase.Params.Count - 1 do
  begin
    if (Pos(Name, LowerCase(FDatabase.Params.Names[i])) = 1) then {mbcs ok}
    begin
      Result := FDatabase.Params.Values[FDatabase.Params.Names[i]];
      break;
    end;
  end;
end;

procedure TIBDatabaseINI.Loaded;
begin
  inherited;
  ReadFromINI;
  if Assigned(FDatabase) and ( not ( csDesigning in ComponentState ) ) then
    WriteToDatabase(FDatabase);
end;

procedure TIBDatabaseINI.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (AComponent = FDatabase) and (Operation = opRemove) then
    FDatabase := nil;
end;

procedure TIBDatabaseINI.ReadFromDatabase;
begin
  if Assigned(FDatabase) then
  begin
    if FDatabase.DatabaseName <> '' then
      FDatabaseName := FDatabase.DatabaseName;
    if GetParam(SIniUserName) <> '' then
      FUserName := GetParam(SIniUserName);
    if GetParam(SIniPassword) <> '' then
      FPassword := GetParam(SIniPassword);
    if GetParam(SIniSQLRole) <> '' then
      FSQLRole := GetParam(SIniSQLRole);
    if GetParam(SIniCharacterSet) <> '' then
      FCharacterSet := GetParam(SIniCharacterSet);
  end;
end;

procedure TIBDatabaseINI.ReadFromINI;
var
  sININame : String;
begin
  sININame := IniFileName;
  if sININame = '' then
    Exit;

 with TIniFile.Create(sININame) do
  try
    {Do it to the setter so the IBDatabase will be updated if assigned }
    if SectionExists(FSection) then
    begin
      FDatabaseName := ReadString(FSection, SIniDatabase, '' );
      FUsername := ReadString(FSection, SIniUserName, '' );
      FPassword := ReadString(FSection, SIniPassword, '' );
      FSQLRole := ReadString(FSection, SIniSQLRole, '' );
      FCharacterSet := ReadString(FSection, SIniCharacterSet, '');
    end;
  finally
    Free;
  end;
end;

procedure TIBDatabaseINI.SaveToINI;
begin
  if FFileName = '' then
    Exit;
  with TIniFile.Create(FFileName) do
  try
    WriteString(FSection, SIniDatabase, FDatabaseName );
    WriteString(FSection, SIniUserName, FUsername );
    WriteString(FSection, SIniPassword, FPassword );
    WriteString(FSection, SIniSQLRole, FSQLRole );
    WriteString(FSection, SIniCharacterSet, FCharacterSet);
  finally
    Free;
  end;
end;

procedure TIBDatabaseINI.SetDatabase(const Value: TIBDatabase);
begin
  if FDatabase <> Value then
    FDatabase := Value;
end;

procedure TIBDatabaseINI.SetDatabaseName(const Value: String);
begin
  if FDatabaseName <> Value then
    FDatabaseName := Value;
end;

procedure TIBDatabaseINI.SetFileName(const Value: String);
begin
  if FFileName <> Value then
  begin
    FFileName := Value;
    ReadFromINI;
  end;
end;

procedure TIBDatabaseINI.SetPassword(const Value: String);
begin
  if FPassword <> Value then
    FPassword := Value;
end;

procedure TIBDatabaseINI.SetSQLRole(const Value: String);
begin
  if FSQLRole <> Value then
    FSQLRole := Value;
end;

procedure TIBDatabaseINI.SetUsername(const Value: String);
begin
  if FUsername <> Value then
    FUsername := Value;
end;

constructor TIBDatabaseINI.Create(AOwner: Tcomponent);
begin
  inherited;
  FSection := 'Database Settings';
  FAppPath := ipoPathToServer;
end;

procedure TIBDatabaseINI.SetSection(const Value: String);
begin
  if Value = '' then
    raise Exception.Create('Section name can not be empty');
  FSection := Value;
end;

function TIBDatabaseINI.IniFileName: string;
begin
  if FFileName = '' then
    Result := ''
  else
  begin
    if FAppPath = ipoPathToServer then
      Result := LocalServerPath(FFileName)
    else
      if FAppPath = ipoPathRelative then
        Result := SlashPath(LocalServerPath) + FFileName
      else
        Result := FFileName;
  end;
end;

procedure TIBDatabaseINI.SetCharacterSet(const Value: String);
begin
  if FCharacterSet <> Value then
    FCharacterSet := Value;
end;

end.
