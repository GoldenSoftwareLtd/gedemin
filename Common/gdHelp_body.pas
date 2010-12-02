
unit gdHelp_Body;

interface

uses
  gdHelp_Interface;

type
  TgdHelp = class(TInterfacedObject, IgdHelp)
  private
    HelpDir: String;

    procedure CheckHelpDir;

  public
    procedure ShowHelp(const ATopic: String); overload;
    procedure ShowHelp(const HelpContext: Integer);overload;
  end;

implementation

uses
  Windows, HtmlHlp, gd_directories_const, Registry, FileCtrl,
  SysUtils, ShellAPI, Forms{, HelpContextsList_Unit};

const
  FirstUserContext = 100000;

procedure TgdHelp.CheckHelpDir;
var
  Reg: TRegistry;
  S: String;
begin
  if HelpDir = '' then
  begin
    Reg := TRegistry.Create(KEY_READ);
    try
      Reg.RootKey := ClientRootRegistryKey;
      if Reg.OpenKey(ClientRootRegistrySubKey, False) then
      begin
        if Reg.ValueExists(HelpDirValueName) then
        begin
          S := Reg.ReadString(HelpDirValueName);
        end;
        Reg.CloseKey;
      end;
    finally
      Reg.Free;
    end;

    if DirectoryExists(S) then
    begin
      HelpDir := IncludeTrailingBackSlash(S);
      exit;
    end;

    S := ExtractFilePath(Application.EXEName) + 'Help';

    if DirectoryExists(S) then
    begin
      HelpDir := IncludeTrailingBackSlash(S);
      exit;
    end;
  end;
end;

procedure TgdHelp.ShowHelp(const ATopic: String);
begin
  CheckHelpDir;
  if FileExists(HelpDir + ATopic) then
  begin
    HtmlHelp(
              GetDesktopWindow(),
              PChar(HelpDir + ATopic),
              HH_DISPLAY_TOPIC,
              0);
  end else
  begin
    if (ExtractFileExt(ATopic) = '.CHM') or (ExtractFileExt(ATopic) = '.HLP') then
      MessageBox(0,
        PChar('Не найден файл справки: ' + HelpDir + ATopic),
        'Ошибка',
        MB_ICONHAND or MB_TASKMODAL or MB_OK)
    else
      ShellExecute(0,
        'open',
        PChar('http://gsbelarus.com/gs/wiki/index.php/' + ATopic),
        nil,
        nil,
        SW_SHOW);

    {HtmlHelp(
              GetDesktopWindow(),
              PChar(HelpDir + 'gedyminUG.chm::/' + ATopic),
              HH_DISPLAY_TOPIC,
              0);}
  end;
end;


procedure TgdHelp.ShowHelp(const HelpContext: Integer);
var
//  I: Integer;
  HelpFile: string;
  Context: Integer;
const
  UG = 'gedyminUG.chm';
begin
  CheckHelpDir;
  if HelpContext > FirstUserContext then
  begin
    HelpFile := Screen.ActiveCustomForm.HelpFile;
    if HelpFile = '' then
      HelpFile := UG;
  end else
    HelpFile := UG;

  if HelpContext > 0 then
    Context := HelpContext
  else
    Context := 99999;
  if HelpDir > '' then
    HtmlHelp( GetDesktopWindow(),
              PChar(HelpDir + HelpFile),
              HH_HELP_CONTEXT,
              Context) ;
end;

initialization
  gdHelp := TgdHelp.Create;

finalization
  gdHelp := nil;
end.
