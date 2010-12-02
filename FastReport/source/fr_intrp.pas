
{******************************************}
{                                          }
{             FastReport v2.53             }
{               Interpreter                }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FR_Intrp;

interface

{$I FR.inc}

uses Classes, SysUtils, FR_Pars
{$IFDEF 1CScript}
, interp_tp, sint_tr, interp_ex, memmngr{, debugW}
{$ENDIF};

type

// This is a simple Pascal-like interpreter. Input code can contain
// if-then-else, while-do, repeat-until, for, goto operators, begin-end blocks.
// Code can also contain expressions, variables, functions and methods.
// There is three events for handling variables and functions(methods):
// GetValue, SetValue and DoFunction.
// To execute code, call PrepareScript and then DoScript.

  TfrInterpretator = class(TObject)
  protected
    FParser: TfrParser;
{$IFDEF 1CScript}
    FInterpreter : TInterpreter;
  private
    FOnGetValue: TGetPValueEvent;
    procedure GetVariable(Sender : TObject; mIndex : Integer; VarName : String; var Ok : Boolean; var Result : TVariant);
    procedure SetVariable(Sender : TObject; mIndex : Integer; VarName : String; var Ok : Boolean; var Result : TVariant);
    procedure FOnSetValue(Value : TGetPValueEvent);
{$ENDIF}
  public
    Global : Boolean;
    constructor Create;
    destructor Destroy; override;
    procedure GetValue(const Name: String; var Value: Variant); virtual;
    procedure SetValue(const Name: String; Value: Variant); virtual;
    procedure DoFunction(const name: String; p1, p2, p3: Variant;
                         var val: Variant); virtual;
    procedure PrepareScript(MemoFrom, MemoTo, MemoErr: TStrings); virtual;
    procedure DoScript(Memo: TStrings); virtual;
    {$IFDEF 1CScript}
    function QueryValue(Name : String) : Variant;  
    property OnGetValue: TGetPValueEvent read FOnGetValue write FOnSetValue;
    {$ENDIF}
    procedure SplitExpressions(Memo, MatchFuncs, SplitTo: TStrings;
      Variables: TfrVariables);
  end;


implementation

{$IFNDEF 1CScript}
type
  TCharArray = Array[0..31999] of Char;
  PCharArray = ^TCharArray;
  lrec = record
    name: String[16];
    n: Integer;
  end;
{$ENDIF}

const
  ttIf    = #1;
  ttGoto  = #2;
  ttProc  = #3;

{$IFNDEF 1CScript}
var
  labels: Array[0..100] of lrec;
  labc: Integer;
{$ENDIF}

function Remain(const S: String; From: Integer): String;
begin
  Result := Copy(s, From, MaxInt);
end;

function GetIdentify(const s: String; var i: Integer): String;
var
  k: Integer;
begin
  while (i <= Length(s)) and (s[i] <= ' ') do
    Inc(i);
  k := i;
  while (i <= Length(s)) and (s[i] > ' ') do
    Inc(i);
  Result := Copy(s, k, i - k);
end;


{ TfrInterpretator }
{$IFNDEF 1CScript}
constructor TfrInterpretator.Create;
begin
  inherited Create;
  FParser := TfrParser.Create;
  FParser.OnGetValue := GetValue;
  FParser.OnFunction := DoFunction;
end;

destructor TfrInterpretator.Destroy;
begin
  FParser.Free;
  inherited Destroy;
end;

procedure TfrInterpretator.PrepareScript(MemoFrom, MemoTo, MemoErr: TStrings);
var
  i, j, cur, lastp: Integer;
  s, bs: String;
  len: Integer;
  buf: PCharArray;
  Error: Boolean;
  CutList: TStringList;

procedure DoCommand; forward;
procedure DoBegin; forward;
procedure DoIf; forward;
procedure DoRepeat; forward;
procedure DoWhile; forward;
procedure DoGoto; forward;
procedure DoEqual; forward;
procedure DoExpression; forward;
procedure DoSExpression; forward;
procedure DoTerm; forward;
procedure DoFactor; forward;
procedure DoVariable; forward;
procedure DoConst; forward;
procedure DoLabel; forward;
procedure DoFunc; forward;
procedure DoFuncId; forward;

  function last: Integer;
  begin
    Result := MemoTo.Count;
  end;

  function CopyArr(cur, n: Integer): String;
  begin
    SetLength(Result, n);
    Move(buf^[cur], Result[1], n);
  end;

  procedure AddLabel(s: String; n: Integer);
  var
    i: Integer;
    f: Boolean;
  begin
    f := True;
    for i := 0 to labc - 1 do
      if labels[i].name = s then f := False;
    if f then
    begin
      labels[labc].name := s;
      labels[labc].n := n;
      Inc(labc);
    end;
  end;

  procedure SkipSpace;
  begin
    while (buf^[cur] <= ' ') and (cur < len) do Inc(cur);
  end;

  function GetToken: String;
  var
    n, j: Integer;
  label 1;
  begin
1:  SkipSpace;
    j := cur;
    while (buf^[cur] > ' ') and (cur < len) do
    begin
      if (buf^[cur] = '{') and (buf^[j] <> #$27) then
      begin
        n := cur;
        while (buf^[cur] <> '}') and (cur < len) do
          Inc(cur);
        CutList.Add(IntToStr(n) + ' ' + IntToStr(cur - n + 1));
        Move(buf^[cur + 1], buf^[n], len - cur);
        Dec(len, cur - n + 1);
        cur := n;
        goto 1;
      end
      else if (buf^[cur] = '/') and (buf^[cur + 1] = '/') and (buf^[j] <> #$27) then
      begin
        n := cur;
        while (buf^[cur] <> #13) and (cur < len) do
          Inc(cur);
        CutList.Add(IntToStr(n) + ' ' + IntToStr(cur - n + 1));
        Move(buf^[cur + 1], buf^[n], len - cur);
        Dec(len, cur - n + 1);
        cur := n;
        goto 1;
      end;
      Inc(cur);
    end;
    Result := AnsiUpperCase(CopyArr(j, cur - j));
    if Result = '' then
      Result := ' ';
  end;

  procedure AddError(s: String);
  var
    i, j, c: Integer;
    s1: String;
  begin
    Error := True;
    cur := lastp;
    SkipSpace;
    for i := 0 to CutList.Count - 1 do
    begin
      s1 := CutList[i];
      j := StrToInt(Copy(s1, 1, Pos(' ', s1) - 1));
      c := StrToInt(Copy(s1, Pos(' ', s1) + 1, 255));
      if lastp >= j then
        Inc(cur, c);
    end;

    Inc(cur);
    i := 0;
    c := 0;
    j := 0;
    while i < MemoFrom.Count do
    begin
      s1 := MemoFrom[i];
      if c + Length(s1) + 1 < cur then
        c := c + Length(s1) + 1 else
      begin
        j := cur - c;
        break;
      end;
      Inc(i);
    end;
    MemoErr.Add('Line ' + IntToStr(i + 1) + '/' + IntToStr(j) + ': ' + s);
    cur := lastp;
  end;

  procedure ProcessBrackets(var i: Integer);
  var
    c: Integer;
    fl1, fl2: Boolean;
  begin
    fl1 := True; fl2 := True; c := 0;
    Dec(i);
    repeat
      Inc(i);
      if fl1 and fl2 then
        if buf^[i] = '[' then
          Inc(c) else
          if buf^[i] = ']' then Dec(c);
      if fl1 then
        if buf^[i] = '"' then fl2 := not fl2;
      if fl2 then
        if buf^[i] = '''' then fl1 := not fl1;
    until (c = 0) or (i >= len);
  end;

  {----------------------------------------------}
  procedure DoDigit;
  begin
    while (buf^[cur] <= ' ') and (cur < len) do Inc(cur);
    if buf^[cur] in ['0'..'9'] then
      while (buf^[cur] in ['0'..'9']) and (cur < len) do Inc(cur)
    else Error := True;
  end;

  procedure DoBegin;
  label 1;
  begin
  1:DoCommand;
    if Error then Exit;
    lastp := cur;
    bs := GetToken;
    if (bs = '') or (bs[1] = ';') then
    begin
      cur := cur - Length(bs) + 1;
      goto 1;
    end
    else if (bs = 'END') or (bs = 'END;') then cur := cur - Length(bs) + 3
    else AddError('Need ";" or "end" here');
  end;

  procedure DoIf;
  var
    nsm, nl, nl1: Integer;
  begin
    nsm := cur;
    DoExpression;
    if Error then Exit;
    bs := ttIf + '  ' + CopyArr(nsm, cur - nsm);
    nl := last;
    MemoTo.Add(bs);
    lastp := cur;
    if GetToken = 'THEN' then
    begin
      DoCommand;
      if Error then Exit;
      nsm := cur;
      if GetToken = 'ELSE' then
      begin
        nl1 := last;
        MemoTo.Add(ttGoto + '  ');
        bs := MemoTo[nl]; bs[2] := Chr(last); bs[3] := Chr(last div 256); MemoTo[nl] := bs;
        DoCommand;
        bs := MemoTo[nl1]; bs[2] := Chr(last); bs[3] := Chr(last div 256); MemoTo[nl1] := bs;
      end
      else
      begin
        bs := MemoTo[nl]; bs[2] := Chr(last); bs[3] := Chr(last div 256); MemoTo[nl] := bs;
        cur := nsm;
      end;
    end
    else AddError('Need "then" here');
  end;

  procedure DoRepeat;
  label 1;
  var
    nl, nsm: Integer;
  begin
    nl := last;
  1:DoCommand;
    if Error then Exit;
    lastp := cur;
    bs := GetToken;
    if bs = 'UNTIL' then
    begin
      nsm := cur;
      DoExpression;
      MemoTo.Add(ttIf + Chr(nl) + Chr(nl div 256) + CopyArr(nsm, cur - nsm));
    end
    else if bs[1] = ';' then
    begin
      cur := cur - Length(bs) + 1;
      goto 1;
    end
    else AddError('Need ";" or "until" here');
  end;

  procedure DoWhile;
  var
    nl, nsm: Integer;
  begin
    nl := last;
    nsm := cur;
    DoExpression;
    if Error then Exit;
    MemoTo.Add(ttIf + '  ' + CopyArr(nsm, cur - nsm));
    lastp := cur;
    if GetToken = 'DO' then
    begin
      DoCommand;
      MemoTo.Add(ttGoto + Chr(nl) + Chr(nl div 256));
      bs := MemoTo[nl]; bs[2] := Chr(last); bs[3] := Chr(last div 256); MemoTo[nl] := bs;
    end
    else AddError('Need "do" here');
  end;

  procedure DoFor;
  var
    nsm, nl: Integer;
    loopvar: String;
  begin
    nsm := cur;
    DoEqual;
    if Error then Exit;
    bs := Trim(CopyArr(nsm, cur - nsm));
    loopvar := Copy(bs, 1, Pos(':=', bs) - 1);
    lastp := cur;
    if GetToken = 'TO' then
    begin
      nsm := cur;
      DoExpression;
      if Error then Exit;
      nl := last;
      MemoTo.Add(ttIf + '  ' + loopvar + '<=' + CopyArr(nsm, cur - nsm));

      lastp := cur;
      if GetToken = 'DO' then
      begin
        DoCommand;
        if Error then Exit;
        MemoTo.Add(loopvar + ' ' + loopvar + '+1');
        MemoTo.Add(ttGoto + Chr(nl) + Chr(nl div 256));
        bs := MemoTo[nl]; bs[2] := Chr(last); bs[3] := Chr(last div 256); MemoTo[nl] := bs;
      end
      else AddError('Need "do" here');
    end
    else AddError('Need "to" here');
  end;

  procedure DoGoto;
  var
    nsm: Integer;
  begin
    SkipSpace;
    nsm := cur;
    lastp := cur;
    DoDigit;
    if Error then AddError('"goto" label must be a number');
    MemoTo.Add(ttGoto + Trim(CopyArr(nsm, cur - nsm)));
  end;

  procedure DoEqual;
  var
    s: String;
    n, nsm: Integer;
  begin
    nsm := cur;
    DoVariable;
    s := Trim(CopyArr(nsm, cur - nsm)) + ' ';
    lastp := cur;
    bs := GetToken;
    if (bs = ';') or (bs = '') or (bs = #0) or (bs = 'END') or (bs = 'ELSE') then
    begin
      s := Trim(CopyArr(nsm, lastp - nsm));
      MemoTo.Add(ttProc + s + '(0)');
      cur := lastp;
    end
    else if Pos(':=', bs) = 1 then
    begin
      cur := cur - Length(bs) + 2;
      nsm := cur;
      DoExpression;
      n := Pos('[', s);
      if n <> 0 then
      begin
        s := ttProc + 'SETARRAY(' + Copy(s, 1, n - 1) + ', ' +
          Copy(s, n + 1, Length(s) - n - 2) + ', ' + CopyArr(nsm, cur - nsm) + ')';
      end
      else
        s := s + CopyArr(nsm, cur - nsm);
      MemoTo.Add(s);
    end
    else
      AddError('Need ":=" here');
  end;
  {-------------------------------------}
  procedure DoExpression;
  var
    nsm: Integer;
  begin
    DoSExpression;
    nsm := cur;
    bs := GetToken;
    if (Pos('>=', bs) = 1) or (Pos('<=', bs) = 1) or (Pos('<>', bs) = 1) then
    begin
      cur := cur - Length(bs) + 2;
      DoSExpression;
    end
    else if (bs[1] = '>') or (bs[1] = '<') or (bs[1] = '=') then
    begin
      cur := cur - Length(bs) + 1;
      DoSExpression;
    end
    else cur := nsm;
  end;

  procedure DoSExpression;
  var
    nsm: Integer;
  begin
    DoTerm;
    nsm := cur;
    bs := GetToken;
    if (bs[1] = '+') or (bs[1] = '-') then
    begin
      cur := cur - Length(bs) + 1;
      DoSExpression;
    end
    else if Pos('OR', bs) = 1 then
    begin
      cur := cur - Length(bs) + 2;
      DoSExpression;
    end
    else cur := nsm;
  end;

  procedure DoTerm;
  var
    nsm: Integer;
  begin
    DoFactor;
    nsm := cur;
    bs := GetToken;
    if (bs[1] = '*') or (bs[1] = '/') then
    begin
      cur := cur - Length(bs) + 1;
      DoTerm;
    end
    else if (Pos('AND', bs) = 1) or (Pos('MOD', bs) = 1) then
    begin
      cur := cur - Length(bs) + 3;
      DoTerm;
    end
    else cur := nsm;
  end;

  procedure DoFactor;
  var
    nsm: Integer;
  begin
    nsm := cur;
    bs := GetToken;
    if bs[1] = '(' then
    begin
      cur := cur - Length(bs) + 1;
      DoExpression;
      SkipSpace;
      lastp := cur;
      if buf^[cur] = ')' then Inc(cur)
      else AddError('Need ")" here');
    end
    else if bs[1] = '[' then
    begin
      cur := cur - Length(bs);
      ProcessBrackets(cur);
      SkipSpace;
      lastp := cur;
      if buf^[cur] = ']' then Inc(cur)
      else AddError('Need "]" here');
    end
    else if (bs[1] = '+') or (bs[1] = '-') then
    begin
      cur := cur - Length(bs) + 1;
      DoExpression;
    end
    else if bs = 'NOT' then
    begin
      cur := cur - Length(bs) + 3;
      DoExpression;
    end
    else
    begin
      cur := nsm;
      DoVariable;
      if Error then
      begin
        Error := False;
        cur := nsm;
        DoConst;
        if Error then
        begin
          Error := False;
          cur := nsm;
          DoFunc;
        end;
      end;
    end;
  end;

  procedure DoVariable;
  begin
    SkipSpace;
    if (buf^[cur] in ['a'..'z', 'A'..'Z']) then
    begin
      Inc(cur);
      while buf^[cur] in ['0'..'9', '_', '.', 'A'..'Z', 'a'..'z'] do Inc(cur);
      if buf^[cur] = '(' then
        Error := True
      else if buf^[cur] = '[' then
      begin
        Inc(cur);
        DoExpression;
        if buf^[cur] <> ']' then
          Error := True else
          Inc(cur);
      end;
    end
    else Error := True;
  end;

  procedure DoConst;
  label 1;
  begin
    SkipSpace;
    if buf^[cur] = #$27 then
    begin
   1: Inc(cur);
      while (buf^[cur] <> #$27) and (cur < len) do Inc(cur);
      if (cur < len) and (buf^[cur + 1] = #$27) then
      begin
        Inc(cur);
        goto 1;
      end;
      if cur = len then Error := True
      else Inc(cur);
    end
    else
    begin
      DoDigit;
      if buf^[cur] = '.' then
      begin
        Inc(cur);
        DoDigit;
      end;
    end;
  end;

  procedure DoLabel;
  begin
    DoDigit;
    if buf^[cur] = ':' then Inc(cur)
    else Error := True;
  end;

  procedure DoFunc;
  label 1;
  begin
    DoFuncId;
    if buf^[cur] = '(' then
    begin
      Inc(cur);
      SkipSpace;
      if buf^[cur] = ')' then
      begin
        Inc(cur);
        exit;
      end;
  1:  DoExpression;
      lastp := cur;
      SkipSpace;
      if buf^[cur] = ',' then
      begin
        Inc(cur);
        goto 1;
      end
      else if buf^[cur] = ')' then Inc(cur)
      else AddError('Need "," or ")" here');
    end;
  end;

  procedure DoFuncId;
  begin
    SkipSpace;
    if buf^[cur] in ['A'..'Z', 'a'..'z'] then
      while buf^[cur] in ['0'..'9', '_', '.', 'A'..'Z', 'a'..'z'] do Inc(cur)
    else Error := True;
  end;

  procedure DoCommand;
  label 1;
  var
    nsm: Integer;
  begin
  1:Error := False;
    nsm := cur;
    lastp := cur;
    bs := GetToken;
    if bs = 'BEGIN' then DoBegin
    else if bs = 'IF' then DoIf
    else if bs = 'REPEAT' then DoRepeat
    else if bs = 'WHILE' then DoWhile
    else if bs = 'FOR' then DoFor
    else if bs = 'GOTO' then DoGoto
    else if (bs = 'END') or (bs = 'END;') then
    begin
      cur := nsm;
      Error := False;
    end
    else if bs = 'UNTIL' then
    begin
      cur := nsm;
      Error := False;
    end
    else
    begin
      cur := nsm;
      DoLabel;
      if Error then
      begin
        Error := False;
        cur := nsm;
        DoVariable;
        if not Error then
        begin
          cur := nsm;
          DoEqual;
        end
        else
        begin
          cur := nsm;
          Error := False;
          DoExpression;
          MemoTo.Add(ttProc + Trim(CopyArr(nsm, cur - nsm)));
        end;
      end
      else
      begin
        AddLabel(Trim(CopyArr(nsm, cur - nsm)), last);
        goto 1;
      end;
    end;
  end;

begin
  CutList := TStringList.Create;
  Error := False;
  GetMem(buf, 32000);
  FillChar(buf^, 32000, 0);
  len := 0;
  for i := 0 to MemoFrom.Count - 1 do
  begin
    s := MemoFrom[i] + #13;
    while Pos(#9, s) <> 0 do
      s[Pos(#9, s)] := ' ';
    Move(s[1], buf^[len], Length(s));
    Inc(len, Length(s));
  end;

  cur := 0; labc := 0;
  MemoTo.Clear;
  MemoErr.Clear;
  if len > 0 then
    DoCommand;
  FreeMem(buf, 32000);
  CutList.Free;

  for i := 0 to MemoTo.Count - 1 do
    if MemoTo[i][1] = ttGoto then
    begin
      s := Remain(MemoTo[i], 2) + ':';
      for j := 0 to labc do
        if labels[j].name = s then
        begin
          s := MemoTo[i]; s[2] := Chr(labels[j].n);
          s[3] := Chr(labels[j].n div 256); MemoTo[i] := s;
          break;
        end;
    end
    else if MemoTo[i][1] = ttIf then
    begin
      s := FParser.Str2OPZ(Remain(MemoTo[i], 4));
      MemoTo[i] := Copy(MemoTo[i], 1, 3) + s;
    end
    else if MemoTo[i][1] = ttProc then
    begin
      s := FParser.Str2OPZ(Remain(MemoTo[i], 2));
      MemoTo[i] := Copy(MemoTo[i], 1, 1) + s;
    end
    else
    begin
      j := 1;
      GetIdentify(MemoTo[i], j);
      len := j;
      s := FParser.Str2OPZ(Remain(MemoTo[i], j));
      MemoTo[i] := Copy(MemoTo[i], 1, len) + s;
    end;
end;

procedure TfrInterpretator.DoScript(Memo: TStrings);
var
  i, j: Integer;
  s, s1: String;
begin
  i := 0;
  while i < Memo.Count do
  begin
    s := Memo[i];
    j := 1;
    if s[1] = ttIf then
    begin
      if FParser.CalcOPZ(Remain(s, 4)) = 0 then
      begin
        i := Ord(s[2]) + Ord(s[3]) * 256;
        continue;
      end;
    end
    else if s[1] = ttGoto then
    begin
      i := Ord(s[2]) + Ord(s[3]) * 256;
      continue;
    end
    else if s[1] = ttProc then
    begin
      s1 := Remain(s, 2);
      if AnsiUpperCase(s1) = 'EXIT(0)' then
        exit;
      FParser.CalcOPZ(s1);
    end
    else
    begin
      s1 := GetIdentify(s, j);
      SetValue(s1, FParser.CalcOPZ(Remain(s, j)));
    end;
    Inc(i);
  end;
end;
{$ELSE}
constructor TfrInterpretator.Create;
begin
  inherited Create;
  FInterpreter := TInterpreter.Create;
  FParser := TfrParser.Create;
  FParser.OnGetValue := GetValue;
  FParser.OnFunction := DoFunction;
  FInterpreter.OnVariable := GetVariable;
  FInterpreter.OnSetVariable := SetVariable;
  Global := False;
end;

destructor TfrInterpretator.Destroy;
begin
  FParser.Free;
  FInterpreter.Free;
  inherited Destroy;
end;

procedure TfrInterpretator.PrepareScript(MemoFrom, MemoTo, MemoErr: TStrings);
var Stream : TMemoryStream;
    Module : TModule;
    Ident : PIdent;
begin
{
  1. Прочитатать из MemoFrom в поток
  2. Сделать трансляцию потока
  3. Ошибки в MemoErr
  4. Результат трансляции в MemoTo
}
  If (MemoFrom.Text <> EmptyStr) or Global then
  begin
    Stream := TMemoryStream.Create;
    MemoFrom.SaveToStream(Stream);
    Stream.Seek(0, 0);
    If Global then Module := TModule.Create(mtGlobal, Stream, nil) else
                   Module := TModule.Create(mtLocal, Stream, nil);
    If Global then
    begin
      while FInterpreter.Translator.ModuleList.Count > 0 do
      begin
        Try
          If TModule(FInterpreter.Translator.ModuleList.Objects[0]).ModuleType = mtGlobal then
          begin
            TModule(FInterpreter.Translator.ModuleList.Objects[0]).FInStream.Free;
          end;
          FInterpreter.Translator.ModuleList.Objects[0].Free;
          FInterpreter.Translator.ModuleList.Delete(0);
        except
        end;
      end;
      while FInterpreter.Translator.ExportNT.Count > 0 do
      begin
        Ident := PIdent(FInterpreter.Translator.ExportNT.Objects[0]);
        DelBlock(Ident);
        FInterpreter.Translator.ExportNT.Delete(0);
      end;
    end;
    FInterpreter.Translator.ModuleList.AddObject('', Module);
    FInterpreter.Translate(FInterpreter.Translator.ModuleList.Count);
    MemoErr.Text := Finterpreter.ErList.Text;
    MemoTo.Text := MemoFrom.Text;
    If not Global then
    begin
      FInterpreter.Translator.ModuleList.Delete(FInterpreter.Translator.ModuleList.Count - 1);
{
      DWindowForm.DWindow.Text := Module.OpList.AsString + #$D#$A + Module.IList.AsString;
      DwindowForm.ShowModal;
}
      Module.Free;
      Stream.Free;
    end;
  end;
end;

procedure TfrInterpretator.DoScript(Memo: TStrings);
var Stream : TMemoryStream;
    Module : TModule;
    TempList : TStringList;
begin
{
 Выполнить оттранслированый код в Memo
}
  If Memo.Text <> EmptyStr then
  begin
    If not Global then
    begin
      Stream := TMemoryStream.Create;
      Memo.SaveToStream(Stream);
      Stream.Seek(0, 0);
      Module := TModule.Create(mtLocal, Stream, nil);
      FInterpreter.Translator.ModuleList.AddObject('', Module);
      FInterpreter.ExecuteCode(FInterpreter.Translator.ModuleList.Count);
      Stream.Free;
      Module.Free;
      FInterpreter.Translator.ModuleList.Delete(FInterpreter.Translator.ModuleList.Count-1);
    end else begin
      TempList := TStringList.Create;
      PrepareScript(Memo, Memo, TempList);
//      If TempList.Text <> EmptyStr then ShowMessage(TempList.Text);
      TempList.Free;
      FInterpreter.ExecuteCode(1);
    end;
  end;
end;
{$ENDIF}

procedure TfrInterpretator.SplitExpressions(Memo, MatchFuncs, SplitTo: TStrings;
  Variables: TfrVariables);
{$IfNDEF 1CScript}
var
  i, j: Integer;
  s: String;
  FuncSplitter: TfrFunctionSplitter;
{$ENDIF}
begin
{$IfNDEF 1CScript}
  FuncSplitter := TfrFunctionSplitter.Create(MatchFuncs, SplitTo, Variables);
  i := 0;
  while i < Memo.Count do
  begin
    s := Memo[i];
    j := 1;
    if s[1] = ttIf then
      FuncSplitter.Split(Remain(s, 4))
    else if s[1] = ttProc then
      FuncSplitter.Split(Remain(s, 2))
    else
    begin
      GetIdentify(s, j);
      FuncSplitter.Split(Remain(s, j));
    end;
    Inc(i);
  end;
  FuncSplitter.Free;
{$ENDIF}
end;

procedure TfrInterpretator.GetValue(const Name: String; var Value: Variant);
begin
// abstract method
end;

procedure TfrInterpretator.SetValue(const Name: String; Value: Variant);
begin
// abstract method
end;

procedure TfrInterpretator.DoFunction(const Name: String; p1, p2, p3: Variant;
  var val: Variant);
begin
// abstract method
end;
{$IFDEF 1CScript}
procedure TfrInterpretator.GetVariable(Sender : TObject; mIndex : Integer; VarName : String; var Ok : Boolean; var Result : TVariant);
begin
  Result.Obj := nil;
  Result.VarValue := Null;
  If Sender is TInterpreter then FParser.OnGetValue(VarName, Result.VarValue)
    else If Assigned(OnGetValue) then OnGetValue(VarName, Result.VarValue);
  If varIsNull(Result.VarValue) or VarIsEmpty(Result.VarValue) then
       Ok := False else Ok := True;
end;
procedure TfrInterpretator.SetVariable(Sender: TObject; mIndex: Integer;
  VarName: String; var Ok: Boolean; var Result: TVariant);
begin
  SetValue(VarName, Result.VarValue);
  Ok := True;
end;

function TfrInterpretator.QueryValue(Name: String): Variant;
var R : TVariant;
begin
//  ShowMessage('query value');
  R := FInterpreter.QueryValue(Name);
  Result := R.VarValue;
end;
procedure TfrInterpretator.FOnSetValue(Value : TGetPValueEvent);
begin
  FOnGetValue := Value;
end;
{$ENDIF}

end.
