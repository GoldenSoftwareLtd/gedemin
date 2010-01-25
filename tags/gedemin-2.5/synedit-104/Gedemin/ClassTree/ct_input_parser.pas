
unit ct_input_parser;

interface

uses
  Classes, ct_class;

{
  Разбіральнік патоку дадзеных атрымоўвае на ўваходзе
  плынь і разбірае яе па натупных элементох:

    1. Сімвал канца файла.
    2. Ідэнтыфікатар (страка сімвалаў, першы літара ці падкрэсліваньне, апошнія
       літары, падкрэсліваньне ці лічбы).
    3. Прабел (ланцуг з некалькіх паслядоўных сімвалаў: прабел, табуляцыя, перавод стракі
       вазврат карэткі). Можа быць і адзін толькі сімвал.
    4. Сімвал (любы сімвал, які не зьяўляецца складнікам ідэнтыфікатару, ці
       прабелу).
    5. Страка. Калі разбіральніку даецца каманда прачытаць з плыні паслядоўнасць
       сімвалаў пакуль не сустрэнецца дадзены тэрмінатар.
}
type
  TTokemType = (ttEOF, ttIdentifier, ttSpace, ttSymbol, ttString);

const
  TWhiteSpaces = [#32, #09, #10, #13];
  TEnglishLetters = ['a'..'z', 'A'..'Z', '_'];
  TEnglishLettersAndNumbers = ['a'..'z', 'A'..'Z', '0'..'9', '_', '$']; // $ добавлен для SQL

{
  Такема -- адзінка, вяртаймая разбіральнікам.
  Мае свой тып і, уласна, такему -- паслядоўнасць сімвалаў.
}
type
  TctTokem = record
    Tokem: String;
    TokemType: TTokemType;
  end;

{
  Стэк патрабуецца нам каб часам вяртацца назад.
}
type
  TctStack = class(TObject)
  private
    FStack: array of TctTokem;
    FCount: Integer;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Push(const ATokem: TctTokem);
    function Pop: TctTokem;
    function Peek: TctTokem;
    function AtLeast(const ACount: Integer): Boolean;
    procedure Clear;

    property Count: Integer read FCount;
  end;

type
  TctInputParser = class(TObject)
  private
    function GetEOF: Boolean;
    function GetLowerTokem: String;

  protected
    FTokem: String;
    FStream: TStream;
    FTokemType: TTokemType;
    FStack: TctStack;
    FSkipComment: Boolean;

  public
    constructor Create(AStream: TStream; const ASkipComment: Boolean);
    destructor Destroy; override;

    function GetNext: TTokemType; virtual;
    procedure GetNextUntil(const ASymbol: Char); overload; virtual;
    procedure GetNextUntil(const ASymbol: Char; const AnOpenPair, AnClosingPair: String); overload; virtual;
    procedure GetNextUntilEOL; virtual;
    procedure Rollback;

    procedure ClearStack;
    function GetPrev: TctTokem;

    property Stream: TStream read FStream;
    property TokemType: TTokemType read FTokemType;
    property Tokem: String read FTokem;
    property LowerTokem: String read GetLowerTokem;
    property EOF: Boolean read GetEOF;
    property SkipComment: Boolean read FSkipComment;
  end;

function CreateTokem(const A: String; const T: TTokemType): TctTokem;

implementation

uses
  SysUtils;

function CreateTokem(const A: String; const T: TTokemType): TctTokem;
begin
  Result.Tokem := A;
  Result.TokemType := T;
end;

{ TctInputParser }

procedure TctInputParser.ClearStack;
begin
  FStack.Clear;
end;

constructor TctInputParser.Create;
begin
  inherited Create;
  FStream := AStream;
  FTokemType := ttEOF;
  FStack := TctStack.Create;
  FSkipComment := ASkipComment;
end;

destructor TctInputParser.Destroy;
begin
  inherited;
  FStack.Free;
end;

function TctInputParser.GetEOF: Boolean;
begin
  Result := FStream.Position >= FStream.Size;
end;

function TctInputParser.GetLowerTokem: String;
begin
  Result := LowerCase(FTokem);
end;

function TctInputParser.GetNext;
var
  Ch: Char;
begin
  if FStream.Position > 0 then
    FStack.Push(CreateTokem(FTokem, FTokemType));

  if EOF then
  begin
    FTokemType := ttEOF;
    Result := FTokemType;
    exit;
  end;

  FStream.ReadBuffer(Ch, SizeOf(Ch));

  if Ch in TEnglishLetters then
  begin
    FTokem := '';
    FTokemType := ttIdentifier;
    Result := FTokemType;
    repeat
      FTokem := FTokem + Ch;
      if FStream.Read(Ch, SizeOf(Ch)) = 0 then
        exit;
    until not (Ch in TEnglishLettersAndNumbers);
    FStream.Seek(-SizeOf(Ch), soFromCurrent);
  end
  else if Ch in TWhiteSpaces then
  begin
    FTokem := '';
    FTokemType := ttSpace;
    Result := FTokemType;
    repeat
      FTokem := FTokem + Ch;
      if FStream.Read(Ch, SizeOf(Ch)) = 0 then
        exit;
    until not (Ch in TWhiteSpaces);
    FStream.Seek(-SizeOf(Ch), soFromCurrent);
  end else
  begin
    FTokem := Ch;
    FTokemType := ttSymbol;
    Result := FTokemType;
  end;
end;

procedure TctInputParser.GetNextUntil(const ASymbol: Char);
var
  Ch: Char;
begin
  if FStream.Position > 0 then
    FStack.Push(CreateTokem(FTokem, FTokemType));

  FTokem := '';
  FTokemType := ttString;

  while FStream.Read(Ch, SizeOf(Ch)) = SizeOf(Ch) do
  begin
    // check if a comment is here and skip it
    if FSkipComment then
      if (Ch = '/') and (Length(FTokem) > 0) and (FTokem[Length(FTokem)] = '/') then
      begin
        FTokem := FTokem + Ch;
        GetNextUntilEOL;
        FTokem := FStack.Pop.Tokem + FTokem;
        FTokemType := ttString;
        continue;
      end;

    if Ch = ASymbol then
    begin
      FStream.Seek(-SizeOf(Ch), soFromCurrent);
      exit;
    end;

    FTokem := FTokem + Ch;
  end;
end;

procedure TctInputParser.GetNextUntil(const ASymbol: Char;
  const AnOpenPair, AnClosingPair: String);
var
  Ch: Char;
  K: Integer;
begin
  if FStream.Position > 0 then
    FStack.Push(CreateTokem(FTokem, FTokemType));

  FTokem := '';
  FTokemType := ttString;
  K := 0;

  while FStream.Read(Ch, SizeOf(Ch)) = SizeOf(Ch) do
  begin
{ TODO -oандрэй -cпамылка : З кавычкамі гэта працаваць не будзе }
    if Pos(Ch, AnOpenPair) > 0 then
      Inc(K);

    if Pos(Ch, AnClosingPair) > 0 then
      Dec(K);

    if (Ch = ASymbol) and (K = 0) then
    begin
      FStream.Seek(- SizeOf(Ch), soFromCurrent);
      exit;
    end;

    FTokem := FTokem + Ch;
  end;
end;

procedure TctInputParser.GetNextUntilEOL;
var
  Ch: Char;
begin
  if FStream.Position > 0 then
    FStack.Push(CreateTokem(FTokem, FTokemType));

  FTokem := '';
  FTokemType := ttString;

  while FStream.Read(Ch, SizeOf(Ch)) = SizeOf(Ch) do
  begin
    if (Ch = #13) or (Ch = #10) then
    begin
      FStream.Seek(- SizeOf(Ch), soFromCurrent);
      exit;
    end;

    FTokem := FTokem + Ch;
  end;
end;

function TctInputParser.GetPrev: TctTokem;
begin
  Result := FStack.Pop;
end;

procedure TctInputParser.Rollback;
begin
  FStream.Seek(- Length(FTokem), soFromCurrent);
  FTokem := FStack.Peek.Tokem;
  FTokemType := FStack.Peek.TokemType;
  FStack.Pop;
end;

{ TctStack }

procedure TctStack.Clear;
begin
  FCount := 0;
  SetLength(FStack, 0);
end;

constructor TctStack.Create;
begin
  inherited;
  FCount := 0;
end;

destructor TctStack.Destroy;
begin
  SetLength(FStack, 0);
  inherited;
end;

function TctStack.Pop: TctTokem;
begin
  Assert(FCount > 0);
  Dec(FCount);
  Result := FStack[FCount];
end;

procedure TctStack.Push(const ATokem: TctTokem);
begin
  if FCount >= High(FStack) then
  begin
    if High(FStack) = -1 then
      SetLength(FStack, 100)
    else
      SetLength(FStack, High(FStack) * 2);
  end;

  FStack[FCount] := ATokem;
  Inc(FCount);
end;

function TctStack.Peek: TctTokem;
begin
  Assert(FCount > 0);
  Result := FStack[FCount - 1];
end;

function TctStack.AtLeast(const ACount: Integer): Boolean;
begin
  Result := FCount >= ACount;
end;

end.
