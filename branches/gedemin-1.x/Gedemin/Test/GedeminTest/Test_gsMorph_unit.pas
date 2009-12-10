
unit Test_gsMorph_unit;

interface

uses
  Classes, TestFrameWork, gsMorph;

type
  TgsMorphTest = class(TTestCase)
  published
    procedure TestBasicBehavior;
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
  WordCount = 3;
  CaseTest: array[1..WordCount, csNominative..csPreposizionale] of String = (
    ('',         '',         '',         '',         '',         ''),
    ('�������',  '��������', '��������', '��������', '���������','��������'),
    ('��������-�������',  '���������-��������', '���������-��������', '���������-��������', '����������-�������', '���������-�������')
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

initialization
  RegisterTest('', TgsMorphTest.Suite);
end.
