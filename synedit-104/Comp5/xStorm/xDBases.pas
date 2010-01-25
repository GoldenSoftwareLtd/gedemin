{$DEFINE xTool}

{*******************************************************}
{                                                       }
{       xTool - Component Collection                    }
{                                                       }
{       Copyright (c) 1995,96 Stefan Bother             }
{                                                       }
{*******************************************************}

{++

  Copyright (c) 1996 by Golden Software of Belarus

  Module

    xDBases.pas

  Abstract

    Some basic routines to manipulate the databases.

  Author

    Vladimir Belyi (17-Sep-1996)

  Contact address

    andreik@gs.minsk.by

  Revisions history

    1.00  17-Sep-1996  Belyi  First functions.
    1.01  23-Sep-1996  Belyi  DeleteTable, TablesHaveEqualStructures func's
                              TableTypes added (no errors with dBase tables)
                              gettableType, TableTypeByExt functions.
    1.02   4-Oct-1996  Belyi  Property editor for DatabaseName property.
                             (Really, its code was copied from private part
                             of Borland's db registration file)

--}



unit xDBases;

interface

uses
  Classes, SysUtils, DBTables, DB, DsgnIntf;


type
  TCopyMode = (cmCopyIndex, cmRename);
  TCopyModes = set of TCopyMode;

{ next function copies/renames table with its indeces
  (returns true if successfully) }
function CopyTable(SrcDatabaseName, SrcTableName: TFileName;
  SrcTableType: TTableType;
  DestDatabaseName, DestTableName: TFileName; DestTableType: TTableType;
  Mode: TCopyModes): Boolean;

{ this function returns true if table exists }
function TableExists(DatabaseName, TableName: TFileName;
  TableType: TTableType): Boolean;

{ next function deletes a table (true if successfully) }
function DeleteTable(DatabaseName, TableName: TFileName;
  TableType: TTableType): Boolean;

{ next function compares structures (and indeces) of two tables } 
function TablesHaveEqualStructure(DatabaseName1, TableName1: TFileName;
  TableType1: TTableType; DatabaseName2, TableName2: TFileName;
  TableType2: TTableType): Boolean;

{ This function returns the type of the table. It finds type even for
  tables with TableType = ttDefault }
function GetTableType(ATable: TTable): TTableType;

{ This function returns the type of the default table by its extension }
function TableTypeByExt(TableName: TFileName): TTableType;

const
  TableTypeMasks: array[TTableType] of string[5] =
    ('*.*', '*.DB', '*.DBF', '*.TXT', '*.DB');

{ Some property editors to be used }
type
  TDBStringProperty = class(TStringProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure GetValueList(List: TStrings); virtual; abstract;
    procedure GetValues(Proc: TGetStrProc); override;
  end;

type
  TDatabaseNameProperty = class(TDBStringProperty)
  public
    procedure GetValueList(List: TStrings); override;
  end;


implementation

function CopyTable(SrcDatabaseName, SrcTableName: TFileName;
  SrcTableType: TTableType;
  DestDatabaseName, DestTableName: TFileName; DestTableType: TTableType;
  Mode: TCopyModes): Boolean;
var
  STable, DTable: TTable;
  Mover: TbatchMove;
  i: Integer;
begin
  STable := TTable.create(nil);
  DTable := TTable.create(nil);
  Mover := TBatchMove.Create(nil);
  try
    STable.DatabaseName := SrcDatabaseName;
    STable.TableName := SrcTableName;
    STable.TableType := SrcTableType;
    DTable.DatabaseName := DestDatabaseName;
    DTable.TableName := DestTableName;
    DTable.TableType := DestTableType;
    STable.Active := true;
    STable.FieldDefs.Update;
    STable.IndexDefs.Update;
    DTable.FieldDefs.Assign(STable.FieldDefs);
    DTable.CreateTable;
    if cmCopyIndex in Mode then
      begin
        for i:=0 to STable.IndexDefs.Count - 1 do
          DTable.AddIndex(STable.IndexDefs.Items[i].Name,
                          STable.IndexDefs.Items[i].Fields,
                          STable.IndexDefs.Items[i].Options);
      end;
    Mover.Source := STable;
    Mover.Destination := DTable;
    Mover.Mode := batAppend;
    Mover.Execute;
    if cmRename in Mode then
      begin
        STable.Close;
        STable.DeleteTable;
      end;
    Result := true;
  finally
    Stable.Free;
    DTable.Free;
    Mover.Free;
  end;
end;

function TableExists(DatabaseName, TableName: TFileName;
  TableType: TTableType): Boolean;
var
  List: TStringList;
  s: string;
begin
  s := TableName;
  if pos('.', s) = 0 then
    s := s + ExtractFileExt(TableTypeMasks[TableType]);
  List := TStringList.Create;
  try
    Session.GetTableNames(DatabaseName, s, true, false, List);
    Result := List.Count > 0;
  finally
    List.Free;
  end;
end;

function DeleteTable(DatabaseName, TableName: TFileName;
  TableType: TTableType): Boolean;
var
  ATable: TTable;
begin
  Result := False;
  try
    ATable := TTable.Create(nil);
    try
      ATable.DatabaseName := DatabaseName;
      ATable.TableName := TableName;
      ATable.TableType := TableType;
      ATable.DeleteTable;
      Result := true;
    finally
      ATable.Free;
    end;
  except
  end;
end;

function TablesHaveEqualStructure(DatabaseName1, TableName1: TFileName;
  TableType1: TTableType; DatabaseName2, TableName2: TFileName;
  TableType2: TTableType): Boolean;
var
  A, B: TTable;
  i, j: Integer;
  f: Boolean;
begin
  if tableType1 <> TableType2 then
    begin
      Result := false;
      exit; 
    end;
  A := TTable.create(nil);
  B := TTable.create(nil);
  try
    Result := true;
    A.DatabaseName := DatabaseName1;
    A.TableName := TableName1;
    A.TableType := TableType1;
    B.DatabaseName := DatabaseName2;
    B.TableName := TableName2;
    B.TableType := TableType2;
    A.Active := true;
    B.Active := true;

    { comparing fields }
    A.FieldDefs.Update;
    B.FieldDefs.Update;
    if A.FieldDefs.Count <> B.FieldDefs.Count then
      Result := false
    else
      for i := 0 to A.FieldDefs.Count - 1 do
        begin
          f := false;
          for j := 0 to B.FieldDefs.Count - 1 do
            if ( A.FieldDefs.Items[i].Name =
                 B.FieldDefs.Items[j].Name ) and
               ( A.FieldDefs.Items[i].DataType =
                 B.FieldDefs.Items[j].DataType ) and
               ( A.FieldDefs.Items[i].Size =
                 B.FieldDefs.Items[j].Size ) and
               ( A.FieldDefs.Items[i].Required =
                 B.FieldDefs.Items[j].Required ) then f := true;
            Result := f and Result;
        end;


    { comparing indeces }
    if result then { no need to check if fields are different }
      begin
        A.IndexDefs.Update;
        B.IndexDefs.Update;
        if A.IndexDefs.Count <> B.IndexDefs.Count then
          Result := false
        else
          for i := 0 to A.IndexDefs.Count - 1 do
            begin
              f := false;
              for j := 0 to B.IndexDefs.Count - 1 do
                if ( A.IndexDefs.Items[i].Name =
                     B.IndexDefs.Items[j].Name ) and
                   ( A.IndexDefs.Items[i].Fields =
                     B.IndexDefs.Items[j].Fields ) and
                   ( A.IndexDefs.Items[i].Expression =
                     B.IndexDefs.Items[j].Expression ) and
                   ( A.IndexDefs.Items[i].Options =
                     B.IndexDefs.Items[j].Options ) then f := true;
                Result := f and Result;
            end;
      end;

  finally
    A.Free;
    B.Free;
  end;
end;

function GetTableType(ATable: TTable): TTableType;
begin
  if ATable.TableType <> ttDefault then
    Result := ATable.TableType
  else
    Result := TableTypeByExt(ATable.TableName);
end;

function TableTypeByExt(TableName: TFileName): TTableType;
var
  s: string;
begin
  s := ExtractFileExt(TableName);
  if s[1] = '.' then
    delete(s, 1, 1);

  if UpperCase(s) = 'DBF' then
    Result := ttDBase
  else if UpperCase(s) = 'DB' then
    Result := ttParadox
  else if UpperCase(s) = 'TXT' then
    Result := ttASCII
  else Result := ttDefault;
end;

{ TDBStringProperty }

function TDBStringProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paValueList, paSortList, paMultiSelect];
end;

procedure TDBStringProperty.GetValues(Proc: TGetStrProc);
var
  I: Integer;
  Values: TStringList;
begin
  Values := TStringList.Create;
  try
    GetValueList(Values);
    for I := 0 to Values.Count - 1 do Proc(Values[I]);
  finally
    Values.Free;
  end;
end;

{ TDatabaseNameProperty }
procedure TDatabaseNameProperty.GetValueList(List: TStrings);
begin
  Session.GetDatabaseNames(List);
end;


end.
