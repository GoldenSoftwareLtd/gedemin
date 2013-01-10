unit IBReplicator_TLB;

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
// File generated on 15.01.2004 19:27:01 from Type Library described below.

// ************************************************************************  //
// Type Lib: D:\PROJECTS\delphi\IBReplicator\IBReplicator.tlb (1)
// LIBID: {0C02D2BA-1358-4621-9B3B-12C5E1098735}
// LCID: 0
// Helpfile: 
// HelpString: IBReplicator Library
// DepndLst: 
//   (1) v2.0 stdole, (C:\WIN2000\System32\stdole2.tlb)
//   (2) v1.0 SCARDSSPLib, (C:\WIN2000\System32\scardssp.dll)
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
interface

uses Windows, ActiveX, Classes, Graphics, SCARDSSPLib_TLB, StdVCL, Variants;
  

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  IBReplicatorMajorVersion = 1;
  IBReplicatorMinorVersion = 0;

  LIBID_IBReplicator: TGUID = '{0C02D2BA-1358-4621-9B3B-12C5E1098735}';

  IID_IIBReplicator: TGUID = '{F552C3B1-3DFD-4085-B2B4-6B5955E66457}';
  CLASS_IBReplicator_: TGUID = '{D22AABE3-1F98-4166-A2CE-2CAA8111CB9E}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IIBReplicator = interface;
  IIBReplicatorDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  IBReplicator_ = IIBReplicator;


// *********************************************************************//
// Interface: IIBReplicator
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {F552C3B1-3DFD-4085-B2B4-6B5955E66457}
// *********************************************************************//
  IIBReplicator = interface(IDispatch)
    ['{F552C3B1-3DFD-4085-B2B4-6B5955E66457}']
    procedure Connect(const ServerName: WideString; const FileName: WideString; 
                      const Protocol: WideString; const UserName: WideString; 
                      const Password: WideString; const CharSet: WideString; 
                      const Role: WideString; const Additinal: WideString); safecall;
    procedure ImportData(const Stream: IStream; SaveErrorToManualLog: WordBool); safecall;
    procedure ExportData(const Stream: IStream; CorDBKey: Integer); safecall;
  end;

// *********************************************************************//
// DispIntf:  IIBReplicatorDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {F552C3B1-3DFD-4085-B2B4-6B5955E66457}
// *********************************************************************//
  IIBReplicatorDisp = dispinterface
    ['{F552C3B1-3DFD-4085-B2B4-6B5955E66457}']
    procedure Connect(const ServerName: WideString; const FileName: WideString; 
                      const Protocol: WideString; const UserName: WideString; 
                      const Password: WideString; const CharSet: WideString; 
                      const Role: WideString; const Additinal: WideString); dispid 201;
    procedure ImportData(const Stream: IStream; SaveErrorToManualLog: WordBool); dispid 202;
    procedure ExportData(const Stream: IStream; CorDBKey: Integer); dispid 203;
  end;

// *********************************************************************//
// The Class CoIBReplicator_ provides a Create and CreateRemote method to          
// create instances of the default interface IIBReplicator exposed by              
// the CoClass IBReplicator_. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoIBReplicator_ = class
    class function Create: IIBReplicator;
    class function CreateRemote(const MachineName: string): IIBReplicator;
  end;

implementation

uses ComObj;

class function CoIBReplicator_.Create: IIBReplicator;
begin
  Result := CreateComObject(CLASS_IBReplicator_) as IIBReplicator;
end;

class function CoIBReplicator_.CreateRemote(const MachineName: string): IIBReplicator;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_IBReplicator_) as IIBReplicator;
end;

end.
