program GedeminTest;

uses
  FastMM4,
  TestFramework,
  GUITestRunner,
  TestExtensions,
  GedeminTestList;

{$R *.res}

begin
  GUITestRunner.runRegisteredTests;
end.

