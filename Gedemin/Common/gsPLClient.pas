unit gsPLClient;

interface

uses
  Windows, Classes, SysUtils, IBDatabase, IBSQL, IBHeader, dbclient, DB,
  gdcBase, PLHeader, PLIntf;

type
  TgsTermv = class(TObject)
  private
    FTerm: term_t;
    FSize: LongWord;
    function GetValue(const Idx: LongWord): Variant;
    function GetDataType(const Idx: LongWord): Integer;
    function GetTerm(const Idx: LongWord): term_t;  
  public
    constructor CreateTerm(const ASize: Integer);
    procedure SetInteger(const Idx: LongWord; const AValue: Integer);
    procedure SetString(const Idx: LongWord; const AValue: String);
    procedure SetFloat(const Idx: LongWord; const AValue: Double);
    procedure SetDateTime(const Idx: LongWord; const AValue: TDateTime);
    procedure SetDate(const Idx: LongWord; const AValue: TDateTime);
    procedure SetInt64(const Idx: LongWord; const AValue: Int64);

    property Value[const Idx: LongWord]: Variant read GetValue;
    property DataType[const Idx: LongWord]: Integer read GetDataType;
    property Term[const Idx: LongWord]: term_t read GetTerm; 
    property Size: LongWord read FSize;
  end;

  TgsPLQuery = class(TObject)
  private
    FQid: qid_t;
    FEof: Boolean;
    FTermv: TgsTermv;
    FPred: String;

    function GetEof: Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    procedure OpenQuery;
    procedure Close;
    procedure NextSolution;

    property Eof: Boolean read GetEof;
    property Pred: String read FPred write FPred;
    property Termv: TgsTermv read FTermv write FTermv; 
  end;

  TgsPLClient = class(TObject)
  private
    FInitArgv: array of PChar;
    FDebug: Boolean;
    
    function GetArity(ASql: TIBSQL): Integer; overload;
    function GetArity(ADataSet: TDataSet; const AFieldList: String): Integer; overload;
    function CheckDataType(const AVariableType: Integer; const AField: TField): Boolean;
    function GetTempPath: String;
    function TermToString(ATerm: term_t): String;
  public
    destructor Destroy; override;
     
    function Call(const APredicateName: String; AParams: TgsTermv): Boolean; overload;
    function Call(const AGoal: String): Boolean; overload;
    procedure Compound(const AFunctor: String; AGoal: term_t; ATermv: TgsTermv);
    function Initialise(const AParams: Variant): Boolean;
    function IsInitialised: Boolean;
    procedure MakePredicatesOfSQLSelect(const ASQL: String; ATr: TIBTransaction;
      const APredicateName: String; const AFileName: String);
    procedure MakePredicatesOfDataSet(ADataSet: TDataSet; const AFieldList: String; const APredicateName: String; const AFileName: String);
    procedure MakePredicatesOfObject(const AClassName: String; const ASubType: String; const ASubSet: String;
      AParams: Variant; AnExtraConditions: TStringList; const AFieldList: String; ATr: TIBTransaction;
      const APredicateName: String; const AFileName: String);
    function CreateTermRef: term_t;
    procedure ExtractData(ADataSet: TClientDataSet; const APredicateName: String; ATermv: TgsTermv);

    property Debug: Boolean read FDebug write FDebug;
  end;

  EgsPLClientException = class(Exception);

implementation

uses
  jclStrings, gd_GlobalParams_unit;

procedure RaisePrologError(AnException: term_t);
var
  a: term_t;
  name: atom_t;
  arity: Integer;
begin
  if AnException <> 0 then
  begin
    a := PL_new_term_refs(2);
    if (PL_get_arg(1, AnException, a) <> 0)
      and (PL_get_name_arity(a, name, arity) <> 0)
    then
      raise EgsPLClientException.Create(PL_atom_chars(name));
  end;
end;

constructor TgsTermv.CreateTerm(const ASize: Integer);
begin
  inherited Create;

  FTerm := PL_new_term_refs(ASize);
  FSize := ASize;
end;

function TgsTermv.GetTerm(const Idx: LongWord): term_t;
begin
  if Idx >= Size then
    raise EgsPLClientException.Create('Invalid index!');

  Result := FTerm + Idx;
end;

procedure TgsTermv.SetInteger(const Idx: LongWord; const AValue: Integer);
begin
  PL_put_integer(GetTerm(Idx), AValue);
end;

procedure TgsTermv.SetString(const Idx: LongWord; const AValue: String);
begin
  PL_put_string_chars(GetTerm(Idx), PChar(AValue));
end;

procedure TgsTermv.SetFloat(const Idx: LongWord; const AValue: Double);
begin
  PL_put_float(GetTerm(Idx), AValue);
end;

procedure TgsTermv.SetDateTime(const Idx: LongWord; const AValue: TDateTime);
begin
  PL_put_atom_chars(GetTerm(Idx), PChar(FormatDateTime('yyyy-mm-dd hh:nn:ss', AValue)));
end;

procedure TgsTermv.SetDate(const Idx: LongWord; const AValue: TDateTime);
begin
  PL_put_atom_chars(GetTerm(Idx), PChar(FormatDateTime('yyyy-mm-dd', AValue)));
end;

procedure TgsTermv.SetInt64(const Idx: LongWord; const AValue: Int64);
begin
  PL_put_int64(GetTerm(Idx), AValue);
end;      

function TgsTermv.GetValue(const Idx: LongWord): Variant;
var
  I: Integer;
  I64: Int64;
  S: PChar;
  D: Double;
  len: Cardinal;
begin
  Result := Unassigned;

  case GetDataType(Idx) of
    PL_INTEGER, PL_SHORT, PL_INT:
      if PL_get_integer(GetTerm(Idx), I) <> 0 then
        Result := I
      else
        raise EgsPLClientException.Create('Invalid sync type prolog and delphi!');
    PL_LONG:
      if PL_get_int64(GetTerm(Idx), I64) <> 0 then
        Result := IntToStr(I64)
      else
        raise EgsPLClientException.Create('Invalid sync type prolog and delphi!');
    PL_ATOM, PL_CHARS:
      if PL_get_atom_chars(GetTerm(Idx), S) <> 0 then
        Result := String(S)
      else
        raise EgsPLClientException.Create('Invalid sync type prolog and delphi!');
    PL_STRING:
    begin
      if PL_get_string(GetTerm(Idx), S, len) <> 0 then
        Result := String(S)
      else
        raise EgsPLClientException.Create('Invalid sync type prolog and delphi!');
    end;
    PL_FLOAT, PL_DOUBLE:
      if PL_get_float(GetTerm(Idx), D) <> 0 then
        Result := D
      else
        raise EgsPLClientException.Create('Invalid sync type prolog and delphi!');
    PL_BOOL:
      if PL_get_bool(GetTerm(Idx), I) <> 0 then
        Result := I
      else  
        raise EgsPLClientException.Create('Invalid sync type prolog and delphi!');
  end;
end;

function TgsTermv.GetDataType(const Idx: LongWord): Integer;
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
  NextSolution;
end;

procedure TgsPLQuery.Close;
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
      if ex <> 0 then RaisePrologError(ex);
    end; 
  end;  
end; 

destructor TgsPLClient.Destroy;
begin
  if IsInitialised then
    PL_cleanup(0);
    
  inherited;
end;

function TgsPLClient.CheckDataType(const AVariableType: Integer; const AField: TField): Boolean;
begin
  Assert(AField <> nil); 

  case AVariableType of
    PL_INTEGER, PL_SHORT, PL_INT:
      Result := AField.DataType in [ftSmallint, ftInteger, ftWord];
    PL_LONG: Result := AField.DataType = ftLargeint;
    PL_ATOM, PL_STRING, PL_CHARS:
      Result := AField.DataType in [ftString, ftMemo, ftWideString, ftDate, ftTime, ftDateTime];
    PL_FLOAT, PL_DOUBLE:
      Result := AField.DataType in [ftFloat, ftCurrency, ftBCD];
    PL_BOOL:
      Result := AField.DataType in [ftBoolean];
  else
    Result := False;
  end;
end;

procedure TgsPLClient.ExtractData(ADataSet: TClientDataSet; const APredicateName: String; ATermv: TgsTermv);
var
  Query: TgsPLQuery;
  I: LongWord;
  V: Variant;
  DT: TDateTime; 
begin
  Assert(ADataSet <> nil);
  Assert(ATermv <> nil);

  Query := TgsPLQuery.Create;
  try
    Query.Pred := APredicateName;
    Query.Termv := ATermv;
    Query.OpenQuery;
    while not Query.Eof do
    begin
      ADataSet.Insert;
      try
        for I := 0 to Query.Termv.Size - 1 do
        begin
          V := Query.Termv.Value[I];
          if CheckDataType(Query.Termv.DataType[I], ADataSet.Fields[I])
            and (VarType(V) <> 0) then
          begin
            if ADataSet.Fields[I].DataType in [ftDate, ftTime, ftDateTime] then
            begin
              try
                DT := VarToDateTime(V);
                ADataSet.Fields[I].AsDateTime := DT;
              except
                on E:Exception do
                  raise EgsPLClientException.Create('Invalid TDateTime format!');
              end;
            end else
              ADataSet.Fields[I].AsVariant := V;
          end else
            raise EgsPLClientException.Create('Error sync data type!');
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

function TgsPLClient.CreateTermRef: term_t;
begin
  Result := PL_new_term_ref;
end;   

function TgsPLClient.Call(const AGoal: String): Boolean;
var
  t: TgsTermv;
  Query: TgsPLQuery;
begin
  Result := False;
  t := TgsTermv.CreateTerm(1);
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

function TgsPLClient.Call(const APredicateName: String; AParams: TgsTermv): Boolean;
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

procedure TgsPLClient.Compound(const AFunctor: String; AGoal: term_t; ATermv: TgsTermv);
begin
  Assert(AFunctor > '');  

  PL_cons_functor_v(AGoal, PL_new_functor(PL_new_atom(PChar(AFunctor)), ATermv.size), ATermv.Term[0]);
end;

function TgsPLClient.TermToString(ATerm: term_t): String;
var
  a: term_t;
  name: atom_t;
  arity, I: Integer;
  S: PChar; 
  len: Cardinal;
begin
  Result := '';
  case PL_term_type(ATerm) of
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

function TgsPLClient.Initialise(const AParams: Variant): Boolean;
var
  I, argc: Integer;
begin
  Assert(VarIsArray(AParams));
  Assert(VarArrayDimCount(AParams) = 1);
  
  if not TryPLLoad then
    raise EgsPLClientException.Create('Клиентская часть Prolog не установлена!');

  argc := VarArrayHighBound(AParams, 1) + 1;
  SetLength(FInitArgv, argc + 1);
  for I:= VarArrayLowBound(AParams, 1) to VarArrayHighBound(AParams, 1) do
    FInitArgv[I] := PChar(VarToStr(AParams[I]));
  FInitArgv[argc] := nil;

  if not IsInitialised then
  begin
    Result := PL_initialise(argc, FInitArgv) <> 0;
    if not Result then
      PL_halt(1);
  end else
    Result := False;
end;

procedure TgsPLClient.MakePredicatesOfDataSet(ADataSet: TDataSet; const AFieldList: String;
  const APredicateName: String; const AFileName: String);
var
  I, Arity, Idx: Integer;
  Refs, Term: TgsTermv;
begin
  Assert(ADataSet <> nil);
  Assert(APredicateName > '');


  Arity := GetArity(ADataSet, AFieldList);
  Refs := TgsTermv.CreateTerm(Arity);
  Term := TgsTermv.CreateTerm(1);
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
              Refs.SetInteger(Idx, ADataSet.Fields[I].AsInteger);
            ftLargeint: Refs.SetInt64(Idx, TLargeintField(ADataSet.Fields[I]).AsLargeInt);
            ftFloat: Refs.SetFloat(Idx, ADataSet.Fields[I].AsFloat);
            ftCurrency: Refs.SetFloat(Idx, ADataSet.Fields[I].AsCurrency);
            ftString, ftMemo: Refs.SetString(Idx, ADataSet.Fields[I].AsString);
            ftDate: Refs.SetDate(Idx, ADataSet.Fields[I].AsDateTime);
            ftDateTime, ftTime: Refs.SetDateTime(Idx, ADataSet.Fields[I].AsDateTime);
          end;
          Inc(Idx);
        end;
      end;
      Compound(APredicateName, Term.Term[0], Refs);
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
  Refs, Term: TgsTermv;
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
      Refs := TgsTermv.CreateTerm(Arity);
      Term := TgsTermv.CreateTerm(1);
      try
        while not q.Eof do
        begin
          for I := 0 to q.Current.Count - 1 do
          begin
            case q.Fields[I].SQLType of
              SQL_LONG, SQL_SHORT:
                if q.Fields[I].AsXSQLVAR.sqlscale = 0 then
                  Refs.SetInteger(I, q.Fields[I].AsInteger)
                else
                  Refs.SetFloat(I, q.Fields[I].AsCurrency);
              SQL_FLOAT, SQL_D_FLOAT, SQL_DOUBLE:
                Refs.SetFloat(I, q.Fields[I].AsFloat);
              SQL_INT64:
                if q.Fields[I].AsXSQLVAR.sqlscale = 0 then
                  Refs.SetInt64(I, q.Fields[I].AsInt64)
                else
                  Refs.SetFloat(I, q.Fields[I].AsCurrency);
              SQL_TYPE_DATE:
                Refs.SetDate(I, q.Fields[I].AsDate);
              SQL_TIMESTAMP, SQL_TYPE_TIME:
                Refs.SetDateTime(I, q.Fields[I].AsDateTime);
              SQL_TEXT, SQL_VARYING:
                Refs.SetString(I, q.Fields[I].AsTrimString);
            end;
          end;
          Compound(APredicateName, Term.Term[0], Refs);
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
