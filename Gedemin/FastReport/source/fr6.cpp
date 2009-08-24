//---------------------------------------------------------------------------

#include <basepch.h>
#pragma hdrstop
USEFORMNS("FR_DBFldList.pas", Fr_dbfldlist, frDBFieldsListForm);
USEFORMNS("FR_DBNewLookup.pas", Fr_dbnewlookup, frDBLookupFieldForm);
USEFORMNS("FR_DBSQLEdit.pas", Fr_dbsqledit, frDBSQLEditorForm);
USEFORMNS("FR_DBFldEditor.pas", Fr_dbfldeditor, frDBFieldsEditorForm);
//---------------------------------------------------------------------------
#pragma package(smart_init)
//---------------------------------------------------------------------------

//   Package source.
//---------------------------------------------------------------------------

#pragma argsused
int WINAPI DllEntryPoint(HINSTANCE hinst, unsigned long reason, void*)
{
        return 1;
}
//---------------------------------------------------------------------------
 