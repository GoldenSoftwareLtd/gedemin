unit gsPLClient;

interface

uses
  Windows, Classes, SysUtils, IBDatabase, IBSQL, IBHeader, dbclient, DB,
  gdcBase, PLHeader, PLIntf;

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
    FPred: String;
    FDeleteDataAfterClose: Boolean;

    function GetEof: Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    procedure OpenQuery;
    procedure Close;
    procedure NextSolution;

    property Eof: Boolean read GetEof;
    property Pred: String read FPred write FPred;
    property Termv: TgsPLTermv read FTermv write FTermv;
    property DeleteDataAfterClose: Boolean read FDeleteDataAfterClose write FDeleteDataAfterClose;
  end;

  TgsPLClient = class(TObject)
  private
    FInitArgv: array of PChar;
    FDebug: Boolean;
    
    function GetArity(ASql: TIBSQL): Integer; overload;
    function GetArity(ADataSet: TDataSet; const AFieldList: String): Integer; overload;
    function GetTempPath: String;  
  public
    destructor Destroy; override;
     
    function Call(const APredicateName: String; AParams: TgsPLTermv): Boolean;
    function Call2(const AGoal: String): Boolean;
    procedure Compound(AGoal: term_t; const AFunctor: String; ATermv: TgsPLTermv);
    function Initialise(const AParams: String = InitParams): Boolean;
    function IsInitialised: Boolean;
    procedure MakePredicatesOfSQLSelect(const ASQL: String; ATr: TIBTransaction;
      const APredicateName: String; const AFileName: String);
    procedure MakePredicatesOfDataSet(ADataSet: TDataSet; const AFieldList: String; const APredicateName: String; const AFileName: String);
    procedure MakePredicatesOfObject(const AClassName: String; const ASubType: String; const ASubSet: String;
      AParams: Variant; AnExtraConditions: TStringList; const AFieldList: String; ATr: TIBTransaction;
      const APredicateName: String; const AFileName: String);
    procedure ExtractData(ADataSet: TClientDataSet; const APredicateName: String; ATermv: TgsPLTermv);

    property Debug: Boolean read FDebug write FDebug;
  end;

  EgsPLClientException = class(Exception)
  public
    constructor CreateTypeError(const AnExpected: String; const AnActual: term_t);
    constructor CreatePLError(AnException: term_t);
  end;

  function TermToString(ATerm: term_t): String;

implementation

uses
  jclStrings, gd_GlobalParams_unit;

constructor EgsPLClientException.CreateTypeError(const AnExpected: String; const AnActual: term_t);
begin
  Message := 'error(type_error(' + AnExpected + ',' + TermToString(AnActual) + '))';
end;

constructor EgsPLClientException.CreatePLError(AnException: term_t);
var
  a: term_t;
  name: atom_t;
  arity: Integer;
begin
  a := PL_new_term_ref;
  if (PL_get_arg(1, AnException, a) <> 0)
    and (PL_get_name_arity(a, name, arity) <> 0)
  then
    Message := PL_atom_chars(name); 
end;

procedure RaisePrologError;
var
  ex: term_t;  
begin
  ex := PL_exception(0);
  if ex <> 0 then
    raise EgsPLClientException.CreatePLError(ex);
end;

constructor TgsPLTermv.CreateTermv(const ASize: Integer);
begin
  inherited Create;

  FTerm := PL_new_term_refs(ASize);
  FSize := ASize;
end;

function TgsPLTermv.GetTerm(const Idx: LongWord): term_t;
begin
  if Idx >= Size then
    raise EgsPLClientException.Create('Invalid index!');

  Result := FTerm + Idx;
end;

function TgsPLTermv.ToString(const Idx: LongWord): String;
begin
  Result := TermToString(GetTerm(Idx));
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
    raise EgsPLClientException.CreateTypeError('integer', GetTerm(Idx));
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
      else
        raise EgsPLClientException.CreateTypeError('atom', GetTerm(Idx));
    PL_STRING:
      if PL_get_string(GetTerm(Idx), S, len) <> 0 then
        Result := S
      else  
        raise EgsPLClientException.CreateTypeError('string', GetTerm(Idx));
  end;
end;

function TgsPLTermv.ReadFloat(const Idx: LongWord): Double;
begin
  if PL_get_float(GetTerm(Idx), Result) = 0 then
    raise EgsPLClientException.CreateTypeError('float', GetTerm(Idx));
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
      raise EgsPLClientException.CreateTypeError('datetime', GetTerm(Idx));
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
    raise EgsPLClientException.CreateTypeError('int64', GetTerm(Idx));
end; 

function TgsPLTermv.GetDataType(const Idx: LongWord): Integer;
begin
  if Idx >= Size then
    raise EgsPLClientException.Create('Invalid index!');

  Result := PL_term_type(GetTerm(Idx));
end;

constructor TgsPLQuery.Create;
begin
  inherited Create;

  FQid := 0;
  FEOF := False;
  FDeleteDataAfterClose := False;
end;

destructor TgsPLQuery.Destroy;
begin
  Close;

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
  p := PL_predicate(PChar(FPred), FTermv.Size, 'user');
  FQid := PL_open_query(nil, PL_Q_CATCH_EXCEPTION, p, FTermv.Term[0]);

  if FQid = 0 then RaisePrologError;

  NextSolution;
end;

procedure TgsPLQuery.Close;
begin
  try
    if FDeleteDataAfterClose then
      PL_close_query(FQid)
    else
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
        raise EgsPLClientException.CreatePLError(ex);
    end; 
  end;  
end; 

destructor TgsPLClient.Destroy;
begin
  if IsInitialised then
    PL_cleanup(0);
    
  inherited;
end;  

procedure TgsPLClient.ExtractData(ADataSet: TClientDataSet; const APredicateName: String; ATermv: TgsPLTermv);
var
  Query: TgsPLQuery;
  I: LongWord;
  F: TField;
begin
  Assert(ADataSet <> nil);
  Assert(ATermv <> nil);  

  Query := TgsPLQuery.Create;
  try
    Query.Pred := APredicateName;
    Query.Termv := ATermv;
    Query.DeleteDataAfterClose := True;
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
          else
            F.AsString := Query.Termv.ToString(I);
          end;
        end;
        ADataSet.Post;
      finally
        if ADataSet.State in dsEditModes then
          ADataSet.Cancel;
      end;
      Query.NextSolution;
    end;
  finally
    Query.Free; 
  end;
end;     

function TgsPLClient.Call2(const AGoal: String): Boolean;
var
  t: TgsPLTermv;
  Query: TgsPLQuery;
begin
  Result := False;
  t := TgsPLTermv.CreateTermv(1);
  try
    if PL_chars_to_term(PChar(AGoal), t.Term[0]) <> 0 then
    begin
      Query := TgsPLQuery.Create;
      try
        Query.Pred := 'call';
        Query.Termv := t;
        Query.OpenQuery;
        Result := not Query.Eof;
      finally
        Query.Free;
      end;
    end;
  finally
    t.Free;
  end;
end;

function TgsPLClient.Call(const APredicateName: String; AParams: TgsPLTermv): Boolean;
var
  Query: TgsPLQuery;
begin
  Assert(APredicateName > '');

  Query := TgsPLQuery.Create;
  try
    Query.Pred := APredicateName;
    Query.Termv := AParams;
    Query.OpenQuery; 
    Result := not Query.Eof;
  finally
    Query.Free;    
  end;
end;

procedure TgsPLClient.Compound(AGoal: term_t; const AFunctor: String; ATermv: TgsPLTermv);
begin
  Assert(AFunctor > '');

  if PL_cons_functor_v(AGoal,
    PL_new_functor(PL_new_atom(PChar(AFunctor)), ATermv.size),
    ATermv.Term[0]) = 0
  then
    RaisePrologError;
end;

function TermToString(ATerm: term_t): String;
var
  a: term_t;
  name: atom_t;
  arity, I: Integer;
  S: PChar; 
  len: Cardinal;
begin
  Result := '';
  case PL_term_type(ATerm) of
   PL_VARIABLE:
   begin
     PL_get_chars(ATerm, S, CVT_VARIABLE);
     Result := S;
   end;
    PL_ATOM, PL_INTEGER, PL_FLOAT:
    begin
      PL_get_chars(ATerm, S, CVT_ALL);
      Result := S;
    end;
    PL_STRING:
    begin
      PL_get_string(ATerm, S, len);
      Result := StrSingleQuote(S);  
    end;
    PL_TERM:
    begin
      if PL_get_name_arity(ATerm, name, arity) <> 0 then
      begin
        Result := Result + PL_atom_chars(name) + '(';

        for I := 1 to arity do
        begin
          a := PL_new_term_ref;
          PL_get_arg(I, ATerm, a);
          Result := Result + TermToString(a) + ',';
        end;

        SetLength(Result, Length(Result) - 1);
        Result := Result + ')';
      end;
    end;
    else
      raise Exception.Create('No variable!');
  end;
end;

function TgsPLClient.GetArity(ASql: TIBSQL): Integer;
var
  I: Integer;
begin
  Assert(ASql <> nil);
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

function TgsPLClient.GetTempPath: String;
var
  Buff: array[0..1024] of Char;
begin
  Windows.GetTempPath(SizeOf(Buff), Buff);
  Result := ExcludeTrailingBackslash(Buff);
end;

function TgsPLClient.GetArity(ADataSet: TDataSet; const AFieldList: String): Integer;
var
  I: Integer;
begin
  Assert(ADataSet <> nil);
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

function TgsPLClient.IsInitialised: Boolean;
var
  argc: Integer;
begin
  argc := High(FInitArgv);
  Result := (argc > -1) and TryPLLoad;

  if Result then
    Result := PL_is_initialised(argc, FInitArgv) <> 0; 
end;

function TgsPLClient.Initialise(const AParams: String = InitParams): Boolean;

  function GetNextElement(const S: String; var L: Integer): String;
  var
    F: Integer;
  begin
    F := L;

    while (F <= Length(S)) and (S[F] <> ',') do
      Inc(F);
      
    Result := Trim(Copy(S, L, F - L));
    Inc(F);
    L := F;
  end;

var
  P: Integer; 
begin
  Assert(AParams > '');

  if not TryPLLoad then
    raise EgsPLClientException.Create('Клиентская часть Prolog не установлена!'); 
      
  P := 1;
  while P <= Length(AParams) do
  begin
    SetLength(FInitArgv, High(FInitArgv) + 2);
    FInitArgv[High(FInitArgv)] := PChar(GetNextElement(AParams, P));
  end;

  Setlength(FInitArgv, High(FInitArgv) + 2);
  FInitArgv[High(FInitArgv)] := nil;

  if not IsInitialised then
  begin
    Result := PL_initialise(High(FInitArgv), FInitArgv) <> 0;
    if not Result then
      PL_halt(1);
  end else
    Result := False;
end;

procedure TgsPLClient.MakePredicatesOfDataSet(ADataSet: TDataSet; const AFieldList: String;
  const APredicateName: String; const AFileName: String);
var
  I, Arity, Idx: Integer;
  Refs, Term: TgsPLTermv;
begin
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
      Call('assert', Term);
      ADataSet.Next;
    end;
  finally
    Refs.Free;
    Term.Free;
  end;
end;

procedure TgsPLClient.MakePredicatesOfSQLSelect(const ASQL: String; ATr: TIBTransaction;
  const APredicateName: String; const AFileName: String);
var
  q: TIBSQL;
  Refs, Term: TgsPLTermv;
  I: LongWord;
  Arity: Integer; 
begin
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
          Call('assert', Term);
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

procedure TgsPLClient.MakePredicatesOfObject(const AClassName: String; const ASubType: String; const ASubSet: String;
  AParams: Variant; AnExtraConditions: TStringList; const AFieldList: String; ATr: TIBTransaction;
  const APredicateName: String; const AFileName: String);
var
  C: TPersistentClass;
  Obj: TgdcBase;
  I: Integer; 
begin
  Assert(ATr <> nil);
  Assert(ATr.InTransaction);
  Assert(AClassName > '');
  Assert(ASubSet > '');
  Assert(APredicateName > '');
  Assert(VarIsArray(AParams));
  Assert(VarArrayDimCount(AParams) = 1);

  C := GetClass(AClassName);

  if (C = nil) or (not C.InheritsFrom(TgdcBase)) then
    raise EgsPLClientException.Create('Invalid class name ' + AClassName);

  Obj := CgdcBase(C).Create(nil);
  try
    Obj.SubType := ASubType;
    Obj.ReadTransaction := ATr;
    Obj.Transaction := ATr;
    if AnExtraConditions <> nil then
      Obj.ExtraConditions := AnExtraConditions;
    Obj.SubSet := ASubSet;
    Obj.Prepare; 

    for I := VarArrayLowBound(AParams,  1) to VarArrayHighBound(AParams,  1) do
    begin
      Obj.Params[0].AsVariant := AParams[I];
      Obj.Open;
      if not Obj.Eof then
        MakePredicatesOfDataSet(Obj, AFieldList, APredicateName, AFileName);
      Obj.Close;
    end;
  finally
    Obj.Free;
  end;
end;   

end.
