
unit yaml_parser;

interface

uses
  Classes, ContNrs, yaml_common, yaml_scanner;

type
  TyamlNode = class(TObject)
  private
    FIndent: Integer;
    FTag: AnsiString;

  protected
    function ExtractNode(Scanner: TyamlScanner): TyamlNode;

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
    procedure SetAsDate(const Value: TDateTime); virtual;
    procedure SetAsDateTime(const Value: TDateTime); virtual;
    procedure SetAsFloat(const Value: Double); virtual;
    procedure SetAsInteger(const Value: Integer); virtual;
    procedure SetAsString(const Value: AnsiString); virtual;
    procedure SetAsBoolean(const Value: Boolean); virtual;

  public
    procedure Parse(Scanner: TyamlScanner); override;

    property AsString: AnsiString read GetAsString write SetAsString;
    property AsInteger: Integer read GetAsInteger write SetAsInteger;
    property AsFloat: Double read GetAsFloat write SetAsFloat;
    property AsDate: TDateTime read GetAsDate write SetAsDate;
    property AsDateTime: TDateTime read GetAsDateTime write SetAsDateTime;
    property AsBoolean: Boolean read GetAsBoolean write SetAsBoolean;
    property IsNull: Boolean read GetIsNull;
  end;

  TyamlString = class(TyamlScalar)
  private
    FValue: AnsiString;
    FQuoting: TyamlScalarQuoting;
    FStyle: TyamlScalarStyle;

  protected
    function GetAsString: AnsiString; override;
    function GetAsInteger: Integer; override;
    procedure SetAsString(const Value: AnsiString); override;
    procedure SetAsInteger(const Value: Integer); override;

  public
    constructor CreateString(const AValue: AnsiString; const AQuoting: TyamlScalarQuoting;
      const AStyle: TyamlScalarStyle);

    property Quoting: TyamlScalarQuoting read FQuoting write FQuoting;
    property Style: TyamlScalarStyle read FStyle write FStyle;
  end;

  TyamlInteger = class(TyamlScalar)
  private
    FValue: Integer;

  protected
    function GetAsInteger: Integer; override;
    procedure SetAsInteger(const Value: Integer); override;

  public
    constructor CreateInteger(const AValue: Integer);
  end;

  TyamlDateTime = class(TyamlScalar)
  private
    FValue: TDateTime;

  protected
    function GetAsDateTime: TDateTime; override;
    procedure SetAsDateTime(const Value: TDateTime); override;

  public
    constructor CreateDateTime(const AValue: TDateTime);
  end;

  TyamlDate = class(TyamlScalar)
  private
    FValue: TDateTime;

  protected
    function GetAsDate: TDateTime; override;
    procedure SetAsDate(const Value: TDateTime); override;

  public
    constructor CreateDate(const AValue: TDateTime);
  end;

  TyamlFloat = class(TyamlScalar)
  private
    FValue: Double;

  protected
    function GetAsFloat: Double; override;
    procedure SetAsFloat(const Value: Double); override;

  public
    constructor CreateFloat(const AValue: Double);
  end;

  TyamlBoolean = class(TyamlScalar)
  private
    FValue: Boolean;

  protected
    function GetAsBoolean: Boolean; override;
    procedure SetAsBoolean(const Value: Boolean); override;

  public
    constructor CreateBoolean(const AValue: Boolean);
  end;

  TyamlNull = class(TyamlScalar)
  protected
    function GetIsNull: Boolean; override;
  end;

  TyamlContainer = class(TyamlNode)
  private
    FList: TObjectList;

    function GetItems(Index: Integer): TyamlNode;
    function GetCount: Integer;

  public
    constructor Create; override;
    destructor Destroy; override;

    procedure Parse(Scanner: TyamlScanner); override;
    function Add(Node: TyamlNode): TyamlNode;
    function FindByName(const AName: String): TyamlNode;
    function ReadString(const AName: String; const DefValue: String = ''): String;
    function ReadInteger(const AName: String; const DefValue: Integer = 0): Integer;
    function ReadDateTime(const AName: String; const DefValue: TDateTime = 0): TDateTime;
    function ReadBoolean(const AName: String; const DefValue: Boolean = False): Boolean;
    function TestString(const AName: String; const AString: String): Boolean;

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

  TyamlMapping = class(TyamlNode)
  private
    FKey: AnsiString;
    FValue: TyamlNode;

    procedure SetValue(const Value: TyamlNode);

  public
    destructor Destroy; override;

    procedure Parse(Scanner: TyamlScanner); override;

    property Key: AnsiString read FKey write FKey;
    property Value: TyamlNode read FValue write SetValue;
  end;

  TyamlSequence = class(TyamlContainer)
  public
    procedure Parse(Scanner: TyamlScanner); override;
  end;

  TyamlParser = class(TObject)
  private
    FYAMLStream: TyamlStream;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Parse(AStream: TStream);

    property YAMLStream: TyamlStream read FYAMLStream;
  end;

implementation

uses
  SysUtils;

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
  P: Integer;
  MS: AnsiString;
begin
  Result := False;
  P := Length(S);
  if (P >= 8) and (S[3] = ':') and (S[6] = ':') then
  begin
    while (P >= 1) and (S[P] <> 'Z') do
      Dec(P);
    if P >= 9 then
    begin
      try
        MS := Copy(S, 10, P - 10);
        if Length(MS) = 1 then
          MS := MS + '00'
        else if Length(MS) = 2 then
          MS := MS + '0'
        else if Length(MS) > 3 then
          SetLength(MS, 3);
        DT := EncodeTime(
          StrToIntDef(Copy(S, 1, 2), -1),
          StrToIntDef(Copy(S, 4, 2), -1),
          StrToIntDef(Copy(S, 7, 2), -1),
          StrToIntDef(MS, 0));
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

function ConvertToFloat(S: AnsiString; out F: Double): Boolean;
var
  I: Integer;
begin
  for I := 1 to Length(S) do
    if S[I] in ['.', ','] then
      S[I] := DecimalSeparator;
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
  Result := AsInteger;
end;

function TyamlScalar.GetAsInteger: Integer;
begin
  raise EyamlException.Create('Data type is not supported.');
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
  AsFloat := Value;
end;

procedure TyamlScalar.SetAsString(const Value: AnsiString);
begin
  raise EyamlException.Create('Data type is not supported.');
end;

{ TyamlNode }

constructor TyamlNode.Create;
begin
  FIndent := 0;
end;

function TyamlNode.ExtractNode(Scanner: TyamlScanner): TyamlNode;
var
  DT: TDateTime;
  F: Double;
  Tag: AnsiString;
  B: Boolean;
begin
  case Scanner.Token of
    tKey:
    begin
      Result := TyamlMapping.Create;
      Result.Parse(Scanner);
    end;

    tScalar:
    begin
      if (Scanner.Quoting in [qSingleQuoted, qDoubleQuoted])
          or (Scanner.Style <> sPlain) then
        Result := TyamlString.CreateString(Scanner.Scalar, Scanner.Quoting,
          Scanner.Style)
      else if ConvertToDateTime(Scanner.Scalar, DT) then
        Result := TyamlDateTime.CreateDateTime(DT)
      else if ConvertToDate(Scanner.Scalar, DT) then
        Result := TyamlDate.CreateDate(DT)
      else if StrToIntDef(Scanner.Scalar, MAXINT) <> MAXINT then
        Result := TyamlInteger.CreateInteger(StrToInt(Scanner.Scalar))
      else if ConvertToFloat(Scanner.Scalar, F) then
        Result := TyamlFloat.CreateFloat(F)
      else if ConvertToBoolean(Scanner.Scalar, B) then
        Result := TyamlBoolean.CreateBoolean(B)
      else if Scanner.Scalar = '~' then
        Result := TyamlNull.Create
      else
        Result := TyamlString.CreateString(Scanner.Scalar, Scanner.Quoting,
          Scanner.Style);
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
      Result := ExtractNode(Scanner);
      if Result = nil then
        raise EyamlSyntaxError.Create('Syntax error')
      else
        Result.Tag := Tag;  
    end;
  else
    Result := nil;
  end;
end;

{ TyamlContainer }

function TyamlContainer.Add(Node: TyamlNode): TyamlNode;
begin
  FList.Add(Node);
  Result := Node;
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

function TyamlContainer.FindByName(const AName: String): TyamlNode;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if (Items[I] is TyamlMapping) and
      (AnsiCompareText((Items[I] as TyamlMapping).Key, AName) = 0) then
    begin
      Result := (Items[I] as TyamlMapping).Value;
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
var
  N: TyamlNode;
  Indent: Integer;
begin
  Indent := Scanner.Indent;
  while Scanner.Token <> tStreamEnd do
  begin
    if Scanner.Indent < Indent then
      break;

    N := ExtractNode(Scanner);
    if N <> nil then
      Add(N)
    else
      break;

    if (N = nil) or (N is TyamlScalar) then
      Scanner.GetNextToken;
  end;
end;

function TyamlContainer.ReadBoolean(const AName: String;
  const DefValue: Boolean): Boolean;
var
  N: TyamlNode;
begin
  N := FindByName(AName);
  if N is TyamlScalar then
    Result := TyamlScalar(N).AsBoolean
  else
    Result := DefValue;
end;

function TyamlContainer.ReadDateTime(const AName: String;
  const DefValue: TDateTime): TDateTime;
var
  N: TyamlNode;
begin
  N := FindByName(AName);
  if N is TyamlScalar then
    Result := TyamlScalar(N).AsDateTime
  else
    Result := DefValue;
end;

function TyamlContainer.ReadInteger(const AName: String;
  const DefValue: Integer): Integer;
var
  N: TyamlNode;
begin
  N := FindByName(AName);
  if N is TyamlScalar then
    Result := TyamlScalar(N).AsInteger
  else
    Result := DefValue;
end;

function TyamlContainer.ReadString(const AName, DefValue: String): String;
var
  N: TyamlNode;
begin
  N := FindByName(AName);
  if N is TyamlScalar then
    Result := TyamlScalar(N).AsString
  else
    Result := DefValue;
end;

function TyamlContainer.TestString(const AName, AString: String): Boolean;
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

procedure TyamlParser.Parse(AStream: TStream);
var
  Scanner: TyamlScanner;
begin
  Scanner := TyamlScanner.Create(AStream);
  try
    if not Scanner.EOF then
    begin
      Scanner.GetNextToken;
      if Scanner.Token = tStreamStart then
        FYAMLStream.Parse(Scanner);
    end;
  finally
    Scanner.Free;
  end;
end;

{ TyamlInteger }

constructor TyamlInteger.CreateInteger(const AValue: Integer);
begin
  inherited Create;
  FValue := AValue;
end;

function TyamlInteger.GetAsInteger: Integer;
begin
  Result := FValue;
end;

procedure TyamlInteger.SetAsInteger(const Value: Integer);
begin
  FValue := Value;
end;

{ TyamlString }

constructor TyamlString.CreateString(const AValue: AnsiString;
  const AQuoting: TyamlScalarQuoting; const AStyle: TyamlScalarStyle);
begin
  inherited Create;
  FValue := AValue;
  FQuoting := AQuoting;
  FStyle := AStyle;
end;

function TyamlString.GetAsInteger: Integer;
begin
  Result := StrToInt(AsString);
end;

function TyamlString.GetAsString: AnsiString;
begin
  Result := FValue;
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

function TyamlDateTime.GetAsDateTime: TDateTime;
begin
  Result := FValue;
end;

procedure TyamlDateTime.SetAsDateTime(const Value: TDateTime);
begin
  FValue := Value;
end;

{ TyamlDate }

constructor TyamlDate.CreateDate(const AValue: TDateTime);
begin
  inherited Create;
  FValue := AValue;
end;

function TyamlDate.GetAsDate: TDateTime;
begin
  Result := FValue;
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

function TyamlBoolean.GetAsBoolean: Boolean;
begin
  Result := FValue;
end;

procedure TyamlBoolean.SetAsBoolean(const Value: Boolean);
begin
  FValue := Value;
end;

{ TyamlNull }

function TyamlNull.GetIsNull: Boolean;
begin
  Result := True;
end;

{ TyamlMapping }

destructor TyamlMapping.Destroy;
begin
  FValue.Free;
  inherited;
end;

procedure TyamlMapping.SetValue(const Value: TyamlNode);
begin
  FValue.Free;
  FValue := Value;
end;

procedure TyamlMapping.Parse(Scanner: TyamlScanner); 
begin
  Assert(FValue = nil);
  if Scanner.Token <> tKey then
    raise EyamlSyntaxError.Create('Invalid token!');
  FKey := Scanner.Key;
  Scanner.GetNextToken;
  FValue := ExtractNode(Scanner);
  if FValue = nil then
    raise EyamlSyntaxError.Create('Invalid token!');
  Scanner.GetNextToken;
end;

{ TyamlDocument }

procedure TyamlDocument.Parse(Scanner: TyamlScanner);
var
  N: TyamlNode;
begin
  if Scanner.Token = tDocumentStart then
    Scanner.GetNextToken;

  while Scanner.Token <> tStreamEnd do
  begin
    case Scanner.Token of
      tDocumentStart:
        break;

      tDocumentEnd:
      begin
        Scanner.GetNextToken;
        break;
      end;

    else
      N := ExtractNode(Scanner);
      if N <> nil then
        Add(N);
      if (N = nil) or (N is TyamlScalar) then
        Scanner.GetNextToken;
    end;
  end;
end;

procedure TyamlSequence.Parse(Scanner: TyamlScanner);
begin
  while Scanner.Token = tSequenceStart do
  begin
    Scanner.GetNextToken;
    Add(TyamlContainer.Create).Parse(Scanner);
  end;
end;

{ TyamlStream }

procedure TyamlStream.Parse(Scanner: TyamlScanner);
begin
  if Scanner.Token <> tStreamStart then
    raise EyamlSyntaxError.Create('Syntax error');
  Scanner.GetNextToken;  
  while not Scanner.EOF do
    Add(TyamlDocument.Create).Parse(Scanner);
end;

end.