
unit xMemTable;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, DB, DBTables, Bde, DBCommon;

type

{ TxMemTable }

  TxMemTable = class(TTable)
  private
    hNilDB   : hDBIDb;

    procedure EncodeFieldDesc(var FieldDesc: FLDDesc;
      const Name: String; DataType: TFieldType; Size: Word);

  protected
    function CreateHandle: HDBICur; override;
    procedure DestroyHandle; override;

  public
    procedure BorrowFields(const Value: TTable);
    
  end;
  
procedure Register;

implementation

procedure TxMemTable.EncodeFieldDesc(var FieldDesc: FLDDesc;
  const Name: string; DataType: TFieldType; Size: Word);
begin
  with FieldDesc do
  begin
    AnsiToNative(Locale, Name, szName, SizeOf(szName) - 1);
    iFldType := FldTypeMap[DataType];
    iSubType := FldSubTypeMap[DataType];
    case DataType of
      ftString, ftBytes, ftVarBytes, ftBlob, ftMemo, ftGraphic,
      ftFmtMemo, ftParadoxOle, ftDBaseOle, ftTypedBinary:
        iUnits1 := Size;
      ftBCD:
        begin
          iUnits1 := 32;
          iUnits2 := Size;
        end;
    end;
  end;
end;

function TxMemTable.CreateHandle: hDBICur;
type
  PFieldDescList = ^TFieldDescList;
  TFieldDescList = array[0..1024] of FLDDesc;
var
  STableName: array[0..SizeOf(TFileName) - 1] of Char;
  FieldDescs: PFLDDesc;
  iFldCount: Integer;
  i : Integer;
  hIMcur   : hDBICur;
begin
  if FieldDefs.Count = 0 then
  begin
    FieldDefs.BeginUpdate;
    for I := 0 to FieldCount - 1 do
      with Fields[I] do
        if FieldKind = fkData then
          FieldDefs.Add(FieldName, DataType, Size, {Required} False);
    FieldDefs.EndUpdate;      
  end;

  Result := nil;
  FieldDescs := nil;

  iFldCount := FieldDefs.Count;
  try
    FieldDescs := AllocMem(iFldCount * SizeOf(FLDDesc));

    for I := 0 to FieldDefs.Count - 1 do
    begin
      with FieldDefs[I] do
        EncodeFieldDesc(PFieldDescList(FieldDescs)^[I], Name, DataType, Size);
    end;

    if TableName = '' then
      raise Exception.Create('Table name not assigned');

    StrPCopy(STableName, TableName);
    Check(dbiOpenDatabase(nil, nil, dbiREADWRITE, dbiOPENSHARED, nil, 0, nil,
      nil, hNilDB));
    Check(dbiCreateInMemTable(hNilDB, STableName, iFldCount, FieldDescs, hIMCur));
    Result := hIMCur;
  finally
    if FieldDescs <> nil then
      FreeMem(FieldDescs, iFldCount * Sizeof(FldDesc));
  end;
end;

procedure TxMemTable.DestroyHandle;
begin
  inherited DestroyHandle;
  Check(dbiCloseDatabase(hNilDB));
end;

procedure TxMemTable.BorrowFields(const Value: TTable);
var
  I: Integer;
begin
  Active := False;
  Fields.Clear;
  FieldDefs.BeginUpdate;
  FieldDefs.Clear;
  for I := 0 to Value.FieldCount - 1 do
    with Value.Fields[I] do
      if FieldKind = fkData then
        FieldDefs.Add(FieldName, DataType, Size, Required);
  FieldDefs.EndUpdate;
end;

// Registration

procedure Register;
begin
  RegisterComponents('x-DataBase', [TxMemTable]);
end;

end.

