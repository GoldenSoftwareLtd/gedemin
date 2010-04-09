
{++

  Copyright (c) 1996-98 by Golden Software of Belarus

  Module

    xUpgTable.pas

  Abstract

    Ordinary Table or Query with ability to create Calulated fields during run-time. 

  Author

    Romanovski Denis (10-08-98)

  Revisions history

    Initial  10-08-98  Dennis  Initial version.

    beta1    10-08-98  Dennis  Beta1. Including and removing of calculated fields
                                      is possible in TTable and TQuery.  
--}

unit xUpgTable;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, DBTables;

type
  TxUpgTable = class(TTable)
  private
  protected
  public
    function AddCalcField(FieldName: String; DataType: TFieldType; 
      Size: Integer; Visible: Boolean): TField;
    procedure DeleteCalcField(FieldName: String);
  published
  end;

type
  TxUpgQuery = class(TQuery)
  private
  protected
  public
    function AddCalcField(FieldName: String; DataType: TFieldType; 
      Size: Integer; Visible: Boolean): TField;
    procedure DeleteCalcField(FieldName: String);
  published
  end;

implementation

{
  ---------------------------
  ---   xUpgTable Class   ---
  ---------------------------
}


{
  **********************
  **   Private Part   **
  **********************
}


{
  ************************
  **   Protected Part   **
  ************************
}


{
  *********************
  **   Public Part   **
  *********************
}


{
  Добавляет вычисляемое поле в таблицу
}

function TxUpgTable.AddCalcField(FieldName: String; DataType: TFieldType; 
  Size: Integer; Visible: Boolean): TField;
begin
  case DataType of
    ftString: Result := TStringField.Create(Self);
    ftSmallint: Result := TSmallintField.Create(Self);
    ftInteger: Result := TIntegerField.Create(Self);
    ftWord: Result := TWordField.Create(Self);
    ftBoolean: Result := TBooleanField.Create(Self);
    ftFloat: Result := TFloatField.Create(Self);
    ftCurrency: Result := TCurrencyField.Create(Self);
    ftBCD: Result := TBCDField.Create(Self);
    ftDate: Result := TDateField.Create(Self);
    ftTime: Result := TTimeField.Create(Self);
    ftDateTime: Result := TDateTimeField.Create(Self);
    ftBytes: Result := TBytesField.Create(Self);
    ftVarBytes: Result := TVarBytesField.Create(Self);
    ftAutoInc: Result := TAutoIncField.Create(Self);
    ftBlob: Result := TBlobField.Create(Self);
    ftMemo: Result := TMemoField.Create(Self);
    ftGraphic: Result := TGraphicField.Create(Self);
    ftFmtMemo: Result := TBlobField.Create(Self);
    ftParadoxOle: Result := TBlobField.Create(Self);
    ftDBaseOle: Result := TBlobField.Create(Self);
    ftTypedBinary: Result := TBlobField.Create(Self);
    ftCursor: Result := nil;
    ftFixedChar: Result := TStringField.Create(Self);
    ftWideString: Result := nil;
    ftLargeInt: Result := TLargeIntField.Create(Self);
    ftADT: Result := TADTField.Create(Self);
    ftArray: Result := TArrayField.Create(Self);
    ftReference: Result := TReferenceField.Create(Self);
    ftDataSet: Result := TDataSetField.Create(Self);
    ftUnknown: Result := nil
  else
    Result := nil;
  end;

  if Result <> nil then
  begin
    Result.Visible := Visible;
    Result.FieldName := FieldName;
    Result.DataSet := Self;
    Result.FieldKind := fkCalculated;
    if Size <> 0 then Result.Size := Size;
  end;
end;

{
  Удаляет вычисляемое поле
}

procedure TxUpgTable.DeleteCalcField(FieldName: String);
var
  F: TField;
begin
  F := Fields.FindField(FieldName);

  if F <> nil then
  begin
    Fields.Remove(F);
    F.Free;
  end;
end;


{
  ---------------------------
  ---   xUpgQuery Class   ---
  ---------------------------
}


{
  **********************
  **   Private Part   **
  **********************
}


{
  ************************
  **   Protected Part   **
  ************************
}


{
  *********************
  **   Public Part   **
  *********************
}


{
  Добавляет вычисляемое поле в таблицу
}

function TxUpgQuery.AddCalcField(FieldName: String; DataType: TFieldType; 
  Size: Integer; Visible: Boolean): TField;
begin
  case DataType of
    ftString: Result := TStringField.Create(Self);
    ftSmallint: Result := TSmallintField.Create(Self);
    ftInteger: Result := TIntegerField.Create(Self);
    ftWord: Result := TWordField.Create(Self);
    ftBoolean: Result := TBooleanField.Create(Self);
    ftFloat: Result := TFloatField.Create(Self);
    ftCurrency: Result := TCurrencyField.Create(Self);
    ftBCD: Result := TBCDField.Create(Self);
    ftDate: Result := TDateField.Create(Self);
    ftTime: Result := TTimeField.Create(Self);
    ftDateTime: Result := TDateTimeField.Create(Self);
    ftBytes: Result := TBytesField.Create(Self);
    ftVarBytes: Result := TVarBytesField.Create(Self);
    ftAutoInc: Result := TAutoIncField.Create(Self);
    ftBlob: Result := TBlobField.Create(Self);
    ftMemo: Result := TMemoField.Create(Self);
    ftGraphic: Result := TGraphicField.Create(Self);
    ftFmtMemo: Result := TBlobField.Create(Self);
    ftParadoxOle: Result := TBlobField.Create(Self);
    ftDBaseOle: Result := TBlobField.Create(Self);
    ftTypedBinary: Result := TBlobField.Create(Self);
    ftCursor: Result := nil;
    ftFixedChar: Result := TStringField.Create(Self);
    ftWideString: Result := nil;
    ftLargeInt: Result := TLargeIntField.Create(Self);
    ftADT: Result := TADTField.Create(Self);
    ftArray: Result := TArrayField.Create(Self);
    ftReference: Result := TReferenceField.Create(Self);
    ftDataSet: Result := TDataSetField.Create(Self);
    ftUnknown: Result := nil
  else
    Result := nil;
  end;

  if Result <> nil then
  begin
    Result.Visible := Visible;
    Result.FieldName := FieldName;
    Result.DataSet := Self;
    Result.FieldKind := fkCalculated;
    if (DataType = ftString) and (Size <> 0) then
      Result.Size := Size;
  end;
end;

{
  Удаляет вычисляемое поле
}

procedure TxUpgQuery.DeleteCalcField(FieldName: String);
var
  F: TField;
begin
  F := Fields.FindField(FieldName);

  if F <> nil then
  begin
    Fields.Remove(F);
    F.Free;
  end;
end;

end.


