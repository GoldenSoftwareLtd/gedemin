
unit tx_textdatabase;

interface

uses
  Classes, Contnrs;

// tdb -- text database

type
  TtdbField = class(TObject)
  private
    FName: String;
    FValue: String;

    function GetAsString: String;
    procedure SetAsString(const Value: String);
    function GetAsDate: TDateTime;
    procedure SetAsDate(const Value: TDateTime);
    function GetAsInteger: Integer;
    procedure SetAsInteger(const Value: Integer);

  public
    constructor Create(const AName: String; const AValue: String = '');

    property Name: String read FName write FName;
    property AsString: String read GetAsString write SetAsString;
    property AsDate: TDateTime read GetAsDate write SetAsDate;
    property AsInteger: Integer read GetAsInteger write SetAsInteger;
  end;

  TtdbTable = class(TObject)
  private
    FFieldDefs: array of String;
    FData: array of array of String;
    FRecNo: Integer;

    function GetRecNo: Integer;
    function GetRecordCount: Integer;
    procedure SetRecNo(const Value: Integer);
    function GetFieldCount: Integer;

  public
    constructor Create;
    destructor Destroy; override;

    // стварае пустую табл≥цу дадзенай структуры
    procedure CreateTable(AFields: array of String);
    // в€ртае парадкавы нумар пол€.  ал≥ такое не ≥снуе --
    // выкл≥кае выключэньне
    function GetFieldIndex(const AFieldName: String): Integer;
    // в€ртае ≥м€ пол€ па €гонаму ≥ндэксу
    function GetFieldName(const Index: Integer): String;
    // дадае новы зап≥с у канец табл≥цы. –об≥ць €го б€гучым
    procedure Append;
    //
    procedure First;
    //
    procedure Next;
    //
    function EOF: Boolean;

    // в€ртае значэньне дадзенага пол€
    function GetFieldByName(const AFieldName: String): String;
    // устанашл≥вае значэньне дадзенага пол€
    procedure SetFieldByName(const AFieldName, AValue: String);

    // колькасць зап≥саҐ у табл≥цы
    property RecordCount: Integer read GetRecordCount;
    // нумар б€гучага зап≥су
    property RecNo: Integer read GetRecNo write SetRecNo;
    // колькасць палЄҐ у табл≥цы
    property FieldCount: Integer read GetFieldCount;
  end;

  TtdbArea = class(TObject)
  private
    FName: String;
    FFields: TObjectList;
    FTable: TtdbTable;

    function GetFields(Index: Integer): TtdbField;
    function GetFieldCount: Integer;

  public
    constructor Create;
    destructor Destroy; override;

    function AddField(F: TtdbField): Integer;
    procedure AddTable(T: TtdbTable);
    function FieldByName(const AFieldName: String): TtdbField;

    property Name: String read FName write FName;
    property FieldCount: Integer read GetFieldCount;
    property Fields[Index: Integer]: TtdbField read GetFields;
    property Table: TtdbTable read FTable;
  end;

  TtdbFile = class(TObject)
  private
    FAreas: TObjectList;

    function GetAreas(Index: Integer): TtdbArea;
    function GetAreasCount: Integer;

  public
    constructor Create;
    destructor Destroy; override;

    function Add(AnArea: TtdbArea): Integer;

    property Areas[Index: Integer]: TtdbArea read GetAreas;
    property AreasCount: Integer read GetAreasCount;
  end;

implementation

uses
  SysUtils;

{ TtdbFile }

function TtdbFile.Add(AnArea: TtdbArea): Integer;
begin
  Result := FAreas.Add(AnArea);
end;

constructor TtdbFile.Create;
begin
  inherited;
  FAreas := TObjectList.Create;
end;

destructor TtdbFile.Destroy;
begin
  inherited;
  FAreas.Free;
end;

function TtdbFile.GetAreas(Index: Integer): TtdbArea;
begin
  Result := FAreas[Index] as TtdbArea;
end;

function TtdbFile.GetAreasCount: Integer;
begin
  Result := FAreas.Count;
end;

{ TtdbArea }

function TtdbArea.AddField(F: TtdbField): Integer;
begin
  Result := FFields.Add(F);
end;

procedure TtdbArea.AddTable(T: TtdbTable);
begin
  Assert(FTable = nil);
  FTable := T;
end;

constructor TtdbArea.Create;
begin
  inherited;
  FFields := TObjectList.Create;
end;

destructor TtdbArea.Destroy;
begin
  inherited;
  FFields.Free;
end;

function TtdbArea.FieldByName(const AFieldName: String): TtdbField;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FieldCount - 1 do
    if AnsiCompareText(Fields[I].Name, AFieldName) = 0 then
    begin
      Result := Fields[I];
      exit;
    end;
end;

function TtdbArea.GetFieldCount: Integer;
begin
  Result := FFields.Count;
end;

function TtdbArea.GetFields(Index: Integer): TtdbField;
begin
  Result := FFields[Index] as TtdbField;
end;

{ TtdbField }

constructor TtdbField.Create(const AName: String; const AValue: String = '');
begin
  inherited Create;
  FName := AName;
  FValue := AValue;
end;

function TtdbField.GetAsDate: TDateTime;
begin
  Result := StrToDate(FValue);
end;

function TtdbField.GetAsInteger: Integer;
begin
  Result := StrToInt(FValue);
end;

function TtdbField.GetAsString: String;
begin
  Result := FValue;
end;

procedure TtdbField.SetAsDate(const Value: TDateTime);
begin
  FValue := DateToStr(Value);
end;

procedure TtdbField.SetAsInteger(const Value: Integer);
begin
  FValue := IntToStr(Value);
end;

procedure TtdbField.SetAsString(const Value: String);
begin
  FValue := Value;
end;

{ TtdbTable }

procedure TtdbTable.Append;
var
  I: Integer;
begin
  I := RecordCount + 1;
  SetLength(FData, I);
  SetLength(FData[I - 1], FieldCount);
  FRecNo := I - 1;
end;

constructor TtdbTable.Create;
begin
  inherited Create;
  SetLength(FFieldDefs, 0);
  SetLength(FData, 0);
  FRecNo := 0;
end;

procedure TtdbTable.CreateTable(AFields: array of String);
var
  I: Integer;
begin
  Assert(FieldCount = 0);
  SetLength(FFieldDefs, High(AFields) + 1);
  for I := Low(AFields) to High(AFields) do
  begin
    FFieldDefs[I] := AnsiUpperCase(AFields[I]);
  end;
end;

destructor TtdbTable.Destroy;
begin
  inherited;
  Finalize(FData);
  Finalize(FFieldDefs);
end;

function TtdbTable.EOF: Boolean;
begin
  Result := (FData = nil) or (FRecNo > High(FData));
end;

procedure TtdbTable.First;
begin
  RecNo := 0;
end;

function TtdbTable.GetFieldByName(const AFieldName: String): String;
begin
  Assert(not EOF);
  Result := FData[FRecNo, GetFieldIndex(AFieldName)];
end;

function TtdbTable.GetFieldCount: Integer;
begin
  if FFieldDefs <> nil then
    Result := High(FFieldDefs) + 1
  else
    Result := 0;
end;

function TtdbTable.GetFieldIndex(const AFieldName: String): Integer;
begin
  for Result := 0 to FieldCount - 1 do
    if AnsiCompareText(AFieldName, FFieldDefs[Result]) = 0 then
    begin
      exit;
    end;
  raise Exception.Create('Invalid field name');
end;

function TtdbTable.GetFieldName(const Index: Integer): String;
begin
  Result := FFieldDefs[Index];
end;

function TtdbTable.GetRecNo: Integer;
begin
  Assert(not EOF);
  Assert(RecordCount > 0);
  Result := FRecNo;
end;

function TtdbTable.GetRecordCount: Integer;
begin
  if FData <> nil then
    Result := High(FData) + 1
  else
    Result := 0;
end;

procedure TtdbTable.Next;
begin
  if not EOF then
    FRecNo := FRecNo + 1
  else
    raise Exception.Create('EOF reached');  
end;

procedure TtdbTable.SetFieldByName(const AFieldName, AValue: String);
begin
  Assert(not EOF);
  FData[FRecNo, GetFieldIndex(AFieldName)] := AValue;
end;

procedure TtdbTable.SetRecNo(const Value: Integer);
begin
  Assert(Value >= 0);
  Assert(Value < RecordCount);
  FRecNo := Value;
end;

end.
