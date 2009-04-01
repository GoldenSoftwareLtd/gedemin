//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop
USERES("FRBDE4.res");
USEPACKAGE("vcl40.bpi");
USEUNIT("FR_BDEReg.pas");
USERES("FR_BDEReg.dcr");
USEPACKAGE("vcldb40.bpi");
USEPACKAGE("vclsmp40.bpi");
USEPACKAGE("FR4.bpi");
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
