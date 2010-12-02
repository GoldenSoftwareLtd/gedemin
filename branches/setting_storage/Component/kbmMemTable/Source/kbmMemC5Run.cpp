//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop
USERES("kbmMemC5Run.res");
USEUNIT("kbmMemTable.pas");
USERES("kbmMemTable.dcr");
USEUNIT("kbmMemResEng.pas");
USEUNIT("kbmMemResFra.pas");
USEUNIT("kbmMemResGer.pas");
USEUNIT("kbmMemResRus.pas");
USEUNIT("kbmMemResBra.pas");
USEUNIT("kbmMemResSpa.pas");
USEUNIT("kbmMemResIta.pas");
USEUNIT("kbmMemResSky.pas");
USEUNIT("kbmMemResRom.pas");
USEUNIT("kbmMemResCsy.pas");
USEUNIT("kbmMemResHun.pas");
USEUNIT("kbmMemResUkr.pas");
USEPACKAGE("vcl50.bpi");
USEPACKAGE("vcldb50.bpi");
USEPACKAGE("vclbde50.bpi");
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

