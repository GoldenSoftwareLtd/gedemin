unit TestPr_TLB;

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
// File generated on 29.12.00 14:57:01 from Type Library described below.

// ************************************************************************ //
// Type Lib: D:\GOLDEN\GEDEMIN\Report\TestPr.tlb (1)
// IID\LCID: {D6D46310-D1A6-11D4-AE53-006052067F0D}\0
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
  TestPrMajorVersion = 1;
  TestPrMinorVersion = 0;

  LIBID_TestPr: TGUID = '{D6D46310-D1A6-11D4-AE53-006052067F0D}';

  IID_IIBQueryTest: TGUID = '{D6D46311-D1A6-11D4-AE53-006052067F0D}';
  CLASS_IBQueryTest: TGUID = '{D6D46313-D1A6-11D4-AE53-006052067F0D}';
  IID_IQueryList: TGUID = '{D6D4632C-D1A6-11D4-AE53-006052067F0D}';
  CLASS_QueryList: TGUID = '{D6D4632E-D1A6-11D4-AE53-006052067F0D}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IIBQueryTest = interface;
  IIBQueryTestDisp = dispinterface;
  IQueryList = interface;
  IQueryListDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  IBQueryTest = IIBQueryTest;
  QueryList = IQueryList;


// *********************************************************************//
// Interface: IIBQueryTest
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {D6D46311-D1A6-11D4-AE53-006052067F0D}
// *********************************************************************//
  IIBQueryTest = interface(IDispatch)
    ['{D6D46311-D1A6-11D4-AE53-006052067F0D}']
    procedure Open; safecall;
    function  Get_SQL: WideString; safecall;
    procedure Set_SQL(const Value: WideString); safecall;
    procedure Close; safecall;
    function  Get_Eof: WordBool; safecall;
    property SQL: WideString read Get_SQL write Set_SQL;
    property Eof: WordBool read Get_Eof;
  end;

// *********************************************************************//
// DispIntf:  IIBQueryTestDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {D6D46311-D1A6-11D4-AE53-006052067F0D}
// *********************************************************************//
  IIBQueryTestDisp = dispinterface
    ['{D6D46311-D1A6-11D4-AE53-006052067F0D}']
    procedure Open; dispid 1;
    property SQL: WideString dispid 2;
    procedure Close; dispid 4;
    property Eof: WordBool readonly dispid 6;
  end;

// *********************************************************************//
// Interface: IQueryList
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {D6D4632C-D1A6-11D4-AE53-006052067F0D}
// *********************************************************************//
  IQueryList = interface(IDispatch)
    ['{D6D4632C-D1A6-11D4-AE53-006052067F0D}']
    procedure AddQuery; safecall;
    procedure DeleteQuery(Index: Integer); safecall;
    function  Get_Query(Index: Integer): IIBQueryTest; safecall;
    procedure Set_Query(Index: Integer; const Value: IIBQueryTest); safecall;
    function  Get_Count: Integer; safecall;
    procedure Clear; safecall;
    function  Get_ResultIndex: Integer; safecall;
    procedure Set_ResultIndex(AnIndex: Integer); safecall;
    property Query[Index: Integer]: IIBQueryTest read Get_Query write Set_Query;
    property Count: Integer read Get_Count;
    property ResultIndex: Integer read Get_ResultIndex write Set_ResultIndex;
  end;

// *********************************************************************//
// DispIntf:  IQueryListDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {D6D4632C-D1A6-11D4-AE53-006052067F0D}
// *********************************************************************//
  IQueryListDisp = dispinterface
    ['{D6D4632C-D1A6-11D4-AE53-006052067F0D}']
    procedure AddQuery; dispid 1;
    procedure DeleteQuery(Index: Integer); dispid 2;
    property Query[Index: Integer]: IIBQueryTest dispid 4;
    property Count: Integer readonly dispid 3;
    procedure Clear; dispid 5;
    property ResultIndex: Integer dispid 6;
  end;

// *********************************************************************//
// The Class CoIBQueryTest provides a Create and CreateRemote method to          
// create instances of the default interface IIBQueryTest exposed by              
// the CoClass IBQueryTest. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoIBQueryTest = class
    class function Create: IIBQueryTest;
    class function CreateRemote(const MachineName: string): IIBQueryTest;
  end;

// *********************************************************************//
// The Class CoQueryList provides a Create and CreateRemote method to          
// create instances of the default interface IQueryList exposed by              
// the CoClass QueryList. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoQueryList = class
    class function Create: IQueryList;
    class function CreateRemote(const MachineName: string): IQueryList;
  end;

implementation

uses ComObj;

class function CoIBQueryTest.Create: IIBQueryTest;
begin
  Result := CreateComObject(CLASS_IBQueryTest) as IIBQueryTest;
end;

class function CoIBQueryTest.CreateRemote(const MachineName: string): IIBQueryTest;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_IBQueryTest) as IIBQueryTest;
end;

class function CoQueryList.Create: IQueryList;
begin
  Result := CreateComObject(CLASS_QueryList) as IQueryList;
end;

class function CoQueryList.CreateRemote(const MachineName: string): IQueryList;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_QueryList) as IQueryList;
end;

end.
