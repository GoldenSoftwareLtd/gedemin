//---------------------------------------------------------------------------

#include <basepch.h>
#pragma hdrstop
USEFORMNS("NBPagesEditor.pas", Nbpageseditor, NBPagesForm);
USEFORMNS("bsRootEdit.pas", Bsrootedit, bsRootPathEditDlg);
USEFORMNS("bsPngImageEditor.pas", Bspngimageeditor, bsPNGEditorForm);
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
 