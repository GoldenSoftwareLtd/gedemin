//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop
USERES("Fr5.res");
USEUNIT("fr_reg.pas");
USERES("fr_reg.dcr");
USEUNIT("FR_DBUtils.pas");
USEFORMNS("FR_DBFldList.pas", Fr_dbfldlist, frDBFieldsListForm);
USEUNIT("FR_DBLookupCtl.pas");
USEFORMNS("FR_DBNewLookup.pas", Fr_dbnewlookup, frDBLookupFieldForm);
USEFORMNS("FR_DBSQLEdit.pas", Fr_dbsqledit, frDBSQLEditorForm);
USEFORMNS("FR_DBFldEditor.pas", Fr_dbfldeditor, frDBFieldsEditorForm);
USEPACKAGE("vcl50.bpi");
USEPACKAGE("vclsmp50.bpi");
USEPACKAGE("vcldb50.bpi");
USEPACKAGE("vclbde50.bpi");
USEPACKAGE("vclx50.bpi");
USEPACKAGE("vcljpg50.bpi");
USEPACKAGE("tee50.bpi");
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
