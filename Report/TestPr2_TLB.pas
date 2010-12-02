unit TestPr2_TLB;

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
// File generated on 29.12.00 15:24:07 from Type Library described below.

// ************************************************************************ //
// Type Lib: D:\GOLDEN\GEDEMIN\Report\TestPr2.tlb (1)
// IID\LCID: {B2EFC161-DB12-11D4-AE5A-006052067F0D}\0
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
  TestPr2MajorVersion = 1;
  TestPr2MinorVersion = 0;

  LIBID_TestPr2: TGUID = '{B2EFC161-DB12-11D4-AE5A-006052067F0D}';

  IID_IcoQuery: TGUID = '{EAFEA52C-DD7C-11D4-AE5D-006052067F0D}';
  CLASS_coQuery: TGUID = '{EAFEA52E-DD7C-11D4-AE5D-006052067F0D}';
  IID_IcoQueryList: TGUID = '{EAFEA530-DD7C-11D4-AE5D-006052067F0D}';
  CLASS_coQueryList: TGUID = '{EAFEA532-DD7C-11D4-AE5D-006052067F0D}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IcoQuery = interface;
  IcoQueryDisp = dispinterface;
  IcoQueryList = interface;
  IcoQueryListDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  coQuery = IcoQuery;
  coQueryList = IcoQueryList;


// *********************************************************************//
// Interface: IcoQuery
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {EAFEA52C-DD7C-11D4-AE5D-006052067F0D}
// *********************************************************************//
  IcoQuery = interface(IDispatch)
    ['{EAFEA52C-DD7C-11D4-AE5D-006052067F0D}']
    procedure Open; safecall;
    procedure Close; safecall;
    function  Get_ResultData: WordBool; safecall;
    procedure Set_ResultData(Value: WordBool); safecall;
    function  Get_SQL: WideString; safecall;
    procedure Set_SQL(const Value: WideString); safecall;
    function  Get_Eof: WordBool; safecall;
    property ResultData: WordBool read Get_ResultData write Set_ResultData;
    property SQL: WideString read Get_SQL write Set_SQL;
    property Eof: WordBool read Get_Eof;
  end;

// *********************************************************************//
// DispIntf:  IcoQueryDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {EAFEA52C-DD7C-11D4-AE5D-006052067F0D}
// *********************************************************************//
  IcoQueryDisp = dispinterface
    ['{EAFEA52C-DD7C-11D4-AE5D-006052067F0D}']
    procedure Open; dispid 1;
    procedure Close; dispid 2;
    property ResultData: WordBool dispid 3;
    property SQL: WideString dispid 4;
    property Eof: WordBool readonly dispid 5;
  end;

// *********************************************************************//
// Interface: IcoQueryList
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {EAFEA530-DD7C-11D4-AE5D-006052067F0D}
// *********************************************************************//
  IcoQueryList = interface(IDispatch)
    ['{EAFEA530-DD7C-11D4-AE5D-006052067F0D}']
    procedure AddQuery; safecall;
  end;

// *********************************************************************//
// DispIntf:  IcoQueryListDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {EAFEA530-DD7C-11D4-AE5D-006052067F0D}
// *********************************************************************//
  IcoQueryListDisp = dispinterface
    ['{EAFEA530-DD7C-11D4-AE5D-006052067F0D}']
    procedure AddQuery; dispid 1;
  end;

// *********************************************************************//
// The Class CocoQuery provides a Create and CreateRemote method to          
// create instances of the default interface IcoQuery exposed by              
// the CoClass coQuery. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CocoQuery = class
    class function Create: IcoQuery;
    class function CreateRemote(const MachineName: string): IcoQuery;
  end;

// *********************************************************************//
// The Class CocoQueryList provides a Create and CreateRemote method to          
// create instances of the default interface IcoQueryList exposed by              
// the CoClass coQueryList. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CocoQueryList = class
    class function Create: IcoQueryList;
    class function CreateRemote(const MachineName: string): IcoQueryList;
  end;

implementation

uses ComObj;

class function CocoQuery.Create: IcoQuery;
begin
  Result := CreateComObject(CLASS_coQuery) as IcoQuery;
end;

class function CocoQuery.CreateRemote(const MachineName: string): IcoQuery;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_coQuery) as IcoQuery;
end;

class function CocoQueryList.Create: IcoQueryList;
begin
  Result := CreateComObject(CLASS_coQueryList) as IcoQueryList;
end;

class function CocoQueryList.CreateRemote(const MachineName: string): IcoQueryList;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_coQueryList) as IcoQueryList;
end;

end.
