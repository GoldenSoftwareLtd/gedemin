
{++

  Copyright (c) 2012-2013 by Golden Software of Belarus

  Module

    gd_FileList_unit.pas

  Abstract

    A file list for gedemin updater.

  Author

    Andrei Kireyeu

  Revisions history

    1.00    04.09.12    andreik        Initial version.

--}

unit gd_FileList_unit;

interface

uses
  Classes, ContNrs, SysUtils, idHTTP, idComponent, gd_ProgressNotifier_unit,
  yaml_writer, yaml_parser;

type
  TFLFlag = (
    flAlwaysOverwrite,
    flNeverOverwrite,
    flOverwriteIfNewer,
    flRemove,
    flDontBackup,
    flAskPermission);

  TFLFlags = set of TFLFlag;

  TChars = set of Char;

  TFLItem = class(TCollectionItem)
  private
    FName: String;
    FPath: String;
    FIsDirectory: Boolean;
    FReqVer: String;

    FDate: TDateTime;
    FVersion: String;
    FSize: Int64;
    FExists: Boolean;

    FFlags: TFLFlags;

    class function ExtractInt(const V: String; var B: Integer;
      const TermChars: TChars): Integer;

    function GetFullName: String;
    function GetRelativeName: String;
    function GetParentFolder: String;

  protected
    class procedure InternalScan(const AFullName: String; const IsDirectory: Boolean;
      out AnExists: Boolean; out ADate: TDateTime; out ASize: Int64; out AVersion: String);

    procedure GetYAML(W: TyamlWriter);
    procedure ParseYAML(ANode: TyamlNode);
    procedure UpdateFile(AHTTP: TidHTTP; const AnURL: String; ACmdList: TStringList;
      const AMandatoryUpdate: Boolean = False);
    procedure Scan;

  public
    constructor Create(Collection: TCollection); override;

    class function Flags2Str(const Flags: TFLFlags): String;
    class function Str2Flags(const S: String): TFLFlags;
    class function CompareVersionStrings(const V1, V2: String;
      const CompareFirst: Integer = 4): Integer;

    procedure ReadFromDisk(AStream: TStream);
    procedure WriteToDisk(const AFileName: String; AStream: TStream);

    property Name: String read FName;
    property IsDirectory: Boolean read FIsDirectory;
    property Path: String read FPath;
    property ReqVer: String read FReqVer;
    property FullName: String read GetFullName;
    property RelativeName: String read GetRelativeName;
    property ParentFolder: String read GetParentFolder;
    property Exists: Boolean read FExists;
    property Date: TDateTime read FDate;
    property Version: String read FVersion;
    property Size: Int64 read FSize;
    property Flags: TFLFlags read FFlags;
  end;

  TFLCollection = class(TCollection)
  private
    FRootPath: String;
    FCurr: Integer;
    FOldWorkBegin: TWorkBeginEvent;
    FOldWorkEnd: TWorkEndEvent;
    FOldWork: TWorkEvent;
    FOnProgressWatch: TProgressWatchEvent;
    FUpdateToken: String;

    procedure DoWorkBegin(Sender: TObject; AWorkMode: TWorkMode; const AWorkCountMax: Integer);
    procedure DoWorkEnd(Sender: TObject; AWorkMode: TWorkMode);
    procedure DoWork(Sender: TObject; AWorkMode: TWorkMode; const AWorkCount: Integer);

    procedure SetRootPath(const Value: String);

  protected
    FPI: TgdProgressInfo;

    procedure DoProgressWatch;

  public
    constructor Create;

    function UpdateFile(AHTTP: TidHTTP; const AnURL: String; ACmdList: TStringList;
      const AMandatoryUpdate: Boolean = False): Boolean;
    procedure BuildEtalonFileSet;
    procedure GetYAML(AStream: TStream);
    procedure ParseYAML(AStream: TStream);
    function FindItem(ARelativeName: String): TFLItem;

    property RootPath: String read FRootPath write SetRootPath;
    property OnProgressWatch: TProgressWatchEvent read FOnProgressWatch write FOnProgressWatch;
    property UpdateToken: String read FUpdateToken write FUpdateToken;
  end;

  EFLError = class(Exception);

implementation

uses
  Windows, Forms, FileCtrl, jclFileUtils, gd_directories_const,
  JclWin32, zlib, idURI, gd_common_functions;

const
  GedeminDirectoryLayoutYAML =
    'Version: 1'#13#10 +
    'Items: '#13#10 +
    '  - '#13#10 +
    '    Type   : Directory'#13#10 +
    '    Name   : INTL'#13#10 +
    '  - '#13#10 +
    '    Type   : Directory'#13#10 +
    '    Name   : UDF'#13#10 +
    '  - '#13#10 +
    '    Type   : Directory'#13#10 +
    '    Name   : HELP'#13#10 +
    '  - '#13#10 +
    '    Type   : Directory'#13#10 +
    '    Name   : SWIPl'#13#10 +
    '  - '#13#10 +
    '    Type   : Directory'#13#10 +
    '    Name   : SWIPl\Lib'#13#10 +
{    '  - '#13#10 +
    '    Type   : File'#13#10 +
    '    Name   : gd_pl_state.dat'#13#10 +
    '    Path   : SWIPl'#13#10 +
    '    Flags  : OverwriteIfNewer DontBackup'#13#10 +
    '    ReqVer : 2.5.20'#13#10 +
    '  - '#13#10 +
    '    Type   : File'#13#10 +
    '    Name   : libgmp-10.dll'#13#10 +
    '    Path   : SWIPl'#13#10 +
    '    Flags  : OverwriteIfNewer DontBackup'#13#10 +
    '    ReqVer : 2.5.20'#13#10 +
    '  - '#13#10 +
    '    Type   : File'#13#10 +
    '    Name   : libswipl.dll'#13#10 +
    '    Path   : SWIPl'#13#10 +
    '    Flags  : OverwriteIfNewer DontBackup'#13#10 +
    '    ReqVer : 2.5.20'#13#10 +
    '  - '#13#10 +
    '    Type   : File'#13#10 +
    '    Name   : pthreadGC2.dll'#13#10 +
    '    Path   : SWIPl'#13#10 +
    '    Flags  : OverwriteIfNewer DontBackup'#13#10 +
    '    ReqVer : 2.5.20'#13#10 +
    '  - '#13#10 +
    '    Type   : File'#13#10 +
    '    Name   : memfile.dll'#13#10 +
    '    Path   : SWIPl\Lib'#13#10 +
    '    Flags  : OverwriteIfNewer DontBackup'#13#10 +
    '    ReqVer : 2.5.20'#13#10 +
    '  - '#13#10 +
    '    Type   : File'#13#10 +
    '    Name   : readutil.dll'#13#10 +
    '    Path   : SWIPl\Lib'#13#10 +
    '    Flags  : OverwriteIfNewer DontBackup'#13#10 +
    '    ReqVer : 2.5.20'#13#10 +  }
    '  - '#13#10 +
    '    Type   : File'#13#10 +
    '    Name   : gudf.dll'#13#10 +
    '    Path   : UDF'#13#10 +
    '    Flags  : OverwriteIfNewer'#13#10 +
    '  - '#13#10 +
    '    Type   : File'#13#10 +
    '    Name   : fbintl.conf'#13#10 +
    '    Path   : INTL'#13#10 +
    '    Flags  : OverwriteIfNewer DontBackup'#13#10 +
    '  - '#13#10 +
    '    Type   : File'#13#10 +
    '    Name   : fbintl.dll'#13#10 +
    '    Path   : INTL'#13#10 +
    '    Flags  : OverwriteIfNewer DontBackup'#13#10 +
    '  - '#13#10 +
    '    Type   : File'#13#10 +
    '    Name   : fr24rus.chm'#13#10 +
    '    Path   : HELP'#13#10 +
    '    Flags  : OverwriteIfNewer DontBackup'#13#10 +
    '  - '#13#10 +
    '    Type   : File'#13#10 +
    '    Name   : vbs55.chm'#13#10 +
    '    Path   : HELP'#13#10 +
    '    Flags  : OverwriteIfNewer DontBackup'#13#10 +
    '  - '#13#10 +
    '    Type   : File'#13#10 +
    '    Name   : gedemin.exe'#13#10 +
    '    Flags  : OverwriteIfNewer'#13#10 +
    '  - '#13#10 +
    '    Type   : File'#13#10 +
    '    Name   : gedemin_upd.exe'#13#10 +
    '    Flags  : OverwriteIfNewer DontBackup'#13#10 +
    '  - '#13#10 +
    '    Type   : File'#13#10 +
    '    Name   : ssleay32.dll'#13#10 +
    '    Flags  : OverwriteIfNewer DontBackup'#13#10 +
    '  - '#13#10 +
    '    Type   : File'#13#10 +
    '    Name   : libeay32.dll'#13#10 +
    '    Flags  : OverwriteIfNewer DontBackup'#13#10 +
    '  - '#13#10 +
    '    Type   : File'#13#10 +
    '    Name   : fbembed.dll'#13#10 +
    '    Flags  : OverwriteIfNewer DontBackup'#13#10 +
    '  - '#13#10 +
    '    Type   : File'#13#10 +
    '    Name   : firebird.msg'#13#10 +
    '    Flags  : OverwriteIfNewer DontBackup'#13#10 +
    '  - '#13#10 +
    '    Type   : File'#13#10 +
    '    Name   : ib_util.dll'#13#10 +
    '    Flags  : OverwriteIfNewer DontBackup'#13#10 +
    '  - '#13#10 +
    '    Type   : File'#13#10 +
    '    Name   : icudt30.dll'#13#10 +
    '    Flags  : OverwriteIfNewer DontBackup'#13#10 +
    '  - '#13#10 +
    '    Type   : File'#13#10 +
    '    Name   : icuin30.dll'#13#10 +
    '    Flags  : OverwriteIfNewer DontBackup'#13#10 +
    '  - '#13#10 +
    '    Type   : File'#13#10 +
    '    Name   : icuuc30.dll'#13#10 +
    '    Flags  : OverwriteIfNewer DontBackup'#13#10 +
    '  - '#13#10 +
    '    Type   : File'#13#10 +
    '    Name   : midas.dll'#13#10 +
    '    Flags  : OverwriteIfNewer'#13#10 +
    '  - '#13#10 +
    '    Type   : File'#13#10 +
    '    Name   : midas.sxs.manifest'#13#10 +
    '    Flags  : OverwriteIfNewer DontBackup'#13#10 +
    '  - '#13#10 +
    '    Type   : File'#13#10 +
    '    Name   : msvcp80.dll'#13#10 +
    '    Flags  : OverwriteIfNewer DontBackup'#13#10 +
    '  - '#13#10 +
    '    Type   : File'#13#10 +
    '    Name   : msvcr80.dll'#13#10 +
    '    Flags  : OverwriteIfNewer DontBackup'#13#10 +
    '  - '#13#10 +
    '    Type   : File'#13#10 +
    '    Name   : Microsoft.VC80.CRT.manifest'#13#10 +
    '    Flags  : OverwriteIfNewer DontBackup';

class function TFLItem.CompareVersionStrings(const V1, V2: String;
  const CompareFirst: Integer = 4): Integer;
var
  B1, B2, J: Integer;
begin
  B1 := 1; B2 := 1; J := 0;
  repeat
    Inc(J);
    Result := ExtractInt(V1, B1, ['.']) - ExtractInt(V2, B2, ['.']);
  until (Result <> 0)
    or ((B1 > Length(V1)) and (B2 > Length(V2)))
    or (J >= CompareFirst);
end;

constructor TFLItem.Create(Collection: TCollection);
begin
  inherited;
end;

class function TFLItem.ExtractInt(const V: String; var B: Integer;
  const TermChars: TChars): Integer;
var
  E: Integer;
begin
  E := B + 1;
  while (B <= Length(V)) and (E <= Length(V)) and (not (V[E] in TermChars)) do
    Inc(E);
  Result := StrToIntDef(Copy(V, B, E - B), 0);
  B := E + 1;
end;

class function TFLItem.Flags2Str(const Flags: TFLFlags): String;
begin
  Result := '';

  if flAlwaysOverwrite in Flags then
    Result := Result + 'AlwaysOverwrite ';
  if flNeverOverwrite in Flags then
    Result := Result + 'NeverOverwrite ';
  if flOverwriteIfNewer in Flags then
    Result := Result + 'OverwriteIfNewer ';
  if flRemove in Flags then
    Result := Result + 'Remove ';
  if flDontBackup in Flags then
    Result := Result + 'DontBackup ';
  if flAskPermission in Flags then
    Result := Result + 'AskPermission ';

  if Result > '' then
    SetLength(Result, Length(Result) - 1);
end;

function TFLItem.GetFullName: String;
begin
  Result := (Collection as TFLCollection).RootPath + RelativeName;
end;

{ TFLCollection }

function TFLCollection.UpdateFile(AHTTP: TidHTTP; const AnURL: String;
  ACmdList: TStringList; const AMandatoryUpdate: Boolean = False): Boolean;
begin
  Result := FCurr < Count;
  if Result then
  begin
    if FCurr = 0 then
    begin
      FPI.State := psInit;
      FPI.Started := Now;
      FPI.ProcessName := 'Обновление файлов';
      FPI.NumberOfSteps := Count;
      FPI.Message := '';
      DoProgressWatch;
    end;

    FPI.State := psProgress;
    FPI.CurrentStep := FCurr;
    FPI.CurrentStepName := 'Загрузка файла ' + (Items[FCurr] as TFLItem).RelativeName + '...';
    FPI.CurrentStepMax := 0;
    FPI.CurrentStepDone := 0;
    DoProgressWatch;

    FOldWorkBegin := AHTTP.OnWorkBegin;
    FOldWorkEnd := AHTTP.OnWorkEnd;
    FOldWork := AHTTP.OnWork;
    try
      AHTTP.OnWorkBegin := DoWorkBegin;
      AHTTP.OnWorkEnd := DoWorkEnd;
      AHTTP.OnWork := DoWork;

      (Items[FCurr] as TFLItem).UpdateFile(AHTTP, AnURL, ACmdList, AMandatoryUpdate);
      Inc(FCurr);
    finally
      AHTTP.OnWorkBegin := FOldWorkBegin;
      AHTTP.OnWorkEnd := FOldWorkEnd;
      AHTTP.OnWork := FOldWork;
    end;

    DoProgressWatch;
  end else
  begin
    if FCurr > 0 then
    begin
      FPI.State := psDone;
      FPI.CurrentStep := FCurr;
      FPI.CurrentStepName := '';
      FPI.CurrentStepMax := 0;
      FPI.CurrentStepDone := 0;
      FPI.Message :=
        'Для завершения процесса обновления необходимо перезапустить приложение.'#13#10 +
        'Прежние версии файлов сохранены с расширением .BAK';
      DoProgressWatch;
    end;
  end;
end;

procedure TFLCollection.BuildEtalonFileSet;
var
  I: Integer;
  S: TStringStream;
begin
  S := TStringStream.Create(GedeminDirectoryLayoutYAML);
  try
    ParseYAML(S);
    for I := 0 to Count - 1 do
      (Items[I] as TFLItem).Scan;
  finally
    S.Free;
  end;
end;

class procedure TFLItem.InternalScan(const AFullName: String; const IsDirectory: Boolean;
  out AnExists: Boolean; out ADate: TDateTime; out ASize: Int64; out AVersion: String);
begin
  AVersion := '';
  ADate := 0;
  AnExists := False;
  ASize := 0;

  if IsDirectory then
  begin
    if DirectoryExists(AFullName) then
    begin
      AnExists := True;
      ADate := gd_common_functions.GetFileLastWrite(AFullName);
    end;
  end else
  begin
    if FileExists(AFullName) then
    begin
      AnExists := True;
      ADate := gd_common_functions.GetFileLastWrite(AFullName);
      ASize := FileGetSize(AFullName);
      if VersionResourceAvailable(AFullName) then
        with TjclFileVersionInfo.Create(AFullName) do
        try
          AVersion := BinFileVersion;
        finally
          Free;
        end
      else
     end;
  end;
end;

constructor TFLCollection.Create;
begin
  inherited Create(TFLItem);
  FRootPath := ExtractFilePath(Application.EXEName);
  FCurr := 0;
end;

function TFLCollection.FindItem(ARelativeName: String): TFLItem;
var
  I: Integer;
begin
  Result := nil;
  ARelativeName := StringReplace(ARelativeName, '/', '\', [rfReplaceAll]);
  for I := 0 to Count - 1 do
  begin
    if (Items[I] as TFLItem).RelativeName = ARelativeName then
    begin
      Result := Items[I] as TFLItem;
      break;
    end;
  end;
end;

procedure TFLItem.Scan;
begin
  InternalScan(FullName, IsDirectory, FExists, FDate, FSize, FVersion);
end;

class function TFLItem.Str2Flags(const S: String): TFLFlags;
var
  B, E: Integer;
  SubStr: String;
begin
  Result := [];
  B := 1;
  E := 1;
  while B <= Length(S) do
  begin
    if (S[E] = ' ') or (E > Length(S)) then
    begin
      SubStr := UpperCase(Copy(S, B, E - B));

      if SubStr = 'ALWAYSOVERWRITE' then
        Include(Result, flAlwaysOverwrite)
      else if SubStr = 'NEVEROVERWRITE' then
        Include(Result, flNeverOverwrite)
      else if SubStr = 'OVERWRITEIFNEWER' then
        Include(Result, flOverwriteIfNewer)
      else if SubStr = 'REMOVE' then
        Include(Result, flRemove)
      else if SubStr = 'DONTBACKUP' then
        Include(Result, flDontBackup)
      else if SubStr = 'ASKPERMISSION' then
        Include(Result, flAskPermission)
      else
        raise EFLError.Create('Invalid flag value');  

      B := E + 1;
      E := B + 1;
    end else
      Inc(E);
  end;
end;

procedure TFLItem.UpdateFile(AHTTP: TidHTTP; const AnURL: String;
  ACmdList: TStringList; const AMandatoryUpdate: Boolean = False);

  procedure DownloadFile(const ALocalName: String);
  var
    MS: TMemoryStream;
    f: THandle;
    T: TFileTime;
    S: TSystemTime;
  begin
    MS := TMemoryStream.Create;
    try
      AHTTP.Get(TidURI.URLEncode(AnURL + '/get_file?fn=' + RelativeName +
        '&update_token=' + (Collection as TFLCollection).UpdateToken), MS);
      MS.Position := 0;
      WriteToDisk(ALocalName, MS);
    finally
      MS.Free;
    end;

    if Self.Date <> 0 then
    begin
      DecodeDate(Self.Date, S.wYear, S.wMonth, S.wDay);
      DecodeTime(Self.Date, S.wHour, S.wMinute, S.wSecond, S.wMilliseconds);
      S.wMilliseconds := 0;
      f := FileOpen(ALocalName, fmOpenWrite or fmShareDenyNone);
      try
        if (f <> 0) and SystemTimeToFileTime(S, T) then
          SetFileTime(f, nil, nil, @T);
      finally
        FileClose(f);
      end;
    end;
  end;

var
  LocalExists: Boolean;
  LocalSize: Int64;
  LocalFileDate: TDateTime;
  LocalVersion: String;
begin
  Assert(Assigned(AHTTP));
  Assert(Assigned(ACmdList));

  InternalScan(FullName, IsDirectory, LocalExists, LocalFileDate,
    LocalSize, LocalVersion);

  if IsDirectory then
  begin
    if Exists and (not LocalExists) then
      CreateDir(FullName)
      //ACmdList.Add('CD ' + FullName)
    else if flRemove in Flags then
      ACmdList.Add('RD ' + FullName);
  end else
  begin
    if Exists and (not LocalExists) then
    begin
      if AnsiCompareText(Name, Gedemin_Updater) = 0 then
      begin
        DownloadFile(FullName);
      end else
      begin
        DownloadFile(FullName + '.new');
        ACmdList.Add('CF ' + FullName);
      end;  
    end else if flRemove in Flags then
      ACmdList.Add('RF ' + FullName)
    else if Exists and LocalExists and (not (flNeverOverwrite in Flags)) then
    begin
      if (flAlwaysOverwrite in Flags)
        or
        AMandatoryUpdate
        or
         (
           (flOverwriteIfNewer in Flags)
           and
           (
             (
               (Version > '')
               and (LocalVersion > '')
               and (CompareVersionStrings(Version, LocalVersion) > 0)
             )
             or
             (
               (Version = '')
               and (LocalVersion = '')
               and (Date > LocalFileDate)
             )
           )
         ) then
      begin
        if not (flDontBackup in Flags) then
          FileCopy(FullName, FullName + '.bak', True);
        if AnsiCompareText(Name, Gedemin_Updater) = 0 then
        begin
          DownloadFile(FullName);
        end else
        begin
          DownloadFile(FullName + '.new');
          ACmdList.Add('UF ' + FullName);
        end;
      end;
    end;
  end;
end;

function TFLItem.GetRelativeName: String;
begin
  if Path = '' then
    Result := Name
  else
    Result := IncludeTrailingBackslash(Path) + Name;
end;

procedure TFLItem.ReadFromDisk(AStream: TStream);
var
  Version, FSize: Int64;
  ZS: TZCompressionStream;
  FS: TFileStream;
begin
  if IsDirectory then
    raise EFLError.Create('Can not read a directory.');

  Version := 1;
  FSize := FileGetSize(FullName);
  AStream.WriteBuffer(Version, SizeOf(Version));
  AStream.WriteBuffer(FSize, SizeOf(FSize));

  ZS := TZCompressionStream.Create(AStream);
  try
    FS := TFileStream.Create(FullName, fmOpenRead or fmShareCompat);
    try
      ZS.CopyFrom(FS, 0);
    finally
      FS.Free;
    end;
  finally
    ZS.Free;
  end;
end;

function TFLItem.GetParentFolder: String;
begin
  Result := (Collection as TFLCollection).RootPath + Path;
end;

procedure TFLItem.WriteToDisk(const AFileName: String; AStream: TStream);
var
  Version, FSize: Int64;
  ZS: TZDecompressionStream;
  FS: TFileStream;
begin
  if IsDirectory then
    raise EFLError.Create('Can not write a directory.');

  AStream.ReadBuffer(Version, SizeOf(Version));
  if Version <> 1 then
    raise EFLError.Create('Invalid stream format');

  AStream.ReadBuffer(FSize, SizeOf(FSize));

  ZS := TZDecompressionStream.Create(AStream);
  try
    FS := TFileStream.Create(AFileName, fmCreate);
    try
      FS.CopyFrom(ZS, FSize);
    finally
      FS.Free;
    end;
  finally
    ZS.Free;
  end;
end;

procedure TFLCollection.SetRootPath(const Value: String);
begin
  if not DirectoryExists(Value) then
    raise EFLError.Create('Invalid root path');
  FRootPath := IncludeTrailingBackslash(Value);
end;

procedure TFLCollection.DoWork(Sender: TObject; AWorkMode: TWorkMode;
  const AWorkCount: Integer);
begin
  if Assigned(FOldWork) then
    FOldWork(Sender, AWorkMode, AWorkCount);

  FPI.CurrentStepDone := AWorkCount;
  DoProgressWatch;
end;

procedure TFLCollection.DoWorkBegin(Sender: TObject; AWorkMode: TWorkMode;
  const AWorkCountMax: Integer);
begin
  if Assigned(FOldWorkBegin) then
    FOldWorkBegin(Sender, AWOrkMode, AWorkCountMax);

  FPI.CurrentStepMax := AWorkCountMax;
end;

procedure TFLCollection.DoWorkEnd(Sender: TObject; AWorkMode: TWorkMode);
begin
  if Assigned(FOldWorkEnd) then
    FOldWorkEnd(Sender, AWorkMode);

  FPI.CurrentStepDone := FPI.CurrentStepMax;
end;

procedure TFLCollection.DoProgressWatch;
begin
  if Assigned(FOnProgressWatch) then
    FOnProgressWatch(Self, FPI);
end;

procedure TFLCollection.GetYAML(AStream: TStream);
var
  I: Integer;
  W: TyamlWriter;
begin
  W := TyamlWriter.Create(AStream);
  try
    W.WriteKey('Version');
    W.WriteInteger(1);
    W.StartNewLine;
    W.WriteKey('Items');
    W.IncIndent;
    for I := 0 to Count - 1 do
    begin
      W.StartNewLine;
      W.WriteSequenceIndicator;
      W.IncIndent;
      (Items[I] as TFLItem).GetYAML(W);
      W.DecIndent;
    end;
    W.Flush;
  finally
    W.Free;
  end;
end;

procedure TFLItem.GetYAML(W: TyamlWriter);
begin
  W.StartNewLine;
  W.WriteKey('Type   ');
  if IsDirectory then
    W.WriteString('Directory')
  else
    W.WriteString('File');

  W.StartNewLine;
  W.WriteKey('Name   ');
  W.WriteString(Name);

  if Path > '' then
  begin
    W.StartNewLine;
    W.WriteKey('Path   ');
    W.WriteString(Path);
  end;

  if ReqVer > '' then
  begin
    W.StartNewLine;
    W.WriteKey('ReqVer ');
    W.WriteString(ReqVer);
  end;

  W.StartNewLine;
  W.WriteKey('Exists ');
  W.WriteBoolean(FExists);

  if Flags <> [] then
  begin
    W.StartNewLine;
    W.WriteKey('Flags  ');
    W.WriteString(Flags2Str(Flags));
  end;  

  if (not IsDirectory) and Exists then
  begin
    W.StartNewLine;
    W.WriteKey('Size   ');
    W.WriteInteger(FSize);

    if FDate > 0 then
    begin
      W.StartNewLine;
      W.WriteKey('Date   ');
      W.WriteTimestamp(FDate);
    end;

    if FVersion > '' then
    begin
      W.StartNewLine;
      W.WriteKey('Version');
      W.WriteString(FVersion);
    end;
  end;
end;

procedure TFLCollection.ParseYAML(AStream: TStream);
var
  P: TyamlParser;
  D: TyamlDocument;
  M: TyamlMapping;
  N: TyamlSequence;
  I: Integer;
  FSOItem: TFLItem;
begin
  Clear;

  P := TyamlParser.Create;
  try
    P.Parse(AStream);
    if P.YAMLStream.Count = 1 then
    begin
      D := P.YAMLStream[0] as TyamlDocument;
      if D.Count > 0 then
      begin
        M := D.Items[0] as TyamlMapping;
        if M.ReadInteger('Version') = 1 then
        begin
          N := M.FindByName('Items') as TyamlSequence;
          for I := 0 to N.Count - 1 do
          begin
            FSOItem := Add as TFLItem;
            FSOItem.ParseYAML(N[I]);
          end;
        end;
      end;
    end;
  finally
    P.Free;
  end;
end;

procedure TFLItem.ParseYAML(ANode: TyamlNode);
begin
  if not (ANode is TyamlContainer) then
    raise EFLError.Create('Invalid data format.');

  with ANode as TyamlMapping do
  begin
    FIsDirectory := TestString('Type', 'DIRECTORY');
    FName := ReadString('Name');
    FPath := ReadString('Path');
    FFlags := Str2Flags(ReadString('Flags'));
    FExists := ReadBoolean('Exists');
    FDate := ReadDateTime('Date');
    FSize := ReadInteger('Size');
    FVersion := ReadString('Version');
    FReqVer := ReadString('ReqVer');
  end;

  if FName = '' then
    raise EFLError.Create('Name is not specified.');
end;

end.
