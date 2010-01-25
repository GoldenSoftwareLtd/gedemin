//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop
USERES("FRADO5.res");
USEPACKAGE("vcl50.bpi");
USEUNIT("FR_ADOReg.pas");
USERES("FR_ADOReg.dcr");
USEPACKAGE("vclado50.bpi");
USEPACKAGE("Fr5.bpi");
USEPACKAGE("vcldb50.bpi");
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
