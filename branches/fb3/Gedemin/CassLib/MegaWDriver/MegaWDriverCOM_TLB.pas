unit MegaWDriverCOM_TLB;

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

// PASTLWTR : 1.2
// File generated on 04.11.2006 19:55:42 from Type Library described below.

// ************************************************************************  //
// Type Lib: D:\golden\GEDEMIN\CassLib\MegaWDriver\MegaWDriverCOM.tlb (1)
// LIBID: {1BBEEDAA-28F2-4C22-B35C-FE4147C23D5D}
// LCID: 0
// Helpfile: 
// HelpString: MegaWDriverCOM Library
// DepndLst: 
//   (1) v2.0 stdole, (C:\WINDOWS\system32\STDOLE2.TLB)
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
interface

uses Windows, ActiveX, Classes, Graphics, StdVCL, Variants;
  

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  MegaWDriverCOMMajorVersion = 1;
  MegaWDriverCOMMinorVersion = 0;

  LIBID_MegaWDriverCOM: TGUID = '{1BBEEDAA-28F2-4C22-B35C-FE4147C23D5D}';

  IID_IMegaWDriver: TGUID = '{180A31E7-3856-452F-8334-5113C5A52F98}';
  CLASS_MegaWDriver: TGUID = '{760EE10E-CA55-434E-B9A2-86C7DCB43A87}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IMegaWDriver = interface;
  IMegaWDriverDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  MegaWDriver = IMegaWDriver;


// *********************************************************************//
// Declaration of structures, unions and aliases.                         
// *********************************************************************//
  POleVariant1 = ^OleVariant; {*}


// *********************************************************************//
// Interface: IMegaWDriver
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {180A31E7-3856-452F-8334-5113C5A52F98}
// *********************************************************************//
  IMegaWDriver = interface(IDispatch)
    ['{180A31E7-3856-452F-8334-5113C5A52F98}']
    function FrWConnect: SYSINT; safecall;
    function FrWLogIn(const pszPw: WideString; Mode: SYSINT): SYSINT; safecall;
    function FrWLogOut: SYSINT; safecall;
    function FrWCutReceipt: SYSINT; safecall;
    function FrWFeed(Count: SYSINT): SYSINT; safecall;
    function FrWOpenDrawer: SYSINT; safecall;
    function FrWPrintData(const strDate: WideString): SYSINT; safecall;
    function FrWCreateDoc(DocType: Shortint; Slip: SYSINT; fLinePrn: WordBool; 
                          const pathOne: WideString; const pathTwo: WideString): SYSINT; safecall;
    function FrWCreateDocCopy(DocType: Shortint; const serialKSA: WideString; DateTime: TDateTime; 
                              lRcptNo: Integer; Slip: SYSINT; fLinePrn: WordBool; 
                              const pathOne: WideString; const pathTwo: WideString): SYSINT; safecall;
    function FrWAddItem(Dept: Shortint; Quantity: Currency; Price: Currency; 
                        const Code: WideString; const pszName: WideString; 
                        const pszComment: WideString; out Cost: OleVariant; 
                        out iStrCheck: OleVariant): SYSINT; safecall;
    function FrWAdjustment(fPercent: Byte; Summ: Currency; DocFlag: Byte; var RealSumm: OleVariant; 
                           var TotalSumm: OleVariant): SYSINT; safecall;
    function FrWTax(IdTax: Byte; fInclude: WordBool; DocFlag: Byte; var Summ: OleVariant; 
                    var TotalSumm: OleVariant): SYSINT; safecall;
    function FrWCancelItem(ItemNo: SYSINT; pSumm: Currency): SYSINT; safecall;
    function FrWTotal(var Summ: OleVariant): SYSINT; safecall;
    function FrWPrintAdvItem(const strType: WideString; const strValue: WideString): SYSINT; safecall;
    function FrWPayment(var Summ: OleVariant): SYSINT; safecall;
    function FrWPrintReport(TypeRep: SYSINT): SYSINT; safecall;
    function FrWCancelReceipt: SYSINT; safecall;
  end;

// *********************************************************************//
// DispIntf:  IMegaWDriverDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {180A31E7-3856-452F-8334-5113C5A52F98}
// *********************************************************************//
  IMegaWDriverDisp = dispinterface
    ['{180A31E7-3856-452F-8334-5113C5A52F98}']
    function FrWConnect: SYSINT; dispid 201;
    function FrWLogIn(const pszPw: WideString; Mode: SYSINT): SYSINT; dispid 202;
    function FrWLogOut: SYSINT; dispid 203;
    function FrWCutReceipt: SYSINT; dispid 204;
    function FrWFeed(Count: SYSINT): SYSINT; dispid 205;
    function FrWOpenDrawer: SYSINT; dispid 206;
    function FrWPrintData(const strDate: WideString): SYSINT; dispid 207;
    function FrWCreateDoc(DocType: {??Shortint}OleVariant; Slip: SYSINT; fLinePrn: WordBool; 
                          const pathOne: WideString; const pathTwo: WideString): SYSINT; dispid 209;
    function FrWCreateDocCopy(DocType: {??Shortint}OleVariant; const serialKSA: WideString; 
                              DateTime: TDateTime; lRcptNo: Integer; Slip: SYSINT; 
                              fLinePrn: WordBool; const pathOne: WideString; 
                              const pathTwo: WideString): SYSINT; dispid 208;
    function FrWAddItem(Dept: {??Shortint}OleVariant; Quantity: Currency; Price: Currency; 
                        const Code: WideString; const pszName: WideString; 
                        const pszComment: WideString; out Cost: OleVariant; 
                        out iStrCheck: OleVariant): SYSINT; dispid 210;
    function FrWAdjustment(fPercent: Byte; Summ: Currency; DocFlag: Byte; var RealSumm: OleVariant; 
                           var TotalSumm: OleVariant): SYSINT; dispid 211;
    function FrWTax(IdTax: Byte; fInclude: WordBool; DocFlag: Byte; var Summ: OleVariant; 
                    var TotalSumm: OleVariant): SYSINT; dispid 212;
    function FrWCancelItem(ItemNo: SYSINT; pSumm: Currency): SYSINT; dispid 213;
    function FrWTotal(var Summ: OleVariant): SYSINT; dispid 214;
    function FrWPrintAdvItem(const strType: WideString; const strValue: WideString): SYSINT; dispid 215;
    function FrWPayment(var Summ: OleVariant): SYSINT; dispid 216;
    function FrWPrintReport(TypeRep: SYSINT): SYSINT; dispid 217;
    function FrWCancelReceipt: SYSINT; dispid 218;
  end;

// *********************************************************************//
// The Class CoMegaWDriver provides a Create and CreateRemote method to          
// create instances of the default interface IMegaWDriver exposed by              
// the CoClass MegaWDriver. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoMegaWDriver = class
    class function Create: IMegaWDriver;
    class function CreateRemote(const MachineName: string): IMegaWDriver;
  end;

implementation

uses ComObj;

class function CoMegaWDriver.Create: IMegaWDriver;
begin
  Result := CreateComObject(CLASS_MegaWDriver) as IMegaWDriver;
end;

class function CoMegaWDriver.CreateRemote(const MachineName: string): IMegaWDriver;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_MegaWDriver) as IMegaWDriver;
end;

end.
