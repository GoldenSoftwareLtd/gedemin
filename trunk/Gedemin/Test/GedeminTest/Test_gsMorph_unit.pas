
unit Test_gsMorph_unit;

interface

uses
  Classes, TestFrameWork, gsMorph, windows;

type
  TgsMorphTest = class(TTestCase)
  published
    procedure TestBasicBehavior;
    procedure TestNumericWordBehavior;
    procedure TestNumeral;
  end;

implementation

{ TgsMorphTest }

(*
  csNominative     = 1;    { ������������ ���-��� }
  csGenitive       = 2;    { �����������  ����-���� }
  csDative         = 3;    { ���������    ����-���� }
  csAccusative     = 4;    { �����������  ����-��� }
  csInstrumentale  = 5;    { ������������ ���-��� }
  csPreposizionale = 6;    { ����������   � ���-� ��� }
*)

const
  WordCount        = 3;
  NumeralWordCount = 4;
  CaseTest: array[1..WordCount, csNominative..csPreposizionale] of String = (
    ('',         '',         '',         '',         '',         ''),
    ('�������',  '��������', '��������', '��������', '���������','��������'),
    ('��������-�������',  '���������-��������', '���������-��������', '���������-��������', '����������-�������', '���������-�������')
  );

  CaseNumeralTest: array[1..NumeralWordCount, csNominative..csPreposizionale] of String = (
    ('���', '����', '����', '���', '�����', '����'),
    ('������ ����������', '������� �����������', '�������� �����������', '������ ����������', '���������� �������������', '�������� �����������'),
    ('����� ������', '������ ������', '������ ������', '����� ������', '������ �������', '������ ������'),
    ('������', '������', '������', '������', '�������', '������')
  );


procedure TgsMorphTest.TestBasicBehavior;
var
  I, J: Integer;
begin
  for I := 1 to WordCount do
  begin
    for J := csNominative to csPreposizionale do
    begin
      Check(ComplexCase(CaseTest[I, csNominative], J) = CaseTest[I, J],
        '������ ��� ��������� ����� "' + CaseTest[I, csNominative] + '"');
    end;
  end;
end;

procedure TgsMorphTest.TestNumericWordBehavior;
const
  StringCount = 5;
  StringArray: array[0..(StringCount - 1), 0..2] of String = (
    ('', '', ''),
    ('�������', '��������', '�������'),
    ('�������', '��������', '���������'),
    ('������', '������', '�����'),
    ('����', '�����', '������')
  );
var
  I: Integer;
begin
  for I := 0 to StringCount - 1 do
  begin
    Check(GetNumericWordForm(1, StringArray[I, 0], StringArray[I, 1], StringArray[I, 2]) = StringArray[I, 0],
      '������ ��� ��������� ����� "' + StringArray[I, 0] + '" �� ����� 1');
    Check(GetNumericWordForm(2, StringArray[I, 0], StringArray[I, 1], StringArray[I, 2]) = StringArray[I, 1],
      '������ ��� ��������� ����� "' + StringArray[I, 0] + '" �� ����� 2');
    Check(GetNumericWordForm(5, StringArray[I, 0], StringArray[I, 1], StringArray[I, 2]) = StringArray[I, 2],
      '������ ��� ��������� ����� "' + StringArray[I, 0] + '" �� ����� 5');
  end;
end;

procedure TgsMorphTest.TestNumeral;
var
  I, J: Integer;
begin
  for I := 1 to WordCount do
  begin
    for J := csNominative to csPreposizionale do
    begin
      OutputDebugString(PChar(ComplexCase(CaseNumeralTest[I, csNominative], J) + '=' + CaseNumeralTest[I, J]));
      Check(ComplexCase(CaseNumeralTest[I, csNominative], J) = CaseNumeralTest[I, J],
        '������ ��� ��������� ����� "' + CaseNumeralTest[I, csNominative] + '"');
    end;
  end;
end;

initialization
  RegisterTest('Internals', TgsMorphTest.Suite);
end.
