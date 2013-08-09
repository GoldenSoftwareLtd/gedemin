unit FindCompare;

interface

//------------------------------------------------------------------------------
//������� ��������� ��������� ����� ��� ����� ��������
//------------------------------------------------------------------------------
//MaxMatching - ������������ ����� ��������� (���������� 3-4)
//strInputMatching - ������������ ������
//strInputStandart - ������-�������

// ����������� ��� ����� ��������
// if IndistinctMatching(4, "��������� ������", "������������ ������  - ������") > 40 then ...

function IndistinctMatching(MaxMatching     : Integer;
                            strInputMatching: PAnsiChar;
                            strInputStandart: PAnsiChar): Integer;
implementation

Uses SysUtils;

Type
     TRetCount = packed record
                 lngSubRows   : Word;
                 lngCountLike : Word;
                end;

//------------------------------------------------------------------------------
function Matching(const StrInputA: PAnsiChar;
                  const StrInputB: PAnsiChar;
                  const lngLen: Integer) : TRetCount;
Var
    TempRet   : TRetCount;
    PosStrB   : Integer;
    PosStrA   : Integer;
begin
    For PosStrA:= 0 To Integer(StrLen(strInputA)) - lngLen do
    begin
//       StrTempA:= System.Copy(strA, PosStrA, lngLen);

       //PosStrB:= 1;
       For PosStrB:= 0 To Integer(StrLen(strInputB)) - lngLen do
       begin
//          StrTempB:= System.Copy(strB, PosStrB, lngLen);

          if AnsiStrLComp(StrInputA + PosStrA, StrInputB + PosStrB, lngLen) = 0 then
//          If SysUtils.AnsiCompareText(StrTempA,StrTempB) = 0 Then
          begin
             Inc(TempRet.lngCountLike);
             break;
          end;
       end;

       Inc(TempRet.lngSubRows);
    end; // PosStrA

    Matching.lngCountLike:= TempRet.lngCountLike;
    Matching.lngSubRows  := TempRet.lngSubRows;
end; { function }

//------------------------------------------------------------------------------
function IndistinctMatching(MaxMatching     : Integer;
                            strInputMatching: PAnsiChar;
                            strInputStandart: PAnsiChar): Integer;
Var
    gret     : TRetCount;
    tret     : TRetCount;
    lngCurLen: Integer   ; //������� ����� ���������
begin
    //���� �� ������� �����-���� ��������, �� �����
    If (MaxMatching = 0) Or (strInputMatching^ = #0) Or
       (strInputStandart^ = #0) Then
    begin
        IndistinctMatching:= 0;
        exit;
    end;

    gret.lngCountLike:= 0;
    gret.lngSubRows  := 0;
    // ���� ������� �� ����� ������������ �����
    For lngCurLen:= 1 To MaxMatching do
    begin
        //���������� ������ A �� ������� B
        tret:= Matching(strInputMatching, strInputStandart, lngCurLen);
        gret.lngCountLike := gret.lngCountLike + tret.lngCountLike;
        gret.lngSubRows   := gret.lngSubRows + tret.lngSubRows;
        //���������� ������ B �� ������� A
        tret:= Matching(strInputStandart, strInputMatching, lngCurLen);
        gret.lngCountLike := gret.lngCountLike + tret.lngCountLike;
        gret.lngSubRows   := gret.lngSubRows + tret.lngSubRows;
    end;

    If gret.lngSubRows = 0 Then
    begin
        IndistinctMatching:= 0;
        exit;
    end;

    IndistinctMatching:= Trunc((gret.lngCountLike / gret.lngSubRows) * 100);
end;


end.
