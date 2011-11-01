//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop
USEUNIT("kbmMemTableReg.pas");
USEPACKAGE("kbmMemC5Run.bpi");
USEPACKAGE("vcl50.bpi");
USEPACKAGE("vcldb50.bpi");
USEPACKAGE("vclbde50.bpi");
USEPACKAGE("dclbde50.bpi");
USEPACKAGE("dcldb50.bpi");
USEPACKAGE("vclx50.bpi");
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

