unit gsdbquery_TLB;

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
// File generated on 29.04.2003 13:45:45 from Type Library described below.

// ************************************************************************ //
// Type Lib: D:\golden\gedemin\DBQuery\gsdbquery.tlb (1)
// IID\LCID: {248DE8F2-908B-49BC-9257-D681B913A4BA}\0
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
  gsdbqueryMajorVersion = 1;
  gsdbqueryMinorVersion = 0;

  LIBID_gsdbquery: TGUID = '{248DE8F2-908B-49BC-9257-D681B913A4BA}';

  IID_IgsDBField: TGUID = '{CA7FA920-7964-49D5-A03E-4AE0B497F4F5}';
  IID_IgsDBQuery: TGUID = '{274AC859-37FB-4604-B756-8E43303A4534}';
  IID_IgsDBQueryList: TGUID = '{43679DB3-EEB3-40EF-A0C4-C9060AF840B1}';
  CLASS_gsdb_rpQueryList: TGUID = '{BD6FF16D-8392-4E73-AE48-23AF373625D1}';
  CLASS_gsdb_rpQuery: TGUID = '{7C916B87-94DF-4712-A5AC-10C971C7E160}';
  CLASS_gsdb_rpParam: TGUID = '{A946AFB6-9D4F-400B-8923-BE695C048E85}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IgsDBField = interface;
  IgsDBFieldDisp = dispinterface;
  IgsDBQuery = interface;
  IgsDBQueryDisp = dispinterface;
  IgsDBQueryList = interface;
  IgsDBQueryListDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  gsdb_rpQueryList = IgsDBQueryList;
  gsdb_rpQuery = IgsDBQuery;
  gsdb_rpParam = IgsDBField;


// *********************************************************************//
// Interface: IgsDBField
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {CA7FA920-7964-49D5-A03E-4AE0B497F4F5}
// *********************************************************************//
  IgsDBField = interface(IDispatch)
    ['{CA7FA920-7964-49D5-A03E-4AE0B497F4F5}']
    function  Get_AsString: WideString; safecall;
    procedure Set_AsString(const Value: WideString); safecall;
    function  Get_AsInteger: Integer; safecall;
    procedure Set_AsInteger(Value: Integer); safecall;
    function  Get_AsVariant: OleVariant; safecall;
    procedure Set_AsVariant(Value: OleVariant); safecall;
    function  Get_FieldType: WideString; safecall;
    function  Get_FieldName: WideString; safecall;
    function  Get_FieldSize: Integer; safecall;
    function  Get_Required: WordBool; safecall;
    function  Get_AsFloat: Double; safecall;
    procedure Set_AsFloat(Value: Double); safecall;
    property AsString: WideString read Get_AsString write Set_AsString;
    property AsInteger: Integer read Get_AsInteger write Set_AsInteger;
    property AsVariant: OleVariant read Get_AsVariant write Set_AsVariant;
    property FieldType: WideString read Get_FieldType;
    property FieldName: WideString read Get_FieldName;
    property FieldSize: Integer read Get_FieldSize;
    property Required: WordBool read Get_Required;
    property AsFloat: Double read Get_AsFloat write Set_AsFloat;
  end;

// *********************************************************************//
// DispIntf:  IgsDBFieldDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {CA7FA920-7964-49D5-A03E-4AE0B497F4F5}
// *********************************************************************//
  IgsDBFieldDisp = dispinterface
    ['{CA7FA920-7964-49D5-A03E-4AE0B497F4F5}']
    property AsString: WideString dispid 1;
    property AsInteger: Integer dispid 2;
    property AsVariant: OleVariant dispid 28;
    property FieldType: WideString readonly dispid 30;
    property FieldName: WideString readonly dispid 31;
    property FieldSize: Integer readonly dispid 32;
    property Required: WordBool readonly dispid 33;
    property AsFloat: Double dispid 39;
  end;

// *********************************************************************//
// Interface: IgsDBQuery
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {274AC859-37FB-4604-B756-8E43303A4534}
// *********************************************************************//
  IgsDBQuery = interface(IgsDBField)
    ['{274AC859-37FB-4604-B756-8E43303A4534}']
    procedure Open; safecall;
    procedure Close; safecall;
    procedure First; safecall;
    procedure Last; safecall;
    function  Eof: WordBool; safecall;
    function  Get_Fields(Index: Integer): IgsDBField; safecall;
    function  Get_FieldByName(const FieldName: WideString): IgsDBField; safecall;
    function  Bof: WordBool; safecall;
    procedure Next; safecall;
    procedure Prior; safecall;
    function  Get_IsResult: WordBool; safecall;
    procedure Set_IsResult(Value: WordBool); safecall;
    function  Get_SQL: WideString; safecall;
    procedure Set_SQL(const Value: WideString); safecall;
    procedure AddField(const FieldName: WideString; const FieldType: WideString; 
                       FieldSize: Integer; Required: WordBool); safecall;
    procedure ClearFields; safecall;
    procedure Append; safecall;
    procedure Edit; safecall;
    procedure Delete; safecall;
    procedure Post; safecall;
    procedure Cancel; safecall;
    function  Get_Params(Index: Integer): IgsDBField; safecall;
    function  Get_ParamByName(const ParamName: WideString): IgsDBField; safecall;
    function  Get_FieldCount: Integer; safecall;
    function  Get_ParamCount: Integer; safecall;
    function  Get_OnCalcField: LongWord; safecall;
    procedure Set_OnCalcField(Value: LongWord); safecall;
    procedure ExecSQL; safecall;
    function  Get_FetchBlob: WordBool; safecall;
    procedure Set_FetchBlob(Value: WordBool); safecall;
    function  Get_RecordCount: Integer; safecall;
    procedure Insert; safecall;
    function  Get_Active: WordBool; safecall;
    function  Get_Database: WideString; safecall;
    procedure Set_Database(const Value: WideString); safecall;
    function  Get_TableName: WideString; safecall;
    procedure Set_TableName(const Value: WideString); safecall;
    property Fields[Index: Integer]: IgsDBField read Get_Fields;
    property FieldByName[const FieldName: WideString]: IgsDBField read Get_FieldByName;
    property IsResult: WordBool read Get_IsResult write Set_IsResult;
    property SQL: WideString read Get_SQL write Set_SQL;
    property Params[Index: Integer]: IgsDBField read Get_Params;
    property ParamByName[const ParamName: WideString]: IgsDBField read Get_ParamByName;
    property FieldCount: Integer read Get_FieldCount;
    property ParamCount: Integer read Get_ParamCount;
    property OnCalcField: LongWord read Get_OnCalcField write Set_OnCalcField;
    property FetchBlob: WordBool read Get_FetchBlob write Set_FetchBlob;
    property RecordCount: Integer read Get_RecordCount;
    property Active: WordBool read Get_Active;
    property Database: WideString read Get_Database write Set_Database;
    property TableName: WideString read Get_TableName write Set_TableName;
  end;

// *********************************************************************//
// DispIntf:  IgsDBQueryDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {274AC859-37FB-4604-B756-8E43303A4534}
// *********************************************************************//
  IgsDBQueryDisp = dispinterface
    ['{274AC859-37FB-4604-B756-8E43303A4534}']
    procedure Open; dispid 13;
    procedure Close; dispid 14;
    procedure First; dispid 3;
    procedure Last; dispid 4;
    function  Eof: WordBool; dispid 5;
    property Fields[Index: Integer]: IgsDBField readonly dispid 6;
    property FieldByName[const FieldName: WideString]: IgsDBField readonly dispid 8;
    function  Bof: WordBool; dispid 9;
    procedure Next; dispid 10;
    procedure Prior; dispid 11;
    property IsResult: WordBool dispid 12;
    property SQL: WideString dispid 7;
    procedure AddField(const FieldName: WideString; const FieldType: WideString; 
                       FieldSize: Integer; Required: WordBool); dispid 20;
    procedure ClearFields; dispid 22;
    procedure Append; dispid 23;
    procedure Edit; dispid 24;
    procedure Delete; dispid 25;
    procedure Post; dispid 26;
    procedure Cancel; dispid 27;
    property Params[Index: Integer]: IgsDBField readonly dispid 15;
    property ParamByName[const ParamName: WideString]: IgsDBField readonly dispid 16;
    property FieldCount: Integer readonly dispid 17;
    property ParamCount: Integer readonly dispid 18;
    property OnCalcField: LongWord dispid 19;
    procedure ExecSQL; dispid 21;
    property FetchBlob: WordBool dispid 29;
    property RecordCount: Integer readonly dispid 100;
    procedure Insert; dispid 35;
    property Active: WordBool readonly dispid 102;
    property Database: WideString dispid 36;
    property TableName: WideString dispid 37;
    property AsString: WideString dispid 1;
    property AsInteger: Integer dispid 2;
    property AsVariant: OleVariant dispid 28;
    property FieldType: WideString readonly dispid 30;
    property FieldName: WideString readonly dispid 31;
    property FieldSize: Integer readonly dispid 32;
    property Required: WordBool readonly dispid 33;
    property AsFloat: Double dispid 39;
  end;

// *********************************************************************//
// Interface: IgsDBQueryList
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {43679DB3-EEB3-40EF-A0C4-C9060AF840B1}
// *********************************************************************//
  IgsDBQueryList = interface(IDispatch)
    ['{43679DB3-EEB3-40EF-A0C4-C9060AF840B1}']
    function  Add(const QueryName: WideString; MemQuery: Integer): Integer; safecall;
    procedure Delete(Index: Integer); safecall;
    procedure Clear; safecall;
    function  Get_Query(Index: Integer): IgsDBQuery; safecall;
    function  Get_Count: Integer; safecall;
    function  Get_QueryByName(const Name: WideString): IgsDBQuery; safecall;
    procedure DeleteByName(const AName: WideString); safecall;
    property Query[Index: Integer]: IgsDBQuery read Get_Query;
    property Count: Integer read Get_Count;
    property QueryByName[const Name: WideString]: IgsDBQuery read Get_QueryByName;
  end;

// *********************************************************************//
// DispIntf:  IgsDBQueryListDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {43679DB3-EEB3-40EF-A0C4-C9060AF840B1}
// *********************************************************************//
  IgsDBQueryListDisp = dispinterface
    ['{43679DB3-EEB3-40EF-A0C4-C9060AF840B1}']
    function  Add(const QueryName: WideString; MemQuery: Integer): Integer; dispid 15;
    procedure Delete(Index: Integer); dispid 16;
    procedure Clear; dispid 17;
    property Query[Index: Integer]: IgsDBQuery readonly dispid 18;
    property Count: Integer readonly dispid 19;
    property QueryByName[const Name: WideString]: IgsDBQuery readonly dispid 21;
    procedure DeleteByName(const AName: WideString); dispid 2;
  end;

// *********************************************************************//
// The Class Cogsdb_rpQueryList provides a Create and CreateRemote method to          
// create instances of the default interface IgsDBQueryList exposed by              
// the CoClass gsdb_rpQueryList. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  Cogsdb_rpQueryList = class
    class function Create: IgsDBQueryList;
    class function CreateRemote(const MachineName: string): IgsDBQueryList;
  end;

// *********************************************************************//
// The Class Cogsdb_rpQuery provides a Create and CreateRemote method to          
// create instances of the default interface IgsDBQuery exposed by              
// the CoClass gsdb_rpQuery. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  Cogsdb_rpQuery = class
    class function Create: IgsDBQuery;
    class function CreateRemote(const MachineName: string): IgsDBQuery;
  end;

// *********************************************************************//
// The Class Cogsdb_rpParam provides a Create and CreateRemote method to          
// create instances of the default interface IgsDBField exposed by              
// the CoClass gsdb_rpParam. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  Cogsdb_rpParam = class
    class function Create: IgsDBField;
    class function CreateRemote(const MachineName: string): IgsDBField;
  end;

implementation

uses ComObj;

class function Cogsdb_rpQueryList.Create: IgsDBQueryList;
begin
  Result := CreateComObject(CLASS_gsdb_rpQueryList) as IgsDBQueryList;
end;

class function Cogsdb_rpQueryList.CreateRemote(const MachineName: string): IgsDBQueryList;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_gsdb_rpQueryList) as IgsDBQueryList;
end;

class function Cogsdb_rpQuery.Create: IgsDBQuery;
begin
  Result := CreateComObject(CLASS_gsdb_rpQuery) as IgsDBQuery;
end;

class function Cogsdb_rpQuery.CreateRemote(const MachineName: string): IgsDBQuery;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_gsdb_rpQuery) as IgsDBQuery;
end;

class function Cogsdb_rpParam.Create: IgsDBField;
begin
  Result := CreateComObject(CLASS_gsdb_rpParam) as IgsDBField;
end;

class function Cogsdb_rpParam.CreateRemote(const MachineName: string): IgsDBField;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_gsdb_rpParam) as IgsDBField;
end;

end.
