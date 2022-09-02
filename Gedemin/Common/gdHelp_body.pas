// ShlTanya, 24.02.2019

unit gdHelp_Body;

interface

uses
  gdHelp_Interface, gdcBaseInterface;

type
  TgdHelp = class(TInterfacedObject, IgdHelp)
  private
    HelpDir: String;

    procedure CheckHelpDir;
    function GetHelpFileID(const AFormClass, AFormSubType, AnObjClass, AnObjSubType: String): TID;

  public
    procedure ShowHelp(const ATopic: String); overload;
    procedure ShowHelp(const HelpContext: Integer); overload;
    procedure ShowHelp(const AFormClass, AFormSubType, AnObjClass, AnObjSubType: String); overload;
    function GetHelpText(const AFormClass, AFormSubType, AnObjClass, AnObjSubType: String): String;
    function ShowHelpText(const AFormClass, AFormSubType, AnObjClass, AnObjSubType: String): Boolean;
  end;

implementation

uses
  Classes, Windows, HtmlHlp, gd_directories_const, Registry, FileCtrl,
  SysUtils, ShellAPI, Forms, IBSQL, gdcFile;

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

function TgdHelp.GetHelpText(const AFormClass, AFormSubType, AnObjClass,
  AnObjSubType: String): String;
var
  F: TgdcFile;
  SS: TStringStream;
  ID: TID;
begin
  Result := '';

  ID := GetHelpFileID(AFormClass, AFormSubType, AnObjClass, AnObjSubType);

  if ID > -1 then
  begin
    SS := TStringStream.Create('');
    F := TgdcFile.Create(nil);
    try
      F.SubSet := 'ByID';
      F.ID := ID;
      F.Open;

      if not F.EOF then
      begin
        F.SaveDataToStream(SS);
        Result := SS.DataString;
      end;
    finally
      SS.Free;
      F.Free;
    end;
  end;
end;

procedure TgdHelp.ShowHelp(const AFormClass, AFormSubType, AnObjClass,
  AnObjSubType: String);
begin
end;

function TgdHelp.ShowHelpText(const AFormClass, AFormSubType, AnObjClass,
  AnObjSubType: String): Boolean;
var
  F: TgdcFile;
  ID: TID;
begin
  Result := False;

  ID := GetHelpFileID(AFormClass, AFormSubType, AnObjClass, AnObjSubType);

  if ID > -1 then
  begin
    F := TgdcFile.Create(nil);
    try
      F.SubSet := 'ByID';
      F.ID := ID;
      F.Open;

      if not F.EOF then
      begin
        F.ViewFile(False, False);
        Result := True;
      end;
    finally
      F.Free;
    end;
  end;
end;

function TgdHelp.GetHelpFileID(const AFormClass, AFormSubType, AnObjClass,
  AnObjSubType: String): TID;
var
  q: TIBSQL;
begin
  Result := -1;

  if (gdcBaseManager = nil) or (gdcBaseManager.Database = nil)
    or (not gdcBaseManager.Database.Connected) then
  begin
    exit;
  end;

  q := TIBSQL.Create(nil);
  try
    q.Transaction := gdcBaseManager.ReadTransaction;
    q.SQL.Text :=
      'SELECT 1, f.id ' +
      'FROM gd_file fold JOIN gd_file f ' +
      '  ON f.lb > fold.lb AND f.rb <= fold.rb ' +
      'WHERE ' +
      '  fold.id = 4000004 AND f.name STARTING WITH :f ' +
      'UNION ALL ' +
      'SELECT 2, f.id ' +
      'FROM gd_file fold JOIN gd_file f ' +
      '  ON f.lb > fold.lb AND f.rb <= fold.rb ' +
      'WHERE ' +
      '  fold.id = 4000004 AND f.name STARTING WITH :o ' +
      'UNION ALL ' +
      'SELECT 3, f.id ' +
      'FROM gd_file fold JOIN gd_file f ' +
      '  ON f.lb > fold.lb AND f.rb <= fold.rb ' +
      'WHERE ' +
      '  fold.id = 4000003 AND f.name STARTING WITH :f ' +
      'UNION ALL ' +
      'SELECT 4, f.id ' +
      'FROM gd_file fold JOIN gd_file f ' +
      '  ON f.lb > fold.lb AND f.rb <= fold.rb ' +
      'WHERE ' +
      '  fold.id = 4000003 AND f.name STARTING WITH :o ' +
      'ORDER BY 1';
    q.ParamByName('f').AsString := AFormClass + AFormSubType;
    q.ParamByName('o').AsString := AnObjClass + AnObjSubType;
    q.ExecQuery;
    if not q.EOF then
      Result := GetTID(q.FieldByName('id'));
  finally
    q.Free;
  end;
end;

initialization
  gdHelp := TgdHelp.Create;

finalization
  gdHelp := nil;
end.
