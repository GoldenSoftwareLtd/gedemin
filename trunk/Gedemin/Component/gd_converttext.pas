
unit gd_converttext;

interface

{

  ������� ����������� ���������� �� ��������� ��������� � �������
  ����� ������� � ������������ ������ � ������������ � �����
  ���������� ����������.

  ������� �����������, ��������, � ������, ��� ����������� ��
  ������� �� ������� �12.

  ���� ������������ ����� ������ Golden Software, ��
  �������� ������ ��� �� ������� ��������� ����������, ��
  ������ ����, ����� ����������� ���������, ������� ���������
  ����������� � ������� ����� ������, ��� ���������� ������ �12.
  ��������� ����� ����������� �� ���������� � ����� �������������
  ���, ��� ����� �� ��� ������ �� ���������� ���������.

}

function ConvertText(const S: String): String;

implementation

uses
  SysUtils, Windows;

const
  ArrRus = '�"�;:?��������������������������������.���������������������������������.';
  ArrEng = '`@#$^&qwertyuiop[]asdfghjkl;''zxcvbnm,./~QWERTYUIOP[]ASDFGHJKL;''ZXCVBNM,./';
  ArrBel = '�"�;:?�����������''�������������������.��������ء��''��������������̲����.';

function ConvertText(const S: String): String;
var
  Ch: array[0..KL_NAMELENGTH] of Char;
  Kl, I, J: Integer;
  SFrom, STo: String;
begin
  Result := S;

  GetKeyboardLayoutName(Ch);
  KL := StrToInt('$' + StrPas(Ch));

  case (KL and $3ff) of
    LANG_BELARUSIAN: SFrom := ArrBel;
    LANG_RUSSIAN: SFrom := ArrRus;
    LANG_ENGLISH: SFrom := ArrEng;
  else
    exit;
  end;

  ActivateKeyBoardLayout(HKL_NEXT, 0);
  GetKeyboardLayoutName(Ch);
  KL := StrToInt('$' + StrPas(Ch));

  case (KL and $3ff) of
    LANG_BELARUSIAN: STo := ArrBel;
    LANG_RUSSIAN: STo := ArrRus;
    LANG_ENGLISH: STo := ArrEng;
  else
    exit;
  end;

  for I := 1 to Length(Result) do
  begin
    J := AnsiPos(Result[I], SFrom);
    if J > 0 then
      Result[I] := STo[J];
  end;
end;


end.
 