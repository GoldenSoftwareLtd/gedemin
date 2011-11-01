unit GedeminTestList;

interface

uses
  TestSQLParser_unit,
  TestGdKeyArray_unit,
  TestMMFStream_unit,
  Test_gsMorph_unit,
  Test_gsPeriodEdit_unit,
  Test_AtSQLSetup_unit,
  TestBasics_unit
  {$IFDEF GEDEMIN}
  , Test_gsStorage_unit
  , Test_gdcContact_unit
  , Test_AcEntry_unit
  , Test_CopyObject_unit
  , Test_gdcMetaData_unit
  , Test_dlgAbout_unit
  {$ENDIF}
  ;
  
implementation

end.
