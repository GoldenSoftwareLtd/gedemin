program TestProperty;

{%ToDo 'TestProperty.todo'}
{$DEFINE GEDEMIN}
uses
  Forms,
  prp_dlgViewProperty_unit in 'prp_dlgViewProperty_unit.pas' {dlgViewProperty},
  prp_i_MethodsList in 'prp_i_MethodsList.pas',
  prp_MainTestForm_unit in 'prp_MainTestForm_unit.pas' {MainTestForm},
  TestProperty_TLB in 'TestProperty_TLB.pas',
  tst_BaseClass in 'tst_BaseClass.pas',
  tst_TwoClass in 'tst_TwoClass.pas',
  tst_TestInterface in 'tst_TestInterface.pas',
  evt_Base in 'evt_Base.pas',
  evt_i_Base in 'evt_i_Base.pas',
  mtd_Base in 'mtd_Base.pas',
  mtd_i_Base in 'mtd_i_Base.pas',
  prp_frmFromMain_unit in 'prp_frmFromMain_unit.pas' {frmFromMain},
  obj_WrapperDelphiClasses in 'obj_WrapperDelphiClasses.pas',
  gdcMacros in '..\Component\GDC\gdcMacros.pas',
  gdcDelphiObject in '..\Component\GDC\gdcDelphiObject.pas',
  gdcConstants in '..\Component\GDC\gdcConstants.pas',
  scr_i_FunctionList in 'scr_i_FunctionList.pas',
  dmClientReport_unit in '..\Report\dmClientReport_unit.pas' {dmClientReport: TDataModule},
  dmDataBase_unit in '..\GAdmin\dmDataBase_unit.pas';

//{$R Gedemin.TLB}

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TdmDatabase, dmDatabase);
  Application.CreateForm(TdmClientReport, dmClientReport);
  Application.CreateForm(TMainTestForm, MainTestForm);
  fff.PopupMenu.OnPopup := MainTestForm.Button3Click;
  fff.Name := 'TestObject';
  Application.Run;
end.
