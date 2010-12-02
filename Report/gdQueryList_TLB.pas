unit gdQueryList_TLB;

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
// File generated on 20.02.01 13:16:51 from Type Library described below.

// ************************************************************************ //
// Type Lib: D:\GOLDEN\GEDEMIN\Report\ReportClient.exe (1)
// IID\LCID: {7B5C2EE1-E56D-11D4-AE62-006052067F0D}\0
// Helpfile: 
// DepndLst: 
//   (1) v2.0 stdole, (C:\WINNT\System32\StdOle2.Tlb)
// Parent TypeLibrary:
//   (0) v1.0 ReportServer, (D:\GOLDEN\GEDEMIN\Report\ReportServer.tlb)
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
  gdQueryListMajorVersion = 1;
  gdQueryListMinorVersion = 0;

  LIBID_gdQueryList: TGUID = '{7B5C2EE1-E56D-11D4-AE62-006052067F0D}';

  IID_IgsField: TGUID = '{7B5C2EE8-E56D-11D4-AE62-006052067F0D}';
  IID_IgsQuery: TGUID = '{7B5C2EE6-E56D-11D4-AE62-006052067F0D}';
  IID_IgsQueryList: TGUID = '{7B5C2EE2-E56D-11D4-AE62-006052067F0D}';
  CLASS_QueryList: TGUID = '{7B5C2EE4-E56D-11D4-AE62-006052067F0D}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IgsField = interface;
  IgsFieldDisp = dispinterface;
  IgsQuery = interface;
  IgsQueryDisp = dispinterface;
  IgsQueryList = interface;
  IgsQueryListDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  QueryList = IgsQueryList;


// *********************************************************************//
// Interface: IgsField
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {7B5C2EE8-E56D-11D4-AE62-006052067F0D}
// *********************************************************************//
  IgsField = interface(IDispatch)
    ['{7B5C2EE8-E56D-11D4-AE62-006052067F0D}']
    function  Get_AsString: WideString; safecall;
    procedure Set_AsString(const Value: WideString); safecall;
    function  Get_AsInteger: Integer; safecall;
    procedure Set_AsInteger(Value: Integer); safecall;
    property AsString: WideString read Get_AsString write Set_AsString;
    property AsInteger: Integer read Get_AsInteger write Set_AsInteger;
  end;

// *********************************************************************//
// DispIntf:  IgsFieldDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {7B5C2EE8-E56D-11D4-AE62-006052067F0D}
// *********************************************************************//
  IgsFieldDisp = dispinterface
    ['{7B5C2EE8-E56D-11D4-AE62-006052067F0D}']
    property AsString: WideString dispid 1;
    property AsInteger: Integer dispid 2;
  end;

// *********************************************************************//
// Interface: IgsQuery
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {7B5C2EE6-E56D-11D4-AE62-006052067F0D}
// *********************************************************************//
  IgsQuery = interface(IgsField)
    ['{7B5C2EE6-E56D-11D4-AE62-006052067F0D}']
    procedure Open; safecall;
    procedure Close; safecall;
    procedure First; safecall;
    procedure Last; safecall;
    function  Eof: WordBool; safecall;
    function  Get_Fields(Index: Integer): IgsField; safecall;
    function  Get_FieldByName(const FieldName: WideString): IgsField; safecall;
    function  Bof: WordBool; safecall;
    procedure Next; safecall;
    procedure Prior; safecall;
    function  Get_IsResult: WordBool; safecall;
    procedure Set_IsResult(Value: WordBool); safecall;
    function  Get_SQL: WideString; safecall;
    procedure Set_SQL(const Value: WideString); safecall;
    property Fields[Index: Integer]: IgsField read Get_Fields;
    property FieldByName[const FieldName: WideString]: IgsField read Get_FieldByName;
    property IsResult: WordBool read Get_IsResult write Set_IsResult;
    property SQL: WideString read Get_SQL write Set_SQL;
  end;

// *********************************************************************//
// DispIntf:  IgsQueryDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {7B5C2EE6-E56D-11D4-AE62-006052067F0D}
// *********************************************************************//
  IgsQueryDisp = dispinterface
    ['{7B5C2EE6-E56D-11D4-AE62-006052067F0D}']
    procedure Open; dispid 13;
    procedure Close; dispid 14;
    procedure First; dispid 3;
    procedure Last; dispid 4;
    function  Eof: WordBool; dispid 5;
    property Fields[Index: Integer]: IgsField readonly dispid 6;
    property FieldByName[const FieldName: WideString]: IgsField readonly dispid 8;
    function  Bof: WordBool; dispid 9;
    procedure Next; dispid 10;
    procedure Prior; dispid 11;
    property IsResult: WordBool dispid 12;
    property SQL: WideString dispid 7;
    property AsString: WideString dispid 1;
    property AsInteger: Integer dispid 2;
  end;

// *********************************************************************//
// Interface: IgsQueryList
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {7B5C2EE2-E56D-11D4-AE62-006052067F0D}
// *********************************************************************//
  IgsQueryList = interface(IgsQuery)
    ['{7B5C2EE2-E56D-11D4-AE62-006052067F0D}']
    function  Add(const QueryName: WideString): Integer; safecall;
    procedure Delete(Index: Integer); safecall;
    procedure Clear; safecall;
    function  Get_Query(Index: Integer): IgsQuery; safecall;
    function  Get_Count: Integer; safecall;
    property Query[Index: Integer]: IgsQuery read Get_Query;
    property Count: Integer read Get_Count;
  end;

// *********************************************************************//
// DispIntf:  IgsQueryListDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {7B5C2EE2-E56D-11D4-AE62-006052067F0D}
// *********************************************************************//
  IgsQueryListDisp = dispinterface
    ['{7B5C2EE2-E56D-11D4-AE62-006052067F0D}']
    function  Add(const QueryName: WideString): Integer; dispid 15;
    procedure Delete(Index: Integer); dispid 16;
    procedure Clear; dispid 17;
    property Query[Index: Integer]: IgsQuery readonly dispid 18;
    property Count: Integer readonly dispid 19;
    procedure Open; dispid 13;
    procedure Close; dispid 14;
    procedure First; dispid 3;
    procedure Last; dispid 4;
    function  Eof: WordBool; dispid 5;
    property Fields[Index: Integer]: IgsField readonly dispid 6;
    property FieldByName[const FieldName: WideString]: IgsField readonly dispid 8;
    function  Bof: WordBool; dispid 9;
    procedure Next; dispid 10;
    procedure Prior; dispid 11;
    property IsResult: WordBool dispid 12;
    property SQL: WideString dispid 7;
    property AsString: WideString dispid 1;
    property AsInteger: Integer dispid 2;
  end;

// *********************************************************************//
// The Class CoQueryList provides a Create and CreateRemote method to          
// create instances of the default interface IgsQueryList exposed by              
// the CoClass QueryList. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoQueryList = class
    class function Create: IgsQueryList;
    class function CreateRemote(const MachineName: string): IgsQueryList;
  end;

implementation

uses ComObj;

class function CoQueryList.Create: IgsQueryList;
begin
  Result := CreateComObject(CLASS_QueryList) as IgsQueryList;
end;

class function CoQueryList.CreateRemote(const MachineName: string): IgsQueryList;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_QueryList) as IgsQueryList;
end;

end.
