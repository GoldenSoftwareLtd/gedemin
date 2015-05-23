unit gdStrings;

interface

uses
  classes;

const
  gdsSpace       = ' ';
  gdsComment     = '//';
  gdsBPasComment = '{';
  gdsEPasComment = '}';
  gdsBCComment   = '(*';
  gdsECComment   = '*)';
  gdsStrSymbol   = '''';
  gdsStrEnd      = ';';
//  gdsStrReplPas = '';
//  gdsStrReplC   = 'CCC';
  gdsStrReplPas = 'asd_begin_g8#6_Pascal_0a8$_Comment_%76a^';
  gdsStrReplC   = 'jyl_begin_gkbe_C_094dfm#$%_Comment_vzf%^';
  gdsStrComment = 'sergh$%tarG54Ysy%$herg%^se_Comment_n*bD^';

// ������ ���������� ������ begin - end
  bgnCase  = 'CASE';
  bgnAsm   = 'ASM';
  bgnTry   = 'TRY';
  bgnBegin = 'BEGIN';

  endEnd   = 'END';

// �������� �� ������ ������ �����, �������� ���������� �������
function TestOnFirstFullWord(const AWord, AStr: String): Boolean;
// ���������� ��������� ��������� � ������
function  SubStrCount(const ASubString, AString: String): Integer;
// ���-�� Pos, �� ��� ����� ��������
function  PosWithoutCase(const ASubString, AString: String): Integer;
// ���������� ������ ��� ������������
// PasText - ������������ �����, StrPos - ������� ������,
// NextPos - ��������� ������ ����� �������� ����������� (���� ������ ���, �� -1),
// BeginSymbol - ������ ������ ����� �����������
function StrWithoutComment(PasFile: TStrings; const StrPos: Integer;
  out NextPos: Integer; var BeginSymbol: Integer; const FindNext: Boolean): String;
// ��������� ������ ��� ������ ���������
function StrWithoutSubStr(const SubStr, Str: String): String;
// ���������� ���������� ����� ���������� ������ begin end � ������
// Str - ������ ��� ������������
function BeginCountInStr(const Str: String): Integer;
// ���������� End � ������
function EndCountInStr(const Str: String): Integer;
// ���������� ��������� ��������� � ������
// ���� ��� ���. ������ begin end
function OperatorCount(Operator, AStr: String): Integer;

function ReplaceSubStr(const OutSubStr, InSubStr: String; var Str: String): Boolean;

implementation

uses
  SysUtils, JclStrings;

function OperatorCount(Operator, AStr: String): Integer;
var
  ai, ac: Integer;
  aTmpStr, aRStr: String;
begin
  Result := 0;
  ai := SubStrCount(Operator, AStr);
  for ai := 1 to SubStrCount(Operator, AStr) do
  begin
    aTmpStr := StrLeft(AStr, StrNPos(UpperCase(AStr), Operator, ai) - 1);
    aRStr := Copy(AStr, StrNPos(UpperCase(AStr), Operator, ai) + Length(Operator),
      Length(AStr));
    if ((Length(Trim(aRStr)) = 0) or (Pos(gdsSpace, aRStr) = 1) or
      (Pos(gdsStrEnd, Trim(aRStr)) = 1)) and ((Length(Trim(aTmpStr)) = 0) or
      (StrRight(aTmpStr, 1) = gdsSpace) or
      (StrRight(aTmpStr, 1) = gdsStrEnd)) then
//      (StrRight(aRStr, 1) = gdsSpace) or
//      (StrRight(aRStr, 1) = gdsStrEnd)) then
    begin
      if SubStrCount(gdsStrSymbol, aTmpStr) mod 2 = 0 then
        Inc(Result);
    end;
  end;
end;

function  SubStrCount(const ASubString, AString: String): Integer;
var
  str: String;
begin
  Result := 0;
  str := AString;
  while Pos(UpperCase(ASubString), UpperCase(str)) > 0 do
  begin
    Inc(Result);
    str := StrAfter(ASubString, str);
  end;
end;

function  PosWithoutCase(const ASubString, AString: String): Integer;
begin
  Result := Pos(UpperCase(ASubString), UpperCase(AString));
end;

function TestOnFirstFullWord(const AWord, AStr: String): Boolean;
var
  {bStr, }eStr: String;
begin
  Result := False;
  if ((PosWithoutCase(AWord, Trim(AStr)) = 1)) then
  begin
//    bStr := TrimLeft(StrBefore(AWord, AStr));
    eStr := StrAfter(AWord, AStr);
    if (Length(eStr) = 0) or (Pos('{', eStr) = 1) or
      (Pos('(', eStr) = 1) or (Pos(';', eStr) = 1) or
      (Pos('/', eStr) = 1) or (Pos(' ', eStr) = 1) or
      (Pos('-', eStr) = 1) or (Pos('+', eStr) = 1) or
      (Pos('=', eStr) = 1) or (Pos('*', eStr) = 1) or
      (Pos('[', eStr) = 1) or (Pos('^', eStr) = 1)then
      Result := True;
  end;
end;

function StrWithoutComment(PasFile: TStrings; const StrPos: Integer;
  out NextPos: Integer; var BeginSymbol: Integer; const FindNext: Boolean): String;
var
  i, k: Integer;
  TempStr, MdlStr, PasStr, PrStr: String;
  LeftStr, RightStr: String;
  EndComment, FlagCom, ComDet: Boolean;
  InsidePasFile: TStrings;

begin
//  if StrPos < (PasFile.Count - 1) then
  Result := '';
  NextPos := StrPos + 1;
  if StrPos >= PasFile.Count then
    Exit;
  MdlStr := PasStr;
  BeginSymbol := 0;
  InsidePasFile := TStringList.Create;
  try
    InsidePasFile.Assign(PasFile);
    InsidePasFile[StrPos] := Copy(PasFile[StrPos], BeginSymbol, Length(PasFile[StrPos]));
    PasStr := InsidePasFile[StrPos];
    // ���� ������ ���������� � //, �� ��� �����������






    if Pos(gdsComment, Trim(PasStr)) = 1 then
    begin
      Exit;
    end;

    MdlStr := PasStr;
    // ��������� ����������� � ����� �������
    if SubStrCount(gdsBPasComment, PasStr) > 0 then
    begin
      // ����� ������� ������� �����������, ����������� � ��������� ����������
      i := 1;
      while i < SubStrCount(gdsBPasComment, PasStr) + 1 do
      begin
        TempStr := StrLeft(PasStr, StrNPos(PasStr, gdsBPasComment, i) - 1);
        if (SubStrCount(gdsStrSymbol, TempStr) mod 2) = 0 then
        begin
          if Pos(gdsBCComment, TempStr) > 0 then
          begin
            LeftStr := TempStr + gdsBPasComment;
            RightStr := Copy(PasStr, Pos(gdsBPasComment, PasStr) + 1, Length(PasStr));
            ReplaceSubStr(gdsBPasComment, gdsStrReplPas, LeftStr);
            InsidePasFile[StrPos] := LeftStr;
            LeftStr := StrWithoutComment(InsidePasFile, StrPos,
                  NextPos, BeginSymbol, False);
            FlagCom := ReplaceSubStr(gdsStrReplPas, gdsBPasComment, LeftStr);
            InsidePasFile[StrPos] := LeftStr + RightStr;
            if FlagCom then
            begin
              MdlStr := TempStr;
              Break;
            end else
              begin
               TempStr := LeftStr + gdsBCComment;
               InsidePasFile[StrPos] := TempStr + RightStr;
               PasStr := InsidePasFile[StrPos];
              end;
          end else
            begin
//              Inc(i);

              MdlStr := TempStr;
              Break;
            end;
        end else
          Inc(i);
      end;
      PasStr := InsidePasFile[StrPos];

      // ���� ����� ������ ����������� ���������
      if i < SubStrCount(gdsBPasComment, PasStr) + 1 then
      begin
        FlagCom := True;
        if FlagCom then
        begin
          // ������ ����� ������ �����������
          TempStr := Copy(PasStr,
            StrNPos(PasStr, gdsBPasComment, i) + 1, Length(PasStr));
          // ����� ����� �����������
          if Pos(gdsEPasComment, TempStr) > 0 then
          begin
            // ���� � ������ ��������� ����� �����������, �� ���������
            // ������������� ��������� ��� �������� �����������
            MdlStr := MdlStr +
              Copy(TempStr, Pos(gdsEPasComment, TempStr) + 1, Length(TempStr));
            InsidePasFile[StrPos] := MdlStr;
            // ����������� �����, � ������ ����� ���� ��� �����������
            if (Pos(gdsComment, MdlStr) > 0) or (Pos(gdsBPasComment, MdlStr) > 0) or
              (Pos(gdsBCComment, MdlStr) > 0) then
              MdlStr := StrWithoutComment(InsidePasFile, StrPos,
                NextPos, BeginSymbol, True);
          end else
            begin
              // ���� ����� ����������� �� ��������� � ������� ������,
              // �� ���� ��� � ������ �� ������
              if FindNext then
                for i := StrPos + 1 to InsidePasFile.Count - 1 do
                begin
                  if Pos(gdsEPasComment, InsidePasFile[i]) > 0 then
                  begin
                    BeginSymbol := Pos(gdsEPasComment, InsidePasFile[i]) + 1;
                    NextPos := i;
                    Break;
                  end;
                end;
            end;
        end;
      end;
    end;// else
    begin
      // ��������� ����������� � ����� �, ���������� �����������
      if SubStrCount(gdsBCComment, PasStr) > 0 then
      begin
        PasStr := MdlStr;
//        MdlStr := PasStr;

//*********************

        for i := 1 to SubStrCount(gdsBCComment, PasStr) do
        begin
          TempStr := StrLeft(PasStr, StrNPos(PasStr, gdsBCComment, i) - 1);
          if (SubStrCount(gdsStrSymbol, TempStr) mod 2) = 0 then
          begin
            MdlStr := TempStr;
            Break;
          end;
        end;
        FlagCom := True;
        if FlagCom then
        begin
          if i < SubStrCount(gdsBCComment, PasStr) + 1 then
          begin
//            TempStr := StrRight(PasStr, StrNPos(PasStr, gdsBCComment, i) + 1);
            TempStr := Copy(PasStr,
              StrNPos(PasStr, gdsBCComment, i) + 2, Length(PasStr));
            if Pos(gdsECComment, TempStr) > 0 then
            begin
              MdlStr := MdlStr +
                Copy(TempStr, Pos(gdsECComment, TempStr) + 2, Length(TempStr));
              InsidePasFile[StrPos] := MdlStr;
              if (Pos(gdsComment, MdlStr) > 0) or (Pos(gdsBPasComment, MdlStr) > 0) or
                (Pos(gdsBCComment, MdlStr) > 0) then
                MdlStr := StrWithoutComment(InsidePasFile, StrPos,
                  NextPos, BeginSymbol, True);
            end else
              begin
                if FindNext then
                  for k := StrPos + 1 to InsidePasFile.Count - 1 do
                  begin
                    if Pos(gdsECComment, InsidePasFile[k]) > 0 then
                    begin
                      BeginSymbol := Pos(gdsECComment, InsidePasFile[k]) + 2;
                      NextPos := k;
                      Break;
                    end;
                  end;
              end;
          end;
        end;
      end;
    end;

{    // �������� �� ������� � ����� ������ ���� '//'}
    if Pos(gdsComment, MdlStr) > 0 then
    begin
      ComDet := False;
      for i := 1 to SubStrCount(gdsComment, MdlStr) do
      begin
        TempStr := StrLeft(MdlStr, StrNPos(MdlStr, gdsComment, i) - 1);
        if (SubStrCount(gdsStrSymbol, TempStr) mod 2) = 0 then
        begin
          MdlStr := TempStr;
          ComDet := True;
          Break;
        end;
      end;
      if ComDet then
        MdlStr := TempStr;
    end;

  finally
    InsidePasFile.Free;
  end;
  Result := MdlStr;
end;

function StrWithoutSubStr(const SubStr, Str: String): String;
begin
  if Pos(SubStr, Str) > 0 then
    Result := Copy(Str, 1, Pos(SubStr, Str) - 1) +
      Copy(Str, Pos(SubStr, Str) + Length(SubStr), Length(Str))
  else
    Result := Str;
end;

function ReplaceSubStr(const OutSubStr, InSubStr: String; var Str: String): Boolean;
begin
  Result := False;
  if Pos(OutSubStr, Str) > 0 then
  begin
    Str := Copy(Str, 1, Pos(OutSubStr, Str) - 1) + InSubStr +
      Copy(Str, Pos(OutSubStr, Str) + Length(OutSubStr), Length(Str));
    Result := True;
  end;
end;

function BeginCountInStr(const Str: String): Integer;
var
  TmpStr: String;
begin
  Result := 0;
  TmpStr := UpperCase(Str);
  if (Length(Str) = 0) or ((Pos(bgnCase, TmpStr) = 0) and
    (Pos(bgnTry, TmpStr) = 0) and (Pos(bgnAsm, TmpStr) = 0) and
    (Pos(bgnBegin, TmpStr) = 0)) then
    Exit;

  Result := OperatorCount(bgnBegin, TmpStr);
  Result := Result + OperatorCount(bgnCase, TmpStr);
  Result := Result + OperatorCount(bgnTry, TmpStr);
  Result := Result + OperatorCount(bgnAsm, TmpStr);
end;

function EndCountInStr(const Str: String): Integer;
begin
  Result := OperatorCount(endEnd, Str);
end;

end.
