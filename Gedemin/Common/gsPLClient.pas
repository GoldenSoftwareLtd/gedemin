// ShlTanya, 24.02.2019

unit gsPLClient;

interface

uses
  Windows, Classes, SysUtils, IBDatabase, IBSQL, IBHeader, dbclient, DB,
  gdcBase, PLHeader, PLIntf, gdcBaseInterface;

type
  TgsPL = class(TObject)
  private
    FCount: Integer;
    FInitArgv: array of PChar;
    FIsInitialised: Boolean;
    FError: Boolean;
    function GetDefaultPLInitString: String;

  public
    constructor Create;
    destructor Destroy; override;

    property Count: Integer read FCount write FCount;
    property Error: Boolean read FError write FError;

    function Initialise(const AParams: String = ''): Boolean;
    function IsInitialised: Boolean;
    function Cleanup: Boolean;
  end;

type
  TgsPLTermv = class(TObject)
  private
    FTerm: term_t;
    FSize: LongWord;

    function GetDataType(const Idx: LongWord): Integer;
    function GetTerm(const Idx: LongWord): term_t;

  public
    constructor CreateTermv(const ASize: Integer);

    procedure PutInteger(const Idx: LongWord; const AValue: Integer);
    procedure PutString(const Idx: LongWord; const AValue: String);
    procedure PutFloat(const Idx: LongWord; const AValue: Double);
    procedure PutDateTime(const Idx: LongWord; const AValue: TDateTime);
    procedure PutDate(const Idx: LongWord; const AValue: TDateTime);
    procedure PutInt64(const Idx: LongWord; const AValue: Int64);
    procedure PutAtom(const Idx: LongWord; const AValue: String);
    procedure PutVariable(const Idx: LongWord);

    function ReadInteger(const Idx: LongWord): Integer;
    function ReadString(const Idx: LongWord): String;
    function ReadFloat(const Idx: LongWord): Double;
    function ReadDateTime(const Idx: LongWord): TDateTime;
    function ReadDate(const Idx: LongWord): TDateTime;
    function ReadInt64(const Idx: LongWord): Int64;
    function ReadAtom(const Idx: LongWord): String;
    function ToString(const Idx: LongWord): String;
    function ToTrimQuotesString(const Idx: LongWord): String;
    procedure Reset;

    property DataType[const Idx: LongWord]: Integer read GetDataType;
    property Term[const Idx: LongWord]: term_t read GetTerm;
    property Size: LongWord read FSize;
  end;

  TgsPLQuery = class(TObject)
  private
    FQid: qid_t;
    FEof: Boolean;
    FTermv: TgsPLTermv;
    FPredicateName: String;

    function GetEof: Boolean;

  public
    constructor Create;
    destructor Destroy; override;

    procedure OpenQuery;
    procedure Close;
    procedure Cut;
    procedure NextSolution;

    property Eof: Boolean read GetEof;
    property PredicateName: String read FPredicateName write FPredicateName;
    property Termv: TgsPLTermv read FTermv write FTermv;
  end;

  TgsPLClient = class(TObject)
  private
    FIsInitialised: Boolean;
    FDebug: Boolean;
    function GetArity(ASql: TIBSQL): Integer; overload;
    function GetArity(ADataSet: TDataSet; const AFieldList: String): Integer; overload;
    function GetFileName(const AFileName: String): String;

    procedure WriteTermv(ATerm: TgsPLTermv; AStream: TStream);
    procedure WriteScript(const AText: String; AStream: TStream);
    procedure WritePredicate(const APredicateName: String; ATermv: TgsPLTermv; AStream: TStream);

    function InternalMakePredicatesOfDataSet(ADataSet: TDataSet; const AFieldList: String;
      const APredicateName: String; const AStream: TStream = nil): Integer;
    function InternalMakePredicatesOfSQLSelect(const ASQL: String; ATr: TIBTransaction;
      const APredicateName: String; const AStream: TStream = nil): Integer;

    function GetScriptIDByName(const Name: String): TID;
  public
    constructor Create;
    destructor Destroy; override;

    function Call(const APredicateName: String; AParams: TgsPLTermv): Boolean;
    function Call2(const AGoal: String): Boolean;
    procedure Compound(AGoal: term_t; const AFunctor: String; ATermv: TgsPLTermv);
    function Initialise(const AParams: String = ''): Boolean;
    function IsInitialised: Boolean;
    function Cleanup: Boolean;
    function MakePredicatesOfSQLSelect(const ASQL: String; ATr: TIBTransaction;
      const APredicateName: String; const AFileName: String; const AnAppend: Boolean = False): Integer;
    function MakePredicatesOfDataSet(ADataSet: TDataSet; const AFieldList: String;
      const APredicateName: String; const AFileName: String; const AnAppend: Boolean = False): Integer;
    procedure ExtractData(ADataSet: TClientDataSet; const APredicateName: String; ATermv: TgsPLTermv);
    procedure SavePredicatesToFile(const APredicateName: String; ATermv: TgsPLTermv; const AFileName: String);

    function LoadScript(AScriptID: TID): Boolean;
    function LoadScriptByName(const AScriptName: String): Boolean;

    property Debug: Boolean read FDebug write FDebug;
  end;

  EgsPLClientException = class(Exception)
  public
    constructor CreateTypeError(const AnExpected: String; const AnActual: String);
    constructor CreatePLError(const AnExpected: String);
  end;

  function TermToString(ATerm: term_t): String;

var
  gsPL: TgsPL;

implementation

uses
  jclStrings, gd_GlobalParams_unit, Forms, rp_report_const,
  FileCtrl;

constructor EgsPLClientException.CreatePLError(const AnExpected: String);
begin
  gsPL.Error := True;
  Message := AnExpected;
end;

constructor EgsPLClientException.CreateTypeError(const AnExpected: String; const AnActual: String);
begin
  gsPL.Error := True;
  Message := 'error(type_error(' + AnExpected + ',' + AnActual + '))';
end;

procedure RaisePrologError;
var
  ex: term_t;
begin
  ex := PL_exception(0);
  if ex <> 0 then
    begin
      raise EgsPLClientException.CreatePLError(TermToString(ex));
    end;
end;

constructor TgsPLTermv.CreateTermv(const ASize: Integer);
begin
  if not gsPL.Count > 0 then
    raise  EgsPLClientException.CreatePLError('Prolog �� ���������������!');
  if ASize <= 0 then
    raise  EgsPLClientException.CreatePLError('�������� ������ ������� ������!');

  inherited Create;

  FTerm := PL_new_term_refs(ASize);
  FSize := ASize;
end;

function TgsPLTermv.GetTerm(const Idx: LongWord): term_t;
begin
  if Idx >= Size then
    raise  EgsPLClientException.CreatePLError('���������� ������� ������� ������!');

  Result := FTerm + Idx;
end;

function TgsPLTermv.ToString(const Idx: LongWord): String;
begin
  Result := TermToString(GetTerm(Idx));
end;

function TgsPLTermv.ToTrimQuotesString(const Idx: LongWord): String;
begin
  Result := StrTrimQuotes(ToString(Idx))
end;

procedure TgsPLTermv.Reset;
var
  I: Integer;
begin
  for I := 0 to FSize - 1 do
    PutVariable(I);
end;

procedure TgsPLTermv.PutInteger(const Idx: LongWord; const AValue: Integer);
begin
  PL_put_integer(GetTerm(Idx), AValue);
end;

procedure TgsPLTermv.PutString(const Idx: LongWord; const AValue: String);
begin
  PL_put_string_chars(GetTerm(Idx), PChar(AValue));
end;

procedure TgsPLTermv.PutFloat(const Idx: LongWord; const AValue: Double);
begin
  PL_put_float(GetTerm(Idx), AValue);
end;

procedure TgsPLTermv.PutDateTime(const Idx: LongWord; const AValue: TDateTime);
begin
  PL_put_atom_chars(GetTerm(Idx), PChar(FormatDateTime('yyyy-mm-dd hh:nn:ss', AValue)));
end;

procedure TgsPLTermv.PutDate(const Idx: LongWord; const AValue: TDateTime);
begin
  PL_put_atom_chars(GetTerm(Idx), PChar(FormatDateTime('yyyy-mm-dd', AValue)));
end;

procedure TgsPLTermv.PutInt64(const Idx: LongWord; const AValue: Int64);
begin
  PL_put_int64(GetTerm(Idx), AValue);
end;

procedure TgsPLTermv.PutAtom(const Idx: LongWord; const AValue: String);
begin
  PL_put_atom_chars(GetTerm(Idx), PChar(AValue));
end;

procedure TgsPLTermv.PutVariable(const Idx: LongWord);
begin
  PL_put_variable(GetTerm(Idx));
end;

function TgsPLTermv.ReadInteger(const Idx: LongWord): Integer;
begin
  if PL_get_integer(GetTerm(Idx), Result) = 0 then
    raise EgsPLClientException.CreateTypeError('integer', TermToString(GetTerm(Idx)));
end;

function TgsPLTermv.ReadString(const Idx: LongWord): String;
var
  len: Cardinal;
  S: PChar;
begin
  case GetDataType(Idx) of
    PL_ATOM:
      if PL_get_atom_chars(GetTerm(Idx), S) <> 0 then
        Result := S
      else if PL_get_chars(GetTerm(Idx), S, PL_ATOM or REP_MB) <> 0 then
        Result := S
      else
        raise EgsPLClientException.CreateTypeError('atom', TermToString(GetTerm(Idx)));
    PL_STRING:
      if PL_get_string(GetTerm(Idx), S, len) <> 0 then
        Result := S
      else if PL_get_chars(GetTerm(Idx), S, CVT_STRING or REP_MB) <> 0 then
        Result := S
      else
        raise EgsPLClientException.CreateTypeError('string', TermToString(GetTerm(Idx)));
  end;
end;

function TgsPLTermv.ReadFloat(const Idx: LongWord): Double;
begin
  if PL_get_float(GetTerm(Idx), Result) = 0 then
    raise EgsPLClientException.CreateTypeError('float', TermToString(GetTerm(Idx)));
end;

function TgsPLTermv.ReadDateTime(const Idx: LongWord): TDateTime;
var
  S: String;
begin
  S := ReadString(Idx);
  try
    Result := VarToDateTime(S);
  except
    on E:Exception do
      raise EgsPLClientException.CreateTypeError('datetime', TermToString(GetTerm(Idx)));
  end;
end;

function TgsPLTermv.ReadAtom(const Idx: LongWord): String;
begin
  Result := ReadString(Idx);
end;

function TgsPLTermv.ReadDate(const Idx: LongWord): TDateTime;
begin
  Result := ReadDateTime(Idx);
end;

function TgsPLTermv.ReadInt64(const Idx: LongWord): Int64;
begin
  if PL_get_int64(GetTerm(Idx), Result) = 0 then
    raise EgsPLClientException.CreateTypeError('int64', TermToString(GetTerm(Idx)));
end;

function TgsPLTermv.GetDataType(const Idx: LongWord): Integer;
begin
  if Idx >= Size then
    raise  EgsPLClientException.CreatePLError('���������� ������� ������� ������!');

  Result := PL_term_type(GetTerm(Idx));
end;

constructor TgsPLQuery.Create;
begin
  if not gsPL.Count > 0 then
    raise  EgsPLClientException.CreatePLError('Prolog �� ���������������!');

  inherited Create;

  FQid := 0;
  FEOF := False;
end;

destructor TgsPLQuery.Destroy;
begin
  if FQid <> 0 then
    Cut;

  inherited;
end;

function TgsPLQuery.GetEof: Boolean;
begin
  Result := FEof or (FQid = 0);
end;

procedure TgsPLQuery.OpenQuery;
var
  p: predicate_t;
begin
  p := PL_predicate(PChar(FPredicateName), FTermv.Size, 'user');
  FQid := PL_open_query(nil, PL_Q_CATCH_EXCEPTION, p, FTermv.Term[0]);

  if FQid = 0 then RaisePrologError;

  NextSolution;
end;

procedure TgsPLQuery.Close;
begin
  try
    PL_close_query(FQid);
  finally
    FQid := 0;
    FEof := False;
  end;
end;

procedure TgsPLQuery.Cut;
begin
  try
    PL_cut_query(FQid);
  finally
    FQid := 0;
    FEof := False;
  end;
end;

procedure TgsPLQuery.NextSolution;
var
  ex: term_t;
begin
  if not FEof then
  begin
    FEof := PL_next_solution(FQid) = 0;
    if FEof then
    begin
      ex := PL_exception(FQid);
      if ex <> 0 then
        begin
          raise EgsPLClientException.CreatePLError(TermToString(ex));
        end;
    end;
  end;  
end; 

constructor TgsPLClient.Create;
begin
  inherited Create;

  FIsInitialised := False;
end;

destructor TgsPLClient.Destroy;
begin
  gsPL.Count := gsPL.Count - 1;

  if not (gsPL.Count > 0) or gsPL.Error then
    gsPL.Cleanup;

  inherited;
end;

procedure TgsPLClient.SavePredicatesToFile(const APredicateName: String; ATermv: TgsPLTermv; const AFileName: String);
var
  Query: TgsPLQuery;
  FS: TFileStream;
begin
  if not gsPL.Count > 0 then
    raise  EgsPLClientException.CreatePLError('Prolog �� ���������������!');

  if APredicateName = '' then
    raise  EgsPLClientException.CreatePLError('�� ������ ��� ���������!');
  if ATermv = nil then
    raise  EgsPLClientException.CreatePLError('�� ����� ������ ������!');

  FS := TFileStream.Create(GetFileName(AFileName), fmCreate);
  Query := TgsPLQuery.Create;
  try
    Query.PredicateName := APredicateName;
    Query.Termv := ATermv;
    Query.OpenQuery;
    while not Query.Eof do
    begin
      WritePredicate(APredicateName, Query.Termv, FS);
      Query.NextSolution;
    end;
  finally
    Query.Free;
    FS.Free;
  end;
end;

procedure TgsPLClient.ExtractData(ADataSet: TClientDataSet; const APredicateName: String; ATermv: TgsPLTermv);
var
  Query: TgsPLQuery;
  I: LongWord;
  F: TField;
begin
  if not gsPL.Count > 0 then
    raise  EgsPLClientException.CreatePLError('Prolog �� ���������������!');
  if ADataSet = nil then
    raise  EgsPLClientException.CreatePLError('�� ����� ����� ������!');
  if APredicateName = '' then
    raise  EgsPLClientException.CreatePLError('�� ������ ��� ���������!');
  if ATermv = nil then
    raise  EgsPLClientException.CreatePLError('�� ����� ������ ������!');

  Query := TgsPLQuery.Create;
  try
    Query.PredicateName := APredicateName;
    Query.Termv := ATermv;
    Query.OpenQuery;
    while not Query.Eof do
    begin
      ADataSet.Insert;
      try
        for I := 0 to ADataSet.Fields.Count - 1 do
        begin
          F := ADataSet.Fields[I];
          case F.DataType of
            ftSmallint, ftInteger, ftBoolean: F.AsInteger := Query.Termv.ReadInteger(I);
            ftCurrency, ftBCD: F.AsCurrency := Query.Termv.ReadFloat(I);
            ftFloat: F.AsFloat := Query.Termv.ReadFloat(I);
            ftLargeInt: (F as TLargeIntField).AsLargeInt := Query.Termv.ReadInt64(I);
            ftTime, ftDateTime: F.AsDateTime := Query.Termv.ReadDateTime(I);
            ftDate: F.AsDateTime := Query.Termv.ReadDate(I);
            ftString: F.AsString := Query.Termv.ReadString(I);
          else
            raise  EgsPLClientException.CreatePLError('������ ���� ������!');
          end;
        end;
        ADataSet.Post;
      finally
        if ADataSet.State in dsEditModes then
          ADataSet.Cancel;
      end;
      Query.NextSolution;
    end;
    Query.Close;
  finally
    Query.Free; 
  end;
end;

function TgsPLClient.LoadScript(AScriptID: TID): Boolean;

  procedure LoadUsesScript(const S: String);
  const
    IncludePrefix = '%#INCLUDE ';
    LengthInc = Length(IncludePrefix);
    LimitChar = [' ', ',', ';', #13, #10];
  var
    I, ID, P: Integer;
    SN: String;
  begin
    P := StrSearch(IncludePrefix, S, 1);
    while P > 0 do
    begin
      P := P + LengthInc;
      while (P <= Length(S)) and (S[P] in LimitChar) do
        Inc(P);

      I := P;
      while (P <= Length(S)) and not (S[P] in LimitChar) do
        Inc(P);

      SN := Copy(S, I, P - I);
      ID := GetScriptIDByName(SN);

      if ID > -1 then
        LoadScript(ID)
      else
        raise  EgsPLClientException.CreatePLError('������ ''' + SN + ''' �� ������ � ����!');

      P := StrSearch(IncludePrefix, S, P);
    end;
  end;

var
  q: TIBSQL;
  Termv: TgsPLTermv;
  FS: TFileStream;
begin
  if not gsPL.Count > 0 then
    raise  EgsPLClientException.CreatePLError('Prolog �� ���������������!');

  Result := False;
  q := TIBSQL.Create(nil);
  Termv := TgsPLTermv.CreateTermv(2);
  try
    q.Transaction := gdcBaseManager.ReadTransaction;
    q.SQL.Text := 'SELECT * FROM gd_function WHERE id = :id';
    SetTID(q.ParamByName('id'), AScriptID);
    q.ExecQuery;

    if not q.Eof then
    begin 
      LoadUsesScript(q.FieldByName('script').AsString);

      Termv.PutString(0, q.FieldByName('name').AsString);
      Termv.PutString(1, q.FieldByName('script').AsString);
      Result := Call('load_atom', Termv);

      if Result and FDebug then
      begin
        FS := TFileStream.Create(GetFileName(q.FieldByName('name').AsString), fmCreate);
        try
          WriteScript(q.FieldByName('script').AsString, FS);
        finally
          FS.Free;
        end;
      end;
    end;
  finally
    q.Free;
    TermV.Free;    
  end;
end;

function TgsPLClient.LoadScriptByName(const AScriptName: String): Boolean;
begin
  Result := LoadScript(GetScriptIDByName(AScriptName));
end;

function TgsPLClient.Call2(const AGoal: String): Boolean;
var
  Termv: TgsPLTermv;
  Query: TgsPLQuery;
  fid: fid_t;
begin
  if not gsPL.Count > 0 then
    raise  EgsPLClientException.CreatePLError('Prolog �� ���������������!');
  if AGoal = '' then
    raise  EgsPLClientException.CreatePLError('�� ����� ���� ��� ����������!');

  fid := PL_open_foreign_frame();
  Termv := TgsPLTermv.CreateTermv(1);
  try
    Termv.PutAtom(0, AGoal);
    Query := TgsPLQuery.Create;
    try
      Query.PredicateName := 'pl_run';
      Query.Termv := Termv;
      Query.OpenQuery;
      Result := not Query.Eof;
    finally
      Query.Free;
    end;
  finally
    Termv.Free;
    PL_discard_foreign_frame(fid);
  end;
end;

function TgsPLClient.Call(const APredicateName: String; AParams: TgsPLTermv): Boolean;
var
  Query: TgsPLQuery;
begin
  if not gsPL.Count > 0 then
    raise  EgsPLClientException.CreatePLError('Prolog �� ���������������!');
  if APredicateName = '' then
    raise  EgsPLClientException.CreatePLError('�� ������ ��� ���������!');
  if AParams = nil then
    raise  EgsPLClientException.CreatePLError('�� ����� ������ ������!');

  Query := TgsPLQuery.Create;
  try
    Query.PredicateName := APredicateName;
    Query.Termv := AParams;
    Query.OpenQuery; 
    Result := not Query.Eof;
  finally
    Query.Free;
  end;
end;

procedure TgsPLClient.Compound(AGoal: term_t; const AFunctor: String; ATermv: TgsPLTermv);
begin
  if not gsPL.Count > 0 then
    raise  EgsPLClientException.CreatePLError('Prolog �� ���������������!');
  if AFunctor = '' then
    raise  EgsPLClientException.CreatePLError('�� ����� �������!');
  if ATermv = nil then
    raise  EgsPLClientException.CreatePLError('�� ����� ������ ������!');

  if PL_cons_functor_v(AGoal,
    PL_new_functor(PL_new_atom(PChar(AFunctor)), ATermv.size),
    ATermv.Term[0]) = 0
  then
    RaisePrologError;
end;

function TermToString(ATerm: term_t): String;
var
  len: Cardinal;
  S: PChar;
begin
  Result := '';

  if ATerm = 0 then
    raise  EgsPLClientException.CreatePLError('�� ����� ����!');

  case PL_term_type(ATerm) of
    PL_STRING:
      if PL_get_string(ATerm, S, len) <> 0 then
        Result := '"' + S + '"'
      else if PL_get_chars(ATerm, S, CVT_STRING or REP_MB) <> 0 then
        Result := '"' + S + '"'
      else
        raise  EgsPLClientException.CreatePLError('������ ����������� ������!');
    else
      if PL_get_chars(ATerm, S, CVT_WRITEQ) <> 0 then
        Result := S
      else if PL_get_chars(ATerm, S, CVT_WRITEQ or REP_MB) <> 0 then
        Result := S
      else
        raise  EgsPLClientException.CreatePLError('������ ����������� ����� � ������!');
  end;
end;

function TgsPLClient.GetArity(ASql: TIBSQL): Integer;
var
  I: Integer;
begin
  if ASql = nil then
    raise  EgsPLClientException.CreatePLError('�� ����� ������ TIBSQL!');

  Result := 0;

  for I := 0 to ASQL.Current.Count - 1 do
  begin
    case ASQL.Fields[I].SQLType of
      SQL_DOUBLE, SQL_FLOAT, SQL_LONG, SQL_SHORT,
      SQL_TIMESTAMP, SQL_D_FLOAT, SQL_TYPE_TIME,
      SQL_TYPE_DATE, SQL_INT64, SQL_Text, SQL_VARYING: Inc(Result);
    end;
  end;
end;

function TgsPLClient.GetFileName(const AFileName: String): String;
var
  TempS: String;
begin
  TempS := GetSWIPath;
  if not DirectoryExists(TempS) then
    if not CreateDir(TempS) then
      raise  EgsPLClientException.CreatePLError('�� ������� ������� ���������� ''' + TempS + '''');
  TempS := GetSWITempPath;
  if not DirectoryExists(TempS) then
    if not CreateDir(TempS) then
      raise  EgsPLClientException.CreatePLError('�� ������� ������� ���������� ''' + TempS + '''');
  Result := TempS + '\' + AFileName + '.pl';
end; 

function TgsPLClient.GetArity(ADataSet: TDataSet; const AFieldList: String): Integer;
var
  I: Integer;
begin
  if ADataSet = nil then
    raise  EgsPLClientException.CreatePLError('�� ����� ����� ������!');

  Result := 0;

  for I := 0 to ADataSet.Fields.Count - 1 do
  begin
    if (StrIPos(',' + ADataSet.Fields[I].FieldName + ',', ',' + AFieldList + ',') > 0)
      or (AFieldList = '') then
    begin
      case ADataSet.Fields[I].DataType of
        ftString, ftSmallint, ftInteger, ftWord,
        ftBoolean, ftFloat, ftCurrency, ftDate, ftTime, ftDateTime,
        ftMemo, ftLargeint: Inc(Result);
      end;
    end;
  end;
end;

function TgsPLClient.Cleanup: Boolean;
begin
  Result := gsPL.Cleanup;

  FIsInitialised := False;
end;

function TgsPLClient.IsInitialised: Boolean;
begin
  Result := FIsInitialised;
end;

function TgsPLClient.Initialise(const AParams: String = ''): Boolean;
begin
  if not FIsInitialised then
    FIsInitialised := gsPL.Initialise(AParams);

  Result := FIsInitialised;
end;

procedure TgsPLClient.WriteTermv(ATerm: TgsPLTermv; AStream: TStream);
var
  TempS: String;
begin
  if AStream <> nil then
  begin
    TempS := TermToString(ATerm.Term[0]) + '.'#13#10;
    AStream.WriteBuffer(TempS[1], Length(TempS));
  end;
end;

procedure TgsPLClient.WriteScript(const AText: String; AStream: TStream);
var
  TempS: String;
begin
  if AStream <> nil then
  begin
    TempS := AText;
    AStream.WriteBuffer(TempS[1], Length(TempS));
  end;
end;

procedure TgsPLClient.WritePredicate(const APredicateName: String; ATermv: TgsPLTermv; AStream: TStream);

  function GetString(Termv: TgsPLTermv): String;
  var
    I: Integer;
  begin
    Result := '';
    for I := 0 to Termv.Size - 1 do
      Result := Result + Termv.ToString(I) + ',';

    if Result > '' then
      Setlength(Result, Length(Result) - 1);
  end;
  
var
  TempS: String;
begin
  TempS := APredicateName + '(' + GetString(ATermv) + ').'#13#10;
  AStream.WriteBuffer(TempS[1], Length(TempS));
end;

function TgsPLClient.InternalMakePredicatesOfSQLSelect(const ASQL: String; ATr: TIBTransaction;
  const APredicateName: String; const AStream: TStream = nil): Integer;
var
  q: TIBSQL;
  Refs, Term: TgsPLTermv;
  I: LongWord;
  Arity: Integer;
begin
  Result := 0;
  
  Assert(ATr <> nil);
  Assert(ATr.InTransaction); 

  q := TIBSQL.Create(nil);
  try
    q.Transaction := ATr;
    q.SQL.Text := ASQL;
    q.ExecQuery;

    Arity := GetArity(q);
    if Arity > 0 then
    begin
      Refs := TgsPLTermv.CreateTermv(Arity);
      Term := TgsPLTermv.CreateTermv(1);
      try
        while not q.Eof do
        begin
          for I := 0 to q.Current.Count - 1 do
          begin
            case q.Fields[I].SQLType of
              SQL_LONG, SQL_SHORT:
                if q.Fields[I].AsXSQLVAR.sqlscale = 0 then
                  Refs.PutInteger(I, q.Fields[I].AsInteger)
                else
                  Refs.PutFloat(I, q.Fields[I].AsCurrency);
              SQL_FLOAT, SQL_D_FLOAT, SQL_DOUBLE:
                Refs.PutFloat(I, q.Fields[I].AsFloat);
              SQL_INT64:
                if q.Fields[I].AsXSQLVAR.sqlscale = 0 then
                  Refs.PutInt64(I, q.Fields[I].AsInt64)
                else
                  Refs.PutFloat(I, q.Fields[I].AsCurrency);
              SQL_TYPE_DATE:
                Refs.PutDate(I, q.Fields[I].AsDate);
              SQL_TIMESTAMP, SQL_TYPE_TIME:
                Refs.PutDateTime(I, q.Fields[I].AsDateTime);
              SQL_TEXT, SQL_VARYING:
                Refs.PutString(I, q.Fields[I].AsTrimString);
            end;
          end;
          Compound(Term.Term[0], APredicateName, Refs);
          if Call('pl_assert', Term) then
          begin
            if AStream <> nil then
              WriteTermv(Term, AStream);
            Inc(Result);
          end
          else
            raise  EgsPLClientException.CreatePLError('� �������� ���������� ������ ''' +
              Term.ToString(0) + ''' �������� ������!');
          q.Next;
        end;
      finally
        Refs.Free;
        Term.Free;
      end;
    end;
  finally
    q.Free;
  end;
end;

function TgsPLClient.InternalMakePredicatesOfDataSet(ADataSet: TDataSet; const AFieldList: String;
  const APredicateName: String; const AStream: TStream = nil): Integer;
var
  I, Arity, Idx: Integer;
  Refs, Term: TgsPLTermv;
begin
  Result := 0;
  Assert(ADataSet <> nil);
  Assert(APredicateName > '');
  
  Arity := GetArity(ADataSet, AFieldList);
  Refs := TgsPLTermv.CreateTermv(Arity);
  Term := TgsPLTermv.CreateTermv(1);
  try
    ADataSet.First;
    while not ADataSet.Eof do
    begin
      Idx := 0;
      for I := 0 to ADataSet.Fields.Count - 1 do
      begin
        if (StrIPos(',' + ADataSet.Fields[I].FieldName + ',', ',' + AFieldList + ',') > 0)
          or (AFieldList = '') then
        begin
          case ADataSet.Fields[I].DataType of
            ftSmallint, ftInteger, ftWord, ftBoolean:
              Refs.PutInteger(Idx, ADataSet.Fields[I].AsInteger);
            ftLargeint: Refs.PutInt64(Idx, TLargeintField(ADataSet.Fields[I]).AsLargeInt);
            ftFloat: Refs.PutFloat(Idx, ADataSet.Fields[I].AsFloat);
            ftCurrency: Refs.PutFloat(Idx, ADataSet.Fields[I].AsCurrency);
            ftString, ftMemo: Refs.PutString(Idx, ADataSet.Fields[I].AsString);
            ftDate: Refs.PutDate(Idx, ADataSet.Fields[I].AsDateTime);
            ftDateTime, ftTime: Refs.PutDateTime(Idx, ADataSet.Fields[I].AsDateTime);
          end;
          Inc(Idx);
        end;
      end;
      Compound(Term.Term[0], APredicateName, Refs);
      if Call('pl_assert', Term) then
      begin
        if AStream <> nil then
          WriteTermv(Term, AStream);
        Inc(Result);
      end else
        raise  EgsPLClientException.CreatePLError('� �������� ���������� ������ ''' +
          Term.ToString(0) + ''' �������� ������!');
      ADataSet.Next;
    end;
  finally
    Refs.Free;
    Term.Free;
  end;
end;

function TgsPLClient.MakePredicatesOfDataSet(ADataSet: TDataSet; const AFieldList: String;
  const APredicateName: String; const AFileName: String; const AnAppend: Boolean = False): Integer;
var
  FS: TFileStream;
  FN: String;
begin
  if not gsPL.Count > 0 then
    raise  EgsPLClientException.CreatePLError('Prolog �� ���������������!');

  if FDebug then
  begin
    FN := GetFileName(AFileName);
    if AnAppend and FileExists(FN) then
    begin
      FS := TFileStream.Create(FN, fmOpenReadWrite);
      FS.Seek(0, soFromEnd);
    end else
      FS := TFileStream.Create(FN, fmCreate);
    try
      Result := InternalMakePredicatesOfDataSet(ADataSet, AFieldList, APredicateName, FS);
    finally
      FS.Free;
    end;
  end else
    Result := InternalMakePredicatesOfDataSet(ADataSet, AFieldList, APredicateName, nil); 
end;

function TgsPLClient.MakePredicatesOfSQLSelect(const ASQL: String; ATr: TIBTransaction;
  const APredicateName: String; const AFileName: String; const AnAppend: Boolean = False): Integer;
var
  FN: String;
  FS: TFileStream;
begin
  if not gsPL.Count > 0 then
    raise  EgsPLClientException.CreatePLError('Prolog �� ���������������!');

  if FDebug then
  begin
    FN := GetFileName(AFileName);
    if AnAppend and FileExists(FN) then
    begin
      FS := TFileStream.Create(FN, fmOpenReadWrite);
      FS.Seek(0, soFromEnd);
    end else
      FS := TFileStream.Create(FN, fmCreate);
    try
      Result := InternalMakePredicatesOfSQLSelect(ASQL, ATr, APredicateName, FS);
    finally
      FS.Free;
    end;
  end else
    Result := InternalMakePredicatesOfSQLSelect(ASQL, ATr, APredicateName, nil);
end;

function TgsPLClient.GetScriptIDByName(const Name: String): TID;
  var
    q: TIBSQL;
begin
    Result := -1;

    if Name > '' then
    begin
      q := TIBSQL.Create(nil);
      try
        q.Transaction := gdcBaseManager.ReadTransaction;
        q.SQL.Text := 'SELECT * FROM gd_function ' +
          'WHERE UPPER(name) = UPPER(:name) AND module = :module';
        q.ParamByName('name').AsString := Name;
        q.ParamByName('module').AsString := scrPrologModuleName;
        q.ExecQuery;

        if not q.Eof then
          Result := GetTID(q.FieldByName('id'));
      finally
        q.Free;
      end;
    end;
end;

constructor TgsPL.Create;
begin
  inherited Create;

  FCount := 0;
  FIsInitialised := False;
  FError := False;
end;

destructor TgsPL.Destroy;
begin
  inherited;
end;

function TgsPL.Cleanup: Boolean;
begin
  if not IsInitialised then
    Result := False
  else
    Result := PL_cleanup(0) <> 0;

  FreePLLibrary;
  FreePLDependentLibraries;

  FCount := 0;
  FIsInitialised := False;
  FError := False;
end;

function TgsPL.IsInitialised: Boolean;
var
  argc: Integer;
begin
  argc := High(FInitArgv);
  Result := (argc > -1) and TryPLLoad;

  if Result then
    Result := PL_is_initialised(argc, FInitArgv) <> 0;
end;

function TgsPL.Initialise(const AParams: String = ''): Boolean;

  function GetNextElement(const S: String; var L: Integer): String;
  var
    F: Integer;
  begin
    F := L;
    while (F <= Length(S)) and (S[F] <> '!') and (S[F + 1] <> '@') do
      Inc(F);

    Result := Trim(Copy(S, L, F - L));
    Inc(F, 2);
    L := F;
  end;

  procedure GetParamsList(const S: String; SL: TStringList);
  var
    P: Integer;
  begin
    P := 1;
    while P <= Length(S) do
      SL.Add(GetNextElement(S, P));
  end;

var
  SL: TStringList;
  I: Integer;
  TempS: String;
begin
  if FError then
    Cleanup;

  if not TryPLLoad then
    raise  EgsPLClientException.CreatePLError('���������� ����� Prolog �� �����������!');

  if FCount > 0 then
    begin
      FCount := FCount + 1;
      Result := True;
      Exit;
    end;

  if AParams > '' then
    TempS := Trim(AParams)
  else
    TempS := GetDefaultPLInitString;

  TempS := StringReplace(TempS, '],[', '!@', [rfReplaceAll]);
  TempS := Copy(TempS, 2, Length(TempS) - 2);

  SL := TStringList.Create;
  try
    GetParamsList(TempS, SL);

    SetLength(FInitArgv, SL.Count + 1);
    for I := 0 to SL.Count - 1 do
      FInitArgv[I] := PChar(SL[I]);
    FInitArgv[High(FInitArgv)] := nil;

    if not IsInitialised then
      begin
        Result := PL_initialise(High(FInitArgv), FInitArgv) <> 0;
        if Result then
          begin
            FCount := 1;
            FIsInitialised := True;
          end
        else
          Cleanup;
      end
    else
      Result := False;
  finally
    SL.Free;
  end;
end;

function TgsPL.GetDefaultPLInitString: String;
var
  Path: String;
begin
  Path := StringReplace(GetPath, '\', '/', [rfReplaceAll]);
  Result := Format('[%1:s],[-x],[%0:s%2:s],[-p],[foreign=%0:s%3:s]', [Path, Libswipl_dll, Gd_pl_state, Foreign_lib]);
end;

initialization
  gsPL := TgsPL.Create;

finalization
  FreeAndNil(gsPL);

end.
