
unit yaml_parser;

interface

uses
  Classes, ContNrs, yaml_common, yaml_scanner;

type
  TyamlNode = class(TObject)
  private
    FIndent: Integer;

    function GetIndent: Integer;
    procedure SetIndent(const Value: Integer);

  public
    constructor Create; virtual;

    property Indent: Integer read GetIndent write SetIndent;
  end;

  TyamlContainer = class(TyamlNode)
  private
    FList: TObjectList;

    function GetItems(Index: Integer): TyamlNode;
    function GetCount: Integer;

  public
    constructor Create; override;
    destructor Destroy; override;

    function Add(Node: TyamlNode): Integer;

    property Items[Index: Integer]: TyamlNode read GetItems; default;
    property Count: Integer read GetCount;
  end;

  TyamlScalar = class(TyamlNode)
  private
    function GetAsDate: TDateTime; virtual;
    function GetAsDateTime: TDateTime; virtual;
    function GetAsFloat: Double; virtual;
    function GetAsInteger: Integer; virtual;
    function GetAsString: AnsiString; virtual;
    function GetIsNull: Boolean; virtual;
    procedure SetAsDate(const Value: TDateTime); virtual;
    procedure SetAsDateTime(const Value: TDateTime); virtual;
    procedure SetAsFloat(const Value: Double); virtual;
    procedure SetAsInteger(const Value: Integer); virtual;
    procedure SetAsString(const Value: AnsiString); virtual;
    procedure SetIsNull(const Value: Boolean); virtual;

  public
    property AsString: AnsiString read GetAsString write SetAsString;
    property AsInteger: Integer read GetAsInteger write SetAsInteger;
    property AsFloat: Double read GetAsFloat write SetAsFloat;
    property Date: TDateTime read GetAsDate write SetAsDate;
    property DateTime: TDateTime read GetAsDateTime write SetAsDateTime;
    property IsNull: Boolean read GetIsNull write SetIsNull;
  end;

  TyamlString = class(TyamlScalar)
  private
    FValue: AnsiString;
    FQuoting: TyamlScalarQuoting;
    FStyle: TyamlScalarStyle;

    function GetAsString: AnsiString; override;
    procedure SetAsString(const Value: AnsiString); override;

  public
    constructor CreateString(const AValue: AnsiString; const AQuoting: TyamlScalarQuoting;
      const AStyle: TyamlScalarStyle);

    property Quoting: TyamlScalarQuoting read FQuoting write FQuoting;
    property Style: TyamlScalarStyle read FStyle write FStyle;
  end;

  TyamlInteger = class(TyamlScalar)
  private
    FValue: Integer;

    function GetAsInteger: Integer; override;
    procedure SetAsInteger(const Value: Integer); override;
  end;

  TyamlDocument = class(TyamlContainer)
  end;

  TyamlMapping = class(TyamlNode)
  end;

  TyamlSequence = class(TyamlContainer)
  end;

  TyamlParser = class(TObject)
  private
    FYAMLStream: TyamlContainer;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Parse(AStream: TStream);

    property YAMLStream: TyamlContainer read FYAMLStream;
  end;

implementation

{ TyamlScalar }

function TyamlScalar.GetAsDate: TDateTime;
begin
  raise EyamlException.Create('Data type is not supported.');
end;

function TyamlScalar.GetAsDateTime: TDateTime;
begin
  raise EyamlException.Create('Data type is not supported.');
end;

function TyamlScalar.GetAsFloat: Double;
begin
  raise EyamlException.Create('Data type is not supported.');
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
  raise EyamlException.Create('Data type is not supported.');
end;

procedure TyamlScalar.SetAsDate(const Value: TDateTime);
begin
  raise EyamlException.Create('Data type is not supported.');
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
  raise EyamlException.Create('Data type is not supported.');
end;

procedure TyamlScalar.SetAsString(const Value: AnsiString);
begin
  raise EyamlException.Create('Data type is not supported.');
end;

procedure TyamlScalar.SetIsNull(const Value: Boolean);
begin
  raise EyamlException.Create('Data type is not supported.');
end;

{ TyamlNode }

constructor TyamlNode.Create;
begin
  FIndent := 0;
end;

function TyamlNode.GetIndent: Integer;
begin
  Result := FIndent;
end;

procedure TyamlNode.SetIndent(const Value: Integer);
begin
  FIndent := Value;
end;

{ TyamlContainer }

function TyamlContainer.Add(Node: TyamlNode): Integer;
begin
  Result := FList.Add(Node);
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

function TyamlContainer.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TyamlContainer.GetItems(Index: Integer): TyamlNode;
begin
  Result := FList[Index] as TyamlNode;
end;

{ TyamlParser }

constructor TyamlParser.Create;
begin
  FYAMLStream := TyamlContainer.Create;
end;

destructor TyamlParser.Destroy;
begin
  FYAMLStream.Free;
  inherited;
end;

procedure TyamlParser.Parse(AStream: TStream);
var
  Scanner: TyamlScanner;
  Token: TyamlToken;
  Doc: TyamlDocument;
begin
  Doc := nil;
  Scanner := TyamlScanner.Create(AStream);
  try
    Token := Scanner.GetNextToken;
    while Token <> tStreamEnd do
    begin
      case Token of
        tDocumentStart:
        begin
          Doc := TyamlDocument.Create;
          FYAMLStream.Add(Doc);
        end;

        tDocumentEnd:
        begin
          Doc := nil;
        end;

        tKey: ;

        tScalar:
        begin
          if Doc = nil then
            raise EyamlSyntaxError.Create('Syntax error');

          if (Scanner.Quoting in [qSingleQuoted, qDoubleQuoted])
            or (Scanner.Style <> sPlain) then
          begin
            Doc.Add(TyamlString.CreateString(Scanner.Scalar, Scanner.Quoting,
              Scanner.Style));
          end;
        end;

        tSequenceStart: ;
        tTag: ;
      end;

      Token := Scanner.GetNextToken;
    end;
  finally
    Scanner.Free;
  end;
end;

{ TyamlInteger }

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

function TyamlString.GetAsString: AnsiString;
begin
  Result := FValue;
end;

procedure TyamlString.SetAsString(const Value: AnsiString);
begin
  FValue := Value;
end;

end.