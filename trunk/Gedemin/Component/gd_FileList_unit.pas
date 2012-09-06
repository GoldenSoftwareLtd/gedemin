
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

  public
    function GetXML: String;

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
    procedure Build;
    function GetXML: String;

    property RootPath: String read GetRootPath;
  end;

implementation

uses
  Forms, SysUtils, FileCtrl;

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

procedure TgdFSOItem.SetPath(const Value: String);
begin
  if Value > '' then
    FPath := IncludeTrailingBackslash(Value)
  else
    FPath := Value;
end;

function TgdFSOCollection.GetRootPath: String;
begin
  Result := ExtractFilePath(Application.EXEName);
end;

function TgdFSOCollection.GetXML: String;
var
  I: Integer;
begin
  Result := '<GEDEMIN_FILES>' + #13#10;

  for I := 0 to Count - 1 do
  begin
    Result := Result + (Items[I] as TgdFSOItem).GetXML;
  end;

  Result := '</GEDEMIN_FILES>' + #13#10;
end;

end.
