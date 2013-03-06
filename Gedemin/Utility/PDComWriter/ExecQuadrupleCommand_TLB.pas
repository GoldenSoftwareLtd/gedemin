unit ExecQuadrupleCommand_TLB;

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
// File generated on 18.09.2008 13:39:20 from Type Library described below.

// ************************************************************************  //
// Type Lib: D:\user\alexandra\COM_Objects, Devices\PDComWriter\PDComWriter.tlb (1)
// LIBID: {4F2048DB-6548-4D0F-974A-168A124ABE8E}
// LCID: 0
// Helpfile: 
// HelpString: PD Library
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
  ExecQuadrupleCommandMajorVersion = 1;
  ExecQuadrupleCommandMinorVersion = 0;

  LIBID_ExecQuadrupleCommand: TGUID = '{4F2048DB-6548-4D0F-974A-168A124ABE8E}';

  IID_IPD: TGUID = '{E559D4D8-C963-476E-A082-E9721809644C}';
  CLASS_PD: TGUID = '{88FC1EA4-A5B4-4D76-82CD-0BD33BF54246}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IPD = interface;
  IPDDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  PD = IPD;


// *********************************************************************//
// Interface: IPD
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {E559D4D8-C963-476E-A082-E9721809644C}
// *********************************************************************//
  IPD = interface(IDispatch)
    ['{E559D4D8-C963-476E-A082-E9721809644C}']
    procedure InitCOM(ComNumber: Integer; BaudRate: Integer); safecall;
    procedure ExecSingleCommand(param1: Shortint); safecall;
    procedure ExecDoubleCommand(param1: Shortint; param2: Shortint); safecall;
    procedure ExecTrippleCommand(param1: Shortint; param2: Shortint; Param3: Shortint); safecall;
    procedure PutString(const ToInput: WideString); safecall;
    procedure ExecQuadrupleCommand(param1: Shortint; param2: Shortint; Param3: Shortint; 
                                   Param4: Shortint); safecall;
  end;

// *********************************************************************//
// DispIntf:  IPDDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {E559D4D8-C963-476E-A082-E9721809644C}
// *********************************************************************//
  IPDDisp = dispinterface
    ['{E559D4D8-C963-476E-A082-E9721809644C}']
    procedure InitCOM(ComNumber: Integer; BaudRate: Integer); dispid 201;
    procedure ExecSingleCommand(param1: {??Shortint}OleVariant); dispid 202;
    procedure ExecDoubleCommand(param1: {??Shortint}OleVariant; param2: {??Shortint}OleVariant); dispid 203;
    procedure ExecTrippleCommand(param1: {??Shortint}OleVariant; param2: {??Shortint}OleVariant; 
                                 Param3: {??Shortint}OleVariant); dispid 204;
    procedure PutString(const ToInput: WideString); dispid 205;
    procedure ExecQuadrupleCommand(param1: {??Shortint}OleVariant; param2: {??Shortint}OleVariant; 
                                   Param3: {??Shortint}OleVariant; Param4: {??Shortint}OleVariant); dispid 206;
  end;

// *********************************************************************//
// The Class CoPD provides a Create and CreateRemote method to          
// create instances of the default interface IPD exposed by              
// the CoClass PD. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoPD = class
    class function Create: IPD;
    class function CreateRemote(const MachineName: string): IPD;
  end;

implementation

uses ComObj;

class function CoPD.Create: IPD;
begin
  Result := CreateComObject(CLASS_PD) as IPD;
end;

class function CoPD.CreateRemote(const MachineName: string): IPD;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_PD) as IPD;
end;

end.
