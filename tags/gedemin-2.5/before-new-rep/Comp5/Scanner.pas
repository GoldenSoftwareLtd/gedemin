(*
TScanner, a component interface to a TWAIN compliant scanner.
Copyright (C) 2000, Oliver George

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Library General Public
License as published by the Free Software Foundation; either
version 2 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Library General Public License for more details.

You should have received a copy of the GNU Library General Public
License along with this library; if not, write to the
Free Software Foundation, Inc., 59 Temple Place - Suite 330,
Boston, MA  02111-1307, USA.

==================================================================
That was the license, general implications are:
- free to use
- free to modify
- source code of this library (not your whole app) must be available.

*)

unit Scanner;

(*

  HOMEPAGE...
  -----------
  http://tscanner.sourceforge.net

  This site links to:
  - mailing lists,
  - a cvs repositry (for developers of tscanner),
  - release downloads (for users of tscanner),
  - bug reporting/tracking,
  - feature request/report/tracking.

  REFERENCES...
  -------------
  Comments of the form {ref:1-61} are references to documentation, the first
  Number indicates one of the references listed here, the second is a pointer
  in that reference (ie. a page number or a figure...)


  REFERENCE LIST...
  --------------------
  1. TWAIN Specification Version 1.8, avaliable at www.twain.org

*)

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  twain, syncobjs;

type

  TScannerUnits = (UN_INCHES, UN_CENTIMETERS, UN_PICAS,
                   UN_POINTS, UN_TWIPS, UN_PIXELS);

  TImageAcquiredEvent = procedure (Sender: TObject; hDib: HBITMAP) of object;

  TScanner = class(TComponent)
  private      
    FDefaultState: integer;
    FSettingUnits: TScannerUnits;
    FSettingLayoutArea: array[0..3] of double;
    FSettingLayoutAll: boolean;
    FSettingDPI: integer; {resolution, both x and y direction}
    FSettingBPP: integer; {bits per pixel}
    FSettingColour: boolean; {colour vs gray/bw}
    FSettingCaptureCount: integer; {number of images to scan, -1 for auto}
    dllHandle  : THandle;
    State      : integer;
    FOnMessage : TMessageEvent;
    FOnImageAcquired: TImageAcquiredEvent;
    FOnAcquireComplete: TNotifyEvent;
    event_xferReady: TSimpleEvent;
    sysCaps: array of TW_CAPABILITY; {for storing/reloading system capabilities}
    sysImageLayout: TW_IMAGELAYOUT;
    procedure ProcessMessage(var message: TMsg; var Handled: Boolean);
    procedure resetCapabilities;
    function LoadOurCapabilities: boolean;
    function GetLayoutAreaCoordinate(Index: Integer): double;
    procedure SetLayoutAreaCoordinate(Index: Integer; Value: double);
    function SetCapabilityBOOL(cap: TW_UINT16; val: TW_BOOL): boolean;
    function SetCapabilityINT16(cap: TW_UINT16; val: TW_INT16): boolean;
    function SetCapabilityUINT16(cap: TW_UINT16; val: TW_UINT16): boolean;
    function SetCapabilityFIX32(cap: TW_UINT16; val: TW_FIX32): boolean;
    function SetCapabilityFIX32asDouble(cap: TW_UINT16; val: Double): boolean;
    function SetCapability(cap: TW_UINT16; itemType: TW_UINT16; val: TW_UINT32): boolean;
    function GetCurrentCapabilityUINT16(cap: TW_UINT16; var val: pTW_UINT16): TW_UINT16;
    function GetCurrentCapabilityFIX32(cap: TW_UINT16; var val: pTW_FIX32): TW_UINT16;
    function GetCurrentCapability(cap:TW_UINT16; itemType:TW_UINT16; var val: pTW_UINT32): TW_UINT16;
    function get_SettingColour: boolean;
    procedure set_SettingColour(b: boolean);
    function get_SettingBPP: integer;
    procedure set_SettingBPP(b: integer);
    function get_SettingDPI: integer;
    procedure set_SettingDPI(b: integer);
    function get_ScannerName: string;
    procedure set_ScannerName(n: string);
    function get_SettingShowUI: boolean;
    procedure set_SettingShowUI(b: boolean);
    function get_SettingLayoutAll: boolean;
    procedure set_SettingLayoutAll(b: boolean);
    function doubleToFIX32(d:double): TW_FIX32;
    function FIX32ToDouble(f:TW_FIX32): double;
    function get_SettingUnits: TScannerUnits;
    procedure set_SettingUnits(b: TScannerUnits);
    function get_ScanCapable: boolean;
    function get_PhysicalWidth: double;
    function get_PhysicalHeight: double;
    function get_Ready: boolean;
  protected
    DSM_Entry    : TDSMEntryProc;    // interface function for the twain dll
    appID        : TW_IDENTITY;      // Application
    dsID         : TW_IDENTITY;      // Data source
    UI           : TW_USERINTERFACE; // User interface
    function  TWAIN_IMAGENATIVEXFER(var hNative: HBITMAP): boolean; { =6 }
    function  TWAIN_USERSELECT: boolean; { =3 }
    procedure OnXferReady;   virtual;
    procedure OnCloseDSReq;  virtual;
    procedure OnCloseDSOK;   virtual;
    procedure OnDeviceEvent; virtual;
    function  goto_state(new_state: integer): boolean;
    procedure storeProfile;
    procedure restoreProfile;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    property twainState: integer read state;
    function  selectSource: boolean;
    function  Acquire: boolean;
    function  Enable: boolean;
    function  Disable: boolean;
  published
    property Ready: boolean read get_ready;
    property PhysicalWidth: double read get_PhysicalWidth;
    property PhysicalHeight: double read get_PhysicalHeight;
    property ScanCapable: boolean read get_ScanCapable;
    property SettingUnits: TScannerUnits read get_SettingUnits write set_SettingUnits;
    property SettingLayoutAll: boolean read get_SettingLayoutAll write set_SettingLayoutAll;
    property SettingLayoutTop: double index 0 read GetLayoutAreaCoordinate write SetLayoutAreaCoordinate;
    property SettingLayoutLeft: double index 1 read GetLayoutAreaCoordinate write SetLayoutAreaCoordinate;
    property SettingLayoutBottom: double index 2 read GetLayoutAreaCoordinate write SetLayoutAreaCoordinate;
    property SettingLayoutRight: double index 3 read GetLayoutAreaCoordinate write SetLayoutAreaCoordinate;
    property SettingShowUI: boolean read get_SettingShowUI write set_SettingShowUI;
    property ScannerName: string read get_ScannerName write set_ScannerName;
    property SettingDPI: integer read get_SettingDPI write set_SettingDPI;
    property SettingBPP: integer read get_SettingBPP write set_SettingBPP;
    property SettingColour: boolean read get_SettingColour write set_SettingColour;
    property SettingCaptureCount: integer read FSettingCaptureCount write FSettingCaptureCount;
    property OnImageAcquired: TImageAcquiredEvent read FOnImageAcquired write FOnImageAcquired;
    property OnAcquireComplete: TNotifyEvent read FOnAcquireComplete write FOnAcquireComplete;
  end;

  TScannerThread = class (TThread)
  private
    FScanner: TScanner;
    hNative: HBITMAP;
    procedure doOnImageAcquire;
    procedure goto_state_3;
    procedure goto_state_default;
  public
    procedure Execute; override;
  end;

type
  TScannerState = (ssEnabled, ssDisabled, ssNotKnown);

var
  ScannerState: TScannerState;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TWAIN', [TScanner]);
end;

///////////////////////////////////////////////////////////////////////////

function TScanner.goto_state(new_state: integer): boolean;
(*
  { twain state change functions ( >5 controlled by source not app ) }
  {1->2} function LOADDLL(): boolean;
  {2->3} function OPENDSM(): boolean;
  {3->4} function OPENDS(): boolean;
  {4->5} function ENABLEDS(): boolean;
  {5->4} function DISABLEDS(): boolean;
  {6->5} function PENDINGXFER_RESET(): boolean;
  {4->3} function CLOSEDS(): boolean;
  {3->2} function CLOSEDSM(): boolean;
  {2->1} function FREEDLL(): boolean;
*)
  function LOADDLL(): boolean;
  begin
    if state=1 then
    begin
      dllHandle := LoadLibrary('twain_32.dll');
      if dllHandle <> 0 then
      begin
        @DSM_Entry := GetProcAddress(dllHandle, 'DSM_Entry');
        state := 2;
      end;
    end;
    result := state=2;
  end;

  function FREEDLL(): boolean;
  begin
    if state=2 then
    begin
      FreeLibrary(dllHandle);
      state := 1;
    end;
    result := state=1;
  end;

  function OPENDSM(): boolean;
  begin
    if state=2 then
    begin
      AppID.Id := 0;
      if (DSM_Entry(@AppID, nil, DG_CONTROL, DAT_PARENT, MSG_OPENDSM, @(application.handle)) = TWRC_SUCCESS) then
        state := 3;
    end;
    result := state=3;
  end;

  function CLOSEDSM(): boolean;
  begin
    if state=3 then
      if (DSM_Entry(@AppID, nil, DG_CONTROL, DAT_PARENT, MSG_CLOSEDSM, @(application.handle)) = TWRC_SUCCESS) then
        state := 2;
    result := state=2;
  end;

  function OPENDS(): boolean;
  begin
    if state=3 then
    begin
      dsID.Id := 0;
      if (DSM_Entry(@AppID, nil, DG_CONTROL, DAT_IDENTITY, MSG_OPENDS, @dsID) = TWRC_SUCCESS) then
      begin
        state := 4;
        storeProfile;  
        resetCapabilities;
        LoadOurCapabilities;
      end;
    end;
    result := state=4;
  end;

  function CLOSEDS(): boolean;
  begin
    if state=4 then
    begin
      restoreProfile;
      if (DSM_Entry(@AppID, nil, DG_CONTROL, DAT_IDENTITY, MSG_CLOSEDS, @dsID) = TWRC_SUCCESS) then
        state := 3;
    end;
    result := state=3;
  end;

  function ENABLEDS(): boolean;
  begin
    if state=4 then
    begin
      if ( DSM_Entry(@AppID, @dsID, DG_CONTROL, DAT_USERINTERFACE, MSG_ENABLEDS, @UI) = TWRC_SUCCESS) then
        state := 5;
    end;
  result := state=5;
  end;

  function DISABLEDS(): boolean;
  begin
    if state=5 then
      if (DSM_Entry(@AppID, @dsID, DG_CONTROL, DAT_USERINTERFACE, MSG_DISABLEDS, @UI) = TWRC_SUCCESS) then
        state := 4;
    result := state=4;
  end;

begin
  if State < 7 then
  begin
    if state < new_state then begin
      {going up}
      case new_state of
        5: begin LOADDLL;OPENDSM;OPENDS;ENABLEDS; end;
        4: begin LOADDLL;OPENDSM;OPENDS; end;
        3: begin LOADDLL;OPENDSM; end;
        2: begin LOADDLL; end;
      end;
    end else begin
      {going down}
      case new_state of
        4: begin DISABLEDS; end;
        3: begin DISABLEDS;CLOSEDS; end;
        2: begin DISABLEDS;CLOSEDS;CLOSEDSM; end;
        1: begin DISABLEDS;CLOSEDS;CLOSEDSM;FREEDLL; end;
      end;
    end;
  end;
  result := state=new_state;
end;

function TScanner.TWAIN_USERSELECT(): boolean;
begin
  result := false;
  if state=3 then
  begin
    dsID.Id := 0;
    {preset dsid.ProductName to select a default scanner}
    {this call blocks while the source select window is open}
    if (DSM_Entry(@AppID, nil, DG_CONTROL, DAT_IDENTITY, MSG_USERSELECT, @dsID) = TWRC_SUCCESS) then
    begin
      {store dsid.productname to record the selected scanner between sessions}
      result := true;
    end;
  end;
end;

procedure TScanner.ProcessMessage(var message: TMsg; var Handled: Boolean);
var
  twEvent: TW_EVENT;
  rs: TW_UINT16;
begin
  if Assigned(FOnMessage) then FOnMessage(message, Handled);
  if (State > 4) and (not Handled) then
  begin

    twEvent.pEvent := @message;
    twEvent.TWMessage := MSG_NULL;

    rs := DSM_Entry(@AppID, @dsID, DG_CONTROL, DAT_EVENT, MSG_PROCESSEVENT, @twEvent);

    if (rs = TWRC_DSEVENT) then
    begin
      Handled := true;
      case twEvent.TWMessage of
        MSG_XFERREADY: begin {ref:1-p61}
          state := 6;
          event_xferReady.SetEvent;
          OnXferReady;
        end;
        MSG_CLOSEDSREQ: begin
          goto_state(4);
          OnCloseDSReq;
        end;
        MSG_CLOSEDSOK: begin
          OnCloseDSOK;
        end;
        MSG_DEVICEEVENT: begin
          OnDeviceEvent;
        end;
        MSG_NULL: begin
          OnCloseDSOK;
        end;
      end;
    end;

  end;
end;

procedure TScanner.resetCapabilities;
type UINT16_array = array[0..1] of TW_UINT16;
var
  index: integer;
  il: TW_IMAGELAYOUT;
  scCap, cvCap: TW_CAPABILITY;
  parr: ^TW_ARRAY;
  pItemList: ^UINT16_array;
begin
  scCap.Cap        := CAP_SUPPORTEDCAPS;
  scCap.ConType    := TWON_DONTCARE16;
  scCap.hContainer := 0;
  if (DSM_Entry(@AppID, @dsID, DG_CONTROL, DAT_CAPABILITY, MSG_GET, @scCap) = TWRC_SUCCESS) then
  begin
    parr := GlobalLock(scCap.hContainer);
    SetLength(sysCaps, parr.NumItems);
    pItemList := @(parr.ItemList);
    for index := 0 to parr.NumItems-1 do
    begin
      cvCap.cap        := pItemList[index];
      cvCap.ConType    := TWON_DONTCARE16;
      cvCap.hContainer := 0;
      DSM_Entry(@AppID, @dsID, DG_CONTROL, DAT_CAPABILITY, MSG_RESET, @cvCap);
    end;
  end;
  DSM_Entry(@AppID, @dsID, DG_IMAGE, DAT_IMAGELAYOUT, MSG_RESET, @il);
end;


{  LoadOurCapabilities
   - DONT FORGET THAT THESE ARE REQUESTS, THE SOURCE WILL TRY AND ACCOMODATE
     AS BEST IT CAN. }
function TScanner.LoadOurCapabilities(): boolean;
var
  ImageLayout: TW_IMAGELAYOUT;
begin
  result := false;
  if state=4 then
  begin
    result := true;

    {these lines act to assign current values to values, since this is
     done in stage 4 the settings will be loaded into the data source}

    // set units for other capability sets
    SettingUnits := FSettingUnits;

    // turn progress information for background (silent) mode
    SetCapabilityBOOL(CAP_INDICATORS, false);

    // resolution...
    SettingDPI := FSettingDPI;
    SettingBPP := FSettingBPP;
    SettingColour := FSettingColour;

    if FSettingLayoutAll then
    begin
      DSM_Entry(@AppID, @dsID, DG_IMAGE, DAT_IMAGELAYOUT, MSG_RESET, @ImageLayout);
    end else begin
      DSM_Entry(@AppID, @dsID, DG_IMAGE, DAT_IMAGELAYOUT, MSG_GET, @ImageLayout);
      ImageLayout.Frame.Top    := doubleToFIX32(FSettingLayoutArea[0]); {inches}
      ImageLayout.Frame.Left   := doubleToFIX32(FSettingLayoutArea[1]); {inches}
      ImageLayout.Frame.Bottom := doubleToFIX32(FSettingLayoutArea[2]); {inches}
      ImageLayout.Frame.Right  := doubleToFIX32(FSettingLayoutArea[3]); {inches}
      DSM_Entry(@AppID, @dsID, DG_IMAGE, DAT_IMAGELAYOUT, MSG_SET, @ImageLayout); {ref:1-97}
    end;
  end;
end;

{ TWAIN_IMAGENATIVEXFER
  - this function blocks while the image is being acquired }
function TScanner.TWAIN_IMAGENATIVEXFER(var hNative: HBITMAP): boolean;

  procedure DoEndXfer;
  var
    pendingXfers: TW_PENDINGXFERS;
  begin
    if (DSM_Entry(@AppID, @dsID, DG_CONTROL, DAT_PENDINGXFERS, MSG_ENDXFER, @pendingxfers)=TWRC_SUCCESS) then
      if pendingxfers.Count = 0 then
        state := 5
      else
        state := 6;
  end;

var
  rs: TW_UINT16;
begin
  result := false;
  if state=6 then
  begin
    {this call blocks while the image is captured}
    rs := DSM_Entry(@AppID, @dsID, DG_IMAGE, DAT_IMAGENATIVEXFER, MSG_GET, @hNative);
    case rs of
      TWRC_XFERDONE: begin {ref:1-p63}
        state := 7;
        {hNative is valid, application must deallocate memory}
        result := true;
        {acknoledge the end of transfer}
        DoEndXfer;
      end;
      TWRC_CANCEL: begin {ref:1-p64}
        state := 7;
        {hNative is invalid but allocated, application must deallocate}
        GlobalFree(hNative);
        result := false;
        {must acknoledge the end of transfer}
        DoEndXfer;
      end;
      TWRC_FAILURE: begin {ref:1-p65}
        {no state transition occurred - still in 6}
        {hNative is invalid, no memory was allocated}
        result := false;
        {condition code could be checked}
        {image is still pending... we could renegotiate stuff and retry, based
         on the error reported, but for now lets just terminate the transfer
         session}
        goto_state(5);
      end;
    end;
  end;
end;

///////////////////////////////////////////////////////////////////////////
constructor TScanner.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  if not (csDesigning in ComponentState) then
  begin
    {hook into applications event loop}
    FOnMessage := application.OnMessage;
    application.OnMessage := ProcessMessage;

    {set default state}
    state := 1;

    {Set _required_ AppID properties}
    AppID.Id:=0;
    AppID.ProtocolMajor   := TWON_PROTOCOLMAJOR;
    AppID.ProtocolMinor   := TWON_PROTOCOLMINOR;
    AppID.SupportedGroups := DG_CONTROL or DG_IMAGE;

    {set User interface defaults}
    UI.hParent := application.handle;

    event_xferReady := TSimpleEvent.Create;

    {set some backup defaults}
    SettingShowUI := false;
    FSettingLayoutAll := true;
    FSettingUnits := UN_INCHES;

    FDefaultState := 1;
    goto_state(FDefaultState);
  end;
end;

destructor TScanner.Destroy;
begin
  if not (csDesigning in ComponentState) then
  begin
    application.OnMessage := FOnMessage;
    goto_state(1);
  end;

  inherited Destroy;
end;

procedure TScanner.OnCloseDSOK;
begin

end;

procedure TScanner.OnCloseDSReq;
begin

end;

procedure TScanner.OnDeviceEvent;
begin

end;

procedure TScanner.OnXferReady;
begin

end;


function TScanner.SetCapability(cap, itemType: TW_UINT16; val: TW_UINT32): boolean;
var
  twCap: TW_CAPABILITY;
  pval: pTW_ONEVALUE;
  twStatus: TW_STATUS;
begin
  result := false;
  if state=4 then
  begin
    twcap.Cap        := cap;
    twcap.ConType    := TWON_ONEVALUE;
    twcap.hContainer := GlobalAlloc(GMEM_MOVEABLE, sizeof(TW_ONEVALUE));
    pval := GlobalLock(twcap.hContainer);
    pval.ItemType := itemType;
    pval.Item := val;
    case DSM_Entry(@AppID, @dsID, DG_CONTROL, DAT_CAPABILITY, MSG_SET, @twcap) of
      TWRC_SUCCESS: begin
        result := true;
      end;
      TWRC_CHECKSTATUS: begin
        result := true;
      end;
      TWRC_FAILURE: begin
        {look at error code}
        DSM_Entry(@AppID, @dsID, DG_CONTROL, DAT_STATUS, MSG_GET, @twStatus);
        case twStatus.ConditionCode of
          TWCC_BADCAP:          application.Title := 'TWCC_BADCAP';
          TWCC_CAPUNSUPPORTED:  application.Title := 'TWCC_CAPUNSUPPORTED';
          TWCC_CAPBADOPERATION: application.Title := 'TWCC_CAPBADOPERATION';
          TWCC_CAPSEQERROR:     application.Title := 'TWCC_CAPSEQERROR';
          TWCC_BADDEST:         application.Title := 'TWCC_BADDEST';
          TWCC_BADVALUE:        application.Title := 'TWCC_BADVALUE';
          TWCC_SEQERROR:        application.Title := 'TWCC_SEQERROR';
        end;
      end;
    end;
    GlobalUnlock(twcap.hContainer);
    GlobalFree(twcap.hContainer);
  end;
end;

function TScanner.SetCapabilityBOOL(cap: TW_UINT16; val: TW_BOOL): boolean;
begin
  result := SetCapability(cap, TWTY_BOOL, TW_UINT32(val));
end;

function TScanner.SetCapabilityINT16(cap: TW_UINT16; val: TW_INT16): boolean;
begin
  result := SetCapability(cap, TWTY_INT16, TW_UINT32(val));
end;

function TScanner.SetCapabilityUINT16(cap, val: TW_UINT16): boolean;
begin
  result := SetCapability(cap, TWTY_UINT16, TW_UINT32(val));
end;

function TScanner.SetCapabilityFIX32(cap: TW_UINT16; val: TW_FIX32): boolean;
begin
  result := SetCapability(cap, TWTY_FIX32, TW_UINT32(val));
end;

function TScanner.SetCapabilityFIX32asDouble(cap: TW_UINT16; val: Double): boolean;
begin
  result := SetCapabilityFIX32(cap, doubletofix32(val));
end;

function TScanner.GetCurrentCapabilityUINT16(cap: TW_UINT16; var val: pTW_UINT16): TW_UINT16;
begin
  result := GetCurrentCapability(cap, TWTY_UINT16, pTW_UINT32(val));
end;

function TScanner.GetCurrentCapabilityFIX32(cap: TW_UINT16; var val: pTW_FIX32): TW_UINT16;
begin
  result := GetCurrentCapability(cap, TWTY_FIX32, pTW_UINT32(val));
end;


function TScanner.GetCurrentCapability(cap:TW_UINT16; itemType:TW_UINT16; var val: pTW_UINT32): TW_UINT16;
var
  twCap: TW_CAPABILITY;
  pval: pTW_ONEVALUE;  
  prval: pTW_RANGE;
  twStatus: TW_STATUS;
begin
  twCap.cap        := cap;
  twCap.ConType    := TWON_ONEVALUE;
  twCap.hContainer := 0;
  if (DSM_Entry(@AppID, @dsID, DG_CONTROL, DAT_CAPABILITY, MSG_GETCURRENT, @twCap) = TWRC_SUCCESS) then
  begin
    case twCap.ConType of
      TWON_ONEVALUE: begin
        pval := GlobalLock(twCap.hContainer);
        if pval.ItemType=itemType then
        begin
          val^ := pval.Item;
        end else begin
          {should really handle this possibility}
        end;
        GlobalUnlock(twCap.hContainer);
        GlobalFree(twCap.hContainer);
      end;
      TWON_RANGE: begin
        prval := GlobalLock(twCap.hContainer);
        if prval.ItemType=itemType then
        begin
          val^ := prval.CurrentValue;
        end else begin
          {should really handle this possibility}
        end;
        GlobalUnlock(twCap.hContainer);
        GlobalFree(twCap.hContainer);
      end;
    else ;
    end;
  end;
  DSM_Entry(@AppID, @dsID, DG_CONTROL, DAT_STATUS, MSG_GET, @twStatus);
  result := twStatus.ConditionCode; {look for TWCC_SUCCESS}
end;

procedure TScanner.restoreProfile;
var index: integer;
begin
  if state=4 then
  begin
    for index := low(sysCaps) to high(sysCaps) do
    begin
      DSM_Entry(@AppID, @dsID, DG_CONTROL, DAT_CAPABILITY, MSG_SET, @(sysCaps[index]));
    end;
    DSM_Entry(@AppID, @dsID, DG_IMAGE, DAT_IMAGELAYOUT, MSG_SET, @sysImageLayout);
    if length(sysCaps) > 0 then
      for index := high(sysCaps) to low(sysCaps) do
      begin
        if (sysCaps[index].hContainer <> 0) then
          GlobalFree(sysCaps[index].hContainer);
//        Finalize(sysCaps[index]);
      end;
  end;
end;

procedure TScanner.storeProfile;
type UINT16_array = array[0..1] of TW_UINT16;
var
  index: integer;
  scCap, cvCap: TW_CAPABILITY;
  parr: pTW_ARRAY;
  pItemList: ^UINT16_array;
begin
  if state=4 then
  begin
    if length(sysCaps) > 0 then
      for index := high(sysCaps) to low(sysCaps) do
      begin
        if (sysCaps[index].hContainer <> 0) then
          GlobalFree(sysCaps[index].hContainer);
//        Finalize(sysCaps[index]);
      end;
    scCap.Cap        := CAP_SUPPORTEDCAPS;
    scCap.ConType    := TWON_DONTCARE16;
    scCap.hContainer := 0;
    if (DSM_Entry(@AppID, @dsID, DG_CONTROL, DAT_CAPABILITY, MSG_GET, @scCap) = TWRC_SUCCESS) then
    begin
      parr := GlobalLock(scCap.hContainer);
      SetLength(sysCaps, parr.NumItems);
      pItemList := @(parr.ItemList);
      for index := 0 to parr.NumItems-1 do
      begin
        cvCap.cap        := pItemList[index];
        cvCap.ConType    := TWON_DONTCARE16;
        cvCap.hContainer := 0;
        if (DSM_Entry(@AppID, @dsID, DG_CONTROL, DAT_CAPABILITY, MSG_GETCURRENT, @cvCap)=TWRC_SUCCESS) then
          sysCaps[index] := cvCap;
      end;
    end;
    DSM_Entry(@AppID, @dsID, DG_IMAGE, DAT_IMAGELAYOUT, MSG_GET, @sysImageLayout);
  end;
end;

function TScanner.selectSource: boolean;
begin
  goto_state(3);
  result := TWAIN_USERSELECT();
  goto_state(FDefaultState);
end;

function TScanner.Acquire;
var
  scanthread: TScannerThread;
begin
  result := false;
  if state<5 then
  begin
    goto_state(4);
    if state=4 then
    begin
      SetCapabilityINT16(CAP_XFERCOUNT, FSettingCaptureCount);
      event_xferReady.ResetEvent;
      goto_state(5);
      if twainState>=5 then
      begin
        result := true;
        scanthread := TScannerThread.Create(true);
        scanthread.FScanner := self;
        scanthread.FreeOnTerminate := true;
        scanthread.OnTerminate := FOnAcquireComplete;
        scanthread.Resume;
      end;
    end;
  end;
end;

{ TScannerThread }

procedure TScannerThread.Execute;
const INFINITE = 4294967295; {approximated to very big}
begin
  FScanner.event_xferReady.WaitFor(INFINITE);
  if FScanner.TWAIN_IMAGENATIVEXFER(hNative) then
    synchronize(doOnImageAcquire);
  {could loop here if state = 6}
  synchronize(goto_state_3);
  synchronize(goto_state_default);
end;

procedure TScannerThread.goto_state_3;
begin
  FScanner.goto_state(3);
end;

procedure TScannerThread.goto_state_default;
begin
  FScanner.goto_state(FScanner.FDefaultState);
end;

procedure TScannerThread.doOnImageAcquire;
begin
  FScanner.FOnImageAcquired(FScanner, hNative);
end;

procedure TScanner.set_SettingColour(b: boolean);
begin
  FSettingColour := b;
  if state=4 then
  begin
    if FSettingColour then
      SetCapabilityUINT16(ICAP_PIXELTYPE, TWPT_RGB)
    else
      if FSettingBPP = 1 then
        SetCapabilityUINT16(ICAP_PIXELTYPE, TWPT_BW)
      else
        SetCapabilityUINT16(ICAP_PIXELTYPE, TWPT_GRAY);
  end;
end;

function TScanner.get_SettingColour: boolean;
var pVal: pTW_UINT16;
begin
  result := FSettingColour;
  if state=4 then
  begin
    new(pVal);
    if getCurrentCapabilityUINT16(ICAP_PIXELTYPE, pVal)=TWCC_SUCCESS then
      result := (pVal^=TWPT_RGB);
    dispose(pVal);
  end;
end;

procedure TScanner.set_SettingBPP(b: integer);
begin
  FSettingBPP := b;
  if state=4 then
  begin
    SettingColour := FSettingColour; {to switch between BW and Gray}
    SetCapabilityUINT16(ICAP_BITDEPTH, FSettingBPP);
  end;
end;

function TScanner.get_SettingBPP: integer;
var
  pRes: pTW_UINT16;
  pCol: pTW_UINT16;
begin
  result := FSettingBPP;
  if state=4 then
  begin
    new(pres);
    case getCurrentCapabilityUINT16(TW_UINT16(ICAP_BITDEPTH), pres) of
      TWCC_SUCCESS: result := pres^;
      TWCC_BADCAP: begin
        {some scanners dont support this capability}
        new(pCol);
        getCurrentCapabilityUINT16(ICAP_PIXELTYPE, pCol);
        case pCol^ of
          TWPT_RGB:  result := 24;
          TWPT_GRAY: result := 8;
          TWPT_BW:   result := 1;
        end;
        dispose(pCol);
      end;
    else ;
    end;
    dispose(pres);
  end;
end;

function TScanner.get_SettingDPI: integer;
var
  pRes: pTW_FIX32;
begin
  result := FSettingDPI;
  if state=4 then
  begin
    new(pres);
    getCurrentCapabilityFIX32(ICAP_XRESOLUTION, pres);
    result := pres.Whole;
    dispose(pres);
  end;
end;

procedure TScanner.set_SettingDPI(b: integer);
begin
  FSettingDPI := b;
  if state=4 then
  begin
    SetCapabilityFIX32asDouble(ICAP_XRESOLUTION, FSettingDPI);
    SetCapabilityFIX32asDouble(ICAP_YRESOLUTION, FSettingDPI);
  end;
end;

function TScanner.get_ScannerName: string;
begin
  result := dsID.ProductName; {assigning pchar to string copies it}
end;

procedure TScanner.set_ScannerName(n: string);
begin
  goto_state(3);
  StrLCopy(dsID.ProductName, PChar(n), 34);
  goto_state(FDefaultState);
end;

procedure TScanner.set_SettingShowUI(b: boolean);
begin
  UI.ShowUI := b;
end;

function TScanner.get_SettingShowUI: boolean;
begin
  result := UI.ShowUI;
end;

function TScanner.get_SettingUnits: TScannerUnits;
var pres: pTW_UINT16;
begin
  result := FSettingUnits;
  if state=4 then
  begin
    new(pres);
    getCurrentCapabilityUINT16(ICAP_UNITS, pres);
    case pres^ of
      TWUN_INCHES:      result := UN_INCHES;
      TWUN_CENTIMETERS: result := UN_CENTIMETERS;
      TWUN_PICAS:       result := UN_PICAS;
      TWUN_POINTS:      result := UN_POINTS;
      TWUN_TWIPS:       result := UN_TWIPS;
      TWUN_PIXELS:      result := UN_PIXELS;
    end;
    dispose(pres);
  end;
end;

procedure TScanner.set_SettingUnits(b: TScannerUnits);
begin
  FSettingUnits := b;
  if state=4 then
  begin
    case FSettingUnits of
      UN_INCHES:      SetCapabilityUINT16(ICAP_UNITS, TWUN_INCHES);
      UN_CENTIMETERS: SetCapabilityUINT16(ICAP_UNITS, TWUN_CENTIMETERS);
      UN_PICAS:       SetCapabilityUINT16(ICAP_UNITS, TWUN_PICAS);
      UN_POINTS:      SetCapabilityUINT16(ICAP_UNITS, TWUN_POINTS);
      UN_TWIPS:       SetCapabilityUINT16(ICAP_UNITS, TWUN_TWIPS);
      UN_PIXELS:      SetCapabilityUINT16(ICAP_UNITS, TWUN_PIXELS);
    end;
  end;
end;

function TScanner.doubleToFIX32(d: double): TW_FIX32;
begin
  result.Whole := trunc(d);
  result.Frac := round((d - trunc(d)) * 65536);
end;

function TScanner.FIX32ToDouble(f: TW_FIX32): double;
begin
  result := f.Whole + f.Frac/65536
end;

function TScanner.get_ScanCapable: boolean;
var origstate: integer;
begin
  result := false;
  if state>3 then
  begin
    result := true;
  end else begin
    origstate := state;
    goto_state(4);
    if state=4 then result := true;
    goto_state(origstate);
  end;
end;

function TScanner.get_PhysicalHeight: double;
var
  pRes: pTW_FIX32;
begin
  result := -1;
  if state=4 then
  begin
    new(pres);
    getCurrentCapabilityFIX32(ICAP_PHYSICALHEIGHT, pres);
    result := FIX32ToDouble(pres^);
    dispose(pres);
  end;
end;

function TScanner.get_PhysicalWidth: double;
var
  pRes: pTW_FIX32;
begin
  result := -1;
  if state=4 then
  begin
    new(pres);
    getCurrentCapabilityFIX32(ICAP_PHYSICALWIDTH, pres);
    result := FIX32ToDouble(pres^);
    dispose(pres);
  end;
end;

function TScanner.get_Ready: boolean;
begin
  result := (state=4);
end;

function TScanner.Disable;
begin
  FDefaultState := 1;
  goto_state(FDefaultState);
  result := state=1;
end;

function TScanner.Enable;
begin
  FDefaultState := 4;
  goto_state(FDefaultState);
  result := state=4;
end;

function TScanner.GetLayoutAreaCoordinate(Index: Integer): double;
var
  ImageLayout: TW_IMAGELAYOUT;
begin
  result := FSettingLayoutArea[Index];
  if state=4 then
  begin
    DSM_Entry(@AppID, @dsID, DG_IMAGE, DAT_IMAGELAYOUT, MSG_GET, @ImageLayout);
    case Index of
      0: result := FIX32ToDouble(ImageLayout.Frame.Top);
      1: result := FIX32ToDouble(ImageLayout.Frame.Left);
      2: result := FIX32ToDouble(ImageLayout.Frame.Bottom);
      3: result := FIX32ToDouble(ImageLayout.Frame.Right);
    end;
  end;
end;

procedure TScanner.SetLayoutAreaCoordinate(Index: Integer; Value: double);
var
  ImageLayout: TW_IMAGELAYOUT;
begin
  FSettingLayoutArea[Index] := value;
  if state=4 then
  begin
    if not FSettingLayoutAll then
    begin
      DSM_Entry(@AppID, @dsID, DG_IMAGE, DAT_IMAGELAYOUT, MSG_GET, @ImageLayout);
      ImageLayout.Frame.Top    := doubleToFIX32(FSettingLayoutArea[0]); {inches}
      ImageLayout.Frame.Left   := doubleToFIX32(FSettingLayoutArea[1]); {inches}
      ImageLayout.Frame.Bottom := doubleToFIX32(FSettingLayoutArea[2]); {inches}
      ImageLayout.Frame.Right  := doubleToFIX32(FSettingLayoutArea[3]); {inches}
      DSM_Entry(@AppID, @dsID, DG_IMAGE, DAT_IMAGELAYOUT, MSG_SET, @ImageLayout); {ref:1-97}
    end;
  end;
end;

function TScanner.get_SettingLayoutAll: boolean;
begin
  result := FSettingLayoutAll;
end;

procedure TScanner.set_SettingLayoutAll(b: boolean);
var
  ImageLayout: TW_IMAGELAYOUT;
begin
  FSettingLayoutAll := b;
  if state=4 then
  begin
   if FSettingLayoutAll then
    begin
      DSM_Entry(@AppID, @dsID, DG_IMAGE, DAT_IMAGELAYOUT, MSG_RESET, @ImageLayout);
    end else begin
      DSM_Entry(@AppID, @dsID, DG_IMAGE, DAT_IMAGELAYOUT, MSG_GET, @ImageLayout);
      ImageLayout.Frame.Top    := doubleToFIX32(FSettingLayoutArea[0]); {inches}
      ImageLayout.Frame.Left   := doubleToFIX32(FSettingLayoutArea[1]); {inches}
      ImageLayout.Frame.Bottom := doubleToFIX32(FSettingLayoutArea[2]); {inches}
      ImageLayout.Frame.Right  := doubleToFIX32(FSettingLayoutArea[3]); {inches}
      DSM_Entry(@AppID, @dsID, DG_IMAGE, DAT_IMAGELAYOUT, MSG_SET, @ImageLayout); {ref:1-97}
    end;
  end;
end;

initialization
  ScannerState := ssNotKnown;
end.


