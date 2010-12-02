//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop
USERES("tdbf_c3.res");
USEPACKAGE("VCL35.bpi");
USEPACKAGE("vcldb35.bpi");
USEPACKAGE("dclusr35.bpi");
USEUNIT("dbf.pas");
USERES("dbf.dcr");
USEUNIT("dbf_common.pas");
USEUNIT("dbf_cursor.pas");
USEUNIT("dbf_dbffile.pas");
USEUNIT("dbf_fields.pas");
USEUNIT("dbf_idxcur.pas");
USEUNIT("dbf_idxfile.pas");
USEUNIT("dbf_lang.pas");
USEUNIT("dbf_memo.pas");
USEUNIT("dbf_parser.pas");
USEUNIT("dbf_pgcfile.pas");
USEUNIT("dbf_pgfile.pas");
USEUNIT("dbf_prscore.pas");
USEUNIT("dbf_prsdef.pas");
USEUNIT("dbf_prssupp.pas");
USEUNIT("dbf_reg.pas");
USEUNIT("dbf_str.pas");
USEUNIT("dbf_wtil.pas");
USEUNIT("dbf_avl.pas");
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
