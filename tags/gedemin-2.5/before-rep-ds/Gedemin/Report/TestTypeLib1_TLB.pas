unit TestTypeLib1_TLB;

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
// File generated on 20.02.01 11:57:52 from Type Library described below.

// ************************************************************************ //
// Type Lib: D:\GOLDEN\GEDEMIN\Report\TypeLib1.tlb (1)
// IID\LCID: {46E0072B-070B-11D5-AE92-006052067F0D}\0
// Helpfile: 
// DepndLst: 
//   (1) v2.0 stdole, (C:\WINNT\System32\StdOle2.Tlb)
//   (2) v4.0 StdVCL, (C:\WINNT\System32\STDVCL40.DLL)
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
  TestTypeLib1MajorVersion = 1;
  TestTypeLib1MinorVersion = 0;

  LIBID_TestTypeLib1: TGUID = '{46E0072B-070B-11D5-AE92-006052067F0D}';

  IID_InterfaceTest: TGUID = '{46E0072C-070B-11D5-AE92-006052067F0D}';
  CLASS_CoClassTest: TGUID = '{46E0072E-070B-11D5-AE92-006052067F0D}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  InterfaceTest = interface;
  InterfaceTestDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  CoClassTest = InterfaceTest;


// *********************************************************************//
// Interface: InterfaceTest
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {46E0072C-070B-11D5-AE92-006052067F0D}
// *********************************************************************//
  InterfaceTest = interface(IDispatch)
    ['{46E0072C-070B-11D5-AE92-006052067F0D}']
    procedure MethodTest; safecall;
  end;

// *********************************************************************//
// DispIntf:  InterfaceTestDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {46E0072C-070B-11D5-AE92-006052067F0D}
// *********************************************************************//
  InterfaceTestDisp = dispinterface
    ['{46E0072C-070B-11D5-AE92-006052067F0D}']
    procedure MethodTest; dispid 1;
  end;

// *********************************************************************//
// The Class CoCoClassTest provides a Create and CreateRemote method to          
// create instances of the default interface InterfaceTest exposed by              
// the CoClass CoClassTest. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoCoClassTest = class
    class function Create: InterfaceTest;
    class function CreateRemote(const MachineName: string): InterfaceTest;
  end;

implementation

uses ComObj;

class function CoCoClassTest.Create: InterfaceTest;
begin
  Result := CreateComObject(CLASS_CoClassTest) as InterfaceTest;
end;

class function CoCoClassTest.CreateRemote(const MachineName: string): InterfaceTest;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_CoClassTest) as InterfaceTest;
end;

end.
