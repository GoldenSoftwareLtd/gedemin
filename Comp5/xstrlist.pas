
{++

  Copyright (c) 1997 by Golden Software of Belarus

  Module

    xstrlist.pas

  Abstract

    String list component.
    Позволяет хранить список строк в форме.
    Список поделен на секции, к которым можно обращаться как
    по имени, так и по индексу. Внутри секции нумерация строк
    по индексу, начиная с нуля. Строки внутри секций начинаются с пробела(ов)
    которые в саму строку не входят.

    Вот пример списка:

    1,
      Section 1, line 0
      Section 1, line 1

    2, DATA
      Section 2 or DATA, line 0

    , STRINGS
      Section STRINGS, line 0
      Section STRINGS, line 1

  Author

    Andrei Kireev (10-May-1997)

  Contact address

    andreik@gs.minsk.by

  Revisions history

    1.00    10-may-97    andreik    Initial version.
    1.01     1-nov-97    andreik    IntByIndex added.

--}


unit xStrList;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs;

type
  TxStrList = class(TComponent)
  private
    FList: TStringList;

    procedure SetList(AList: TStringList);

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    function StrByName(const Section: String; const Index: Integer): String;
    function StrByIndex(const Section, Index: Integer): String;
    function IntByIndex(const Section, Index: Integer): LongInt;
    function IntByName(const Section: String; const Index: Integer): LongInt;

    procedure SectionByName(const Section: String; Strings: TStrings);
    procedure SectionByIndex(const Section: Integer; Strings: TStrings);

  published
    property List: TStringList read FList write SetList;
  end;

  ExStrListError = class(Exception);

procedure Register;

implementation

{ Auxiliry routines --------------------------------------}

function StripStr(const S: String): String;
var
  B, E: Integer;
begin
  B := 1;
  while (B < Length(S)) and (S[B] in [#32, #9]) do Inc(B);
  E := Length(S);
  while (E >= B) and (S[E] in [#32, #9]) do Dec(E);
  Result := Copy(S, B, E - B + 1);
end;

function StripQuotes(const S: String): String;
begin
  Result := S;
  if (Result[1] in ['"', '''', '`']) and
    (Result[Length(Result)] = Result[1]) then
    Result := Copy(Result, 2, Length(Result) - 2);
end;

function GetIndex(S: String): Integer;
var
  P, Code: Integer;
begin
  P := Pos(',', S);
  if P <> 0 then
    Delete(S, P, 255);
  Val(StripStr(S), Result, Code);
  if Code <> 0 then
    raise ExStrListError.Create('Invalid section index');
end;

function GetName(const S: String): String;
var
  P: Integer;
begin
  P := Pos(',', S);
  if P <> 0 then
    Result := StripQuotes(StripStr(Copy(S, P + 1, 255)))
  else
    raise ExStrListError.Create('Invalid section name');
end;

{ TxStrList ----------------------------------------------}

constructor TxStrList.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  FList := TStringList.Create;
end;

destructor TxStrList.Destroy;
begin
  FList.Free;
  inherited Destroy;
end;

function TxStrList.StrByName(const Section: String; const Index: Integer): String;
var
  I, K: Integer;
begin
  for I := 0 to FList.Count - 1 do
////    if FList[I][1] <> ' ' then
    if (Copy(FList[I], 1, 1) <> ' ') and (FList[I] > '') then
    begin
      if AnsiCompareText(Section, GetName(FList[I])) = 0 then
      begin
        for K := I + 1 to I + 1 + Index do
////          if FList[K][1] <> ' ' then
          if (Copy(FList[K], 1, 1) <> ' ') and (FList[K] > '') then
            raise ExStrListError.Create('Invalid index');

        Result := StripQuotes(StripStr(FList[I + 1 + Index]));

        exit;
      end;
    end;

  raise ExStrListError.Create('Invalid section name');
end;

function TxStrList.StrByIndex(const Section, Index: Integer): String;
var
  I, K: Integer;
begin
  for I := 0 to FList.Count - 1 do
////    if FList[I][1] <> ' ' then
    if (Copy(FList[I], 1, 1) <> ' ') and (FList[I] > '') then
    begin
      if GetIndex(FList[I]) = Section then
      begin
        for K := I + 1 to I + 1 + Index do
////          if FList[K][1] <> ' ' then
          if (Copy(FList[K], 1, 1) <> ' ') and (FList[K] > '') then
            raise ExStrListError.Create('Invalid index');

        Result := StripQuotes(StripStr(FList[I + 1 + Index]));

        exit;
      end;
    end;

  raise ExStrListError.Create('Invalid section index');
end;

function TxStrList.IntByIndex(const Section, Index: Integer): LongInt;
var
  Code: Integer;
begin
  Val(StrByIndex(Section, Index), Result, Code);
  if Code <> 0 then
    raise Exception.Create('Invalid integer');
end;

function TxStrList.IntByName(const Section: String; const Index: Integer): LongInt;
var
  Code: Integer;
begin
  Val(StrByName(Section, Index), Result, Code);
  if Code <> 0 then
    raise Exception.Create('Invalid integer');
end;

procedure TxStrList.SectionByName(const Section: String; Strings: TStrings);
var
  I: Integer;
begin
  Strings.Clear;
  Strings.Add(StrByName(Section, 0));
  try
    for I := 1 to MaxInt do
      Strings.Add(StrByName(Section, I));
  except
    { end of section }
  end;
end;

procedure TxStrList.SectionByIndex(const Section: Integer; Strings: TStrings);
var
  I: Integer;
begin
  Strings.Clear;
  Strings.Add(StrByIndex(Section, 0));
  try
    for I := 1 to MaxInt do
      Strings.Add(StrByIndex(Section, I));
  except
    { end of section }
  end;
end;

procedure TxStrList.SetList(AList: TStringList);
begin
  FList.Assign(AList);
end;

{ Registration -------------------------------------------}

procedure Register;
begin
  RegisterComponents('gsNV', [TxStrList]);
end;

end.
