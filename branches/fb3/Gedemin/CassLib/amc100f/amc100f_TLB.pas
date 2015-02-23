unit amc100f_TLB;

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
// File generated on 05.10.2004 9:16:07 from Type Library described below.

// ************************************************************************ //
// Type Lib: C:\Program Files\Borland\Delphi5\Projects\amc100f\amc100f.tlb (1)
// IID\LCID: {4B6E0A3B-C4E9-4F03-9A00-7E573F2101C2}\0
// Helpfile: 
// DepndLst: 
//   (1) v2.0 stdole, (C:\WIN2000\System32\stdole2.tlb)
//   (2) v4.0 StdVCL, (C:\WIN2000\System32\STDVCL40.DLL)
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
  amc100fMajorVersion = 1;
  amc100fMinorVersion = 0;

  LIBID_amc100f: TGUID = '{4B6E0A3B-C4E9-4F03-9A00-7E573F2101C2}';

  IID_ITAMC100F: TGUID = '{4AB74B7B-F8B6-49A1-9B9B-65EA29EED6F2}';
  CLASS_TAMC100F: TGUID = '{417D117D-4979-418B-AC17-9467F3263DC6}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  ITAMC100F = interface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  TAMC100F = ITAMC100F;


// *********************************************************************//
// Interface: ITAMC100F
// Flags:     (256) OleAutomation
// GUID:      {4AB74B7B-F8B6-49A1-9B9B-65EA29EED6F2}
// *********************************************************************//
  ITAMC100F = interface(IUnknown)
    ['{4AB74B7B-F8B6-49A1-9B9B-65EA29EED6F2}']
    function  ConnectECR(Port: SYSINT; NetNum: SYSINT): HResult; stdcall;
    procedure DisconnectECR; stdcall;
    function  AddSale(const Name: WideString; Price: Double; Quantity: Double; Section: SYSINT): HResult; stdcall;
    procedure PrintCheck; stdcall;
    procedure ClearSales; stdcall;
  end;

// *********************************************************************//
// The Class CoTAMC100F provides a Create and CreateRemote method to          
// create instances of the default interface ITAMC100F exposed by              
// the CoClass TAMC100F. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoTAMC100F = class
    class function Create: ITAMC100F;
    class function CreateRemote(const MachineName: string): ITAMC100F;
  end;

implementation

uses ComObj;

class function CoTAMC100F.Create: ITAMC100F;
begin
  Result := CreateComObject(CLASS_TAMC100F) as ITAMC100F;
end;

class function CoTAMC100F.CreateRemote(const MachineName: string): ITAMC100F;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_TAMC100F) as ITAMC100F;
end;

end.
