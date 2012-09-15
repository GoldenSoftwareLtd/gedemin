
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
  Classes, ContNrs;

type
  TgdFSOItem = class(TCollectionItem)
  private
    FIsDirectory: Boolean;
    FName: String;
    FPath: String;

    function GetFullName: String;
    procedure SetPath(const Value: String);
    function GetExists: Boolean;

  protected
    procedure Clear;

  public
    function GetXML: String;
    procedure ParseXML(const AnXML: String);

    property Name: String read FName write FName;
    property Exists: Boolean read GetExists;
    property Path: String read FPath write SetPath;
    property FullName: String read GetFullName;
    property IsDirectory: Boolean read FIsDirectory write FIsDirectory;
  end;

  TgdFSOCollection = class(TCollection)
  private
    function GetRootPath: String;

  public
    constructor Create;

    procedure Build;
    function GetXML: String;
    procedure ParseXML(const AnXML: String);

    property RootPath: String read GetRootPath;
  end;

implementation

uses
  Forms, SysUtils, FileCtrl, ComObj;

procedure TgdFSOItem.Clear;
begin
  FIsDirectory := False;
  FName := '';
  FPath := '';
end;

function TgdFSOItem.GetExists: Boolean;
begin
  if FIsDirectory then
    Result := DirectoryExists(FullName)
  else
    Result := FileExists(FullName);
end;

function TgdFSOItem.GetFullName: String;
begin
  Result := (Collection as TgdFSOCollection).RootPath + Path + Name;
end;

{ TgdFSOCollection }

procedure TgdFSOCollection.Build;

  procedure AddDirectory(const APath, AName: String);
  var
    Item: TgdFSOItem;
  begin
    Item := Add as TgdFSOItem;
    Item.Name := AName;
    Item.Path := APath;
    Item.IsDirectory := True;
  end;

  procedure AddFile(const APath, AName: String);
  var
    Item: TgdFSOItem;
  begin
    Item := Add as TgdFSOItem;
    Item.Name := AName;
    Item.Path := APath;
    Item.IsDirectory := False;
  end;

begin
  AddDirectory('', 'UDF');
  AddFile('UDF', 'gudf.dll');
end;

function TgdFSOItem.GetXML: String;
const
  Indent  = '  ';
  Indent2 = Indent + Indent;
begin
  if IsDirectory then
    Result := Indent + '<DIRECTORY>' + #13#10
  else
    Result := Indent + '<FILE>' + #13#10;

  Result := Result +
    Indent2 + '<NAME>' + Name + '</NAME>' + #13#10 +
    Indent2 + '<PATH>' + Path + '</PATH>' + #13#10;

  if Exists then
    Result := Result + Indent2 + '<EXISTS>True</EXISTS>' + #13#10
  else
    Result := Result + Indent2 + '<EXISTS>False</EXISTS>' + #13#10;

  if IsDirectory then
    Result := Result + Indent + '</DIRECTORY>' + #13#10
  else begin
    Result := Result + Indent + '</FILE>' + #13#10;
  end;
end;

procedure TgdFSOItem.ParseXML(const AnXML: String);
var
  LocalDoc, N: OleVariant;
begin
  Clear;

  LocalDoc := CreateOleObject('MSXML.DOMDocument');
  LocalDoc.Async := False;
  if LocalDoc.LoadXML(AnXML) then
  begin
    LocalDoc.SetProperty('SelectionLanguage', 'XPath');
    N := LocalDoc.SelectSingleNode('/*');
    if VarIsEmpty(N) then
      raise Exception.Create('Invalid XML format');
    FIsDirectory := AnsiCompareText(N.NodeName, 'DIRECTORY') = 0;
    N := N.FirstChild;
    while not VarIsEmpty(N) do
    begin
      if AnsiCompareText(N.NodeName, 'NAME') = 0 then
        Name := N.NodeTypedValue
      else if AnsiCompareText(N.NodeName, 'PATH') = 0 then
        Path := N.NodeTypedValue;

      N := N.NextSibling;
    end;
  end;
end;

procedure TgdFSOItem.SetPath(const Value: String);
begin
  if Value > '' then
    FPath := IncludeTrailingBackslash(Value)
  else
    FPath := Value;
end;

constructor TgdFSOCollection.Create;
begin
  inherited Create(TgdFSOItem);
end;

function TgdFSOCollection.GetRootPath: String;
begin
  Result := ExtractFilePath(Application.EXEName);
end;

function TgdFSOCollection.GetXML: String;
var
  I: Integer;
begin
  Result :=
    '<?xml version="1.0" encoding="utf-8"?>' + #13#10 +
    '<GEDEMIN_FILES><VERSION_1>' + #13#10;

  for I := 0 to Count - 1 do
  begin
    Result := Result + (Items[I] as TgdFSOItem).GetXML;
  end;

  Result := Result + '</VERSION_1></GEDEMIN_FILES>' + #13#10;
end;

procedure TgdFSOCollection.ParseXML(const AnXML: String);
var
  LocalDoc, Sel: OleVariant;
  I: Integer;
  FSOItem: TgdFSOItem;
begin
  Clear;

  LocalDoc := CreateOleObject('MSXML.DOMDocument');
  LocalDoc.Async := False;
  if LocalDoc.LoadXML(AnXML) then
  begin
    LocalDoc.SetProperty('SelectionLanguage', 'XPath');
    Sel := LocalDoc.SelectNodes('/GEDEMIN_FILES/VERSION_1/FILE | /GEDEMIN_FILES/VERSION_1/DIRECTORY');
    for I := 0 to Sel.Length - 1 do
    begin
      if Sel.Item(I).HasChildNodes then
      begin
        FSOItem := Add as TgdFSOItem;
        FSOItem.ParseXML(Sel.Item(I).XML);
      end;  
    end;
  end;
end;

end.
