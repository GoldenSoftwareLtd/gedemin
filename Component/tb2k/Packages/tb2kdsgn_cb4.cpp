// $Id: tb2kdsgn_cb4.cpp,v 1.2 2001/08/19 15:44:00 jr Exp $
//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop
USEPACKAGE("vcl40.bpi");
USEUNIT("..\Source\TB2DsgnConsts.pas");
USEFORMNS("..\Source\TB2DsgnConverter.pas", Tb2dsgnconverter, TBConverterForm);
USEFORMNS("..\Source\TB2DsgnItemEditor.pas", Tb2dsgnitemeditor, TBItemEditForm);
USEFORMNS("..\Source\TB2DsgnConvertOptions.pas", Tb2dsgnconvertoptions, TBConvertOptionsForm);
USEUNIT("..\Source\TB2Reg.pas");
USERES("..\Source\TB2Reg.dcr");
USEPACKAGE("dclstd40.bpi");
USEPACKAGE("tb2k_cb4.bpi");
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

