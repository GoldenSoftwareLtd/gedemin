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
// File generated on 06.10.2004 14:19:58 from Type Library described below.

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
  gsDRVMajorVersion = 1;
  gsDRVMinorVersion = 0;

  LIBID_gsDRV: TGUID = '{4B6E0A3B-C4E9-4F03-9A00-7E573F2101C2}';

  IID_ITAMC100F: TGUID = '{9D61D576-4D9D-4773-AE6F-6400F6DEAC04}';
  CLASS_TAMC100F: TGUID = '{C4A6DEF3-923D-46C7-B5A5-CC4030309587}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  ITAMC100F = interface;
  ITAMC100FDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  TAMC100F = ITAMC100F;


// *********************************************************************//
// Interface: ITAMC100F
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {9D61D576-4D9D-4773-AE6F-6400F6DEAC04}
// *********************************************************************//
  ITAMC100F = interface(IDispatch)
    ['{9D61D576-4D9D-4773-AE6F-6400F6DEAC04}']
    function  Connect(Port: SYSINT; NetNum: SYSINT): SYSINT; safecall;
    procedure Disconnect; safecall;
    function  AddSale(const Name: WideString; Price: Double; Quantity: Double; Section: SYSINT): SYSINT; safecall;
    function  PrintCheck: SYSINT; safecall;
    procedure ClearSales; safecall;
    function  GetErrorMessage: WideString; safecall;
    procedure SetSupplierCode(const Code: WideString); safecall;
    function  ClearDisplay: SYSINT; safecall;
    function  Get_CashSum: Double; safecall;
    procedure Set_CashSum(Value: Double); safecall;
    function  Get_CheckSum: Double; safecall;
    function  Get_ClearBufMode: SYSINT; safecall;
    procedure Set_ClearBufMode(Value: SYSINT); safecall;
    function  Get_CreditMode: SYSINT; safecall;
    procedure Set_CreditMode(Value: SYSINT); safecall;
    function  Get_ReturnMode: SYSINT; safecall;
    procedure Set_ReturnMode(Value: SYSINT); safecall;
    procedure BringSum(Sum: Double); safecall;
    procedure RemoveSum(Sum: Double); safecall;
    function  GetErrorCode: SYSINT; safecall;
    function  GetCashSum: Double; safecall;
    property CashSum: Double read Get_CashSum write Set_CashSum;
    property CheckSum: Double read Get_CheckSum;
    property ClearBufMode: SYSINT read Get_ClearBufMode write Set_ClearBufMode;
    property CreditMode: SYSINT read Get_CreditMode write Set_CreditMode;
    property ReturnMode: SYSINT read Get_ReturnMode write Set_ReturnMode;
  end;

// *********************************************************************//
// DispIntf:  ITAMC100FDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {9D61D576-4D9D-4773-AE6F-6400F6DEAC04}
// *********************************************************************//
  ITAMC100FDisp = dispinterface
    ['{9D61D576-4D9D-4773-AE6F-6400F6DEAC04}']
    function  Connect(Port: SYSINT; NetNum: SYSINT): SYSINT; dispid 1;
    procedure Disconnect; dispid 2;
    function  AddSale(const Name: WideString; Price: Double; Quantity: Double; Section: SYSINT): SYSINT; dispid 3;
    function  PrintCheck: SYSINT; dispid 4;
    procedure ClearSales; dispid 5;
    function  GetErrorMessage: WideString; dispid 6;
    procedure SetSupplierCode(const Code: WideString); dispid 7;
    function  ClearDisplay: SYSINT; dispid 9;
    property CashSum: Double dispid 10;
    property CheckSum: Double readonly dispid 8;
    property ClearBufMode: SYSINT dispid 11;
    property CreditMode: SYSINT dispid 12;
    property ReturnMode: SYSINT dispid 13;
    procedure BringSum(Sum: Double); dispid 14;
    procedure RemoveSum(Sum: Double); dispid 15;
    function  GetErrorCode: SYSINT; dispid 16;
    function  GetCashSum: Double; dispid 17;
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
