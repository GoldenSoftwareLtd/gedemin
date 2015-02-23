unit TestProperty_TLB;

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
// File generated on 11.01.02 20:15:09 from Type Library described below.

// ************************************************************************ //
// Type Lib: D:\GOLDEN\GEDEMIN\Property\TestProperty.tlb (1)
// IID\LCID: {6E7822F2-D843-11D5-B62A-00C0DF0E09D1}\0
// Helpfile: 
// DepndLst: 
//   (1) v2.0 stdole, (C:\WINNT4\System32\stdole2.tlb)
//   (2) v4.0 StdVCL, (C:\WINNT4\System32\STDVCL40.DLL)
//   (3) v1.0 Gedemin, (z:\gedemin.exe)
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
interface

uses Windows, ActiveX, Classes, Graphics, OleServer, OleCtrls, StdVCL, 
  Gedemin_TLB;

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  TestPropertyMajorVersion = 1;
  TestPropertyMinorVersion = 0;

  LIBID_TestProperty: TGUID = '{6E7822F2-D843-11D5-B62A-00C0DF0E09D1}';

  IID_IBaseClass: TGUID = '{6E7822F3-D843-11D5-B62A-00C0DF0E09D1}';
  DIID_IBaseClassEvents: TGUID = '{6E7822F5-D843-11D5-B62A-00C0DF0E09D1}';
  CLASS_oleBaseClass: TGUID = '{6E7822F7-D843-11D5-B62A-00C0DF0E09D1}';
  IID_ITwoClass: TGUID = '{6E782300-D843-11D5-B62A-00C0DF0E09D1}';
  CLASS_oleTwoClass: TGUID = '{6E782302-D843-11D5-B62A-00C0DF0E09D1}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IBaseClass = interface;
  IBaseClassDisp = dispinterface;
  IBaseClassEvents = dispinterface;
  ITwoClass = interface;
  ITwoClassDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  oleBaseClass = IBaseClass;
  oleTwoClass = ITwoClass;


// *********************************************************************//
// Interface: IBaseClass
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {6E7822F3-D843-11D5-B62A-00C0DF0E09D1}
// *********************************************************************//
  IBaseClass = interface(IDispatch)
    ['{6E7822F3-D843-11D5-B62A-00C0DF0E09D1}']
    procedure Method1; safecall;
    procedure Method2; safecall;
    procedure Method3; safecall;
    procedure Method11(Param1: Integer); safecall;
  end;

// *********************************************************************//
// DispIntf:  IBaseClassDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {6E7822F3-D843-11D5-B62A-00C0DF0E09D1}
// *********************************************************************//
  IBaseClassDisp = dispinterface
    ['{6E7822F3-D843-11D5-B62A-00C0DF0E09D1}']
    procedure Method1; dispid 1;
    procedure Method2; dispid 2;
    procedure Method3; dispid 3;
    procedure Method11(Param1: Integer); dispid 6;
  end;

// *********************************************************************//
// DispIntf:  IBaseClassEvents
// Flags:     (4096) Dispatchable
// GUID:      {6E7822F5-D843-11D5-B62A-00C0DF0E09D1}
// *********************************************************************//
  IBaseClassEvents = dispinterface
    ['{6E7822F5-D843-11D5-B62A-00C0DF0E09D1}']
  end;

// *********************************************************************//
// Interface: ITwoClass
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {6E782300-D843-11D5-B62A-00C0DF0E09D1}
// *********************************************************************//
  ITwoClass = interface(IBaseClass)
    ['{6E782300-D843-11D5-B62A-00C0DF0E09D1}']
    procedure Method4; safecall;
    procedure Method5; safecall;
  end;

// *********************************************************************//
// DispIntf:  ITwoClassDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {6E782300-D843-11D5-B62A-00C0DF0E09D1}
// *********************************************************************//
  ITwoClassDisp = dispinterface
    ['{6E782300-D843-11D5-B62A-00C0DF0E09D1}']
    procedure Method4; dispid 4;
    procedure Method5; dispid 5;
    procedure Method1; dispid 1;
    procedure Method2; dispid 2;
    procedure Method3; dispid 3;
    procedure Method11(Param1: Integer); dispid 6;
  end;

// *********************************************************************//
// The Class CooleBaseClass provides a Create and CreateRemote method to          
// create instances of the default interface IBaseClass exposed by              
// the CoClass oleBaseClass. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CooleBaseClass = class
    class function Create: IBaseClass;
    class function CreateRemote(const MachineName: string): IBaseClass;
  end;

// *********************************************************************//
// The Class CooleTwoClass provides a Create and CreateRemote method to          
// create instances of the default interface ITwoClass exposed by              
// the CoClass oleTwoClass. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CooleTwoClass = class
    class function Create: ITwoClass;
    class function CreateRemote(const MachineName: string): ITwoClass;
  end;

implementation

uses ComObj;

class function CooleBaseClass.Create: IBaseClass;
begin
  Result := CreateComObject(CLASS_oleBaseClass) as IBaseClass;
end;

class function CooleBaseClass.CreateRemote(const MachineName: string): IBaseClass;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_oleBaseClass) as IBaseClass;
end;

class function CooleTwoClass.Create: ITwoClass;
begin
  Result := CreateComObject(CLASS_oleTwoClass) as ITwoClass;
end;

class function CooleTwoClass.CreateRemote(const MachineName: string): ITwoClass;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_oleTwoClass) as ITwoClass;
end;

end.
