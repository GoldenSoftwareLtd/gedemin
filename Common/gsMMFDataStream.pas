
unit gsMMFDataStream;

interface

uses
  gsMMFStream, DB;

type
  TgsMMFDataHeader = record
    Version: Integer;
    RecordCount: Integer;
    FieldCount: Integer;
  end;

  TgsMMFField = class
  private
    FName: String;
    FDataType: TFieldType;
    FField: TField;

  public
    constructor Create(F: TField); overload;
    constructor Create(S: TgsStream64; DS: TDataSet); overload;

    procedure SaveToStream(S: TgsStream64);
  end;

  TgsMMFDataStream = class(TgsStream64)
  private
    FFields: TObjectList;
    FRecordCount: Integer;
    Hdr: TgsMMFDataHeader;

  public
    constructor Create;
    destructor Destroy; override;

    procedure AddFieldDef(F: TField);
    procedure PostRecord(DS: TDataSet);
    procedure SaveData(S: TStream);
    function TestRecord(DS: TDataSet): Boolean;
  end;

implementation

{ TgsMMFDataStream }

procedure TgsMMFDataStream.AddFieldDef(F: TField);
begin
  FFields.Add(TgsMMFField.Create(F));
end;

constructor TgsMMFDataStream.Create;
begin
  inherited Create;
  FFields := TObjectList.Create(True);
end;

destructor TgsMMFDataStream.Destroy;
begin
  FFields.Free;
  inherited;
end;

procedure TgsMMFDataStream.PostRecord(DS: TDataSet);
var
  I: Integer;
  IntegerValue: Integer;
  DoubleValue: Double;
  CurrValue: Currency;
  St: TStream;
  NullArr: array[0..63] of Byte;
begin
  if FRecordCount = 0 then
  begin
    Hdr.Version := 1;
    Hdr.RecordCount := 0;
    Hdr.FieldCount := FFields.Count;
    WriteBuffer(Hdr, SizeOf(Hdr));

    for I := 0 to FFields.Count - 1 do
      with FFields[I] as TgsMMFField do
        SaveToStream(Self);
  end;

  FillChar(NullArr, SizeOf(NullArr), 0);
  for I := 0 to FFields.Count - 1 do
  begin
    with FFields[I] as TgsMMFField do
      if FField.IsNull then
        NullArr[I div 8] := NullArr[I div 8] or (Byte(1) shl (I mod 8));
  end;

  WriteBuffer(NullArr, ((FFields.Count - 1) div 8) + 1);

  for I := 0 to FFields.Count - 1 do
  begin
    with FFields[I] as TgsMMFField do
    begin
      if FField.IsNull then
        continue;

      case FDataType of
        ftInteger, ftSmallInt, ftWord:
        begin
          IntegerValue := FField.AsInteger;
          WriteBuffer(IntegerValue, SizeOf(IntegerValue));
        end;

        ftFloat, ftDate, ftTime, ftDateTime:
        begin
          DoubleValue := FField.AsFloat;
          WriteBuffer(DoubleValue, SizeOf(DoubleValue));
        end;

        ftCurrency:
        begin
          CurrValue := FField.AsCurrency;
          WriteBuffer(CurrValue, SizeOf(CurrValue));
        end;

        ftString:
        begin
          WriteString(FField.AsString);
        end;

        ftBlob, ftMemo, ftGraphic:
        begin
          St := DS.CreateBlobStream(FField, bmRead);
          try
            IntegerValue := St.Size;
            WriteBuffer(IntegerValue, SizeOf(IntegerValue));
            Self.CopyFrom(St, St.Size);
          finally
            St.Free;
          end;
        end;
      end;
    end;
  end;

  Inc(FRecordCount);
end;

procedure TgsMMFDataStream.SaveData(S: TStream);
var
  Buff: array[0..4096 - 1] of AnsiChar;
  L: LongInt;
begin
  if FRecordCount > 0 then
  begin
    Seek(0, soFromBeginning);
    ReadBuffer(Hdr, SizeOf(Hdr));
    Hdr.RecordCount := FRecordCount;
    Seek(0, soFromBeginning);
    WriteBuffer(Hdr, SizeOf(Hdr));
  end;

  Position := 0;
  repeat
    L := Read(Buff, SizeOf(Buff));
    S.WriteBuffer(Buff, L);
  until L = 0;
end;

function TgsMMFDataStream.TestRecord(DS: TDataSet): Boolean;
var
  I: Integer;
  IntegerValue: Integer;
  DoubleValue: Double;
  CurrValue: Currency;
  St: TStream;
  NullArr: array[0..63] of Byte;
  F: TgsMMFField;
begin
  Result := False;

  if FPos = 0 then
  begin
    ReadBuffer(Hdr, SizeOf(Hdr));
    if (Hdr.Version <> 1) or (Hdr.RecordCount < 0) or (Hdr.FieldCount <= 0) then
      raise EgsMMFStream.Create('Invalid stream format');
    FFields.Clear;
    for I := 0 to Hdr.FieldCount - 1 do
      FFields.Add(TgsMMFField.Create(Self, DS));
  end;

  if FRecordCount >= Hdr.RecordCount then
    exit;

  ReadBuffer(NullArr, ((FFields.Count - 1) div 8) + 1);

  for I := 0 to FFields.Count - 1 do
  begin
    F := FFields[I] as TgsMMFField;

    if F.FField.IsNull xor Boolean(NullArr[I div 8] and (Byte(1) shl (I mod 8))) then
      exit;

    if F.FField.IsNull then
      continue;

    case F.FDataType of
      ftInteger, ftSmallInt, ftWord:
      begin
        ReadBuffer(IntegerValue, SizeOf(IntegerValue));
        if F.FField.AsString = IntToStr(IntegerValue) then
          continue
        else
          exit;  
      end;

      ftFloat, ftDate, ftTime, ftDateTime:
      begin
        ReadBuffer(DoubleValue, SizeOf(DoubleValue));
        if DoubleValue <> F.FField.AsFloat then
          exit;
      end;

      ftCurrency:
      begin
        ReadBuffer(CurrValue, SizeOf(CurrValue));
        if CurrValue <> F.FField.AsCurrency then
          exit;
      end;

      ftString:
      begin
        if ReadString <> F.FField.AsString then
          exit;
      end;

      ftBlob, ftMemo, ftGraphic:
      begin
        St := DS.CreateBlobStream(F.FField, bmRead);
        try
          ReadBuffer(IntegerValue, SizeOf(IntegerValue));
          if IntegerValue <> St.Size then
            exit;
          Seek(IntegerValue, soFromCurrent);
        finally
          St.Free;
        end;
      end;
    end;
  end;

  Inc(FRecordCount);
  Result := True;
end;

{ TgsMMFField }

constructor TgsMMFField.Create(F: TField);
begin
  FName := F.FieldName;
  FDataType := F.DataType;
  FField := F;
end;

constructor TgsMMFField.Create(S: TgsStream64; DS: TDataSet);
begin
  FName := S.ReadString;
  S.ReadBuffer(FDataType, SizeOf(FDataType));
  if DS <> nil then
  begin
    FField := DS.FieldByName(FName);
    if FField = nil then
      raise EgsMMFStream.Create('Dataset doesn''t match stream format');
  end;
end;

procedure TgsMMFField.SaveToStream(S: TgsStream64);
begin
  S.WriteString(FName);
  S.WriteBuffer(FDataType, SizeOf(FDataType));
end;

end.