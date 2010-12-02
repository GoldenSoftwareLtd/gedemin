//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop
USERES("FR4.res");
USEPACKAGE("vcl40.bpi");
USEUNIT("fr_reg.pas");
USERES("fr_reg.dcr");
USEUNIT("FR_DBUtils.pas");
USEFORMNS("FR_DBFldList.pas", Fr_dbfldlist, frDBFieldsListForm);
USEUNIT("FR_DBLookupCtl.pas");
USEFORMNS("FR_DBNewLookup.pas", Fr_dbnewlookup, frDBLookupFieldForm);
USEFORMNS("FR_DBSQLEdit.pas", Fr_dbsqledit, frDBSQLEditorForm);
USEFORMNS("FR_DBFldEditor.pas", Fr_dbfldeditor, frDBFieldsEditorForm);
USEPACKAGE("vclsmp40.bpi");
USEPACKAGE("vcldb40.bpi");
USEPACKAGE("vclx40.bpi");
USEPACKAGE("vcljpg40.bpi");
USEPACKAGE("tee40.bpi");
//---------------------------------------------------------------------------
#pragma package(smart_init)
//---------------------------------------------------------------------------
//   Package source.
//---------------------------------------------------------------------------
int WINAPI DllEntryPoint(HINSTANCE hinst, unsigned long reason, void*)
{
        return 1;
}
//---------------------------------------------------------------------------
