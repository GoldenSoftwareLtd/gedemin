{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    at_sql_parser.pas

  Abstract

    Delphi non-visual component - part of Gedemin project.
    Prepares sql objects - parse the sql-statements.

  Author

    Romanovski Denis    (2001)
    Teryokhina Julia

  Revisions history

    1.0    Denis    2001        Initial version.
           Julie    25.03.2002  Correction brackets in parser.
    1.1    Julie    12.04.2002  Was added new classes for work with sets,
                                some sets were replaced by classes,
                                Was added keywords "First" and "Skip"
           Julie    13.04.2002  Was corrected reading of fraction number
    1.2    Julie    15.04.2002  Was added function "extract"
           Julie    02.05.2002  Was added error handling
--}
unit at_sql_parser;

interface

uses
  Windows, SysUtils, Classes, Contnrs;

type
  TTokenType = (ttClause, ttWord, ttSymbolClause, ttClear, ttSpace, ttNone);

type
  TClause =
  (
    cSelect, cDistinct, cAll, cInsert, cInto, cFrom, cWhere,
    cGroup, cCollate, cHaving, cUnion, cPlan, cOrder, cBy,
    cFor, cOf, cSum, cAvg, cMax, cMin, cCast,
    cUpper, cGen_id, cOn, cLeft, cRight, cFull, cOuter,
    cInner, cJoin, cAnd, cOr, cNot, cBetween, cLike, cIn, cEscape, cIs, cNull,
    cSome, cAny, cExists, cSingular, cContaining, cStarting, cWith,
    cSort, cMerge, cIndex, cNatural, cAsc, cDesc,
    cUpdate, cSet, cValues, cAs, cCount, cDelete, cFirst, cSkip, cExtract,
    cDay, cHour, cMinute, cMonth, cSecond, cWeakday, cYear, cYearday,
    cNone, cCase, cWhen, cElse, cThen, cEnd, cSubstring);

  TClauses = set of TClause;

  TclClause = class
  private
    FArrClause: array of TClause;

    function GetCount: Integer;
    function GetItems(Index: Integer): TClause;

  public
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TClause read GetItems;

    function Add(Value: TClause): Integer;
    procedure Delete(Index: Integer);

    function Include(Value: TClause): Boolean;
    procedure Exclude(Value: TClause);

    function Cross(ValueSet: TClauses): TClauses;
    procedure Assign(clInstance: TclClause);
    procedure Clear;
  end;

const
  ClauseText: array [TClause] of String =
  (
    'SELECT', 'DISTINCT', 'ALL', 'INSERT', 'INTO', 'FROM', 'WHERE',
    'GROUP', 'COLLATE', 'HAVING', 'UNION', 'PLAN', 'ORDER', 'BY',
    'FOR', 'OF', 'SUM', 'AVG', 'MAX', 'MIN', 'CAST',
    'UPPER', 'GEN_ID', 'ON', 'LEFT', 'RIGHT', 'FULL', 'OUTER',
    'INNER', 'JOIN', 'AND', 'OR', 'NOT', 'BETWEEN', 'LIKE', 'IN', 'ESCAPE',
    'IS', 'NULL', 'SOME', 'ANY', 'EXISTS', 'SINGULAR', 'CONTAINING',
    'STARTING', 'WITH', 'SORT', 'MERGE', 'INDEX', 'NATURAL', 'ASC', 'DESC',
    'UPDATE', 'SET', 'VALUES', 'AS', 'COUNT', 'DELETE', 'FIRST', 'SKIP',
    'EXTRACT', 'DAY', 'HOUR', 'MINUTE', 'MONTH', 'SECOND', 'WEAKDAY',
    'YEAR', 'YEARDAY', '', 'CASE', 'WHEN', 'ELSE', 'THEN', 'END', 'SUBSTRING'
  );


type
  TSymbolClause = (scBracketOpen, scBracketClose, scDot, scComma, scNone);

  TSymbolClauses = set of TSymbolClause;

const
  SymbolClauseText: array[TSymbolClause] of Char =
    ('(', ')', '.', ',', #0);

  SymbolClauseArray = ['(', ')', '.', ','];

type
  TMathClause =
  (
    mcPlus, mcMinus, mcMultiple, mcDevide, mcStr,
    mcLess, mcMore, mcInverse, mcEqual, mcNone
  );

  TMathClauses = set of TMathClause;

  TclMathClause = class
  private
    FArrClause: array of TMathClause;
    function GetCount: Integer;
    function GetItems(Index: Integer): TMathClause;

  public
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TMathClause read GetItems;

    function Add(Value: TMathClause): Integer;
    procedure Delete(Index: Integer);

    function Include(Value: TMathClause): Boolean;
    procedure Exclude(Value: TMathClause);

    function Cross(ValueSet: TMathClauses): TMathClauses;
  end;

const
  MathClauseText: array[TMathClause] of Char =
    ('+', '-', '*', '/', '|', '<', '>', '!', '=', #0);

  MathSymbolsArray = ['=', '>', '<', '!'];
  MathOperationArray = ['+', '-', '*', '/', '|'];

const
  NumberSymbols = ['0'..'9', '.'];

type
  TTextKind = (tkText, tkUserText, tkMath, tkMathOp, tkNone);

type
  TsqlToken = record
    TokenType: TTokenType;

    Text, Source: String;
    Symbol: Char;

    Clause: TClause;
    SymbolClause: TSymbolClause;
    TextKind: TTextKind;
  end;


type
  TElementOption =
  (
    eoName, eoAlias, eoValue, eoSubName, eoClause, eoSubClause, eoAsc, eoDesc,
    eoUserFunc, eoMath, eoOn, eoBefore, eoCollate, eoUnderCast, eoComplicatedJoin,
    eoFraction, eoType, eoWhen, eoEnd, eoElse, eoThen, eoCase, eoFor, eoFrom
  );

  TElementOptions = set of TElementOption;

type
  TCommentState = (csStarted, csFinished, csNone);

type
  TsqlParser = class;
  TsqlFull = class;

  TsqlStatement = class
  private
    FParser: TsqlParser;

    function GetIndent: Integer;
    procedure SetIndent(const Value: Integer);
    function GetSIndent: String;

  protected
    procedure ParseStatement; virtual; abstract;
    procedure BuildStatement(out sql: String); virtual; abstract;

    property Indent: Integer read GetIndent write SetIndent;
    property SIndent: String read GetSIndent;

  public
    constructor Create(AParser: TsqlParser); virtual;
    destructor Destroy; override;
  end;

  TsqlMath = class(TsqlStatement)
  private
    FMath: TclMathClause;

    function GetIsOperation: Boolean;

  protected
    procedure ParseStatement; override;
    procedure BuildStatement(out sql: String); override;

    property IsOperation: Boolean read GetIsOperation;

  public
    constructor Create(AParser: TsqlParser); override;
    destructor Destroy; override;

    property Math: TclMathClause read FMath; //write SetMath;

  end;

  TsqlValue = class(TsqlStatement)
  private
    FValue, FSourceValue: String;
    FSubName: String;
    FCollation: String;

    FNeeded, FDone: TElementOptions;
    //Вложено в конструкцию, не может иметь as-наименования
    FNested: Boolean;

    procedure SetValue(const Value: String);
    procedure SetSubName(const Value: String);
    procedure SetCollation(const Value: String);
    procedure SetDone(const Value: TElementOptions);

  protected
    procedure ParseStatement; override;
    procedure BuildStatement(out sql: String); override;

  public
    constructor Create(AParser: TsqlParser; const ANested: Boolean); reintroduce;
    destructor Destroy; override;

    property Value: String read FSourceValue write SetValue;
    property ValueAsName: String read FSubName write SetSubName;
    property ValueCollation: String read FCollation write SetCollation;
    property ValueAttrs: TElementOptions read FDone write SetDone;

  end;

  TsqlSelectParam = class(TsqlStatement)
  private
    FParamText: String;
    FParamValue: String;

  protected
    procedure ParseStatement; override;
    procedure BuildStatement(out sql: String); override;

  public
    constructor Create(AParser: TsqlParser); override;
    destructor Destroy; override;

  end;

  TsqlField = class(TsqlStatement)
  private
    FName: String;
    FAlias: String;
    FSubName: String;
    FCollation: String;
    FComment: TStringList;

    FDone, FNeeded: TElementOptions;

    FAs: TsqlStatement;
    FNested: Boolean;

    procedure SetName(const Value: String);
    procedure SetAlias(const Value: String);
    procedure SetSubName(const Value: String);
    procedure SetCollation(const Value: String);
    procedure SetDone(const Value: TElementOptions);

  protected
    procedure ParseStatement; override;
    procedure BuildStatement(out sql: String); override;

  public
    constructor Create(AParser: TsqlParser; const ANested: Boolean); reintroduce;
    destructor Destroy; override;

    property FieldName: String read FName write SetName;
    property FieldAlias: String read FAlias write SetAlias;
    property FieldAsName: String read FSubName write SetSubName;
    property FieldCollation: String read FCollation write SetCollation;
    property FieldAttrs: TElementOptions read FDone write SetDone;
    property FieldCast: TsqlStatement read FAs;
    property Comment: TStringList read FComment write FComment;

    property Nested: Boolean read FNested;
  end;

  TsqlFunction = class(TsqlStatement)
  private
    FArguments: TObjectList;
    FDone, FNeeded: TElementOptions;
    FFuncClause: TclClause;
    FJoins: TObjectList;

    FName: String;
    FSubName: String;
    FNested: Boolean;

    procedure SetName(const Value: String);
    procedure SetSubName(const Value: String);

  protected
    procedure ParseStatement; override;
    procedure BuildStatement(out sql: String); override;

    function GetLastClass: TClass;

  public
    constructor Create(AParser: TsqlParser; const ANested: Boolean); reintroduce;
    destructor Destroy; override;

    property FuncName: String read FName write SetName;
    property FuncAsName: String read FSubName write SetSubName;

    property Arguments: TObjectList read FArguments;
    property FuncClause: TclClause read FFuncClause;// write SetFuncClause;
    property Joins: TObjectList read FJoins;
    property Nested: Boolean read FNested;

    procedure Clear;
    procedure AssignAndClear(AsqlFunction: TsqlFunction);
  end;

  TsqlCast = class(TsqlStatement)
  private
    FTypeName: String;
    FTypeDimension: TStringList;
    FNeeded, FDone: TElementOptions;
    FInternalStatement: TsqlStatement;

  protected
    procedure ParseStatement; override;
    procedure BuildStatement(out sql: String); override;

  public
    constructor Create(AParser: TsqlParser); override;
    destructor Destroy; override;

    property InternalStatement: TsqlStatement read FInternalStatement;
    property TypeName: String read FTypeName;
    property TypeDimension: TStringList read FTypeDimension;
  end;

  TsqlSubString = class(TsqlStatement)
  private
    FNeeded, FDone: TElementOptions;
    FFrom: TsqlStatement;
    FFor: TsqlStatement;
    FValue: TsqlStatement;
    FInternalStatement: TsqlStatement;

  protected
    procedure ParseStatement; override;
    procedure BuildStatement(out sql: String); override;

  public
    constructor Create(AParser: TsqlParser); override;
    destructor Destroy; override;

    property InternalStatement: TsqlStatement read FInternalStatement;
  end;


  {имеет два синтаксиса, первый:

    case v
      when <значение> then
      when <значение> then
      ...
    else
      ...
    end

второй:

    case
      when <условие> then
      when <условие> then
      ...
    else
      ...
    end
}
  TsqlBaseCase = class(TsqlStatement)
  protected
    FNeeded, FDone: TElementOptions;
  end;

  TsqlCase = class(TsqlBaseCase)
  private
    //По условию
    FByCondition: Boolean;
    //Значение
    FValue: TsqlStatement;
    //Список.Может хранить либо условие, либо значение
    FWhenCondStatement: TObjectList;
    //Список выражений, которые выполняются на when
    FWhenStatement: TObjectList;
    //Выражение которое выполняется на else
    FElseStatement: TsqlStatement;

  protected
    procedure ParseStatement; override;
    procedure BuildStatement(out sql: String); override;

  public
    constructor Create(AParser: TsqlParser); override;
    destructor Destroy; override;

    //По условию
    property ByCondition: Boolean read FByCondition;
    //Список.Может хранить либо условие, либо значение
    property WhenCondStatement: TObjectList read FWhenCondStatement;
    //Список выражений, которые выполняются на when
    property WhenStatement: TObjectList read FWhenStatement;
    //Выражение которое выполняется на else
    property ElseStatement: TsqlStatement read FElseStatement;
    //Значение
    property Value: TsqlStatement read FValue;
  end;

  TsqlSimpleCase = class(TsqlBaseCase)
  private
    FValue: TsqlStatement;

  protected
    procedure ParseStatement; override;
    procedure BuildStatement(out sql: String); override;

  public
    constructor Create(AParser: TsqlParser); override;
    destructor Destroy; override;
  end;

  TsqlSearchedCase = class(TsqlBaseCase)
  protected
    procedure ParseStatement; override;
    procedure BuildStatement(out sql: String); override;

  public
    constructor Create(AParser: TsqlParser); override;
    destructor Destroy; override;
  end;

  TsqlExpr = class(TsqlStatement)
  private
    FExprs: TObjectList;
    FDone, FNeeded: TElementOptions;
    FSubName: String;
    FNested: Boolean;

    procedure SetSubName(const Value: String);

  protected
    procedure ParseStatement; override;
    procedure BuildStatement(out sql: String); override;
    function GetLastClass: TClass;

  public
    constructor Create(AParser: TsqlParser; const ANested: Boolean); reintroduce;
    destructor Destroy; override;

    property Exprs: TObjectList read FExprs;
    property ExprAttrs: TElementOptions read FDone;
    property ExprAsName: String read FSubName write SetSubName;

    property Nested: Boolean read FNested;
  end;


  TsqlSelect = class(TsqlStatement)
  private
    FFields: TObjectList;
    FDone: TClauses;

    procedure SetDone(const Value: TClauses);

  protected
    procedure ParseStatement; override;
    procedure BuildStatement(out sql: String); override;

  public
    constructor Create(AParser: TsqlParser); override;
    destructor Destroy; override;

    property Fields: TObjectList read FFields;
    property SelectAttrs: TClauses read FDone write SetDone;

  end;


  TsqlBoolean = class(TsqlStatement)
  private
    FBoolean: TclClause;

  protected
    procedure ParseStatement; override;
    procedure BuildStatement(out sql: String); override;

  public
    constructor Create(AParser: TsqlParser); override;
    destructor Destroy; override;

    property BooleanAttrs: TclClause read FBoolean; //write SetBoolean;

  end;

  TsqlCondition = class(TsqlStatement)
  private
    FStatements: TObjectList;

    FDone, FNeeded: TElementOptions;
    FConditionClause: TclClause;
    FInBrackets: Boolean;

    function GetLastClass: TClass;
    function GetClassByIndex(Index: Integer): TClass;
    function IsLastDataObject: Boolean;
    function FindClass(AClass: TClass): Boolean;

    procedure SetDone(const Value: TElementOptions);

  protected
    procedure ParseStatement; override;
    procedure BuildStatement(out sql: String); override;

  public
    constructor Create(AParser: TsqlParser); override;
    destructor Destroy; override;

    property InBrackets: Boolean read FInBrackets{ write FInBrackets};
    property Statements: TObjectList read FStatements;
    property ConditionClause: TclClause read FConditionClause;
    property ConditionAttrs: TElementOptions read FDone write SetDone;

  end;

  TsqlTable = class;

  TsqlJoin = class(TsqlStatement)
  private
    FJoinClause: TclClause;
    FDone, FNeeded: TElementOptions;

    FJoinTable: TsqlStatement;
    FConditions: TObjectList;

    procedure SetDone(const Value: TElementOptions);
    procedure SetJoinTable(const Value: TsqlStatement);

  protected
    procedure ParseStatement; override;
    procedure BuildStatement(out sql: String); override;

  public
    constructor Create(AParser: TsqlParser); override;
    destructor Destroy; override;

    property JoinClause: TclClause read FJoinClause; //write SetJoinClause;
    property JoinAttrs: TElementOptions read FDone write SetDone;

    property Conditions: TObjectList read FConditions write FConditions;
    property JoinTable: TsqlStatement read FJoinTable write SetJoinTable;

  end;

  TsqlTable = class(TsqlStatement)
  private
    FName: String;
    FAlias: String;
    FSubSelect: TsqlFull;

    FDone, FNeeded: TElementOptions;

    FJoins: TObjectList;

    procedure SetName(const Value: String);
    procedure SetAlias(const Value: String);
    procedure SetDone(const Value: TElementOptions);

  protected
    procedure ParseStatement; override;
    procedure BuildStatement(out sql: String); override;

  public
    constructor Create(AParser: TsqlParser); override;
    destructor Destroy; override;

    property TableName: String read FName write SetName;
    property TableAlias: String read FAlias write SetAlias;
    property TableAttrs: TElementOptions read FDone write SetDone;

    property Joins: TObjectList read FJoins;

  end;

  TsqlFrom = class(TsqlStatement)
  private
    FTables: TObjectList;

    function GetLastClass: TClass;

  protected
    procedure ParseStatement; override;
    procedure BuildStatement(out sql: String); override;

  public
    constructor Create(AParser: TsqlParser); override;
    destructor Destroy; override;

    property Tables: TObjectList read FTables;

    function FindTableByAlias(AnAlias: String): Boolean;

  end;


  TsqlWhere = class(TsqlStatement)
  private
    FConditions: TObjectList;

  protected
    procedure ParseStatement; override;
    procedure BuildStatement(out sql: String); override;

  public
    constructor Create(AParser: TsqlParser); override;
    destructor Destroy; override;

    property Conditions: TObjectList read FConditions;

  end;

  TsqlOrderBy = class(TsqlStatement)
  private
    FFields: TObjectList;
    FDone: TClauses;

    procedure SetDone(const Value: TClauses);

  protected
    procedure ParseStatement; override;
    procedure BuildStatement(out sql: String); override;

  public
    constructor Create(AParser: TsqlParser); override;
    destructor Destroy; override;

    property Fields: TObjectList read FFields;
    property OrderAttrs: TClauses read FDone write SetDone;

  end;

  TsqlUpdate = class(TsqlStatement)
  private
    FTable: TsqlTable;
    FWhere: TsqlWhere;

    FFieldConditions: TObjectList;

    FDone, FNeeded: TClauses;

    procedure SetDone(const Value: TClauses);

  protected
    procedure ParseStatement; override;
    procedure BuildStatement(out sql: String); override;

  public
    constructor Create(AParser: TsqlParser); override;
    destructor Destroy; override;

    property Table: TsqlTable read FTable;
    property Where: TsqlWhere read FWhere;
    property FieldConditions: TObjectList read FFieldConditions;

    property UpdateAttrs: TClauses read FDone write SetDone;

  end;

  TsqlInsert = class(TsqlStatement)
  private
    FTable: TsqlTable;
    FFields: TObjectList;
    FValues: TObjectList;
    FFull: TsqlFull;

    FDone, FNeeded: TClauses;

    procedure SetDone(const Value: TClauses);

  protected
    procedure ParseStatement; override;
    procedure BuildStatement(out sql: String); override;

  public
    constructor Create(AParser: TsqlParser); override;
    destructor Destroy; override;

    property Table: TsqlTable read FTable;
    property Fields: TObjectList read FFields;
    property Values: TObjectList read FValues;
    property Full: TsqlFull read FFull;

    property InsertAttrs: TClauses read FDone write SetDone;

  end;


  TsqlDelete = class(TsqlStatement)
  private
    FFrom: TsqlFrom;
    FWhere: TsqlWhere;
    FDone: TClauses;

  protected
    procedure ParseStatement; override;
    procedure BuildStatement(out sql: String); override;

  public
    constructor Create(AParser: TsqlParser); override;
    destructor Destroy; override;

    property From: TsqlFrom read FFrom;

  end;

  TsqlHaving = class;

  TsqlGroupBy = class(TsqlStatement)
  private
    FFields: TObjectList;
    FDone, FNeeded: TClauses;

    procedure SetDone(const Value: TClauses);

  protected
    procedure ParseStatement; override;
    procedure BuildStatement(out sql: String); override;

  public
    constructor Create(AParser: TsqlParser); override;
    destructor Destroy; override;

    property Fields: TObjectList read FFields;
    property GroupByAttrs: TClauses read FDone write SetDone;
  end;

  TsqlHaving = class(TsqlStatement)
  private
    FConditions: TObjectList;

  protected
    procedure ParseStatement; override;
    procedure BuildStatement(out sql: String); override;

  public
    constructor Create(AParser: TsqlParser); override;
    destructor Destroy; override;

    property Conditions: TObjectList read FConditions;
  end;

  TsqlUnion = class(TsqlStatement)
  private
    FFull: TsqlFull;
    FDone, FNeeded: TClauses;

    procedure SetDone(const Value: TClauses);

  protected
    procedure ParseStatement; override;
    procedure BuildStatement(out sql: String); override;

  public
    constructor Create(AParser: TsqlParser); override;
    destructor Destroy; override;

    property Full: TsqlFull read FFull;
    property UnionAttrs: TClauses read FDone write SetDone;

  end;


  TsqlPlanItem = class(TsqlStatement)
  private
    FDone, FNeeded: TClauses;

    FTable: TsqlTable;
    FFields: TObjectList;

    procedure SetDone(const Value: TClauses);

  protected
    procedure ParseStatement; override;
    procedure BuildStatement(out sql: String); override;

  public
    constructor Create(AParser: TsqlParser); override;
    destructor Destroy; override;

    property Table: Tsqltable read FTable;
    property Fields: TObjectList read FFields;
    property PlanAttrs: TClauses read FDone write SetDone;

  end;

  TsqlPlanExpr = class(TsqlStatement)
  private
    FDone: TclClause;
    FNeeded: TClauses;
    FItems: TObjectList;

  protected
    procedure ParseStatement; override;
    procedure BuildStatement(out sql: String); override;

  public
    constructor Create(AParser: TsqlParser); override;
    destructor Destroy; override;

    property Items: TObjectList read FItems;
    property PlanAttrs: TclClause read FDone;

  end;


  TsqlPlan = class(TsqlStatement)
  private
    FExprs: TObjectList;

  protected
    procedure ParseStatement; override;
    procedure BuildStatement(out sql: String); override;

  public
    constructor Create(AParser: TsqlParser); override;
    destructor Destroy; override;

    property Exprs: TObjectList read FExprs;

  end;


  TsqlFull = class(TsqlStatement)
  private
    FSelect: TsqlSelect;
    FFrom: TsqlFrom;
    FWhere: TsqlWhere;
    FOrderBy: TsqlOrderBy;
    FUnion: TsqlUnion;
    FGroupBy: TsqlGroupBy;
    FPlan: TsqlPlan;
    FHaving: TsqlHaving;
    FSubSelect: Boolean;

    FNeeded, FDone: TClauses;

    procedure SetDone(const Value: TClauses);

  protected
    procedure ParseStatement; override;
    procedure BuildStatement(out sql: String); override;

  public
    constructor Create(AParser: TsqlParser); override;
    destructor Destroy; override;

    property Select: TsqlSelect read FSelect;
    property From: TsqlFrom read FFrom;
    property Where: TsqlWhere read FWhere;
    property GroupBy: TsqlGroupBy read FGroupBy;
    property OrderBy: TsqlOrderBy read FOrderBy;
    property Plan: TsqlPlan read FPlan;
    property Having: TsqlHaving read FHaving;

    property FullAtts: TClauses read FDone write SetDone;

  end;


  TsqlParser = class
  private
    FToken: TsqlToken;
    FSource: String;
    FSql: String;

    FIndent: Integer;

    FIndex: Integer;
    FLength: Integer;

    FMainStatements: TObjectList;
    FComments: TStringList;
    FObjectClassName: String;

  protected
    procedure ReadNext;
    procedure RollBack;

    property Token: TsqlToken read FToken;

  public
    constructor Create(const AnSql: String);
    destructor Destroy; override;

    procedure Parse;
    procedure Build(out sql: String);
    procedure GetFields(out FList: TStringList);
    procedure GetTables(out FList: TStrings);

    property Statements: TObjectList read FMainStatements;
    property ObjectClassName: String read FObjectClassName write FObjectClassName;
    property Index: Integer read FIndex;
  end;

  EatParserError = class(Exception);

  procedure GetFieldsName(const AnSql: String; out FList: TStringList);
  procedure GetTablesName(const AnSql: String; out FList: TStrings);


implementation

uses
  gdcBaseInterface;

var
  ClausesList: TStringList;

procedure GetTablesName(const AnSql: String; out FList: TStrings);
begin
  FList.Clear;
  with TsqlParser.Create(AnSql) do
  try
    GetTables(FList);
  finally
    Free;
  end;
end;

procedure GetFieldsName(const AnSql: String; out FList: TStringList);
(* Если в запросе вместо перечисления полей используется *,
   то в список вместо названия полей будет занесена *;*)
begin
  FList.Clear;
  with TsqlParser.Create(AnSql) do
  try
    GetFields(FList);
  finally
    Free;
  end;
end;

function IsComment(const Text: String): Boolean;
begin
  if (Text > '') and (Text[1] = '@') then
    Result := True
  else
    Result := False;
end;

function GetRightTrim(const S: String): String;
var
  I: Integer;
begin
  I := Length(S);
  while (I > 0) and (S[I] <= ' ') do Dec(I);
  Result := Copy(S, I + 1, Length(S) - I);
end;

function GetLeftTrim(const S: String): String;
var
  I, L: Integer;
begin
  L := Length(S);
  I := 1;
  while (I <= L) and (S[I] <= ' ') do Inc(I);
  Result := Copy(S, 1, I - 1);
end;

function IsFVF(C: TObject): boolean;
begin
  Result := (C.ClassType = TsqlField) or (C.ClassType = TsqlValue) or
    (C.ClassType = TsqlFunction);
end;

function ClearToken: TsqlToken;
begin
  with Result do
  begin
    TokenType := ttNone;
    Text := '';
    Source := '';
    Symbol := #0;
    Clause := cNone;
    SymbolClause := scNone;
    TextKind := tkNone;
  end;
end;

function DestroyOutBrackets(St: String): String;
begin
  Result := Trim(St);
  if (Result[1] = '(') and (Result[Length(Result)] = ')') then
  begin
    Result[1] := ' ';
    Result[Length(Result)] := ' ';
  end;
end;

function IsClause(const Text: String): Boolean;
begin
  Assert(ClausesList <> nil);

  if ClausesList.IndexOf(UpperCase(Text)) = -1 then
    Result := False
  else
    Result := True;
end;

function CreateCaseClause(FParser: TsqlParser): TsqlBaseCase;
begin
  if (FParser.Token.TokenType <> ttClause) or (FParser.Token.Clause <> cCase) then
    raise EatParserError.Create('Invalid CASE clause');

  FParser.ReadNext;
  if FParser.Token.TokenType <> ttSpace then
    raise EatParserError.Create('Invalid CASE clause');

  FParser.ReadNext;
  Result := nil;

  case FParser.Token.TokenType of
    ttClause:
    begin
      if FParser.Token.Clause = cWhen then
        Result := TsqlSearchedCase.Create(FParser);
    end;

    ttWord, ttSymbolClause:
      Result := TsqlSimpleCase.Create(FParser);
  end;

  if Result = nil then
    raise EatParserError.Create('Invalid CASE clause');
end;

{ TsqlStatement }

constructor TsqlStatement.Create(AParser: TsqlParser);
begin
  FParser := AParser;
end;

destructor TsqlStatement.Destroy;
begin
  inherited Destroy;
end;

function TsqlStatement.GetIndent: Integer;
begin
  Result := FParser.FIndent;
end;

function TsqlStatement.GetSIndent: String;
begin
  Result := StringOfChar(' ', Indent);
end;

procedure TsqlStatement.SetIndent(const Value: Integer);
begin
  FParser.FIndent := Value;
end;

{ TsqlMath }

function GetMathClause(const C: Char): TMathClause;
var
  Mc: TMathClause;
begin
  for Mc := Low(TMathClause) to High(TMathClause) do
    if MathClauseText[Mc] = C then
    begin
      Result := Mc;
      Exit;
    end;

  Result := mcNone;
end;

function IsNumeric(const Text: String): Boolean;
var
  I: Integer;
begin
  for I := 1 to Length(Text) do
    if not (Text[I] in NumberSymbols) then
    begin
      Result := False;
      Exit;
    end;
  Result := True;
end;

function IsUserText(const Text: String): Boolean;
var
  I: Integer;
begin
  for I := 1 to Length(Text) do
    if Text[I] in ['''', ':'] then
    begin
      Result := True;
      Exit;
    end;

  Result := False;
end;

function IsNull(const Text: String): Boolean;
begin
  Result := AnsiCompareText(Text, ClauseText[cNull]) = 0;
end;


constructor TsqlMath.Create(AParser: TsqlParser);
begin
  inherited Create(AParser);

  FMath := TclMathClause.Create;
end;

destructor TsqlMath.Destroy;
begin
  FMath.Free;
  inherited Destroy;
end;

procedure TsqlMath.ParseStatement;
var
  CurrMath: TMathClause;
  I: Integer;
  MathStarted, MathOpStarted: Boolean;
begin
  MathStarted := False;
  MathOpStarted := False;

  with FParser do
  while not (Token.TokenType in [ttClear, ttNone]) do
  begin
    case Token.TokenType of

      ttSymbolClause:
      begin
        Break;
      end;

      ttClause:
      begin
        Break;
      end;

      ttSpace:
      begin
        if MathStarted or MathOpStarted then
          break;
      end;

      ttWord:
      begin
        case Token.TextKind of

          tkMath, tkMathOp:
          begin
            if
              not MathStarted and not MathOpStarted
                or
              (
                ((Token.TextKind = tkMath) and MathStarted)
                  xor
                ((Token.TextKind = tkMathOp) and MathOpStarted)
              )
            then begin
              MathStarted := Token.TextKind = tkMath;
              MathOpStarted := Token.TextKind = tkMathOp;

              for I := 1 to Length(Token.Text) do
              begin
                CurrMath := GetMathClause(Token.Text[I]);

                if CurrMath <> mcNone then
                  FMath.Add(CurrMath)
                else
                  Break;
              end;
            end else
              Break;
          end;

          else begin
            Break;
          end;
        end;
      end;
    end;

    ReadNext;
  end;
end;

procedure TsqlMath.BuildStatement(out sql: String);
var
  I: Integer;
begin
  sql := '';

  for I := 0 to FMath.Count - 1 do
    sql := sql + MathClauseText[FMath.Items[I]];
  sql := ' ' + sql + ' ';  
end;

function TsqlMath.GetIsOperation: Boolean;
begin
  Result := FMath.Cross([mcPlus, mcMinus, mcMultiple, mcDevide, mcStr]) <> [];
end;

{ TsqlValue }

constructor TsqlValue.Create(AParser: TsqlParser; const ANested: Boolean);
begin
  inherited Create(AParser);

  FValue := '';
  FSourceValue := '';
  FSubName := '';
  FCollation := '';

  FDone := [];
  FNeeded := [eoValue];
  FNested := ANested;
end;

destructor TsqlValue.Destroy;
begin
  inherited Destroy;
end;

procedure TsqlValue.ParseStatement;
begin
  with FParser do
  while not (Token.TokenType in [ttClear, ttNone]) do
  begin
    case FToken.TokenType of

      ttClause:
      begin
        case Token.Clause of
          cAs:
          begin
            if FNested then Break;
            Include(FNeeded, eoSubName);
          end;

          cCollate:
          begin
            if FNested then Break;
            Include(FNeeded, eoCollate);
          end;

          cAsc:
          begin
            if FNested then Break;
            Include(FDone, eoAsc);
          end;

          cDesc:
          begin
            if FNested then Break;
            Include(FDone, eoDesc);
          end;

          cNull:
          begin
            if (eoValue in FNeeded) then
            begin
              FValue := FToken.Text;
              FSourceValue := FToken.Source;
              Include(FDone, eoValue);
              Exclude(FNeeded, eoValue);
            end else
              raise EatParserError.Create('Ошибка в SQL-выражении: ' + Token.Text);
          end;

          else begin
            Break;
          end;
        end;
      end;

      ttSymbolClause:
      begin
        case Token.SymbolClause of
          scDot:
          begin
            FValue := FValue + '.';
            FSourceValue := FSourceValue + '.';
            Include(FNeeded, eoFraction);
          end
        else
          Break;
        end;
      end;

      ttWord:
      begin
        case Token.TextKind of

          tkUserText:
          begin
            if (eoValue in FNeeded) then
            begin
              FValue := FToken.Text;
              FSourceValue := FToken.Source;
              Include(FDone, eoValue);
              Exclude(FNeeded, eoValue);
            end else

            if eoFraction in FNeeded then
            begin
              Exclude(FNeeded, eoFraction);
              FValue := FValue + FToken.Text;
              FSourceValue := FSourceValue + FToken.Source;
              Include(FDone, eoFraction);
            end

            else
              raise EatParserError.Create('Ошибка в SQL-выражении: ' + Token.Text);
          end;

          tkText:
          begin
            if eoSubName in FNeeded then
            begin
              if FNested then Break;
              Include(FDone, eoSubName);
              Exclude(FNeeded, eoSubName);
              FSubName := Token.Text;
            end else

            if eoCollate in FNeeded then
            begin
              FCollation := Token.Text;
              Include(FDone, eoCollate);
              Exclude(FNeeded, eoCollate);
            end else

            if not (eoSubName in FDone) then
            begin
              if FNested then Break;
              FSubName := Token.Text;
              Include(FDone, eoSubName);
            end else
              Break;
          end;

          else begin
            Break;
          end;
        end;
      end;
    end;

    ReadNext;
  end;
end;

procedure TsqlValue.BuildStatement(out sql: String);
begin
  Assert(Assigned(gdcBaseManager));

  if IsNumeric(FValue) or IsUserText(FValue) or IsNull(FValue) then
    sql := FSourceValue
  else
    sql := ':' + FSourceValue;

  if eoCollate in FDone then
    sql := sql + ' ' + ClauseText[cCollate] + ' ' + FCollation;

  if eoSubName in FDone then
    sql := sql + ' ' + ClauseText[cAs] + ' ' + gdcBaseManager.AdjustMetaName(FSubName);

  if eoAsc in FDone then
    sql := sql + ' ' + ClauseText[cAsc]
  else

  if eoDesc in FDone then
    sql := sql + ' ' + ClauseText[cDesc];
   
end;

procedure TsqlValue.SetValue(const Value: String);
begin
  FSourceValue := Value;
end;

procedure TsqlValue.SetSubName(const Value: String);
begin
  FSubName := Value;
end;

procedure TsqlValue.SetCollation(const Value: String);
begin
  FCollation := Value;
end;

procedure TsqlValue.SetDone(const Value: TElementOptions);
begin
  FDone := Value;
end;

{ TsqlSelectParam }

procedure TsqlSelectParam.BuildStatement(out sql: String);
begin
  sql := FParamText + ' ' + FParamValue;
end;

constructor TsqlSelectParam.Create(AParser: TsqlParser);
begin
  inherited;

  FParamText := '';
  FParamValue := '';
end;

destructor TsqlSelectParam.Destroy;
begin
  inherited;
end;

procedure TsqlSelectParam.ParseStatement;
begin
  // There's nothing to do...
end;

{ TsqlField }

constructor TsqlField.Create(AParser: TsqlParser; const ANested: Boolean);
begin
  inherited Create(AParser);

  FName := '';
  FAlias := '';
  FSubName := '';
  FCollation := '';

  FDone := [];
  FNeeded := [eoName];

  FAs := nil;
  FComment := TStringList.Create;
  FNested := ANested;
end;

destructor TsqlField.Destroy;
begin
  FAs.Free;
  FComment.Free;
  inherited Destroy;
end;

procedure TsqlField.ParseStatement;
begin
  with FParser do
  while not (Token.TokenType in [ttClear, ttNone]) do
  begin
    case FToken.TokenType of

      ttClause:
      begin
        case Token.Clause of

          cAs:
          begin
            if FNested then
              Break;
            if eoName in FDone then
              Include(FNeeded, eoSubName);
          end;

          cCollate:
          begin
            Include(FNeeded, eoCollate);
          end;

          cAsc:
          begin
            Include(FDone, eoAsc);
          end;

          cDesc:
          begin
            Include(FDone, eoDesc);
          end;

          else begin
            Break;
          end;
        end;
      end;

      ttSymbolClause:
      begin
        case Token.SymbolClause of

          scDot:
          begin
            if eoName in FDone then
            begin
              FAlias := FName;
              FName := '';

              Include(FDone, eoAlias);
              Exclude(FDone, eoName);
              Include(FNeeded, eoName);
            end else
              raise EatParserError.Create('Ошибка в SQL-выражении: ' + Token.Text);
          end;

          scBracketOpen:
          begin
            if
              ([eoSubName, eoUnderCast] * FDone = [eoSubName, eoUnderCast]) and
              not (eoUserFunc in FDone) then
            begin
              FAs := TsqlFunction.Create(FParser, True);
              FAs.ParseStatement;
              Include(FDone, eoUserFunc);
              Continue;
            end else
              Break;
          end;

          else begin
            Break;
          end;
        end;
      end;

      ttWord:
      begin
        case Token.TextKind of

          tkText:
          begin
            if IsComment(Token.Text) then
            begin
              Comment.Add(Token.Text);
            end else

            if eoName in FNeeded then
            begin
              FName := Token.Text;
              Include(FDone, eoName);
              Exclude(FNeeded, eoName);
            end else

            if eoSubName in FNeeded then
            begin
              if FNested then Break;
              FSubName := Token.Text;
              Include(FDone, eoSubName);
              Exclude(FNeeded, eoSubName);
            end else

            if eoCollate in FNeeded then
            begin
              if FNested then Break;
              FCollation := Token.Text;
              Include(FDone, eoCollate);
              Exclude(FNeeded, eoCollate);
            end else

            if not (eoSubName in FDone) then
            begin
              if FNested then Break;
              FSubName := Token.Text;
              Include(FDone, eoSubName);
            end else

            begin
              Break;
            end;
          end;

          tkMathOp:
          begin
            if not (eoName in FDone) then
            begin
              if (Length(Token.Text) = 1) and
                (GetMathClause(Token.Text[1]) = mcMultiple)
              then begin
                FName := Token.Text;
                Include(FDone, eoName);
                Exclude(FNeeded, eoName);
              end else

              begin
                Break;
              end;
            end else
              Break;
          end;

          else begin
            Break;
          end;
        end;
      end;
    end;

    ReadNext;
  end;
end;

procedure TsqlField.BuildStatement(out sql: String);
var
  subsql: string;
  I: Integer;
begin
  Assert(Assigned(gdcBaseManager));

  sql := '';

  for I := 0 to Comment.Count - 1 do
    sql := sql + Comment[I] + ' ';

  if eoAlias in FDone then
    sql := sql + gdcBaseManager.AdjustMetaName(FAlias) + '.';

  if eoName in FDone then
    sql := sql + FName;

  if eoCollate in FDone then
    sql := sql + ' ' + ClauseText[cCollate] + ' ' + FCollation;

  if eoSubName in FDone then
  begin
    sql := sql + ' ' + ClauseText[cAs] + ' ' + gdcBaseManager.AdjustMetaName(FSubName);

    if
      [eoUnderCast, eoUserFunc, eoSubName] * FDone =
        [eoUnderCast, eoUserFunc, eoSubName]
    then begin
      FAs.BuildStatement(subsql);
      sql := sql + subsql;
    end;
  end;

  if eoAsc in FDone then
    sql := sql + ' ' + ClauseText[cAsc]
  else

  if eoDesc in FDone then
    sql := sql + ' ' + ClauseText[cDesc];
end;

procedure TsqlField.SetName(const Value: String);
begin
  FName := Value;
end;

procedure TsqlField.SetAlias(const Value: String);
begin
  FAlias := Value;
end;

procedure TsqlField.SetSubName(const Value: String);
begin
  FSubName := Value;
end;

procedure TsqlField.SetCollation(const Value: String);
begin
  FCollation := Value;
end;

procedure TsqlField.SetDone(const Value: TElementOptions);
begin
  FDone := Value;

  if eoUnderCast in FDone then
  begin
    if not Assigned(FAs) then
      FAs := TsqlFunction.Create(FParser, True);
  end else begin
    if Assigned(FAs) then
      FreeAndNil(FAs);
  end;
end;

{ TsqlFunction }

constructor TsqlFunction.Create(AParser: TsqlParser; const ANested: Boolean);
begin
  inherited Create(AParser);

  FArguments := TObjectList.Create;
  FJoins := TObjectList.Create;

  FDone := [];
  FNeeded := [eoClause, eoUserFunc];
  FFuncClause := TclClause.Create;

  FName := '';
  FSubName := '';
  FNested := ANested;
end;

destructor TsqlFunction.Destroy;
begin
  FArguments.Free;
  FJoins.Free;
  FFuncClause.Free;

  inherited Destroy;
end;

procedure TsqlFunction.ParseStatement;
var
  CurrArg: TsqlStatement;
  BracketCount: Integer;
  WasBracket: Boolean;
  WasComma: Boolean;
  CommaCount: Integer;
  CurrFunction: TsqlFunction;
  WasInBracket: Boolean;
begin
  BracketCount := 0;
  //Указывает на то, были ли в выражении скобки
  WasBracket := False;
  CommaCount := 0;
  WasComma := False;
  WasInBracket := (FParser.Token.SymbolClause = scBracketOpen);

  with FParser do
  while not (Token.TokenType in [ttClear, ttNone]) do
  begin
    case Token.TokenType of

      ttClause:
      begin
        case Token.Clause of
          cCast:
          begin
            if not (eoClause in FDone) then
            begin
              Include(FDone, eoClause);
              FFuncClause.Add(Token.Clause);

              Exclude(FNeeded, eoClause);
              Exclude(FNeeded, eoUserFunc);
              ReadNext;

              CurrArg := TsqlCast.Create(FParser);
              CurrArg.ParseStatement;
              FArguments.Add(CurrArg);
              Continue;
            end else
            begin
              CurrArg := TsqlFunction.Create(FParser, True);
              CurrArg.ParseStatement;
              FArguments.Add(CurrArg);
              Continue;
            end
          end;
          cSubstring:
          begin
            if not (eoClause in FDone) then
            begin
              Include(FDone, eoClause);
              FFuncClause.Add(Token.Clause);

              Exclude(FNeeded, eoClause);
              Exclude(FNeeded, eoUserFunc);
              ReadNext;

              CurrArg := TsqlSubString.Create(FParser);
              CurrArg.ParseStatement;
              FArguments.Add(CurrArg);
              Continue;
            end else
            begin
              CurrArg := TsqlFunction.Create(FParser, True);
              CurrArg.ParseStatement;
              FArguments.Add(CurrArg);
              Continue;
            end
          end;
          cCase:
          begin
            CurrArg := TsqlCase.Create(FParser);
            CurrArg.ParseStatement;
            FArguments.Add(CurrArg);
            Continue;
          end;

          cSum, cAvg, cMax, cMin, cUpper,
          cCount, cGen_id, cFirst, cSkip:
          begin
            if BracketCount > 0 then
            begin
              CurrArg := TsqlFunction.Create(FParser, True);
              CurrArg.ParseStatement;
              FArguments.Add(CurrArg);
              Continue;
            end

            else if not (eoClause in FDone) then
            begin
              Include(FDone, eoClause);
              FFuncClause.Add(Token.Clause);

              Exclude(FNeeded, eoClause);
              Exclude(FNeeded, eoUserFunc);
            end
          end;

          cAll, cDistinct:
          begin
            FFuncClause.Add(Token.Clause);
          end;

          cIn, cIs, cNull, cNot:
          begin
            if BracketCount > 0 then
            begin
              CurrArg := TsqlCondition.Create(FParser);

              if (FArguments.Count > 0) and (FArguments.Last <> nil) and
                (CommaCount < FArguments.Count) then
              with FArguments do
              begin
                if BracketCount > 0 then
                begin
                  OwnsObjects := False;
                  (CurrArg as TsqlCondition).FStatements.Add(Extract(Last));
                  OwnsObjects := True;
                end else
                begin
                  CurrFunction := TsqlFunction.Create(FParser, True);
                  CurrFunction.AssignAndClear(Self);
                  (CurrArg as TsqlCondition).FStatements.Add(CurrFunction);
                end;
              end;

              Exclude(FNeeded, eoClause);
              Exclude(FNeeded, eoUserFunc);
              CurrArg.ParseStatement;
              FArguments.Add(CurrArg);
              Continue;
              //raise EatParserError.Create('Ошибка в SQL-выражении: ' + Token.Text)
            end
            else
              Break;
          end;

          cExtract:
          begin
            if not (eoClause in FDone) then
            begin
              Include(FDone, eoClause);
              FFuncClause.Add(Token.Clause);

              Exclude(FNeeded, eoClause);
              Exclude(FNeeded, eoUserFunc);
              Include(FNeeded, eoSubClause);
            end;
          end;

//function Extract has specific description
//(For example, SELECT extract (hour from creationdate) from gd_document)
//therefor subfucntions day, hour, minute and e.t. need special processing
          cDay, cHour, cMinute, cMonth, cSecond,
          cWeakday, cYear, cYearday:
          begin
            if FFuncClause.Include(cExtract) and (eoSubClause in FNeeded) then
            begin
              Include(FDone, eoSubClause);
              Exclude(FNeeded, eoSubClause);

              FFuncClause.Add(Token.Clause);

              ReadNext;
              while Token.SymbolClause <> scBracketClose do
              begin
                if (Token.TokenType <> ttSpace) then
                begin
                  CurrArg := TsqlValue.Create(FParser, True);
                  (CurrArg as TsqlValue).Value := Token.Text;
                  FArguments.Add(CurrArg);
                end;

                ReadNext;
              end;

              Continue;
           end else
              raise EatParserError.Create('Ошибка в SQL-выражении: ' + Token.Text);
          end;

          cSelect:
          begin
            if BracketCount > 0 then
            begin
              Exclude(FNeeded, eoClause);
              Exclude(FNeeded, eoUserFunc);

              CurrArg := TsqlFull.Create(FParser);
              CurrArg.ParseStatement;
              FArguments.Add(CurrArg);
              Continue;
            end;
          end;

          cAs:
          begin
            //У вложенной функции не может быть as-наименования
            if Nested  then
              Break
            else if (BracketCount = 0) then
            begin
              Include(FNeeded, eoSubName);
            end else
              raise EatParserError.Create('Ошибка в SQL-выражении: ' + Token.Text);
          end;

          cLeft, cRight, cJoin, cInner, cOuter, cFull:
          begin
            CurrArg := TsqlJoin.Create(FParser);
            FJoins.Add(CurrArg);
            CurrArg.ParseStatement;
            Continue;
          end;

          else begin
            Break;
          end;
        end;
      end;

      ttSymbolClause:
      begin
        case Token.SymbolClause of

          scBracketOpen:
          begin
            if BracketCount <= 0 then
            begin
               Inc(BracketCount);
               WasBracket := True;
            end

            else begin
              if (BracketCount < FArguments.Count) or
                ((not WasComma) and (FArguments.Count > 0)) then
              begin
                RollBack;
                while Token.TokenType = ttSpace do
                  RollBack;
                FArguments.Delete(FArguments.Count - 1);

                CurrArg := TsqlFunction.Create(FParser, True);
                FArguments.Add(CurrArg);
                CurrArg.ParseStatement;
                Continue;
              end else begin
                CurrArg := TsqlFunction.Create(FParser, True);
                CurrArg.ParseStatement;
                FArguments.Add(CurrArg);
                Continue;
              end;
            end;
          end;

          scBracketClose:
          begin
            if BracketCount = 0 then Break;
            Dec(BracketCount);
            if BracketCount = 0 then
            begin
              if (FFuncClause.Cross([cFirst, cSkip]) <> []) then
              begin
                Break;
              end
              else if WasInBracket then
              begin
                ReadNext;
                Break;
              end;
            end;
          end;

          scComma:
          begin
            if BracketCount = 0 then
              Break
            else
              Inc(CommaCount);
          end;
        end;
      end;

      ttWord:
      begin
        case Token.TextKind of

          tkUserText:
          begin
            CurrArg := TsqlValue.Create(FParser, True);
            if (FFuncClause.Cross([cFirst, cSkip]) <> []) and
               (BracketCount = 0) then
            begin
              (CurrArg as TsqlValue).Value := Token.Text;
              FArguments.Add(CurrArg);
              ReadNext;
              Break;
            end
            else
            begin
              CurrArg.ParseStatement;
              FArguments.Add(CurrArg);
              Continue;
            end;
          end;

          tkText:
          begin
            if (FNeeded = []) and (CommaCount = FArguments.Count) then
            begin
              CurrArg := TsqlField.Create(FParser, True);

              if FFuncClause.Include(cCast) then
                (CurrArg as TsqlField).FieldAttrs :=
                  (CurrArg as TsqlField).FieldAttrs + [eoUnderCast];

              CurrArg.ParseStatement;
              FArguments.Add(CurrArg);
              Continue;
            end else begin
              if (eoUserFunc in FNeeded) and (not WasBracket) and (BracketCount = 0) then
              begin
                FName := Token.Text;

                Include(FDone, eoUserFunc);
                Exclude(FNeeded, eoUserFunc);
                Exclude(FNeeded, eoClause);
              end else

              if (eoSubName in FNeeded) and (BracketCount = 0) then
              begin
                FSubName := Token.Text;
                Exclude(FNeeded, eoSubName);
                Include(FDone, eoSubName);
              end else

              if not (eoAlias in FDone) and (BracketCount = 0) then
              begin
                FSubName := Token.Text;
                Exclude(FNeeded, eoAlias);
                Include(FDone, eoAlias);
              end else

              if (FNeeded = [eoClause, eoUserFunc]) and (BracketCount > 0) and
                (FFuncClause.Count = 0) then
              begin
                FNeeded := [];

                CurrArg := TsqlExpr.Create(FParser, True);
                CurrArg.ParseStatement;
                FArguments.Add(CurrArg);

                Continue;
              end else
                raise EatParserError.Create('Ошибка в SQL-выражении: ' + Token.Text);
            end;
          end;

          tkMathOp:
          begin
            if (FDone * [eoClause, eoUserFunc] <> []) and
              (Token.Text = '*') and (FArguments.Count = 0) then
            begin
              CurrArg := TsqlField.Create(FParser, True);
              CurrArg.ParseStatement;
              FArguments.Add(CurrArg);
              Continue;
            end else

            if (FDone * [eoClause, eoUserFunc] = []) and
              (Token.Text = '*') and (BracketCount = 0) then
            begin
              Break;
            end else

            begin
              CurrArg := TsqlExpr.Create(FParser, True);

              if (FArguments.Count > 0) and (FArguments.Last <> nil) and
                (CommaCount < FArguments.Count) then
              with FArguments do
              begin
                if BracketCount > 0 then
                begin
                  OwnsObjects := False;
                  (CurrArg as TsqlExpr).FExprs.Add(Extract(Last));
                  OwnsObjects := True;
                end else
                begin
                  CurrFunction := TsqlFunction.Create(FParser, True);
                  CurrFunction.AssignAndClear(Self);
                  (CurrArg as TsqlExpr).Exprs.Add(CurrFunction);
                end;
              end;

              Exclude(FNeeded, eoClause);
              Exclude(FNeeded, eoUserFunc);
              CurrArg.ParseStatement;
              FArguments.Add(CurrArg);
              Continue;
            end;
          end;

          tkMath:
          begin
            if BracketCount > 0 then
            begin
              CurrArg := TsqlExpr.Create(FParser, True);

              if (FArguments.Count > 0) and (FArguments.Last <> nil) and
                (CommaCount < FArguments.Count) then
              with FArguments do
              begin
                if BracketCount > 0 then
                begin
                  OwnsObjects := False;
                  (CurrArg as TsqlExpr).FExprs.Add(Extract(Last));
                  OwnsObjects := True;
                end else
                begin
                  CurrFunction := TsqlFunction.Create(FParser, True);
                  CurrFunction.AssignAndClear(Self);
                  (CurrArg as TsqlExpr).Exprs.Add(CurrFunction);
                end;
              end;

              Exclude(FNeeded, eoClause);
              Exclude(FNeeded, eoUserFunc);
              CurrArg.ParseStatement;
              FArguments.Add(CurrArg);
              Continue;
              //raise EatParserError.Create('Ошибка в SQL-выражении: ' + Token.Text)
            end
            else
              Break;
          end;

          else begin
            Break;
          end;
        end;
      end;
    end;
    if Token.SymbolClause = scComma then
      WasComma := True
    else if Token.TokenType <> ttSpace then
      WasComma := False;
    ReadNext;
  end;
end;

procedure TsqlFunction.BuildStatement(out sql: String);
var
  I: Integer;
  subsql: String;
  AddSt: String;
  ArgSt: String;
begin
  sql := '';

  if eoUserFunc in FDone then
  begin
    sql := sql + FName + '('
  end else

  if FFuncClause.Count > 0 then
    for I := 0 to FFuncClause.Count - 1 do
      if FFuncClause.Items[I] in [cDistinct, cAll] then
        sql := sql + ClauseText[FFuncClause.Items[I]] + ' '
      else if sql = '' then
          sql := sql + ClauseText[FFuncClause.Items[I]] + '('
      else
          sql := sql + ClauseText[FFuncClause.Items[I]] + ' ';

  if (FFuncClause.Count = 0) and not (eoUserFunc in FDone) then
    sql := sql + '(';

  if FFuncClause.Include(cExtract) then
   AddSt := ' '
  else
   AddSt := ', ';

  ArgSt := '';
  for I := 0 to FArguments.Count - 1 do
  begin
    (FArguments[I] as TsqlStatement).BuildStatement(subsql);
    ArgSt := ArgSt + subsql;

    if I < FArguments.Count - 1 then
      ArgSt := ArgSt + AddSt;
  end;

{  if ((FArguments.Count > 1) or (ArgSt[1] <> '(') or (ArgSt[Length(ArgSt)] <> ')'))
  then}
    sql := sql + ArgSt + ')';
{  else
    sql := Copy(sql, 1, Length(sql) - 1) + ArgSt;}

  if eoSubName in FDone then
    sql := sql + ' AS ' + gdcBaseManager.AdjustMetaName(FSubName);

  if eoAlias in FDone then
    sql := sql + ' ' + gdcBaseManager.AdjustMetaName(FSubName);

  for I := 0 to FJoins.Count - 1 do
  begin
    (FJoins[I] as TsqlStatement).BuildStatement(subsql);
    sql := sql + ' ' + subsql;
  end;
end;

function TsqlFunction.GetLastClass: TClass;
begin
  if FArguments.Count > 0 then
    Result := FArguments.Items[FArguments.Count - 1].ClassType
  else
    Result := nil;
end;

procedure TsqlFunction.SetName(const Value: String);
begin
  FName := Value;
end;

procedure TsqlFunction.SetSubName(const Value: String);
begin
  FSubName := Value;
end;

procedure TsqlFunction.AssignAndClear(AsqlFunction: TsqlFunction);
var
  I: Integer;
begin
  FArguments.Clear;
  FJoins.Clear;
  
  AsqlFunction.Arguments.OwnsObjects := False;
  for I := AsqlFunction.Arguments.Count - 1 downto 0 do
    FArguments.Insert(0, AsqlFunction.Arguments.Extract(AsqlFunction.Arguments[I]));
  AsqlFunction.Arguments.OwnsObjects := True;

  AsqlFunction.Joins.OwnsObjects := False;
  for I := AsqlFunction.Joins.Count - 1 downto 0 do
    FJoins.Insert(0, AsqlFunction.Joins.Extract(AsqlFunction.Joins[I]));
  AsqlFunction.Joins.OwnsObjects := True;

  FName := AsqlFunction.FuncName;
  FSubName := AsqlFunction.FuncAsName;
  FFuncClause.Assign(AsqlFunction.FuncClause);
  AsqlFunction.Clear;
end;

procedure TsqlFunction.Clear;
begin
  FArguments.Clear;
  FJoins.Clear;

  FDone := [];
  FNeeded := [eoClause, eoUserFunc];
  FFuncClause.Clear;

  FName := '';
  FSubName := '';
end;

{ TsqlExpr }

constructor TsqlExpr.Create(AParser: TsqlParser; const ANested: Boolean);
begin
  inherited Create(AParser);

  FExprs := TObjectList.Create;
  FDone := [];
  FNeeded := [];
  FSubName := '';

  FNested := ANested;
end;

destructor TsqlExpr.Destroy;
begin
  FExprs.Free;

  inherited Destroy;
end;

procedure TsqlExpr.ParseStatement;
var
  CurrStatement: TsqlStatement;

begin
  with FParser do
  while not (Token.TokenType in [ttClear, ttNone]) do
  begin
    case Token.TokenType of
      ttClause:
      begin
        case Token.Clause of
          cSum, cAvg, cMax, cMin, cUpper,
          cCast, cCount, cFirst, cSkip, cExtract, cSubString:
          begin
            CurrStatement := TsqlFunction.Create(FParser, True);
            FExprs.Add(CurrStatement);
            CurrStatement.ParseStatement;
            Continue;
          end;

          cCase:
          begin
            CurrStatement := TsqlCase.Create(FParser);
            FExprs.Add(CurrStatement);
            CurrStatement.ParseStatement;
            Continue;
          end;

          cSelect:
          begin
            CurrStatement := TsqlFull.Create(FParser);
            CurrStatement.ParseStatement;
            FExprs.Add(CurrStatement);
            Continue;
          end;

          cAs:
          begin
            //Вложенное выражение не может иметь as-наименования
            if FNested then
              Break
            else
              Include(FNeeded, eoSubName);
          end;

        else
          Break;
        end;
      end;

      ttSymbolClause:
      begin
        case Token.SymbolClause of
          scBracketOpen:
          begin
            if (FExprs.Count > 0) and (TObject(FExprs.Last) is TsqlField) then
            begin
              // if it function
              RollBack;
              while Token.TokenType = ttSpace do
                RollBack;
              FExprs.Delete(FExprs.Count - 1);
            end;

            CurrStatement := TsqlFunction.Create(FParser, True);
            FExprs.Add(CurrStatement);
            CurrStatement.ParseStatement;
            Continue;
          end;
        else
          Break;
        end;
      end;

      ttWord:
      begin
        case Token.TextKind of

          tkMathOp, tkMath:
          begin
            CurrStatement := TsqlMath.Create(FParser);
            CurrStatement.ParseStatement;
            FExprs.Add(CurrStatement);
            Continue;
          end;

          tkText:
          begin
            if (eoSubName in FNeeded) or (GetLastClass <> TsqlMath) and
              (GetLastClass <> nil) then
            begin
              Include(FDone, eoSubName);
              Exclude(FNeeded, eoSubName);
              FSubName := Token.Text;
            end else

            begin
              CurrStatement := TsqlField.Create(FParser, True);
              FExprs.Add(CurrStatement);
              CurrStatement.ParseStatement;
              Continue;
            end;
          end;

          tkUserText:
          begin
            CurrStatement := TsqlValue.Create(FParser, True);
            (CurrStatement as TsqlValue).Value := Token.Source;
            FExprs.Add(CurrStatement);
          end;

          else begin
            Break;
          end;
        end;
      end;
    end;

    ReadNext;
  end;
end;

procedure TsqlExpr.BuildStatement(out sql: String);
var
  I: Integer;
  subsql: String;
  CurrStatement: TsqlStatement;
begin
  Assert(Assigned(gdcBaseManager));

  sql := '';

  for I := 0 to FExprs.Count - 1 do
  begin
    CurrStatement := FExprs[I] as TsqlStatement;
    CurrStatement.BuildStatement(subsql);

    if CurrStatement is TsqlMath then
      sql := sql + {' ' + }subsql{ + ' '}
    else
      sql := sql + subsql;
  end;

  if eoSubName in FDone then
    sql := sql + ' ' + ClauseText[cAs] + ' ' + gdcBaseManager.AdjustMetaName(FSubName);
end;

procedure TsqlExpr.SetSubName(const Value: String);
begin
  FSubName := Value;
end;

function TsqlExpr.GetLastClass: TClass;
begin
  if Exprs.Count > 0 then
    Result := Exprs.Items[Exprs.Count - 1].ClassType
  else
    Result := nil;
end;

{ TsqlSelect }

constructor TsqlSelect.Create(AParser: TsqlParser);
begin
  inherited Create(AParser);

  FFields := TObjectList.Create;
  FDone := [];
end;

destructor TsqlSelect.Destroy;
begin
  FFields.Free;

  inherited Destroy;
end;

procedure TsqlSelect.ParseStatement;
var
  CurrStatement, TheStatement, OldStatement: TsqlStatement;
  CommaCount: Integer;
  PriorToken: TsqlToken;
  WasSpace: Boolean;
begin
  CommaCount := 0;
  PriorToken := ClearToken;

  with FParser do
  while not (Token.TokenType in [ttClear, ttNone]) do
  begin
    case Token.TokenType of

      ttSymbolClause:
      begin
        case Token.SymbolClause of

          scBracketOpen:
          begin
            if (cDistinct in FDone) and (FFields.Count = 0) then
              Exclude(FDone, cDistinct);

            RollBack;

            if FFields.Count > 0 then
            begin
              if (FFields[FFields.Count - 1] is TsqlField) then
              begin
                WasSpace := False;
                while Token.TokenType = ttSpace do
                begin
                  RollBack;
                  WasSpace := True;
                end;

                if (AnsiCompareText(TsqlField(FFields[FFields.Count - 1]).FieldName, Token.Text) = 0)
                then
                begin
                  FFields.Delete(FFields.Count - 1);
                  while Token.TokenType = ttSpace do
                    RollBack;
                end else if WasSpace then
                  ReadNext;
              end;
            end;

            CurrStatement := TsqlFunction.Create(FParser, False);
            FFields.Add(CurrStatement);
            CurrStatement.ParseStatement;
            Continue;
          end;
          scComma:
          begin
            Inc(CommaCount);
          end;
        end;
      end;

      ttClause:
      begin
        case Token.Clause of
          cSum, cAvg, cMax, cMin, cUpper,
          cCast, cCount, cFirst, cSkip, cExtract, cGen_ID, cSubString:
          begin
            CurrStatement := TsqlFunction.Create(FParser, False);
            FFields.Add(CurrStatement);
            CurrStatement.ParseStatement;
            Continue;
          end;

          cCase:
          begin
            CurrStatement := TsqlCase.Create(FParser);
            FFields.Add(CurrStatement);
            CurrStatement.ParseStatement;
            Continue;
          end;

          cSelect, cDistinct, cAll:
          begin
            Include(FDone, Token.Clause);
          end;

          else begin
            Break;
          end;
        end;
      end;

      ttWord:
      begin
        case Token.TextKind of

          tkMathOp:
          begin
            if
              (CommaCount = FFields.Count) and
              (Length(Token.Text) = 1) and
              (GetMathClause(Token.Text[1]) = mcMultiple)
            then begin
              CurrStatement := TsqlField.Create(FParser, True);
              FFields.Add(CurrStatement);
              CurrStatement.ParseStatement;
              Continue;
            end else

            begin
              CurrStatement := TsqlExpr.Create(FParser, False);

              if (FFields.Count > 0) and (FFields.Last <> nil) and (CommaCount < FFields.Count) then
              begin
                FFields.OwnsObjects := False;
                (CurrStatement as TsqlExpr).FExprs.
                  Add(FFields.Extract(FFields.Last));
                FFields.OwnsObjects := True;
              end;

              CurrStatement.ParseStatement;
              FFields.Add(CurrStatement);
              Continue;
            end;
          end;

          tkText:
          begin
            CurrStatement := TsqlField.Create(FParser, False);
            FFields.Add(CurrStatement);
            CurrStatement.ParseStatement;
            if (FFields[FFields.Count - 1] as TsqlField).FieldName = '' then
              FFields.Delete(FFields.Count - 1);
            Continue;
          end;

          tkUserText:
          begin
            CurrStatement := TsqlValue.Create(FParser, False);
            FFields.Add(CurrStatement);
            CurrStatement.ParseStatement;

            if (FFields.Count > 1) then
            begin
              TheStatement := FFields[FFields.Count - 2] as TsqlStatement;

              if
                (TheStatement is TsqlField)
                  and
                (
                  (AnsiCompareText((TheStatement as TsqlField).FName, 'first') = 0)
                    or
                  (AnsiCompareText((TheStatement as TsqlField).FName, 'skip') = 0)
                )
              then begin
                OldStatement := CurrStatement;

                CurrStatement := TsqlSelectParam.Create(FParser);
                (CurrStatement as TsqlSelectParam).FParamText :=
                  (TheStatement as TsqlField).FName;
                (CurrStatement as TsqlSelectParam).FParamValue :=
                  (OldStatement as TsqlValue).FValue;

                FFields.Delete(FFields.Count - 1);
                FFields.Delete(FFields.Count - 1);

                FFields.Add(CurrStatement);
                CurrStatement.ParseStatement;
              end;
            end;

            Continue;
          end;

          else begin
            Break;
          end;
        end;
      end;
    end;

    PriorToken := Token;
    ReadNext;
  end;

end;

procedure TsqlSelect.BuildStatement(out sql: String);
var
  I: Integer;
  subsql: string;
begin
  sql := sql + SIndent;

  sql := ClauseText[cSelect] + ' ';

  if cDistinct in FDone then
    sql := sql + ClauseText[cDistinct] + ' '

  else if cAll in FDone then
    sql := sql + ClauseText[cAll] + ' ';

  Indent := Indent + 2;
  sql := sql + #13#10 + SIndent;

  for I := 0 to FFields.Count - 1 do
  begin
    (FFields[I] as TsqlStatement).BuildStatement(subsql);
    sql := sql + subsql;

    if (I < FFields.Count - 1) then
    begin
      if not ((FFields[I] is TsqlSelectParam) or
        ((FFields[I] is TsqlFunction) and
        ((FFields[I] as TsqlFunction).FuncClause.Cross([cFirst, cSkip]) <> [])))then
        sql := sql + ', ' + #13#10 + SIndent
      else
        sql := sql + ' ' + #13#10 + SIndent
    end;
  end;

  Indent := Indent - 2;
  sql := sql;
end;

procedure TsqlSelect.SetDone(const Value: TClauses);
begin
  FDone := Value;
end;

{ TsqlBoolean }

constructor TsqlBoolean.Create(AParser: TsqlParser);
begin
  inherited Create(AParser);
  FBoolean := TclClause.Create;
end;

destructor TsqlBoolean.Destroy;
begin
  FBoolean.Free;
  inherited Destroy;
end;

procedure TsqlBoolean.ParseStatement;
begin
  with FParser do
  while not (Token.TokenType in [ttClear, ttNone]) do
  begin
    case Token.TokenType of

      ttSymbolClause:
      begin
        Break;
      end;

      ttClause:
      begin
        case Token.Clause of

          cAnd, cOr, cNot:
          begin
            FBoolean.Add(Token.Clause);
          end;

          else begin
            Break;
          end;
        end;
      end;

      ttWord:
      begin
        Break;
      end;
    end;

    ReadNext;
  end;
end;

procedure TsqlBoolean.BuildStatement(out sql: String);
var
  Ch: array[0..63] of Char;
  I: Integer;
begin
  Ch := ' ';
  for I := 0 to FBoolean.Count - 1 do
  begin
    StrCat(Ch, PChar(ClauseText[FBoolean.Items[I]]));
    StrCat(Ch, ' ');
  end;

  sql := StrPas(Ch);
end;

{ TsqlCondition }

constructor TsqlCondition.Create(AParser: TsqlParser);
begin
  inherited Create(AParser);

  FStatements := TObjectList.Create;

  FDone := [];
  FNeeded := [eoClause];
  FConditionClause := TclClause.Create;
  FInBrackets := False;
end;

destructor TsqlCondition.Destroy;
begin
  FStatements.Free;
  FConditionClause.Free;

  inherited Destroy;
end;

procedure TsqlCondition.ParseStatement;
var
  CurrStatement: TsqlStatement;
  BracketCount: Integer;
begin
  FInBrackets := FParser.Token.SymbolClause = scBracketOpen;
  BracketCount := 0;

  with FParser do
  while not (Token.TokenType in [ttClear, ttNone]) do
  begin
    case Token.TokenType of

      ttSymbolClause:
      begin
        case Token.SymbolClause of

          scBracketOpen:
          begin
            if FConditionClause.Count = 0 then
            begin
              if (GetLastClass = TsqlField) then
              begin
                RollBack;
                while Token.TokenType = ttSpace do
                  RollBack;
                FStatements.Delete(FStatements.Count - 1);

                CurrStatement := TsqlFunction.Create(FParser, True);
                FStatements.Add(CurrStatement);
                CurrStatement.ParseStatement;
                Continue;
              end else

              if (GetLastClass = TsqlMath) then
              begin
                CurrStatement := TsqlFunction.Create(FParser, True);
                FStatements.Add(CurrStatement);
                CurrStatement.ParseStatement;
                Continue;
              end else

              begin
                if BracketCount > 0 then
                begin
                  CurrStatement := TsqlCondition.Create(FParser);
                  FStatements.Add(CurrStatement);
                  CurrStatement.ParseStatement;
                  Continue;
                end else
                  Inc(BracketCount);
              end;

            end else

            if GetLastClass = TsqlBoolean then
            begin
              CurrStatement := TsqlCondition.Create(FParser);
              FStatements.Add(CurrStatement);
              CurrStatement.ParseStatement;
              Continue;
            end else

            begin
              CurrStatement := TsqlFunction.Create(FParser, True);
              FStatements.Add(CurrStatement);
              CurrStatement.ParseStatement;
              Continue;
            end;
          end;

          scBracketClose:
          begin
            if BracketCount = 0 then Break;
            Dec(BracketCount);

            if BracketCount = 0 then
            begin
              ReadNext;
              Break;
            end;
          end;

          else begin
            Break;
          end;
        end;
      end;

      ttClause:
      begin
        case Token.Clause of

          cContaining:
          begin
            if IsLastDataObject and (eoClause in FNeeded)
              and not (eoSubClause in FNeeded) then
            begin
              FConditionClause.Add(Token.Clause);

              Include(FDone, eoClause);
              Exclude(FNeeded, eoClause);
            end else
              raise EatParserError.Create('Ошибка в SQL-выражении: ' + Token.Text);
          end;

          cStarting:
          begin
            if IsLastDataObject and (eoClause in FNeeded)
              and not (eoSubClause in FNeeded) then
            begin
              FConditionClause.Add(Token.Clause);

              Include(FDone, eoClause);
              Include(FNeeded, eoSubClause);

              Exclude(FNeeded, eoClause);
            end else
              raise EatParserError.Create('Ошибка в SQL-выражении: ' + Token.Text);
          end;

          cWith:
          begin
            if FConditionClause.Include(cStarting) and (eoSubClause in FNeeded) then
            begin
              FConditionClause.Add(Token.Clause);
              Include(FDone, eoSubClause);
              Exclude(FNeeded, eoSubClause);
            end else
              raise EatParserError.Create('Ошибка в SQL-выражении: ' + Token.Text);
          end;

          cBetween:
          begin
            if IsLastDataObject and (eoClause in FNeeded)
              and not (eoSubClause in FNeeded) then
            begin
              FConditionClause.Add(Token.Clause);

              Include(FDone, eoClause);
              Include(FNeeded, eoSubClause);

              Exclude(FNeeded, eoClause);
            end else
              raise EatParserError.Create('Ошибка в SQL-выражении: ' + Token.Text);
          end;

          cLike{, cEscape}:
          begin
            if IsLastDataObject and (eoClause in FNeeded)
              and not (eoSubClause in FNeeded) then
            begin
              FConditionClause.Add(Token.Clause);
              Include(FDone, eoClause);
              Include(FNeeded, eoSubClause);

              Exclude(FNeeded, eoClause);
            end else
              raise EatParserError.Create('Ошибка в SQL-выражении: ' + Token.Text);
          end;

          cEscape:
          begin
            if FConditionClause.Include(cLike) and (eoSubClause in FNeeded) then
            begin
              FConditionClause.Add(Token.Clause);
              Include(FDone, eoSubClause);
              Exclude(FNeeded, eoSubClause);
            end else
              raise EatParserError.Create('Ошибка в SQL-выражении: ' + Token.Text);
          end;

          cIn:
          begin
            if {IsLastDataObject and} (eoClause in FNeeded)
              and not (eoSubClause in FNeeded) then
            begin
              FConditionClause.Add(Token.Clause);
              Include(FDone, eoClause);

              Exclude(FNeeded, eoClause);
            end else
              raise EatParserError.Create('Ошибка в SQL-выражении: ' + Token.Text);
          end;

          cAll, cSome, cAny:
          begin
            if (GetLastClass = TsqlMath) and (eoClause in FNeeded)
              and not (eoSubClause in FNeeded) then
            begin
              FConditionClause.Add(Token.Clause);
              Include(FDone, eoClause);

              Exclude(FNeeded, eoClause);
            end else
              raise EatParserError.Create('Ошибка в SQL-выражении: ' + Token.Text);
          end;

          cIs:
          begin
            if {IsLastDataObject and} (eoClause in FNeeded)
              and not (eoSubClause in FNeeded) then
            begin
              FConditionClause.Add(Token.Clause);
              Include(FDone, eoClause);

              Exclude(FNeeded, eoClause);
              Include(FNeeded, eoSubClause);
            end else
              raise EatParserError.Create('Ошибка в SQL-выражении: ' + Token.Text);
          end;

          cNull:
          begin
            if FConditionClause.Include(cIs) and (eoSubClause in FNeeded) then
            begin
              FConditionClause.Add(Token.Clause);
              Include(FDone, eoSubClause);
              Exclude(FNeeded, eoSubClause);
            end else
              raise EatParserError.Create('Ошибка в SQL-выражении: ' + Token.Text);
          end;

          {cAll, cSome, cAny, }cExists, cSingular:
          begin
            if (FStatements.Count = 0) and (eoClause in FNeeded)
              and not (eoSubClause in FNeeded) then
            begin
              FConditionClause.Add(Token.Clause);
              Include(FDone, eoClause);

              Exclude(FNeeded, eoClause);
            end else

            if (FStatements.Count > 0) and (GetLastClass = TsqlBoolean) then
            begin
              CurrStatement := TsqlCondition.Create(FParser);
              FStatements.Add(CurrStatement);
              CurrStatement.ParseStatement;
              Continue;
            end else
              raise EatParserError.Create('Ошибка в SQL-выражении: ' + Token.Text);
          end;

          cNot:
          begin
            if (IsLastDataObject and ([eoClause, eoSubClause] * FNeeded <> []))
              or ((FConditionClause.Count > 0) and (FConditionClause.Items[0] = cIs)) then
            begin
              FConditionClause.Add(Token.Clause);
            end else

            if (GetLastClass = nil) or (GetLastClass = TsqlCondition) then
            begin
              CurrStatement := TsqlBoolean.Create(FParser);
              FStatements.Add(CurrStatement);
              CurrStatement.ParseStatement;
              Continue;
            end else

            begin
              Break;
            end;
          end;

          cAnd:
          begin
            if FConditionClause.Include(cBetween) and (eoSubClause in FNeeded) then
            begin
              if IsLastDataObject then
              begin
                FConditionClause.Add(Token.Clause);
                Include(FDone, eoSubClause);
                Exclude(FNeeded, eoSubClause);
              end else
                raise EatParserError.Create('Ошибка в SQL-выражении: ' + Token.Text);
            end else begin
              if (GetLastClass = TsqlCondition) or (BracketCount > 0) then
              begin
                CurrStatement := TsqlBoolean.Create(FParser);
                FStatements.Add(CurrStatement);
                CurrStatement.ParseStatement;
                Continue;
              end else
                Break;
            end;
          end;

          cOr:
          begin
            if (GetLastClass = TsqlCondition) or (BracketCount > 0) then
            begin
              CurrStatement := TsqlBoolean.Create(FParser);
              FStatements.Add(CurrStatement);
              CurrStatement.ParseStatement;
              Continue;
            end else
              Break;
          end;

          cSum, cAvg, cMax, cMin, cUpper,
          cCast, cCount, cGen_id, cSelect, cFirst, cSkip, cSubString:
          begin
            if GetLastClass = TsqlBoolean then
            begin
              CurrStatement := TsqlCondition.Create(FParser);
              FStatements.Add(CurrStatement);
              CurrStatement.ParseStatement;
              Continue;
            end else

            begin
              if Token.Clause = cSelect then
              begin
                CurrStatement := TsqlFull.Create(FParser);
              end else
              begin
                CurrStatement := TsqlFunction.Create(FParser, True);
              end;
              FStatements.Add(CurrStatement);
              CurrStatement.ParseStatement;
              Continue;
            end;
          end;

          cCase:
          begin
            CurrStatement := TsqlCase.Create(FParser);
            FStatements.Add(CurrStatement);
            CurrStatement.ParseStatement;
            Continue;
          end;

          else begin
            Break;
          end;
        end;
      end;

      ttWord:
      begin
        if GetLastClass = TsqlBoolean then
        begin
          CurrStatement := TsqlCondition.Create(FParser);
          FStatements.Add(CurrStatement);
          CurrStatement.ParseStatement;
          Continue;
        end else

        case Token.TextKind of

          tkUserText:
          begin
            CurrStatement := TsqlValue.Create(FParser, True);
            FStatements.Add(CurrStatement);
            CurrStatement.ParseStatement;
            Continue;
          end;

          tkMath:
          begin
            CurrStatement := TsqlMath.Create(FParser);
            FStatements.Add(CurrStatement);
            CurrStatement.ParseStatement;
            Continue;
          end;

          tkMathOp:
          begin
            CurrStatement := TsqlExpr.Create(FParser, True);

            if (FStatements.Count > 0) and (FStatements.Last <> nil) and IsFVF(FStatements.Last) then
            with FStatements do
            begin
              OwnsObjects := False;
              (CurrStatement as TsqlExpr).FExprs.Add(Extract(Last));
              OwnsObjects := True;
            end;

            CurrStatement.ParseStatement;
            FStatements.Add(CurrStatement);
            Continue;
          end;

          tkText:
          begin
            CurrStatement := TsqlField.Create(FParser, True);
            FStatements.Add(CurrStatement);
            CurrStatement.ParseStatement;
            Continue;
          end;

          else begin
            Break;
          end;
        end;

      end;

    end;

    ReadNext;
  end;
end;

procedure TsqlCondition.BuildStatement(out sql: String);
var
  I, K, J: Integer;
  subsql: String;
begin
  if (eoClause in FDone) then
  begin
    sql := SIndent;

    if FConditionClause.Cross([{cAll, cSome, cAny, }cExists, cSingular]) <> [] then
    begin
      for I := 0 to FConditionClause.Count - 1 do
        sql := sql + ClauseText[FConditionClause.Items[I]] + ' ';

      for I := 0 to FStatements.Count - 1 do
      begin
        (FStatements[I] as TsqlStatement).BuildStatement(subsql);
        sql := sql + subsql;
      end;
    end else

    if FConditionClause.Cross([cAll, cSome, cAny]) <> [] then
    begin
      for I := 0 to FStatements.Count - 2 do
      begin
        (FStatements[I] as TsqlStatement).BuildStatement(subsql);
        sql := sql + subsql;
      end;

      for I := 0 to FConditionClause.Count - 1 do
        sql := sql + ClauseText[FConditionClause.Items[I]] + ' ';

      (FStatements[FStatements.Count - 1] as TsqlStatement).BuildStatement(subsql);
      sql := sql + subsql;

    end else
    begin
      if eoSubClause in FDone then
      begin
        J := 0;
        if FConditionClause.Cross([cBetween, cAnd]) = [cBetween, cAnd] then
        begin
          if FStatements.Count <> 3 then
            raise EatParserError.Create('Ошибка при построении запроса!');


          (FStatements[0] as TsqlStatement).BuildStatement(subsql);
          sql := sql + subsql;

          if FConditionClause.Include(cNot) then
            sql := sql + ' ' + ClauseText[cNot];

          sql := sql + ' ' + ClauseText[cBetween];

          (FStatements[1] as TsqlStatement).BuildStatement(subsql);
          sql := sql + ' ' + subsql;

          sql := sql + ' ' + ClauseText[cAnd];

          (FStatements[2] as TsqlStatement).BuildStatement(subsql);
          sql := sql + ' ' + subsql;

          J := 3;
        end else

        if FConditionClause.Include(cStarting) then
        begin
          (FStatements[0] as TsqlStatement).BuildStatement(subsql);
          sql := sql + subsql + ' ' + ClauseText[cStarting] + ' ' + ClauseText[cWith];

          (FStatements[1] as TsqlStatement).BuildStatement(subsql);
          sql := sql + ' ' + subsql;

          J := 2;
        end else

        if FConditionClause.Include(cIs) then
        begin
          if FStatements.Count > 0 then
            (FStatements[0] as TsqlStatement).BuildStatement(subsql)
          else
            subsql := '';  
          sql := sql + subsql + ' ' + ClauseText[cIs] + ' ';

          if FConditionClause.Include(cNot) then
            sql := sql + ClauseText[cNot] + ' ';

          if FConditionClause.Include(cNull) then
            sql := sql + ClauseText[cNull];

          J := 1;
        end;

        if FConditionClause.Include(cLike) then
        begin
          (FStatements[0] as TsqlStatement).BuildStatement(subsql);
          sql := sql + subsql;

          sql := sql + ' ' + ClauseText[cLike];

          (FStatements[1] as TsqlStatement).BuildStatement(subsql);
          sql := sql + ' ' + subsql;

          if FConditionClause.Include(cEscape) then
          begin
            sql := sql + ' ' + ClauseText[cEscape];

            (FStatements[2] as TsqlStatement).BuildStatement(subsql);
            sql := sql + ' ' + subsql;

            J := 3;
          end else
            J := 2;
        end;

        sql := sql + SIndent;
        //J - содержит количество уже прочитанных условий
        for I := J to  FStatements.Count - 1 do
        begin
          (FStatements[I] as TsqlStatement).BuildStatement(subsql);
          sql := sql + subsql;
        end;

      end else begin
        I := 0;

        while True do
        begin
          (FStatements[I] as TsqlStatement).BuildStatement(subsql);
          sql := sql + subsql;

          Inc(I);

          if
            (I >= FStatements.Count - 1)
              or
            (
              (I < FStatements.Count - 1)
                and
              (
                not (FStatements[I] is TsqlMath)
                  or
                not (FStatements[I] as TsqlMath).IsOperation
              )
            )
          then
            Break;
        end;

        sql := sql + ' ';

        for K := 0 to FConditionClause.Count - 1 do
          sql := sql + ClauseText[FConditionClause.Items[K]] + ' ';

        for K := I to FStatements.Count - 1 do
        begin
          (FStatements[K] as TsqlStatement).BuildStatement(subsql);
          sql := sql + subsql;
        end;
      end;
    end;
  end else begin
    if FindClass(TsqlMath) then
    begin
      sql := SIndent;

      for K := 0 to FStatements.Count - 1 do
      begin
        (FStatements[K] as TsqlStatement).BuildStatement(subsql);
        if ((GetClassByIndex(K - 1) <> TsqlMath) and (FStatements[K] is TsqlMath)) or
           ((GetClassByIndex(K - 1) = TsqlMath) and not(FStatements[K] is TsqlMath)) then
           sql := sql + ' ' + subsql
        else
           sql := sql + subsql;
      end;
    end else begin

      sql := sql + SIndent;
      Indent := Indent + 2;

      for I := 0 to FStatements.Count - 1 do
      begin
        if FStatements[I] is TsqlCondition then
        begin
          (FStatements[I] as TsqlStatement).BuildStatement(subsql);
          sql := sql + #13#10 +  Trim(subsql) +  #13#10;
        end else begin
          (FStatements[I] as TsqlStatement).BuildStatement(subsql);
          sql := sql + SIndent + StringOfChar(' ', 2) + subsql;
        end;
      end;

      Indent := Indent - 2;
      sql := sql + SIndent;
    end;
  end;
  if FInBrackets then
    sql := GetLeftTrim(sql) + '(' +  Trim(sql) + ')' + GetRightTrim(sql);
end;

function TsqlCondition.GetLastClass: TClass;
begin
  if FStatements.Count > 0 then
    Result := FStatements[FStatements.Count - 1].ClassType
  else
    Result := nil;
end;

function TsqlCondition.GetClassByIndex(Index: Integer): TClass;
begin
  if (Index > 0) and (FStatements.Count > Index) then
    Result := FStatements[Index].ClassType
  else
    Result := nil;
end;

function TsqlCondition.IsLastDataObject: Boolean;
begin
  Result := (GetLastClass = TsqlField) or (GetLastClass = TsqlFunction)
    or (GetLastClass = TsqlValue)
end;

function TsqlCondition.FindClass(AClass: TClass): Boolean;
var
  I: Integer;
begin
  for I := 0 to FStatements.Count - 1 do
    if FStatements[I].ClassType = AClass then
    begin
      Result := True;
      Exit;
    end;

  Result := False;
end;

procedure TsqlCondition.SetDone(const Value: TElementOptions);
begin
  FDone := Value;
end;

{ TsqlJoin }

constructor TsqlJoin.Create(AParser: TsqlParser);
begin
  inherited Create(AParser);

  FJoinClause := TclClause.Create;

  FDone := [];
  FNeeded := [eoClause, eoOn];

  FConditions := TObjectList.Create;
  FJoinTable := nil;
end;

destructor TsqlJoin.Destroy;
begin
  FConditions.Free;
  FJoinClause.Free;

  if Assigned(FJoinTable) then
    FreeAndNil(FJoinTable);

  inherited Destroy;
end;

procedure TsqlJoin.ParseStatement;
var
  CurrStatement: TsqlStatement;
  BracketCount: Integer;
begin
  BracketCount := 0;

  with FParser do
  while not (Token.TokenType in [ttClear, ttNone]) do
  begin
    case Token.TokenType of

      ttSymbolClause:
      begin
        case Token.SymbolClause of
          scBracketOpen:
          begin
            if [eoClause, eoOn] * FDone = [eoClause, eoOn] then
            begin
              CurrStatement := TsqlCondition.Create(FParser);
              FConditions.Add(CurrStatement);
              CurrStatement.ParseStatement;
              Continue;
            end else

            if (FDone = [eoClause]) and (BracketCount = 0) and (FJoinTable = nil) then
            begin
              Inc(BracketCount);
              Include(FNeeded, eoComplicatedJoin);
            end else

            if (FDone = [eoClause]) and Assigned(FJoinTable) and
              (FJoinTable is TsqlTable) then
            begin
              RollBack;
              while Token.TokenType = ttSpace do
                RollBack;
              FreeAndNil(FJoinTable);

              FJoinTable := TsqlFunction.Create(FParser, False);
              FJoinTable.ParseStatement;
              Continue;
            end else
              raise EatParserError.Create('Ошибка в SQL-выражении: ' + Token.Text);
          end;

          scBracketClose:
          begin
            if BracketCount = 0 then Break;
            Dec(BracketCount);
          end;

          else begin
            Break;
          end;

        end;
      end;

      ttClause:
      begin
        case Token.Clause of

          cSelect:
          begin
            if eoComplicatedJoin in FNeeded then
            begin
              //Include(FDone, eoComplicatedJoin);
              Exclude(FNeeded, eoComplicatedJoin);

              Rollback;
              FJoinTable := TsqlTable.Create(FParser);
              FJoinTable.ParseStatement;
              Continue;
            end else
              raise EatParserError.Create('Ошибка в SQL-выражении: ' + Token.Text)
          end;

          cLeft, cRight, cInner, cOuter, cJoin, cFull:
          begin
            if FJoinClause.Include(Token.Clause) then
            begin
              if not FJoinClause.Include(cJoin) then
                raise EatParserError.Create('Ошибка в SQL-выражении: ' + Token.Text)
              else
                Break;
            end else

            if (Token.Clause in [cLeft, cRight, cInner, cOuter, cFull]) and
              FJoinClause.Include(cJoin)
            then
              Break;

            FJoinClause.Add(Token.Clause);

            if FJoinClause.Include(cJoin) then
            begin
              Include(FDone, eoClause);
              Exclude(FNeeded, eoClause);
            end;
          end;

          cOn:
          begin
            if eoClause in FDone then
            begin
              Include(FDone, eoOn);
              Exclude(FNeeded, eoOn);
            end else
              raise EatParserError.Create('Ошибка в SQL-выражении: ' + Token.Text);
          end;

          cAnd, cOr, cNot:
          begin
            CurrStatement := TsqlBoolean.Create(FParser);
            FConditions.Add(CurrStatement);
            CurrStatement.ParseStatement;
            Continue;
          end;

          else begin
            Break;
          end;
        end;
      end;

      ttWord:
      begin
        if eoComplicatedJoin in FNeeded then
        begin
          Include(FDone, eoComplicatedJoin);
          Exclude(FNeeded, eoComplicatedJoin);

          FJoinTable := TsqlTable.Create(FParser);
          FJoinTable.ParseStatement;
          Continue;
        end else

        if FDone * [eoClause, eoOn] = [eoClause, eoOn] then
        begin
          CurrStatement := TsqlCondition.Create(FParser);
          FConditions.Add(CurrStatement);
          CurrStatement.ParseStatement;
          Continue;
        end else

        if eoClause in FDone then
        begin
          FJoinTable := TsqlTable.Create(FParser);
          FJoinTable.ParseStatement;
          Continue;
        end else
          raise EatParserError.Create('Ошибка в SQL-выражении: ' + Token.Text);
      end;
    end;

    ReadNext;
  end;
end;

procedure TsqlJoin.BuildStatement(out sql: String);
var
  subsql: String;
  I: Integer;
begin
  for I := 0 to FJoinClause.Count - 1 do
    sql := sql + ClauseText[FJoinClause.Items[I]] +  ' ';

  FJoinTable.BuildStatement(subsql);

  if eoComplicatedJoin in FDone then
  begin
    sql := sql + #13#10 + SIndent + '(';
    Indent := Indent + 2;
    sql := sql + #13#10 + SIndent + subsql;
    Indent := Indent - 2;
    sql := sql + #13#10 + SIndent + ')';
  end else begin
    Indent := Indent + 2;
    sql := sql + #13#10 + SIndent + subsql;
    Indent := Indent - 2;

    sql := sql + #13#10 + SIndent + ClauseText[cOn] + ' ' + #13#10;

    Indent := Indent + 2;

    for I := 0 to FConditions.Count - 1 do
    begin
      (FConditions[I] as TsqlStatement).BuildStatement(subsql);

      if (FConditions[I] is TsqlBoolean) and (I > 0) then
        sql := sql + #13#10 + SIndent + StringOfChar(' ', 2) + subsql + #13#10
      else
        sql := sql + subsql;
    end;

    Indent := Indent - 2;
  end;
end;

procedure TsqlJoin.SetDone(const Value: TElementOptions);
begin
  FDone := Value;

  if eoClause in FDone then
  begin
    if not Assigned(FJoinTable) then
      FJoinTable := TsqlTable.Create(FParser);
  end else begin
    if Assigned(FJoinTable) then
      FreeAndNil(FJoinTable);
  end;
end;

procedure TsqlJoin.SetJoinTable(const Value: TsqlStatement);
begin
  if FJoinTable <> Value then
  begin
    FJoinTable.Free;
    FJoinTable := Value;
  end;
end;

{ TsqlTable }

constructor TsqlTable.Create(AParser: TsqlParser);
begin
  inherited Create(AParser);

  FName := '';
  FAlias := '';

  FDone := [];
  FNeeded := [eoName];

  FJoins := TObjectList.Create;
end;

destructor TsqlTable.Destroy;
begin
  FJoins.Free;
  FSubSelect.Free;

  inherited Destroy;
end;

procedure TsqlTable.ParseStatement;
var
  CurrStatement: TsqlStatement;
begin
  if (FParser.FToken.TokenType = ttSymbolClause) and
    (FParser.FToken.SymbolClause = scBracketOpen) then
  begin
    FNeeded := [];
    FSubSelect := TsqlFull.Create(FParser);
    FSubSelect.ParseStatement;
  end;

  with FParser do
  while not (Token.TokenType in [ttClear, ttNone]) do
  begin
    case Token.TokenType of

      ttSymbolClause:
      begin
        Break;
      end;

      ttClause:
      begin
        case Token.Clause of

          cLeft, cRight, cJoin, cInner, cOuter, cFull:
          begin
            CurrStatement := TsqlJoin.Create(FParser);
            FJoins.Add(CurrStatement);
            CurrStatement.ParseStatement;
            Continue;
          end;

          else begin
            Break;
          end;
        end;
      end;

      ttWord:
      begin
        case Token.TextKind of

          tkText:
          begin
            if IsComment(Token.Text) then
            begin
//              Comment.Add(Token.Text);
            end else

            if eoName in FNeeded then
            begin
              FName := Token.Text;

              Include(FDone, eoName);
              Exclude(FNeeded, eoName);
            end else

            if not (eoAlias in FDone) then
            begin
              FAlias := Token.Text;
              Include(FDone, eoAlias);
            end else
              Break;
          end;

          else begin
            Break;
          end;
        end;
      end;
    end;

    ReadNext;
  end;
end;

procedure TsqlTable.BuildStatement(out sql: String);
var
  subsql: String;
  I: Integer;
begin
  if FSubSelect = nil then
    sql := FName
  else begin
    FSubSelect.BuildStatement(sql);
  end;

  if eoAlias in FDone then
    sql := sql + ' ' + gdcBaseManager.AdjustMetaName(FAlias);

  Indent := Indent + 2;
  for I := 0 to FJoins.Count - 1 do
  begin
    (FJoins[I] as TsqlStatement).BuildStatement(subsql);
    sql := sql + #13#10 + SIndent + subsql;
  end;
  Indent := Indent - 2;
end;


procedure TsqlTable.SetName(const Value: String);
begin
  FName := Value;
end;

procedure TsqlTable.SetAlias(const Value: String);
begin
  FAlias := Value;
end;

procedure TsqlTable.SetDone(const Value: TElementOptions);
begin
  FDone := Value;
end;

{ TsqlFrom }

constructor TsqlFrom.Create(AParser: TsqlParser);
begin
  inherited Create(AParser);

  FTables := TObjectList.Create;
end;

destructor TsqlFrom.Destroy;
begin
  FTables.Free;
  inherited Destroy;
end;

procedure TsqlFrom.ParseStatement;
var
  CurrStatement: TsqlStatement;
  CommaCount: Integer;
begin
  CommaCount := 0;

  with FParser do
  while not (Token.TokenType in [ttClear, ttNone]) do
  begin
    case Token.TokenType of

      ttSymbolClause:
      begin
        case Token.SymbolClause of

          scBracketOpen:
          begin
            if GetLastClass = Tsqltable then
            begin
              RollBack;
              while Token.TokenType = ttSpace do
                RollBack;
              FTables.Delete(FTables.Count - 1);

              CurrStatement := TsqlFunction.Create(FParser, False);
              FTables.Add(CurrStatement);
              CurrStatement.ParseStatement;
              Continue;
            end else
            begin
              CurrStatement := TsqlTable.Create(FParser);
              FTables.Add(CurrStatement);
              CurrStatement.ParseStatement;
              Continue;
            end;
          end;

          scComma:
          begin
            Inc(CommaCount);
          end;

          else begin
            Break;
          end;
        end;
      end;

      ttClause:
      begin
        if Token.Clause <> cFrom then
          Break;
      end;

      ttWord:
      begin
        case Token.TextKind of

          tkText:
          begin
            if CommaCount = FTables.Count then
            begin
              CurrStatement := TsqlTable.Create(Fparser);
              FTables.Add(CurrStatement);
              CurrStatement.ParseStatement;
              Continue;
            end;
          end;

          else begin
            Break;
          end;
        end;
      end;
    end;

    ReadNext;
  end;
end;

procedure TsqlFrom.BuildStatement(out sql: String);
var
  subsql: String;
  I: Integer;
begin
  sql := ClauseText[cFrom] + ' ' + #13#10;

  Indent := Indent + 2;
  sql := sql + SIndent;

  for I := 0 to FTables.Count - 1 do
  begin
    (FTables[I] as TsqlStatement).BuildStatement(subsql);
    sql := sql + subsql;

    if I < FTables.Count - 1 then
      sql := sql + ', ' + #13#10 + SIndent;
  end;

  Indent := Indent - 2;
end;

function TsqlFrom.GetLastClass: TClass;
begin
  if FTables.Count > 0 then
    Result := FTables[FTables.Count - 1].ClassType
  else
    Result := nil;
end;

function TsqlFrom.FindTableByAlias(AnAlias: String): Boolean;
var
  I, J : Integer;
begin
  Result := False;
  for I := 0 to Tables.Count - 1 do
  begin
    if Tables[I] is TsqlTable then
    begin
      if AnsiCompareText((Tables[I] as TsqlTable).TableAlias, AnAlias) = 0 then
      begin
        Result := True;
        Break;
      end;
      for J := 0 to (Tables[I] as TsqlTable).Joins.Count - 1 do
      begin
        if (((Tables[I] as TsqlTable).Joins[J] as TsqlJoin).JoinTable is TsqlTable) then
         if AnsiCompareText((((Tables[I] as TsqlTable).Joins[J] as TsqlJoin).JoinTable as TsqlTable).TableAlias, AnAlias) = 0 then
         begin
           Result := True;
           Break;
         end;
      end;

    end
    else if Tables[I] is TsqlFunction then
    begin
      for J := 0 to (Tables[I] as TsqlFunction).Joins.Count - 1 do
      begin
        if (((Tables[I] as TsqlFunction).Joins[J] as TsqlJoin).JoinTable is TsqlTable) then
         if AnsiCompareText((((Tables[I] as TsqlFunction).Joins[J] as TsqlJoin).JoinTable as TsqlTable).TableAlias, AnAlias) = 0 then
         begin
           Result := True;
           Break;
         end;
      end;
    end;
  end;
end;

{ TsqlWhere }

constructor TsqlWhere.Create(AParser: TsqlParser);
begin
  inherited Create(AParser);
  FConditions := TObjectList.Create;
end;

destructor TsqlWhere.Destroy;
begin
  FConditions.Free;
  inherited Destroy;
end;

procedure TsqlWhere.ParseStatement;
var
  CurrStatement: TsqlStatement;
begin
  with FParser do
  while not (Token.TokenType in [ttClear, ttNone]) do
  begin
    case FToken.TokenType of

      ttClause:
      begin
        case Token.Clause of

          cWhere:
          begin
          end;

          cAnd, cOr, cNot:
          begin
            CurrStatement := TsqlBoolean.Create(FParser);
            FConditions.Add(CurrStatement);
            CurrStatement.ParseStatement;
            Continue;
          end;

          cAll, cSome, cAny,
          cExists, cSingular, cCast, cSubString, cIs:
          begin
            CurrStatement := TsqlCondition.Create(FParser);
            FConditions.Add(CurrStatement);
            CurrStatement.ParseStatement;
            Continue;
          end;

          cUpper:
          begin
            CurrStatement := TsqlCondition.Create(FParser);
            FConditions.Add(CurrStatement);
            CurrStatement.ParseStatement;
            Continue;
          end;

          else begin
            Break;
          end;
        end;
      end;

      ttSymbolClause:
      begin
        case Token.SymbolClause of

          scBracketOpen:
          begin
            CurrStatement := TsqlCondition.Create(FParser);
            FConditions.Add(CurrStatement);
            CurrStatement.ParseStatement;
            Continue;
          end;

          else begin
            Break;
          end;
        end;
      end;

      ttWord:
      begin
        CurrStatement := TsqlCondition.Create(FParser);
        FConditions.Add(CurrStatement);
        CurrStatement.ParseStatement;
        Continue;
      end;
    end;

    ReadNext;
  end;
end;

procedure TsqlWhere.BuildStatement(out sql: String);
var
  I: Integer;
  subsql: String;
begin
  Indent := Indent + 2;

  sql := ClauseText[cWhere] + ' ' + #13#10;

  for I := 0 to FConditions.Count - 1 do
  begin
    (FConditions[I] as TsqlStatement).BuildStatement(subsql);

    if (FConditions[I] is TsqlBoolean) and (I > 0) then
      sql := sql + #13#10 + SIndent + StringOfChar(' ', 2) + subsql + #13#10
    else
      sql := sql + subsql;
  end;

  Indent := Indent - 2;
end;

{ TsqlOrderBy }

constructor TsqlOrderBy.Create(AParser: TsqlParser);
begin
  inherited Create(AParser);

  FFields := TObjectList.Create;
  FDone := [];
end;

destructor TsqlOrderBy.Destroy;
begin
  FFields.Free;

  inherited Destroy;
end;

procedure TsqlOrderBy.ParseStatement;
var
  CurrStatement: TsqlStatement;
  CommaCount: Integer;
begin
  CommaCount := 0;

  with FParser do
  while not (Token.TokenType in [ttClear, ttNone]) do
  begin
    case Token.TokenType of

      ttSymbolClause:
      begin
        case Token.SymbolClause of

          scComma:
          begin
            Inc(CommaCount);
          end;

          else begin
            Break;
          end;
        end;
      end;

      ttClause:
      begin
        case Token.Clause of
          cOrder, cBy:
          begin
            Include(FDone, Token.Clause);
          end;

          else begin
            Break;
          end;
        end;
      end;

      ttWord:
      begin
        if ([cOrder, cBy] * FDone = [cOrder, cBy]) and
          (CommaCount = FFields.Count) then
        begin
          case Token.TextKind of

            tkText:
            begin
              CurrStatement := TsqlField.Create(FParser, False);
              FFields.Add(CurrStatement);
              CurrStatement.ParseStatement;
              Continue;
            end;

            tkUserText:
            begin
              CurrStatement := TsqlValue.Create(FParser, False);
              FFields.Add(CurrStatement);
              CurrStatement.ParseStatement;
              Continue;
            end;

          else
            Break;
          end;
        end else
          Break;
      end;
    end;

    ReadNext;
  end;
end;

procedure TsqlOrderBy.BuildStatement(out sql: String);
var
  I: Integer;
  subsql: string;
begin
  sql := ClauseText[cOrder] + ' ' + ClauseText[cBy] + ' ';

  Indent := Indent + 2;

  for I := 0 to FFields.Count - 1 do
  begin
    (FFields[I] as TsqlStatement).BuildStatement(subsql);

    sql := sql + #13#10 + SIndent + subsql;

    if (I < FFields.Count - 1) then
      sql := sql + ', ';
  end;

  Indent := Indent - 2;
end;

procedure TsqlOrderBy.SetDone(const Value: TClauses);
begin
  FDone := Value;
end;

{ TsqlUpdate }

constructor TsqlUpdate.Create(AParser: TsqlParser);
begin
  inherited Create(AParser);

  FTable := nil;
  FWhere := nil;

  FDone := [];
  FNeeded := [cUpdate, cSet];

  FFieldConditions := TObjectList.Create;
end;

destructor TsqlUpdate.Destroy;
begin
  FFieldConditions.Free;

  if Assigned(FTable) then
    FreeAndNil(FTable);

  if Assigned(FWhere) then
    FreeAndNil(FWhere);

  inherited Destroy;
end;

procedure TsqlUpdate.ParseStatement;
var
  CurrStatement: TsqlStatement;
  CommaCount: Integer;
begin
  CommaCount := 0;
  with FParser do
  while not (Token.TokenType in [ttClear, ttNone]) do
  begin
    case FToken.TokenType of

      ttClause:
      begin
        case Token.Clause of

          cUpdate:
          begin
            Include(FDone, cUpdate);
            Exclude(FNeeded, cUpdate);
          end;

          cSet:
          begin
            CommaCount := 0;
            Include(FDone, cSet);
            Exclude(FNeeded, cSet);
          end;

          cWhere:
          begin
            FWhere := TsqlWhere.Create(FParser);
            FWhere.ParseStatement;

            Include(FDone, cWhere);
            Continue;
          end;

          else begin
            Break;
          end;
        end;
      end;

      ttSymbolClause:
      begin
        case Token.SymbolClause of
          scComma:
          begin
            Inc(CommaCount);
          end;

          else begin
            Break;
          end;
        end;
      end;

      ttWord:
      begin
        case Token.TextKind of
          tkText:
          begin
            if (cUpdate in FDone) and not (cSet in FDone) then
            begin
              if not Assigned(FTable) then
              begin
                FTable := TsqlTable.Create(FParser);
                FTable.ParseStatement;
                Continue;
              end else
                raise EatParserError.Create('Ошибка в SQL-выражении: ' + Token.Text);
            end else begin
              if (cSet in FDone) and not (cWhere in FDone) and
                (CommaCount = FFieldConditions.Count) then
              begin
                CurrStatement := TsqlCondition.Create(FParser);
                CurrStatement.ParseStatement;
                FFieldConditions.Add(CurrStatement);
                Continue;
              end else
                Break;
            end;
          end;

          else begin
            Break;
          end;
        end;
      end;
    end;

    ReadNext;
  end;
end;

procedure TsqlUpdate.BuildStatement(out sql: String);
var
  subsql: String;
  I: Integer;
  CurrStatement: TsqlStatement;
begin
  sql := ClauseText[cUpdate] + ' ' + #13#10;

  if Assigned(FTable) then
  begin
    FTable.BuildStatement(subsql);
    sql := sql + subsql + ' ' + #13#10;
  end;

  sql := sql + ClauseText[cSet] + ' ' + #13#10;

  for I := 0 to FFieldConditions.Count - 1 do
  begin
    CurrStatement := FFieldConditions[I] as TsqlStatement;
    CurrStatement.BuildStatement(subsql);
    sql := sql + DestroyOutBrackets(subsql);

    if I < FFieldConditions.Count - 1 then
      sql := sql + ', ' + #13#10;
  end;

  if Assigned(FWhere) then
  begin
    FWhere.BuildStatement(subsql);
    sql := sql + ' ' + #13#10 + subsql;
  end;
end;

procedure TsqlUpdate.SetDone(const Value: TClauses);
begin
  FDone := Value;

  if cUpdate in FDone then
  begin
    if not Assigned(FTable) then
      FTable := tsqlTable.Create(FParser);
  end else begin
    if Assigned(FTable) then
      FreeAndNil(FTable);
  end;

  if cWhere in FDone then
  begin
    if not Assigned(FWhere) then
      FWhere := tsqlWhere.Create(FParser);
  end else begin
    if Assigned(FWhere) then
      FreeAndNil(FWhere);
  end;
end;

{ TsqlInsert }

constructor TsqlInsert.Create(AParser: TsqlParser);
begin
  inherited Create(AParser);

  FTable := nil;
  FValues := TObjectList.Create;
  FFields := TObjectList.Create;
  FFull := nil;

  FDone := [];
  FNeeded := [cInsert, cInto, cValues];
end;

destructor TsqlInsert.Destroy;
begin
  FValues.Free;
  FFields.Free;

  if Assigned(FTable) then
    FreeAndNil(FTable);

  if Assigned(FFull) then
    FreeAndNil(FFull);

  inherited Destroy;
end;

procedure TsqlInsert.ParseStatement;
var
  CurrStatement: TsqlStatement;
  BracketCount: Integer;
  CommaCount: Integer;
begin
  BracketCount := 0;
  CommaCount := 0;

  with FParser do
  while not (Token.TokenType in [ttClear, ttNone]) do
  begin
    case Token.TokenType of

      ttSymbolClause:
      begin
        case Token.SymbolClause of

          scComma:
          begin
            Inc(CommaCount);
          end;

          scBracketOpen:
          begin
            Inc(BracketCount);
          end;

          scBracketClose:
          begin
            if BracketCount = 0 then Break;
            Dec(BracketCount);
          end;

          else begin
            Break;
          end;
        end;
      end;

      ttClause:
      begin
        case Token.Clause of

          cInsert, cInto, cValues:
          begin
            Include(FDone, Token.Clause);
            Exclude(FNeeded, Token.Clause);

            if [cInsert, cInto, cValues] * FDone = [cInsert, cInto, cValues] then
              CommaCount := 0;
          end;

          cSelect:
          begin
            FFull := TsqlFull.Create(FParser);
            FFull.ParseStatement;
            Include(FDone, Token.Clause);
            Continue;
          end;

          else begin
            Break;
          end;
        end;
      end;

      ttWord:
      begin
        case Token.TextKind of

          tkText:
          begin
            if ([cInsert, cInto] * FDone = [cInsert, cInto]) and
              not (cValues in FDone) then
            begin
              if BracketCount > 0 then
              begin
                CurrStatement := TsqlField.Create(FParser, True);
                FFields.Add(CurrStatement);
                CurrStatement.ParseStatement;
                Continue;
              end else begin
                if not Assigned(FTable) then
                begin
                  FTable := TsqlTable.Create(FParser);
                  FTable.ParseStatement;
                  Continue;
                end else
                  raise EatParserError.Create('Ошибка в SQL-выражении: ' + Token.Text);
              end;
            end else

            if cValues in FDone then
            begin
              if BracketCount > 0 then
              begin
                CurrStatement := TsqlValue.Create(FParser, True);
                FValues.Add(CurrStatement);
                CurrStatement.ParseStatement;
                Continue;
              end else
                raise EatParserError.Create('Ошибка в SQL-выражении: ' + Token.Text);
            end else

            begin
              Break;
            end;
          end;

          tkUserText:
          begin
            if (BracketCount > 0) and (cValues in FDone) then
            begin
              CurrStatement := TsqlValue.Create(FParser, True);
              FValues.Add(CurrStatement);
              CurrStatement.ParseStatement;
              Continue;
            end else
              raise EatParserError.Create('Ошибка в SQL-выражении: ' + Token.Text);
          end;

          tkMathOp:
          begin
            if (BracketCount > 0) and (cValues in FDone) then
            begin
              CurrStatement := TsqlExpr.Create(FParser, True);

              if (FValues.Count > 0) and (FValues.Last <> nil) and (CommaCount < FValues.Count) then
              begin
                FValues.OwnsObjects := False;
                (CurrStatement as TsqlExpr).FExprs.
                  Add(FValues.Extract(FValues.Last));
                FValues.OwnsObjects := True;
              end;

              CurrStatement.ParseStatement;
              FValues.Add(CurrStatement);
              Continue;
            end else
              raise EatParserError.Create('Ошибка в SQL-выражении: ' + Token.Text);
          end;

          else begin
            Break;
          end;
        end;
      end;
    end;

    ReadNext;
  end;
end;

procedure TsqlInsert.BuildStatement(out sql: String);
var
  subsql: String;
  I: Integer;
  CurrStatement: TsqlStatement;
begin
  sql := ClauseText[cInsert] + ' ' + Clausetext[cInto] + ' ' + #13#10;

  if Assigned(FTable) then
  begin
    FTable.BuildStatement(subsql);
    sql := sql + subsql + ' ' + #13#10;
  end;

  sql := sql + '(';

  for I := 0 to FFields.Count - 1 do
  begin
    CurrStatement := FFields[I] as TsqlStatement;
    CurrStatement.BuildStatement(subsql);
    sql := sql + subsql;

    if I < FFields.Count - 1 then
      sql := sql + ', ' + #13#10;
  end;

  sql := sql + ') ' + ClauseText[cValues] + ' ' + #13#10;

  if FValues.Count > 0 then
  begin
    sql := sql + '(';

    for I := 0 to FValues.Count - 1 do
    begin
      CurrStatement := FValues[I] as TsqlStatement;
      CurrStatement.BuildStatement(subsql);
      sql := sql + subsql;

      if (I < FValues.Count - 1) then
        sql := sql + ', ' + #13#10;
    end;

    sql := sql + ')';
  end else

  if Assigned(FFull) then
  begin
    FFull.BuildStatement(subsql);
    sql := sql + ' ' + subsql + #13#10;
  end;
end;


procedure TsqlInsert.SetDone(const Value: TClauses);
begin
  FDone := Value;

  if cInsert in FDone then
  begin
    if not Assigned(FTable) then
      FTable := TsqlTable.Create(FParser);
  end else begin
    if Assigned(FTable) then
      FreeAndNil(FTable);
  end;

  if cSelect in FDone then
  begin
    if not Assigned(FFull) then
      FFull := TsqlFull.Create(FParser);
  end else begin
    if Assigned(FFull) then
      FreeAndNil(FFull);
  end;
end;


{ TsqlDelete }

procedure TsqlDelete.BuildStatement(out sql: String);
var
  subsql: String;
begin
  sql := ClauseText[cDelete] + ' ';

  if Assigned(FFrom) then
  begin
    FFrom.BuildStatement(subsql);
    sql := sql + subsql + ' ' + #13#10;
  end;

  if Assigned(FWhere) then
  begin
    FWhere.BuildStatement(subsql);
    sql := sql + '  ' + subsql + ' ' + #13#10;
  end;
end;

constructor TsqlDelete.Create(AParser: TsqlParser);
begin
  inherited;

  FFrom := nil;
  FWhere := nil;

  FDone := [];
end;

destructor TsqlDelete.Destroy;
begin
  if Assigned(FFrom) then
    FFrom.Free;
  if Assigned(FWhere) then
    FWhere.Free;

  inherited;
end;

procedure TsqlDelete.ParseStatement;
begin
  with FParser do
  while not (Token.TokenType in [ttClear, ttNone]) do
  begin
    case FToken.TokenType of

      ttClause:
      begin
        case Token.Clause of

          cDelete:
            Include(FDone, cDelete);

          cFrom:
          begin
            FFrom := TsqlFrom.Create(FParser);
            FFrom.ParseStatement;

            Include(FDone, cFrom);
            Continue;
          end;

          cWhere:
          begin
            FWhere := TsqlWhere.Create(FParser);
            FWhere.ParseStatement;

            Include(FDone, cWhere);
            Continue;
          end;

          else begin

            Break;
          end;
        end;
      end;

      ttSymbolClause:
      begin
        Break;
      end;

      ttWord:
      begin
        Break;
      end;
    end;

    ReadNext;
  end;
end;



{ TsqlGroupBy }

constructor TsqlGroupBy.Create(AParser: TsqlParser);
begin
  inherited Create(AParser);

  FFields := TObjectList.Create;

  FDone := [];
  FNeeded := [cGroup, cBy];
end;

destructor TsqlGroupBy.Destroy;
begin
  FreeAndNil(FFields);
  inherited Destroy;
end;

procedure TsqlGroupBy.ParseStatement;
var
  CurrStatement: TsqlStatement;
  CommaCount: Integer;
  BracketCount: Integer;

begin
  CommaCount := 0;
  BracketCount := 0;
  with FParser do
  while not (Token.TokenType in [ttClear, ttNone]) do
  begin
    case FToken.TokenType of

      ttClause:
      begin
        case Token.Clause of

          cGroup, cBy:
          begin
            Include(FDone, Token.Clause);
            Exclude(FNeeded, Token.Clause);
          end;

          else begin
            Break;
          end;

        end;
      end;

      ttWord:
      begin
        if ([cGroup, cBy] * FDone = [cGroup, cBy]) and
          (CommaCount = FFields.Count) then
        begin
          case Token.TextKind of

            tkText:
            begin
              CurrStatement := TsqlField.Create(FParser, True);
              FFields.Add(CurrStatement);
              CurrStatement.ParseStatement;
              Continue;
            end;

            tkUserText:
            begin
              CurrStatement := TsqlValue.Create(FParser, True);
              FFields.Add(CurrStatement);
              CurrStatement.ParseStatement;
              Continue;
            end;

          else
            Break;
          end;
        end else
          Break;
      end;

      ttSymbolClause:
      begin
        case Token.SymbolClause of
          scComma:
          begin
            Inc(CommaCount);
          end;

          scBracketOpen:
          begin
            if ([cGroup, cBy] * FDone = [cGroup, cBy])
            then begin
              if (CommaCount = FFields.Count - 1) then
              begin
                FFields.Delete(FFields.Count - 1);
                RollBack;
                while Token.TokenType = ttSpace do
                  RollBack;
              end;

              CurrStatement := TsqlFunction.Create(FParser, True);
              FFields.Add(CurrStatement);
              CurrStatement.ParseStatement;
              Continue;
            end;
          end;

          scBracketClose:
          begin
            if BracketCount < 1 then
              Break;
            Dec(BracketCount);
            if BracketCount = 0 then
            begin
              ReadNext;
              Break;
            end;
          end;

          else begin
            Break;
          end;
        end;
      end;
    end;

    ReadNext;
  end;
end;

procedure TsqlGroupBy.BuildStatement(out sql: String);
var
  CurrStatement: TsqlStatement;
  subsql: String;
  I: Integer;
begin
  if [cGroup, cBy] * FDone = [cGroup, cBy] then
  begin
    sql := sql + ClauseText[cGroup] + ' ' + ClauseText[cBy] + #13#10;

    for I := 0 to FFields.Count - 1 do
    begin
      CurrStatement := FFields[I] as TsqlStatement;
      CurrStatement.BuildStatement(subsql);
      sql := sql + '  ' + subsql;

      if I < FFields.Count - 1 then
        sql :=  sql + ', '#13#10;
    end;
  end;
end;

procedure TsqlGroupBy.SetDone(const Value: TClauses);
begin
  FDone := Value;
end;

{ TsqlHaving }

constructor TsqlHaving.Create(AParser: TsqlParser);
begin
  inherited;

  FConditions := TObjectList.Create;
end;

destructor TsqlHaving.Destroy;
begin
  FConditions.Free;

  inherited;
end;

procedure TsqlHaving.BuildStatement(out sql: String);
var
  I: Integer;
  subsql: String;
begin
  Indent := Indent + 2;

  sql := ClauseText[cHaving] + ' ' + #13#10;

  for I := 0 to FConditions.Count - 1 do
  begin
    (FConditions[I] as TsqlStatement).BuildStatement(subsql);

    if (FConditions[I] is TsqlBoolean) and (I > 0) then
      sql := sql + #13#10 + SIndent + StringOfChar(' ', 2) + subsql + #13#10
    else
      sql := sql + subsql;
  end;

  Indent := Indent - 2;
end;

procedure TsqlHaving.ParseStatement;
var
  CurrStatement: TsqlStatement;
begin
  with FParser do
  while not (Token.TokenType in [ttClear, ttNone]) do
  begin
    case FToken.TokenType of

      ttClause:
      begin
        case Token.Clause of

          cHaving:
          begin
          end;

          cAnd, cOr, cNot:
          begin
            CurrStatement := TsqlBoolean.Create(FParser);
            FConditions.Add(CurrStatement);
            CurrStatement.ParseStatement;
            Continue;
          end;

          cAll, cSome, cAny,
          cExists, cSingular:
          begin
            CurrStatement := TsqlCondition.Create(FParser);
            FConditions.Add(CurrStatement);
            CurrStatement.ParseStatement;
            Continue;
          end;

          cSum, cAvg, cMax, cMin, cUpper,
          cCast, cCount, cGen_id, cFirst, cSkip, cSubString:
          begin
            CurrStatement := TsqlCondition.Create(FParser);
            FConditions.Add(CurrStatement);
            CurrStatement.ParseStatement;
            Continue;
          end;
          
          cCase:
          begin
            CurrStatement := TsqlCondition.Create(FParser);
            FConditions.Add(CurrStatement);
            CurrStatement.ParseStatement;
            Continue;
          end;

          else begin
            Break;
          end;
        end;
      end;

      ttSymbolClause:
      begin
        case Token.SymbolClause of

          scBracketOpen:
          begin
            CurrStatement := TsqlCondition.Create(FParser);
            FConditions.Add(CurrStatement);
            CurrStatement.ParseStatement;
            Continue;
          end;

          else begin
            Break;
          end;
        end;
      end;

      ttWord:
      begin
        CurrStatement := TsqlCondition.Create(FParser);
        FConditions.Add(CurrStatement);
        CurrStatement.ParseStatement;
        Continue;
      end;
    end;

    ReadNext;
  end;
end;

{ TsqlUnion }

constructor TsqlUnion.Create(AParser: TsqlParser);
begin
  inherited Create(AParser);

  FFull := nil;

  FDone := [];
  FNeeded := [cUnion, cSelect];
end;

destructor TsqlUnion.Destroy;
begin
  if Assigned(FFull) then
    FreeAndNil(FFull);

  inherited Destroy;
end;

procedure TsqlUnion.ParseStatement;
begin
  with FParser do
  while not (Token.TokenType in [ttClear, ttNone]) do
  begin
    case FToken.TokenType of

      ttClause:
      begin
        case Token.Clause of

          cSelect:
          begin
            if cUnion in FDone then
            begin
              FFull := TsqlFull.Create(FParser);
              FFull.ParseStatement;

              Include(FDone, cSelect);
              Exclude(FNeeded, cSelect);

              Continue;
            end else
              raise EatParserError.Create('Ошибка в SQL-выражении: ' + Token.Text);
          end;

          cUnion:
          begin
            if cUnion in FDone then
              break;

            Include(FDone, Token.Clause);
            Exclude(FNeeded, Token.Clause);
          end;

          cAll:
          begin
            Include(FDone, Token.Clause);
            Exclude(FNeeded, Token.Clause);
          end;

          else begin
            Break;
          end;

        end;
      end;

      ttWord, ttSymbolClause:
      begin
        Break;
      end;
    end;

    ReadNext;
  end;
end;

procedure TsqlUnion.BuildStatement(out sql: String);
var
  subsql: String;
begin
  if cUnion in FDone then
  begin
    sql := #13#10 + ClauseText[cUnion];

    if cAll in FDone then
      sql := sql + '  ' + ClauseText[cAll];

    sql := sql + #13#10;

    if Assigned(FFull) then
    begin
      FFull.BuildStatement(subsql);
      sql := sql + subsql;
    end;
  end;
end;

procedure TsqlUnion.SetDone(const Value: TClauses);
begin
  FDone := Value;
end;


{ TsqlPlanItem }


constructor TsqlPlanItem.Create(AParser: TsqlParser);
begin
  inherited Create(AParser);

  FDone := [];
  FNeeded := [];

  FTable := nil;
  FFields := TObjectList.Create;
end;

destructor TsqlPlanItem.Destroy;
begin
  if Assigned(FTable) then
    FreeAndNil(FTable);

  FreeAndNil(FFields);

  inherited Destroy;
end;

procedure TsqlPlanItem.ParseStatement;
var
  CurrStatement: TsqlStatement;
  BracketCount: Integer;
begin
  BracketCount := 0;

  with FParser do
  while not (Token.TokenType in [ttClear, ttNone]) do
  begin
    case FToken.TokenType of

      ttClause:
      begin
        case Token.Clause of

          cNatural, cIndex, cOrder:
          begin
            Include(FDone, Token.Clause);
            Exclude(FNeeded, Token.Clause);
          end;

          else begin
            Break;
          end;

        end;
      end;

      ttWord:
      begin
        if FDone = [] then
        begin
          FTable := TsqlTable.Create(FParser);
          FTable.ParseStatement;
          Continue;
        end else begin
          CurrStatement := TsqlField.Create(FParser, True);
          CurrStatement.ParseStatement;
          FFields.Add(CurrStatement);

          Continue;
        end;
      end;

      ttSymbolClause:
      begin
        case Token.SymbolClause of

          scBracketOpen:
          begin
            Inc(BracketCount);
          end;

          scBracketClose:
          begin
            if BracketCount = 0 then Break;
            Dec(BracketCount);
          end;

          scComma:
          begin
            if BracketCount = 0 then
              Break;
          end;

          else begin
            Break;
          end;
        end;
      end;
    end;

    ReadNext;
  end;
end;

procedure TsqlPlanItem.BuildStatement(out sql: String);
var
  subsql: String;
  I: Integer;
  CurrStatement: TsqlStatement;
begin
  sql := '';

  if Assigned(FTable) then
  FTable.BuildStatement(subsql);
  sql := sql + subsql + ' ';

  if cNatural in FDone then
    sql := sql + ClauseText[cNatural] + ' ';

  if cIndex in FDone then
    sql := sql + ClauseText[cIndex] + ' ';

  if cOrder in FDone then
    sql := sql + ClauseText[cOrder] + ' ';

  if (FDone <> []) and not (cOrder in FDone) then
    sql := sql + '(';

  for I := 0 to FFields.Count - 1 do
  begin
    CurrStatement := FFields[I] as TsqlStatement;
    CurrStatement.BuildStatement(subsql);
    sql := sql + subsql;

    if I < FFields.Count - 1 then
      sql := sql + ', ';
  end;

  if (FDone <> []) and not (cOrder in FDone) then
    sql := sql + ')';
end;


procedure TsqlPlanItem.SetDone(const Value: TClauses);
begin
  FDone := Value;
end;

{ TsqlPlanExpr }


constructor TsqlPlanExpr.Create(AParser: TsqlParser);
begin
  inherited Create(AParser);

  FDone := TclClause.Create;
  FNeeded := [];

  FItems := TObjectList.Create;
end;

destructor TsqlPlanExpr.Destroy;
begin
  FDone.Free;
  inherited Destroy;
end;

procedure TsqlPlanExpr.ParseStatement;
var
  CurrStatement: TsqlStatement;
  BracketCount: Integer;
  Finished: Boolean;
  CommaCount: Integer;
begin
  BracketCount := 0;
  Finished := False;
  CommaCount := 0;

  with FParser do
  while not (Token.TokenType in [ttClear, ttNone]) do
  begin
    case FToken.TokenType of

      ttClause:
      begin
        case Token.Clause of

          cJoin, cSort, cMerge, cPlan:
          begin
            if (BracketCount = 0) and not Finished then
            begin
              FDone.Add(Token.Clause);
              Exclude(FNeeded, Token.Clause);
            end else

            if not Finished and (CommaCount = FItems.Count) then
            begin
              CurrStatement := TsqlPlanExpr.Create(FParser);
              FItems.Add(CurrStatement);
              CurrStatement.ParseStatement;
              Continue;
            end else

            begin
              Break;
            end;

          end;

          else begin
            Break;
          end;

        end;
      end;

      ttWord:
      begin
        if (BracketCount > 0) {and (CommaCount = FItems.Count) }then
        begin
          CurrStatement := TsqlPlanItem.Create(FParser);
          FItems.Add(CurrStatement);
          CurrStatement.ParseStatement;
          Continue;
        end else
          Break;
      end;

      ttSymbolClause:
      begin
        case Token.SymbolClause of

          scBracketOpen:
          begin
            Inc(BracketCount);
          end;

          scBracketClose:
          begin
            if BracketCount = 0 then Break;
            Dec(BracketCount);

            if BracketCount = 0 then
              Finished := True;
          end;

          scComma:
          begin
            Inc(CommaCount);
          end;

          else begin
            Break;
          end;
        end;
      end;
    end;

    ReadNext;
  end;
end;

procedure TsqlPlanExpr.BuildStatement(out sql: String);
var
  subsql: String;
  I: Integer;
  CurrStatement: TsqlStatement;
begin
  sql := '';

  for I := 0 to FDone.Count - 1 do
    sql := sql + ClauseText[FDone.Items[I]] + ' ';

  sql := sql + '(';

  for I := 0 to FItems.Count - 1 do
  begin
    CurrStatement := FItems[I] as TsqlStatement;
    CurrStatement.BuildStatement(subsql);
    sql := sql + subsql;

    if I < FItems.Count - 1 then
      sql := sql + ', ';
  end;

  sql := sql + ')';
end;

{ TsqlPlan }

constructor TsqlPlan.Create(AParser: TsqlParser);
begin
  inherited Create(AParser);

  FExprs := TObjectList.Create;
end;

destructor TsqlPlan.Destroy;
begin
  FreeAndNil(FExprs);

  inherited Destroy;
end;

procedure TsqlPlan.ParseStatement;
var
  CurrStatement: TsqlStatement;
begin
  with FParser do
  while not (Token.TokenType in [ttClear, ttNone]) do
  begin
    case FToken.TokenType of

      ttClause:
      begin
        case Token.Clause of

          cPlan, cJoin, cSort, cMerge:
          begin
            CurrStatement := TsqlPlanExpr.Create(FParser);
            FExprs.Add(CurrStatement);
            CurrStatement.ParseStatement;
            Continue;
          end;

          else begin
            Break;
          end;

        end;
      end;

      ttWord, ttSymbolClause:
      begin
        Break;
      end;
    end;

    ReadNext;
  end;
end;

procedure TsqlPlan.BuildStatement(out sql: String);
var
  I: Integer;
  subsql: string;
begin
  sql := '';

  for I := 0 to FExprs.Count - 1 do
  begin
    (FExprs[I] as TsqlStatement).BuildStatement(subsql);

    sql := sql + subsql;

    if I < FExprs.Count - 1 then
      sql := sql + ' '
  end;
end;


{ TsqlFull }


constructor TsqlFull.Create(AParser: TsqlParser);
begin
  inherited Create(AParser);

  FSelect := nil;
  FFrom := nil;
  FWhere := nil;
  FOrderBy := nil;
  FUnion := nil;
  FGroupBy := nil;
  FPlan := nil;
  FHaving := nil;

  FNeeded := [cSelect, cFrom];
  FDone := [];
end;

destructor TsqlFull.Destroy;
begin
  if Assigned(FSelect) then
    FreeAndNil(FSelect);

  if Assigned(FFrom) then
    FreeAndNil(FFrom);

  if Assigned(FWhere) then
    FreeAndNil(FWhere);

  if Assigned(FOrderBy) then
    FreeAndNil(FOrderBy);

  if Assigned(FUnion) then
    FreeAndNil(FUnion);

  if Assigned(FGroupBy) then
    FreeAndNil(FGroupBy);

  if Assigned(FPlan) then
    FreeAndNil(FPlan);

  if Assigned(FHaving) then
    FreeAndNil(FHaving);

  inherited Destroy;
end;

procedure TsqlFull.ParseStatement;
begin
  if (FParser.FToken.TokenType = ttSymbolClause) and
    (FParser.FToken.SymbolClause = scBracketOpen) then
  begin
    FSubSelect := True;
    FParser.ReadNext;
  end;

  with FParser do
  while not (Token.TokenType in [ttClear, ttNone]) do
  begin
    case FToken.TokenType of

      ttClause:
      begin
        case Token.Clause of

          cSelect:
          begin
            FSelect := TsqlSelect.Create(FParser);
            FSelect.ParseStatement;

            Include(FDone, cSelect);
            Exclude(FNeeded, cSelect);

            Continue;
          end;

          cFrom:
          begin
            FFrom := TsqlFrom.Create(FParser);
            FFrom.ParseStatement;

            Include(FDone, cFrom);
            Exclude(FNeeded, cFrom);

            Continue;
          end;

          cUnion:
          begin
            FUnion := TsqlUnion.Create(FParser);
            FUnion.ParseStatement;

            Include(FDone, cUnion);
            Exclude(FNeeded, cUnion);

            Continue;
          end; 

          cWhere:
          begin
            FWhere := TsqlWhere.Create(FParser);
            FWhere.ParseStatement;

            Include(FDone, cWhere);

            Continue;
          end;

          cOrder:
          begin
            FOrderBy := TsqlOrderBy.Create(FParser);
            FOrderBy.ParseStatement;
            Include(FDone, cOrder);
            Continue;
          end;

          cGroup:
          begin
            FGroupBy := TsqlGroupBy.Create(FParser);
            FGroupBy.ParseStatement;
            Include(FDone, cGroup);
            Continue;
          end;

          cHaving:
          begin
            FHaving := TsqlHaving.Create(FParser);
            FHaving.ParseStatement;
            Include(FDone, cHaving);
            Continue;
          end;

          cPlan:
          begin
            FPlan := TsqlPlan.Create(FParser);
            FPlan.ParseStatement;
            Include(FDone, cPlan);
            Continue;
          end;

          else begin
            Break;
          end;
        end;
      end;

      ttWord, ttSymbolClause:
      begin
        if (FParser.FToken.TokenType = ttSymbolClause) and
          (FParser.FToken.SymbolClause = scBracketClose) and
          FSubSelect then
        begin
          ReadNext;
        end;

        Break;
      end;
    end;

    ReadNext;
  end;

  if (FParser.FToken.TokenType = ttSymbolClause) and
    (FParser.FToken.SymbolClause = scBracketClose) and
    FSubSelect then
  begin
    FParser.ReadNext;
  end;  
end;

procedure TsqlFull.BuildStatement(out sql: String);
var
  subsql: String;
begin
  if FSubSelect then
    sql := '('
  else
    sql := '';

  if Assigned(FSelect) then
  begin
    FSelect.BuildStatement(subsql);
    sql := sql + subsql + ' ';
  end;

  if Assigned(FFrom) then
  begin
    FFrom.BuildStatement(subsql);
    sql := sql + #13#10 + SIndent + subsql;
  end;

  if Assigned(FWhere) then
  begin
    FWhere.BuildStatement(subsql);
    sql := sql + #13#10 + SIndent + subsql;
  end;

  if Assigned(FGroupBy) then
  begin
    FGroupBy.BuildStatement(subsql);
    sql := sql + #13#10 + subsql;
  end;

  if Assigned(FHaving) then
  begin
    FHaving.BuildStatement(subsql);
    sql := sql + #13#10 + subsql;
  end;

  if Assigned(FPlan) then
  begin
    FPlan.BuildStatement(subsql);
    sql := sql + #13#10 + subsql;
  end;

  if Assigned(FOrderBy) then
  begin
    FOrderBy.BuildStatement(subsql);
    sql := sql + #13#10 + subsql;
  end;

  if FSubSelect then
  begin
    if Assigned(FUnion) then
    begin
      FUnion.BuildStatement(subsql);
      sql := sql + #13#10 + subsql;
    end;
    sql := sql + ')';
  end;
end;

procedure TsqlFull.SetDone(const Value: TClauses);
begin
  FDone := Value;

  if cSelect in FDone then
  begin
    if not Assigned(FSelect) then
      FSelect := TsqlSelect.Create(FParser);
  end else begin
    if Assigned(FSelect) then
      FreeAndNil(FSelect);
  end;

  if cFrom in FDone then
  begin
    if not Assigned(FFrom) then
      FFrom := TsqlFrom.Create(FParser);
  end else begin
    if Assigned(FFrom) then
      FreeAndNil(FFrom);
  end;

  if cWhere in FDone then
  begin
    if not Assigned(FWhere) then
      FWhere := TsqlWhere.Create(FParser);
  end else begin
    if Assigned(FWhere) then
      FreeAndNil(FWhere);
  end;

  if [cOrder, cBy] * FDone = [cOrder, cBy] then
  begin
    if not Assigned(FOrderBy) then
      FOrderBy := TsqlOrderBy.Create(FParser);
  end else begin
    if Assigned(FOrderBy) then
      FreeAndNil(FOrderBy);
  end;

  if [cGroup, cBy] * FDone = [cGroup, cBy] then
  begin
    if not Assigned(FGroupBy) then
      FGroupBy := TsqlGroupBy.Create(FParser);
  end else begin
    if Assigned(FGroupBy) then
      FreeAndNil(FGroupBy);
  end;

  if cPlan in FDone then
  begin
    if not Assigned(FPlan) then
      FPlan := TsqlPlan.Create(FParser);
  end else begin
    if Assigned(FPlan) then
      FreeAndNil(FPlan);
  end;

  if cUnion in FDone then
  begin
    if not Assigned(FUnion) then
      FUnion := TsqlUnion.Create(FParser);
  end else begin
    if Assigned(FUnion) then
      FreeAndNil(FUnion);
  end;
end;

{ TsqlParser }

function GetClause(const Text: String): TClause;
var
  I: Integer;
begin
  Assert(ClausesList <> nil);

  I := ClausesList.IndexOf(UpperCase(Text));
  if I = -1 then
    Result := cNone
  else
    Result := TClause(ClausesList.Objects[I]);
end;

function GetSymbolClause(const Symb: Char): TSymbolClause;
var
  Ts: TSymbolClause;
begin
  for Ts := Low(TSymbolClause) to High(TSymbolClause) do
    if Symb = SymbolClauseText[Ts] then
    begin
      Result := Ts;
      Exit;
    end;

  Result := scNone;
end;

function KillComments(const Text: String; List: TStringList): String;
var
  I, K: Integer;
  S: String;
begin
  Result := Text;
  List.Clear;

  repeat
    I := AnsiPos('/*', Result);

    if I > 0 then
    begin
      S := Copy(Result, 1, I - 1);
      I := AnsiPos('*/', Result);

      if I > 0 then
      begin
        K := Length(S) + 1;
        List.Add(Copy(Result, K, I - K + 2));

        Result := S + Format(' @%.4d ', [List.Count]) +
          Copy(Result, I + 2, Length(Result));
      end;
    end;

  until I = 0;

  // Добавим корректировку текста после запятых
  // Если после запятой идет сразу текст, то добавим между ними пробел
  // иначе возможно зацикливание парсера

  S := Result;
  Result := '';
  while AnsiPos(',', S) > 0 do
  begin
    if (AnsiPos('''', S) > 0) and (AnsiPos('''', S) < AnsiPos(',', S)) then
    begin
      Result := Result + Copy(S, 1, AnsiPos('''', S));
      Delete(S, 1, AnsiPos('''', S));
      if AnsiPos('''', S) = 0 then
        raise Exception.Create('Некорректный запрос: ковычки не закрыты');
      Result := Result + Copy(S, 1, AnsiPos('''', S));
      Delete(S, 1, AnsiPos('''', S));
    end
    else
    begin
      Result := Result + ' ' + Copy(S, 1, AnsiPos(',', S)) + ' ';
      Delete(S, 1, AnsiPos(',', S));
      S := TrimLeft(S);
    end;
  end;
  Result := Result + ' ' + S;
end;

constructor TsqlParser.Create(const AnSql: String);
begin
  FComments := TStringList.Create;

  FToken := ClearToken;
  FSource := KillComments(AnSql, FComments);
  FSql := AnsiUpperCase(FSource);

  FIndex := 0;
  FLength := Length(FSql);

  FMainStatements := TObjectList.Create;
  FIndent := 0;

  FObjectClassName := '';
end;

destructor TsqlParser.Destroy;
begin
  FMainStatements.Free;
  FComments.Free;

  inherited Destroy;
end;

procedure TsqlParser.Parse;
var
  CurrStatement: TsqlStatement;

begin
  ReadNext;

  while not (Token.TokenType in [ttClear, ttNone]) do
  begin
    case FToken.TokenType of
      ttClause:
      begin
        case FToken.Clause of
          cSelect:
          begin
            CurrStatement := TsqlFull.Create(Self);
            FMainStatements.Add(CurrStatement);
            CurrStatement.ParseStatement;
            Continue;
          end;
          cUnion:
          begin
            CurrStatement := TsqlUnion.Create(Self);
            FMainStatements.Add(CurrStatement);
            CurrStatement.ParseStatement;
            Continue;
          end;
          cUpdate:
          begin
            CurrStatement := TsqlUpdate.Create(Self);
            FMainStatements.Add(CurrStatement);
            CurrStatement.ParseStatement;
            Continue;
          end;
          cInsert:
          begin
            CurrStatement := TsqlInsert.Create(Self);
            FMainStatements.Add(CurrStatement);
            CurrStatement.ParseStatement;
            Continue;
          end;
          cDelete:
          begin
            CurrStatement := TsqlDelete.Create(Self);
            FMainStatements.Add(CurrStatement);
            CurrStatement.ParseStatement;
            Continue;
          end;
          else
            raise EatParserError.Create('Ошибка в SQL-выражении: ' + FToken.Text);
        end;
      end;
      else
        if not ((Token.TokenType in [ttClear, ttNone, ttSpace]) or IsComment(FToken.Text)) then
          raise EatParserError.Create('Ошибка в SQL-выражении: ' + FToken.Text);
    end;

    ReadNext;
  end;
end;

procedure TsqlParser.Build(out sql: String);
var
  I, K: Integer;
  subsql, commsign: String;
begin
  sql := '';

  for I := 0 to FMainStatements.Count - 1 do
  begin
    (FMainStatements[I] as TsqlStatement).BuildStatement(subsql);
    sql := sql + subsql + ' ';
  end;

  for I := 0 to FComments.Count - 1 do
  begin
    commsign := Format('@%.4d', [I + 1]);
    K := AnsiPos(commsign, sql);

    if K > 0 then
      sql :=
        Copy(sql, 1, K - 1) +
        FComments[I] +
        Copy(sql, K + Length(commsign), Length(sql))
    else
      sql := FComments[I] + #13#10 + sql;
  end;

end;

procedure TsqlParser.ReadNext;

  function ReadNextWord: String;
  var
    StrUserText: Boolean;

  begin
    StrUserText := False;
    FToken.Text := '';
    FToken.Source := '';
    if FSql[FIndex] in NumberSymbols then
      while (FIndex <= FLength) and (FSql[FIndex] in NumberSymbols) do
      begin
        FToken.Text := FToken.Text + FSql[FIndex];
        FToken.Source := FToken.Source + FSource[FIndex];

        Inc(FIndex);
      end

    else repeat
      if (FSql[FIndex] in MathSymbolsArray) and not StrUserText then
      begin
        if FToken.TextKind in [tkMath, tkNone] then
          FToken.TextKind := tkMath
        else
          Break;
      end else

      if (FSql[FIndex] in MathOperationArray) and not StrUserText then
      begin
        if FToken.TextKind in [tkMathOp, tkNone] then
          FToken.TextKind := tkMathOp
        else
          Break;
      end else

      if (FSql[FIndex] in SymbolClauseArray) and not StrUserText then
      begin
        Break;
      end else

      if FSql[FIndex] = '''' then
      begin
        if not StrUserText and (FToken.TextKind = tkNone) then
        begin
          StrUserText := True;
          FToken.TextKind := tkUserText;
        end else

        if StrUserText then
        begin
          FToken.Text := FToken.Text + FSql[FIndex];
          FToken.Source := FToken.Source + FSource[FIndex];
          Inc(FIndex);
          if (FIndex <= Length(FSql)) and (FSql[FIndex] = '''') then
          begin
            while (FIndex <= Length(FSql)) and (FSql[FIndex] = '''') do
            begin
              FToken.Text := FToken.Text + FSql[FIndex];
              FToken.Source := FToken.Source + FSource[FIndex];
              Inc(FIndex);
            end
          end
          else
            Break;
        end else
          Break;

      end else

      if (FSql[FIndex] = ':') and (FToken.Text = '') then
      begin
        FToken.TextKind := tkUserText
      end else

      if (FSql[FIndex] <= ' ') and not StrUserText then
      begin
        Break
      end else

      if FToken.TextKind = tkNone then
      begin
        FToken.TextKind := tkText
      end else

      if not (FToken.TextKind in [tkText, tkUserText]) then
        Break;

      FToken.Text := FToken.Text + FSql[FIndex];
      FToken.Source := FToken.Source + FSource[FIndex];

      Inc(FIndex);
    until (FIndex > FLength);

    if IsNumeric(FToken.Text) then
      FToken.TextKind := tkUserText;

    Result := FToken.Text;

    Dec(FIndex);
  end;

  procedure ReadSpaces;
  begin
    FToken.TokenType := ttSpace;

    while (FIndex <= FLength) and (FSql[FIndex] <= ' ') do
      Inc(FIndex);

    Dec(FIndex);
  end;

begin
  FToken := ClearToken;

  if FIndex < FLength then
  begin
    Inc(FIndex);

    if FSql[FIndex] <= ' ' then
    begin
      //FToken.TokenType := ttSpace;
      ReadSpaces;
    end
    else if FSql[FIndex] in SymbolClauseArray then
    begin
      with FToken do
      begin
        TokenType := ttSymbolClause;
        Symbol := FSql[FIndex];
        Text := FSql[FIndex];
        SymbolClause := GetSymbolClause(Symbol);
      end;
    end
    else begin
      with FToken do
      begin
        ReadNextWord;
        Clause := GetClause(Text);

        if Clause <> cNone then
          TokenType := ttClause
        else
          TokenType := ttWord;
      end;
    end;
  end else
    FToken.TokenType := ttClear;
end;


procedure TsqlParser.RollBack;

  function ReadPriorWord: String;
  var
    StrUserText: Boolean;
  begin
    StrUserText := False;
    FToken.Text := '';
    FToken.Source := '';

    repeat
      if (FSql[FIndex] in MathSymbolsArray) and not StrUserText then
      begin
        if FToken.TextKind in [tkMath, tkNone] then
          FToken.TextKind := tkMath
        else
          Break;
      end else

      if (FSql[FIndex] in MathOperationArray) and not StrUserText then
      begin
        if FToken.TextKind in [tkMathOp, tkNone] then
          FToken.TextKind := tkMathOp
        else
          Break;
      end else

      if (FSql[FIndex] in SymbolClauseArray) and not StrUserText then
      begin
        Break;
      end else

      if FSql[FIndex] = '''' then
      begin
        if not StrUserText and (FToken.TextKind = tkNone) then
        begin
          StrUserText := True;
          FToken.TextKind := tkUserText;
        end else

        if StrUserText then
        begin
          FToken.Text := FToken.Text + FSql[FIndex];
          FToken.Source := FToken.Source + FSource[FIndex];
          Dec(FIndex);

          Break;
        end else
          Break;

      end else

      if (FSql[FIndex] = ':') and (FToken.Text = '') then
      begin
        FToken.TextKind := tkUserText
      end else

      if (FSql[FIndex] <= ' ') and not StrUserText then
      begin
        Break
      end else

      if FToken.TextKind = tkNone then
      begin
        FToken.TextKind := tkText
      end else

      if not (FToken.TextKind in [tkText, tkUserText]) then
        Break;

      FToken.Text := FToken.Text + FSql[FIndex];
      FToken.Source := FToken.Source + FSource[FIndex];

      Dec(FIndex);
// ??    until (FIndex > FLength);
      until (FIndex <= 0);

    if IsNumeric(FToken.Text) then
      FToken.TextKind := tkUserText;

    Result := FToken.Text;
  end;

  procedure ReadPriorSpaces;
  begin
    while (FSql[FIndex] <= ' ') and (FIndex > 0) do
      Dec(FIndex);

   // Inc(FIndex);
  end;

begin
  case FToken.TokenType of
    ttClause, ttWord:
      Dec(FIndex, Length(FToken.Text));
    ttSymbolClause:
      Dec(FIndex);
    ttSpace:
      ReadPriorSpaces;
  end;

  if FIndex > 1 then
  begin
    if (FSql[FIndex] <= ' ') then
      ReadPriorSpaces
    else if (FSql[FIndex] > ' ') and not (FSql[FIndex] in SymbolClauseArray) then
      ReadPriorWord
    else
      Dec(FIndex);
  end;

  ReadNext;
end;

//Процедура для считывания полей
procedure TsqlParser.GetFields(out FList: TStringList);
var
  I, J: Integer;

  procedure AddField(const AFieldName: String);
  var
    I: Integer;
    FN: String;
  begin
    I := 1;
    FN := AFieldName;
    while FList.IndexOf(AnsiUpperCase(FN)) <> -1 do
    begin
      FN := AFieldName + IntToStr(I);
      Inc(I);
    end;

    FList.Add(AnsiUpperCase(FN));
  end;

begin
  FList.Clear;
  Parse;
  for I := 0 to FMainStatements.Count - 1 do
    if (FMainStatements.Items[I] is TsqlFull) then
      for J := 0 to (FMainStatements[I] as TsqlFull).Select.Fields.Count - 1 do
        with (FMainStatements[I] as TsqlFull).Select do
        if (Fields[J] is TsqlField) then
        begin
          if Trim((Fields[J] as TsqlField).FieldAsName) <> '' then
            AddField((Fields[J] as TsqlField).FieldAsName)
          else
            AddField((Fields[J] as TsqlField).FieldName)
        end

        else if (Fields[J] is TsqlExpr) then
        begin
          if Trim((Fields[J] as TsqlExpr).ExprAsName) <> '' then
            AddField((Fields[J] as TsqlExpr).ExprAsName)
          else
            AddField('UnknownExpr' + IntToStr(FList.Count))
        end

        else if (Fields[J] is TsqlFunction) then
        begin
          if Trim((Fields[J] as TsqlFunction).FuncAsName) <> '' then
            AddField((Fields[J] as TsqlFunction).FuncAsName)
          else
            AddField('UnknownFunc' + IntToStr(FList.Count))
        end

        else if (Fields[J] is TsqlValue) then
        begin
          if Trim((Fields[J] as TsqlValue).ValueAsName) <> '' then
            AddField((Fields[J] as TsqlValue).ValueAsName)
          else
            AddField('UnknownValue' + IntToStr(FList.Count))
        end

        else if (Fields[J] is TsqlSelectParam) then
        begin
          AddField('UnknownSQL' + IntToStr(FList.Count))
        end;
end;

procedure FillUpClausesList;
var
  I: TClause;
begin
  for I := Low(TClause) to High(TClause) do
    ClausesList.AddObject(UpperCase(ClauseText[I]), Pointer(I));
end;

{Возвращает список таблиц, входящих во фром-часть запроса, без повторений}
procedure TsqlParser.GetTables(out FList: TStrings);
var
  I, J: Integer;

  procedure GetJoinTables(tbl: TsqlStatement);
  var
    K: Integer;
  begin
    if (tbl is TsqlTable) then
    begin
      if FList.IndexOf(AnsiUpperCase((tbl as TsqlTable).TableName)) = -1 then
        FList.Add(AnsiUpperCase((tbl as TsqlTable).TableName));

      for K := 0 to (tbl as TsqlTable).Joins.Count - 1 do
      begin
        GetJoinTables(((tbl as TsqlTable).Joins[K] as TsqlJoin).JoinTable)
      end;

    end else
    if (tbl is TsqlFunction) then
    begin
      for K := 0 to (tbl as TsqlFunction).Joins.Count - 1 do
      begin
        GetJoinTables(((tbl as TsqlFunction).Joins[K] as TsqlJoin).JoinTable)
      end;
    end;

  end;

begin
  FList.Clear;
  Parse;
  for I := 0 to FMainStatements.Count - 1 do
    if (FMainStatements.Items[I] is TsqlFull) then
      for J := 0 to (FMainStatements[I] as TsqlFull).From.Tables.Count - 1 do
        with (FMainStatements[I] as TsqlFull).From do
          GetJoinTables(Tables[J] as TsqlStatement);
end;

{ TclClause }

function TclClause.Add(Value: TClause): Integer;
begin
  SetLength(FArrClause, Length(FArrClause) + 1);
  FArrClause[Length(FArrClause) - 1] := Value;
  Result := Length(FArrClause) - 1;
end;

procedure TclClause.Assign(clInstance: TclClause);
var
  I: Integer;
begin
  Clear;
  for I := 0 to clInstance.Count - 1 do
    Add(clInstance.Items[I]);
end;

procedure TclClause.Clear;
var
  I: Integer;
begin
  for I := 0 to Length(FArrClause) - 1 do
  begin
    Delete(I);
  end;
end;

function TclClause.Cross(ValueSet: TClauses): TClauses;
var
  I: Integer;
begin
  Result := [];
  for I := 0 to Count - 1 do
    System.Include(Result, FArrClause[I]);
  Result := Result * ValueSet;
end;

procedure TclClause.Delete(Index: Integer);
var
  I: Integer;
begin
  Assert(Index >= 0);
  if Index < Length(FArrClause) then
  begin
    for I := Index to Length(FArrClause) - 2 do
      FArrClause[I] := FArrClause[I + 1];
    SetLength(FArrClause, Length(FArrClause) - 1);
  end;
end;

procedure TclClause.Exclude(Value: TClause);
var
  I: Integer;
begin
  for I := 0 to Length(FArrClause) - 1 do
    if FArrClause[I] = Value then
    begin
      Delete(I);
      Break;
    end;
end;

function TclClause.GetCount: Integer;
begin
  Result := Length(FArrClause);
end;

function TclClause.GetItems(Index: Integer): TClause;
begin
  if Index < Length(FArrClause) then
    Result := FArrClause[Index]
  else
    Result := cNone;
end;

function TclClause.Include(Value: TClause): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Length(FArrClause) - 1 do
    if FArrClause[I] = Value then
    begin
      Result := True;
      Break;
    end;
end;

{ TclMathClause }

function TclMathClause.Add(Value: TMathClause): Integer;
begin
  SetLength(FArrClause, Length(FArrClause) + 1);
  FArrClause[Length(FArrClause) - 1] := Value;
  Result := Length(FArrClause) - 1;
end;

function TclMathClause.Cross(ValueSet: TMathClauses): TMathClauses;
var
  I: Integer;
begin
  Result := [];
  for I := 0 to Count - 1 do
    System.Include(Result, FArrClause[I]);
  Result := Result * ValueSet;
end;

procedure TclMathClause.Delete(Index: Integer);
var
  I: Integer;
begin
  Assert(Index >= 0);
  if Index < Length(FArrClause) then
  begin
    for I := Index to Length(FArrClause) - 2 do
      FArrClause[I] := FArrClause[I + 1];
    SetLength(FArrClause, Length(FArrClause) - 1);
  end;
end;

procedure TclMathClause.Exclude(Value: TMathClause);
var
  I: Integer;
begin
  for I := 0 to Length(FArrClause) - 1 do
    if FArrClause[I] = Value then
    begin
      Delete(I);
      Break;
    end;
end;

function TclMathClause.GetCount: Integer;
begin
  Result := Length(FArrClause);
end;

function TclMathClause.GetItems(Index: Integer): TMathClause;
begin
  if Index < Length(FArrClause) then
    Result := FArrClause[Index]
  else
    Result := mcNone;
end;

function TclMathClause.Include(Value: TMathClause): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Length(FArrClause) - 1 do
    if FArrClause[I] = Value then
    begin
      Result := True;
      Break;
    end;
end;

{ TsqlCast }

procedure TsqlCast.BuildStatement(out sql: String);
var
  I: Integer;
  StDim: String;
begin
  sql := '';
  if Assigned(FInternalStatement) then
    FInternalStatement.BuildStatement(sql);
  sql := sql + ' AS ' + FTypeName;
  StDim := '';
  for I := 0 to FTypeDimension.Count - 1 do
  begin
    if StDim > '' then
      StDim := StDim + ', ';
    StDim := StDim + FTypeDimension[I];
  end;
  if StDim > '' then
  begin
    StDim := '(' + StDim + ') ';
  end;
  sql := sql + StDim;
end;

constructor TsqlCast.Create(AParser: TsqlParser);
begin
  inherited;
  FTypeDimension := TStringList.Create;
  FDone := [];
  FNeeded := [eoValue, eoType];

  FInternalStatement := nil;
 // FInternalValue := nil;
end;

destructor TsqlCast.Destroy;
begin
  FTypeDimension.Free;
  if Assigned(FInternalStatement) then
    FInternalStatement.Free;
{  if Assigned(FInternalValue) then
    FInternalValue.Free;       }
  inherited;
end;

procedure TsqlCast.ParseStatement;
var
  BracketCount: Integer;
  BeginIndex: Integer;
  St: TsqlStatement;
begin
  BracketCount := 0;

  while (FParser.Token.TokenType in [ttClear, ttNone, ttSpace]) do
    FParser.ReadNext;

  BeginIndex := FParser.Index;
  with FParser do
  while not (Token.TokenType in [ttClear, ttNone]) do
  begin
    case FToken.TokenType of

      ttClause:
      begin
        case Token.Clause of

          cSum, cAvg, cMax, cMin, cUpper,
          cCast, cCount, cFirst, cSkip, cExtract, cSubString:
          begin
            if FInternalStatement <> nil then
              raise Exception.Create('Ошибка в Cast-выражении!');
            FInternalStatement := TsqlFunction.Create(FParser, True);
            FInternalStatement.ParseStatement;
            Include(FDone, eoValue);
            Exclude(FNeeded, eoValue);
            Continue;
          end;

          cCase:
          begin
            if FInternalStatement <> nil then
              raise Exception.Create('Ошибка в Cast-выражении!');
            FInternalStatement := TsqlCase.Create(FParser);
            FInternalStatement.ParseStatement;
            Include(FDone, eoValue);
            Exclude(FNeeded, eoValue);
            Continue;
          end;

          cAs:
          begin
            if (BracketCount = 0)  then
              Break;

            if (FInternalStatement = nil) or (BracketCount <> 1) then
              raise Exception.Create('Ошибка в Cast-выражении!');
          end;

          cNull:
          begin
            if (eoValue in FNeeded) then
            begin
              FInternalStatement := TsqlValue.Create(FParser, True);
              FInternalStatement.ParseStatement;
              Include(FDone, eoValue);
              Exclude(FNeeded, eoValue);
              Continue;
            end
            else
              raise EatParserError.Create('Ошибка в SQL-выражении: ' + Token.Text);

          end;

          else begin
            Break;
          end;
        end;
      end;

      ttSymbolClause:
      begin
        case Token.SymbolClause of
          scBracketOpen:
          begin
            if (BeginIndex < FParser.Index) and not(eoType in FDone) then
            begin
              if (FInternalStatement <> nil) then
              begin
                FreeAndNil(FInternalStatement);
                RollBack;
                while Token.TokenType = ttSpace do
                  RollBack;
              end;
              St := TsqlFunction.Create(FParser, True);
              FInternalStatement := St;
              FInternalStatement.ParseStatement;

              Exclude(FNeeded, eoValue);
              Include(FDone, eoValue);
              Continue;

            end else
            begin
              Inc(BracketCount);
            end;
          end;

          scBracketClose:
          begin
            if BracketCount < 1 then
              Break;
            Dec(BracketCount);
            if BracketCount = 0 then
            begin
              ReadNext;
              Break;
            end;
          end;

          scComma:
          begin
            if BracketCount = 0 then
              Break;
          end

          else
            Break;
          end;
      end;

      ttWord:
      begin
        case Token.TextKind of

          tkUserText:
          begin
            if (eoValue in FNeeded) then
            begin
              FInternalStatement := TsqlValue.Create(FParser, True);
              FInternalStatement.ParseStatement;
              Include(FDone, eoValue);
              Exclude(FNeeded, eoValue);
              Continue;
            end else

            if eoType in FDone then
            begin
              FTypeDimension.Add(FToken.Text)
            end

            else
              raise EatParserError.Create('Ошибка в SQL-выражении: ' + Token.Text);
          end;

          tkText:
          begin
            if (eoValue in FNeeded) then
            begin
              FInternalStatement := TsqlField.Create(FParser, True);
              FInternalStatement.ParseStatement;
              Include(FDone, eoValue);
              Exclude(FNeeded, eoValue);
              Continue;
            end else

            if eoType in FNeeded then
            begin
              Exclude(FNeeded, eoType);
              FTypeName := FToken.Text;
              Include(FDone, eoType);
            end else

            if (eoType in FDone) and (AnsiCompareText(FToken.Text, 'PRECISION') = 0) then
            begin
              FTypeName := FTypeName + ' ' + FToken.Text;
            end

            else
              raise EatParserError.Create('Ошибка в SQL-выражении: ' + Token.Text);
          end;

          tkMathOp:
          begin
            St := TsqlExpr.Create(FParser, True);
            if eoValue in FDone then
            begin
              if FInternalStatement = nil then
                raise EatParserError.Create('Ошибка в SQL-выражении: ' + Token.Text);
              (St as TsqlExpr).FExprs.Add(FInternalStatement);
            end;
            FInternalStatement := St;
            FInternalStatement.ParseStatement;
            Include(FDone, eoValue);
            Exclude(FNeeded, eoValue);
            Continue;
          end;

          else begin
            Break;
          end;
        end;
      end;
    end;

    ReadNext;
  end;
end;

{ TsqlCase }

procedure TsqlCase.BuildStatement(out sql: String);
var
  S: String;
  I: Integer;
begin
  S := '';
  sql := '';
  if Assigned(FValue) then
    FValue.BuildStatement(S);

  sql := sql + ClauseText[cCase] + ' ' + Trim(S) + #13#10;

  for I := 0 to FWhenCondStatement.Count - 1 do
  begin
    S := '';
    (FWhenCondStatement[I] as TsqlStatement).BuildStatement(S);
    sql := sql + SIndent + ClauseText[cWhen] + ' ' + Trim(S) +  ' '  + ClauseText[cThen] + #13#10;
    S := '';
    Indent := Indent + 2;
    (FWhenStatement[I] as TsqlStatement).BuildStatement(S);
    sql := sql + SIndent + Trim(S) + #13#10;
    Indent := Indent - 2;
  end;

  S := '';
  if Assigned(FElseStatement) then
  begin
    FElseStatement.BuildStatement(S);
    sql := sql + SIndent + ClauseText[cElse] + #13#10;
    Indent := Indent + 2;
    sql := sql + SIndent + Trim(S) + #13#10;
    Indent := Indent - 2;
  end;
  sql := sql + SIndent + ClauseText[cEnd];
end;

constructor TsqlCase.Create(AParser: TsqlParser);
begin
  inherited;
  FByCondition := False;
  //Список.Может хранить либо условие, либо значение
  FWhenCondStatement := TObjectList.Create;
  //Список выражений, которые выполняются на when
  FWhenStatement := TObjectList.Create;
  //Выражение которое выполняется на else
  FElseStatement := nil;
  //Значение
  FValue := nil;

  FNeeded := [eoEnd, eoCase];
  FDone := [];
end;

destructor TsqlCase.Destroy;
begin
  //Список.Может хранить либо условие, либо значение
  FWhenCondStatement.Free;
  //Список выражений, которые выполняются на when
  FWhenStatement.Free;
  if Assigned(FElseStatement) then
    FElseStatement.Free;
  if Assigned(FValue) then
    FValue.Free;
  inherited;
end;

procedure TsqlCase.ParseStatement;
var
  St: TsqlStatement;
  {Счетчик when-конструкций}
  WhenCount: Integer;
begin
  WhenCount := 0;
  with FParser do
  while not (Token.TokenType in [ttClear, ttNone]) do
  begin
    case FToken.TokenType of

      ttClause:
      begin
        case Token.Clause of
          cCase:
          begin
            //Если в нашем выражении уже есть eoCase, значит это вложенный case
            if eoCase in FDone then
            begin
              //Если это конструкция на else
              if eoElse in FDone then
              begin
                if not Assigned(FElseStatement) then
                begin
                  FElseStatement := TsqlCase.Create(FParser);
                  FElseStatement.ParseStatement;
                end else
                  raise EatParserError.Create('Ошибка в sql-выражении: CASE!');
              end else
              //Если это конструкция после then
              if (eoThen in FDone) and (not(eoThen in FNeeded))
                and (WhenCount = FWhenStatement.Count + 1) then
              begin
                St := TsqlCase.Create(FParser);
                FWhenStatement.Add(St);
                St.ParseStatement;
              end else
              //Если это конструкция как условие when
              if (eoWhen in FDone) and (WhenCount = FWhenCondStatement.Count + 1)
                and (not(eoWhen in FNeeded)) then
              begin
                St := TsqlCase.Create(FParser);
                FWhenCondStatement.Add(St);
                St.ParseStatement;
              end else
              //Если это переменная Case
              if (eoCase in FDone) and (FValue = nil) then
              begin
                FValue := TsqlCase.Create(FParser);
                FValue.ParseStatement;
              end else
                raise EatParserError.Create('Ошибка в sql-выражении: CASE!');
            end else
            begin
              Include(FDone, eoCase);
              Exclude(FNeeded, eoCase);
            end;
          end;
          cWhen:
          begin
            if eoThen in FNeeded then
              raise EatParserError.Create('Ошибка в sql-выражении: WHEN!')
            else
            begin
              Include(FDone, eoWhen);
              Include(FNeeded, eoThen);
              Exclude(FNeeded, eoWhen);
              Inc(WhenCount);
            end;
          end;
          cThen:
          begin
            if eoThen in FNeeded then
            begin
              Include(FDone, eoThen);
              Exclude(FNeeded, eoThen);
              Include(FNeeded, eoWhen);
            end else
              raise EatParserError.Create('Ошибка в sql-выражении: THEN!');
          end;

          cElse:
          begin
            if (eoElse in FDone) or (WhenCount = 0) then
              raise EatParserError.Create('Ошибка в sql-выражении: ELSE!')
            else
            begin
              Include(FDone, eoElse);
            end;
          end;

          cEnd:
          begin
            ReadNext;
            Break;
          end;

          cSum, cAvg, cMax, cMin, cUpper,
          cCast, cCount, cFirst, cSkip, cExtract, cSubString:
          begin
            //Если это конструкция на else
            if eoElse in FDone then
            begin
              if not Assigned(FElseStatement) then
              begin
                FElseStatement := TsqlFunction.Create(FParser, True);
                FElseStatement.ParseStatement;
              end else
                raise EatParserError.Create('Ошибка в sql-выражении: ' + Token.Text + '!');
            end else
             //Если это конструкция после then
            if (eoThen in FDone) and not(eoThen in FNeeded)
              and (WhenCount = FWhenStatement.Count + 1) then
            begin
              St := TsqlFunction.Create(FParser, True);
              FWhenStatement.Add(St);
              St.ParseStatement;
            end else
            //Если это конструкция как условие when
            if (eoWhen in FDone) and (WhenCount = FWhenCondStatement.Count + 1)
              and (not(eoWhen in FNeeded)) then
            begin
              St := TsqlFunction.Create(FParser, True);
              FWhenCondStatement.Add(St);
              St.ParseStatement;
            end else
           //Если это переменная Case
            if (eoCase in FDone) and (FValue = nil) then
            begin
              FValue := TsqlFunction.Create(FParser, True);
              FValue.ParseStatement;
            end else
              raise EatParserError.Create('Ошибка в sql-выражении: ' + Token.Text + '!');
            Continue;
          end;

          cIn, cIs, cNull, cNot, cExists, cSingular:
          begin
            //Если это конструкция на else
            if eoElse in FDone then
            begin
              St := TsqlCondition.Create(FParser);
              if Assigned(FElseStatement) then
              begin
               (St as TsqlCondition).FStatements.Add(FElseStatement);
              end else
              FElseStatement := St;
              FElseStatement.ParseStatement;
            end else
            //Если это конструкция после then
            if (eoThen in FDone) and (not(eoThen in FNeeded))
              and ((WhenCount = FWhenStatement.Count + 1) or
                (WhenCount = FWhenStatement.Count))
            then
            begin
              St := TsqlCondition.Create(FParser);
              if (WhenCount = FWhenStatement.Count) then
              begin
               (St as TsqlCondition).FStatements.Add(FWhenStatement.Extract(FWhenStatement[FWhenStatement.Count - 1]));
              end;
              FWhenStatement.Add(St);
              St.ParseStatement;
            end else
            //Если это конструкция как условие when
            if (eoWhen in FDone) and ((WhenCount = FWhenCondStatement.Count + 1)
              or (WhenCount = FWhenCondStatement.Count))
              and (not(eoWhen in FNeeded)) then
            begin
              St := TsqlCondition.Create(FParser);
              if (WhenCount = FWhenCondStatement.Count) then
              begin
               (St as TsqlCondition).FStatements.Add(FWhenCondStatement.Extract(
                  FWhenCondStatement[FWhenCondStatement.Count - 1]));
              end;
              FWhenCondStatement.Add(St);
              St.ParseStatement;
            end else
           //Если это переменная Case
            if (eoCase in FDone) then
            begin
              St := TsqlCondition.Create(FParser);
              if Assigned(FValue) then
              begin
                (St as TsqlCondition).FStatements.Add(FValue);
              end else
              FValue := St;
              FValue.ParseStatement;

            end else
              raise EatParserError.Create('Ошибка в sql-выражении: ' + Token.Text + '!');
            Continue;
          end;

          else
            Break;
        end;
      end;

      ttSymbolClause:
      begin
        case Token.SymbolClause of
          scBracketOpen:
          begin
            //Если это конструкция на else
            if eoElse in FDone then
            begin
              if Assigned(FElseStatement) then
              begin
                FreeAndNil(FElseStatement);
                RollBack;
                while Token.TokenType = ttSpace do
                  RollBack;
              end;

              St := TsqlFunction.Create(FParser, True);
              FElseStatement := St;
              FElseStatement.ParseStatement;

            end else
            //Если это конструкция после then
            if (eoThen in FDone) and (not(eoThen in FNeeded))
              and ((WhenCount = FWhenStatement.Count + 1) or
                (WhenCount = FWhenStatement.Count))
            then
            begin
              if (WhenCount = FWhenStatement.Count) then
              begin
                FWhenStatement.Delete(FWhenStatement.Count - 1);
                RollBack;
                while Token.TokenType = ttSpace do
                  RollBack;
              end;
              St := TsqlFunction.Create(FParser, True);
              FWhenStatement.Add(St);
              St.ParseStatement;
            end else
            //Если это конструкция как условие when
            if (eoWhen in FDone) and ((WhenCount = FWhenCondStatement.Count + 1)
              or (WhenCount = FWhenCondStatement.Count))
              and (not(eoWhen in FNeeded)) then
            begin
              if (WhenCount = FWhenCondStatement.Count) then
              begin
                FWhenCondStatement.Delete(FWhenCondStatement.Count - 1);
                RollBack;
                while Token.TokenType = ttSpace do
                  RollBack;
              end;
              St := TsqlFunction.Create(FParser, True);
              FWhenCondStatement.Add(St);
              St.ParseStatement;
            end else
           //Если это переменная Case
            if (eoCase in FDone) then
            begin
              if Assigned(FValue) then
              begin
                FreeAndNil(FValue);
                RollBack;
                while Token.TokenType = ttSpace do
                  RollBack;
              end;
              St := TsqlFunction.Create(FParser, True);
              FValue := St;
              FValue.ParseStatement;

            end else
              raise EatParserError.Create('Ошибка в sql-выражении: ' + Token.Text + '!');
            Continue;
          end

          else
            Break;
          end;
      end;

      ttWord:
      begin
        case Token.TextKind of

          tkUserText:
          begin
            //Если это конструкция на else
            if eoElse in FDone then
            begin
              if not Assigned(FElseStatement) then
              begin
                FElseStatement := TsqlValue.Create(FParser, True);
                FElseStatement.ParseStatement;
              end else
                raise EatParserError.Create('Ошибка в sql-выражении: ' + Token.Text + '!');
            end else
            //Если это конструкция после then
            if (eoThen in FDone) and not(eoThen in FNeeded)
              and (WhenCount = FWhenStatement.Count + 1) then
            begin
              St := TsqlValue.Create(FParser, True);
              FWhenStatement.Add(St);
              St.ParseStatement;
            end else
            //Если это конструкция как условие when
            if (eoWhen in FDone) and (WhenCount = FWhenCondStatement.Count + 1)
              and (not(eoWhen in FNeeded)) then
            begin
              St := TsqlValue.Create(FParser, True);
              FWhenCondStatement.Add(St);
              St.ParseStatement;
            end else
            //Если это переменная Case
            if (eoCase in FDone) and (FValue = nil) then
            begin
              FValue := TsqlValue.Create(FParser, True);
              FValue.ParseStatement;
            end else
              raise EatParserError.Create('Ошибка в sql-выражении: ' + Token.Text + '!');
            Continue;              
          end;

          tkText:
          begin
            //Если это конструкция на else
            if eoElse in FDone then
            begin
              if not Assigned(FElseStatement) then
              begin
                FElseStatement := TsqlField.Create(FParser, True);
                FElseStatement.ParseStatement;
              end else
                raise EatParserError.Create('Ошибка в sql-выражении: ' + Token.Text + '!');
            end else
            //Если это конструкция после then
              //Если это конструкция после then
            if (eoThen in FDone) and (not(eoThen in FNeeded))
              and (WhenCount = FWhenStatement.Count + 1) then
            begin
              St := TsqlField.Create(FParser, True);
              FWhenStatement.Add(St);
              St.ParseStatement;
            end else
            //Если это конструкция как условие when
            if (eoWhen in FDone) and (WhenCount = FWhenCondStatement.Count + 1)
              and (not(eoWhen in FNeeded)) then
            begin
              St := TsqlField.Create(FParser, True);
              FWhenCondStatement.Add(St);
              St.ParseStatement;
            end else
            //Если это переменная Case
            if (eoCase in FDone) and (FValue = nil) then
            begin
              FValue := TsqlField.Create(FParser, True);
              FValue.ParseStatement;
            end else
              raise EatParserError.Create('Ошибка в sql-выражении: ' + Token.Text + '!');
            Continue;
          end;

          tkMathOp:
          begin
            //Если это конструкция на else
            if eoElse in FDone then
            begin
              St := TsqlExpr.Create(FParser, True);

              if Assigned(FElseStatement) then
              begin
                (St as TsqlExpr).FExprs.Add(FElseStatement);
              end;
              FElseStatement := St;
              FElseStatement.ParseStatement;

            end else
            //Если это конструкция после then
            if (eoThen in FDone) and (not(eoThen in FNeeded))
              and ((WhenCount = FWhenStatement.Count + 1) or
                (WhenCount = FWhenStatement.Count))
            then
            begin
              St := TsqlExpr.Create(FParser, True);
              if (WhenCount = FWhenStatement.Count) then
              begin
                (St as TsqlExpr).FExprs.Add(FWhenStatement.Extract(FWhenStatement[FWhenStatement.Count - 1]));
              end;
              FWhenStatement.Add(St);
              St.ParseStatement;
            end else
            //Если это конструкция как условие when
            if (eoWhen in FDone) and ((WhenCount = FWhenCondStatement.Count + 1)
              or (WhenCount = FWhenCondStatement.Count))
              and (not(eoWhen in FNeeded)) then
            begin
              St := TsqlExpr.Create(FParser, True);
              if (WhenCount = FWhenCondStatement.Count) then
              begin
                (St as TsqlExpr).FExprs.Add(FWhenCondStatement.Extract(
                  FWhenCondStatement[FWhenCondStatement.Count - 1]));
              end;
              FWhenCondStatement.Add(St);
              St.ParseStatement;
            end else
           //Если это переменная Case
            if (eoCase in FDone) then
            begin
              St := TsqlExpr.Create(FParser, True);
              if Assigned(FValue) then
              begin
                (St as TsqlExpr).FExprs.Add(FValue);
              end;
              FValue := St;
              FValue.ParseStatement;

            end else
              raise EatParserError.Create('Ошибка в sql-выражении: ' + Token.Text + '!');
            Continue;
          end;

          tkMath:
          begin
            //Если это конструкция на else
            if eoElse in FDone then
            begin
              St := TsqlCondition.Create(FParser);
              if Assigned(FElseStatement) then
              begin
               (St as TsqlCondition).FStatements.Add(FElseStatement);
              end else
              FElseStatement := St;
              FElseStatement.ParseStatement;
            end else
            //Если это конструкция после then
            if (eoThen in FDone) and (not(eoThen in FNeeded))
              and ((WhenCount = FWhenStatement.Count + 1) or
                (WhenCount = FWhenStatement.Count))
            then
            begin
              St := TsqlCondition.Create(FParser);
              if (WhenCount = FWhenStatement.Count) then
              begin
               (St as TsqlCondition).FStatements.Add(FWhenStatement.Extract(FWhenStatement[FWhenStatement.Count - 1]));
              end;
              FWhenStatement.Add(St);
              St.ParseStatement;
            end else
            //Если это конструкция как условие when
            if (eoWhen in FDone) and ((WhenCount = FWhenCondStatement.Count + 1)
              or (WhenCount = FWhenCondStatement.Count))
              and (not(eoWhen in FNeeded)) then
            begin
              St := TsqlCondition.Create(FParser);
              if (WhenCount = FWhenCondStatement.Count) then
              begin
               (St as TsqlCondition).FStatements.Add(FWhenCondStatement.Extract(
                  FWhenCondStatement[FWhenCondStatement.Count - 1]));
              end;
              FWhenCondStatement.Add(St);
              St.ParseStatement;
            end else
           //Если это переменная Case
            if (eoCase in FDone) then
            begin
              St := TsqlCondition.Create(FParser);
              if Assigned(FValue) then
              begin
                (St as TsqlCondition).FStatements.Add(FValue);
              end else
              FValue := St;
              FValue.ParseStatement;

            end else
              raise EatParserError.Create('Ошибка в sql-выражении: ' + Token.Text + '!');
            Continue;
          end;

          else begin
            Break;
          end;
        end;
      end;

    end;
    ReadNext;
  end;
end;


{ TsqlSubString }

procedure TsqlSubString.BuildStatement(out sql: String);
var
  S: String;
begin
  FValue.BuildStatement(sql);
  sql := SQL + S + ' ' + ClauseText[cFrom];
  FFrom.BuildStatement(S);
  sql := sql + ' ' + S + ' ' + ClauseText[cFor];;
  FFor.BuildStatement(S);
  sql := sql + ' ' + S ;
end;

constructor TsqlSubString.Create(AParser: TsqlParser);
begin
inherited;
  FDone := [];
  FNeeded := [eoValue, eoFor, eoFrom];
  FFrom := nil;
  FFor := nil;
  FValue := nil;

  FInternalStatement := nil;
end;

destructor TsqlSubString.Destroy;
begin

  if Assigned(FFor) and (FFor <> FInternalStatement) then
    FFor.Free;
  if Assigned(FValue) and (FValue <> FInternalStatement) then
    FValue.Free;
  if Assigned(FFrom) and (FFrom <> FInternalStatement) then
    FFrom.Free;

  if Assigned(FInternalStatement) then
    FInternalStatement.Free;
{  if Assigned(FInternalValue) then
    FInternalValue.Free;       }
  inherited;

end;

procedure TsqlSubString.ParseStatement;
var
  BracketCount: Integer;
  BeginIndex: Integer;
  St: TsqlStatement;
begin
  BracketCount := 0;

  while (FParser.Token.TokenType in [ttClear, ttNone, ttSpace]) do
    FParser.ReadNext;

  BeginIndex := FParser.Index;
  with FParser do
  while not (Token.TokenType in [ttClear, ttNone]) do
  begin
    case FToken.TokenType of

      ttClause:
      begin
        case Token.Clause of
          cSum, cAvg, cMax, cMin, cUpper,
          cCast, cCount, cFirst, cSkip, cExtract, cSubString:
          begin
            if FInternalStatement <> nil then
              raise Exception.Create('Ошибка в Cast-выражении!');
            FInternalStatement := TsqlFunction.Create(FParser, True);
            FInternalStatement.ParseStatement;
            Include(FDone, eoValue);
            Exclude(FNeeded, eoValue);
            Continue;
          end;

          cCase:
          begin
            if FInternalStatement <> nil then
              raise Exception.Create('Ошибка в Cast-выражении!');
            FInternalStatement := TsqlCase.Create(FParser);
            FInternalStatement.ParseStatement;
            Include(FDone, eoValue);
            Exclude(FNeeded, eoValue);
            Continue;
          end;

          cAs:
          begin
            if (BracketCount = 0)  then
              Break;

            if (FInternalStatement = nil) or (BracketCount <> 1) then
              raise Exception.Create('Ошибка в Cast-выражении!');
          end;

          cNull:
          begin
            if (eoValue in FNeeded) then
            begin
              FInternalStatement := TsqlValue.Create(FParser, True);
              FInternalStatement.ParseStatement;
              Include(FDone, eoValue);
              Exclude(FNeeded, eoValue);
              Continue;
            end
            else
              raise EatParserError.Create('Ошибка в SQL-выражении: ' + Token.Text);

          end;
          cFor:
          begin
            if eoFor in FNeeded then
            begin
              Include(FDone, eoFor);
              Exclude(FNeeded, eoFor);
              Include(FNeeded, eoValue);
              ReadNext;
              Continue;
            end
            else
              raise EatParserError.Create('Ошибка в SQL-выражении: ' + Token.Text);

          end;
          cFrom:
            if eoFrom in FNeeded then
            begin
              Include(FDone, eoFrom);
              Exclude(FNeeded, eoFrom);
              Include(FNeeded, eoValue);
              ReadNext;
              Continue;
            end
            else
              raise EatParserError.Create('Ошибка в SQL-выражении: ' + Token.Text);
          else begin
            Break;
          end;
        end;
      end;

      ttSymbolClause:
      begin
        case Token.SymbolClause of
          scBracketOpen:
          begin
            if (BeginIndex < FParser.Index) and not(eoType in FDone) then
            begin
              if (FInternalStatement <> nil) then
              begin
                FreeAndNil(FInternalStatement);
                RollBack;
                while Token.TokenType = ttSpace do
                  RollBack;
              end;
              St := TsqlFunction.Create(FParser, True);
              FInternalStatement := St;
              FInternalStatement.ParseStatement;

              Exclude(FNeeded, eoValue);
              Include(FDone, eoValue);
              Continue;

            end else
            begin
              Inc(BracketCount);
            end;
          end;

          scBracketClose:
          begin
            if BracketCount < 1 then
              Break;
            Dec(BracketCount);
            if BracketCount = 0 then
            begin
              ReadNext;
              Break;
            end;
          end;

          scComma:
          begin
            if BracketCount = 0 then
              Break;
          end

          else
            Break;
          end;
      end;

      ttWord:
      begin
        case Token.TextKind of

          tkUserText:
          begin
            if (eoValue in FNeeded) then
            begin
              FInternalStatement := TsqlValue.Create(FParser, True);
              FInternalStatement.ParseStatement;
              Include(FDone, eoValue);
              Exclude(FNeeded, eoValue);
              if (eoFrom in FNeeded) then
                FValue := FInternalStatement
              else if (eoFor in FNeeded) then
                FFrom := FInternalStatement
              else
                FFor := FInternalStatement;
              Continue;
            end
          end;

          tkText:
          begin
            if (eoValue in FNeeded) then
            begin
              FInternalStatement := TsqlField.Create(FParser, True);
              FInternalStatement.ParseStatement;
              Include(FDone, eoValue);
              Exclude(FNeeded, eoValue);
              if (eoFrom in FNeeded) then
              begin
                if Assigned(FValue) then
                  FValue.Free;
                FValue := FInternalStatement
              end
              else if (eoFor in FNeeded) then
              begin
                if Assigned(FFrom) then
                  FFrom.Free;
                FFrom := FInternalStatement
              end
              else
              begin
                if Assigned(FFor) then
                  FFor.Free;
                FFor := FInternalStatement;
              end;
              Continue;
            end else
              raise EatParserError.Create('Ошибка в SQL-выражении: ' + Token.Text);
          end;

          tkMathOp:
          begin
            St := TsqlExpr.Create(FParser, True);
            if eoValue in FDone then
            begin
              if FInternalStatement = nil then
                raise EatParserError.Create('Ошибка в SQL-выражении: ' + Token.Text);
              (St as TsqlExpr).FExprs.Add(FInternalStatement);
            end;
            FInternalStatement := St;
            FInternalStatement.ParseStatement;
            Include(FDone, eoValue);
            Exclude(FNeeded, eoValue);
            if (eoFrom in FNeeded) then
            begin
              if Assigned(FValue) then
                FValue.Free;
              FValue := FInternalStatement
            end
            else if (eoFor in FNeeded) then
            begin
              if Assigned(FFrom) then
                FFrom.Free;
              FFrom := FInternalStatement
            end
            else
            begin
              if Assigned(FFor) then
                FFor.Free;
              FFor := FInternalStatement;
            end;

            Continue;
          end;

          else begin
            Break;
          end;
        end;
      end;
    end;

    ReadNext;
  end;
end;

{ TsqlSimpleCase }

procedure TsqlSimpleCase.BuildStatement(out sql: String);
begin
  inherited;

end;

constructor TsqlSimpleCase.Create(AParser: TsqlParser);
begin
  inherited;

end;

destructor TsqlSimpleCase.Destroy;
begin
  inherited;

end;

procedure TsqlSimpleCase.ParseStatement;
begin
end;
(*
var
  St: TsqlStatement;
  {Счетчик when-конструкций}
  WhenCount: Integer;
begin
  WhenCount := 0;
  with FParser do
  while not (Token.TokenType in [ttClear, ttNone]) do
  begin
    case FToken.TokenType of

      ttClause:
      begin
        case Token.Clause of
          cCase:
          begin
            //Если в нашем выражении уже есть eoCase, значит это вложенный case
            if eoCase in FDone then
            begin
              //Если это конструкция на else
              if eoElse in FDone then
              begin
                if not Assigned(FElseStatement) then
                begin
                  FElseStatement := CreateCaseClause(FParser);
                  FElseStatement.ParseStatement;
                end else
                  raise EatParserError.Create('Ошибка в sql-выражении: CASE!');
              end else
              //Если это конструкция после then
              if (eoThen in FDone) and (not(eoThen in FNeeded))
                and (WhenCount = FWhenStatement.Count + 1) then
              begin
                St := CreateCaseClause(FParser);
                FWhenStatement.Add(St);
                St.ParseStatement;
              end else
              //Если это конструкция как условие when
              if (eoWhen in FDone) and (WhenCount = FWhenCondStatement.Count + 1)
                and (not(eoWhen in FNeeded)) then
              begin
                St := TsqlCase.Create(FParser);
                FWhenCondStatement.Add(St);
                St.ParseStatement;
              end else
              //Если это переменная Case
              if (eoCase in FDone) and (FValue = nil) then
              begin
                FValue := TsqlCase.Create(FParser);
                FValue.ParseStatement;
              end else
                raise EatParserError.Create('Ошибка в sql-выражении: CASE!');
            end else
            begin
              Include(FDone, eoCase);
              Exclude(FNeeded, eoCase);
            end;
          end;
          cWhen:
          begin
            if eoThen in FNeeded then
              raise EatParserError.Create('Ошибка в sql-выражении: WHEN!')
            else
            begin
              Include(FDone, eoWhen);
              Include(FNeeded, eoThen);
              Exclude(FNeeded, eoWhen);
              Inc(WhenCount);
            end;
          end;
          cThen:
          begin
            if eoThen in FNeeded then
            begin
              Include(FDone, eoThen);
              Exclude(FNeeded, eoThen);
              Include(FNeeded, eoWhen);
            end else
              raise EatParserError.Create('Ошибка в sql-выражении: THEN!');
          end;

          cElse:
          begin
            if (eoElse in FDone) or (WhenCount = 0) then
              raise EatParserError.Create('Ошибка в sql-выражении: ELSE!')
            else
            begin
              Include(FDone, eoElse);
            end;
          end;

          cEnd:
          begin
            ReadNext;
            Break;
          end;

          cSum, cAvg, cMax, cMin, cUpper,
          cCast, cCount, cFirst, cSkip, cExtract, cSubString:
          begin
            //Если это конструкция на else
            if eoElse in FDone then
            begin
              if not Assigned(FElseStatement) then
              begin
                FElseStatement := TsqlFunction.Create(FParser, True);
                FElseStatement.ParseStatement;
              end else
                raise EatParserError.Create('Ошибка в sql-выражении: ' + Token.Text + '!');
            end else
             //Если это конструкция после then
            if (eoThen in FDone) and not(eoThen in FNeeded)
              and (WhenCount = FWhenStatement.Count + 1) then
            begin
              St := TsqlFunction.Create(FParser, True);
              FWhenStatement.Add(St);
              St.ParseStatement;
            end else
            //Если это конструкция как условие when
            if (eoWhen in FDone) and (WhenCount = FWhenCondStatement.Count + 1)
              and (not(eoWhen in FNeeded)) then
            begin
              St := TsqlFunction.Create(FParser, True);
              FWhenCondStatement.Add(St);
              St.ParseStatement;
            end else
           //Если это переменная Case
            if (eoCase in FDone) and (FValue = nil) then
            begin
              FValue := TsqlFunction.Create(FParser, True);
              FValue.ParseStatement;
            end else
              raise EatParserError.Create('Ошибка в sql-выражении: ' + Token.Text + '!');
            Continue;
          end;

          cIn, cIs, cNull, cNot, cExists, cSingular:
          begin
            //Если это конструкция на else
            if eoElse in FDone then
            begin
              St := TsqlCondition.Create(FParser);
              if Assigned(FElseStatement) then
              begin
               (St as TsqlCondition).FStatements.Add(FElseStatement);
              end else
              FElseStatement := St;
              FElseStatement.ParseStatement;
            end else
            //Если это конструкция после then
            if (eoThen in FDone) and (not(eoThen in FNeeded))
              and ((WhenCount = FWhenStatement.Count + 1) or
                (WhenCount = FWhenStatement.Count))
            then
            begin
              St := TsqlCondition.Create(FParser);
              if (WhenCount = FWhenStatement.Count) then
              begin
               (St as TsqlCondition).FStatements.Add(FWhenStatement.Extract(FWhenStatement[FWhenStatement.Count - 1]));
              end;
              FWhenStatement.Add(St);
              St.ParseStatement;
            end else
            //Если это конструкция как условие when
            if (eoWhen in FDone) and ((WhenCount = FWhenCondStatement.Count + 1)
              or (WhenCount = FWhenCondStatement.Count))
              and (not(eoWhen in FNeeded)) then
            begin
              St := TsqlCondition.Create(FParser);
              if (WhenCount = FWhenCondStatement.Count) then
              begin
               (St as TsqlCondition).FStatements.Add(FWhenCondStatement.Extract(
                  FWhenCondStatement[FWhenCondStatement.Count - 1]));
              end;
              FWhenCondStatement.Add(St);
              St.ParseStatement;
            end else
           //Если это переменная Case
            if (eoCase in FDone) then
            begin
              St := TsqlCondition.Create(FParser);
              if Assigned(FValue) then
              begin
                (St as TsqlCondition).FStatements.Add(FValue);
              end else
              FValue := St;
              FValue.ParseStatement;

            end else
              raise EatParserError.Create('Ошибка в sql-выражении: ' + Token.Text + '!');
            Continue;
          end;

          else
            Break;
        end;
      end;

      ttSymbolClause:
      begin
        case Token.SymbolClause of
          scBracketOpen:
          begin
            //Если это конструкция на else
            if eoElse in FDone then
            begin
              if Assigned(FElseStatement) then
              begin
                FreeAndNil(FElseStatement);
                RollBack;
                while Token.TokenType = ttSpace do
                  RollBack;
              end;

              St := TsqlFunction.Create(FParser, True);
              FElseStatement := St;
              FElseStatement.ParseStatement;

            end else
            //Если это конструкция после then
            if (eoThen in FDone) and (not(eoThen in FNeeded))
              and ((WhenCount = FWhenStatement.Count + 1) or
                (WhenCount = FWhenStatement.Count))
            then
            begin
              if (WhenCount = FWhenStatement.Count) then
              begin
                FWhenStatement.Delete(FWhenStatement.Count - 1);
                RollBack;
                while Token.TokenType = ttSpace do
                  RollBack;
              end;
              St := TsqlFunction.Create(FParser, True);
              FWhenStatement.Add(St);
              St.ParseStatement;
            end else
            //Если это конструкция как условие when
            if (eoWhen in FDone) and ((WhenCount = FWhenCondStatement.Count + 1)
              or (WhenCount = FWhenCondStatement.Count))
              and (not(eoWhen in FNeeded)) then
            begin
              if (WhenCount = FWhenCondStatement.Count) then
              begin
                FWhenCondStatement.Delete(FWhenCondStatement.Count - 1);
                RollBack;
                while Token.TokenType = ttSpace do
                  RollBack;
              end;
              St := TsqlFunction.Create(FParser, True);
              FWhenCondStatement.Add(St);
              St.ParseStatement;
            end else
           //Если это переменная Case
            if (eoCase in FDone) then
            begin
              if Assigned(FValue) then
              begin
                FreeAndNil(FValue);
                RollBack;
                while Token.TokenType = ttSpace do
                  RollBack;
              end;
              St := TsqlFunction.Create(FParser, True);
              FValue := St;
              FValue.ParseStatement;

            end else
              raise EatParserError.Create('Ошибка в sql-выражении: ' + Token.Text + '!');
            Continue;
          end

          else
            Break;
          end;
      end;

      ttWord:
      begin
        case Token.TextKind of

          tkUserText:
          begin
            //Если это конструкция на else
            if eoElse in FDone then
            begin
              if not Assigned(FElseStatement) then
              begin
                FElseStatement := TsqlValue.Create(FParser, True);
                FElseStatement.ParseStatement;
              end else
                raise EatParserError.Create('Ошибка в sql-выражении: ' + Token.Text + '!');
            end else
            //Если это конструкция после then
            if (eoThen in FDone) and not(eoThen in FNeeded)
              and (WhenCount = FWhenStatement.Count + 1) then
            begin
              St := TsqlValue.Create(FParser, True);
              FWhenStatement.Add(St);
              St.ParseStatement;
            end else
            //Если это конструкция как условие when
            if (eoWhen in FDone) and (WhenCount = FWhenCondStatement.Count + 1)
              and (not(eoWhen in FNeeded)) then
            begin
              St := TsqlValue.Create(FParser, True);
              FWhenCondStatement.Add(St);
              St.ParseStatement;
            end else
            //Если это переменная Case
            if (eoCase in FDone) and (FValue = nil) then
            begin
              FValue := TsqlValue.Create(FParser, True);
              FValue.ParseStatement;
            end else
              raise EatParserError.Create('Ошибка в sql-выражении: ' + Token.Text + '!');
            Continue;              
          end;

          tkText:
          begin
            //Если это конструкция на else
            if eoElse in FDone then
            begin
              if not Assigned(FElseStatement) then
              begin
                FElseStatement := TsqlField.Create(FParser, True);
                FElseStatement.ParseStatement;
              end else
                raise EatParserError.Create('Ошибка в sql-выражении: ' + Token.Text + '!');
            end else
            //Если это конструкция после then
              //Если это конструкция после then
            if (eoThen in FDone) and (not(eoThen in FNeeded))
              and (WhenCount = FWhenStatement.Count + 1) then
            begin
              St := TsqlField.Create(FParser, True);
              FWhenStatement.Add(St);
              St.ParseStatement;
            end else
            //Если это конструкция как условие when
            if (eoWhen in FDone) and (WhenCount = FWhenCondStatement.Count + 1)
              and (not(eoWhen in FNeeded)) then
            begin
              St := TsqlField.Create(FParser, True);
              FWhenCondStatement.Add(St);
              St.ParseStatement;
            end else
            //Если это переменная Case
            if (eoCase in FDone) and (FValue = nil) then
            begin
              FValue := TsqlField.Create(FParser, True);
              FValue.ParseStatement;
            end else
              raise EatParserError.Create('Ошибка в sql-выражении: ' + Token.Text + '!');
            Continue;
          end;

          tkMathOp:
          begin
            //Если это конструкция на else
            if eoElse in FDone then
            begin
              St := TsqlExpr.Create(FParser, True);

              if Assigned(FElseStatement) then
              begin
                (St as TsqlExpr).FExprs.Add(FElseStatement);
              end;
              FElseStatement := St;
              FElseStatement.ParseStatement;

            end else
            //Если это конструкция после then
            if (eoThen in FDone) and (not(eoThen in FNeeded))
              and ((WhenCount = FWhenStatement.Count + 1) or
                (WhenCount = FWhenStatement.Count))
            then
            begin
              St := TsqlExpr.Create(FParser, True);
              if (WhenCount = FWhenStatement.Count) then
              begin
                (St as TsqlExpr).FExprs.Add(FWhenStatement.Extract(FWhenStatement[FWhenStatement.Count - 1]));
              end;
              FWhenStatement.Add(St);
              St.ParseStatement;
            end else
            //Если это конструкция как условие when
            if (eoWhen in FDone) and ((WhenCount = FWhenCondStatement.Count + 1)
              or (WhenCount = FWhenCondStatement.Count))
              and (not(eoWhen in FNeeded)) then
            begin
              St := TsqlExpr.Create(FParser, True);
              if (WhenCount = FWhenCondStatement.Count) then
              begin
                (St as TsqlExpr).FExprs.Add(FWhenCondStatement.Extract(
                  FWhenCondStatement[FWhenCondStatement.Count - 1]));
              end;
              FWhenCondStatement.Add(St);
              St.ParseStatement;
            end else
           //Если это переменная Case
            if (eoCase in FDone) then
            begin
              St := TsqlExpr.Create(FParser, True);
              if Assigned(FValue) then
              begin
                (St as TsqlExpr).FExprs.Add(FValue);
              end;
              FValue := St;
              FValue.ParseStatement;

            end else
              raise EatParserError.Create('Ошибка в sql-выражении: ' + Token.Text + '!');
            Continue;
          end;

          tkMath:
          begin
            //Если это конструкция на else
            if eoElse in FDone then
            begin
              St := TsqlCondition.Create(FParser);
              if Assigned(FElseStatement) then
              begin
               (St as TsqlCondition).FStatements.Add(FElseStatement);
              end else
              FElseStatement := St;
              FElseStatement.ParseStatement;
            end else
            //Если это конструкция после then
            if (eoThen in FDone) and (not(eoThen in FNeeded))
              and ((WhenCount = FWhenStatement.Count + 1) or
                (WhenCount = FWhenStatement.Count))
            then
            begin
              St := TsqlCondition.Create(FParser);
              if (WhenCount = FWhenStatement.Count) then
              begin
               (St as TsqlCondition).FStatements.Add(FWhenStatement.Extract(FWhenStatement[FWhenStatement.Count - 1]));
              end;
              FWhenStatement.Add(St);
              St.ParseStatement;
            end else
            //Если это конструкция как условие when
            if (eoWhen in FDone) and ((WhenCount = FWhenCondStatement.Count + 1)
              or (WhenCount = FWhenCondStatement.Count))
              and (not(eoWhen in FNeeded)) then
            begin
              St := TsqlCondition.Create(FParser);
              if (WhenCount = FWhenCondStatement.Count) then
              begin
               (St as TsqlCondition).FStatements.Add(FWhenCondStatement.Extract(
                  FWhenCondStatement[FWhenCondStatement.Count - 1]));
              end;
              FWhenCondStatement.Add(St);
              St.ParseStatement;
            end else
           //Если это переменная Case
            if (eoCase in FDone) then
            begin
              St := TsqlCondition.Create(FParser);
              if Assigned(FValue) then
              begin
                (St as TsqlCondition).FStatements.Add(FValue);
              end else
              FValue := St;
              FValue.ParseStatement;

            end else
              raise EatParserError.Create('Ошибка в sql-выражении: ' + Token.Text + '!');
            Continue;
          end;

          else begin
            Break;
          end;
        end;
      end;

    end;
    ReadNext;
  end;
end;
*)

{ TsqlSearchedCase }

procedure TsqlSearchedCase.BuildStatement(out sql: String);
begin
  inherited;

end;

constructor TsqlSearchedCase.Create(AParser: TsqlParser);
begin
  inherited;

end;

destructor TsqlSearchedCase.Destroy;
begin
  inherited;

end;

procedure TsqlSearchedCase.ParseStatement;
begin
  inherited;

end;

initialization
  ClausesList := TStringList.Create;
  ClausesList.Sorted := True;
  ClausesList.Duplicates := dupError;
  FillUpClausesList;

finalization
  FreeAndNil(ClausesList);
end.

