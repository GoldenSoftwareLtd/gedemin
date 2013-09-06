unit gsPLClient;

interface

uses
  Windows, Classes, SysUtils, swiprolog, IBDatabase, IBSQL, IBHeader, dbclient, DB;

type
  TTermv = record
    Term: term_t;
    Size: LongWord;
  end;

  TgsPLQuery = class(TObject)
  private
    FQid: qid_t;
    FEof: Boolean;
    FTermv: TTermv;
    FPred: String;

    function GetEof: Boolean;
    function GetDataType(const Idx: LongWord): Integer;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ExecQuery;
    procedure Close;
    procedure Next;

    property Eof: Boolean read GetEof;
    property Pred: String read FPred write FPred;
    property Termv: TTermv read FTermv write FTermv;
    property VariableDataType[const Idx: LongWord]: Integer read GetDataType;
  end;

  TgsPLClient = class(TObject)
  private
    function GetArity(ASql: TIBSQL): Integer;
    procedure SetTerm(AField: TIBXSQLVAR; ATerm: term_t);
    procedure Compound(const AFunctor: String; AGoal: term_t; ATermv: TTermv);
    //function CreateTermRef: term_t;
    //function CreateTermRefs(const ASize: Integer): TTermv;
    function CheckDataType(const AVariableType: Integer; const AField: TField): Boolean;
  public
    destructor Destroy; override;
     
    function Call(const APredicateName: String; AParams: TTermv): Boolean; overload;
    function Call(const AGoal: String): Boolean; overload;
    function Initialise{(AnArgc: Integer; AnArgv)}: Boolean;
    procedure MakePredicates(ASQL: String; ATr: TIBTransaction;
      APredName: String; AFileName: String);
    function CreateTermRef: term_t;
    function CreateTermRefs(const ASize: Integer): TTermv;
    procedure ExtractData(ADataSet: TClientDataSet; const APredicateName: String; ATermv: TTermV);
  end;

implementation  

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

procedure TgsPLQuery.ExecQuery;
var
  p: predicate_t;
begin
  p := PL_predicate(PChar(FPred), FTermv.Size, 'user');
  FQid := PL_open_query(nil, PL_Q_CATCH_EXCEPTION, p, FTermv.Term);
  Next;
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

procedure TgsPLQuery.Next;
begin
  if not FEof then
  begin
    FEof := PL_next_solution(FQid) = 0;
  end;  
end;

function TgsPLQuery.GetDataType(const Idx: LongWord): Integer;
begin
  if Idx >= FTermv.Size then
    raise Exception.Create('Invalid index!');

  Result := PL_term_type(FTermv.Term + Idx);
end;

destructor TgsPLClient.Destroy;
begin
  PL_cleanup(0);

  inherited;
end;

function TgsPLClient.CheckDataType(const AVariableType: Integer; const AField: TField): Boolean;
begin
  Assert(AField <> nil); 

  case AVariableType of
    PL_INTEGER, PL_SHORT, PL_INT, PL_LONG:
      Result := AField.DataType in [ftSmallint, ftInteger, ftWord, ftLargeint];
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

procedure TgsPLClient.ExtractData(ADataSet: TClientDataSet; const APredicateName: String; ATermv: TTermV);
var
  Query: TgsPLQuery;
  I: LongWord;
  Y: Integer;
  S: PChar;
  D: Double;
begin
  Assert(ADataSet <> nil);

  Query := TgsPLQuery.Create;
  try
    Query.Pred := APredicateName;
    Query.Termv := ATermv;
    Query.ExecQuery;
    while not Query.Eof do
    begin
      ADataSet.Insert;
      try
        for I := 0 to Query.Termv.Size - 1 do
        begin
          if CheckDataType(Query.VariableDataType[I], ADataSet.Fields[I]) then
          begin
            case Query.VariableDataType[I] of
              PL_INTEGER, PL_SHORT, PL_INT, PL_LONG:
              begin
                if PL_get_integer(Query.Termv.Term + I, Y) <> 0 then
                  ADataSet.Fields[I].AsInteger := Y
                else
                  raise Exception.Create('Error output value!')
              end;
              PL_ATOM, PL_STRING, PL_CHARS:
              begin
               if PL_get_atom_chars(Query.Termv.Term + I, S) <> 0 then
                 ADataSet.Fields[I].AsString := S
               else
                raise Exception.Create('Error output value!');
              end;  
              PL_FLOAT, PL_DOUBLE:
              begin
                if PL_get_float(Query.Termv.Term + I, D) <> 0 then
                  ADataSet.Fields[I].AsFloat := D
                else
                  raise Exception.Create('Error output value!');
              end;
              PL_BOOL:
              begin
                if PL_get_bool(Query.Termv.Term + I, Y) <> 0 then
                  ADataSet.Fields[I].AsInteger := Y
                else
                  raise Exception.Create('Error output value!');
              end;
            end;
          end else
            raise Exception.Create('Error sync data type!');
        end;
        ADataSet.Post;
      finally
        if ADataSet.State in dsEditModes then
          ADataSet.Cancel;
      end;
      Query.Next;
    end;  
  finally
    Query.Free;
  end;
end;

function TgsPLClient.CreateTermRef: term_t;
begin
  Result := PL_new_term_ref;
end;

function TgsPLClient.CreateTermRefs(const ASize: Integer): TTermv;
begin
  Result.Term := PL_new_term_refs(ASize);
  Result.Size := ASize;
end;

function TgsPLClient.Call(const AGoal: String): Boolean;
var
  t: TTermv;
  Query: TgsPLQuery;
begin
  Result := False;
  t := CreateTermRefs(1);
  if PL_chars_to_term(PChar(AGoal), t.Term) <> 0 then
  begin
    Query := TgsPLQuery.Create;
    try
      Query.Pred := 'call';
      Query.Termv := t;
      Query.ExecQuery; 
      Result := not Query.Eof;
    finally
      Query.Free;
    end;
  end;
end;

function TgsPLClient.Call(const APredicateName: String; AParams: TTermv): Boolean;
var
  Query: TgsPLQuery;
begin
  Assert(APredicateName > '');

  Query := TgsPLQuery.Create;
  try
    Query.Pred := APredicateName;
    Query.Termv := AParams;
    Query.ExecQuery; 
    Result := not Query.Eof;
  finally
    Query.Free;
  end;
end;

procedure TgsPLClient.Compound(const AFunctor: String; AGoal: term_t; ATermv: TTermv);
begin
  Assert(AFunctor > '');  

  PL_cons_functor_v(AGoal, PL_new_functor(PL_new_atom(PChar(AFunctor)), ATermv.size), ATermv.Term);
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

function TgsPLClient.Initialise: Boolean;
var
  Params: array [0..1] of PChar;
begin
  Params[0] := 'libswipl.dll';
  Params[1] := nil;
  
  Result := PL_initialise(1, Params) <> 0;
  if not Result then
    PL_halt(1);
end;

procedure TgsPLClient.MakePredicates(ASQL: String; ATr: TIBTransaction;
  APredName: String; AFileName: String);
var
  q: TIBSQL;
  Refs, Term: TTermv;
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
      Refs := CreateTermRefs(Arity);
      Term := CreateTermRefs(1);
      while not q.Eof do
      begin
        for I := 0 to q.Current.Count - 1 do
          SetTerm(q.Fields[I], Refs.Term + I);
        Compound(APredName, Term.Term, Refs);
        Call('assert', Term);
        q.Next;
      end;
    end;    
  finally
    q.Free;
  end;
end;

procedure TgsPLClient.SetTerm(AField: TIBXSQLVAR; ATerm: term_t);
begin
  Assert(AField <> nil);

  case AField.SQLType of
    SQL_LONG, SQL_SHORT:
      if AField.AsXSQLVAR.sqlscale = 0 then
        PL_put_integer(ATerm, AField.AsInteger)
      else
        PL_put_float(ATerm, AField.AsCurrency);
    SQL_FLOAT, SQL_D_FLOAT, SQL_DOUBLE:
      PL_put_float(ATerm, AField.AsFloat);
    SQL_INT64:
      if AField.AsXSQLVAR.sqlscale = 0 then
        PL_put_int64(ATerm, AField.AsInt64)
      else
        PL_put_float(ATerm, AField.AsCurrency);
    SQL_TYPE_DATE:
      PL_put_atom_chars(ATerm, PChar(FormatDateTime('yyyy-mm-dd', AField.AsDate)));
    SQL_TIMESTAMP, SQL_TYPE_TIME:
      PL_put_atom_chars(ATerm, PChar(FormatDateTime('yyyy-mm-dd hh:nn:ss', AField.AsDateTime)));
    SQL_TEXT, SQL_VARYING:
      PL_put_atom_chars(ATerm, PChar(AField.AsTrimString));
  end;
end;

end.
