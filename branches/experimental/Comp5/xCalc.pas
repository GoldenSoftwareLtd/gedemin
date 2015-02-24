
{++

  Copyright (c) 1995-2000 by Golden Software of Belarus

  Module

    xcalc.pas

  Abstract

    Non-visual Delphi component. Formula calculator
    with parentheses support, variables and functions.
    Extended TEdit with built-in formula calculator.

  Author

    Andrei Kireev (Dec, 1995)

  Contact address

  Revisions history

    1.00    17-feb-96    andreik    Initial version.
    1.01    26-feb-96    andreik    Added boolean operators >, <, =,
                                    >= and <=. They results in 1 if
                                    condition is true and in 0 otherwise.
    1.02    29-aug-96    andreik    Fixed bug with priorities.
    1.03    09-nov-96    andreik    Fixed bug w/ priorities.
    1.04    27-dec-96    andreik    Fixed bug.
    1.05    10-jan-97    andreik    Fixed bug.
    1.06    15-feb-97    andreik    Support of russian added.
    1.07    20-oct-97    andreik    Delphi32 version.
    1.08    05-oct-98    andreik    Minor bug fixed.
    1.09    06-oct-98    andreik    Minor bug caused by new Delphi strings fixed.
    1.10    15.03.99     sai        DeleteAllVariable
    1.11    27.01.00     andreik    Functions Round, Frac, Round10, Round100, Round1000 added.
--}

unit xCalc;

interface

uses
  WinTypes, WinProcs, Classes, SysUtils, StdCtrls, Menus, Messages;

type
  TCalcOperation = Char;

type
  TFunction = function(V: Double): Double;

type
  TFunctionEvent = function(const FuncName: String; var V: Double): Boolean of object;

const
  DefStrictVars = True;

const
  StackSize = 200;
  cst_Small = 0.00000000000000000000000001;
type
  TDoubleStack = class(TObject)
  private
    Data: array[0..StackSize - 1] of Double;
    Top: Integer;

    function GetEmpty: Boolean;
    function GetAsString: String;

  public
    constructor Create;

    procedure Push(const V: Double);
    function Pop: Double;
    function Peek: Double;

    { reverses first C items in the stack }
    procedure TurnUpSideDown(C: Integer);

    { removes first C items from the stack }
    { and creates new object based on these }
    function Split(C: Integer): TDoubleStack;

    property Empty: Boolean read GetEmpty;
    property Count: Integer read Top;
    property AsString: String read GetAsString;
  end;

  EDoubleStackError = class(Exception);

type
  TOpStack = class(TObject)
  private
    Data: array[0..StackSize - 1] of TCalcOperation;
    Top: Integer;

    function GetEmpty: Boolean;
    function GetAsString: String;
    function GetItem(Index: Integer): TCalcOperation;

  public
    constructor Create;

    procedure Push(Op: TCalcOperation);
    function Pop: TCalcOperation;
    function Peek: TCalcOperation;

    { removes first C items from the stack }
    { and creates new object based on these }
    function Split(C: Integer): TOpStack;

    property Count: Integer read Top;
    property Empty: Boolean read GetEmpty;
    property AsString: String read GetAsString;
    property Items[Index: Integer]: TCalcOperation read GetItem; default;
  end;

  EOpStackError = class(Exception);

type
  TxCustomFoCal = class(TComponent)
  private
    FExpression: String;
    FValue: Double;
    FRequiredVariables: TStringList;
    FVariables: TList;
    FFunctions: TList;
    FStrictVars: Boolean;
    FOnFunction: TFunctionEvent;
    FOnVariable: TFunctionEvent;
    StringList: TStringList;

    procedure SetExpression(AnExpression: String);
    procedure SetValue(AValue: Double);
    function GetVariables: TStringList;
    function GetFunctions: TStringList;
    procedure SetFunctions(AFunctions: TStringList);

    function ParseNumber(const S: String; var B: Integer): Double;
    function ParseIdentifier(const S: String; var B: Integer): String;
    function GetPriority(AnOp: TCalcOperation): Integer;
    function CalcSubExpression(S: String; var B: Integer): Double;
    function CalcCurrState(OpStack: TOpStack; ValStack: TDoubleStack): Double;
    function CalcExpression(S: String): Double;

    procedure ReadVariables(Reader: TReader);
    procedure WriteVariables(Writer: TWriter);

  protected
    procedure Loaded; override;
    procedure DefineProperties(Filer: TFiler); override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure Load(Reader: TReader);
    procedure Save(Writer: TWriter);

    procedure AssignVariables(AVariables: TStringList);
    procedure AssignVariable(AName: String; AValue: Double);
    procedure DeleteVariable(AName: String);

    procedure AddFunction(AName: String; AFunc: TFunction);
    procedure DeleteFunction(AName: String);

    procedure ClearVariablesList;
    procedure DeleteAllVariable;

    property Value: Double read FValue write SetValue; { must be before Expression }
    property Expression: String read FExpression write SetExpression;
    property RequiredVariables: TStringList read FRequiredVariables
      stored False;
    property Variables: TStringList read GetVariables write AssignVariables
      stored False;
    property Functions: TStringList read GetFunctions write SetFunctions
      stored False;
    property StrictVars: Boolean read FStrictVars write FStrictVars
      default DefStrictVars;
    property OnFunction: TFunctionEvent read FOnFunction write FOnFunction;
    property OnVariable: TFunctionEvent read FOnVariable write FOnVariable;
  end;

  ExCustomFoCalError = class(Exception);

type
  TxFoCal = class(TxCustomFoCal)
  published
    property Value; { must be before Expression }
    property Expression;
    property Variables;
    property Functions;
    property StrictVars;
    property OnFunction;
  end;

const
  DefErrMsg = 'Incorrect Expression';
  DefCalcOnShortCut = 0;
  DefShowFormula = False;
  DefDecDigits = 2;

type
  TxCalcEdit = class(TEdit)
  private
    FCalcOnShortCut: TShortCut;
    FErrMsg: String;
    FShowFormula: Boolean;
    FDecDigits: Word;

    FoCal: TxCustomFoCal;
    Formula: String;
    ResetFormula: Boolean;
    IsShortCut: Boolean;

    OldOnEnter, OldOnExit, OldOnChange: TNotifyEvent;

    procedure SetShowFormula(AShowFormula: Boolean);
    procedure SetDecDigits(ADecDigits: Word);
    function GetVariables: TStringList;
    procedure SetFunctions(AFunctions: TStringList);
    function GetFunctions: TStringList;
    procedure SetStrictVars(AStrictVars: Boolean);
    function GetStrictVars: Boolean;
    function GetValue: Double;
    procedure SetValue(AValue: Double);
    procedure SetOnFunction(AnOnFunction: TFunctionEvent);
    function GetOnFunction: TFunctionEvent;

    function CalcExpr(AnExpr: String): String;

    procedure DoOnEnter(Sender: TObject);
    procedure DoOnExit(Sender: TObject);
    procedure DoOnChange(Sender: TObject);

    procedure ReadFoCal(Reader: TReader);
    procedure WriteFoCal(Writer: TWriter);

    procedure WMLButtonDown(var Message: TWMLButtonDown);
      message WM_LBUTTONDOWN;
    procedure WMRButtonDown(var Message: TWMRButtonDown);
      message WM_RBUTTONDOWN;
    procedure WMKeyDown(var Message: TWMKeyDown);
      message WM_KEYDOWN;
    procedure WMChar(var Message: TWMChar);
      message WM_CHAR;
    procedure WMDestroy(var Message: TWMDestroy);
      message WM_DESTROY;

  protected
    procedure DefineProperties(Filer: TFiler); override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure AssignVariables(AVariables: TStringList);
    procedure AssignVariable(AName: String; AValue: Double);
    procedure DeleteVariable(AName: String);

    procedure AddFunction(AName: String; AFunc: TFunction);
    procedure DeleteFunction(AName: String);

  published
    property CalcOnShortCut: TShortCut read FCalcOnShortCut write FCalcOnShortCut
      default DefCalcOnShortCut;
    property ErrMsg: String read FErrMsg write FErrMsg;
    property ShowFormula: Boolean read FShowFormula write SetShowFormula
      default DefShowFormula;
    property DecDigits: Word read FDecDigits write SetDecDigits
      default DefDecDigits;
    property Variables: TStringList read GetVariables write AssignVariables
      stored False;
    property Functions: TStringList read GetFunctions write SetFunctions
      stored False;
    property StrictVars: Boolean read GetStrictVars write SetStrictVars
      stored False;
    property Value: Double read GetValue write SetValue stored False;
    property OnFunction: TFunctionEvent read GetOnFunction write SetOnFunction;
  end;

  ExCalcEditError = class(Exception);

procedure Register;

implementation

{ Auxiliry functions -------------------------------------}

{ deletes all spaces from the given String }
function MakeItThin(const S: String): String;
var
  I: Integer;
begin
  Result := '';
  for I := 1 to Length(S) do
    if not (S[I] in [#32, #9]) then
      Result := Result + S[I];
end;

{ Stack of doubles ---------------------------------------}

constructor TDoubleStack.Create;
begin
  inherited Create;
  Top := 0;
end;

procedure TDoubleStack.Push(const V: Double);
begin
  if Top = StackSize then
    raise EDoubleStackError.Create('Stack overflow');
  Data[Top] := V;
  Inc(Top);
end;

function TDoubleStack.Pop: Double;
begin
  if Top = 0 then
    raise EDoubleStackError.Create('Stack underflow');
  Dec(Top);
  Result := Data[Top];
end;

function TDoubleStack.Peek: Double;
begin
  if Top = 0 then
    raise EDoubleStackError.Create('Stack underflow');
  Result := Data[Top - 1];
end;

procedure TDoubleStack.TurnUpSideDown(C: Integer);
var
  D: Double;
  I, K: Integer;
begin
  if (C < 2) or (Count < C) then
    raise EDoubleStackError.Create('Invalid parameter');

  I := Round((C / 2) + cst_small);
  for K := 1 to I do
  begin
    D := Data[Top - K];
    Data[Top - K] := Data[Top - C + K - 1];
    Data[Top - C + K - 1] := D;
  end;
end;

function TDoubleStack.Split(C: Integer): TDoubleStack;
var
  I: Integer;
begin
  if (C < 1) or (C > Count) then
    raise EDoubleStackError.Create('Invalid parameter');

  Result := TDoubleStack.Create;
  for I := Top - C to Top - 1 do
    Result.Push(Data[I]);
  Dec(Top, C);
end;

function TDoubleStack.GetEmpty: Boolean;
begin
  Result := Top = 0;
end;

function TDoubleStack.GetAsString: String;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to Count - 1 do
    Result := Result + Format('%g; ', [Data[I]]);
end;

{ Stack of operations ------------------------------------}

constructor TOpStack.Create;
begin
  inherited Create;
  Top := 0;
end;

procedure TOpStack.Push(Op: TCalcOperation);
begin
  if Top = StackSize then
    raise EOpStackError.Create('Stack overflow');
  Data[Top] := Op;
  Inc(Top);
end;

function TOpStack.Pop: TCalcOperation;
begin
  if Top = 0 then
    raise EOpStackError.Create('Stack underflow');
  Dec(Top);
  Result := Data[Top];
end;

function TOpStack.Peek: TCalcOperation;
begin
  if Top = 0 then
    raise EOpStackError.Create('Stack underflow');
  Result := Data[Top - 1];
end;

function TOpStack.Split(C: Integer): TOpStack;
var
  I: Integer;
begin
  if (C < 1) or (C > Count) then
    raise EDoubleStackError.Create('Invalid parameter');

  Result := TOpStack.Create;
  for I := Top - C to Top - 1 do
    Result.Push(Data[I]);
  Dec(Top, C);
end;

function TOpStack.GetEmpty: Boolean;
begin
  Result := Top = 0;
end;

function TOpStack.GetAsString: String;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to Count - 1 do
    Result := Result + Data[I] + ' ';
end;

function TOpStack.GetItem(Index: Integer): TCalcOperation;
begin
  if (Index < 0) or (Index >= Count) then
    raise EOpStackError.Create('Invalid index');

  Result := Data[Index];
end;

{ TVariable record ---------------------------------------}

type
  PVariable = ^TVariable;
  TVariable = record
    Name: String;
    Value: Double;
  end;

{ TFunctionRec -------------------------------------------}

type
  PFunctionRec = ^TFunctionRec;
  TFunctionRec = record
    Name: String;
    Func: TFunction;
  end;

{ Predefined functions -----------------------------------}

function _sin(V: Double): Double; far;
begin
  Result := Sin(V);
end;

function _cos(V: Double): Double; far;
begin
  Result := Cos(V);
end;

function _tan(V: Double): Double; far;
begin
  Result := Sin(V) / Cos(V);
end;

function _sqrt(V: Double): Double; far;
begin
  Result := Sqrt(V);
end;

function _abs(V: Double): Double; far;
begin
  Result := Abs(V);
end;

function _arctan(V: Double): Double; far;
begin
  Result := ArcTan(V);
end;

function _exp(V: Double): Double; far;
begin
  Result := Exp(V);
end;

function _frac(V: Double): Double; far;
begin
  Result := Frac(V);
end;

function _int(V: Double): Double; far;
begin
  Result := Int(V);
end;

function _ln(V: Double): Double; far;
begin
  Result := Ln(V);
end;

function _sqr(V: Double): Double; far;
begin
  Result := Sqr(V);
end;

function _round(V: Double): Double; far;
begin
  Result := Round(V + cst_small);
end;

// акругленьне да 10
function _round10(V: Double): Double; far;
begin
  Result := Round(V / 10 + cst_small) * 10;
end;

// акругленьне да 100
function _round100(V: Double): Double; far;
begin
  Result := Round(V / 100 + cst_small) * 100;
end;

// акругленьне да 1000
function _round1000(V: Double): Double; far;
begin
  Result := Round(V / 1000 + cst_small) * 1000;
end;

{ TxCustomFoCal -------------------------------------------}

constructor TxCustomFoCal.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  StringList := TStringList.Create;

  FExpression := '0';
  FValue := 0;
  FRequiredVariables := TStringList.Create;
  FRequiredVariables.Sorted := True;
  FRequiredVariables.Duplicates := dupIgnore;

  FVariables := TList.Create;
  FFunctions := TList.Create;
  FStrictVars := DefStrictVars;

  { add predefined variables }
  AssignVariable('PI', Pi);
  AssignVariable('E', Exp(1));

  { add predefined functions }
  AddFunction('SIN', _sin);
  AddFunction('COS', _cos);
  AddFunction('TAN', _tan);
  AddFunction('ABS', _abs);
  AddFunction('ARCTAN', _arctan);
  AddFunction('EXP', _exp);
  AddFunction('FRAC', _frac);
  AddFunction('INT', _int);
  AddFunction('LN', _ln);
  AddFunction('SQR', _sqr);
  AddFunction('SQRT', _sqrt);
  AddFunction('ROUND', _round);
  AddFunction('FRAC', _frac);
  AddFunction('ROUND10', _round10);
  AddFunction('ROUND100', _round100);
  AddFunction('ROUND1000', _round1000);
end;

destructor TxCustomFoCal.Destroy;
var
  I: Integer;
begin
  ClearVariablesList;
  FVariables.Free;
  FRequiredVariables.Free;

  for I := 0 to FFunctions.Count - 1 do
    if FFunctions[I] <> nil then Dispose(PFunctionRec(FFunctions[I]));
  FFunctions.Free;

  StringList.Free;

  inherited Destroy;
end;

procedure TxCustomFoCal.Load(Reader: TReader);
begin
  ReadVariables(Reader);
  Expression := Reader.ReadString; { read and calc expression }
end;

procedure TxCustomFoCal.Save(Writer: TWriter);
begin
  WriteVariables(Writer);
  Writer.WriteString(FExpression);
end;

procedure TxCustomFoCal.AssignVariable(AName: String; AValue: Double);
var
  P: PVariable;
  I: Integer;
begin
  for I := 0 to FVariables.Count - 1 do
    if (FVariables[I] <> nil)
      and (AnsiCompareText(PVariable(FVariables[I])^.Name, AName) = 0) then
    begin
      PVariable(FVariables[I])^.Value := AValue;
      exit;
    end;

  P := New(PVariable);
  P^.Name := AName;
  P^.Value := AValue;
  FVariables.Add(P);
end;

procedure TxCustomFoCal.DeleteVariable(AName: String);
var
  I: Integer;
begin
  for I := 0 to FVariables.Count - 1 do
    if (FVariables[I] <> nil)
      and (AnsiCompareText(PVariable(FVariables[I])^.Name, AName) = 0) then
    begin
      Dispose(PVariable(FVariables[I]));
      FVariables[I] := nil;
      FVariables.Pack;
      exit;
    end;
  raise ExCustomFoCalError.Create('Invalid variable name');
end;

procedure TxCustomFoCal.AddFunction(AName: String; AFunc: TFunction);
var
  P: PFunctionRec;
begin
  P := New(PFunctionRec);
  P^.Name := AName;
  P^.Func := AFunc;
  FFunctions.Add(P);
end;

procedure TxCustomFoCal.DeleteFunction(AName: String);
var
  I: Integer;
begin
  for I := 0 to FFunctions.Count - 1 do
    if (FFunctions[I] <> nil)
      and (AnsiCompareText(PFunctionRec(FFunctions[I])^.Name, AName) = 0) then
    begin
      Dispose(PFunctionRec(FFunctions[I]));
      FFunctions[I] := nil;
      FFunctions.Pack;
      exit;
    end;
  raise ExCustomFoCalError.Create('Invalid function name');
end;

procedure TxCustomFoCal.Loaded;
begin
  inherited Loaded;
  Expression := FExpression; {calculate expression}
end;

procedure TxCustomFoCal.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineProperty('_variables_', ReadVariables, WriteVariables,
    FVariables.Count > 0);
end;

function TxCustomFoCal.ParseNumber(const S: String; var B: Integer): Double;
var
  I{, Code}: Integer;
begin
  I := B;
  while (B <= Length(S)) and ((S[B] in ['0'..'9', DecimalSeparator])
    or ((S[B] = 'E') and (B < Length(S)) and (S[B + 1] in ['+', '-']))
    or ((S[B] in ['+', '-']) and (B > 1) and (S[B - 1] = 'E'))) do Inc(B);

  //Val(Copy(S, I, B - I), Result, Code);

  try
    Result := StrToFloat(Copy(S, I, B - I));
  except
    raise ExCustomFoCalError.Create('Invalid number format');
  end;
end;

function TxCustomFoCal.ParseIdentifier(const S: String; var B: Integer): String;
var
  I: Integer;
begin
  if S[B] in ['0'..'9'] then
    raise ExCustomFoCalError.Create('Invalid identifier');
  I := B;
  while (B <= Length(S)) and (S[B] in ['A'..'Z', '0'..'9', 'А'..'Я', 'а'..'я', '_', '$']) do
    Inc(B);
{  while (I < B) and (S[B - 1] in ['0'..'9']) do Dec(B); }
  if I = B then
    raise ExCustomFoCalError.Create('Invalid identifier');
  Result := Copy(S, I, B - I);
end;

function TxCustomFoCal.GetPriority(AnOp: TCalcOperation): Integer;
begin
  case AnOp of
    '<', '>', '=', 'g', 'l': Result := 0;
    '+', '-': Result := 1;
    '*', '/', '\', '@': Result := 2; { last two are div and mod }
    '^': Result := 3;
    '%': Result := 4; { our operation 'percent' }
    'u': Result := 5; { the unary minus has a higher priority }
  else
    raise ExCustomFoCalError.Create('Invalid operation');
  end;
end;

function TxCustomFoCal.CalcSubExpression(S: String; var B: Integer): Double;
var
  K, C: Integer;
begin
  if S[B] <> '(' then
    raise ExCustomFoCalError.Create('Opening parenthesis expected');

  K := B;
  C := 0;
  while B <= Length(S) do
  begin
    if S[B] = '(' then Inc(C)
    else if (S[B] = ')') and (C = 1) then break
    else if S[B] = ')' then Dec(C);
    Inc(B);
  end;
  if B > Length(S) then
    raise ExCustomFoCalError.Create('Closing parenthesis mismatch');
  Result := CalcExpression(Copy(S, K + 1, B - K - 1));
  Inc(B);
end;

function Ternary(Bool: Boolean; A, B: Integer): Integer;
begin
  if Bool then Result := A else Result := B;
end;

function TxCustomFocal.CalcCurrState(OpStack: TOpStack;
  ValStack: TDoubleStack): Double;
var
  X, Y: Double;
  O: TCalcOperation;
begin
  try
    O := OpStack.Peek;

    while (not OpStack.Empty) and (GetPriority(O) <= GetPriority(OpStack.Peek)) do
    begin
      O := OpStack.Pop;
      Y := ValStack.Pop;
      X := ValStack.Pop;

      case O of
        '+': ValStack.Push(X + Y);
        '-', 'u': ValStack.Push(X - Y);
        '*': ValStack.Push(X * Y);
        '/': if Y <> 0 then ValStack.Push(X / Y)
               else raise ExCustomFoCalError.Create('Division by zero');
        '^': if Y >= 0 then ValStack.Push(Exp(Y * Ln(X)))
               else raise ExCustomFoCalError.Create('Invalid operation');
        '%': ValStack.Push((X / 100) * Y);
        '\': if Y <> 0 then ValStack.Push(Int(X / Y))
               else raise ExCustomFoCalError.Create('Division by zero');
        '@': if Y <> 0 then ValStack.Push(X - Int(X / Y) * Y)
               else raise ExCustomFoCalError.Create('Division by zero');
        '<': ValStack.Push(Ternary(X < Y, 1, 0));
        '>': ValStack.Push(Ternary(X > Y, 1, 0));
        '=': ValStack.Push(Ternary(X = Y, 1, 0));
        'g': ValStack.Push(Ternary(X >= Y, 1, 0));
        'l': ValStack.Push(Ternary(X <= Y, 1, 0));
      else
        raise ExCustomFoCalError.Create('Unknown operation');
      end;
    end; { while }

    Result := ValStack.Pop;
  except
(*    on EOpStackError do Result := ValStack.Pop; { operat. stack is empty }  *)
    on EDoubleStackError do raise ExCustomFoCalError.Create('Error in expression');
  end;
end;

function TxCustomFoCal.CalcExpression(S: String): Double;
var
  B, I: Integer;
  Id: String;
  Op: TCalcOperation;
  OpStack: TOpStack;
  ValStack: TDoubleStack;
  WasFound: Boolean;
  V: Double;

begin
  Result := 0;

  OpStack := TOpStack.Create;
  ValStack := TDoubleStack.Create;
  try
    S := AnsiUpperCase(MakeItThin(S));
    B := 1;

    while B <= Length(S) do
    begin
      case S[B] of
        '0'..'9': ValStack.Push(ParseNumber(S, B));
        '.', ',':
          if S[B] = DecimalSeparator then
            ValStack.Push(ParseNumber(S, B))
          else begin
            S[B] := DecimalSeparator;
            ValStack.Push(ParseNumber(S, B));
          end;
          {else
            raise ExCustomFoCalError.Create('Invalid Decimal Separator');}

        '(': ValStack.Push(CalcSubExpression(S, B));

        '+', '-', '*', '/', '^', '%', '<', '>', '=':
          begin
            { check for the unary operations }
            if ValStack.Empty and ((S[B] = '-') or (S[B] = '+')) then
            begin
              { we ignore unary plus }
              if S[B] = '-' then
              begin
                ValStack.Push(0);
                OpStack.Push('u'); { the special operation -- unary minus }
              end;
            end else begin
              Op := S[B];

              { logical operations }
              if (Op = '<') and (B < Length(S)) and (S[B + 1] = '=') then
              begin
                Op := 'l';
                Inc(B);
              end
              else if (Op = '>') and (B < Length(S)) and (S[B + 1] = '=') then
              begin
                Op := 'g';
                Inc(B);
              end;

              if not OpStack.Empty then
                if GetPriority(Op) <= GetPriority(OpStack.Peek) then
                  ValStack.Push(CalcCurrState(OpStack, ValStack));

              OpStack.Push(Op)
            end;

            Inc(B);
          end; { operations }
      else
        Id := ParseIdentifier(S, B);

        Op := #0;
        if AnsiCompareText(Copy(Id, 1, 3), 'DIV') = 0 then Op := '\'
        else if AnsiCompareText(Copy(Id, 1, 3), 'MOD') = 0 then Op := '@';

        if (Op <> #0) then
        begin
          if not OpStack.Empty then
            if GetPriority(Op) <= GetPriority(OpStack.Peek) then
              ValStack.Push(CalcCurrState(OpStack, ValStack));

          OpStack.Push(Op);

          Dec(B, Length(Id) - 3);
        end else
        begin
          WasFound := False;
          FRequiredVariables.Add(Id);

          for I := 0 to FVariables.Count - 1 do
            if (FVariables[I] <> nil)
              and (AnsiCompareText(Id, PVariable(FVariables[I])^.Name) = 0) then
            begin
              ValStack.Push(PVariable(FVariables[I])^.Value);
              WasFound := True;
              break;
            end;

          if WasFound then Continue;

          for I := 0 to FFunctions.Count - 1 do
            if (FFunctions[I] <> nil)
              and (AnsiCompareText(Id, PFunctionRec(FFunctions[I])^.Name) = 0) then
            begin
              ValStack.Push(PFunctionRec(FFunctions[I])^.
                Func(CalcSubExpression(S, B)));
              WasFound := True;
              Break;
            end;

          if not WasFound then
          begin
            if S[B] = '(' then
            begin
              if Assigned(FOnFunction) then
              begin
                V := CalcSubExpression(S, B);
                if FOnFunction(Id, V) then
                begin
                  ValStack.Push(V);
                  continue;
                end;
              end;
              raise ExCustomFoCalError.Create('Unknown function name');
            end else
            begin
              if Assigned(FOnVariable) then
              begin
                if FOnVariable(Id, V) then
                begin
                  ValStack.Push(V);
                  continue;
                end;
              end;
            end;

            if FStrictVars then
              raise ExCustomFoCalError.Create('Unknown identifier')
            else
              ValStack.Push(0);
          end;
        end; { else of if Op <> #0 }
      end; { case }
    end; { while }

    while not OpStack.Empty do
      ValStack.Push(CalcCurrState(OpStack, ValStack));

    if ValStack.Count = 1 then
      Result := ValStack.Pop
    else if ValStack.Count > 1 then
      raise ExCustomFoCalError.Create('Invalid expression')
    else
      raise ExCustomFoCalError.Create('Empty expression');

  finally
    OpStack.Free;
    ValStack.Free;
  end;
end;

procedure TxCustomFoCal.SetExpression(AnExpression: String);
begin
  FExpression := AnExpression;
  if not (csLoading in ComponentState) then
  begin
    FRequiredVariables.Clear;
    if FExpression > '' then
      try
        FValue := CalcExpression(FExpression)
      except
        on Exception do
        begin
          FValue := 0;
          FExpression := 'Error';
        end;
      end
    else begin
      FValue := 0;
      FExpression := '0';
    end;
  end;
end;

procedure TxCustomFoCal.SetValue(AValue: Double);
begin
  FValue := AValue;
  Str(FValue, FExpression);
end;

function TxCustomFoCal.GetVariables: TStringList;
var
  I: Integer;
begin
  Result := StringList;
  Result.Clear;
  for I := 0 to FVariables.Count - 1 do
    if FVariables[I] <> nil then
      Result.Add(Format('%s = %e', [PVariable(FVariables[I])^.Name,
        PVariable(FVariables[I])^.Value]));
end;

procedure TxCustomFoCal.AssignVariables(AVariables: TStringList);
var
  I: Integer;
  V: Double;
begin
  ClearVariablesList;

  for I := 0 to AVariables.Count - 1 do
    if Pos('=', AVariables[I]) <> 0 then
    begin
      try
        V := StrToFloat(Copy(AVariables[I], Pos('=', AVariables[I]) + 1, 255));
      except
        raise ExCustomFoCalError.Create('Invalid number format');
      end;

      AssignVariable(AnsiUpperCase(
        MakeItThin(Copy(AVariables[I], 1, Pos('=', AVariables[I]) - 1))), V);
    end;
end;

function TxCustomFoCal.GetFunctions: TStringList;
var
  I: Integer;
begin
  Result := StringList;
  Result.Clear;
  for I := 0 to FFunctions.Count - 1 do
    if FFunctions[I] <> nil then
      Result.Add(PFunctionRec(FFunctions[I])^.Name);
end;

procedure TxCustomFoCal.SetFunctions(AFunctions: TStringList);
begin
  { dummy function
    we need in it to show property
    in the Object Inspector }
end;

procedure TxCustomFoCal.ReadVariables(Reader: TReader);
var
  V: TVariable;
  T: Byte;
begin
  Reader.ReadListBegin;
  while not Reader.EndOfList do
  begin
    if Reader.NextValue in [vaString, vaLString] then
    begin
      V.Name := Reader.ReadString;
      V.Value := Reader.ReadFloat;
      AssignVariable(V.Name, V.Value);
    end else
    begin
      // мы столкнулись со старой версией
      // просто пропустим ее данные
      while not Reader.EndOfList do
        Reader.Read(T, 1);
      break;
    end;
  end;
  Reader.ReadListEnd;
end;

procedure TxCustomFoCal.WriteVariables(Writer: TWriter);
var
  I: Integer;
begin
  Writer.WriteListBegin;
  for I := 0 to FVariables.Count - 1 do
    if FVariables[I] <> nil then
    begin
      Writer.WriteString(PVariable(FVariables[I])^.Name);
      Writer.WriteFloat(PVariable(FVariables[I])^.Value);
    end;
  Writer.WriteListEnd;
end;

procedure TxCustomFoCal.ClearVariablesList;
var
  I: Integer;
begin
  for I := 0 to FVariables.Count - 1 do
    if FVariables[I] <> nil then
    begin
      Dispose(PVariable(FVariables[I]));
      FVariables[I] := nil;
    end;
  FVariables.Clear;
end;

{ TxCalcEdit ----------------------------------------------}

constructor TxCalcEdit.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  FoCal := TxCustomFoCal.Create(Self);

  FCalcOnShortCut := DefCalcOnShortCut;
  FErrMsg := DefErrMsg;
  FShowFormula := DefShowFormula;
  FDecDigits := DefDecDigits;

  Text := '';
  Formula := '';
  ResetFormula := True;
  IsShortCut := False;

  OldOnEnter := OnEnter;
  OnEnter := DoOnEnter;

  OldOnExit := OnExit;
  OnExit := DoOnExit;

  OldOnChange := OnChange;
  OnChange := DoOnChange;
  {$IFDEF GEDEMIN}
  HelpContext := 9;
  {$ENDIF}
end;

destructor TxCalcEdit.Destroy;
begin
  FoCal.Free;
  inherited Destroy;
end;

procedure TxCalcEdit.AssignVariables(AVariables: TStringList);
begin
  FoCal.AssignVariables(AVariables);
end;

procedure TxCalcEdit.AssignVariable(AName: String; AValue: Double);
begin
  FoCal.AssignVariable(AName, AValue);
end;

procedure TxCalcEdit.DeleteVariable(AName: String);
begin
  FoCal.DeleteVariable(AName);
end;

procedure TxCalcEdit.AddFunction(AName: String; AFunc: TFunction);
begin
  FoCal.AddFunction(AName, AFunc);
end;

procedure TxCalcEdit.DeleteFunction(AName: String);
begin
  FoCal.DeleteFunction(AName);
end;

procedure TxCalcEdit.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineProperty('_focal_', ReadFoCal, WriteFoCal, True);
end;

procedure TxCalcEdit.SetShowFormula(AShowFormula: Boolean);
begin
  if FShowFormula <> AShowFormula then
  begin
    FShowFormula := AShowFormula;
    if not (csDesigning in ComponentState) then Text := Formula;
  end;
end;

procedure TxCalcEdit.SetDecDigits(ADecDigits: Word);
begin
  if FDecDigits <> ADecDigits then
  begin
    FDecDigits := ADecDigits;
    if (not (csDesigning in ComponentState))
      and (not (csLoading in ComponentState)) then
    begin
      ResetFormula := False;
      Text := CalcExpr(Formula);
    end;
  end;
end;

function TxCalcEdit.GetVariables: TStringList;
begin
  Result := FoCal.Variables;
end;

procedure TxCalcEdit.SetFunctions(AFunctions: TStringList);
begin
  { dummy function }
end;

function TxCalcEdit.GetFunctions: TStringList;
begin
  Result := FoCal.Functions;
end;

procedure TxCalcEdit.SetStrictVars(AStrictVars: Boolean);
begin
  FoCal.StrictVars := AStrictVars;
end;

function TxCalcEdit.GetStrictVars: Boolean;
begin
  Result := FoCal.StrictVars;
end;

function TxCalcEdit.GetValue: Double;
begin
  Result := FoCal.Value;
end;

procedure TxCalcEdit.SetValue(AValue: Double);
begin
  FoCal.Value := AValue;
  Text := FoCal.Expression;
end;

function TxCalcEdit.GetOnFunction: TFunctionEvent;
begin
  Result := FoCal.OnFunction;
end;

procedure TxCalcEdit.SetOnFunction(AnOnFunction: TFunctionEvent);
begin
  FoCal.OnFunction := AnOnFunction;
end;

function TxCalcEdit.CalcExpr(AnExpr: String): String;
begin
  try
    FoCal.Expression := AnExpr;
  except
    Result := FErrMsg;
    exit;
  end;

{  Result:= Format('%.*f', [FDecDigits, FoCal.Value]);}
  Str(FoCal.Value: 0: FDecDigits, Result);
end;

procedure TxCalcEdit.DoOnEnter(Sender: TObject);
begin
  if AnsiCompareText(Text, FErrMsg) = 0 then
    SelectAll
  else
    if FShowFormula then Text := Formula;
  if Assigned(OldOnEnter) then OldOnEnter(Sender);
end;

procedure TxCalcEdit.DoOnExit(Sender: TObject);
begin
  ResetFormula := False;
  Text := CalcExpr(Formula);
  if Assigned(OldOnExit) then OldOnExit(Sender);
end;

procedure TxCalcEdit.DoOnChange(Sender: TObject);
begin
  if ResetFormula then Formula := Text
    else ResetFormula := True;
  if Assigned(OldOnChange) then OldOnChange(Sender);
end;

procedure TxCalcEdit.ReadFoCal(Reader: TReader);
begin
  FoCal.Load(Reader);
end;

procedure TxCalcEdit.WriteFoCal(Writer: TWriter);
begin
  FoCal.Save(Writer);
end;

procedure TxCalcEdit.WMLButtonDown(var Message: TWMLButtonDown);
begin
  inherited;
  if (AnsiCompareText(Text, Formula) <> 0) and FShowFormula then
    Text := Formula;
end;

procedure TxCalcEdit.WMRButtonDown(var Message: TWMRButtonDown);
begin
  inherited;
  if (AnsiCompareText(Text, Formula) <> 0) and FShowFormula then
    Text := Formula;
end;

function MakeShortCut(Key: Word; KeyData: LongInt): TShortCut;
const
  AltMask = $20000000;
var
  S: TShortCut;
begin
  S := Byte(Key);
  if GetKeyState(VK_SHIFT) < 0 then Inc(S, scShift);
  if GetKeyState(VK_CONTROL) < 0 then Inc(S, scCtrl);
  if KeyData and AltMask <> 0 then Inc(S, scAlt);
  Result := S;
end;

procedure TxCalcEdit.WMKeyDown(var Message: TWMKeyDown);
var
  ShortCut: TShortCut;
begin
  inherited;
  if AnsiCompareText(Text, FErrMsg) = 0 then
    Text := Formula;

  ShortCut := MakeShortCut(Message.CharCode, Message.KeyData);
  if (ShortCut = FCalcOnShortCut) or
    ((Message.CharCode = VK_RETURN) and (FCalcOnShortCut = 0)) then
  begin
    IsShortCut := True;
    ResetFormula := False;
    Text := CalcExpr(Formula);
    if AnsiCompareText(Text, FErrMsg) = 0 then SelectAll;
  end;
end;

procedure TxCalcEdit.WMChar(var Message: TWMChar);
begin
  if IsShortCut then IsShortCut := False
    else inherited;
end;

procedure TxCalcEdit.WMDestroy(var Message: TWMDestroy);
begin
  Text := CalcExpr(Formula);
  inherited;
end;

procedure TxCustomFoCal.DeleteAllVariable;
begin
  while FVariables.Count <> 0 do
  begin
    Dispose(PVariable(FVariables[0]));
    FVariables[0] := nil;
    FVariables.Pack;
  end;
end;

{ Registration -------------------------------------------}

procedure Register;
begin
  RegisterComponents('x-NonVisual', [TxFoCal]);
  RegisterComponents('x-VisualControl', [TxCalcEdit]);
end;

end.
