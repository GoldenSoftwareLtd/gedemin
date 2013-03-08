unit AddIn_TLB;

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
// File generated on 13.06.2003 9:59:07 from Type Library described below.

// ************************************************************************ //
// Type Lib: D:\Golden\DrvVFD\VFD_server.tlb (1)
// IID\LCID: {CE19C7A8-C0FD-4E44-9280-5F6B2F58F3A3}\0
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
  AddInMajorVersion = 1;
  AddInMinorVersion = 0;

  LIBID_AddIn: TGUID = '{CE19C7A8-C0FD-4E44-9280-5F6B2F58F3A3}';

  IID_IVFD_Display: TGUID = '{0CDC4B6F-79B3-4F25-9B21-8A8CDE753651}';
  CLASS_VFD_Display: TGUID = '{885030A8-03F6-4081-9858-F508700C2F9E}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IVFD_Display = interface;
  IVFD_DisplayDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  VFD_Display = IVFD_Display;


// *********************************************************************//
// Interface: IVFD_Display
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {0CDC4B6F-79B3-4F25-9B21-8A8CDE753651}
// *********************************************************************//
  IVFD_Display = interface(IDispatch)
    ['{0CDC4B6F-79B3-4F25-9B21-8A8CDE753651}']
    function  Get_PortNumber: Smallint; safecall;
    procedure Set_PortNumber(Value: Smallint); safecall;
    function  Get_BaudRate: Integer; safecall;
    procedure Set_BaudRate(Value: Integer); safecall;
    procedure ClearDisplay; safecall;
    function  Get_PortEnabled: WordBool; safecall;
    procedure Set_PortEnabled(Value: WordBool); safecall;
    procedure WriteText(const Text: WideString); safecall;
    procedure WriteToUpperLine(const Text: WideString); safecall;
    procedure WriteToLowerLine(const Text: WideString); safecall;
    function  Get_DisplayMode: Smallint; safecall;
    procedure Set_DisplayMode(Value: Smallint); safecall;
    procedure InitializeDisplay; safecall;
    procedure MoveCursorTo(aPos: Smallint); safecall;
    procedure MoveCursorToPos(column: Smallint; row: Smallint); safecall;
    property PortNumber: Smallint read Get_PortNumber write Set_PortNumber;
    property BaudRate: Integer read Get_BaudRate write Set_BaudRate;
    property PortEnabled: WordBool read Get_PortEnabled write Set_PortEnabled;
    property DisplayMode: Smallint read Get_DisplayMode write Set_DisplayMode;
  end;

// *********************************************************************//
// DispIntf:  IVFD_DisplayDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {0CDC4B6F-79B3-4F25-9B21-8A8CDE753651}
// *********************************************************************//
  IVFD_DisplayDisp = dispinterface
    ['{0CDC4B6F-79B3-4F25-9B21-8A8CDE753651}']
    property PortNumber: Smallint dispid 1;
    property BaudRate: Integer dispid 2;
    procedure ClearDisplay; dispid 3;
    property PortEnabled: WordBool dispid 4;
    procedure WriteText(const Text: WideString); dispid 5;
    procedure WriteToUpperLine(const Text: WideString); dispid 6;
    procedure WriteToLowerLine(const Text: WideString); dispid 7;
    property DisplayMode: Smallint dispid 8;
    procedure InitializeDisplay; dispid 9;
    procedure MoveCursorTo(aPos: Smallint); dispid 10;
    procedure MoveCursorToPos(column: Smallint; row: Smallint); dispid 11;
  end;

// *********************************************************************//
// The Class CoVFD_Display provides a Create and CreateRemote method to          
// create instances of the default interface IVFD_Display exposed by              
// the CoClass VFD_Display. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoVFD_Display = class
    class function Create: IVFD_Display;
    class function CreateRemote(const MachineName: string): IVFD_Display;
  end;

implementation

uses ComObj;

class function CoVFD_Display.Create: IVFD_Display;
begin
  Result := CreateComObject(CLASS_VFD_Display) as IVFD_Display;
end;

class function CoVFD_Display.CreateRemote(const MachineName: string): IVFD_Display;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_VFD_Display) as IVFD_Display;
end;

end.
