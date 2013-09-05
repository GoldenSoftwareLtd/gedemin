unit gsPLClient;

interface

uses
  Windows, Classes, SysUtils, swiprolog, IBDatabase, IBSQL, IBHeader;

type
  TTermv = record
    Term: term_t;
    Size: Integer;
  end;

  TgsPLQuery = class(TObject)
  private
    FQid: qid_t;
    FEof: Boolean;
    FTermv: TTermv;
    FPred: String;

    function GetEof: Boolean;
  public
    constructor Create;

    procedure ExecQuery;
    procedure Close;
    procedure Next;

    property Qid: qid_t read FQid;
    property Eof: Boolean read GetEof;
    property Pred: String read FPred write FPred;
    property Termv: TTermv read FTermv write FTermv;
  end;

  TgsPLClient = class(TObject)
  private
    function GetArity(ASql: TIBSQL): Integer;
    procedure SetTerm(AField: TIBXSQLVAR; ATerm: term_t);
    procedure Compound(const AFunctor: String; AGoal: term_t; ATermv: TTermv);
    function CreateTermRef: term_t;
    function CreateTermRefs(const ASize: Integer): TTermv; 
  public
    destructor Destroy; override;
     
    function Call(const APredicateName: String; AParams: TTermv): Boolean; overload;
    function Call(const AGoal: String): Boolean; overload;
    function Initialise{(AnArgc: Integer; AnArgv)}: Boolean;
    procedure MakePredicates(ASQL: String; ATr: TIBTransaction;
      APredName: String; AFileName: String);
  end;

implementation  

constructor TgsPLQuery.Create;
begin
  inherited Create;

  FQid := 0;
  FEOF := False;
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

destructor TgsPLClient.Destroy;
begin
  PL_cleanup(0);

  inherited;
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
  if PL_chars_to_term(PChar(AGoal), t.Term) = 1 then
  begin
    Query := TgsPLQuery.Create;
    try
      Query.Pred := 'call';
      Query.Termv := t;
      Query.ExecQuery;
      Query.Next;
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
    Query.Next;
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
      SQL_TYPE_DATE, SQL_INT64: Inc(Result);
    end; 
  end;
end;


function TgsPLClient.Initialise: Boolean;
var
  Params: array [0..1] of PChar;
begin
  Params[0] := 'libswipl.dll';
  Params[1] := nil;
  
  Result := PL_initialise(1, Params) = 1;
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
    SQL_LONG, SQL_SHORT: PL_put_integer(ATerm, AField.AsInteger);
  end;  
end;

end.
