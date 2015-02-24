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
// File generated on 26.06.2003 9:41:24 from Type Library described below.

// ************************************************************************ //
// Type Lib: D:\Golden\DrvCass\CassT15.tlb (1)
// IID\LCID: {D974749C-B6C5-47AF-BC5B-3ACC39E6D251}\0
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

  LIBID_gsDRV: TGUID = '{D974749C-B6C5-47AF-BC5B-3ACC39E6D251}';

  IID_IScale15T: TGUID = '{EA392E13-DF9C-4CA4-8F80-81F5BC7A254A}';
  CLASS_Scale15T: TGUID = '{472B14BA-674B-4DD1-A9AF-20CA63E9834E}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IScale15T = interface;
  IScale15TDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  Scale15T = IScale15T;


// *********************************************************************//
// Declaration of structures, unions and aliases.                         
// *********************************************************************//
  POleVariant1 = ^OleVariant; {*}


// *********************************************************************//
// Interface: IScale15T
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {EA392E13-DF9C-4CA4-8F80-81F5BC7A254A}
// *********************************************************************//
  IScale15T = interface(IDispatch)
    ['{EA392E13-DF9C-4CA4-8F80-81F5BC7A254A}']
    function  Get_PortNumber: Smallint; safecall;
    procedure Set_PortNumber(Value: Smallint); safecall;
    function  Get_BaudRate: Smallint; safecall;
    procedure Set_BaudRate(Value: Smallint); safecall;
    procedure AboutBox; safecall;
    function  Get_Protocol: Smallint; safecall;
    procedure Set_Protocol(Value: Smallint); safecall;
    function  Get_Weight: Double; safecall;
    function  Get_LabelParams: WideString; safecall;
    function  GetPLUInfo(out Name1: OleVariant; out Name2: OleVariant; out Cost: OleVariant; 
                         out Code: OleVariant; var PLU: OleVariant): OleVariant; safecall;
    function  SetPLUInfo(var Name1: OleVariant; var Name2: OleVariant; var Cost: OleVariant; 
                         var Code: OleVariant; var PLU: OleVariant): OleVariant; safecall;
    function  GetAddPLUInfo(var PLU: OleVariant): OleVariant; safecall;
    function  Get_PortEnabled: WordBool; safecall;
    procedure Set_PortEnabled(Value: WordBool); safecall;
    function  GetKeys(var Keys: OleVariant): OleVariant; safecall;
    function  SetKeys(var Keys: OleVariant): OleVariant; safecall;
    property PortNumber: Smallint read Get_PortNumber write Set_PortNumber;
    property BaudRate: Smallint read Get_BaudRate write Set_BaudRate;
    property Protocol: Smallint read Get_Protocol write Set_Protocol;
    property Weight: Double read Get_Weight;
    property LabelParams: WideString read Get_LabelParams;
    property PortEnabled: WordBool read Get_PortEnabled write Set_PortEnabled;
  end;

// *********************************************************************//
// DispIntf:  IScale15TDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {EA392E13-DF9C-4CA4-8F80-81F5BC7A254A}
// *********************************************************************//
  IScale15TDisp = dispinterface
    ['{EA392E13-DF9C-4CA4-8F80-81F5BC7A254A}']
    property PortNumber: Smallint dispid 1;
    property BaudRate: Smallint dispid 2;
    procedure AboutBox; dispid 3;
    property Protocol: Smallint dispid 4;
    property Weight: Double readonly dispid 5;
    property LabelParams: WideString readonly dispid 6;
    function  GetPLUInfo(out Name1: OleVariant; out Name2: OleVariant; out Cost: OleVariant; 
                         out Code: OleVariant; var PLU: OleVariant): OleVariant; dispid 8;
    function  SetPLUInfo(var Name1: OleVariant; var Name2: OleVariant; var Cost: OleVariant; 
                         var Code: OleVariant; var PLU: OleVariant): OleVariant; dispid 9;
    function  GetAddPLUInfo(var PLU: OleVariant): OleVariant; dispid 7;
    property PortEnabled: WordBool dispid 10;
    function  GetKeys(var Keys: OleVariant): OleVariant; dispid 11;
    function  SetKeys(var Keys: OleVariant): OleVariant; dispid 12;
  end;

// *********************************************************************//
// The Class CoScale15T provides a Create and CreateRemote method to          
// create instances of the default interface IScale15T exposed by              
// the CoClass Scale15T. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoScale15T = class
    class function Create: IScale15T;
    class function CreateRemote(const MachineName: string): IScale15T;
  end;

implementation

uses ComObj;

class function CoScale15T.Create: IScale15T;
begin
  Result := CreateComObject(CLASS_Scale15T) as IScale15T;
end;

class function CoScale15T.CreateRemote(const MachineName: string): IScale15T;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_Scale15T) as IScale15T;
end;

end.
