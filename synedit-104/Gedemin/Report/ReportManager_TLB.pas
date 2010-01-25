unit ReportManager_TLB;

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
// File generated on 28.May.01 19:50:54 from Type Library described below.

// ************************************************************************ //
// Type Lib: D:\GOLDEN\GEDEMIN\Report\ReportManager.tlb (1)
// IID\LCID: {36B080B1-3630-11D5-AEF9-006052067F0D}\0
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
  ReportManagerMajorVersion = 1;
  ReportManagerMinorVersion = 0;

  LIBID_ReportManager: TGUID = '{36B080B1-3630-11D5-AEF9-006052067F0D}';

  IID_ISvrMng: TGUID = '{36B080B2-3630-11D5-AEF9-006052067F0D}';
  DIID_ISvrMngEvents: TGUID = '{36B080B4-3630-11D5-AEF9-006052067F0D}';
  CLASS_SvrMng: TGUID = '{36B080B6-3630-11D5-AEF9-006052067F0D}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  ISvrMng = interface;
  ISvrMngDisp = dispinterface;
  ISvrMngEvents = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  SvrMng = ISvrMng;


// *********************************************************************//
// Interface: ISvrMng
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {36B080B2-3630-11D5-AEF9-006052067F0D}
// *********************************************************************//
  ISvrMng = interface(IDispatch)
    ['{36B080B2-3630-11D5-AEF9-006052067F0D}']
    procedure Refresh; safecall;
    procedure Rebuild; safecall;
    procedure Options; safecall;
    procedure Close; safecall;
    procedure Run; safecall;
  end;

// *********************************************************************//
// DispIntf:  ISvrMngDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {36B080B2-3630-11D5-AEF9-006052067F0D}
// *********************************************************************//
  ISvrMngDisp = dispinterface
    ['{36B080B2-3630-11D5-AEF9-006052067F0D}']
    procedure Refresh; dispid 1;
    procedure Rebuild; dispid 2;
    procedure Options; dispid 3;
    procedure Close; dispid 4;
    procedure Run; dispid 5;
  end;

// *********************************************************************//
// DispIntf:  ISvrMngEvents
// Flags:     (4096) Dispatchable
// GUID:      {36B080B4-3630-11D5-AEF9-006052067F0D}
// *********************************************************************//
  ISvrMngEvents = dispinterface
    ['{36B080B4-3630-11D5-AEF9-006052067F0D}']
    procedure ChangeState(Param1: OleVariant); dispid 1;
  end;

// *********************************************************************//
// The Class CoSvrMng provides a Create and CreateRemote method to          
// create instances of the default interface ISvrMng exposed by              
// the CoClass SvrMng. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoSvrMng = class
    class function Create: ISvrMng;
    class function CreateRemote(const MachineName: string): ISvrMng;
  end;

implementation

uses ComObj;

class function CoSvrMng.Create: ISvrMng;
begin
  Result := CreateComObject(CLASS_SvrMng) as ISvrMng;
end;

class function CoSvrMng.CreateRemote(const MachineName: string): ISvrMng;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_SvrMng) as ISvrMng;
end;

end.
