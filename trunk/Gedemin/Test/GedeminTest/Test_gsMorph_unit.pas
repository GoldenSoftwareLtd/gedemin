
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
  csNominative     = 1;    { Именительный КТО-ЧТО }
  csGenitive       = 2;    { Родительный  КОГО-ЧЕГО }
  csDative         = 3;    { Дательный    КОМУ-ЧЕМУ }
  csAccusative     = 4;    { Винительный  КОГО-ЧТО }
  csInstrumentale  = 5;    { Творительный КЕМ-ЧЕМ }
  csPreposizionale = 6;    { Предложный   О КОМ-О ЧЕМ }
*)

const
  WordCount        = 3;
  NumeralWordCount = 4;
  CaseTest: array[1..WordCount, csNominative..csPreposizionale] of String = (
    ('',         '',         '',         '',         '',         ''),
    ('человек',  'человека', 'человеку', 'человека', 'человеком','человеке'),
    ('моторист-рулевой',  'моториста-рулевого', 'мотористу-рулевому', 'моториста-рулевого', 'мотористом-рулевым', 'мотористе-рулевом')
  );

  CaseNumeralTest: array[1..NumeralWordCount, csNominative..csPreposizionale] of String = (
    ('три', 'трех', 'трем', 'три', 'тремя', 'трех'),
    ('триста шестьдесят', 'трехсот шестидесяти', 'тремстам шестидесяти', 'триста шестьдесят', 'тремястами шестьюдесятью', 'трехстах шестидесяти'),
    ('сорок восемь', 'сорока восьми', 'сорока восьми', 'сорок восемь', 'сорока восьмью', 'сорока восьми'),
    ('десять', 'десяти', 'десяти', 'десять', 'десятью', 'десяти')
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
        'Ошибка при склонении слова "' + CaseTest[I, csNominative] + '"');
    end;
  end;
end;

procedure TgsMorphTest.TestNumericWordBehavior;
const
  StringCount = 5;
  StringArray: array[0..(StringCount - 1), 0..2] of String = (
    ('', '', ''),
    ('человек', 'человека', 'человек'),
    ('гедемин', 'гедемина', 'гедеминов'),
    ('курица', 'курицы', 'куриц'),
    ('стол', 'стола', 'столов')
  );
var
  I: Integer;
begin
  for I := 0 to StringCount - 1 do
  begin
    Check(GetNumericWordForm(1, StringArray[I, 0], StringArray[I, 1], StringArray[I, 2]) = StringArray[I, 0],
      'Ошибка при склонении слова "' + StringArray[I, 0] + '" по числу 1');
    Check(GetNumericWordForm(2, StringArray[I, 0], StringArray[I, 1], StringArray[I, 2]) = StringArray[I, 1],
      'Ошибка при склонении слова "' + StringArray[I, 0] + '" по числу 2');
    Check(GetNumericWordForm(5, StringArray[I, 0], StringArray[I, 1], StringArray[I, 2]) = StringArray[I, 2],
      'Ошибка при склонении слова "' + StringArray[I, 0] + '" по числу 5');
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
        'Ошибка при склонении слова "' + CaseNumeralTest[I, csNominative] + '"');
    end;
  end;
end;

initialization
  RegisterTest('Internals', TgsMorphTest.Suite);
end.
