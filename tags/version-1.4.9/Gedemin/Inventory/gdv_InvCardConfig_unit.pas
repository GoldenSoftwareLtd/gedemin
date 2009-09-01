unit gdv_InvCardConfig_unit;

interface

uses classes, gd_common_functions, controls;

type
  TInvCardConfigClass = class of TInvCardConfig;
  TInvCardConfig = class(TPersistent)
  private
    FStreamVersion: integer;
    FInternalOps: boolean;
    FCardFields: TStrings;
    FGoodFields: TStrings;
    FGridSettings: TMemoryStream;
    FAllInterval: boolean;
    FGoodValues: string;
    FCardValues: string;
    FEndDate: TDate;
    FBeginDate: TDate;
    FGoodValue: string;
    FDeptValue: string;
    FInputInterval: boolean;
    FDebitDocsValue: string;
    FCreditDocsValue: string;
    function   GetCardFields: TStrings;
    function   GetGoodFields: TStrings;
    function   GetGridSettings: TMemoryStream;
    procedure SetInternalOps(const Value: boolean);
  public
    constructor Create;
    destructor Destroy; override;

    procedure  SaveToStream(const Stream: TStream);
    procedure  LoadFromStream(const Stream: TStream);

    property   GoodValue: string read FGoodValue write FGoodValue;
    property   DeptValue: string read FDeptValue write FDeptValue;
    property   DebitDocsValue: string read FDebitDocsValue write FDebitDocsValue;
    property   CreditDocsValue: string read FCreditDocsValue write FCreditDocsValue;
    property   BeginDate: TDate read FBeginDate write FBeginDate;
    property   EndDate: TDate read FEndDate write FEndDate;
    property   InternalOps: boolean read FInternalOps write SetInternalOps;
    property   AllInterval: boolean read FAllInterval write FAllInterval;
    property   InputInterval: boolean read FInputInterval write FInputInterval;
    property   CardFields: TStrings read GetCardFields;
    property   GoodFields: TStrings read GetGoodFields;
    property   GridSettings: TMemoryStream read GetGridSettings;
    property   CardValues: string read FCardValues write FCardValues;
    property   GoodValues: string read FGoodValues write FGoodValues;
  end;

const
  cInputParam = '/*INPUT PARAM*/';

implementation

const
  StreamVersion = 2;

{ TBaseAcctConfig }

constructor TInvCardConfig.Create;
begin
  FCardFields := TStringList.Create;
  FGoodFields := TStringList.Create;
  FGridSettings := TMemoryStream.Create;

end;

destructor TInvCardConfig.Destroy;
begin
  FGridSettings.Free;
  FCardFields.Free;
  FGoodFields.Free;
  inherited;
end;

function TInvCardConfig.GetCardFields: TStrings;
begin
  Result := FCardFields;
end;

function TInvCardConfig.GetGoodFields: TStrings;
begin

  Result := FGoodFields;
end;

function TInvCardConfig.GetGridSettings: TMemoryStream;
begin
  FGridSettings.Position:= 0;
  Result := FGridSettings;
end;

procedure TInvCardConfig.LoadFromStream(const Stream: TStream);
var
  C, i: integer;
begin
  Stream.Position:= 0;
  Stream.Read(FStreamVersion, SizeOf(FStreamVersion));
  if FStreamVersion >= 0 then begin
    FGoodValue:= ReadStringFromStream(Stream);
    FDeptValue:= ReadStringFromStream(Stream);
    if FStreamVersion >= 2 then begin
      FDebitDocsValue:= ReadStringFromStream(Stream);
      FCreditDocsValue:= ReadStringFromStream(Stream);
    end
    else begin
      FDebitDocsValue:= '';
      FCreditDocsValue:= '';
    end;
    FInternalOps:= ReadBooleanFromStream(Stream);
    FAllInterval:= ReadBooleanFromStream(Stream);
    if not FAllInterval then begin
      FInputInterval:= ReadBooleanFromStream(Stream);
      if not FInputInterval then begin
        Stream.Read(FBeginDate, SizeOf(FBeginDate));
        Stream.Read(FEndDate, SizeOf(FEndDate));
      end;
    end;

    CardFields.Clear;
    Stream.Read(C, SizeOf(C));
    for i:= 0 to C - 1 do
      FCardFields.Add(ReadStringFromStream(Stream));

    GoodFields.Clear;
    Stream.Read(C, SizeOf(C));
    for i:= 0 to C - 1 do
      FGoodFields.Add(ReadStringFromStream(Stream));

    FCardValues:= ReadStringFromStream(Stream);
    FGoodValues:= ReadStringFromStream(Stream);

    C:= ReadIntegerFromStream(Stream);
    if C > 0 then begin
      GridSettings.CopyFrom(Stream, C);
      GridSettings.Position:= 0;
    end
    else
      GridSettings.Clear;
  end;
end;

procedure TInvCardConfig.SaveToStream(const Stream: TStream);
var
  SV, C, i: Integer;
begin
  TMemoryStream(Stream).Clear;
  SV := StreamVersion;
  Stream.Write(SV, SizeOf(SV));
  SaveStringToStream(FGoodValue, Stream);
  SaveStringToStream(FDeptValue, Stream);
  SaveStringToStream(FDebitDocsValue, Stream);
  SaveStringToStream(FCreditDocsValue, Stream);
  SaveBooleanToStream(FInternalOps, Stream);
  SaveBooleanToStream(FAllInterval, Stream);
  if not FAllInterval then begin
    SaveBooleanToStream(FInputInterval, Stream);
    if not FInputInterval then begin
      Stream.Write(FBeginDate, SizeOf(FBeginDate));
      Stream.Write(FEndDate, SizeOf(FEndDate));
    end;
  end;

  C:= CardFields.Count;
  Stream.Write(C, SizeOf(C));
  for i:= 0 to C - 1 do
    SaveStringToStream(FCardFields[i], Stream);

  C:= GoodFields.Count;
  Stream.Write(C, SizeOf(C));
  for i:= 0 to C - 1 do
    SaveStringToStream(FGoodFields[i], Stream);

  SaveStringToStream(FCardValues, Stream);
  SaveStringToStream(FGoodValues, Stream);

  SaveIntegerToStream(GridSettings.Size, Stream);
  if FGridSettings.Size > 0 then begin
    FGridSettings.Position := 0;
    Stream.CopyFrom(FGridSettings, FGridSettings.Size);
  end;
end;

procedure TInvCardConfig.SetInternalOps(const Value: boolean);
begin
  FInternalOps := Value;
end;

initialization
  RegisterClass(TInvCardConfig);
finalization
  UnRegisterClass(TInvCardConfig);

end.
