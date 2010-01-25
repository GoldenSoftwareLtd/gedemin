unit HHCTRLLib_TLB;

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
// File generated on 11.12.02 17:15:53 from Type Library described below.

// ************************************************************************ //
// Type Lib: C:\WINXP\System32\hhctrl.ocx (1)
// IID\LCID: {ADB880A2-D8FF-11CF-9377-00AA003B7A11}\0
// Helpfile: 
// DepndLst: 
//   (1) v2.0 stdole, (C:\WINXP\System32\stdole2.tlb)
//   (2) v4.0 StdVCL, (C:\WINXP\System32\STDVCL40.DLL)
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
  HHCTRLLibMajorVersion = 4;
  HHCTRLLibMinorVersion = 0;

  LIBID_HHCTRLLib: TGUID = '{ADB880A2-D8FF-11CF-9377-00AA003B7A11}';

  DIID__HHCtrlEvents: TGUID = '{ADB880A3-D8FF-11CF-9377-00AA003B7A11}';
  IID_IHHCtrl: TGUID = '{ADB880A1-D8FF-11CF-9377-00AA003B7A11}';
  CLASS_HHCtrl: TGUID = '{ADB880A6-D8FF-11CF-9377-00AA003B7A11}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  _HHCtrlEvents = dispinterface;
  IHHCtrl = interface;
  IHHCtrlDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  HHCtrl = IHHCtrl;


// *********************************************************************//
// Declaration of structures, unions and aliases.                         
// *********************************************************************//

  UINT_PTR = LongWord; 
  LONG_PTR = Integer; 

// *********************************************************************//
// DispIntf:  _HHCtrlEvents
// Flags:     (4096) Dispatchable
// GUID:      {ADB880A3-D8FF-11CF-9377-00AA003B7A11}
// *********************************************************************//
  _HHCtrlEvents = dispinterface
    ['{ADB880A3-D8FF-11CF-9377-00AA003B7A11}']
    procedure Click(const ParamString: WideString); dispid 0;
  end;

// *********************************************************************//
// Interface: IHHCtrl
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {ADB880A1-D8FF-11CF-9377-00AA003B7A11}
// *********************************************************************//
  IHHCtrl = interface(IDispatch)
    ['{ADB880A1-D8FF-11CF-9377-00AA003B7A11}']
    procedure Set_Image(const path: WideString); safecall;
    function  Get_Image: WideString; safecall;
    procedure Click; safecall;
    procedure HHClick; safecall;
    procedure Print; safecall;
    procedure syncURL(const pszUrl: WideString); safecall;
    procedure TCard(wParam: UINT_PTR; lParam: LONG_PTR); safecall;
    procedure TextPopup(const pszText: WideString; const pszFont: WideString; horzMargins: SYSINT; 
                        vertMargins: SYSINT; clrForeground: LongWord; clrBackground: LongWord); safecall;
    property Image: WideString read Get_Image write Set_Image;
  end;

// *********************************************************************//
// DispIntf:  IHHCtrlDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {ADB880A1-D8FF-11CF-9377-00AA003B7A11}
// *********************************************************************//
  IHHCtrlDisp = dispinterface
    ['{ADB880A1-D8FF-11CF-9377-00AA003B7A11}']
    property Image: WideString dispid 1;
    procedure Click; dispid 5;
    procedure HHClick; dispid 9;
    procedure Print; dispid 6;
    procedure syncURL(const pszUrl: WideString); dispid 4;
    procedure TCard(wParam: UINT_PTR; lParam: LONG_PTR); dispid 7;
    procedure TextPopup(const pszText: WideString; const pszFont: WideString; horzMargins: SYSINT; 
                        vertMargins: SYSINT; clrForeground: LongWord; clrBackground: LongWord); dispid 8;
  end;


// *********************************************************************//
// OLE Control Proxy class declaration
// Control Name     : THHCtrl
// Help String      : HHCtrl Class
// Default Interface: IHHCtrl
// Def. Intf. DISP? : No
// Event   Interface: _HHCtrlEvents
// TypeFlags        : (2) CanCreate
// *********************************************************************//
  THHCtrlClick = procedure(Sender: TObject; const ParamString: WideString) of object;

  THHCtrl = class(TOleControl)
  private
    FOnClick: THHCtrlClick;
    FIntf: IHHCtrl;
    function  GetControlInterface: IHHCtrl;
  protected
    procedure CreateControl;
    procedure InitControlData; override;
  public
    procedure Click;
    procedure HHClick;
    procedure Print;
    procedure syncURL(const pszUrl: WideString);
    procedure TCard(wParam: UINT_PTR; lParam: LONG_PTR);
    procedure TextPopup(const pszText: WideString; const pszFont: WideString; horzMargins: SYSINT; 
                        vertMargins: SYSINT; clrForeground: LongWord; clrBackground: LongWord);
    property  ControlInterface: IHHCtrl read GetControlInterface;
    property  DefaultInterface: IHHCtrl read GetControlInterface;
  published
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
    property Image: WideString index 1 read GetWideStringProp write SetWideStringProp stored False;
    property OnClick: THHCtrlClick read FOnClick write FOnClick;
  end;

procedure Register;

implementation

uses ComObj;

procedure THHCtrl.InitControlData;
const
  CEventDispIDs: array [0..0] of DWORD = (
    $00000000);
  CControlData: TControlData2 = (
    ClassID: '{ADB880A6-D8FF-11CF-9377-00AA003B7A11}';
    EventIID: '{ADB880A3-D8FF-11CF-9377-00AA003B7A11}';
    EventCount: 1;
    EventDispIDs: @CEventDispIDs;
    LicenseKey: nil (*HR:$8007000E*);
    Flags: $00000000;
    Version: 401);
begin
  ControlData := @CControlData;
  TControlData2(CControlData).FirstEventOfs := Cardinal(@@FOnClick) - Cardinal(Self);
end;

procedure THHCtrl.CreateControl;

  procedure DoCreate;
  begin
    FIntf := IUnknown(OleObject) as IHHCtrl;
  end;

begin
  if FIntf = nil then DoCreate;
end;

function THHCtrl.GetControlInterface: IHHCtrl;
begin
  CreateControl;
  Result := FIntf;
end;

procedure THHCtrl.Click;
begin
  DefaultInterface.Click;
end;

procedure THHCtrl.HHClick;
begin
  DefaultInterface.HHClick;
end;

procedure THHCtrl.Print;
begin
  DefaultInterface.Print;
end;

procedure THHCtrl.syncURL(const pszUrl: WideString);
begin
  DefaultInterface.syncURL(pszUrl);
end;

procedure THHCtrl.TCard(wParam: UINT_PTR; lParam: LONG_PTR);
begin
  DefaultInterface.TCard(wParam, lParam);
end;

procedure THHCtrl.TextPopup(const pszText: WideString; const pszFont: WideString; 
                            horzMargins: SYSINT; vertMargins: SYSINT; clrForeground: LongWord; 
                            clrBackground: LongWord);
begin
  DefaultInterface.TextPopup(pszText, pszFont, horzMargins, vertMargins, clrForeground, 
                             clrBackground);
end;

procedure Register;
begin
  RegisterComponents('ActiveX',[THHCtrl]);
end;

end.
