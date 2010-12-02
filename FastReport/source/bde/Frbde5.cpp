//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop
USERES("Frbde5.res");
USEUNIT("FR_BDEReg.pas");
USERES("FR_BDEReg.dcr");
USEPACKAGE("vcl50.bpi");
USEPACKAGE("vcldb50.bpi");
USEPACKAGE("vclbde50.bpi");
USEPACKAGE("vclsmp50.bpi");
USEPACKAGE("Fr5.bpi");
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
