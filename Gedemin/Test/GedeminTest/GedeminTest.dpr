program GedeminTest;

uses
  FastMM4,
  TestFramework,
  GUITestRunner,
  TestExtensions,
  TestSQLParser_unit in 'TestSQLParser_unit.pas',
  TestGdKeyArray_unit in 'TestGdKeyArray_unit.pas',
  TestMMFStream_unit in 'TestMMFStream_unit.pas',
  Test_gsStorage_unit in 'Test_gsStorage_unit.pas',
  Test_gsMorph_unit in 'Test_gsMorph_unit.pas';

{$R *.res}

begin
  GUITestRunner.runRegisteredTests;
end.

