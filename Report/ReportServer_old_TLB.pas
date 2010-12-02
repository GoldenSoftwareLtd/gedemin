unit ReportServer_TLB;

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
// Type Lib: D:\GOLDEN\GEDEMIN\Report\ReportServer.tlb (1)
// IID\LCID: {FB3EDE37-0642-11D5-AE91-006052067F0D}\0
// Helpfile: 
// DepndLst: 
//   (1) v2.0 stdole, (C:\WINNT\System32\StdOle2.Tlb)
//   (2) v4.0 StdVCL, (C:\WINNT\System32\STDVCL40.DLL)
//   (3) v1.0 gdQueryList, (D:\GOLDEN\GEDEMIN\Report\ReportClient.exe)
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
interface

uses Windows, ActiveX, Classes, Graphics, OleServer, OleCtrls, StdVCL, 
  gdQueryList_TLB;

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  ReportServerMajorVersion = 1;
  ReportServerMinorVersion = 0;

  LIBID_ReportServer: TGUID = '{FB3EDE37-0642-11D5-AE91-006052067F0D}';

  IID_IgdReportServer: TGUID = '{FB3EDE38-0642-11D5-AE91-006052067F0D}';
  CLASS_gdReportServer: TGUID = '{FB3EDE3A-0642-11D5-AE91-006052067F0D}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IgdReportServer = interface;
  IgdReportServerDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  gdReportServer = IgdReportServer;


// *********************************************************************//
// Interface: IgdReportServer
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {FB3EDE38-0642-11D5-AE91-006052067F0D}
// *********************************************************************//
  IgdReportServer = interface(IDispatch)
    ['{FB3EDE38-0642-11D5-AE91-006052067F0D}']
    function  GetReportResult(ReportKey: Integer; var Param: OleVariant; 
                              out ReportResult: OleVariant): WordBool; safecall;
  end;

// *********************************************************************//
// DispIntf:  IgdReportServerDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {FB3EDE38-0642-11D5-AE91-006052067F0D}
// *********************************************************************//
  IgdReportServerDisp = dispinterface
    ['{FB3EDE38-0642-11D5-AE91-006052067F0D}']
    function  GetReportResult(ReportKey: Integer; var Param: OleVariant; 
                              out ReportResult: OleVariant): WordBool; dispid 1;
  end;

// *********************************************************************//
// The Class CogdReportServer provides a Create and CreateRemote method to          
// create instances of the default interface IgdReportServer exposed by              
// the CoClass gdReportServer. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CogdReportServer = class
    class function Create: IgdReportServer;
    class function CreateRemote(const MachineName: string): IgdReportServer;
  end;

implementation

uses ComObj;

class function CogdReportServer.Create: IgdReportServer;
begin
  Result := CreateComObject(CLASS_gdReportServer) as IgdReportServer;
end;

class function CogdReportServer.CreateRemote(const MachineName: string): IgdReportServer;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_gdReportServer) as IgdReportServer;
end;

end.
