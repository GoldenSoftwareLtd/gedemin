program TestProperty2;

{%ToDo 'TestProperty2.todo'}

uses
  Forms,
  prp_dlgViewProperty_unit in 'prp_dlgViewProperty_unit.pas' {dlgViewProperty},
  prp_i_MethodsList in 'prp_i_MethodsList.pas',
  prp_MainTestForm_unit2 in 'prp_MainTestForm_unit2.pas' {MainTestForm2},
  TestProperty_TLB in 'TestProperty_TLB.pas',
  tst_BaseClass in 'tst_BaseClass.pas',
  tst_TwoClass in 'tst_TwoClass.pas',
  tst_TestInterface in 'tst_TestInterface.pas',
  evt_Base in 'evt_Base.pas',
  evt_i_Base in 'evt_i_Base.pas',
  obj_WrapperDelphiClasses in 'obj_WrapperDelphiClasses.pas',
  prp_TestForm2_unit in 'prp_TestForm2_unit.pas' {TestForm2},
  gdcMacros in '..\Component\GDC\gdcMacros.pas',
  prp_dlgViewProperty3_unit in 'prp_dlgViewProperty3_unit.pas' {dlgViewProperty3},
  prp_dlgViewProperty2_unit in 'prp_dlgViewProperty2_unit.pas' {dlgViewProperty2},
  gdcObject in '..\Component\GDC\gdcObject.pas',
  gdcConstants in '..\Component\GDC\gdcConstants.pas',
  scr_i_FunctionList in 'scr_i_FunctionList.pas',
  dmTestReport_unit in '..\Report\dmTestReport_unit.pas' {dmTestReport: TDataModule},
  dmClientReport_unit in '..\Report\dmClientReport_unit.pas' {dmClientReport: TDataModule};

//{$R Gedemin.TLB}

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TdmTestReport, dmTestReport);
  Application.CreateForm(TMainTestForm2, MainTestForm2);
  Application.CreateForm(Tfff, fff);
  fff.PopupMenu.OnPopup := MainTestForm2.Button3Click;
  fff.Name := 'TestObject';
  Application.Run;
end.
