unit GedeminTestList;

interface

uses
  TestSQLParser_unit,
  TestGdKeyArray_unit,
  TestMMFStream_unit,
  Test_gsStorage_unit,
  Test_gsMorph_unit
  {$IFDEF GEDEMIN}
  , Test_gdcContact_unit
  , Test_CopyObject_unit
  {$ENDIF}
  ;
  
implementation

end.
