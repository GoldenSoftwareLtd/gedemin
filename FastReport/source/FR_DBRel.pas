
{******************************************}
{                                          }
{             FastReport v2.53             }
{             DB related stuff             }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FR_DBRel;

interface

{$I FR.inc}

uses
  SysUtils, Windows, Messages, Classes
{$IFDEF IBO}, IB_Components
{$ELSE}
 {$IFDEF Delphi2}
 , DBTables, BDE
 {$ENDIF}
 , DB
{$ENDIF};

type
  TfrBookmark =
{$IFDEF IBO} type string;
{$ELSE} type TBookmark;
{$ENDIF}

  TfrTDataSet =
{$IFDEF IBO} class(TIB_DataSet)
{$ELSE} class(TDataSet)
{$ENDIF}
  end;

  TfrTField =
{$IFDEF IBO} class(TIB_Column)
{$ELSE} class(TField)
{$ENDIF}
  end;

  TfrTBlobField =
{$IFDEF IBO} class(TIB_ColumnBlob)
{$ELSE} class(TBlobField)
{$ENDIF}
  end;

const
  frEmptyBookmark =
{$IFDEF IBO} ''
{$ELSE} nil
{$ENDIF};

function frIsBlob(Field: TfrTField): Boolean;
function frIsBookmarksEqual(DataSet: TfrTDataSet; b1, b2: TfrBookmark): Boolean;
function frIsDataSet(ds: TComponent): Boolean;
procedure frGetFieldNames(DataSet: TfrTDataSet; List: TStrings);
function frGetBookmark(DataSet: TfrTDataSet): TfrBookmark;
procedure frFreeBookmark(DataSet: TfrTDataSet; Bookmark: TfrBookmark);
procedure frGotoBookmark(DataSet: TfrTDataSet; Bookmark: TfrBookmark);
procedure frAssignBlobTo(Blob: TfrTField; Obj: TObject);


implementation

function frIsBlob(Field: TfrTField): Boolean;
begin
{$IFDEF IBO}
  Result := (Field <> nil) and (Field.SQLType >= 520) and (Field.SQLType <= 541);
{$ELSE}
  Result := (Field <> nil) and ((Field.DataType in [ftBlob..ftTypedBinary])
{$IFDEF Delphi5}
    or (Field.DataType = ftOraBlob)
{$ENDIF});
{$ENDIF};
end;

function frIsDataSet(ds: TComponent): Boolean;
begin
{$IFDEF IBO}
  Result := ds is TIB_DataSet;
{$ELSE}
  Result := ds is TDataSet;
{$ENDIF};
end;

procedure frAssignBlobTo(Blob: TfrTField; Obj: TObject);
begin
{$IFDEF IBO}
   Blob.AssignTo(Obj);
   if Obj is TStream then
     TStream(Obj).Position := 0;
{$ELSE}
  if Obj is TPersistent then
    TPersistent(Obj).Assign(Blob) else
  if Obj is TStream then
  begin
    TfrTBlobField(Blob).SaveToStream(TStream(Obj));
    TStream(Obj).Position := 0;
  end;
{$ENDIF}
end;

{$HINTS OFF}
procedure frGetFieldNames(DataSet: TfrTDataSet; List: TStrings);
var
  i: Integer;
begin
{$IFDEF IBO}
  DataSet.Prepare;
  DataSet.GetFieldNamesList(List);
  for i := 0 to List.Count - 1 do
    List[i] := Copy(List[i], pos('.', List[i]) + 1, 255);
{$ELSE}
  try
    DataSet.GetFieldNames(List);
  except;
  end;
{$ENDIF}
end;
{$HINTS ON}

function frGetBookmark(DataSet: TfrTDataSet): TfrBookmark;
begin
{$IFDEF IBO}
  Result := DataSet.Bookmark;
{$ELSE}
  Result := DataSet.GetBookmark;
{$ENDIF}
end;

procedure frGotoBookmark(DataSet: TfrTDataSet; Bookmark: TfrBookmark);
begin
{$IFDEF IBO}
  DataSet.Bookmark := Bookmark;
{$ELSE}
  DataSet.GotoBookmark(BookMark);
{$ENDIF}
end;

procedure frFreeBookmark(DataSet: TfrTDataSet; Bookmark: TfrBookmark);
begin
{$IFNDEF IBO}
  DataSet.FreeBookmark(BookMark);
{$ENDIF}
end;

{$HINTS OFF}
function frIsBookmarksEqual(DataSet: TfrTDataSet; b1, b2: TfrBookmark): Boolean;
var
  n: Integer;
begin
{$IFDEF IBO}
  Result := b1 = b2;
{$ELSE}
 {$IFDEF Delphi2}
    dbiCompareBookmarks(DataSet.Handle, b1, b2, n);
    Result := n = 0;
 {$ELSE}
    Result := DataSet.CompareBookmarks(b1, b2) = 0;
 {$ENDIF}
{$ENDIF}
end;
{$HINTS ON}

end.