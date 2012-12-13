
{++

  Copyright (c) 2012 by Golden Software of Belarus

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

    //function GetXML: String;
    //procedure ParseXML(ANode: OleVariant);
    procedure GetYAML(W: TyamlWriter);
    procedure ParseYAML(ANode: TyamlNode);
    procedure UpdateFile(AHTTP: TidHTTP; const AnURL: String; ACmdList: TStringList;
      const AMandatoryUpdate: Boolean = False);
    procedure Scan;

  public
    constructor Create(Collection: TCollection); override;

    class function Flags2Str(const Flags: TFLFlags): String;
    class function Str2Flags(const S: String): TFLFlags;
    {class function Boolean2Str(const B: Boolean): String;
    class function Str2Boolean(const S: String): Boolean;
    class function Str2DateTime(const S: String): TDateTime;}
    class function CompareVersionStrings(const V1, V2: String;
      const CompareFirst: Integer = 4): Integer;

    procedure ReadFromDisk(AStream: TStream);
    procedure WriteToDisk(const AFileName: String; AStream: TStream);

    property Name: String read FName;
    property IsDirectory: Boolean read FIsDirectory;
    property Path: String read FPath;
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
    //function GetXML: String;
    //procedure ParseXML(const AnXML: String);
    procedure GetYAML(AStream: TStream);
    procedure ParseYAML(AStream: TStream);
    function FindItem(ARelativeName: String): TFLItem;

    property RootPath: String read FRootPath write SetRootPath;
    property OnProgressWatch: TProgressWatchEvent read FOnProgressWatch write FOnProgressWatch;
  end;

  EFLError = class(Exception);

implementation

uses
  Windows, Forms, FileCtrl, jclFileUtils, gd_directories_const,
  JclWin32, zlib, idURI;

const
  {FileListSchemaXML =
    '<?xml version="1.0" encoding="utf-8"?>'#13#10 +
    '<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema"'#13#10 +
    '  targetNamespace="http://gsbelarus.com/gedemin_files" xmlns="http://gsbelarus.com/gedemin_files"'#13#10 +
    '  elementFormDefault="qualified">'#13#10 +
    '  <xs:element name="GEDEMIN_FILES">'#13#10 +
    '    <xs:complexType>'#13#10 +
    '      <xs:sequence>'#13#10 +
    '        <xs:element name="DIRECTORY" minOccurs="0" maxOccurs="unbounded">'#13#10 +
    '          <xs:complexType>'#13#10 +
    '            <xs:sequence>'#13#10 +
    '              <xs:element name="NAME" minOccurs="1" maxOccurs="1">'#13#10 +
    '                <xs:simpleType>'#13#10 +
    '                  <xs:restriction base="xs:string">'#13#10 +
    '                    <xs:minLength value="1"/>'#13#10 +
    '                    <xs:maxLength value="255"/>'#13#10 +
    '                  </xs:restriction>'#13#10 +
    '                </xs:simpleType>'#13#10 +
    '              </xs:element>'#13#10 +
    '              <xs:element name="PATH" minOccurs="0" maxOccurs="1">'#13#10 +
    '                <xs:simpleType>'#13#10 +
    '                  <xs:restriction base="xs:string">'#13#10 +
    '                    <xs:minLength value="0"/>'#13#10 +
    '                    <xs:maxLength value="255"/>'#13#10 +
    '                  </xs:restriction>'#13#10 +
    '                </xs:simpleType>'#13#10 +
    '              </xs:element>'#13#10 +
    '              <xs:element name="EXISTS" type="xs:boolean" minOccurs="0" maxOccurs="1"/>'#13#10 +
    '              <xs:element name="FLAGS" type="xs:string" minOccurs="0" maxOccurs="1"/>'#13#10 +
    '            </xs:sequence>'#13#10 +
    '          </xs:complexType>'#13#10 +
    '        </xs:element>'#13#10 +
    '        <xs:element name="FILE" minOccurs="0" maxOccurs="unbounded">'#13#10 +
    '          <xs:complexType>'#13#10 +
    '            <xs:sequence>'#13#10 +
    '              <xs:element name="NAME" minOccurs="1" maxOccurs="1">'#13#10 +
    '                <xs:simpleType>'#13#10 +
    '                  <xs:restriction base="xs:string">'#13#10 +
    '                    <xs:minLength value="1"/>'#13#10 +
    '                    <xs:maxLength value="255"/>'#13#10 +
    '                  </xs:restriction>'#13#10 +
    '                </xs:simpleType>'#13#10 +
    '              </xs:element>'#13#10 +
    '              <xs:element name="PATH" minOccurs="0" maxOccurs="1">'#13#10 +
    '                <xs:simpleType>'#13#10 +
    '                  <xs:restriction base="xs:string">'#13#10 +
    '                    <xs:minLength value="0"/>'#13#10 +
    '                    <xs:maxLength value="255"/>'#13#10 +
    '                  </xs:restriction>'#13#10 +
    '                </xs:simpleType>'#13#10 +
    '              </xs:element>'#13#10 +
    '              <xs:element name="EXISTS" type="xs:boolean" minOccurs="0" maxOccurs="1"/>'#13#10 +
    '              <xs:element name="FLAGS" type="xs:string" minOccurs="0" maxOccurs="1"/>'#13#10 +
    '              <xs:element name="SIZE" type="xs:positiveInteger" minOccurs="0" maxOccurs="1"/>'#13#10 +
    '              <xs:element name="DATE" type="xs:dateTime" minOccurs="0" maxOccurs="1"/>'#13#10 +
    '              <xs:element name="VERSION" minOccurs="0" maxOccurs="1">'#13#10 +
    '                <xs:simpleType>'#13#10 +
    '                  <xs:restriction base="xs:string">'#13#10 +
    '                    <xs:pattern value="([0-9]+\.?)+"/>'#13#10 +
    '                  </xs:restriction>'#13#10 +
    '                </xs:simpleType>'#13#10 +
    '              </xs:element>'#13#10 +
    '            </xs:sequence>'#13#10 +
    '          </xs:complexType>'#13#10 +
    '        </xs:element>'#13#10 +
    '      </xs:sequence>'#13#10 +
    '      <xs:attribute name="VERSION" type="xs:decimal"/>'#13#10 +
    '    </xs:complexType>'#13#10 +
    '  </xs:element>'#13#10 +
    '</xs:schema>';

  GedeminDirectoryLayoutXML =
    '<?xml version="1.0" encoding="windows-1251"?>'#13#10 +
    '<GS:GEDEMIN_FILES VERSION="1.0" xmlns:GS="http://gsbelarus.com/gedemin_files">'#13#10 +
    '  <GS:DIRECTORY>'#13#10 +
    '    <GS:NAME>INTL</GS:NAME>'#13#10 +
    '  </GS:DIRECTORY>'#13#10 +
    '  <GS:DIRECTORY>'#13#10 +
    '    <GS:NAME>UDF</GS:NAME>'#13#10 +
    '  </GS:DIRECTORY>'#13#10 +
    '  <GS:DIRECTORY>'#13#10 +
    '    <GS:NAME>HELP</GS:NAME>'#13#10 +
    '  </GS:DIRECTORY>'#13#10 +
    '  <GS:FILE>'#13#10 +
    '    <GS:NAME>gudf.dll</GS:NAME>'#13#10 +
    '    <GS:PATH>UDF</GS:PATH>'#13#10 +
    '  </GS:FILE>'#13#10 +
    '  <GS:FILE>'#13#10 +
    '    <GS:NAME>fbintl.conf</GS:NAME>'#13#10 +
    '    <GS:PATH>INTL</GS:PATH>'#13#10 +
    '  </GS:FILE>'#13#10 +
    '  <GS:FILE>'#13#10 +
    '    <GS:NAME>fbintl.dll</GS:NAME>'#13#10 +
    '    <GS:PATH>INTL</GS:PATH>'#13#10 +
    '  </GS:FILE>'#13#10 +
    '  <GS:FILE>'#13#10 +
    '    <GS:NAME>fr24rus.chm</GS:NAME>'#13#10 +
    '    <GS:PATH>HELP</GS:PATH>'#13#10 +
    '  </GS:FILE>'#13#10 +
    '  <GS:FILE>'#13#10 +
    '    <GS:NAME>vbs55.chm</GS:NAME>'#13#10 +
    '    <GS:PATH>HELP</GS:PATH>'#13#10 +
    '  </GS:FILE>'#13#10 +
    '  <GS:FILE>'#13#10 +
    '    <GS:NAME>gedemin.exe</GS:NAME>'#13#10 +
    '  </GS:FILE>'#13#10 +
    '  <GS:FILE>'#13#10 +
    '    <GS:NAME>gedemin_upd.exe</GS:NAME>'#13#10 +
    '  </GS:FILE>'#13#10 +
    '  <GS:FILE>'#13#10 +
    '    <GS:NAME>fbembed.dll</GS:NAME>'#13#10 +
    '  </GS:FILE>'#13#10 +
    '  <GS:FILE>'#13#10 +
    '    <GS:NAME>firebird.msg</GS:NAME>'#13#10 +
    '  </GS:FILE>'#13#10 +
    '  <GS:FILE>'#13#10 +
    '    <GS:NAME>ib_util.dll</GS:NAME>'#13#10 +
    '  </GS:FILE>'#13#10 +
    '  <GS:FILE>'#13#10 +
    '    <GS:NAME>icudt30.dll</GS:NAME>'#13#10 +
    '  </GS:FILE>'#13#10 +
    '  <GS:FILE>'#13#10 +
    '    <GS:NAME>icuin30.dll</GS:NAME>'#13#10 +
    '  </GS:FILE>'#13#10 +
    '  <GS:FILE>'#13#10 +
    '    <GS:NAME>icuuc30.dll</GS:NAME>'#13#10 +
    '  </GS:FILE>'#13#10 +
    '  <GS:FILE>'#13#10 +
    '    <GS:NAME>midas.dll</GS:NAME>'#13#10 +
    '  </GS:FILE>'#13#10 +
    '  <GS:FILE>'#13#10 +
    '    <GS:NAME>midas.sxs.manifest</GS:NAME>'#13#10 +
    '  </GS:FILE>'#13#10 +
    '  <GS:FILE>'#13#10 +
    '    <GS:NAME>msvcp80.dll</GS:NAME>'#13#10 +
    '  </GS:FILE>'#13#10 +
    '  <GS:FILE>'#13#10 +
    '    <GS:NAME>msvcr80.dll</GS:NAME>'#13#10 +
    '  </GS:FILE>'#13#10 +
    '  <GS:FILE>'#13#10 +
    '    <GS:NAME>Microsoft.VC80.CRT.manifest</GS:NAME>'#13#10 +
    '  </GS:FILE>'#13#10 +
    '</GS:GEDEMIN_FILES>';}

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

{function CheckFileAccess(const FileName: string; const CheckedAccess: Cardinal): Cardinal;
var
  Token: THandle;
  Status: LongBool;
  Access: Cardinal;
  SecDescSize: Cardinal;
  PrivSetSize: Cardinal;
  PrivSet: PRIVILEGE_SET;
  Mapping: GENERIC_MAPPING;
  SecDesc: PSECURITY_DESCRIPTOR;
begin
  Result := 0;

  if not GetFileSecurity(PChar(Filename),
    OWNER_SECURITY_INFORMATION or GROUP_SECURITY_INFORMATION or DACL_SECURITY_INFORMATION,
    nil, 0, SecDescSize) then
  begin
    exit;
  end;

  SecDesc := GetMemory(SecDescSize);
  try
    if GetFileSecurity(PChar(Filename),
      OWNER_SECURITY_INFORMATION or GROUP_SECURITY_INFORMATION
      or DACL_SECURITY_INFORMATION, SecDesc, SecDescSize, SecDescSize)
      and ImpersonateSelf(SecurityImpersonation) then
    begin
      if OpenThreadToken(GetCurrentThread, TOKEN_QUERY, False, Token) and (Token <> 0) then
      begin
        Mapping.GenericRead := FILE_GENERIC_READ;
        Mapping.GenericWrite := FILE_GENERIC_WRITE;
        Mapping.GenericExecute := FILE_GENERIC_EXECUTE;
        Mapping.GenericAll := FILE_ALL_ACCESS;

        MapGenericMask(Access, Mapping);
        PrivSetSize := SizeOf(PrivSet);
        AccessCheck(SecDesc, Token, CheckedAccess, Mapping, PrivSet, PrivSetSize, Access, Status);
        CloseHandle(Token);
        if Status then
          Result := Access;
      end;
    end;
  finally
    FreeMem(SecDesc, SecDescSize);
  end;
end;}

{class function TFLItem.Boolean2Str(const B: Boolean): String;
begin
  if B then
    Result := 'true'
  else
    Result := 'false';
end;}

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

{function TFLItem.GetXML: String;
const
  Indent  = '  ';
  Indent2 = Indent + Indent;
begin
  if IsDirectory then
    Result := Indent + '<GS:DIRECTORY>' + #13#10
  else
    Result := Indent + '<GS:FILE>' + #13#10;

  Result := Result +
    Indent2 + '<GS:NAME>' + Name + '</GS:NAME>' + #13#10 +
    Indent2 + '<GS:PATH>' + Path + '</GS:PATH>' + #13#10 +
    Indent2 + '<GS:EXISTS>' + Boolean2Str(FExists) + '</GS:EXISTS>' + #13#10 +
    Indent2 + '<GS:FLAGS>' + Flags2Str(Flags) + '</GS:FLAGS>' + #13#10;

  if (not IsDirectory) and Exists then
  begin
    Result := Result + Indent2 +
      '<GS:SIZE>' + IntToStr(FSize) + '</GS:SIZE>'#13#10;
    if FDate > 0 then
      Result := Result + Indent2 +
        '<GS:DATE>' + FormatDateTime('yyyy-mm-dd"T"hh:nn:ss', FDate) + '</GS:DATE>'#13#10;
    if FVersion > '' then
      Result := Result + Indent2 +
        '<GS:VERSION>' + FVersion + '</GS:VERSION>'#13#10;
  end;

  if IsDirectory then
    Result := Result + Indent + '</GS:DIRECTORY>' + #13#10
  else begin
    Result := Result + Indent + '</GS:FILE>' + #13#10;
  end;
end;

procedure TFLItem.ParseXML(ANode: OleVariant);
var
  N: OleVariant;
begin
  FIsDirectory := ANode.NodeName = 'GS:DIRECTORY';
  N := ANode.FirstChild;
  while not VarIsEmpty(N) do
  try
    if N.NodeName = 'GS:NAME' then
      FName := N.NodeTypedValue
    else if N.NodeName = 'GS:PATH' then
      FPath := N.NodeTypedValue
    else if N.NodeName = 'GS:FLAGS' then
      FFlags := Str2Flags(N.NodeTypedValue)
    else if N.NodeName = 'GS:EXISTS' then
      FExists := Str2Boolean(N.NodeTypedValue)
    else if N.NodeName = 'GS:DATE' then
      FDate := Str2DateTime(N.NodeTypedValue)
    else if N.NodeName = 'GS:SIZE' then
      FSize := StrToInt(N.NodeTypedValue)
    else if N.NodeName = 'GS:VERSION' then
      FVersion := N.NodeTypedValue;
    N := N.NextSibling;
  except
    on E: Exception do
    begin
      raise EFLError.Create(
        'Item Name: ' + FName + #13#10 +
        'Node Name: ' + N.NodeName + #13#10 +
        'Error: ' + E.Message);
    end;
  end;

  if FName = '' then
    raise EFLError.Create('Name is not specified.');
end;}

class procedure TFLItem.InternalScan(const AFullName: String; const IsDirectory: Boolean;
  out AnExists: Boolean; out ADate: TDateTime; out ASize: Int64; out AVersion: String);

  function GetFileLastWrite: TDateTime;
  var
    T: TFileTime;
    S: TSystemTime;
    f: THandle;
  begin
    Result := 0;
    begin
      f := FileOpen(AFullName, fmOpenRead or fmShareDenyNone);
      try
        if (f <> 0) and GetFileTime(f, nil, nil, @T)
          and FileTimeToSystemTime(T, S) then
        begin
          Result := EncodeDate(S.wYear, S.wMonth, S.wDay) +
            EncodeTime(S.wHour, S.wMinute, S.wSecond, 0);
        end;
      finally
        FileClose(f);
      end;
    end;
  end;

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
      ADate := GetFileLastWrite;
    end;
  end else
  begin
    if FileExists(AFullName) then
    begin
      AnExists := True;
      ADate := GetFileLastWrite;
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

{function TFLCollection.GetXML: String;
var
  I: Integer;
begin
  Result :=
    '<?xml version="1.0" encoding="utf-8"?>' + #13#10 +
    '<GS:GEDEMIN_FILES VERSION="1.0" xmlns:GS="http://gsbelarus.com/gedemin_files">' + #13#10;

  for I := 0 to Count - 1 do
  begin
    Result := Result + (Items[I] as TFLItem).GetXML;
  end;

  Result := Result + '</GS:GEDEMIN_FILES>' + #13#10;
end;

procedure TFLCollection.ParseXML(const AnXML: String);
var
  oXSD, objSchemas, LocalDoc, Root: OleVariant;
  I: Integer;
  FSOItem: TFLItem;
  sNamespace: String;
begin
  Clear;

  oXSD := CreateOLEObject(ProgID_MSXML_DOMDocument);
  oXSD.Async := False;
  if oXSD.LoadXML(FileListSchemaXML) then
    sNamespace := oXSD.documentElement.getAttribute('targetNamespace')
  else
    raise EFLError.Create('Can not load XML schema.');

  objSchemas := CreateOLEObject(ProgID_MSXML_XMLSchemaCache);
  objSchemas.Add(sNamespace, oXSD);

  LocalDoc := CreateOleObject(ProgID_MSXML_DOMDocument);
  LocalDoc.Async := False;
  LocalDoc.Schemas := objSchemas;
  if LocalDoc.LoadXML(AnXML) then
  begin
    Root := LocalDoc.DocumentElement;
    for I := 0 to Root.ChildNodes.Length - 1 do
    begin
      FSOItem := Add as TFLItem;
      FSOItem.ParseXML(Root.ChildNodes.Item[I]);
    end;
  end else
    raise EFLError.Create('Can not load XML.');
end;}

procedure TFLItem.Scan;
begin
  InternalScan(FullName, IsDirectory, FExists, FDate, FSize, FVersion);
end;

{class function TFLItem.Str2Boolean(const S: String): Boolean;
begin
  if (S = 'true') or (S = '1') then
    Result := True
  else if (S = 'false') or (S = '0') then
    Result := False
  else
    raise EFLError.Create('Invalid cast string as boolean.');
end;

class function TFLItem.Str2DateTime(const S: String): TDateTime;
var
  B, Y, M, D, H, N, Sec: Integer;
begin
  B := 1;
  Y := ExtractInt(S, B, ['-']);
  M := ExtractInt(S, B, ['-']);
  D := ExtractInt(S, B, ['T']);
  Result := EncodeDate(Y, M, D);
  if B < Length(S) then
  begin
    H := ExtractInt(S, B, [':']);
    N := ExtractInt(S, B, [':']);
    Sec := ExtractInt(S, B, ['.']);
    Result := Result + EncodeTime(H, N, Sec, 0);
  end;
end;}

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
      AHTTP.Get(TidURI.URLEncode(AnURL + '/get_file?fn=' + RelativeName), MS);
      MS.Position := 0;
      WriteToDisk(ALocalName, MS);
    finally
      MS.Free;
    end;

    if Date <> 0 then
    begin
      DecodeDate(Date, S.wYear, S.wMonth, S.wDay);
      DecodeTime(Date, S.wHour, S.wMinute, S.wSecond, S.wMilliseconds);
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
      ACmdList.Add('CD ' + FullName)
    else if flRemove in Flags then
      ACmdList.Add('RD ' + FullName);
  end else
  begin
    if Exists and (not LocalExists) then
    begin
      DownloadFile(FullName + '.new');
      ACmdList.Add('CF ' + FullName);
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
  end;

  if FName = '' then
    raise EFLError.Create('Name is not specified.');
end;

end.
