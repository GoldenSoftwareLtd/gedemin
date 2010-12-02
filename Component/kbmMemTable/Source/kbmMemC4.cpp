//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop
USERES("kbmMemC4.res");
USEPACKAGE("vcl40.bpi");
USEUNIT("kbmMemTable.pas");
USEUNIT("kbmMemCSVStreamFormat.pas");
USEUNIT("kbmMemBinaryStreamFormat.pas");
USERES("kbmMemTable.dcr");
USEUNIT("kbmMemResEng.pas");
USEUNIT("kbmMemResFra.pas");
USEUNIT("kbmMemResGer.pas");
USEPACKAGE("Vcldb40.bpi");
USEUNIT("kbmMemTableReg.pas");
USEUNIT("kbmMemResRus.pas");
USEUNIT("kbmMemResBra.pas");
USEUNIT("kbmMemResSpa.pas");
USEUNIT("kbmMemResIta.pas");
USEUNIT("kbmMemResSky.pas");
USEUNIT("kbmMemResRom.pas");
USEUNIT("kbmMemResCsy.pas");
USEUNIT("kbmMemResDut.pas");
USEUNIT("kbmMemResHun.pas");
USEUNIT("kbmMemResUkr.pas");
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
