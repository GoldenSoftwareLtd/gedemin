unit Pos7300Command_TLB;

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
// File generated on 20.03.2007 19:14:35 from Type Library described below.

// ************************************************************************  //
// Type Lib: D:\golden\GEDEMIN\CassLib\FlyTech P07303\Pos7300Command.tlb (1)
// LIBID: {2ABE6B8C-EB2E-4529-852C-35E3FE17AB20}
// LCID: 0
// Helpfile: 
// HelpString: Pos7300Command Library
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
  Pos7300CommandMajorVersion = 1;
  Pos7300CommandMinorVersion = 0;

  LIBID_Pos7300Command: TGUID = '{2ABE6B8C-EB2E-4529-852C-35E3FE17AB20}';

  IID_IPos7300COM: TGUID = '{9E91C59C-886D-4848-8CD3-E4CAAE95098E}';
  CLASS_Pos7300COM: TGUID = '{8405946E-422F-4746-BEC9-EC9A835EA47C}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IPos7300COM = interface;
  IPos7300COMDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  Pos7300COM = IPos7300COM;


// *********************************************************************//
// Interface: IPos7300COM
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {9E91C59C-886D-4848-8CD3-E4CAAE95098E}
// *********************************************************************//
  IPos7300COM = interface(IDispatch)
    ['{9E91C59C-886D-4848-8CD3-E4CAAE95098E}']
    procedure ClearScreen; safecall;
    procedure MoveMostLeft; safecall;
    procedure ExecuteSelfTest; safecall;
    procedure PutString(const ToInput: WideString); safecall;
    procedure HorizontalScroll; safecall;
    procedure VerticalScroll; safecall;
    procedure OwerwriteMode; safecall;
    procedure ClearLine; safecall;
    procedure MoveMostRight; safecall;
    procedure BackSpace; safecall;
    procedure Up; safecall;
    procedure Down; safecall;
    procedure Left; safecall;
    procedure Right; safecall;
    procedure CarriageReturn; safecall;
    procedure MoveTo(x: Shortint; y: Shortint); safecall;
  end;

// *********************************************************************//
// DispIntf:  IPos7300COMDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {9E91C59C-886D-4848-8CD3-E4CAAE95098E}
// *********************************************************************//
  IPos7300COMDisp = dispinterface
    ['{9E91C59C-886D-4848-8CD3-E4CAAE95098E}']
    procedure ClearScreen; dispid 202;
    procedure MoveMostLeft; dispid 203;
    procedure ExecuteSelfTest; dispid 201;
    procedure PutString(const ToInput: WideString); dispid 204;
    procedure HorizontalScroll; dispid 205;
    procedure VerticalScroll; dispid 206;
    procedure OwerwriteMode; dispid 207;
    procedure ClearLine; dispid 208;
    procedure MoveMostRight; dispid 209;
    procedure BackSpace; dispid 210;
    procedure Up; dispid 211;
    procedure Down; dispid 212;
    procedure Left; dispid 213;
    procedure Right; dispid 214;
    procedure CarriageReturn; dispid 215;
    procedure MoveTo(x: {??Shortint}OleVariant; y: {??Shortint}OleVariant); dispid 216;
  end;

// *********************************************************************//
// The Class CoPos7300COM provides a Create and CreateRemote method to          
// create instances of the default interface IPos7300COM exposed by              
// the CoClass Pos7300COM. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoPos7300COM = class
    class function Create: IPos7300COM;
    class function CreateRemote(const MachineName: string): IPos7300COM;
  end;

implementation

uses ComObj;

class function CoPos7300COM.Create: IPos7300COM;
begin
  Result := CreateComObject(CLASS_Pos7300COM) as IPos7300COM;
end;

class function CoPos7300COM.CreateRemote(const MachineName: string): IPos7300COM;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_Pos7300COM) as IPos7300COM;
end;

end.
