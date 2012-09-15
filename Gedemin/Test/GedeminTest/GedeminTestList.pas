unit GedeminTestList;

interface

uses
  TestSQLParser_unit,
  Test_MovementDocumenttype,
  Test_AddDuplicateAccount,
  TestGdKeyArray_unit,
  TestMMFStream_unit,
  Test_gsMorph_unit,
  Test_gsPeriodEdit_unit,
  Test_AtSQLSetup_unit,
  Test_gsFTPClient_unit,
  TestBasics_unit
  {$IFDEF WITH_INDY}
  , Test_Indy_unit 
  {$ENDIF}
  {$IFDEF GEDEMIN}
  , Test_gsStorage_unit
  , Test_gdcContact_unit
  , Test_AcEntry_unit
  , Test_CopyObject_unit
  , Test_gdcMetaData_unit
  , Test_dlgAbout_unit
  , Test_gdcObject_unit
  {$ENDIF}
  ;
  
implementation

end.
