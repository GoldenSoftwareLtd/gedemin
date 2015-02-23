unit PriceDrv_TLB;

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
// File generated on 09.06.2010 16:56:30 from Type Library described below.

// ************************************************************************  //
// Type Lib: D:\Projects\Work\PriceDrv\Source\PriceDrv\PriceDrv.tlb (1)
// LIBID: {DD81C9B8-A9F3-4033-B28D-249EA9887CB6}
// LCID: 0
// Helpfile: 
// HelpString: Shtrih-M: Price checker driver
// DepndLst: 
//   (1) v2.0 stdole, (C:\WINDOWS\system32\stdole2.tlb)
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
interface

uses Windows, ActiveX, Classes, Graphics, OleCtrls, StdVCL, Variants;
  

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  PriceDrvMajorVersion = 1;
  PriceDrvMinorVersion = 0;

  LIBID_PriceDrv: TGUID = '{DD81C9B8-A9F3-4033-B28D-249EA9887CB6}';

  IID_IPriceChecker: TGUID = '{985F2D38-A739-474E-B028-DDB511AC7EE7}';
  DIID_IPriceCheckerEvents: TGUID = '{06460D54-0487-4A79-AC84-D2E194596C26}';
  IID_IPriceChecker1: TGUID = '{73BCC485-2A0D-4FA5-AF03-52DF6E5F555B}';
  IID_IPriceChecker2: TGUID = '{B96F051E-D44B-4972-96D2-9ADD66F2A392}';
  CLASS_PriceChecker: TGUID = '{9BAE502F-761B-4BDD-817E-C65DB03AF592}';

// *********************************************************************//
// Declaration of Enumerations defined in Type Library                    
// *********************************************************************//
// Constants for enum TProtocol
type
  TProtocol = TOleEnum;
const
  ptUDP = $00000000;
  ptTCP = $00000001;

// Constants for enum TFieldType
type
  TFieldType = TOleEnum;
const
  FIELD_TYPE_INTEGER = $00000000;
  FIELD_TYPE_STRING = $00000001;
  FIELD_TYPE_IP = $00000002;

type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IPriceChecker = interface;
  IPriceCheckerDisp = dispinterface;
  IPriceCheckerEvents = dispinterface;
  IPriceChecker1 = interface;
  IPriceChecker1Disp = dispinterface;
  IPriceChecker2 = interface;
  IPriceChecker2Disp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  PriceChecker = IPriceChecker2;


// *********************************************************************//
// Interface: IPriceChecker
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {985F2D38-A739-474E-B028-DDB511AC7EE7}
// *********************************************************************//
  IPriceChecker = interface(IDispatch)
    ['{985F2D38-A739-474E-B028-DDB511AC7EE7}']
    procedure AboutBox; safecall;
    function AddLD: Integer; safecall;
    function ClientRead: Integer; safecall;
    function ClientWrite: Integer; safecall;
    function CloseClient: Integer; safecall;
    function CloseServer: Integer; safecall;
    function Connect: Integer; safecall;
    function DeleteLD: Integer; safecall;
    function DeviceBySenderID: Integer; safecall;
    function Disconnect: Integer; safecall;
    function GetData: Integer; safecall;
    function GetFieldParams: Integer; safecall;
    function GetFieldStruct: Integer; safecall;
    function GetSenderParams: Integer; safecall;
    function GetStatus: Integer; safecall;
    function GetTableStruct: Integer; safecall;
    function InitTable: Integer; safecall;
    function LockDevice: Integer; safecall;
    function OpenClient: Integer; safecall;
    function OpenServer: Integer; safecall;
    function ReadFieldsStruct: Integer; safecall;
    function ReadMessage: Integer; safecall;
    function ReadTable: Integer; safecall;
    function Reset: Integer; safecall;
    function SaveParams: Integer; safecall;
    function SendAnswer: Integer; safecall;
    function SendBarcode: Integer; safecall;
    function SendCommand: Integer; safecall;
    function SendEvent: Integer; safecall;
    function ServerWrite: Integer; safecall;
    function SetDefaultMessage: Integer; safecall;
    function SetDefaults: Integer; safecall;
    function SetFieldValue: Integer; safecall;
    function SetIPAddress: Integer; safecall;
    function ShowLine: Integer; safecall;
    function ShowMessage: Integer; safecall;
    function ShowMessage2: Integer; safecall;
    function ShowProperties: Integer; safecall;
    function ShowTablesDlg: Integer; safecall;
    function TestTCP: Integer; safecall;
    function UnlockDevice: Integer; safecall;
    function UpdateSoftware: Integer; safecall;
    function WriteCommand: Integer; safecall;
    function WriteMessage: Integer; safecall;
    function WriteTable: Integer; safecall;
    function Get_Barcode: WideString; safecall;
    procedure Set_Barcode(const Value: WideString); safecall;
    function Get_ClientConnected: WordBool; safecall;
    function Get_ClientData: WideString; safecall;
    procedure Set_ClientData(const Value: WideString); safecall;
    function Get_ClientIP: WideString; safecall;
    procedure Set_ClientIP(const Value: WideString); safecall;
    function Get_ClientPort: Integer; safecall;
    procedure Set_ClientPort(Value: Integer); safecall;
    function Get_ClientProtocol: Integer; safecall;
    procedure Set_ClientProtocol(Value: Integer); safecall;
    function Get_ClientTimeout: Integer; safecall;
    procedure Set_ClientTimeout(Value: Integer); safecall;
    function Get_CommandData: WideString; safecall;
    procedure Set_CommandData(const Value: WideString); safecall;
    function Get_DataBlock: WideString; safecall;
    function Get_DataBlockCount: Integer; safecall;
    function Get_DataBlockNumber: Integer; safecall;
    procedure Set_DataBlockNumber(Value: Integer); safecall;
    function Get_DataBlockSA: OleVariant; safecall;
    function Get_DeviceCode: Integer; safecall;
    procedure Set_DeviceCode(Value: Integer); safecall;
    function Get_DeviceCodeDescription: WideString; safecall;
    function Get_DeviceType: Integer; safecall;
    function Get_DeviceTypeDescription: WideString; safecall;
    function Get_FieldMaxValueStr: WideString; safecall;
    function Get_FieldMinValueStr: WideString; safecall;
    function Get_FieldName: WideString; safecall;
    function Get_FieldNumber: Integer; safecall;
    procedure Set_FieldNumber(Value: Integer); safecall;
    function Get_FieldSize: Integer; safecall;
    function Get_FieldType: Integer; safecall;
    function Get_FieldValue: WideString; safecall;
    procedure Set_FieldValue(const Value: WideString); safecall;
    function Get_FileName: WideString; safecall;
    procedure Set_FileName(const Value: WideString); safecall;
    function Get_FileVersion: WideString; safecall;
    function Get_FirmID: Integer; safecall;
    function Get_Input: WideString; safecall;
    function Get_IsDeviceLocked: WordBool; safecall;
    function Get_IsSetupTableError: WordBool; safecall;
    function Get_LDCount: Integer; safecall;
    function Get_LDIndex: Integer; safecall;
    procedure Set_LDIndex(Value: Integer); safecall;
    function Get_LDName: WideString; safecall;
    procedure Set_LDName(const Value: WideString); safecall;
    function Get_LDNumber: Integer; safecall;
    procedure Set_LDNumber(Value: Integer); safecall;
    function Get_Line1: WideString; safecall;
    procedure Set_Line1(const Value: WideString); safecall;
    function Get_Line1Params: WideString; safecall;
    procedure Set_Line1Params(const Value: WideString); safecall;
    function Get_Line2: WideString; safecall;
    procedure Set_Line2(const Value: WideString); safecall;
    function Get_Line2Params: WideString; safecall;
    procedure Set_Line2Params(const Value: WideString); safecall;
    function Get_LineData: WideString; safecall;
    procedure Set_LineData(const Value: WideString); safecall;
    function Get_LineNumber: Integer; safecall;
    procedure Set_LineNumber(Value: Integer); safecall;
    function Get_LineSpeed: Integer; safecall;
    procedure Set_LineSpeed(Value: Integer); safecall;
    function Get_LineType: Integer; safecall;
    procedure Set_LineType(Value: Integer); safecall;
    function Get_LockDevices: WordBool; safecall;
    procedure Set_LockDevices(Value: WordBool); safecall;
    function Get_LogEnabled: WordBool; safecall;
    procedure Set_LogEnabled(Value: WordBool); safecall;
    function Get_LogFileName: WideString; safecall;
    procedure Set_LogFileName(const Value: WideString); safecall;
    function Get_MAC: WideString; safecall;
    function Get_MaxValueOfField: Integer; safecall;
    function Get_MessageNumber: Integer; safecall;
    procedure Set_MessageNumber(Value: Integer); safecall;
    function Get_MinValueOfField: Integer; safecall;
    function Get_Output: WideString; safecall;
    function Get_OutputTime: Integer; safecall;
    procedure Set_OutputTime(Value: Integer); safecall;
    function Get_RepeatCount: Integer; safecall;
    procedure Set_RepeatCount(Value: Integer); safecall;
    function Get_ResultCode: Integer; safecall;
    function Get_ResultCodeDescription: WideString; safecall;
    function Get_RowNumber: Integer; safecall;
    procedure Set_RowNumber(Value: Integer); safecall;
    function Get_SenderID: Integer; safecall;
    procedure Set_SenderID(Value: Integer); safecall;
    function Get_SenderIP: WideString; safecall;
    function Get_SerialNumber: Integer; safecall;
    function Get_ServerData: WideString; safecall;
    procedure Set_ServerData(const Value: WideString); safecall;
    function Get_ServerOpened: WordBool; safecall;
    function Get_ServerPort: Integer; safecall;
    procedure Set_ServerPort(Value: Integer); safecall;
    function Get_ServerProtocol: Integer; safecall;
    procedure Set_ServerProtocol(Value: Integer); safecall;
    function Get_SoftBuild: Integer; safecall;
    function Get_SoftDate: WideString; safecall;
    function Get_SoftFileName: WideString; safecall;
    procedure Set_SoftFileName(const Value: WideString); safecall;
    function Get_SoftVersion: WideString; safecall;
    function Get_StatusFlags: Integer; safecall;
    function Get_TableName: WideString; safecall;
    function Get_TableNumber: Integer; safecall;
    procedure Set_TableNumber(Value: Integer); safecall;
    property Barcode: WideString read Get_Barcode write Set_Barcode;
    property ClientConnected: WordBool read Get_ClientConnected;
    property ClientData: WideString read Get_ClientData write Set_ClientData;
    property ClientIP: WideString read Get_ClientIP write Set_ClientIP;
    property ClientPort: Integer read Get_ClientPort write Set_ClientPort;
    property ClientProtocol: Integer read Get_ClientProtocol write Set_ClientProtocol;
    property ClientTimeout: Integer read Get_ClientTimeout write Set_ClientTimeout;
    property CommandData: WideString read Get_CommandData write Set_CommandData;
    property DataBlock: WideString read Get_DataBlock;
    property DataBlockCount: Integer read Get_DataBlockCount;
    property DataBlockNumber: Integer read Get_DataBlockNumber write Set_DataBlockNumber;
    property DataBlockSA: OleVariant read Get_DataBlockSA;
    property DeviceCode: Integer read Get_DeviceCode write Set_DeviceCode;
    property DeviceCodeDescription: WideString read Get_DeviceCodeDescription;
    property DeviceType: Integer read Get_DeviceType;
    property DeviceTypeDescription: WideString read Get_DeviceTypeDescription;
    property FieldMaxValueStr: WideString read Get_FieldMaxValueStr;
    property FieldMinValueStr: WideString read Get_FieldMinValueStr;
    property FieldName: WideString read Get_FieldName;
    property FieldNumber: Integer read Get_FieldNumber write Set_FieldNumber;
    property FieldSize: Integer read Get_FieldSize;
    property FieldType: Integer read Get_FieldType;
    property FieldValue: WideString read Get_FieldValue write Set_FieldValue;
    property FileName: WideString read Get_FileName write Set_FileName;
    property FileVersion: WideString read Get_FileVersion;
    property FirmID: Integer read Get_FirmID;
    property Input: WideString read Get_Input;
    property IsDeviceLocked: WordBool read Get_IsDeviceLocked;
    property IsSetupTableError: WordBool read Get_IsSetupTableError;
    property LDCount: Integer read Get_LDCount;
    property LDIndex: Integer read Get_LDIndex write Set_LDIndex;
    property LDName: WideString read Get_LDName write Set_LDName;
    property LDNumber: Integer read Get_LDNumber write Set_LDNumber;
    property Line1: WideString read Get_Line1 write Set_Line1;
    property Line1Params: WideString read Get_Line1Params write Set_Line1Params;
    property Line2: WideString read Get_Line2 write Set_Line2;
    property Line2Params: WideString read Get_Line2Params write Set_Line2Params;
    property LineData: WideString read Get_LineData write Set_LineData;
    property LineNumber: Integer read Get_LineNumber write Set_LineNumber;
    property LineSpeed: Integer read Get_LineSpeed write Set_LineSpeed;
    property LineType: Integer read Get_LineType write Set_LineType;
    property LockDevices: WordBool read Get_LockDevices write Set_LockDevices;
    property LogEnabled: WordBool read Get_LogEnabled write Set_LogEnabled;
    property LogFileName: WideString read Get_LogFileName write Set_LogFileName;
    property MAC: WideString read Get_MAC;
    property MaxValueOfField: Integer read Get_MaxValueOfField;
    property MessageNumber: Integer read Get_MessageNumber write Set_MessageNumber;
    property MinValueOfField: Integer read Get_MinValueOfField;
    property Output: WideString read Get_Output;
    property OutputTime: Integer read Get_OutputTime write Set_OutputTime;
    property RepeatCount: Integer read Get_RepeatCount write Set_RepeatCount;
    property ResultCode: Integer read Get_ResultCode;
    property ResultCodeDescription: WideString read Get_ResultCodeDescription;
    property RowNumber: Integer read Get_RowNumber write Set_RowNumber;
    property SenderID: Integer read Get_SenderID write Set_SenderID;
    property SenderIP: WideString read Get_SenderIP;
    property SerialNumber: Integer read Get_SerialNumber;
    property ServerData: WideString read Get_ServerData write Set_ServerData;
    property ServerOpened: WordBool read Get_ServerOpened;
    property ServerPort: Integer read Get_ServerPort write Set_ServerPort;
    property ServerProtocol: Integer read Get_ServerProtocol write Set_ServerProtocol;
    property SoftBuild: Integer read Get_SoftBuild;
    property SoftDate: WideString read Get_SoftDate;
    property SoftFileName: WideString read Get_SoftFileName write Set_SoftFileName;
    property SoftVersion: WideString read Get_SoftVersion;
    property StatusFlags: Integer read Get_StatusFlags;
    property TableName: WideString read Get_TableName;
    property TableNumber: Integer read Get_TableNumber write Set_TableNumber;
  end;

// *********************************************************************//
// DispIntf:  IPriceCheckerDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {985F2D38-A739-474E-B028-DDB511AC7EE7}
// *********************************************************************//
  IPriceCheckerDisp = dispinterface
    ['{985F2D38-A739-474E-B028-DDB511AC7EE7}']
    procedure AboutBox; dispid -552;
    function AddLD: Integer; dispid 1;
    function ClientRead: Integer; dispid 2;
    function ClientWrite: Integer; dispid 3;
    function CloseClient: Integer; dispid 4;
    function CloseServer: Integer; dispid 5;
    function Connect: Integer; dispid 6;
    function DeleteLD: Integer; dispid 7;
    function DeviceBySenderID: Integer; dispid 8;
    function Disconnect: Integer; dispid 9;
    function GetData: Integer; dispid 10;
    function GetFieldParams: Integer; dispid 11;
    function GetFieldStruct: Integer; dispid 12;
    function GetSenderParams: Integer; dispid 13;
    function GetStatus: Integer; dispid 14;
    function GetTableStruct: Integer; dispid 15;
    function InitTable: Integer; dispid 16;
    function LockDevice: Integer; dispid 17;
    function OpenClient: Integer; dispid 18;
    function OpenServer: Integer; dispid 19;
    function ReadFieldsStruct: Integer; dispid 20;
    function ReadMessage: Integer; dispid 21;
    function ReadTable: Integer; dispid 22;
    function Reset: Integer; dispid 23;
    function SaveParams: Integer; dispid 24;
    function SendAnswer: Integer; dispid 25;
    function SendBarcode: Integer; dispid 26;
    function SendCommand: Integer; dispid 27;
    function SendEvent: Integer; dispid 28;
    function ServerWrite: Integer; dispid 29;
    function SetDefaultMessage: Integer; dispid 30;
    function SetDefaults: Integer; dispid 31;
    function SetFieldValue: Integer; dispid 32;
    function SetIPAddress: Integer; dispid 33;
    function ShowLine: Integer; dispid 34;
    function ShowMessage: Integer; dispid 35;
    function ShowMessage2: Integer; dispid 36;
    function ShowProperties: Integer; dispid 37;
    function ShowTablesDlg: Integer; dispid 38;
    function TestTCP: Integer; dispid 39;
    function UnlockDevice: Integer; dispid 40;
    function UpdateSoftware: Integer; dispid 41;
    function WriteCommand: Integer; dispid 42;
    function WriteMessage: Integer; dispid 43;
    function WriteTable: Integer; dispid 44;
    property Barcode: WideString dispid 45;
    property ClientConnected: WordBool readonly dispid 46;
    property ClientData: WideString dispid 47;
    property ClientIP: WideString dispid 48;
    property ClientPort: Integer dispid 49;
    property ClientProtocol: Integer dispid 50;
    property ClientTimeout: Integer dispid 51;
    property CommandData: WideString dispid 52;
    property DataBlock: WideString readonly dispid 53;
    property DataBlockCount: Integer readonly dispid 54;
    property DataBlockNumber: Integer dispid 55;
    property DataBlockSA: OleVariant readonly dispid 56;
    property DeviceCode: Integer dispid 57;
    property DeviceCodeDescription: WideString readonly dispid 58;
    property DeviceType: Integer readonly dispid 59;
    property DeviceTypeDescription: WideString readonly dispid 60;
    property FieldMaxValueStr: WideString readonly dispid 61;
    property FieldMinValueStr: WideString readonly dispid 62;
    property FieldName: WideString readonly dispid 63;
    property FieldNumber: Integer dispid 64;
    property FieldSize: Integer readonly dispid 65;
    property FieldType: Integer readonly dispid 66;
    property FieldValue: WideString dispid 67;
    property FileName: WideString dispid 68;
    property FileVersion: WideString readonly dispid 69;
    property FirmID: Integer readonly dispid 70;
    property Input: WideString readonly dispid 71;
    property IsDeviceLocked: WordBool readonly dispid 72;
    property IsSetupTableError: WordBool readonly dispid 73;
    property LDCount: Integer readonly dispid 74;
    property LDIndex: Integer dispid 75;
    property LDName: WideString dispid 76;
    property LDNumber: Integer dispid 77;
    property Line1: WideString dispid 78;
    property Line1Params: WideString dispid 79;
    property Line2: WideString dispid 80;
    property Line2Params: WideString dispid 81;
    property LineData: WideString dispid 82;
    property LineNumber: Integer dispid 83;
    property LineSpeed: Integer dispid 84;
    property LineType: Integer dispid 85;
    property LockDevices: WordBool dispid 86;
    property LogEnabled: WordBool dispid 87;
    property LogFileName: WideString dispid 88;
    property MAC: WideString readonly dispid 89;
    property MaxValueOfField: Integer readonly dispid 90;
    property MessageNumber: Integer dispid 91;
    property MinValueOfField: Integer readonly dispid 92;
    property Output: WideString readonly dispid 93;
    property OutputTime: Integer dispid 94;
    property RepeatCount: Integer dispid 95;
    property ResultCode: Integer readonly dispid 96;
    property ResultCodeDescription: WideString readonly dispid 97;
    property RowNumber: Integer dispid 98;
    property SenderID: Integer dispid 99;
    property SenderIP: WideString readonly dispid 100;
    property SerialNumber: Integer readonly dispid 101;
    property ServerData: WideString dispid 102;
    property ServerOpened: WordBool readonly dispid 103;
    property ServerPort: Integer dispid 104;
    property ServerProtocol: Integer dispid 105;
    property SoftBuild: Integer readonly dispid 106;
    property SoftDate: WideString readonly dispid 107;
    property SoftFileName: WideString dispid 108;
    property SoftVersion: WideString readonly dispid 109;
    property StatusFlags: Integer readonly dispid 110;
    property TableName: WideString readonly dispid 111;
    property TableNumber: Integer dispid 112;
  end;

// *********************************************************************//
// DispIntf:  IPriceCheckerEvents
// Flags:     (4096) Dispatchable
// GUID:      {06460D54-0487-4A79-AC84-D2E194596C26}
// *********************************************************************//
  IPriceCheckerEvents = dispinterface
    ['{06460D54-0487-4A79-AC84-D2E194596C26}']
    procedure DataEvent(const Data: WideString; SenderID: Integer); dispid 1;
    procedure LogEvent(const Data: WideString); dispid 2;
  end;

// *********************************************************************//
// Interface: IPriceChecker1
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {73BCC485-2A0D-4FA5-AF03-52DF6E5F555B}
// *********************************************************************//
  IPriceChecker1 = interface(IPriceChecker)
    ['{73BCC485-2A0D-4FA5-AF03-52DF6E5F555B}']
    function WriteFontBlock: Integer; safecall;
    function ReadFontBlock: Integer; safecall;
    function Get_FontBlockNumber: Integer; safecall;
    procedure Set_FontBlockNumber(Value: Integer); safecall;
    function Get_FontBlock: WideString; safecall;
    procedure Set_FontBlock(const Value: WideString); safecall;
    function ShowFontLoaderDlg: Integer; safecall;
    function ShowUpdateFirmwareDlg: Integer; safecall;
    function Get_FieldCount: Integer; safecall;
    function Get_RowCount: Integer; safecall;
    function UpdateStart: Integer; safecall;
    function UpdateEnd: Integer; safecall;
    function GetMode: Integer; safecall;
    function Get_UpdateBlockNumber: Integer; safecall;
    procedure Set_UpdateBlockNumber(Value: Integer); safecall;
    function Get_UpdateBlock: WideString; safecall;
    procedure Set_UpdateBlock(const Value: WideString); safecall;
    function Get_ModeReason: Integer; safecall;
    function Get_Mode: Integer; safecall;
    function UpdateSendBlock: Integer; safecall;
    function Get_BroadcastEnabled: WordBool; safecall;
    procedure Set_BroadcastEnabled(Value: WordBool); safecall;
    function ShowSetIPAddressDlg: Integer; safecall;
    function ShowEmbeddedMessageDlg: Integer; safecall;
    function SetDefaultFont: Integer; safecall;
    function ShowXmlLoaderDlg: Integer; safecall;
    property FontBlockNumber: Integer read Get_FontBlockNumber write Set_FontBlockNumber;
    property FontBlock: WideString read Get_FontBlock write Set_FontBlock;
    property FieldCount: Integer read Get_FieldCount;
    property RowCount: Integer read Get_RowCount;
    property UpdateBlockNumber: Integer read Get_UpdateBlockNumber write Set_UpdateBlockNumber;
    property UpdateBlock: WideString read Get_UpdateBlock write Set_UpdateBlock;
    property ModeReason: Integer read Get_ModeReason;
    property Mode: Integer read Get_Mode;
    property BroadcastEnabled: WordBool read Get_BroadcastEnabled write Set_BroadcastEnabled;
  end;

// *********************************************************************//
// DispIntf:  IPriceChecker1Disp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {73BCC485-2A0D-4FA5-AF03-52DF6E5F555B}
// *********************************************************************//
  IPriceChecker1Disp = dispinterface
    ['{73BCC485-2A0D-4FA5-AF03-52DF6E5F555B}']
    function WriteFontBlock: Integer; dispid 113;
    function ReadFontBlock: Integer; dispid 114;
    property FontBlockNumber: Integer dispid 115;
    property FontBlock: WideString dispid 116;
    function ShowFontLoaderDlg: Integer; dispid 117;
    function ShowUpdateFirmwareDlg: Integer; dispid 118;
    property FieldCount: Integer readonly dispid 119;
    property RowCount: Integer readonly dispid 120;
    function UpdateStart: Integer; dispid 121;
    function UpdateEnd: Integer; dispid 122;
    function GetMode: Integer; dispid 123;
    property UpdateBlockNumber: Integer dispid 124;
    property UpdateBlock: WideString dispid 125;
    property ModeReason: Integer readonly dispid 126;
    property Mode: Integer readonly dispid 128;
    function UpdateSendBlock: Integer; dispid 129;
    property BroadcastEnabled: WordBool dispid 127;
    function ShowSetIPAddressDlg: Integer; dispid 301;
    function ShowEmbeddedMessageDlg: Integer; dispid 302;
    function SetDefaultFont: Integer; dispid 303;
    function ShowXmlLoaderDlg: Integer; dispid 304;
    procedure AboutBox; dispid -552;
    function AddLD: Integer; dispid 1;
    function ClientRead: Integer; dispid 2;
    function ClientWrite: Integer; dispid 3;
    function CloseClient: Integer; dispid 4;
    function CloseServer: Integer; dispid 5;
    function Connect: Integer; dispid 6;
    function DeleteLD: Integer; dispid 7;
    function DeviceBySenderID: Integer; dispid 8;
    function Disconnect: Integer; dispid 9;
    function GetData: Integer; dispid 10;
    function GetFieldParams: Integer; dispid 11;
    function GetFieldStruct: Integer; dispid 12;
    function GetSenderParams: Integer; dispid 13;
    function GetStatus: Integer; dispid 14;
    function GetTableStruct: Integer; dispid 15;
    function InitTable: Integer; dispid 16;
    function LockDevice: Integer; dispid 17;
    function OpenClient: Integer; dispid 18;
    function OpenServer: Integer; dispid 19;
    function ReadFieldsStruct: Integer; dispid 20;
    function ReadMessage: Integer; dispid 21;
    function ReadTable: Integer; dispid 22;
    function Reset: Integer; dispid 23;
    function SaveParams: Integer; dispid 24;
    function SendAnswer: Integer; dispid 25;
    function SendBarcode: Integer; dispid 26;
    function SendCommand: Integer; dispid 27;
    function SendEvent: Integer; dispid 28;
    function ServerWrite: Integer; dispid 29;
    function SetDefaultMessage: Integer; dispid 30;
    function SetDefaults: Integer; dispid 31;
    function SetFieldValue: Integer; dispid 32;
    function SetIPAddress: Integer; dispid 33;
    function ShowLine: Integer; dispid 34;
    function ShowMessage: Integer; dispid 35;
    function ShowMessage2: Integer; dispid 36;
    function ShowProperties: Integer; dispid 37;
    function ShowTablesDlg: Integer; dispid 38;
    function TestTCP: Integer; dispid 39;
    function UnlockDevice: Integer; dispid 40;
    function UpdateSoftware: Integer; dispid 41;
    function WriteCommand: Integer; dispid 42;
    function WriteMessage: Integer; dispid 43;
    function WriteTable: Integer; dispid 44;
    property Barcode: WideString dispid 45;
    property ClientConnected: WordBool readonly dispid 46;
    property ClientData: WideString dispid 47;
    property ClientIP: WideString dispid 48;
    property ClientPort: Integer dispid 49;
    property ClientProtocol: Integer dispid 50;
    property ClientTimeout: Integer dispid 51;
    property CommandData: WideString dispid 52;
    property DataBlock: WideString readonly dispid 53;
    property DataBlockCount: Integer readonly dispid 54;
    property DataBlockNumber: Integer dispid 55;
    property DataBlockSA: OleVariant readonly dispid 56;
    property DeviceCode: Integer dispid 57;
    property DeviceCodeDescription: WideString readonly dispid 58;
    property DeviceType: Integer readonly dispid 59;
    property DeviceTypeDescription: WideString readonly dispid 60;
    property FieldMaxValueStr: WideString readonly dispid 61;
    property FieldMinValueStr: WideString readonly dispid 62;
    property FieldName: WideString readonly dispid 63;
    property FieldNumber: Integer dispid 64;
    property FieldSize: Integer readonly dispid 65;
    property FieldType: Integer readonly dispid 66;
    property FieldValue: WideString dispid 67;
    property FileName: WideString dispid 68;
    property FileVersion: WideString readonly dispid 69;
    property FirmID: Integer readonly dispid 70;
    property Input: WideString readonly dispid 71;
    property IsDeviceLocked: WordBool readonly dispid 72;
    property IsSetupTableError: WordBool readonly dispid 73;
    property LDCount: Integer readonly dispid 74;
    property LDIndex: Integer dispid 75;
    property LDName: WideString dispid 76;
    property LDNumber: Integer dispid 77;
    property Line1: WideString dispid 78;
    property Line1Params: WideString dispid 79;
    property Line2: WideString dispid 80;
    property Line2Params: WideString dispid 81;
    property LineData: WideString dispid 82;
    property LineNumber: Integer dispid 83;
    property LineSpeed: Integer dispid 84;
    property LineType: Integer dispid 85;
    property LockDevices: WordBool dispid 86;
    property LogEnabled: WordBool dispid 87;
    property LogFileName: WideString dispid 88;
    property MAC: WideString readonly dispid 89;
    property MaxValueOfField: Integer readonly dispid 90;
    property MessageNumber: Integer dispid 91;
    property MinValueOfField: Integer readonly dispid 92;
    property Output: WideString readonly dispid 93;
    property OutputTime: Integer dispid 94;
    property RepeatCount: Integer dispid 95;
    property ResultCode: Integer readonly dispid 96;
    property ResultCodeDescription: WideString readonly dispid 97;
    property RowNumber: Integer dispid 98;
    property SenderID: Integer dispid 99;
    property SenderIP: WideString readonly dispid 100;
    property SerialNumber: Integer readonly dispid 101;
    property ServerData: WideString dispid 102;
    property ServerOpened: WordBool readonly dispid 103;
    property ServerPort: Integer dispid 104;
    property ServerProtocol: Integer dispid 105;
    property SoftBuild: Integer readonly dispid 106;
    property SoftDate: WideString readonly dispid 107;
    property SoftFileName: WideString dispid 108;
    property SoftVersion: WideString readonly dispid 109;
    property StatusFlags: Integer readonly dispid 110;
    property TableName: WideString readonly dispid 111;
    property TableNumber: Integer dispid 112;
  end;

// *********************************************************************//
// Interface: IPriceChecker2
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {B96F051E-D44B-4972-96D2-9ADD66F2A392}
// *********************************************************************//
  IPriceChecker2 = interface(IPriceChecker1)
    ['{B96F051E-D44B-4972-96D2-9ADD66F2A392}']
    function SendMifareCommand: Integer; safecall;
    function Get_MifareCommand: WideString; safecall;
    procedure Set_MifareCommand(const Value: WideString); safecall;
    function Get_MifareAnswer: WideString; safecall;
    procedure Set_MifareAnswer(const Value: WideString); safecall;
    function Get_MifareTimeout: Integer; safecall;
    procedure Set_MifareTimeout(Value: Integer); safecall;
    function Get_Connected: WordBool; safecall;
    property MifareCommand: WideString read Get_MifareCommand write Set_MifareCommand;
    property MifareAnswer: WideString read Get_MifareAnswer write Set_MifareAnswer;
    property MifareTimeout: Integer read Get_MifareTimeout write Set_MifareTimeout;
    property Connected: WordBool read Get_Connected;
  end;

// *********************************************************************//
// DispIntf:  IPriceChecker2Disp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {B96F051E-D44B-4972-96D2-9ADD66F2A392}
// *********************************************************************//
  IPriceChecker2Disp = dispinterface
    ['{B96F051E-D44B-4972-96D2-9ADD66F2A392}']
    function SendMifareCommand: Integer; dispid 401;
    property MifareCommand: WideString dispid 403;
    property MifareAnswer: WideString dispid 402;
    property MifareTimeout: Integer dispid 404;
    property Connected: WordBool readonly dispid 405;
    function WriteFontBlock: Integer; dispid 113;
    function ReadFontBlock: Integer; dispid 114;
    property FontBlockNumber: Integer dispid 115;
    property FontBlock: WideString dispid 116;
    function ShowFontLoaderDlg: Integer; dispid 117;
    function ShowUpdateFirmwareDlg: Integer; dispid 118;
    property FieldCount: Integer readonly dispid 119;
    property RowCount: Integer readonly dispid 120;
    function UpdateStart: Integer; dispid 121;
    function UpdateEnd: Integer; dispid 122;
    function GetMode: Integer; dispid 123;
    property UpdateBlockNumber: Integer dispid 124;
    property UpdateBlock: WideString dispid 125;
    property ModeReason: Integer readonly dispid 126;
    property Mode: Integer readonly dispid 128;
    function UpdateSendBlock: Integer; dispid 129;
    property BroadcastEnabled: WordBool dispid 127;
    function ShowSetIPAddressDlg: Integer; dispid 301;
    function ShowEmbeddedMessageDlg: Integer; dispid 302;
    function SetDefaultFont: Integer; dispid 303;
    function ShowXmlLoaderDlg: Integer; dispid 304;
    procedure AboutBox; dispid -552;
    function AddLD: Integer; dispid 1;
    function ClientRead: Integer; dispid 2;
    function ClientWrite: Integer; dispid 3;
    function CloseClient: Integer; dispid 4;
    function CloseServer: Integer; dispid 5;
    function Connect: Integer; dispid 6;
    function DeleteLD: Integer; dispid 7;
    function DeviceBySenderID: Integer; dispid 8;
    function Disconnect: Integer; dispid 9;
    function GetData: Integer; dispid 10;
    function GetFieldParams: Integer; dispid 11;
    function GetFieldStruct: Integer; dispid 12;
    function GetSenderParams: Integer; dispid 13;
    function GetStatus: Integer; dispid 14;
    function GetTableStruct: Integer; dispid 15;
    function InitTable: Integer; dispid 16;
    function LockDevice: Integer; dispid 17;
    function OpenClient: Integer; dispid 18;
    function OpenServer: Integer; dispid 19;
    function ReadFieldsStruct: Integer; dispid 20;
    function ReadMessage: Integer; dispid 21;
    function ReadTable: Integer; dispid 22;
    function Reset: Integer; dispid 23;
    function SaveParams: Integer; dispid 24;
    function SendAnswer: Integer; dispid 25;
    function SendBarcode: Integer; dispid 26;
    function SendCommand: Integer; dispid 27;
    function SendEvent: Integer; dispid 28;
    function ServerWrite: Integer; dispid 29;
    function SetDefaultMessage: Integer; dispid 30;
    function SetDefaults: Integer; dispid 31;
    function SetFieldValue: Integer; dispid 32;
    function SetIPAddress: Integer; dispid 33;
    function ShowLine: Integer; dispid 34;
    function ShowMessage: Integer; dispid 35;
    function ShowMessage2: Integer; dispid 36;
    function ShowProperties: Integer; dispid 37;
    function ShowTablesDlg: Integer; dispid 38;
    function TestTCP: Integer; dispid 39;
    function UnlockDevice: Integer; dispid 40;
    function UpdateSoftware: Integer; dispid 41;
    function WriteCommand: Integer; dispid 42;
    function WriteMessage: Integer; dispid 43;
    function WriteTable: Integer; dispid 44;
    property Barcode: WideString dispid 45;
    property ClientConnected: WordBool readonly dispid 46;
    property ClientData: WideString dispid 47;
    property ClientIP: WideString dispid 48;
    property ClientPort: Integer dispid 49;
    property ClientProtocol: Integer dispid 50;
    property ClientTimeout: Integer dispid 51;
    property CommandData: WideString dispid 52;
    property DataBlock: WideString readonly dispid 53;
    property DataBlockCount: Integer readonly dispid 54;
    property DataBlockNumber: Integer dispid 55;
    property DataBlockSA: OleVariant readonly dispid 56;
    property DeviceCode: Integer dispid 57;
    property DeviceCodeDescription: WideString readonly dispid 58;
    property DeviceType: Integer readonly dispid 59;
    property DeviceTypeDescription: WideString readonly dispid 60;
    property FieldMaxValueStr: WideString readonly dispid 61;
    property FieldMinValueStr: WideString readonly dispid 62;
    property FieldName: WideString readonly dispid 63;
    property FieldNumber: Integer dispid 64;
    property FieldSize: Integer readonly dispid 65;
    property FieldType: Integer readonly dispid 66;
    property FieldValue: WideString dispid 67;
    property FileName: WideString dispid 68;
    property FileVersion: WideString readonly dispid 69;
    property FirmID: Integer readonly dispid 70;
    property Input: WideString readonly dispid 71;
    property IsDeviceLocked: WordBool readonly dispid 72;
    property IsSetupTableError: WordBool readonly dispid 73;
    property LDCount: Integer readonly dispid 74;
    property LDIndex: Integer dispid 75;
    property LDName: WideString dispid 76;
    property LDNumber: Integer dispid 77;
    property Line1: WideString dispid 78;
    property Line1Params: WideString dispid 79;
    property Line2: WideString dispid 80;
    property Line2Params: WideString dispid 81;
    property LineData: WideString dispid 82;
    property LineNumber: Integer dispid 83;
    property LineSpeed: Integer dispid 84;
    property LineType: Integer dispid 85;
    property LockDevices: WordBool dispid 86;
    property LogEnabled: WordBool dispid 87;
    property LogFileName: WideString dispid 88;
    property MAC: WideString readonly dispid 89;
    property MaxValueOfField: Integer readonly dispid 90;
    property MessageNumber: Integer dispid 91;
    property MinValueOfField: Integer readonly dispid 92;
    property Output: WideString readonly dispid 93;
    property OutputTime: Integer dispid 94;
    property RepeatCount: Integer dispid 95;
    property ResultCode: Integer readonly dispid 96;
    property ResultCodeDescription: WideString readonly dispid 97;
    property RowNumber: Integer dispid 98;
    property SenderID: Integer dispid 99;
    property SenderIP: WideString readonly dispid 100;
    property SerialNumber: Integer readonly dispid 101;
    property ServerData: WideString dispid 102;
    property ServerOpened: WordBool readonly dispid 103;
    property ServerPort: Integer dispid 104;
    property ServerProtocol: Integer dispid 105;
    property SoftBuild: Integer readonly dispid 106;
    property SoftDate: WideString readonly dispid 107;
    property SoftFileName: WideString dispid 108;
    property SoftVersion: WideString readonly dispid 109;
    property StatusFlags: Integer readonly dispid 110;
    property TableName: WideString readonly dispid 111;
    property TableNumber: Integer dispid 112;
  end;


// *********************************************************************//
// OLE Control Proxy class declaration
// Control Name     : TPriceChecker
// Help String      : Shtrih-M: Price checker driver
// Default Interface: IPriceChecker2
// Def. Intf. DISP? : No
// Event   Interface: IPriceCheckerEvents
// TypeFlags        : (34) CanCreate Control
// *********************************************************************//
  TPriceCheckerDataEvent = procedure(ASender: TObject; const Data: WideString; SenderID: Integer) of object;
  TPriceCheckerLogEvent = procedure(ASender: TObject; const Data: WideString) of object;

  TPriceChecker = class(TOleControl)
  private
    FOnDataEvent: TPriceCheckerDataEvent;
    FOnLogEvent: TPriceCheckerLogEvent;
    FIntf: IPriceChecker2;
    function  GetControlInterface: IPriceChecker2;
  protected
    procedure CreateControl;
    procedure InitControlData; override;
    function Get_DataBlockSA: OleVariant;
  public
    procedure AboutBox;
    function AddLD: Integer;
    function ClientRead: Integer;
    function ClientWrite: Integer;
    function CloseClient: Integer;
    function CloseServer: Integer;
    function Connect: Integer;
    function DeleteLD: Integer;
    function DeviceBySenderID: Integer;
    function Disconnect: Integer;
    function GetData: Integer;
    function GetFieldParams: Integer;
    function GetFieldStruct: Integer;
    function GetSenderParams: Integer;
    function GetStatus: Integer;
    function GetTableStruct: Integer;
    function InitTable: Integer;
    function LockDevice: Integer;
    function OpenClient: Integer;
    function OpenServer: Integer;
    function ReadFieldsStruct: Integer;
    function ReadMessage: Integer;
    function ReadTable: Integer;
    function Reset: Integer;
    function SaveParams: Integer;
    function SendAnswer: Integer;
    function SendBarcode: Integer;
    function SendCommand: Integer;
    function SendEvent: Integer;
    function ServerWrite: Integer;
    function SetDefaultMessage: Integer;
    function SetDefaults: Integer;
    function SetFieldValue: Integer;
    function SetIPAddress: Integer;
    function ShowLine: Integer;
    function ShowMessage: Integer;
    function ShowMessage2: Integer;
    function ShowProperties: Integer;
    function ShowTablesDlg: Integer;
    function TestTCP: Integer;
    function UnlockDevice: Integer;
    function UpdateSoftware: Integer;
    function WriteCommand: Integer;
    function WriteMessage: Integer;
    function WriteTable: Integer;
    function WriteFontBlock: Integer;
    function ReadFontBlock: Integer;
    function ShowFontLoaderDlg: Integer;
    function ShowUpdateFirmwareDlg: Integer;
    function UpdateStart: Integer;
    function UpdateEnd: Integer;
    function GetMode: Integer;
    function UpdateSendBlock: Integer;
    function ShowSetIPAddressDlg: Integer;
    function ShowEmbeddedMessageDlg: Integer;
    function SetDefaultFont: Integer;
    function ShowXmlLoaderDlg: Integer;
    function SendMifareCommand: Integer;
    property  ControlInterface: IPriceChecker2 read GetControlInterface;
    property  DefaultInterface: IPriceChecker2 read GetControlInterface;
    property ClientConnected: WordBool index 46 read GetWordBoolProp;
    property DataBlock: WideString index 53 read GetWideStringProp;
    property DataBlockCount: Integer index 54 read GetIntegerProp;
    property DataBlockSA: OleVariant index 56 read GetOleVariantProp;
    property DeviceCodeDescription: WideString index 58 read GetWideStringProp;
    property DeviceType: Integer index 59 read GetIntegerProp;
    property DeviceTypeDescription: WideString index 60 read GetWideStringProp;
    property FieldMaxValueStr: WideString index 61 read GetWideStringProp;
    property FieldMinValueStr: WideString index 62 read GetWideStringProp;
    property FieldName: WideString index 63 read GetWideStringProp;
    property FieldSize: Integer index 65 read GetIntegerProp;
    property FieldType: Integer index 66 read GetIntegerProp;
    property FileVersion: WideString index 69 read GetWideStringProp;
    property FirmID: Integer index 70 read GetIntegerProp;
    property Input: WideString index 71 read GetWideStringProp;
    property IsDeviceLocked: WordBool index 72 read GetWordBoolProp;
    property IsSetupTableError: WordBool index 73 read GetWordBoolProp;
    property LDCount: Integer index 74 read GetIntegerProp;
    property MAC: WideString index 89 read GetWideStringProp;
    property MaxValueOfField: Integer index 90 read GetIntegerProp;
    property MinValueOfField: Integer index 92 read GetIntegerProp;
    property Output: WideString index 93 read GetWideStringProp;
    property ResultCode: Integer index 96 read GetIntegerProp;
    property ResultCodeDescription: WideString index 97 read GetWideStringProp;
    property SenderIP: WideString index 100 read GetWideStringProp;
    property SerialNumber: Integer index 101 read GetIntegerProp;
    property ServerOpened: WordBool index 103 read GetWordBoolProp;
    property SoftBuild: Integer index 106 read GetIntegerProp;
    property SoftDate: WideString index 107 read GetWideStringProp;
    property SoftVersion: WideString index 109 read GetWideStringProp;
    property StatusFlags: Integer index 110 read GetIntegerProp;
    property TableName: WideString index 111 read GetWideStringProp;
    property FieldCount: Integer index 119 read GetIntegerProp;
    property RowCount: Integer index 120 read GetIntegerProp;
    property ModeReason: Integer index 126 read GetIntegerProp;
    property Mode: Integer index 128 read GetIntegerProp;
    property Connected: WordBool index 405 read GetWordBoolProp;
  published
    property Anchors;
    property  TabStop;
    property  Align;
    property  DragCursor;
    property  DragMode;
    property  ParentShowHint;
    property  PopupMenu;
    property  ShowHint;
    property  TabOrder;
    property  Visible;
    property  OnDragDrop;
    property  OnDragOver;
    property  OnEndDrag;
    property  OnEnter;
    property  OnExit;
    property  OnStartDrag;
    property Barcode: WideString index 45 read GetWideStringProp write SetWideStringProp stored False;
    property ClientData: WideString index 47 read GetWideStringProp write SetWideStringProp stored False;
    property ClientIP: WideString index 48 read GetWideStringProp write SetWideStringProp stored False;
    property ClientPort: Integer index 49 read GetIntegerProp write SetIntegerProp stored False;
    property ClientProtocol: Integer index 50 read GetIntegerProp write SetIntegerProp stored False;
    property ClientTimeout: Integer index 51 read GetIntegerProp write SetIntegerProp stored False;
    property CommandData: WideString index 52 read GetWideStringProp write SetWideStringProp stored False;
    property DataBlockNumber: Integer index 55 read GetIntegerProp write SetIntegerProp stored False;
    property DeviceCode: Integer index 57 read GetIntegerProp write SetIntegerProp stored False;
    property FieldNumber: Integer index 64 read GetIntegerProp write SetIntegerProp stored False;
    property FieldValue: WideString index 67 read GetWideStringProp write SetWideStringProp stored False;
    property FileName: WideString index 68 read GetWideStringProp write SetWideStringProp stored False;
    property LDIndex: Integer index 75 read GetIntegerProp write SetIntegerProp stored False;
    property LDName: WideString index 76 read GetWideStringProp write SetWideStringProp stored False;
    property LDNumber: Integer index 77 read GetIntegerProp write SetIntegerProp stored False;
    property Line1: WideString index 78 read GetWideStringProp write SetWideStringProp stored False;
    property Line1Params: WideString index 79 read GetWideStringProp write SetWideStringProp stored False;
    property Line2: WideString index 80 read GetWideStringProp write SetWideStringProp stored False;
    property Line2Params: WideString index 81 read GetWideStringProp write SetWideStringProp stored False;
    property LineData: WideString index 82 read GetWideStringProp write SetWideStringProp stored False;
    property LineNumber: Integer index 83 read GetIntegerProp write SetIntegerProp stored False;
    property LineSpeed: Integer index 84 read GetIntegerProp write SetIntegerProp stored False;
    property LineType: Integer index 85 read GetIntegerProp write SetIntegerProp stored False;
    property LockDevices: WordBool index 86 read GetWordBoolProp write SetWordBoolProp stored False;
    property LogEnabled: WordBool index 87 read GetWordBoolProp write SetWordBoolProp stored False;
    property LogFileName: WideString index 88 read GetWideStringProp write SetWideStringProp stored False;
    property MessageNumber: Integer index 91 read GetIntegerProp write SetIntegerProp stored False;
    property OutputTime: Integer index 94 read GetIntegerProp write SetIntegerProp stored False;
    property RepeatCount: Integer index 95 read GetIntegerProp write SetIntegerProp stored False;
    property RowNumber: Integer index 98 read GetIntegerProp write SetIntegerProp stored False;
    property SenderID: Integer index 99 read GetIntegerProp write SetIntegerProp stored False;
    property ServerData: WideString index 102 read GetWideStringProp write SetWideStringProp stored False;
    property ServerPort: Integer index 104 read GetIntegerProp write SetIntegerProp stored False;
    property ServerProtocol: Integer index 105 read GetIntegerProp write SetIntegerProp stored False;
    property SoftFileName: WideString index 108 read GetWideStringProp write SetWideStringProp stored False;
    property TableNumber: Integer index 112 read GetIntegerProp write SetIntegerProp stored False;
    property FontBlockNumber: Integer index 115 read GetIntegerProp write SetIntegerProp stored False;
    property FontBlock: WideString index 116 read GetWideStringProp write SetWideStringProp stored False;
    property UpdateBlockNumber: Integer index 124 read GetIntegerProp write SetIntegerProp stored False;
    property UpdateBlock: WideString index 125 read GetWideStringProp write SetWideStringProp stored False;
    property BroadcastEnabled: WordBool index 127 read GetWordBoolProp write SetWordBoolProp stored False;
    property MifareCommand: WideString index 403 read GetWideStringProp write SetWideStringProp stored False;
    property MifareAnswer: WideString index 402 read GetWideStringProp write SetWideStringProp stored False;
    property MifareTimeout: Integer index 404 read GetIntegerProp write SetIntegerProp stored False;
    property OnDataEvent: TPriceCheckerDataEvent read FOnDataEvent write FOnDataEvent;
    property OnLogEvent: TPriceCheckerLogEvent read FOnLogEvent write FOnLogEvent;
  end;

procedure Register;

resourcestring
  dtlServerPage = 'Servers';

  dtlOcxPage = 'ActiveX';

implementation

uses ComObj;

procedure TPriceChecker.InitControlData;
const
  CEventDispIDs: array [0..1] of DWORD = (
    $00000001, $00000002);
  CControlData: TControlData2 = (
    ClassID: '{9BAE502F-761B-4BDD-817E-C65DB03AF592}';
    EventIID: '{06460D54-0487-4A79-AC84-D2E194596C26}';
    EventCount: 2;
    EventDispIDs: @CEventDispIDs;
    LicenseKey: nil (*HR:$00000000*);
    Flags: $00000000;
    Version: 401);
begin
  ControlData := @CControlData;
  TControlData2(CControlData).FirstEventOfs := Cardinal(@@FOnDataEvent) - Cardinal(Self);
end;

procedure TPriceChecker.CreateControl;

  procedure DoCreate;
  begin
    FIntf := IUnknown(OleObject) as IPriceChecker2;
  end;

begin
  if FIntf = nil then DoCreate;
end;

function TPriceChecker.GetControlInterface: IPriceChecker2;
begin
  CreateControl;
  Result := FIntf;
end;

function TPriceChecker.Get_DataBlockSA: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.DataBlockSA;
end;

procedure TPriceChecker.AboutBox;
begin
  DefaultInterface.AboutBox;
end;

function TPriceChecker.AddLD: Integer;
begin
  Result := DefaultInterface.AddLD;
end;

function TPriceChecker.ClientRead: Integer;
begin
  Result := DefaultInterface.ClientRead;
end;

function TPriceChecker.ClientWrite: Integer;
begin
  Result := DefaultInterface.ClientWrite;
end;

function TPriceChecker.CloseClient: Integer;
begin
  Result := DefaultInterface.CloseClient;
end;

function TPriceChecker.CloseServer: Integer;
begin
  Result := DefaultInterface.CloseServer;
end;

function TPriceChecker.Connect: Integer;
begin
  Result := DefaultInterface.Connect;
end;

function TPriceChecker.DeleteLD: Integer;
begin
  Result := DefaultInterface.DeleteLD;
end;

function TPriceChecker.DeviceBySenderID: Integer;
begin
  Result := DefaultInterface.DeviceBySenderID;
end;

function TPriceChecker.Disconnect: Integer;
begin
  Result := DefaultInterface.Disconnect;
end;

function TPriceChecker.GetData: Integer;
begin
  Result := DefaultInterface.GetData;
end;

function TPriceChecker.GetFieldParams: Integer;
begin
  Result := DefaultInterface.GetFieldParams;
end;

function TPriceChecker.GetFieldStruct: Integer;
begin
  Result := DefaultInterface.GetFieldStruct;
end;

function TPriceChecker.GetSenderParams: Integer;
begin
  Result := DefaultInterface.GetSenderParams;
end;

function TPriceChecker.GetStatus: Integer;
begin
  Result := DefaultInterface.GetStatus;
end;

function TPriceChecker.GetTableStruct: Integer;
begin
  Result := DefaultInterface.GetTableStruct;
end;

function TPriceChecker.InitTable: Integer;
begin
  Result := DefaultInterface.InitTable;
end;

function TPriceChecker.LockDevice: Integer;
begin
  Result := DefaultInterface.LockDevice;
end;

function TPriceChecker.OpenClient: Integer;
begin
  Result := DefaultInterface.OpenClient;
end;

function TPriceChecker.OpenServer: Integer;
begin
  Result := DefaultInterface.OpenServer;
end;

function TPriceChecker.ReadFieldsStruct: Integer;
begin
  Result := DefaultInterface.ReadFieldsStruct;
end;

function TPriceChecker.ReadMessage: Integer;
begin
  Result := DefaultInterface.ReadMessage;
end;

function TPriceChecker.ReadTable: Integer;
begin
  Result := DefaultInterface.ReadTable;
end;

function TPriceChecker.Reset: Integer;
begin
  Result := DefaultInterface.Reset;
end;

function TPriceChecker.SaveParams: Integer;
begin
  Result := DefaultInterface.SaveParams;
end;

function TPriceChecker.SendAnswer: Integer;
begin
  Result := DefaultInterface.SendAnswer;
end;

function TPriceChecker.SendBarcode: Integer;
begin
  Result := DefaultInterface.SendBarcode;
end;

function TPriceChecker.SendCommand: Integer;
begin
  Result := DefaultInterface.SendCommand;
end;

function TPriceChecker.SendEvent: Integer;
begin
  Result := DefaultInterface.SendEvent;
end;

function TPriceChecker.ServerWrite: Integer;
begin
  Result := DefaultInterface.ServerWrite;
end;

function TPriceChecker.SetDefaultMessage: Integer;
begin
  Result := DefaultInterface.SetDefaultMessage;
end;

function TPriceChecker.SetDefaults: Integer;
begin
  Result := DefaultInterface.SetDefaults;
end;

function TPriceChecker.SetFieldValue: Integer;
begin
  Result := DefaultInterface.SetFieldValue;
end;

function TPriceChecker.SetIPAddress: Integer;
begin
  Result := DefaultInterface.SetIPAddress;
end;

function TPriceChecker.ShowLine: Integer;
begin
  Result := DefaultInterface.ShowLine;
end;

function TPriceChecker.ShowMessage: Integer;
begin
  Result := DefaultInterface.ShowMessage;
end;

function TPriceChecker.ShowMessage2: Integer;
begin
  Result := DefaultInterface.ShowMessage2;
end;

function TPriceChecker.ShowProperties: Integer;
begin
  Result := DefaultInterface.ShowProperties;
end;

function TPriceChecker.ShowTablesDlg: Integer;
begin
  Result := DefaultInterface.ShowTablesDlg;
end;

function TPriceChecker.TestTCP: Integer;
begin
  Result := DefaultInterface.TestTCP;
end;

function TPriceChecker.UnlockDevice: Integer;
begin
  Result := DefaultInterface.UnlockDevice;
end;

function TPriceChecker.UpdateSoftware: Integer;
begin
  Result := DefaultInterface.UpdateSoftware;
end;

function TPriceChecker.WriteCommand: Integer;
begin
  Result := DefaultInterface.WriteCommand;
end;

function TPriceChecker.WriteMessage: Integer;
begin
  Result := DefaultInterface.WriteMessage;
end;

function TPriceChecker.WriteTable: Integer;
begin
  Result := DefaultInterface.WriteTable;
end;

function TPriceChecker.WriteFontBlock: Integer;
begin
  Result := DefaultInterface.WriteFontBlock;
end;

function TPriceChecker.ReadFontBlock: Integer;
begin
  Result := DefaultInterface.ReadFontBlock;
end;

function TPriceChecker.ShowFontLoaderDlg: Integer;
begin
  Result := DefaultInterface.ShowFontLoaderDlg;
end;

function TPriceChecker.ShowUpdateFirmwareDlg: Integer;
begin
  Result := DefaultInterface.ShowUpdateFirmwareDlg;
end;

function TPriceChecker.UpdateStart: Integer;
begin
  Result := DefaultInterface.UpdateStart;
end;

function TPriceChecker.UpdateEnd: Integer;
begin
  Result := DefaultInterface.UpdateEnd;
end;

function TPriceChecker.GetMode: Integer;
begin
  Result := DefaultInterface.GetMode;
end;

function TPriceChecker.UpdateSendBlock: Integer;
begin
  Result := DefaultInterface.UpdateSendBlock;
end;

function TPriceChecker.ShowSetIPAddressDlg: Integer;
begin
  Result := DefaultInterface.ShowSetIPAddressDlg;
end;

function TPriceChecker.ShowEmbeddedMessageDlg: Integer;
begin
  Result := DefaultInterface.ShowEmbeddedMessageDlg;
end;

function TPriceChecker.SetDefaultFont: Integer;
begin
  Result := DefaultInterface.SetDefaultFont;
end;

function TPriceChecker.ShowXmlLoaderDlg: Integer;
begin
  Result := DefaultInterface.ShowXmlLoaderDlg;
end;

function TPriceChecker.SendMifareCommand: Integer;
begin
  Result := DefaultInterface.SendMifareCommand;
end;

procedure Register;
begin
  RegisterComponents(dtlOcxPage, [TPriceChecker]);
end;

end.

