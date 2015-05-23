//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop
USERES("Fr3.res");
USEPACKAGE("vcl35.bpi");
USEUNIT("Fr_reg.pas");
USERES("Fr_reg.dcr");
USEPACKAGE("vcldb35.bpi");
USEPACKAGE("tee35.bpi");
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
