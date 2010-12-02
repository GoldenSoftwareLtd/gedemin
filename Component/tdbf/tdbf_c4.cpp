//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop

USEUNIT("Dbf_Common.pas");
USEUNIT("Dbf_Cursor.pas");
USEUNIT("Dbf_Fields.pas");
USEUNIT("Dbf_DbfFile.pas");
USEUNIT("Dbf_IdxCur.pas");
USEUNIT("Dbf_IdxFile.pas");
USEUNIT("Dbf_Memo.pas");
USEUNIT("Dbf_PgFile.pas");
USEUNIT("Dbf_Str.pas");
USEUNIT("Dbf.pas");
USEUNIT("Dbf_PrsSupp.pas");
USEUNIT("Dbf_PrsDef.pas");
USEUNIT("Dbf_PrsCore.pas");
USEUNIT("Dbf_Parser.pas");
USEUNIT("Dbf_Lang.pas");
USEUNIT("Dbf_Wtil.pas");
USERES("Dbf.dcr");
USEPACKAGE("vcl40.bpi");
USEPACKAGE("VCLX40.bpi");
//---------------------------------------------------------------------------
#pragma package(smart_init)
//---------------------------------------------------------------------------
//   Source du paquet.
//---------------------------------------------------------------------------
int WINAPI DllEntryPoint(HINSTANCE hinst, unsigned long reason, void*)
{
  return 1;
}
//---------------------------------------------------------------------------
