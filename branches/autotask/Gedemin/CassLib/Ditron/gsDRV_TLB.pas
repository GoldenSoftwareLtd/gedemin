unit gsDRV_TLB;

// ************************************************************************ //
// WARNING                                                                    
// -------                                                                    
// The types declared in this file were generated from data read from a       
// Type Library. If this type library is explicitly or indirectly (via        
// another type library referring to this type library) re-imported, or the   
// 'Refresh' command of the Type Library Editor activated while editing the   
// Type Library, the contents of this file will be regenerated and all        
// manual modifications will be lost.                                         
// ************************************************************************ //

// PASTLWTR : $Revision:   1.88.1.0.1.0  $
// File generated on 06.09.2005 13:42:23 from Type Library described below.

// ************************************************************************ //
// Type Lib: c:\Program Files\Borland\Delphi5\Projects\Ditron\DitronEU200CS.tlb (1)
// IID\LCID: {76B1392D-EB0B-4C92-9D14-A751CB43B3D6}\0
// Helpfile: 
// DepndLst: 
//   (1) v2.0 stdole, (C:\WINDOWS\System32\stdole2.tlb)
//   (2) v4.0 StdVCL, (C:\WINDOWS\System32\STDVCL40.DLL)
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
interface

uses Windows, ActiveX, Classes, Graphics, OleServer, OleCtrls, StdVCL;

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  gsDRVMajorVersion = 1;
  gsDRVMinorVersion = 0;

  LIBID_gsDRV: TGUID = '{76B1392D-EB0B-4C92-9D14-A751CB43B3D6}';

  IID_IDitronEU200CS: TGUID = '{31A32F05-E51D-4A38-8522-F15D513CC03C}';
  CLASS_DitronEU200CS: TGUID = '{85B95C4D-6AFC-403A-8A40-D10456A92930}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IDitronEU200CS = interface;
  IDitronEU200CSDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  DitronEU200CS = IDitronEU200CS;


// *********************************************************************//
// Interface: IDitronEU200CS
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {31A32F05-E51D-4A38-8522-F15D513CC03C}
// *********************************************************************//
  IDitronEU200CS = interface(IDispatch)
    ['{31A32F05-E51D-4A38-8522-F15D513CC03C}']
    function  Open(const Options: WideString): SYSINT; safecall;
    function  Close: SYSINT; safecall;
    function  EcrCMD(const Command: WideString; out ResStr: WideString): SYSINT; safecall;
    function  Get_ResultCode: SYSINT; safecall;
    property ResultCode: SYSINT read Get_ResultCode;
  end;

// *********************************************************************//
// DispIntf:  IDitronEU200CSDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {31A32F05-E51D-4A38-8522-F15D513CC03C}
// *********************************************************************//
  IDitronEU200CSDisp = dispinterface
    ['{31A32F05-E51D-4A38-8522-F15D513CC03C}']
    function  Open(const Options: WideString): SYSINT; dispid 1;
    function  Close: SYSINT; dispid 2;
    function  EcrCMD(const Command: WideString; out ResStr: WideString): SYSINT; dispid 3;
    property ResultCode: SYSINT readonly dispid 5;
  end;

// *********************************************************************//
// The Class CoDitronEU200CS provides a Create and CreateRemote method to          
// create instances of the default interface IDitronEU200CS exposed by              
// the CoClass DitronEU200CS. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoDitronEU200CS = class
    class function Create: IDitronEU200CS;
    class function CreateRemote(const MachineName: string): IDitronEU200CS;
  end;

implementation

uses ComObj;

class function CoDitronEU200CS.Create: IDitronEU200CS;
begin
  Result := CreateComObject(CLASS_DitronEU200CS) as IDitronEU200CS;
end;

class function CoDitronEU200CS.CreateRemote(const MachineName: string): IDitronEU200CS;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_DitronEU200CS) as IDitronEU200CS;
end;

end.
