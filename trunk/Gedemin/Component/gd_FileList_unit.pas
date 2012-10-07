
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
  Classes, ContNrs, SysUtils;

type
  TFLCommands = class(TStringList)
  private
    FCurr: Integer;

    procedure CheckCommand(const ACommand: String);

  public
    procedure AddCommand(const ACommand, AnArg: String);
    function GetCommand(out ACommand, AnArg: String): Boolean;
  end;

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

  protected
    class procedure InternalScan(const AFullName: String; const IsDirectory: Boolean;
      out AnExists: Boolean; out ADate: TDateTime; out ASize: Int64; out AVersion: String);

    function GetXML: String;
    procedure ParseXML(ANode: OleVariant);
    procedure AnalyzeFile(ACommandList: TFLCommands);
    procedure Scan;

  public
    constructor Create(Collection: TCollection); override;

    class function Flags2Str(const Flags: TFLFlags): String;
    class function Str2Flags(const S: String): TFLFlags;
    class function Boolean2Str(const B: Boolean): String;
    class function Str2Boolean(const S: String): Boolean;
    class function Str2DateTime(const S: String): TDateTime;
    class function CompareVersionStrings(const V1, V2: String): Integer;

    property Name: String read FName;
    property IsDirectory: Boolean read FIsDirectory;
    property Path: String read FPath;
    property FullName: String read GetFullName;
    property RelativeName: String read GetRelativeName;
    property Exists: Boolean read FExists;
    property Date: TDateTime read FDate;
    property Version: String read FVersion;
    property Size: Int64 read FSize;
    property Flags: TFLFlags read FFlags;
  end;

  TFLCollection = class(TCollection)
  private
    FRootPath: String;

  public
    constructor Create;

    procedure AnalyzeFiles(ACommandList: TFLCommands);
    procedure BuildEtalonFileSet;
    function GetXML: String;
    procedure ParseXML(const AnXML: String);

    property RootPath: String read FRootPath write FRootPath;
  end;

  EFLError = class(Exception);

implementation

uses
  Forms, FileCtrl, ComObj, jclFileUtils, gd_directories_const;

const
  FileListSchema =
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

  GedeminDirectoryLayout =
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
    '</GS:GEDEMIN_FILES>';

class function TFLItem.Boolean2Str(const B: Boolean): String;
begin
  if B then
    Result := 'true'
  else
    Result := 'false';
end;

class function TFLItem.CompareVersionStrings(const V1, V2: String): Integer;
var
  B1, B2: Integer;
begin
  B1 := 1; B2 := 1;
  repeat
    Result := ExtractInt(V1, B1, ['.']) - ExtractInt(V2, B2, ['.']);
  until (Result <> 0) or ((B1 > Length(V1)) and (B2 > Length(V2)));
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
  Result := IncludeTrailingBackSlash((Collection as TFLCollection).RootPath) + RelativeName;
end;

{ TFLCollection }

procedure TFLCollection.AnalyzeFiles(ACommandList: TFLCommands);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    (Items[I] as TFLItem).AnalyzeFile(ACommandList);
end;

procedure TFLCollection.BuildEtalonFileSet;
var
  I: Integer;
begin
  ParseXML(GedeminDirectoryLayout);
  for I := 0 to Count - 1 do
    (Items[I] as TFLItem).Scan;
end;

function TFLItem.GetXML: String;
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
      GetFileLastWrite(AFullName, ADate);
    end;
  end else
  begin
    if FileExists(AFullName) then
    begin
      AnExists := True;
      GetFileLastWrite(AFullName, ADate);
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
end;

function TFLCollection.GetXML: String;
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
  if oXSD.LoadXML(FileListSchema) then
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
end;

procedure TFLItem.Scan;
begin
  InternalScan(FullName, IsDirectory, FExists, FDate, FSize, FVersion);

  //!!!
  Include(FFlags, flAlwaysOverwrite);
  //!!!
end;

class function TFLItem.Str2Boolean(const S: String): Boolean;
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
        Include(Result, flAskPermission);

      B := E + 1;
      E := B + 1;
    end else
      Inc(E);
  end;
end;

procedure TFLItem.AnalyzeFile(ACommandList: TFLCommands);

  procedure AddFileCommand(const ACmd: String);
  begin
    if not (flDontBackup in Flags) then
      ACommandList.AddCommand('BF', RelativeName);
    ACommandList.AddCommand(ACmd, RelativeName);
  end;

var
  LocalExists: Boolean;
  LocalSize: Int64;
  LocalFileDate: TDateTime;
  LocalVersion: String;
begin
  InternalScan(FullName, IsDirectory, LocalExists, LocalFileDate,
    LocalSize, LocalVersion);

  if IsDirectory then
  begin
    if Exists and (not LocalExists) then
      ACommandList.AddCommand('CD', RelativeName)
    else if flRemove in Flags then
      ACommandList.AddCommand('RD', RelativeName);
  end else
  begin
    if Exists and (not LocalExists) then
      ACommandList.AddCommand('CF', RelativeName)
    else if flRemove in Flags then
      AddFileCommand('RF')
    else if Exists and LocalExists and (not (flNeverOverwrite in Flags)) then
    begin
      if flAlwaysOverwrite in Flags then
        AddFileCommand('UF')
      else if flOverwriteIfNewer in Flags then
      begin
        if (Version > '') and (LocalVersion > '') then
        begin
          if CompareVersionStrings(Version, LocalVersion) > 0 then
            AddFileCommand('UF');
        end else
        begin
          if Date > LocalFileDate then
            AddFileCommand('UF');
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

{ TFLCommands }

procedure TFLCommands.AddCommand(const ACommand, AnArg: String);
begin
  CheckCommand(ACommand);

  Add(ACommand);
  Add(AnArg);
end;

procedure TFLCommands.CheckCommand(const ACommand: String);
begin
  if (ACommand <> 'CD')
    and (ACommand <> 'RD')
    and (ACommand <> 'BF')
    and (ACommand <> 'UF')
    and (ACommand <> 'CF')
    and (ACommand <> 'RF') then
  begin
    raise EFLError.Create('Invalid command.');
  end;
end;

function TFLCommands.GetCommand(out ACommand, AnArg: String): Boolean;
begin
  if (FCurr >= 0) and (FCurr < Count - 1) then
  begin
    ACommand := Strings[FCurr];
    AnArg := Strings[FCurr + 1];
    Inc(FCurr, 2);
    Result := True;
  end else
    Result := False;
end;

end.
