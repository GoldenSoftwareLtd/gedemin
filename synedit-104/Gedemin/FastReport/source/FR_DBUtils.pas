
{******************************************}
{                                          }
{     FastReport v2.5 - DB components      }
{            Various routines              }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FR_DBUtils;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, FR_Class, StdCtrls,
  Controls, Forms, Menus, Dialogs, DB
{$IFDEF Delphi2}
, DBTables
{$ENDIF};

type
  TfrParamKind = (pkAssignFromMaster, pkValue);

const
  FieldClasses: array[0..9] of TFieldClass =
   (TStringField, TSmallintField, TIntegerField, TWordField,
    TBooleanField, TFloatField, TCurrencyField, TDateField,
    TTimeField, TBlobField);

  ParamTypes: Array[0..10] of TFieldType =
    (ftBCD, ftBoolean, ftCurrency, ftDate, ftDateTime, ftInteger,
     ftFloat, ftSmallint, ftString, ftTime, ftWord);


function frFindFieldDef(DataSet: TDataSet; FieldName: String): TFieldDef;
function frGetDataSetName(Owner: TComponent; d: TDataSource): String;
function frGetDataSource(Owner: TComponent; d: TDataSet): TDataSource;


implementation

uses FR_Utils;


function frFindFieldDef(DataSet: TDataSet; FieldName: String): TFieldDef;
var
  i: Integer;
begin
  Result := nil;
  with DataSet do
  for i := 0 to FieldDefs.Count - 1 do
    if AnsiCompareText(FieldDefs.Items[i].Name, FieldName) = 0 then
    begin
      Result := FieldDefs.Items[i];
      break;
    end;
end;

function frGetDataSetName(Owner: TComponent; d: TDataSource): String;
begin
  Result := '';
  if (d <> nil) and (d.DataSet <> nil) then
  begin
    Result := d.Dataset.Name;
    if d.Dataset.Owner <> Owner then
      Result := d.Dataset.Owner.Name + '.' + Result;
  end;
end;

function frGetDataSource(Owner: TComponent; d: TDataSet): TDataSource;
var
  i: Integer;
  sl: TStringList;
  ds: TDataSource;
begin
  sl := TStringList.Create;
  Result := nil;
  frGetComponents(Owner, TDataSource, sl, nil);
  for i := 0 to sl.Count - 1 do
  begin
    ds := frFindComponent(Owner, sl[i]) as TDataSource;
    if (ds <> nil) and (ds.DataSet = d) then
    begin
      Result := ds;
      break;
    end;
  end;
  sl.Free;
end;

end.

