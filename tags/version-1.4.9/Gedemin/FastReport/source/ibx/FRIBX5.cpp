//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop
USERES("FRIBX5.res");
USEPACKAGE("vcl50.bpi");
USEUNIT("FR_IBXReg.pas");
USERES("FR_IBXReg.dcr");
USEPACKAGE("vcldb50.bpi");
USEPACKAGE("vclib50.bpi");
USEPACKAGE("Fr5.bpi");
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
