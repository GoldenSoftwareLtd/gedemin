// ShlTanya, 03.02.2019

unit yaml_parser;

interface

uses
  Classes, ContNrs, yaml_common, yaml_scanner;

type
  CyamlNode = class of TyamlNode;
  TyamlNode = class(TPersistent)
  private
    FIndent: Integer;
    FTag: AnsiString;

  protected
    function ExtractNode(Scanner: TyamlScanner; const ATag: AnsiString = ''): TyamlNode;
    procedure AssignTo(Dest: TPersistent); override;

  public
    constructor Create; virtual;
    procedure Parse(Scanner: TyamlScanner); virtual; abstract;

    property Indent: Integer read FIndent write FIndent;
    property Tag: AnsiString read FTag write FTag;
  end;

  TyamlScalar = class(TyamlNode)
  protected
    function GetAsDate: TDateTime; virtual;
    function GetAsDateTime: TDateTime; virtual;
    function GetAsFloat: Double; virtual;
    function GetAsInteger: Integer; virtual;
    function GetAsString: AnsiString; virtual;
    function GetAsBoolean: Boolean; virtual;
    function GetIsNull: Boolean; virtual;
    function GetAsInt64: Int64; virtual;
    procedure SetAsDate(const Value: TDateTime); virtual;
    procedure SetAsDateTime(const Value: TDateTime); virtual;
    procedure SetAsFloat(const Value: Double); virtual;
    procedure SetAsInteger(const Value: Integer); virtual;
    procedure SetAsString(const Value: AnsiString); virtual;
    procedure SetAsBoolean(const Value: Boolean); virtual;
    procedure SetAsInt64(const Value: Int64); virtual;
    function GetAsCurrency: Currency; virtual;
    procedure SetAsCurrency(const Value: Currency); virtual;
    function GetAsStream: TStream; virtual;
    function GetAsVariant: Variant; virtual;

  public
    procedure Parse(Scanner: TyamlScanner); override;
    function Compare(ANode: TyamlScalar): Integer; virtual;

    property AsString: AnsiString read GetAsString write SetAsString;
    property AsInteger: Integer read GetAsInteger write SetAsInteger;
    property AsFloat: Double read GetAsFloat write SetAsFloat;
    property AsDate: TDateTime read GetAsDate write SetAsDate;
    property AsDateTime: TDateTime read GetAsDateTime write SetAsDateTime;
    property AsBoolean: Boolean read GetAsBoolean write SetAsBoolean;
    property IsNull: Boolean read GetIsNull;
    property AsInt64: Int64 read GetAsInt64 write SetAsInt64;
    property AsCurrency: Currency read GetAsCurrency write SetAsCurrency;
    property AsStream: TStream read GetAsStream;
    property AsVariant: Variant read GetAsVariant;
  end;

  TyamlNumeric = class(TyamlScalar)
  protected
    function GetAsVariant: Variant; override;

  public
    function Compare(ANode: TyamlScalar): Integer; override;
  end;

  TyamlString = class(TyamlScalar)
  private
    FValue: AnsiString;
    FQuoting: TyamlScalarQuoting;
    FStyle: TyamlScalarStyle;

  protected
    function GetAsString: AnsiString; override;
    function GetAsInteger: Integer; override;
    function GetAsCurrency: Currency; override;
    function GetAsFloat: Double; override;
    function GetAsInt64: Int64; override;
    procedure SetAsString(const Value: AnsiString); override;
    procedure SetAsInteger(const Value: Integer); override;
    procedure SetAsCurrency(const Value: Currency); override;
    procedure SetAsFloat(const Value: Double); override;
    procedure SetAsInt64(const Value: Int64); override;
    procedure AssignTo(Dest: TPersistent); override;

  public
    constructor CreateString(const AValue: AnsiString; const AQuoting: TyamlScalarQuoting;
      const AStyle: TyamlScalarStyle);

    property Quoting: TyamlScalarQuoting read FQuoting write FQuoting;
    property Style: TyamlScalarStyle read FStyle write FStyle;
  end;

  TyamlInteger = class(TyamlNumeric)
  private
    FValue: Integer;

  protected
    function GetAsInteger: Integer; override;
    procedure SetAsInteger(const Value: Integer); override;
    function GetAsString: AnsiString; override;
    procedure SetAsString(const Value: AnsiString); override;
    function GetAsVariant: Variant; override;
    procedure AssignTo(Dest: TPersistent); override;

  public
    constructor CreateInteger(const AValue: Integer); overload;
    constructor CreateInteger(const AValue: AnsiString); overload;
  end;

  TyamlInt64 = class(TyamlNumeric)
  private
    FValue: Int64;

  protected
    function GetAsInt64: Int64; override;
    procedure SetAsInt64(const Value: Int64); override;
    function GetAsBoolean: Boolean; override;
    procedure SetAsBoolean(const Value: Boolean); override;
    procedure AssignTo(Dest: TPersistent); override;

  public
    constructor CreateInt64(const AValue: Int64); overload;
    constructor CreateInt64(const AValue: AnsiString); overload;
  end;

  TyamlDateTime = class(TyamlScalar)
  private
    FValue: TDateTime;

  protected
    function GetAsDateTime: TDateTime; override;
    procedure SetAsDateTime(const Value: TDateTime); override;
    function GetAsVariant: Variant; override;
    procedure AssignTo(Dest: TPersistent); override;

  public
    constructor CreateDateTime(const AValue: TDateTime); overload;
    constructor CreateDateTime(const AValue: AnsiString); overload;
    function Compare(ANode: TyamlScalar): Integer; override;
  end;

  TyamlDate = class(TyamlScalar)
  private
    FValue: TDateTime;

  protected
    function GetAsDate: TDateTime; override;
    procedure SetAsDate(const Value: TDateTime); override;
    function GetAsVariant: Variant; override;
    procedure AssignTo(Dest: TPersistent); override;

  public
    constructor CreateDate(const AValue: TDateTime);
    function Compare(ANode: TyamlScalar): Integer; override;
  end;

  TyamlCurrency = class(TyamlNumeric)
  private
    FValue: Currency;

  protected
    function GetAsCurrency: Currency; override;
    procedure SetAsCurrency(const AValue: Currency); override;
    function GetAsVariant: Variant; override;
    procedure AssignTo(Dest: TPersistent); override;

  public
    constructor CreateCurrency(const AValue: Currency); overload;
    constructor CreateCurrency(const AValue: AnsiString); overload;
  end;

  TyamlFloat = class(TyamlNumeric)
  private
    FValue: Double;

  protected
    function GetAsFloat: Double; override;
    procedure SetAsFloat(const Value: Double); override;
    procedure AssignTo(Dest: TPersistent); override;

  public
    constructor CreateFloat(const AValue: Double); overload;
    constructor CreateFloat(const AValue: AnsiString); overload;
  end;

  TyamlBoolean = class(TyamlScalar)
  private
    FValue: Boolean;

  protected
    function GetAsBoolean: Boolean; override;
    procedure SetAsBoolean(const Value: Boolean); override;
    function GetAsInteger: Integer; override;
    procedure SetAsInteger(const Value: Integer); override;
    function GetAsString: AnsiString; override;
    procedure SetAsString(const Value: AnsiString); override;
    function GetAsVariant: Variant; override;
    procedure AssignTo(Dest: TPersistent); override;

  public
    constructor CreateBoolean(const AValue: Boolean); overload;
    constructor CreateBoolean(const AValue: AnsiString); overload;
    function Compare(ANode: TyamlScalar): Integer; override;
  end;

  TyamlNull = class(TyamlScalar)
  protected
    function GetAsString: AnsiString; override;
    function GetIsNull: Boolean; override;

  public
    function Compare(ANode: TyamlScalar): Integer; override;
  end;

  TyamlBinary = class(TyamlScalar)
  private
    MS: TStream;

    procedure Base64ToBin(const AStr: AnsiString);

  protected
    function GetAsStream: TStream; override;
    function GetAsString: AnsiString; override;
    procedure AssignTo(Dest: TPersistent); override;

  public
    constructor Create; override;
    constructor CreateBinary(const AValue: AnsiString);
    destructor Destroy; override;
  end;

  TyamlKeyValue = class(TyamlNode)
  private
    FKey: AnsiString;
    FValue: TyamlNode;

    procedure SetValue(const Value: TyamlNode);

  protected
    procedure AssignTo(Dest: TPersistent); override;

  public
    destructor Destroy; override;

    procedure Parse(Scanner: TyamlScanner); override;

    property Key: AnsiString read FKey write FKey;
    property Value: TyamlNode read FValue write SetValue;
  end;

  TyamlContainer = class(TyamlNode)
  private
    FList: TObjectList;

    function GetItems(Index: Integer): TyamlNode;
    function GetCount: Integer;

  protected
    procedure AssignTo(Dest: TPersistent); override;

  public
    constructor Create; override;
    destructor Destroy; override;

    procedure Parse(Scanner: TyamlScanner); override;
    function Add(Node: TyamlNode): TyamlNode;

    property Items[Index: Integer]: TyamlNode read GetItems; default;
    property Count: Integer read GetCount;
  end;

  TyamlStream = class(TyamlContainer)
  public
    procedure Parse(Scanner: TyamlScanner); override;
  end;

  TyamlDocument = class(TyamlContainer)
  public
    procedure Parse(Scanner: TyamlScanner); override;
  end;

  TyamlSequence = class(TyamlContainer)
  public
    procedure Parse(Scanner: TyamlScanner); override;
  end;

  TyamlMapping = class(TyamlContainer)
  public
    procedure Parse(Scanner: TyamlScanner); override;
    function FindByName(const AName: AnsiString): TyamlNode;
    function ReadString(const AName: AnsiString; const AMaxLength: Integer = -1;
      const DefValue: AnsiString = ''): AnsiString;
    function ReadInteger(const AName: AnsiString; const DefValue: Integer = 0): Integer;
    function ReadInt64(const AName: AnsiString; const DefValue: Int64 = 0): Int64;
    function ReadCurrency(const AName: AnsiString; const DefValue: Currency = 0): Currency;
    function ReadFloat(const AName: AnsiString; const DefValue: Double = 0): Double;
    function ReadDateTime(const AName: AnsiString; const DefValue: TDateTime = 0): TDateTime;
    function ReadBoolean(const AName: AnsiString; const DefValue: Boolean = False): Boolean;
    function ReadNull(const AName: AnsiString): Boolean;
    procedure ReadStream(const AName: AnsiString; S: TStream);
    function ReadValue(const AName: AnsiString; const DefValue: Variant): Variant;
    function TestString(const AName: AnsiString; const AString: AnsiString): Boolean;
  end;

  TyamlParser = class(TObject)
  private
    FYAMLStream: TyamlStream;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Parse(AStream: TStream; const AStopKey: AnsiString = ''); overload;
    procedure Parse(const AFileName: AnsiString; out ACharReplace: LongBool; const AStopKey: AnsiString = '';
      const ALimitSize: Integer = 0); overload;

    property YAMLStream: TyamlStream read FYAMLStream;
  end;

implementation

uses
  Windows, SysUtils, JclMime, JclUnicode, JclFileUtils, gd_directories_const,
  gd_common_functions;

function ConvertToInteger(const S: AnsiString; out I: Integer): Boolean;
begin
  I := StrToIntDef(S, MAXINT);
  Result := (I <> MAXINT) or (StrToIntDef(S, -1) <> -1);
end;

function ConvertToInt64(const S: AnsiString; out I: Int64): Boolean;
begin
  I := StrToInt64Def(S, High(Int64));
  Result := (I <> High(Int64)) or (StrToInt64Def(S, -1) <> -1);
end;

function ConvertToBoolean(const S: AnsiString; out B: Boolean): Boolean;
begin
  if AnsiCompareText(S, 'True') = 0 then
  begin
    B := True;
    Result := True;
  end
  else if AnsiCompareText(S, 'False') = 0 then
  begin
    B := False;
    Result := True;
  end else
    Result := False;
end;

function ConvertToDate(const S: AnsiString; out DT: TDateTime): Boolean;
begin
  if (Length(S) = 10) and (S[5] = '-') and (S[8] = '-') then
  begin
    try
      DT := EncodeDate(
        StrToIntDef(Copy(S, 1, 4), -1),
        StrToIntDef(Copy(S, 6, 2), -1),
        StrToIntDef(Copy(S, 9, 2), -1));
      Result := True;
    except
      on EConvertError do
        Result := False;
    end;
  end else
    Result := False;
end;

function ConvertToTime(const S: AnsiString; out DT: TDateTime): Boolean;
var
  P, Bias, MSec: Integer;
  MS: AnsiString;
begin
  Result := False;
  P := Length(S);
  if (P >= 8) and (S[3] = ':') and (S[6] = ':') then
  begin
    while (P >= 1) and (not (S[P] in ['+', '-', 'Z'])) do
      Dec(P);
    if P >= 9 then
    begin
      try
        MS := Trim(Copy(S, 10, P - 10));
        if MS = '' then
          MSec := 0
        else if Length(MS) = 1 then
          MSec := StrToInt(MS) * 100
        else if Length(MS) = 2 then
          MSec := StrToInt(MS) * 10
        else
          MSec := StrToInt(Copy(MS, 1, 3));
        DT := EncodeTime(
          StrToIntDef(Copy(S, 1, 2), -1),
          StrToIntDef(Copy(S, 4, 2), -1),
          StrToIntDef(Copy(S, 7, 2), -1),
          MSec);

        if (Length(S) - P = 5) and (S[P] in ['+', '-']) then
        begin
          Bias :=
            StrToInt(S[P + 1]) * 10 * 60 +
            StrToInt(S[P + 2]) * 60 +
            StrToInt(S[P + 4]) * 10 +
            StrToInt(S[P + 5]);
          if S[P] = '+' then
            DT := DT - (Bias + TZBias) / 60 / 24
          else
            DT := DT + (Bias - TZBias) / 60 / 24;
        end;

        Result := True;
      except
        on EConvertError do
          Result := False;
      end;
    end;
  end;
end;

function ConvertToDateTime(const S: AnsiString; out DT: TDateTime): Boolean;
var
  D, T: TDateTime;
begin
  if (Length(S) >= 20)
    and ConvertToDate(Copy(S, 1, 10), D)
    and ConvertToTime(Copy(S, 12, 32), T) then
  begin
    DT := D + T;
    Result := True;
  end else
    Result := False;
end;

function ConvertToCurrency(S: AnsiString; out C: Currency): Boolean;
var
  I: Integer;
begin
  for I := 1 to Length(S) do
    if (S[I] in ['.', ',']) and (S[I] <> DecimalSeparator) then
    begin
      S[I] := DecimalSeparator;
      break;
    end;

  try
    if Length(S) - I <= 4 then
    begin
      C := StrToCurr(S);
      Result := True;
    end else
      Result := False;  
  except
    on EConvertError do
      Result := False;
  end;
end;

function ConvertToFloat(S: AnsiString; out F: Double): Boolean;
var
  I: Integer;
begin
  for I := 1 to Length(S) do
    if (S[I] in ['.', ',']) and (S[I] <> DecimalSeparator) then
    begin
      S[I] := DecimalSeparator;
      break;
    end;

  try
    F := StrToFloat(S);
    Result := True;
  except
    on EConvertError do
      Result := False;
  end;
end;

{ TyamlScalar }

function TyamlScalar.GetAsBoolean: Boolean;
begin
  Result := AsInteger <> 0;
end;

function TyamlScalar.GetAsDate: TDateTime;
begin
  raise EyamlException.Create('Data type is not supported.');
end;

function TyamlScalar.GetAsDateTime: TDateTime;
begin
  Result := AsDate;
end;

function TyamlScalar.GetAsFloat: Double;
begin
  Result := AsCurrency;
end;

function TyamlScalar.GetAsInteger: Integer;
begin
  raise EyamlException.Create('Data type is not supported.');
end;

function TyamlScalar.GetAsInt64: Int64;
begin
  ConvertToInt64(AsString, Result);
end;

function TyamlScalar.GetAsString: AnsiString;
begin
  raise EyamlException.Create('Data type is not supported.');
end;

function TyamlScalar.GetIsNull: Boolean;
begin
  Result := False;
end;

procedure TyamlScalar.Parse(Scanner: TyamlScanner);
begin
  //
end;

procedure TyamlScalar.SetAsBoolean(const Value: Boolean);
begin
  if Value then
    AsInteger := 1
  else
    AsInteger := 0;  
end;

procedure TyamlScalar.SetAsDate(const Value: TDateTime);
begin
  AsDateTime := Value;
end;

procedure TyamlScalar.SetAsDateTime(const Value: TDateTime);
begin
  raise EyamlException.Create('Data type is not supported.');
end;

procedure TyamlScalar.SetAsFloat(const Value: Double);
begin
  raise EyamlException.Create('Data type is not supported.');
end;

procedure TyamlScalar.SetAsInteger(const Value: Integer);
begin
  AsCurrency := Value;
end;

procedure TyamlScalar.SetAsString(const Value: AnsiString);
begin
  raise EyamlException.Create('Data type is not supported.');
end;

procedure TyamlScalar.SetAsInt64(const Value: Int64);
begin
  AsFloat := Value;
end;

function TyamlScalar.GetAsCurrency: Currency;
begin
  Result := AsInteger;
end;

procedure TyamlScalar.SetAsCurrency(const Value: Currency);
begin
  AsFloat := Value;
end;

function TyamlScalar.GetAsStream: TStream;
begin
  raise EyamlException.Create('Data type is not supported.');
end;

function TyamlScalar.Compare(ANode: TyamlScalar): Integer;
begin
  Assert(ANode <> nil);
  Result := AnsiCompareText(Self.AsString, ANode.AsString);
end;

function TyamlScalar.GetAsVariant: Variant;
begin
  if IsNull then
    Result := Null
  else
    Result := GetAsString;  
end;

{ TyamlNode }

procedure TyamlNode.AssignTo(Dest: TPersistent);
begin
  Assert(Dest is TyamlNode);
  TyamlNode(Dest).FIndent := FIndent;
  TyamlNode(Dest).FTag := FTag;
end;

constructor TyamlNode.Create;
begin
  FIndent := 0;
end;

function TyamlNode.ExtractNode(Scanner: TyamlScanner; const ATag: AnsiString = ''): TyamlNode;
var
  DT: TDateTime;
  F: Double;
  Tag: AnsiString;
  B: Boolean;
  I, J, Len, DotCount, SignCount, ECount, DigCount, SpaceCount, OtherCount: Integer;
  I64: Int64;
  C: Currency;
begin
  case Scanner.Token of
    tKey:
    begin
      Result := TyamlMapping.Create;
      Result.Parse(Scanner);
    end;

    tScalar:
    begin
      if ATag = '' then
      begin
        if (Scanner.Quoting in [qSingleQuoted, qDoubleQuoted])
            or (Scanner.Style <> sPlain) then
          Result := TyamlString.CreateString(Scanner.Scalar, Scanner.Quoting,
            Scanner.Style)
        else if Scanner.Scalar = '~' then
          Result := TyamlNull.Create
        else begin
          Len := Length(Scanner.Scalar);
          DotCount := 0;
          SignCount := 0;
          DigCount := 0;
          SpaceCount := 0;
          OtherCount := 0;
          ECount := 0;

          for J := 1 to Len do
            case Scanner.Scalar[J] of
              '.': Inc(DotCount);
              '-', '+': Inc(SignCount);
              '0'..'9': Inc(DigCount);
              #32, #9: Inc(SpaceCount);
              'e', 'E': Inc(ECount);
            else
              Inc(OtherCount);
            end;

          if (DigCount > 0)
            and (OtherCount = 0)
            and (ECount = 0)
            and (SignCount <= 1)
            and (DotCount = 0)
            and (SpaceCount = 0)
            and ConvertToInteger(Scanner.Scalar, I) then
            Result := TyamlInteger.CreateInteger(I)
          else if (DigCount > 0)
            and (OtherCount = 0)
            and (ECount = 0)
            and (SignCount <= 1)
            and (DotCount = 0)
            and (SpaceCount = 0)
            and ConvertToInt64(Scanner.Scalar, I64) then
            Result := TyamlInt64.CreateInt64(I64)
          else if (DigCount > 0)
            and (OtherCount = 0)
            and (ECount = 0)
            and (SignCount <= 1)
            and (DotCount <= 1)
            and (SpaceCount = 0)
            and ConvertToCurrency(Scanner.Scalar, C) then
            Result := TyamlCurrency.CreateCurrency(C)
          else if (DigCount > 0)
            and (OtherCount = 0)
            and (ECount = 0)
            and (SignCount = 2)
            and (DotCount = 0)
            and (SpaceCount = 0)
            and ConvertToDate(Scanner.Scalar, DT) then
            Result := TyamlDate.CreateDate(DT)
          else if (DigCount > 0)
            and (OtherCount > 0)
            and (ECount = 0)
            and (SignCount > 0)
            and (DotCount >= 0)
            and (SpaceCount = 0)
            and ConvertToDateTime(Scanner.Scalar, DT) then
            Result := TyamlDateTime.CreateDateTime(DT)
          else if (DigCount > 0)
            and (OtherCount = 0)
            and (ECount <= 1)
            and (SignCount <= 2)
            and (DotCount <= 1)
            and (SpaceCount = 0)
            and ConvertToFloat(Scanner.Scalar, F) then
            Result := TyamlFloat.CreateFloat(F)
          else if (DigCount = 0)
            and (Len <= 5)
            and (Len >= 4)
            and (SignCount = 0)
            and (DotCount = 0)
            and (SpaceCount = 0)
            and ConvertToBoolean(Scanner.Scalar, B) then
            Result := TyamlBoolean.CreateBoolean(B)
          else
            Result := TyamlString.CreateString(Scanner.Scalar, Scanner.Quoting,
              Scanner.Style);
        end;
      end
      else if ATag = '!!str' then
        Result := TyamlString.CreateString(Scanner.Scalar, Scanner.Quoting,
          Scanner.Style)
      else if ATag = '!!int' then
        Result := TyamlInteger.CreateInteger(Scanner.Scalar)
      else if ATag = '!!float' then
        Result := TyamlFloat.CreateFloat(Scanner.Scalar)
      else if ATag = '!!bool' then
        Result := TyamlBoolean.CreateBoolean(Scanner.Scalar)
      else if ATag = '!!timestamp' then
        Result := TyamlDateTime.CreateDateTime(Scanner.Scalar)
      else if ATag = '!!null' then
        Result := TyamlNull.Create
      else if ATag = '!!binary' then
        Result := TyamlBinary.CreateBinary(Scanner.Scalar)
      else  
        raise EyamlSyntaxError.Create('Unknown tag');  

      if ATag <> '!!null' then
        Scanner.GetNextToken;
    end;

    tSequenceStart:
    begin
      Result := TyamlSequence.Create;
      Result.Parse(Scanner);
    end;

    tTag:
    begin
      Tag := Scanner.Tag;
      Scanner.GetNextToken;
      Result := ExtractNode(Scanner, Tag);
      if Result = nil then
        raise EyamlSyntaxError.Create('Invalid tag placement');
    end;
  else
    Result := nil;
  end;

  if Result <> nil then
    Result.Tag := ATag; 
end;

{ TyamlContainer }

function TyamlContainer.Add(Node: TyamlNode): TyamlNode;
begin
  FList.Add(Node);
  Result := Node;
end;

procedure TyamlContainer.AssignTo(Dest: TPersistent);
var
  I: Integer;
  Obj: TyamlNode;
begin
  Assert(Dest is TyamlContainer);
  inherited;
  TyamlContainer(Dest).FList.Clear;
  for I := 0 to FList.Count - 1 do
  begin
    Obj := CyamlNode(FList[I].ClassType).Create;
    Obj.Assign(FList[I] as TyamlNode);
    TyamlContainer(Dest).FList.Add(Obj);
  end;
end;

constructor TyamlContainer.Create;
begin
  inherited Create;
  FList := TObjectList.Create(True);
end;

destructor TyamlContainer.Destroy;
begin
  FList.Free;
  inherited;
end;

function TyamlMapping.FindByName(const AName: AnsiString): TyamlNode;
var
  I, E: Integer;
  S: AnsiString;
begin
  Result := nil;

  E := 1;
  while (E <= Length(AName)) and (AName[E] <> '\') do
    Inc(E);
  S := Copy(AName, 1, E - 1);

  for I := 0 to Count - 1 do
  begin
    if AnsiCompareText((Items[I] as TyamlKeyValue).Key, S) = 0 then
    begin
      if E > Length(AName) then
        Result := (Items[I] as TyamlKeyValue).Value
      else if (Items[I] as TyamlKeyValue).Value is TyamlMapping then
        Result := ((Items[I] as TyamlKeyValue).Value as TyamlMapping).FindByName(
          Copy(AName, E + 1, 65536))
      else
        break;    
    end;
  end;
end;

function TyamlContainer.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TyamlContainer.GetItems(Index: Integer): TyamlNode;
begin
  Result := FList[Index] as TyamlNode;
end;

procedure TyamlContainer.Parse(Scanner: TyamlScanner);
begin
  //
end;

function TyamlMapping.ReadBoolean(const AName: AnsiString;
  const DefValue: Boolean): Boolean;
var
  N: TyamlNode;
begin
  N := FindByName(AName);
  if (N is TyamlScalar) and (not TyamlScalar(N).IsNull) then
    Result := TyamlScalar(N).AsBoolean
  else
    Result := DefValue;
end;

function TyamlMapping.ReadDateTime(const AName: AnsiString;
  const DefValue: TDateTime): TDateTime;
var
  N: TyamlNode;
begin
  N := FindByName(AName);
  if (N is TyamlScalar) and (not TyamlScalar(N).IsNull) then
    Result := TyamlScalar(N).AsDateTime
  else
    Result := DefValue;
end;

function TyamlMapping.ReadInteger(const AName: AnsiString;
  const DefValue: Integer): Integer;
var
  N: TyamlNode;
begin
  N := FindByName(AName);
  if (N is TyamlScalar) and (not TyamlScalar(N).IsNull) then
    Result := TyamlScalar(N).AsInteger
  else
    Result := DefValue;
end;

function TyamlMapping.ReadString(const AName: AnsiString; const AMaxLength: Integer;
  const DefValue: AnsiString): AnsiString;
var
  N: TyamlNode;
begin
  N := FindByName(AName);
  if (N is TyamlScalar) and (not TyamlScalar(N).IsNull) then
    Result := TyamlScalar(N).AsString
  else
    Result := DefValue;
  if (AMaxLength > -1) and (Length(Result) > AMaxLength) then
    SetLength(Result, AMaxLength);
end;

function TyamlMapping.TestString(const AName, AString: AnsiString): Boolean;
begin
  Result := AnsiCompareText(AString, ReadString(AName)) = 0;
end;

{ TyamlParser }

constructor TyamlParser.Create;
begin
  FYAMLStream := TyamlStream.Create;
end;

destructor TyamlParser.Destroy;
begin
  FYAMLStream.Free;
  inherited;
end;

procedure TyamlParser.Parse(AStream: TStream; const AStopKey: AnsiString = '');
var
  Scanner: TyamlScanner;
begin
  Scanner := TyamlScanner.Create(AStream);
  try
    Scanner.StopKey := AStopKey;
    if Scanner.GetNextToken <> tStreamEnd then
      FYAMLStream.Parse(Scanner);
  finally
    Scanner.Free;
  end;
end;

procedure TyamlParser.Parse(const AFileName: AnsiString; out ACharReplace: LongBool; const AStopKey: AnsiString = '';
  const ALimitSize: Integer = 0);
var
  FS: TFileStream;
  SS1251, SSUTF8: TStringStream;
  Limit: Integer;
begin
  SSUTF8 := TStringStream.Create('');
  try
    if FileGetSize(AFileName) < ALimitSize then
      Limit := FileGetSize(AFileName)
    else
      Limit := ALimitSize;

    FS := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyNone);
    try
      SSUTF8.CopyFrom(FS, Limit);
    finally
      FS.Free;
    end;

    SS1251 := TStringStream.Create(
      WideStringToStringEx(DecodeUTF8{UTF8ToWideString}(SSUTF8.DataString), ACharReplace));
  finally
    SSUTF8.Free;
  end;

  Parse(SS1251, AStopKey);
end;

{ TyamlInteger }

constructor TyamlInteger.CreateInteger(const AValue: Integer);
begin
  inherited Create;
  FValue := AValue;
end;

procedure TyamlInteger.AssignTo(Dest: TPersistent);
begin
  Assert(Dest is TyamlInteger);
  inherited;
  TyamlInteger(Dest).FValue := FValue;
end;

constructor TyamlInteger.CreateInteger(const AValue: AnsiString);
begin
  inherited Create;
  if not ConvertToInteger(AValue, FValue) then
    raise EyamlSyntaxError.Create('Not an integer value');
end;

function TyamlInteger.GetAsInteger: Integer;
begin
  Result := FValue;
end;

function TyamlInteger.GetAsString: AnsiString;
begin
  Result := IntToStr(FValue);
end;

function TyamlInteger.GetAsVariant: Variant;
begin
  Result := GetAsInteger;
end;

procedure TyamlInteger.SetAsInteger(const Value: Integer);
begin
  FValue := Value;
end;

procedure TyamlInteger.SetAsString(const Value: AnsiString);
begin
  FValue := StrToInt(Value);
end;

{ TyamlInt64 }

constructor TyamlInt64.CreateInt64(const AValue: Int64);
begin
  inherited Create;
  FValue := AValue;
end;

constructor TyamlInt64.CreateInt64(const AValue: AnsiString);
begin
  inherited Create;
  if not ConvertToInt64(AValue, FValue) then
    raise EyamlSyntaxError.Create('Not an int64 value');
end;

procedure TyamlInt64.SetAsInt64(const Value: Int64);
begin
  FValue := Value;
end;

function TyamlInt64.GetAsInt64: Int64;
begin
  Result := FValue;
end;

function TyamlInt64.GetAsBoolean: Boolean;
begin
  Result := FValue <> 0;
end;

procedure TyamlInt64.SetAsBoolean(const Value: Boolean);
begin
  if Value then
    FValue := 1
  else
    FValue := 0;
end;

procedure TyamlInt64.AssignTo(Dest: TPersistent);
begin
  Assert(Dest is TyamlInt64);
  inherited;
  TyamlInt64(Dest).FValue := FValue;
end;

{ TyamlString }

procedure TyamlString.AssignTo(Dest: TPersistent);
begin
  Assert(Dest is TyamlString);
  inherited;
  TyamlString(Dest).FValue := FValue;
  TyamlString(Dest).FQuoting := FQuoting;
  TyamlString(Dest).FStyle := FStyle;
end;

constructor TyamlString.CreateString(const AValue: AnsiString;
  const AQuoting: TyamlScalarQuoting; const AStyle: TyamlScalarStyle);
begin
  inherited Create;
  if (AValue > '') and (AValue[1] = SpaceSubstitute) then
    FValue := Copy(AValue, 2, MaxInt)
  else
    FValue := AValue; 
  FQuoting := AQuoting;
  FStyle := AStyle;
end;

function TyamlString.GetAsCurrency: Currency;
begin
  if not ConvertToCurrency(FValue, Result) then
    raise Exception.Create('Conversion error');
end;

function TyamlString.GetAsFloat: Double;
begin
  if not ConvertToFloat(FValue, Result) then
    raise Exception.Create('Conversion error');
end;

function TyamlString.GetAsInt64: Int64;
begin
  if not ConvertToInt64(FValue, Result) then
    raise Exception.Create('Conversion error');
end;

function TyamlString.GetAsInteger: Integer;
begin
  Result := StrToInt(AsString);
end;

function TyamlString.GetAsString: AnsiString;
begin
  Result := FValue;
end;

procedure TyamlString.SetAsCurrency(const Value: Currency);
begin
  FValue := CurrToStr(Value);
  if DecimalSeparator <> '.' then
    FValue := StringReplace(FValue, DecimalSeparator, '.', []);
end;

procedure TyamlString.SetAsFloat(const Value: Double);
begin
  FValue := FloatToStr(Value);
  if DecimalSeparator <> '.' then
    FValue := StringReplace(FValue, DecimalSeparator, '.', []);
end;

procedure TyamlString.SetAsInt64(const Value: Int64);
begin
  FValue := IntToStr(Value);
end;

procedure TyamlString.SetAsInteger(const Value: Integer);
begin
  AsString := IntToStr(Value);
end;

procedure TyamlString.SetAsString(const Value: AnsiString);
begin
  FValue := Value;
end;

{ TyamlDateTime }

constructor TyamlDateTime.CreateDateTime(const AValue: TDateTime);
begin
  inherited Create;
  FValue := AValue;
end;

function TyamlDateTime.Compare(ANode: TyamlScalar): Integer;
begin
  if ANode is TyamlDateTime then
  begin
    if Self.AsDateTime < ANode.AsDateTime then
      Result := -1
    else if Self.AsDateTime > ANode.AsDateTime then
      Result := 1
    else
      Result := 0;
  end else
    Result := inherited Compare(ANode);
end;

constructor TyamlDateTime.CreateDateTime(const AValue: AnsiString);
begin
  inherited Create;
  if not ConvertToDateTime(AValue, FValue) then
    raise EyamlSyntaxError.Create('Not a timestamp value');
end;

function TyamlDateTime.GetAsDateTime: TDateTime;
begin
  Result := FValue;
end;

procedure TyamlDateTime.SetAsDateTime(const Value: TDateTime);
begin
  FValue := Value;
end;

function TyamlDateTime.GetAsVariant: Variant;
begin
  Result := GetAsDateTime;
end;

procedure TyamlDateTime.AssignTo(Dest: TPersistent);
begin
  Assert(Dest is TyamlDateTime);
  inherited;
  TyamlDateTime(Dest).FValue := FValue;
end;

{ TyamlDate }

procedure TyamlDate.AssignTo(Dest: TPersistent);
begin
  Assert(Dest is TyamlDate);
  inherited;
  TyamlDate(Dest).FValue := FValue;
end;

function TyamlDate.Compare(ANode: TyamlScalar): Integer;
begin
  if ANode is TyamlDate then
  begin
    if Self.AsDateTime < ANode.AsDateTime then
      Result := -1
    else if Self.AsDateTime > ANode.AsDateTime then
      Result := 1
    else
      Result := 0;
  end else
    Result := inherited Compare(ANode);
end;

constructor TyamlDate.CreateDate(const AValue: TDateTime);
begin
  inherited Create;
  FValue := AValue;
end;

function TyamlDate.GetAsDate: TDateTime;
begin
  Result := FValue;
end;

function TyamlDate.GetAsVariant: Variant;
begin
  Result := GetAsDate;
end;

procedure TyamlDate.SetAsDate(const Value: TDateTime);
begin
  FValue := Value;
end;

{ TyamlFloat }

constructor TyamlFloat.CreateFloat(const AValue: Double);
begin
  inherited Create;
  FValue := AValue;
end;

procedure TyamlFloat.AssignTo(Dest: TPersistent);
begin
  Assert(Dest is TyamlFloat);
  inherited;
  TyamlFloat(Dest).FValue := FValue;
end;

constructor TyamlFloat.CreateFloat(const AValue: AnsiString);
begin
  inherited Create;
  if not ConvertToFloat(AValue, FValue) then
    raise EyamlSyntaxError.Create('Not a float value');
end;

function TyamlFloat.GetAsFloat: Double;
begin
  Result := FValue;
end;

procedure TyamlFloat.SetAsFloat(const Value: Double);
begin
  FValue := Value;
end;

{ TyamlBoolean }

constructor TyamlBoolean.CreateBoolean(const AValue: Boolean);
begin
  inherited Create;
  FValue := AValue;
end;

function TyamlBoolean.Compare(ANode: TyamlScalar): Integer;
begin
  if ANode is TyamlBoolean then
  begin
    if Self.AsBoolean = ANode.AsBoolean then
      Result := 0
    else
      Result := -1;
  end else
    Result := inherited Compare(ANode);
end;

constructor TyamlBoolean.CreateBoolean(const AValue: AnsiString);
begin
  inherited Create;
  if not ConvertToBoolean(AValue, FValue) then
    raise EyamlSyntaxError.Create('Not a boolean value');
end;

function TyamlBoolean.GetAsBoolean: Boolean;
begin
  Result := FValue;
end;

function TyamlBoolean.GetAsInteger: Integer;
begin
  if FValue then
    Result := 1
  else
    Result := 0;
end;

function TyamlBoolean.GetAsString: AnsiString;
begin
  if FValue then
    Result := 'True'
  else
    Result := 'False';
end;

procedure TyamlBoolean.SetAsBoolean(const Value: Boolean);
begin
  FValue := Value;
end;

procedure TyamlBoolean.SetAsInteger(const Value: Integer);
begin
  FValue := Value <> 0;
end;

procedure TyamlBoolean.SetAsString(const Value: AnsiString);
begin
  FValue := Value = 'True';
end;

function TyamlBoolean.GetAsVariant: Variant;
begin
  Result := GetAsBoolean;
end;

procedure TyamlBoolean.AssignTo(Dest: TPersistent);
begin
  Assert(Dest is TyamlBoolean);
  inherited;
  TyamlBoolean(Dest).FValue := FValue;
end;

{ TyamlNull }

function TyamlNull.Compare(ANode: TyamlScalar): Integer;
begin
  Assert(ANode is TyamlScalar);

  if ANode.IsNull then
    Result := 0
  else
    Result := -1;  
end;

function TyamlNull.GetAsString: AnsiString;
begin
  Result := '';
end;

function TyamlNull.GetIsNull: Boolean;
begin
  Result := True;
end;

{ TyamlBinary }

constructor TyamlBinary.CreateBinary(const AValue: AnsiString);
begin
  Create;
  Base64ToBin(AValue);
end;

destructor TyamlBinary.Destroy;
begin
  MS.Free;
  inherited;
end;

function TyamlBinary.GetAsStream: TStream;
begin
  Result := MS;
end;

procedure TyamlBinary.Base64ToBin(const AStr: AnsiString);
var
  SS: TStringStream;
begin
  SS := TStringStream.Create(AStr);
  try
    MimeDecodeStream(SS, MS);
    MS.Position := 0;
  finally
    SS.Free;
  end;
end;

function TyamlBinary.GetAsString: AnsiString;
var
  SS: TStringStream;
begin
  SS := TStringStream.Create('');
  try
    SS.CopyFrom(MS, 0);
    Result := SS.DataString;
  finally
    SS.Free;
  end;
end;

constructor TyamlBinary.Create;
begin
  inherited Create;
  MS := TMemoryStream.Create;
end;

procedure TyamlBinary.AssignTo(Dest: TPersistent);
begin
  Assert(Dest is TyamlBinary);
  inherited;
  TyamlBinary(Dest).MS.CopyFrom(MS, 0);
end;

{ TyamlKeyValue }

destructor TyamlKeyValue.Destroy;
begin
  FValue.Free;
  inherited;
end;

procedure TyamlKeyValue.SetValue(const Value: TyamlNode);
begin
  FValue.Free;
  FValue := Value;
end;

procedure TyamlKeyValue.Parse(Scanner: TyamlScanner);
var
  I: Integer;
begin
  Assert(FValue = nil);
  if Scanner.Token <> tKey then
    raise EyamlSyntaxError.Create('Mapping key expected');
  FKey := Scanner.Key;
  I := Scanner.Indent;
  Scanner.GetNextToken;
  if Scanner.Indent < I then
    FValue := TyamlNull.Create
  else
    FValue := ExtractNode(Scanner);
  if FValue = nil then
    raise EyamlSyntaxError.Create('Invalid mapping value!');
end;

procedure TyamlKeyValue.AssignTo(Dest: TPersistent);
begin
  Assert(Dest is TyamlKeyValue);
  inherited;
  TyamlKeyValue(Dest).FKey := FKey;
  if FValue = nil then
    TyamlKeyValue(Dest).FValue := nil
  else begin
    TyamlKeyValue(Dest).FValue := CyamlNode(FValue.ClassType).Create;
    TyamlKeyValue(Dest).FValue.Assign(FValue);
  end;
end;

{ TyamlDocument }

procedure TyamlDocument.Parse(Scanner: TyamlScanner);
begin
  if Scanner.Token = tDocumentStart then
    Scanner.GetNextToken;

  if Scanner.Token in [tSequenceStart, tKey, tScalar] then
    Add(ExtractNode(Scanner));

  while not (Scanner.Token in [tDocumentEnd, tDocumentStart, tStreamEnd]) do
    Scanner.GetNextToken;

  if Scanner.Token = tDocumentEnd then
    Scanner.GetNextToken;
end;

procedure TyamlSequence.Parse(Scanner: TyamlScanner);
var
  I: Integer;
  N: TyamlNode;
begin
  I := Scanner.Indent;
  while (Scanner.Token = tSequenceStart) and (Scanner.Indent = I) do
  begin
    Scanner.GetNextToken;
    if (Scanner.Indent = I) and (Scanner.Token = tSequenceStart) then
      Add(TyamlNull.Create)
    else begin
      N := ExtractNode(Scanner);
      if N <> nil then
        Add(N);
    end;    
  end;
end;

{ TyamlStream }

procedure TyamlStream.Parse(Scanner: TyamlScanner);
begin
  if Scanner.Token <> tStreamStart then
    raise EyamlSyntaxError.Create('Not at a stream start');
  while Scanner.GetNextToken <> tStreamEnd do
    Add(TyamlDocument.Create).Parse(Scanner);
end;

{ TyamlMapping }

procedure TyamlMapping.Parse(Scanner: TyamlScanner);
var
  I: Integer;
begin
  I := Scanner.Indent;
  while (Scanner.Token = tKey) and (Scanner.Indent = I) do
    Add(TyamlKeyValue.Create).Parse(Scanner);
end;

function TyamlMapping.ReadNull(const AName: AnsiString): Boolean;
begin
  Result := FindByName(AName) is TYAMLNull;
end;

procedure TyamlMapping.ReadStream(const AName: AnsiString; S: TStream);
var
  N: TYAMLNode;
begin
  Assert(S <> nil);
  N := FindByName(AName);
  if N is TyamlBinary then
    S.CopyFrom(TyamlBinary(N).AsStream, 0);
end;

function TyamlMapping.ReadInt64(const AName: AnsiString;
  const DefValue: Int64): Int64;
var
  N: TyamlNode;
begin
  N := FindByName(AName);
  if (N is TyamlScalar) and (not TyamlScalar(N).IsNull) then
    Result := TyamlScalar(N).AsInt64
  else
    Result := DefValue;
end;

function TyamlMapping.ReadCurrency(const AName: AnsiString;
  const DefValue: Currency): Currency;
var
  N: TyamlNode;
begin
  N := FindByName(AName);
  if (N is TyamlScalar) and (not TyamlScalar(N).IsNull) then
    Result := TyamlScalar(N).AsCurrency
  else
    Result := DefValue;
end;

function TyamlMapping.ReadFloat(const AName: AnsiString;
  const DefValue: Double): Double;
var
  N: TyamlNode;
begin
  N := FindByName(AName);
  if (N is TyamlScalar) and (not TyamlScalar(N).IsNull) then
    Result := TyamlScalar(N).AsFloat
  else
    Result := DefValue;
end;

function TyamlMapping.ReadValue(const AName: AnsiString;
  const DefValue: Variant): Variant;
var
  N: TyamlNode;
begin
  N := FindByName(AName);
  if (N is TyamlScalar) and (not TyamlScalar(N).IsNull) then
    Result := TyamlScalar(N).AsVariant
  else
    Result := DefValue;
end;

{ TyamlCurrency }

constructor TyamlCurrency.CreateCurrency(const AValue: Currency);
begin
  inherited Create;
  FValue := AValue;
end;

procedure TyamlCurrency.AssignTo(Dest: TPersistent);
begin
  Assert(Dest is TyamlCurrency);
  inherited;
  TyamlCurrency(Dest).FValue := FValue;
end;

constructor TyamlCurrency.CreateCurrency(const AValue: AnsiString);
begin
  inherited Create;
  if not ConvertToCurrency(AValue, FValue) then
    raise EyamlSyntaxError.Create('Not a currency value');
end;

function TyamlCurrency.GetAsCurrency: Currency;
begin
  Result := FValue;
end;

function TyamlCurrency.GetAsVariant: Variant;
begin
  Result := GetAsCurrency;
end;

procedure TyamlCurrency.SetAsCurrency(const AValue: Currency);
begin
  FValue := AValue;
end;

{ TyamlNumeric }

function TyamlNumeric.Compare(ANode: TyamlScalar): Integer;
begin
  if ANode is TyamlNumeric then
  begin
    if Self.AsFloat < ANode.AsFloat then
      Result := -1
    else if Self.AsFloat > ANode.AsFloat then
      Result := 1
    else
      Result := 0;
  end else
    Result := inherited Compare(ANode);
end;

function TyamlNumeric.GetAsVariant: Variant;
begin
  Result := GetAsFloat;
end;

end.