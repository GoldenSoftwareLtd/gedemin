
unit flt_sql_parser;

interface

uses
  Classes, ct_input_parser, DBCommon;

(*

  ��������� ���� ��� ����������� ������ ������.
  ������ ��������� ����� �����, ��� � ������ ��������
  ��������� ��� ���������.

*)
type
  TctSQLInputParser = class(TctInputParser)
  public
    function GetNext: TTokemType; override;
    procedure GetNextUntil(const ASymbol: Char); override;
  end;

(*

 procedure ExtractTablesList

   ��������� ������� ����� ������ � ������ ����
   ������ � ���������� �� �����.

 Input

   AnSQLText -- ����� ������

 Output

   ASL -- ������ ���, ������ ������ ��� ������ ����=��� ������
          ��� ���� �� ������� � ������ ������, ���� ������
          ��� ������ ��� ������=��� ������.

          ��� ������ ������� ��� ���� ������� ���������� ������������
          Values, Names � ������ ������.

*)

// ���������� ��� ����� � ������
procedure ExtractFieldLink(const AnSQLText: String; const ASL: TStrings);

// �� ���� ���������� ��� ������
// ��������� ��� ������ FROM �����
// �� ������ ������ ����� ����:
//   ���_�������_1=�����_�������_1.
//   ���_�������_2=�����_�������_2.
//   ...
// �������� ��������, ��� ���� ��������
// AFollowPeriod ����� ������, �� � �������
// ������������ �����
procedure ExtractTablesList(const AnSQLText: String; ASL: TStrings; const AFollowPeriod: Boolean = True;
  const AReverseOrder: Boolean = False);

// ������� ��� ����, ��������� ��� ������� ������
// ������ � ������� ������������ ���������� TField
// �.�. ���_�������.���_����, ����� ������� � �������
// � ����������� �� ���������� ��������
// �� ���� ������� ���������� ����� �������, ����� ����
// � ������� ���� ������
function MakeFieldOrigin(const AnSQLText, AFieldAlias: String;
  const ASQLDialect: Integer): String;

// ���� ����� ���� � �����������, ������������ �������� ��� ��������,
// �� SELECT �� ������������. ������� ���������� ��� ����.
function PrepareString(const Source: String): String;

// ���������� �� ������� SELECT �����
function ExtractSQLSelect(const AnSQLText: String): String;
// ���������� �� ������� FROM �����
function ExtractSQLFrom(const AnSQLText: String): String;
// ���������� �� ������� WHERE �����
function ExtractSQLWhere(const AnSQLText: String): String;
// ���������� �� ������� ���� ����� ������� ��������� ����� ������� WHERE � ORDER
function ExtractSQLOther(const AnSQLText: String): String;
// ���������� �� ������� ORDER �����
function ExtractSQLOrderBy(const AnSQLText: String): String;
// ������� ������������, ��� ���� ����� ����� ����� ORDER BY (FOR UPDATE ...) �� ������������

// ���������� ������������ ��������� �� ������� �� ����������
function ExtractProcedureName(const AnSQLText: String): String;

implementation

uses
  SysUtils, jclSelected, IBUtils;

(*

  ������� ������� ������ �������� ����� � �������� ������
  �� �������.

*)

{
function RemoveLFCR(const S: String): String;
var
  I: Integer;
begin
  Result := '';
  for I := 1 to Length(S) do
    if (S[I] <> #13) and (S[I] <> #10) then
      Result := Result + S[I]
    else
      Result := Result + ' ';
end;
}

type
  TSQLScope = (ssNone, ssSelect, ssFrom, ssWhere);

procedure ExtractTablesList(const AnSQLText: String; ASL: TStrings; const AFollowPeriod: Boolean = True;
  const AReverseOrder: Boolean = False);

  function MakeS(const TN, TA: String): string;
  begin
    if AReverseOrder then
    begin
      if AFollowPeriod then
        Result := TA + '.=' + TN
      else
        Result := TA + '=' + TN;
    end else
    begin
      if AFollowPeriod then
        Result := TN + '=' + TA + '.'
      else
        Result := TN + '=' + TA;
    end;
    Result := AnsiUpperCase(Result);
  end;

var
  IP: TctInputParser;
  Scope: TSQLScope;
  TN, TempS: String;
  K, J, H, SubJoin, ProcParam: Integer;
  InQuote: Boolean;
  WasSubJoin: Boolean;
begin
  ASL.Clear;
  Scope := ssNone;
  SubJoin := 0;
  WasSubJoin := False;
  TempS := '';
  IP := TctSQLInputParser.Create(TStringStream.Create(AnSQLText), False);
  try
    while not IP.EOF do
    begin
      if TempS > '' then
      begin
        ASL.Add(TempS);
        TempS := '';
      end;

      IP.GetNext;

      if IP.TokemType = ttSpace then
        continue;

      if (Scope = ssNone) and (IP.TokemType = ttIdentifier) and (IP.LowerTokem = 'select') then
      begin
        // �� ���� ���������� ����� ������ ������ ��
        // ������� �� ������ ����
        // ����� ���������� ���������� ������
        K := 0;
        IP.GetNext;
        while (not IP.EOF) and (not((IP.TokemType = ttIdentifier) and (IP.LowerTokem = 'from') and (K = 0))) do
        begin
          if IP.LowerTokem = '(' then
          begin
            J := 1;
            while (J > 0) and (not IP.EOF) do
            begin
              IP.GetNext;
              if IP.LowerTokem = '''' then
              begin
                repeat
                  IP.GetNext;
                until IP.EOF or (IP.LowerTokem = '''');
                continue;
              end;
              if IP.LowerTokem = '(' then Inc(J);
              if IP.LowerTokem = ')' then Dec(J);
            end;
            if IP.EOF then
              raise Exception.Create('Invalid SQL');
            IP.GetNext;
          end;

          if (IP.TokemType = ttIdentifier) and (IP.LowerTokem = 'select') then
            Inc(K);
          if (IP.TokemType = ttIdentifier) and (IP.LowerTokem = 'from') then
            Dec(K);
          IP.GetNext;
        end;

        if IP.EOF then
          raise Exception.Create('ExtractTablesList: Invalid SQL specified');

        IP.Rollback;
        Scope := ssSelect;
        continue;
      end;

      if (Scope in [ssSelect, ssNone]) and (IP.TokemType = ttIdentifier) and (IP.LowerTokem = 'from') then
      begin
        Scope := ssFrom;
        continue;
      end;

      if (Scope in [ssFrom, ssNone]) and (IP.TokemType = ttIdentifier) and (IP.LowerTokem = 'where') then
      begin
        Scope := ssWhere;
        continue;
      end;

      if (Scope in [ssFrom, ssWhere]) and (IP.TokemType = ttIdentifier) and ((IP.LowerTokem = 'order')
        or (IP.LowerTokem = 'group')
        or (IP.LowerTokem = 'union') or (IP.LowerTokem = 'plan')
        or (IP.LowerTokem = 'having') or (IP.LowerTokem = 'into'))
      then
      begin
        Scope := ssNone;
        continue;
      end;

      if Scope = ssFrom then
      begin
        if IP.TokemType = ttIdentifier then
        begin
          TN := IP.Tokem;
          //ASL.Add(AnsiUpperCase(TN + '=' + TN + '.'));
          TempS := MakeS(TN, TN);
          IP.GetNext;
          if IP.TokemType = ttSpace then
            IP.GetNext;

          if (IP.TokemType = ttSymbol) and (IP.Tokem = '(') then
          begin
            IP.GetNext;
            ProcParam := 1;
            InQuote := False;
            while not IP.EOF do
            begin
              if (not InQuote) and (IP.TokemType = ttSymbol) and (IP.Tokem = ')') then
              begin
                Dec(ProcParam);
                if ProcParam = 0 then
                begin
                  IP.GetNext;
                  break;
                end;
              end;
              if (not InQuote) and (IP.TokemType = ttSymbol) and (IP.Tokem = '(') then
                Inc(ProcParam);
              if (IP.TokemType = ttSymbol) and (IP.Tokem = '''') then
                InQuote := not InQuote;  
              IP.GetNext;
            end;
          end;
          if IP.TokemType = ttSpace then
            IP.GetNext;

          if (IP.TokemType = ttSymbol) and (IP.Tokem = ',') then
          begin
            continue;
          end;

          if (IP.TokemType = ttIdentifier) then
          begin

            if {(IP.TokemType = ttIdentifier) and} (IP.LowerTokem <> 'inner')
              and (IP.LowerTokem <> 'outer') and (IP.LowerTokem <> 'full')
              and (IP.LowerTokem <> 'left') and (IP.LowerTokem <> 'right')
              and (IP.LowerTokem <> 'join') and (IP.LowerTokem <> 'order')
              and (IP.LowerTokem <> 'group') and (IP.LowerTokem <> 'having')
              and (IP.LowerTokem <> 'union') and (IP.LowerTokem <> 'into')
              and (IP.LowerTokem <> 'where')
            then
            begin
              //ASL.Strings[ASL.IndexOfName(TN)] := AnsiUpperCase(TN + '=' + IP.Tokem + '.');
              TempS := MakeS(TN, IP.Tokem);
              IP.GetNext;
              if IP.TokemType = ttSpace then
                IP.GetNext;
              if IP.Tokem = ',' then
                continue;
            end;

            if (IP.TokemType = ttIdentifier) and ((IP.LowerTokem = 'where')
              or (IP.LowerTokem = 'order') or (IP.LowerTokem = 'group')
              or (IP.LowerTokem = 'union') or (IP.LowerTokem = 'plan')
              or (IP.LowerTokem = 'having') or (IP.LowerTokem = 'into'))
            then
            begin
              IP.Rollback;
              Scope := ssNone;
              continue;
            end;

            TN := '';

            repeat
              if TempS > '' then
              begin
                ASL.Add(TempS);
                TempS := '';
              end;

              if (IP.TokemType = ttIdentifier) and ((IP.LowerTokem = 'inner')
                or (IP.LowerTokem = 'outer') or (IP.LowerTokem = 'full')
                or (IP.LowerTokem = 'left') or (IP.LowerTokem = 'right'))
              then
              begin
                IP.GetNext;
                IP.GetNext;
              end;

              if (IP.TokemType = ttIdentifier) and (IP.LowerTokem = 'join') then
              begin
                IP.GetNext;
                IP.GetNext;

                if IP.Tokem = '(' then
                begin
                  WasSubJoin := True;
                  Inc(SubJoin);
                end else
                begin

                  TN := IP.Tokem;
                  TempS := MakeS(TN, TN);
                  //ASL.Add(AnsiUpperCase(TN + '=' + TN + '.'));

                  IP.GetNext;
                  if IP.TokemType = ttSpace then
                    IP.GetNext;

                  if IP.LowerTokem = '(' then
                  begin
                    // join on stored procedure with params list
                    // skip the params
                    InQuote := False;
                    H := -1;
                    while (InQuote) or (IP.LowerTokem <> ')') or (H <> 0) do
                    begin
                      if IP.TokemType = ttEOF then
                        raise Exception.Create('Invalid SQL');
                      if IP.LowerTokem = '''' then InQuote := not InQuote;
                      if not InQuote then
                      begin
                        if IP.LowerTokem = '(' then Inc(H)
                        else if IP.LowerTokem = ')' then Dec(H);
                      end;
                      IP.GetNext;
                    end;
                    IP.GetNext;
                    if IP.TokemType = ttSpace then
                      IP.GetNext;
                  end;

                  if IP.LowerTokem = 'as' then
                  begin
                    IP.GetNext;
                    if IP.TokemType = ttSpace then
                      IP.GetNext;
                  end;

                  if IP.LowerTokem <> 'on' then
                  begin
                    { TODO : ��� ����� ������, ���� ��� ��������� ������������� ������ }
                    //ASL.Delete(ASL.Count - 1);
                    //ASL.Add(AnsiUpperCase(TN + '=' + IP.Tokem + '.'));
                    TempS := MakeS(TN, IP.Tokem);

                    IP.GetNext;
                    if IP.TokemType = ttSpace then
                      IP.GetNext;
                  end;

                  if IP.LowerTokem <> 'on' then
                    raise Exception.Create('Invalid SQL');
                end;
              end;

              IP.GetNext;

              if IP.LowerTokem = ')' then
              begin
                Dec(SubJoin);
                IP.GetNext;
              end;

              // � ������ �� ����� ������� ������� ������ ������� �����
              // ������, ����� ������������ �������
              // � ���� ������ ��� ���� ���������� ��� ��������� �������
              // ����� ������� ����� ����������, ��� �������, ����������
              // ������� � ������ ����
              if IP.LowerTokem = '(' then
              begin
                J := 1;
                while (J > 0) and (not IP.EOF) do
                begin
                  IP.GetNext;
                  if IP.LowerTokem = '''' then
                  begin
                    repeat
                      IP.GetNext;
                    until IP.EOF or (IP.LowerTokem = '''');
                    continue;
                  end;
                  if IP.LowerTokem = '(' then Inc(J);
                  if IP.LowerTokem = ')' then Dec(J);
                end;
                if IP.EOF then
                  raise Exception.Create('Invalid SQL');
                IP.GetNext;
              end;

            until ((IP.TokemType = ttIdentifier) and ((IP.LowerTokem = 'where') or (IP.LowerTokem = 'order') or
              (IP.LowerTokem = 'group') or (IP.LowerTokem = 'plan') or (IP.LowerTokem = 'union') or (IP.LowerTokem = 'having') or
              (IP.LowerTokem = 'into'))) or ((IP.TokemType = ttSymbol) and (IP.LowerTokem = ',')) or IP.EOF
              or ((SubJoin > 0) and WasSubJoin);

            WasSubJoin := False;

            IP.Rollback;
            continue;
          end;
        end;
      end;
    end;
  finally
    if TempS > '' then
      ASL.Add(TempS);

    IP.Stream.Free;
    IP.Free;

    {if not AFollowPeriod then
      for I := 0 to ASL.Count - 1 do
      begin
        S := ASL[I];
        SetLength(S, Length(S) - 1);
        ASL[I] := S;
      end;}
  end;
end;

function MakeFieldOrigin(const AnSQLText, AFieldAlias: String;
  const ASQLDialect: Integer): String;
const
  WhiteSpaces = [#32, #9, #10, #13];
  ValidCharID = ['A'..'Z', 'a'..'z', '_', '$', '0'..'9'];
  ValidFirstCharID = ['A'..'Z', 'a'..'z', '_', '$'];
var
  S: String;
  P, L, E: Integer;
  SL: TStringList;
begin
  Result := '';
  S := AnSQLText;
  L := Length(AFieldAlias);
  P := 0;
  repeat
    if P > 0 then
      S := System.Copy(S, P + L + 1, 32000);
    P := StrIPos(AFieldAlias, S);
  until (P < 10) or  {length of 'SELECT F '}
    (((S[P - 1] in WhiteSpaces) or (S[P - 1] = '.')) and
      ((P + L >= Length(S)) or (S[P + L + 1] in WhiteSpaces)));
  if P > 9 then
  begin
    SL := TStringList.Create;
    try
      ExtractTablesList(AnSQLText, SL, False, True);
      if S[P - 1] = '.' then
      begin
        Dec(P, 2);
        E := P;
        while (P > 6) and (S[P] in ValidCharID) do
          Dec(P);
        if P > 6 then
        begin
          Result := QuoteIdentifier(ASQLDialect, SL.Values[AnsiUpperCase(System.Copy(S, P + 1, E - P))]) + '.' +
            QuoteIdentifier(ASQLDialect, AFieldAlias);
        end;
      end else begin
        Dec(P);
        while (P > 8) and (S[P] in WhiteSpaces) do
          Dec(P);
        if (P > 8) and
          (S[P] in ['s', 'S']) and
          (S[P - 1] in ['a', 'A']) and
          (S[P - 2] in WhiteSpaces) then
        begin
          Dec(P, 3);
          while (P > 6) and (S[P] in WhiteSpaces) do
            Dec(P);
        end;
        E := P;
        while (P > 6) and (S[P] in ValidCharID) do
          Dec(P);
        if (P > 6) and (S[P + 1] in ValidFirstCharID) then
        begin
          Result := System.Copy(S, P + 1, E - P);
          if S[P] <> '.' then
          begin
            if Result > '' then
              Result := QuoteIdentifier(ASQLDialect, SL.Values[SL.Names[0]]) + '.' +
                QuoteIdentifier(ASQLDialect, Result);
          end else begin
            Dec(P);
            E := P;
            while (P > 6) and (S[P] in ValidCharID) do
              Dec(P);
            if P > 6 then
              Result := QuoteIdentifier(ASQLDialect, SL.Values[AnsiUpperCase(System.Copy(S, P + 1, E - P))]) + '.' +
                QuoteIdentifier(ASQLDialect, Result)
            else
              Result := '';
          end;
        end;
      end;
    finally
      SL.Free;
    end;
  end;
  Result := AnsiUpperCase(Result);
end;

{ TctSQLInputParser }

function TctSQLInputParser.GetNext: TTokemType;
var
  Ch, Prev: Char;
begin
  if (FStream.Read(Ch, SizeOf(Ch)) = SizeOf(Ch)) then
  begin
    if Ch = '/' then
    begin
      if FStream.Read(Ch, SizeOf(Ch)) = SizeOf(Ch) then
      begin
        if (Ch = '*') then
        begin
          FStream.ReadBuffer(Ch, SizeOf(Ch));
          repeat
            Prev := Ch;
          until (FStream.Read(Ch, SizeOf(Ch)) = 0) or ((Ch = '/') and (Prev = '*'));
        end else
        begin
          FStream.Seek(-SizeOf(Ch) * 2, soFromCurrent);
        end;
      end;
    end else
      FStream.Seek(-SizeOf(Ch), soFromCurrent);
  end;

  Result := inherited GetNext;
end;

procedure TctSQLInputParser.GetNextUntil(const ASymbol: Char);
var
  S: String;
begin
  S := '';
  while (not EOF) and (LowerTokem <> ASymbol) do
  begin
    GetNext;
    S := S + Tokem;
  end;
  if LowerTokem = ASymbol then
    Rollback;
  FTokem := S;
  FTokemType := ttString;
end;

function ReplaceBracket(const Text: String): String;
var
  I: Integer;
begin
  Result := Text;
  I := Pos('(', Result);
  while I <> 0 do
  begin
    Result[I] := ' ';
    I := Pos('(', Result);
  end;

  I := Pos(')', Result);
  while I <> 0 do
  begin
    Result[I] := ' ';
    I := Pos(')', Result);
  end;

  I := Pos(#10, Result);
  while I <> 0 do
  begin
    Result[I] := ' ';
    I := Pos(#10, Result);
  end;

  I := Pos(#13, Result);
  while I <> 0 do
  begin
    Result[I] := ' ';
    I := Pos(#13, Result);
  end;
end;

procedure ExtractFieldLink(const AnSQLText: String; const ASL: TStrings);
var
  TempS, Res: String;
  I, J: Integer;
  StrP, EndP: PChar;
begin
  ASL.Clear;
  TempS := ExtractSQLFrom(AnSQLText);
  TempS := TempS + ExtractSQLWhere(AnSQLText);
  TempS := ReplaceBracket(TempS) + ' ';
  // ���� �����
  I := Pos('=', TempS);
  try
    while I <> 0 do
    begin
      // ������ �����
      StrP := @TempS[I - 1];
      // �������� ������
      while StrP^ = ' ' do
        Dec(StrP);
      // ������� �� �����
      while (StrP - 1)^ <> ' ' do
        Dec(StrP);
      // ������ ������
      EndP := @TempS[I + 1];
      // �������� ������
      while EndP^ = ' ' do
        Inc(EndP);
      // ������� �� �����
      while EndP^ <> ' ' do
        Inc(EndP);
      // ����������� ���������
      SetString(Res, StrP, EndP - StrP);
      // �� ����� ��� ���, �� �� ���� ��������� ����.
      J := Pos(' ', Res);
      while J <> 0 do
      begin
        Delete(Res, J, 1);
        J := Pos(' ', Res)
      end;
      // �������� ����� ����� �� ����������
      ASL.Add(AnsiUpperCase(Res));
      TempS[I] := '|';
      // ���� ���� "�����"
      I := Pos('=', TempS);
    end;
  except
  end;
end;

function PrepareString(const Source: String): String;
const
  LeftBracket = '(';
  RightBracket = ')';
  Space = ' ';
  Quote = '''';
var
  I: Integer;
  WasQuote: Boolean;
//  ArInt: array of Integer;
begin
//������ � �������� ������� �� �����
  Result := Source;
  WasQuote := False;
//  SetLength(ArInt, Length(Source));
  I := 1;
  while I <= Length(Result) do
  begin
    if (Result[I] = Quote) then
    begin
      WasQuote := not WasQuote;
    end;

    if ((Result[I] = LeftBracket) or (Result[I] = RightBracket)) and (not WasQuote)then
    begin
      if not((I < Length(Result)) and (Result[I + 1] = Space)) then
        Insert(Space, Result, I + 1);
      if not((I > 1) and (Result[I - 1] = Space)) then
        Insert(Space, Result, I);
    end;

    Inc(I);
  end;
end;

function ExtractProcedureName(const AnSQLText: String): String;
var
  TS: String;
  Current: PChar;
  Token: String;

  function InsertSpace(const AnSource: String): String;
  var
    I: Integer;
  begin
    Result := AnSource;
    I := Pos('(', Result);
    while I <> 0 do
    begin
      Result[I] := ' ';
      I := Pos('(', Result);
    end;
  end;
begin
  TS := InsertSpace(AnSQLText);
  Current := PChar(TS);

  NextSQLToken(Current, Token, stUnknown);
  if AnsiUpperCase(Token) = 'CREATE' then
  begin
    NextSQLToken(Current, Token, stUnknown);
    if AnsiUpperCase(Token) = 'PROCEDURE' then
      NextSQLToken(Current, Result, stUnknown);
  end;
end;

function ExtractSQLSelect(const AnSQLText: String): String;
var
  TS: String;
  Start1, Start2, Current: PChar;
  Token: String;
  SQLToken, CurSection: TSQLToken;
  SubSection: Integer;
  BracketCount, bssc: Integer;
begin
  // ���������� ������ � ������
  TS := PrepareString(AnSQLText);
  Result := '';

  // ����������� ������� �������
  Current := PChar(TS);

  // ���������� ����� ����� SELECT
  CurSection := stUnknown;
  repeat
    Start1 := Current;
    SQLToken := NextSQLToken(Current, Token, CurSection);
    //Finalize(Token);
    if SQLToken in SQLSections then CurSection := SQLToken;
  until SQLToken in [stEnd, stSelect];
  // ���� SELECT ������, �� ����������
  if SQLToken = stSelect then
  begin
    // ������������� ���������� �����������
    SubSection := 0;
    BracketCount := 0;
    // ��������� ���� �� ��������� FROM ���� ����� ������.
    repeat
      // ���� ��������� FROM, �� ��������� ��������� ��������
      // ����������� ���-�� �����������
      if SQLToken = stFrom then
        Dec(SubSection);
      // ���������� ������� �������
      Start2 := Current;
      // ���� ��������� ������� � ������
      SQLToken := NextSQLToken(Current, Token, CurSection);
      //Finalize(Token);
      if SQLToken = stFieldName then begin
        if Token = '(' then
          Inc(BracketCount)
        else if Token = ')' then
            Dec(BracketCount)
        else if Token = 'SUBSTRING' then begin
          bssc:= 0;
          repeat
            Start2 := Current;
            SQLToken := NextSQLToken(Current, Token, CurSection);
            if SQLToken = stFieldName then
              if Token = '(' then
                Inc(bssc)
              else if Token = ')' then
                  Dec(bssc);
          until (bssc = 0) or (SQLToken = stEnd)
        end;
      end;
      // ���� ���� ������� �������� ������� ����������� �� ����������� �������
      if (CurSection = stSelect) and (SQLToken = stSelect) then
        Inc(SubSection);
      // ���� ��� ����������� � ������ ����������, �� ������������� ��.
      if (SQLToken in SQLSections) and (SubSection = 0) and (BracketCount = 0) then
        CurSection := SQLToken;
    until ((CurSection = stFrom) and (SubSection < 1) and (BracketCount = 0)) or (SQLToken = stEnd);
    // ���� FROM ��������� �������� ������ SELECT
    if SQLToken = stFrom then
      SetString(Result, Start1, Start2 - Start1);
  end;
end;

function ExtractSQLFrom(const AnSQLText: String): String;
var
  Start1, Start2, Current: PChar;
  Token: string;
  SQLToken, CurSection: TSQLToken;
  TS: String;
  SubSection: Integer;
  BracketCount, bssc: Integer;
begin
  // ���������� ������ � ������
  TS := PrepareString(AnSQLText);
  Result := '';

  SQLToken := stUnknown;
  Current := PChar(TS);

  CurSection := stUnknown;
  SubSection := 0;
  BracketCount := 0;
  // ���������� ������ �������
  // �������� ���� �� ������ �� ��������� ����
  repeat
    if SQLToken = stFrom then
      Dec(SubSection);
    Start1 := Current;
    SQLToken := NextSQLToken(Current, Token, CurSection);

      if SQLToken = stFieldName then
        if Token = '(' then
          Inc(BracketCount)
        else if Token = ')' then
            Dec(BracketCount)
        else if Token = 'SUBSTRING' then begin
          bssc:= 0;
          repeat
            SQLToken := NextSQLToken(Current, Token, CurSection);
            if SQLToken = stFieldName then
              if Token = '(' then
                Inc(bssc)
              else if Token = ')' then
                  Dec(bssc);
          until (bssc = 0) or (SQLToken = stEnd)
        end;

{    if SQLToken = stFieldName then
      if Token = '(' then
        Inc(BracketCount)
      else
        if Token = ')' then
          Dec(BracketCount);}
    if (CurSection = stSelect) and (SQLToken = stSelect) then
      Inc(SubSection);
    if (SQLToken in SQLSections) and (SubSection = 0) and (BracketCount = 0) then
      CurSection := SQLToken;
  until (CurSection = stFrom) or (SQLToken = stEnd);
  // ���� ����� �� ����� ����
  BracketCount := 0;
  if SQLToken = stFrom then
  begin
    // � ����� ����� ������������ ���������,
    // ������� ���� ����� ����� ��� ������ ��������
    repeat
      Start2 := Current;
      SQLToken := NextSQLToken(Current, Token, CurSection);

      if Token = '(' then
        Inc(BracketCount)
      else
        if Token = ')' then
          Dec(BracketCount);

      if (SQLToken in SQLSections) and (BracketCount = 0) then CurSection := SQLToken;
    until (CurSection <> stFrom) or (SQLToken = stEnd);
    // ����������� ���������
    SetString(Result, Start1, Start2 - Start1);
  end;
end;

function ExtractSQLWhere(const AnSQLText: String): String;
var
  Start1, Start2, Current: PChar;
  Token: string;
  SQLToken, CurSection: TSQLToken;
  TS: String;
  SubSection: Integer;
  BracketCount, bssc: Integer;
begin
  // ���������� ������
  TS := PrepareString(AnSQLText);
  Result := '';

  SQLToken := stUnknown;
  Current := PChar(TS);

  CurSection := stUnknown;
  SubSection := 0;
  BracketCount := 0;
  // ���������� ������ � ����
  // ���������� ����� ������
  repeat
    if SQLToken = stFrom then
      Dec(SubSection);
    Start1 := Current;
    SQLToken := NextSQLToken(Current, Token, CurSection);

      if SQLToken = stFieldName then
        if Token = '(' then
          Inc(BracketCount)
        else if Token = ')' then
            Dec(BracketCount)
        else if Token = 'SUBSTRING' then begin
          bssc:= 0;
          repeat
            SQLToken := NextSQLToken(Current, Token, CurSection);
            if SQLToken = stFieldName then
              if Token = '(' then
                Inc(bssc)
              else if Token = ')' then
                  Dec(bssc);
          until (bssc = 0) or (SQLToken = stEnd)
        end;

{    if SQLToken = stFieldName then
      if Token = '(' then
        Inc(BracketCount)
      else
        if Token = ')' then
          Dec(BracketCount);}
    if (CurSection = stSelect) and (SQLToken = stSelect) then
      Inc(SubSection);
    if (SQLToken in SQLSections) and (SubSection = 0) and (BracketCount = 0) then
      CurSection := SQLToken;
  until (CurSection = stFrom) or (SQLToken = stEnd);
  // ���������� ����� ����
  BracketCount := 0;
  if SQLToken = stFrom then
    repeat
      Start1 := Current;
      SQLToken := NextSQLToken(Current, Token, CurSection);
      if Token = '(' then
        Inc(BracketCount)
      else
        if Token = ')' then
          Dec(BracketCount);
      if (SQLToken in SQLSections)  and (BracketCount = 0) then CurSection := SQLToken;
    until (CurSection <> stFrom) or (SQLToken = stEnd);
  // ���� ����� �� ����� ���
  if SQLToken = stWhere then
  begin
    // ������������� ���������� ����������� 0
    SubSection := 0;
    repeat
      // ���� ��������� ���� ��������� ���������� �����������
      if SQLToken = stFrom then
        Dec(SubSection);
      Start2 := Current;
      // ���������� ��������� ������� �������
      SQLToken := NextSQLToken(Current, Token, CurSection);
      // ���� ��������� ������, �� ����������� ���-�� �����������
      if (CurSection = stWhere) and (SQLToken = stSelect) then
        Inc(SubSection);
      // ���� ���-�� ����������� � ���������� ������, �� ������ �� �������
      if (SQLToken in SQLSections) and (SubSection = 0) then
        CurSection := SQLToken;
      // ��������� ���� ������� ������ ��� ��� �� ��������� ����� ������
    until (CurSection <> stWhere) or (SQLToken = stEnd);
    // ����������� ���������
    SetString(Result, Start1, Start2 - Start1);
  end;
end;

function ExtractSQLOther(const AnSQLText: String): String;
var
  Start1, Start2, Current: PChar;
  Token: string;
  SQLToken, CurSection: TSQLToken;
  TS: String;
  SubSection: Integer;
  BracketCount, bssc: Integer;
begin
  // ���������� ������
  TS := PrepareString(AnSQLText);
  Result := '';

  SQLToken := stUnknown;
  Current := PChar(TS);

  CurSection := stUnknown;
  SubSection := 0;
  BracketCount := 0;
  // ���������� ����� ������
  repeat
    if SQLToken = stFrom then
      Dec(SubSection);
    SQLToken := NextSQLToken(Current, Token, CurSection);

      if SQLToken = stFieldName then
        if Token = '(' then
          Inc(BracketCount)
        else if Token = ')' then
            Dec(BracketCount)
        else if Token = 'SUBSTRING' then begin
          bssc:= 0;
          repeat
            SQLToken := NextSQLToken(Current, Token, CurSection);
            if SQLToken = stFieldName then
              if Token = '(' then
                Inc(bssc)
              else if Token = ')' then
                  Dec(bssc);
          until (bssc = 0) or (SQLToken = stEnd)
        end;

    if (CurSection = stSelect) and (SQLToken = stSelect) then
      Inc(SubSection);
    if (SQLToken in SQLSections) and (SubSection = 0) and (BracketCount = 0) then
      CurSection := SQLToken;
  until (CurSection = stFrom) or (SQLToken = stEnd);

  // ���������� ����� ����
  BracketCount := 0;
  if SQLToken = stFrom then
  begin
    repeat
      Start2 := Current;
      SQLToken := NextSQLToken(Current, Token, CurSection);
      if Token = '(' then
        Inc(BracketCount)
      else
        if Token = ')' then
          Dec(BracketCount);
      if (SQLToken in SQLSections) and (BracketCount = 0) then CurSection := SQLToken;
    until (CurSection <> stFrom) or (SQLToken = stEnd);

    // ���������� ����� ���
    SubSection := 0;
    if SQLToken = stWhere then
      repeat
        if SQLToken = stFrom then
          Dec(SubSection);
        Start2 := Current;
        SQLToken := NextSQLToken(Current, Token, CurSection);
        if (CurSection = stWhere) and (SQLToken = stSelect) then
          Inc(SubSection);
        if (SQLToken in SQLSections) and (SubSection = 0) then
          CurSection := SQLToken;
      until (CurSection <> stWhere) or (SQLToken = stEnd);

    Start1 := Start2;

    // �.�. ORDER BY ����� ���� ������ ���� �� ������,
    // ������� ���� ��� ������ ��������� ���� ����� �����
    if (SQLToken <> stEnd) and (SQLToken <> stOrderBy) then
    begin
      repeat
        Start2 := Current;
        SQLToken := NextSQLToken(Current, Token, CurSection);
        if SQLToken in SQLSections then CurSection := SQLToken;
      until SQLToken in [stEnd, stOrderBy];

    end;
    // ����������� ���������
    SetString(Result, Start1, Start2 - Start1);
  end;
end;

function ExtractSQLOrderBy(const AnSQLText: String): String;
var
  Start1, Start2, Current: PChar;
  Token, TS: string;
  SQLToken, CurSection: TSQLToken;
  SelectPart: Integer;
  BracketCount, bssc: Integer;
begin
  Result := '';

  // ���������� ������ � ������
  TS := PrepareString(AnSQLText);
  Current := PChar(TS);

  CurSection := stUnknown;
  SelectPart := 0;
  BracketCount := 0;
  { TODO -oJKL :
���� ����������, �� ������� ����
SELECT ... FROM ... WHERE ...(SELECT...FROM...ORDER BY) ��������� �������������� �� ����� }
  // ���� ����� �����
  repeat
    Start1 := Current;
    SQLToken := NextSQLToken(Current, Token, CurSection);
      if SQLToken = stFieldName then
      begin
        if Token = '(' then
          Inc(BracketCount)
        else if Token = ')' then
            Dec(BracketCount)
        else if Token = 'SUBSTRING' then begin
          bssc:= 0;
          repeat
            SQLToken := NextSQLToken(Current, Token, CurSection);
            if SQLToken = stFieldName then
              if Token = '(' then
                Inc(bssc)
              else if Token = ')' then
                  Dec(bssc);
          until (bssc = 0) or (SQLToken = stEnd)
        end;
     end
     else if SQLToken = stTableName then
      if Token = '(' then
        Inc(BracketCount)
      else
        if Token = ')' then
          Dec(BracketCount);

{    if SQLToken = stFieldName then
      if Token = '(' then
        Inc(BracketCount)
      else
        if Token = ')' then
          Dec(BracketCount);}
    if SQLToken in SQLSections then CurSection := SQLToken;
    if stSelect = SQLToken then Inc(SelectPart);
    if stFrom = SQLToken then Dec(SelectPart);
  until (SQLToken = stEnd) or ((SQLToken = stOrderBy) and (SelectPart = 0) and (BracketCount = 0));
  if SQLToken = stOrderBy then
  begin
    // ���� ����� ����� �����
    repeat
      Start2 := Current;
      SQLToken := NextSQLToken(Current, Token, CurSection);
      if SQLToken in SQLSections then CurSection := SQLToken;
    until (CurSection <> stOrderBy) or (SQLToken = stEnd);
    // ����������� ���������
    SetString(Result, Start1, Start2 - Start1);
  end;
end;

end.
