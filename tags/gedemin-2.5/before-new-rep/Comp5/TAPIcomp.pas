{+--------------------------------------------------------------------------+
 | Component:   TkkamTAPI
 | Created:     6/3/98 6:35:50 PM
 | Author:      Alan Moore and Ken Kyler
 |              developed for article in Delphi Informant; September 1998
 | Copyright    1998, all rights reserved.
 | Description: TAPI non-visual component for basic Telephony functionality
 | Version:     1.2
 | Modification History:  Modifications by Ken Kyler and Alan Moore
 +--------------------------------------------------------------------------+}
unit TAPIcomp;  { TkkamTAPI component. }
{ Created 6/3/98 6:35:51 PM }
{ Eagle Software CDK, Version 3.02 Rev. F }
{ Version 1.1 completed 6/25/98 }
{ Version 1.2 completed 6/27/98 }

interface

uses
  Windows, SysUtils, Messages, Classes, Graphics, Controls, Forms,
  Dialogs, Tapi, Menus, StdCtrls, ExtCtrls;

type
  // Thread Action Type
  TThreadAction = (taSuspend, taResume, taTerminate);

  // Comm Event Type
  TCommEvent = (tceDSR, tceDTR, tceCTS, tcePORT);

  // Event Types
  TTapiUpdateEvent = procedure(sender : TObject; UpdateList : TStringList)
     of object;
  TCommThreadEvent = procedure(sender : TObject; ThreadAction : TThreadAction)
     of object;
  TCommEventProc = procedure (sender : TObject; ACommEvent : TCommEvent;
                          AStatus : integer) of object;

  // Our Thread Class moved from separate unit
  type
  TCommStatus = class(TThread)
  private
    { Private declarations }
    ThePort : THandle;
    function GetPort : THandle;
    procedure SetPort(Value : THandle);
  protected
    TheOwner: TComponent;
    property APort : THandle
      read  GetPort
      Write SetPort;
      procedure Execute; override;
      procedure TriggerTapiCommEvent(Sender : TObject;
                          CommEvent : TCommEvent; Status : integer);
    public
      constructor Init(Owner : TComponent; Suspended : Boolean;
                        PortRead : THandle);
  end;

  // constants for thread and modem lights
  const
  off = 0;
  red = 1;
  yellow = 2;
  green = 3;

type
  // Main TAPI Class
  TkkamTAPI = class(TComponent)
  private
    FAnswerCalls: Boolean;
    FPulseDialing: boolean;
    FCountryCode: integer;
    FVersion: integer;
    { Private declarations }
    FLineCallParams: TLineCallParams;
    FLineTranslateOptions: DWord;
    FExt: TLINEEXTENSIONID;
    FlpTranslateOutput: LPLINETRANSLATEOUTPUT;
    FPort: THandle;
    FTAPI_Initialized: Boolean;
    FAutoSelectLine: Boolean;
    FDev: Integer;
    FPhoneNumber: String;
    FMediaMode: DWord;
    FBearerMode: DWord;
    FLineIsOpen: Boolean;
    FAnswserCalls : boolean;
    FOnCreateCallManager: TTapiUpdateEvent;
    FOnShutdownManager: TTapiUpdateEvent;
    FOnDestroyCallManager : TTapiUpdateEvent;
    FOnFreeCallManager: TTapiUpdateEvent;
    FOnEnumerateDevices: TTapiUpdateEvent;
    FOnOpenLine: TTapiUpdateEvent;
    FOnDial: TTapiUpdateEvent;
    FOnCommThreadEvent: TCommThreadEvent;
    FOnTriggerCommEvent: TCommEventProc;
    FOnTAPIInit: TNotifyEvent;  { Defined in Classes unit. }
    // The next three events will usually not need to be used but are included
    // in case you want to take additional steps after these changes occur.
    // Generally, you should communicate from the calling application to this
    // component to effect each of these changes
    FOnPhoneNumberChange: TNotifyEvent;  { Defined in Classes unit. }
    FOnChangeMediaMode: TNotifyEvent;  { Defined in Classes unit. }
    FOnChangeBearerMode: TNotifyEvent;  { Defined in Classes unit. }
    function ReadPhoneNumber :  string;
    procedure WritePhoneNumber(NewPhoneNumber : String);
   protected
    { Protected declarations }
    InitResults : TStringList;
    DeviceList: TStringList;
    ShutdownResults: TStringList;
    CreateManagerResults : TStringList;
    DialResults: TStringList;
    { Event triggers: }
    procedure TriggerCreateCallManagerEvent; virtual;
    procedure TriggerShutdownManagerEvent; virtual;
    procedure TriggerDestroyCallManagerEvent; virtual;
    procedure TriggerEnumerateDevicesEvent; virtual;
    procedure TriggerTAPIInitEvent; virtual;
    procedure TriggerOpenLineEvent; virtual;
    procedure TriggerDialEvent; virtual;
    procedure TriggerPhoneNumberChangeEvent; virtual;
    procedure TriggerChangeMediaModeEvent; virtual;
    procedure TriggerChangeBearerModeEvent; virtual;
    procedure TriggerCommThreadEvent(ThreadAction : TThreadAction); virtual;
    procedure TriggerCommEvent(Sender : TObject;
                               ACommEvent : TCommEvent; AStatus : integer);
  public
    { Public declarations }
    CommStatusThread : TCommStatus;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function TapiInitialize: Boolean;
    procedure EnumerateDevices;
    function ShutdownManager: Boolean;
    function CreateCallManager: Boolean;
    function CheckLineIsOpen: boolean;
    procedure ChangePhoneNumber(NewPhoneNumber : string);
    function Dial: String;
    procedure ChangeMediaMode(MediaModeSelected : Integer);
    procedure ChangeBearerMode(BearerModeSelected : Integer);
    procedure ShowLineTranslateDialog(APhoneNum : string; AHandle :  THandle);
    function OpenLine(AcceptCalls : boolean; var OpenMsg : string): boolean;
    function OpenPhone: Boolean;

    property APort : THandle read FPort Write FPort;
    // Use a MaskEdit on main form to enter phone number with the following
    // edit mask:  !9 \(999\) 000-0000;1;_
    property PhoneNumber: String read ReadPhoneNumber write WritePhoneNumber;
    property TAPI_Initialized: Boolean read FTAPI_Initialized write
             FTAPI_Initialized;
    property MediaMode: DWord read FMediaMode write FMediaMode;
    property Dev: Integer read FDev write FDev;  { Public }
    property LineIsOpen : boolean read FLineIsOpen Write FLineIsOpen;
  published
    { Published properties and events }
    property AutoSelectLine: Boolean read FAutoSelectLine write FAutoSelectLine
             default true;
    property AnswerCalls : boolean read FAnswerCalls Write FAnswerCalls;
    property PulseDialing : boolean read FPulseDialing Write FPulseDialing;
    property OnCreateCallManager: TTapiUpdateEvent read FOnCreateCallManager write
             FOnCreateCallManager;
    property OnShutdownManager: TTapiUpdateEvent read FOnShutdownManager
             write FOnShutdownManager;
    property OnDestroyCallManager: TTapiUpdateEvent read FOnDestroyCallManager
             write FOnDestroyCallManager;
    property OnEnumerateDevices: TTapiUpdateEvent read FOnEnumerateDevices
             write FOnEnumerateDevices;
    property OnTriggerCommEvent : TCommEventProc read FOnTriggerCommEvent
             Write FOnTriggerCommEvent;
    property OnTAPIInit: TNotifyEvent read FOnTAPIInit write FOnTAPIInit;
    property OnOpenLine: TTapiUpdateEvent read FOnOpenLine write FOnOpenLine;
    property OnDial: TTapiUpdateEvent read FOnDial write FOnDial;
    property OnPhoneNumberChange: TNotifyEvent read FOnPhoneNumberChange
             write FOnPhoneNumberChange;
    property OnChangeMediaMode: TNotifyEvent read FOnChangeMediaMode
             write FOnChangeMediaMode;
    property OnChangeBearerMode: TNotifyEvent read FOnChangeBearerMode
             write FOnChangeBearerMode;
    property OnCommThreadEvent : TCommThreadEvent read FOnCommThreadEvent
             Write FOnCommThreadEvent;
  end;  { TkkamTAPI }

  var
    LineApp: HLINEAPP;
    PhoneApp: HPHONEAPP;

procedure Register;

implementation

const
  Ver = $00010004;  // API version accepted (1.4) [Windows 95]

// Local Variables -------------------------------------------------------------
var
  TapiMessages : TStringList; // local string list for TAPI results
  Devices : TStringList;      // local string list for available devices
  AkkamTAPI : TkkamTAPI;  // local copy of the TAPI component
  LocalNumDevs : Integer;  // local copy of number of devices
  ALineIsOpen : boolean;   // local copy of line open status
  ALine : HLine; // local copy of line
  ACall : HCall; // local copy of call
  APhoneNumber : string; // local copy of phone number
// Local Functions -------------------------------------------------------------

function RecordGetStr (var Data; Field : Pointer) : string;
var
  Len: Longint;
begin
  Len := PInt(Field)^; // PInt is defined in Windows.pas
  Inc(PInt(Field));
  if (PInt(Field)^ <> 0) then
     SetString(Result, PChar(Longint(@Data) + PInt(Field)^), Len - 1)
  else
     Result:='';
end;

function ShutdownCallManager(var ShutdownResults : string)
           : boolean;
var
  S: string;
begin
  Result := false;
  { LineShutDown performs the equivalent of LineClose
    so set the line flag to false }
  case LineShutdown(LineApp) of
     0: begin
        S := 'success!';
        result := True;
        ALineIsOpen := False;
        AkkamTAPI.LineIsOpen := False;
     end;
     LINEERR_INVALAPPHANDLE: S := 'LINEERR_INVALAPPHANDLE';
     LINEERR_NOMEM: S := 'LINEERR_NOMEM';
     LINEERR_UNINITIALIZED: S := 'LINEERR_UNINITIALIZED';
     LINEERR_RESOURCEUNAVAIL: S := 'LINEERR_RESOURCEUNAVAIL';
  else
     S := 'Unknown value';
  end;
  ShutdownResults := 'LineShutDown reports: ' + S;
  AkkamTAPI.TriggerShutdownManagerEvent;
end;


procedure LineCallBack(hDevice, dwMessage, dwInstance, dwParam1,
  dwParam2, dwParam3 : DWORD); stdcall; // handles messages from the line
var
  CallResults : string;
begin
  AkkamTAPI.DialResults.Clear;
  with AkkamTAPI.DialResults do begin // Write TAPI results to string list for use
                             // by Delphi components in TAPIForm unit
    case dwMessage of
      LINE_CALLSTATE: begin //reports asynchronous responses
        case dwParam1 of
           LINECALLSTATE_IDLE:
              begin
              Add('LCB (LINE_CALLSTATE): ' +
                  'The call is idle - no call actually exists.');
              If ShutdownCallManager(CallResults) then
                 begin
                 AkkamTAPI.TriggerShutdownManagerEvent;
                   //Send TapiMessages to calling app
                 AkkamTAPI.LineIsOpen := False;
                 ALineIsOpen := False;
                 end;
              end;
           LINECALLSTATE_OFFERING:
               begin
                 Add('LCB (LINE_CALLSTATE): ' +
                   'The call is being offered to the station.');
                 if dwParam3<>LINECALLPRIVILEGE_OWNER then
                 Add('Cannot accept call because we don''t '+
                      'have owner priviledges .')
                 else
                    begin
                      Add('Attempting to accept incoming call');
                      lineAccept(ACall, Nil, 0);
                    end;
              end;
           LINECALLSTATE_ACCEPTED:
              begin
              Add('LCB (LINE_CALLSTATE): ' +
                'The call was offering and has been accepted.');
              if MessageDlg('Do you want to accept this call?',
                 mtConfirmation, [mbYes, mbNo], 0) = mrYes  then
                 lineAnswer(ACall, Nil, 0);
              end;
           LINECALLSTATE_DIALTONE:
              Add('LCB (LINE_CALLSTATE): The call is receiving a dial tone.');
           LINECALLSTATE_DIALING:
              Add('LCB (LINE_CALLSTATE): Dialing ' + APhoneNumber);
           LINECALLSTATE_RINGBACK:
              Add('LCB (LINE_CALLSTATE): The call is receiving ringback.');
           LINECALLSTATE_BUSY: begin // note, difficult to detect
           AkkamTAPI.TriggerCommEvent(Nil, tcePORT, red);
             case dwParam2 of
               LINEBUSYMODE_STATION:
                 Add('LCB (LINE_CALLSTATE): ' +
                     'Busy signal; called party''s station is busy.');
               LINEBUSYMODE_TRUNK:
                 Add('LCB (LINE_CALLSTATE): ' +
                     'Busy signal; trunk or circuit is busy.');
               LINEBUSYMODE_UNKNOWN:
                 Add('LCB (LINE_CALLSTATE): ' +
                     'Busy signal; specific mode is currently unkown');
               LINEBUSYMODE_UNAVAIL:
                 Add('LCB (LINE_CALLSTATE): ' +
                     'Busy signal; specific mode is unavailable');
             else
               Add('LCB (LINE_CALLSTATE): ' +
                   'The call is receiving an unidentifiable busy tone.');
             end;
             ShutdownCallManager(CallResults);
             AkkamTAPI.TriggerShutdownManagerEvent;
               // Send TapiMessages to calling app
             AkkamTAPI.TriggerCommEvent(Nil, tcePORT, green);
           end;
           LINECALLSTATE_SPECIALINFO:
              Add('LCB (LINE_CALLSTATE): ' +
                  'Special information is sent by the network.');
           LINECALLSTATE_CONNECTED:
              Add('LCB (LINE_CALLSTATE): ' +
                  'The call has been established and the connection is made.');
           LINECALLSTATE_PROCEEDING:
              Add('LCB (LINE_CALLSTATE): ' +
                  'Dialing has completed and the call is proceeding.');
           LINECALLSTATE_ONHOLD:
              Add('LCB (LINE_CALLSTATE): The call is on hold by the switch.');
           LINECALLSTATE_CONFERENCED:
              Add('LCB (LINE_CALLSTATE): The call is ' +
                  'currently a member of a multi-party conference call.');
           LINECALLSTATE_ONHOLDPENDCONF:
              Add('LCB (LINE_CALLSTATE): The call is currently ' +
                  'on hold while it is being added to a conference.');
           LINECALLSTATE_DISCONNECTED: begin
              Add('LCB (LINE_CALLSTATE): The line has been disconnected.');
              case dwParam2 of
                LINEDISCONNECTMODE_NORMAL:
                   Add(#9 + 'This is a "normal" disconnect request.');
                LINEDISCONNECTMODE_UNKNOWN:
                   Add(#9+'The reason for the disconnect request is unknown.');
                LINEDISCONNECTMODE_REJECT:
                   Add(#9 + 'The remote user has rejected the call.');
                LINEDISCONNECTMODE_PICKUP:
                   Add(#9 + 'The call was picked up from elsewhere.');
                LINEDISCONNECTMODE_FORWARDED:
                   Add(#9 + 'The call was forwarded by the switch.');
                LINEDISCONNECTMODE_BUSY:
                   Add(#9 + 'The remote user''s station is busy.');
                LINEDISCONNECTMODE_NOANSWER:
                   Add(#9 + 'The remote user''s station does not answer.');
                LINEDISCONNECTMODE_BADADDRESS:
                   Add(#9 + 'The destination address in invalid.');
                LINEDISCONNECTMODE_UNREACHABLE:
                   Add(#9 + 'The remote user could not be reached.');
                LINEDISCONNECTMODE_CONGESTION:
                   Add(#9 + 'The network is congested.');
                LINEDISCONNECTMODE_INCOMPATIBLE: Add(#9 +
                   'The remote user''s station equipment is incompatible');
                LINEDISCONNECTMODE_UNAVAIL:
                   Add(#9 + 'The reason for the disconnect is unavailable');
              end;
           end;
           LINECALLSTATE_UNKNOWN:
              Add('LCB (LINE_CALLSTATE): The state of the call is not known.');
           end;
        end;
      LINE_LINEDEVSTATE:
        case dwParam1 of // incomplete list
           LINEDEVSTATE_RINGING:
              Add('LCB (LINE_LINEDEVSTATE): (Ringing) Ring, ring, ring...');
           LINEDEVSTATE_CONNECTED:
              Add('LCB (LINE_LINEDEVSTATE): Connected...');
           LINEDEVSTATE_DISCONNECTED:
              Add('LCB (LINE_LINEDEVSTATE): Disconnected.');
           LINEDEVSTATE_REINIT: // line device has changed or been modified
              if (dwParam2 = 0) then begin
                 Add('LCB (LINE_LINEDEVSTATE): Shutdown required');
                 ShutdownCallManager(CallResults);
                   // Send TapiMessages to calling app
              end;
        end;
      LINE_REPLY:
        if (dwParam2 = 0) then
           Add('LCB (LINE_REPLY): LineMakeCall completed successfully')
        else
           Add('LCB (LINE_REPLY): LineMakeCall failed');
    end;
  end;
  AkkamTAPI.TriggerDialEvent;
end;

function GetPortHandle : THandle;
{ code courtesy of Keith Anderson, Keith@PureScience.com
  This code returns the port handle required to pass to SetCommMask,
  GetCommModemStatus and any other low level comm functions }
type
  LPPort = ^TPort;
     TPort = record
          VarString: TVarString;
          hComm: THandle;
          szDeviceName: array [1..1] of Char;
     end;
var
  TempPort: LPPort;
  PortSize: LongInt;
  FError: longint;
begin
  result := 0;
     if not ALineIsOpen then exit; // use local copy
     PortSize := sizeof(TPort);
     GetMem(TempPort, PortSize);
     TempPort^.VarString.dwTotalSize := PortSize;
     try
          repeat
            FError := lineGetID(ALine, 0, ACall,
              LINECALLSELECT_LINE,
              lpVarString(TempPort), 'comm');
              if FError < 0 then exit;
              if (TempPort^.VarString.dwNeededSize >
                 TempPort^.VarString.dwTotalSize)
                 then begin
                 PortSize := TempPort^.VarString.dwNeededSize;
                 FreeMem(TempPort);
                 GetMem(TempPort, PortSize);
                 TempPort^.VarString.dwTotalSize := PortSize;
                 FError := -1;
                 end;
          until FError = 0;
          Result := TempPort^.hComm;
  finally
    FreeMem(TempPort);
  end;
end;

//-- End of Local Functions ----------------------------------------------------

// Is Line Open?
function TkkamTAPI.CheckLineIsOpen: boolean;
begin
  Result := LineIsOpen;
end;

// Phone number management
function TkkamTAPI.ReadPhoneNumber :  string;
begin
  result := FPhoneNumber;
  APhoneNumber := FPhoneNumber; // set local copy too
end;

procedure TkkamTAPI.WritePhoneNumber(NewPhoneNumber : String);
begin
  FPhoneNumber := NewPhoneNumber;
  APhoneNumber := NewPhoneNumber; // set local copy too
end;

procedure TkkamTAPI.ChangePhoneNumber(NewPhoneNumber : string);
begin
  WritePhoneNumber(NewPhoneNumber);
end;

// Line Management

function TkkamTAPI.OpenLine(AcceptCalls : boolean; var OpenMsg : string)
                                         : boolean;
var
  OpenResult: longint;
begin
 Result := False;
  if AcceptCalls then
      // open a line (outgoing and incoming calls) and get the line handle
  if AutoSelectLine then // automatically select the device
     OpenResult := LineOpen(LineApp, LINEMAPPER, @ALine, FVersion, 0, 0,
        LINECALLPRIVILEGE_OWNER, fMediaMode,
           @FLineCallParams)
  else
     OpenResult := LineOpen(LineApp, FDev, @ALine, FVersion, 0, 0,
        LINECALLPRIVILEGE_OWNER, fMediaMode, nil);
     // open a line (outgoing calls only) and get the line handle
  if AutoSelectLine then // automatically select the device
     OpenResult := LineOpen(LineApp, LINEMAPPER, @ALine, FVersion, 0, 0,
        LINECALLPRIVILEGE_NONE, fMediaMode,
           @FLineCallParams)
  else
     OpenResult := LineOpen(LineApp, FDev, @ALine, FVersion, 0, 0,
        LINECALLPRIVILEGE_NONE, fMediaMode, nil);
  case OpenResult of
     0: begin
       Result := True; // success so drop through
       OpenMsg := 'Line is Open';
       ALineIsOpen := True;
       AkkamTAPI.LineIsOpen := True;
       // create thread suspended
       TriggerCommThreadEvent(taResume);
       end;
     LINEERR_ALLOCATED: OpenMsg := 'LINEERR_ALLOCATED';
     LINEERR_BADDEVICEID: OpenMsg := 'LINEERR_BADDEVICEID';
     LINEERR_INCOMPATIBLEAPIVERSION: OpenMsg :=
       'LINEERR_INCOMPATIBLEAPIVERSION';
     LINEERR_INCOMPATIBLEEXTVERSION: OpenMsg :=
       'LINEERR_INCOMPATIBLEEXTVERSION';
     LINEERR_INVALAPPHANDLE: OpenMsg := 'LINEERR_INVALAPPHANDLE';
     LINEERR_INVALMEDIAMODE: OpenMsg := 'LINEERR_INVALMEDIAMODE';
     LINEERR_INVALPOINTER: OpenMsg := 'LINEERR_INVALPOINTER';
     LINEERR_INVALPRIVSELECT: OpenMsg := 'LINEERR_INVALPRIVSELECT';
     LINEERR_NODEVICE: OpenMsg := 'LINEERR_NODEVICE';
     LINEERR_LINEMAPPERFAILED: OpenMsg := 'LINEERR_LINEMAPPERFAILED';
     LINEERR_NODRIVER: OpenMsg := 'LINEERR_NODRIVER';
     LINEERR_NOMEM: OpenMsg := 'LINEERR_NOMEM';
     LINEERR_OPERATIONFAILED: OpenMsg := 'LINEERR_OPERATIONFAILED';
     LINEERR_RESOURCEUNAVAIL: OpenMsg := 'LINEERR_RESOURCEUNAVAIL';
     LINEERR_STRUCTURETOOSMALL: OpenMsg :=
        'LINEERR_STRUCTURETOOSMALL';
     LINEERR_UNINITIALIZED: OpenMsg := 'LINEERR_UNINITIALIZED';
     LINEERR_REINIT: OpenMsg := 'LINEERR_REINIT';
     LINEERR_OPERATIONUNAVAIL: OpenMsg := 'LINEERR_OPERATIONUNAVAIL';
  else
     OpenMsg := 'LineOpen returned an unknown value of ' + IntToStr(OpenResult);
  end;
  TriggerOpenLineEvent;
end;  { OpenLine }

// TAPI Management
function TkkamTAPI.TapiInitialize : Boolean;
var
  ErrNo: Longint;
  S: string;
begin
  Result := false;
  FCountryCode := 0;
  FVersion := 0;
  ErrNo := LineInitialize(@LineApp, MainInstance, LineCallback, '',
  @LocalNumDevs);
  case ErrNo of
     0:  S := 'LineInitialize was successful';
     LINEERR_INVALAPPNAME: S := 'Invalid Application Name';
     LINEERR_OPERATIONFAILED: S := 'Line Init Operation Failed';
     LINEERR_INIFILECORRUPT: S := 'INI File Corrupt';
     LINEERR_RESOURCEUNAVAIL: S := 'Resource not available';
     LINEERR_INVALPOINTER: S := 'Invalid Pointer';
     LINEERR_REINIT: S := 'Not ready - trying again';
     LINEERR_NODRIVER: S := 'Driver not found';
     LINEERR_NODEVICE: S := 'Device not found';
     LINEERR_NOMEM: S := 'Insufficient memory';
     LINEERR_NOMULTIPLEINSTANCE: S := 'Can''t run multiple instances';
  else
     S := 'Unknown Reason (' + IntToStr(ErrNo) + ')';
  end;
  InitResults.Add(S);
  // show how many devices available
  InitResults.Add('Devices available: ' + IntToStr({FNumDevs}LocalNumDevs));

  if (ErrNo <> 0) then begin
     InitResults.Add('LineInitialize failed with error: ' + S);
     Exit;
  end
  else
     ErrNo := LineNegotiateAPIVersion(LineApp, FDev, Ver, Ver,
        @FVersion, @FExt);
  if (ErrNo <> 0) then begin
     case ErrNo of
        LINEERR_BADDEVICEID: S := 'Bad Device ID';
        LINEERR_NODRIVER: S := 'No Driver';
        LINEERR_INCOMPATIBLEAPIVERSION: S := 'Incompatible Version';
        LINEERR_OPERATIONFAILED: S := 'Operation failed';
        LINEERR_INVALAPPHANDLE: S := 'Invalid Handle';
        LINEERR_RESOURCEUNAVAIL: S := 'Resource Not Available';
        LINEERR_INVALPOINTER: S := 'Invalid Pointer';
        LINEERR_UNINITIALIZED: S := 'Line Not Initialized';
        LINEERR_NOMEM: S := 'Insufficient Memory';
        LINEERR_OPERATIONUNAVAIL: S := 'Operation Not Available Here';
        LINEERR_NODEVICE: S := 'Device Not Found';
     else
        S := 'Unknown Reason (' + IntToStr(ErrNo) + ')';
     end;
     LineShutDown(LineApp);
     InitResults.Add('LineNegotiateAPIVersion failed because:  ' + S);
  end
  else
     Result := true;
  TriggerTAPIInitEvent;
end;  { TapiInitialize }

// Manage Devices
procedure TkkamTAPI.EnumerateDevices;  { public }
var
  i, rc: integer;
  AllocSize: Integer;
  LineDevCaps: LPLINEDEVCAPS; // a pointer of TLineDevCaps type
begin
	// Added by Ken Kyler ---------
  DeviceList.Clear;
  // ---------
  AllocSize := SizeOf(TLINEDEVCAPS);// + 512;
  for i := 0 to {FNumDevs}LocalNumDevs - 1 do begin
     LineDevCaps := AllocMem(AllocSize); // This will also fill with zeroes
     try
        // Get dev caps
        LineDevCaps^.dwTotalSize := AllocSize;
        rc := LineGetDevCaps(LineApp, i, FVersion, 0, LineDevCaps);
        if (LineDevCaps^.dwNeededSize > LineDevCaps^.dwTotalSize) then begin
           // Buffer too small; reallocate and try again
           AllocSize := LineDevCaps^.dwNeededSize;
           ReallocMem(LineDevCaps, AllocSize);
           LineDevCaps^.dwTotalSize := AllocSize;
           rc := LineGetDevCaps(LineApp, i, FVersion, 0, LineDevCaps);
        end;
        TapiCheck(rc);  // Raises exception if rc indicates a line error
        // Extract line name
        if (LineDevCaps^.dwStringFormat = STRINGFORMAT_ASCII) then
          DeviceList.Add(RecordGetStr(LineDevCaps^,
             @LineDevCaps^.dwLineNameSize))
        else
          DeviceList.Add('Invalid string format');
     finally
        FreeMem(LineDevCaps);
     end;
  end;
  TriggerEnumerateDevicesEvent;
end;  { EnumerateDevices }

// Call Manager Functions
function TkkamTAPI.CreateCallManager : Boolean;
var
  S: string;
  ErrNo: longint;
begin
result := False;
  CreateManagerResults.Clear;
  if not LineIsOpen then // if a line is open, no need to initialize TAPI
     if not TapiInitialize then begin
        CreateManagerResults.Add('Failed to initialize TAPI');
        Exit;
     end;

  { fill the LineCallParams structure.  Mandatory for data calls,
    optional for voice calls }
     with FLineCallParams do begin
     dwTotalSize := sizeof(FLineCallParams);
     dwBearerMode := LINEBEARERMODE_VOICE;
     dwMediaMode := LINEMEDIAMODE_DATAMODEM; //LINEMEDIAMODE_INTERACTIVEVOICE
  end;
  if NOT LineIsOpen then
    LineIsOpen := OpenLine(False, S);
    AlineIsOpen := LineIsOpen;
    CommStatusThread.Resume; // start thread
  // now place the call
  if FPulseDialing then
  ErrNo := LineMakeCall(ALine, @ACall, PChar('p'+PhoneNumber), FCountryCode,
     @FLineCallParams) else
  ErrNo := LineMakeCall(ALine, @ACall, PChar(PhoneNumber), FCountryCode,
     @FLineCallParams);
  //ACall := FCall;  // make sure local copy is in sync
  case ErrNo of
     0: S := 'LineMakeCall succeeded'; // success
     LINEERR_ADDRESSBLOCKED: S := 'LINEERR_ADDRESSBLOCKED';
     LINEERR_BEARERMODEUNAVAIL: S := 'LINEERR_BEARERMODEUNAVAIL';
     LINEERR_CALLUNAVAIL: S := 'LINEERR_CALLUNAVAIL';
     LINEERR_DIALBILLING: S := 'LINEERR_DIALBILLING';
     LINEERR_DIALDIALTONE: S := 'LINEERR_DIALDIALTONE';
     LINEERR_DIALPROMPT: S := 'LINEERR_DIALPROMPT';
     LINEERR_DIALQUIET: S := 'LINEERR_DIALQUIET';
     LINEERR_INUSE: S := 'LINEERR_INUSE';
     LINEERR_INVALADDRESS: S := 'LINEERR_INVALADDRESS';
     LINEERR_INVALADDRESSID: S := 'LINEERR_INVALADDRESSID';
     LINEERR_INVALADDRESSMODE: S := 'LINEERR_INVALADDRESSMODE';
     LINEERR_INVALBEARERMODE: S := 'LINEERR_INVALBEARERMODE';
     LINEERR_INVALCALLPARAMS: S := 'LINEERR_INVALCALLPARAMS';
     LINEERR_INVALCOUNTRYCODE: S := 'LINEERR_INVALCOUNTRYCODE';
     LINEERR_INVALLINEHANDLE: S := 'LINEERR_INVALLINEHANDLE';
     LINEERR_INVALLINESTATE: S := 'LINEERR_INVALLINESTATE';
     LINEERR_INVALMEDIAMODE: S := 'LINEERR_INVALMEDIAMODE';
     LINEERR_INVALPARAM: S := 'LINEERR_INVALPARAM';
     LINEERR_INVALPOINTER: S := 'LINEERR_INVALPOINTER';
     LINEERR_INVALRATE: S := 'LINEERR_INVALRATE';
     LINEERR_NOMEM: S := 'LINEERR_NOMEM';
     LINEERR_OPERATIONFAILED: S := 'LINEERR_OPERATIONFAILED';
     LINEERR_OPERATIONUNAVAIL: S := 'LINEERR_OPERATIONUNAVAIL';
     LINEERR_RATEUNAVAIL: S := 'LINEERR_RATEUNAVAIL';
     LINEERR_RESOURCEUNAVAIL: S := 'LINEERR_RESOURCEUNAVAIL';
     LINEERR_STRUCTURETOOSMALL: S := 'LINEERR_STRUCTURETOOSMALL';
     LINEERR_UNINITIALIZED: S := 'LINEERR_UNINITIALIZED';
     LINEERR_USERUSERINFOTOOBIG: S := 'LINEERR_USERUSERINFOTOOBIG';
  else
     S := 'LineMakeCall returned an unknown value (' + IntToStr(ErrNo) + ')';
  end;
  //ALine := FLine;  // make sure local copy is in sync
  CreateManagerResults.Add('LineMakeCall reports: ' + S);
  TriggerCreateCallManagerEvent;  // Send CreateManagerResults to calling app.
end; { CreateCallManager }

function TkkamTAPI.ShutdownManager: Boolean;
var
  ShutdownResults : string;
begin
  result := ShutdownCallManager(ShutdownResults);
end;  { ShutdownManager }

// Dialing a Phone Number
function TkkamTAPI.Dial : String;  { public }
var
  ErrNo: longint;
  S: string;
begin
  if PhoneNumber='' then
    begin
      ShowMessage('You need to enter a phone number');
      result := 'No Phone number entered';
      exit;
    end;

  result := 'Success';
  if not AutoSelectLine and (Dev < 0) then begin // a device wasn't selected
     result := 'You must first select a Line device!';
     Exit;
  end;
  if AutoSelectLine then CreateCallManager
  else
  begin
  ErrNo := TapiRequestMakeCall(
     PChar(PhoneNumber), // the phone number
     '', // application name, optional, could use PChar(Application.Title)
     'Some person', // optional, this is the name of the person being called
     ''); // optional comment
  case ErrNo of
     0: Exit; // success; exit with default message
     TAPIERR_NOREQUESTRECIPIENT: S := 'TAPIERR_NOREQUESTRECIPIENT';
     TAPIERR_INVALDESTADDRESS: S := 'TAPIERR_INVALDESTADDRESS';
     TAPIERR_REQUESTQUEUEFULL: S := 'TAPIERR_REQUESTQUEUEFULL';
     TAPIERR_INVALPOINTER: S := 'TAPIERR_INVALPOINTER';
  else
     S := 'unknown value (' + IntToStr(ErrNo) + ')';
  end;
     DialResults.Add('TapiRequestMakeCall returned: ' + S);
end;
TriggerDialEvent;
end;  { Dial }

// Media Mode Management
procedure TkkamTAPI.ChangeMediaMode(MediaModeSelected : Integer);  { public }
begin
  case MediaModeSelected of
     0:  MediaMode := LINEMEDIAMODE_UNKNOWN;
     1:  MediaMode := LINEMEDIAMODE_INTERACTIVEVOICE;
     2:  MediaMode := LINEMEDIAMODE_AUTOMATEDVOICE;
     3:  MediaMode := LINEMEDIAMODE_DATAMODEM;
     4:  MediaMode := LINEMEDIAMODE_G3FAX;
     5:  MediaMode := LINEMEDIAMODE_TDD;
     6:  MediaMode := LINEMEDIAMODE_G4FAX;
     7:  MediaMode := LINEMEDIAMODE_DIGITALDATA;
     8:  MediaMode := LINEMEDIAMODE_TELETEX;
     9:  MediaMode := LINEMEDIAMODE_VIDEOTEX;
     10: MediaMode := LINEMEDIAMODE_TELEX;
     11: MediaMode := LINEMEDIAMODE_MIXED;
     12: MediaMode := LINEMEDIAMODE_ADSI;
     13: MediaMode := LINEMEDIAMODE_VOICEVIEW;
  else
     MediaMode := LINEMEDIAMODE_INTERACTIVEVOICE; // safety valve
  end;
  FLineCallParams.dwMediaMode := MediaMode;
end;  { ChangeMediaMode }

// Bearer Mode Management
procedure TkkamTAPI.ChangeBearerMode(BearerModeSelected : Integer);  { public }
begin
  case BearerModeSelected of
     0: FBearerMode := LINEBEARERMODE_VOICE;
     1: FBearerMode := LINEBEARERMODE_SPEECH;
     2: FBearerMode := LINEBEARERMODE_MULTIUSE;
     3: FBearerMode := LINEBEARERMODE_DATA;
     4: FBearerMode := LINEBEARERMODE_ALTSPEECHDATA;
     5: FBearerMode := LINEBEARERMODE_NONCALLSIGNALING;
     6: FBearerMode := LINEBEARERMODE_PASSTHROUGH;
  else
     FBearerMode := LINEBEARERMODE_SPEECH; // safety valve
  end;
  FLineCallParams.dwBearerMode := FBearerMode;
end;  { ChangeBearerMode }

// Show TAPI Properties Dialog Box
procedure TkkamTAPI.ShowLineTranslateDialog(APhoneNum : string;
                               AHandle :  THandle);  { public }
var
TapiResult : word;
TempNumber : string;
begin
  TempNumber := '+1' + Copy(APhoneNum, 2, Length(APhoneNum)-1);
  if  FDev<0 then
  TapiResult := lineTranslateDialogA(LineApp, 0, ver, AHandle,
        LPCStr(TempNumber))
  else
  TapiResult := lineTranslateDialogA(LineApp, FDev, ver, AHandle,
        LPCStr(TempNumber));
  if TapiResult<>0 then
    ShowMessage('Could not show Line Translate Dialog Box')
  else
   lineTranslateAddress(LineApp, FDev, ver, PChar(fPhoneNumber), 0,
         FLineTranslateOptions, FlpTranslateOutput);
end;  { ShowLineTranslateDialog }

{ Event triggers: }
procedure TkkamTAPI.TriggerCreateCallManagerEvent;
{ Triggers the OnCreateCallManager event. This is a virtual method
  (descendants of this component can override it). }
{ CDK: Call as needed to trigger event. }
begin
  if assigned(FOnCreateCallManager) then
    FOnCreateCallManager(Self, CreateManagerResults);
end;  { TriggerCreateCallManagerEvent }

procedure TkkamTAPI.TriggerShutdownManagerEvent;
{ Triggers the OnShutdownManager event. This is a virtual method
  (descendants of this component can override it). }
{ CDK: Call as needed to trigger event. }
begin
  if assigned(FOnShutdownManager) then
    FOnShutdownManager(Self, ShutdownResults);
end;  { TriggerShutdownManagerEvent }

procedure TkkamTAPI.TriggerDestroyCallManagerEvent;
{ Triggers the OnDestroyCallManager event. This is a virtual method (descendants of this
component can override it). }
{ CDK: Call as needed to trigger event. }
begin
  if assigned(FOnDestroyCallManager) then
    FOnDestroyCallManager(Self, ShutdownResults);
end;  { TriggerDestroyCallManagerEvent }

procedure TkkamTAPI.TriggerEnumerateDevicesEvent;
{ Triggers the OnEnumerateDevices event. This is a virtual method (descendants of this component
can override it). }
{ CDK: Call as needed to trigger event. }
begin
  if assigned(FOnEnumerateDevices) then
    FOnEnumerateDevices(Self, DeviceList);
end;  { TriggerEnumerateDevicesEvent }

procedure TkkamTAPI.TriggerTAPIInitEvent;
{ Triggers the OnTAPIInit event. This is a virtual method (descendants of this component can
override it). }
{ CDK: Call as needed to trigger event. }
begin
  if assigned(FOnTAPIInit) then
    FOnTAPIInit(Self);
end;  { TriggerTAPIInitEvent }

procedure TkkamTAPI.TriggerOpenLineEvent;
{ Triggers the OnOpenLine event. This is a virtual method (descendants of this component can
override it). }
{ CDK: Call as needed to trigger event. }
begin
  if assigned(FOnOpenLine) then
    FOnOpenLine(Self, InitResults);
end;  { TriggerOpenLineEvent }

procedure TkkamTAPI.TriggerDialEvent;
{ Triggers the OnDial event. This is a virtual method (descendants of this component can override
it). }
{ CDK: Call as needed to trigger event. }
begin
  if assigned(FOnDial) then
    FOnDial(Self, DialResults);
end;  { TriggerDialEvent }

procedure TkkamTAPI.TriggerPhoneNumberChangeEvent;
{ Triggers the OnPhoneNumberChange event. This is a virtual method (descendants of this
component can override it). }
{ CDK: Call as needed to trigger event. }
begin
  if assigned(FOnPhoneNumberChange) then
    FOnPhoneNumberChange(Self);
end;  { TriggerPhoneNumberChangeEvent }

procedure TkkamTAPI.TriggerChangeMediaModeEvent;
{ Triggers the OnChangeMediaMode event. This is a virtual method (descendants of this component
can override it). }
{ CDK: Call as needed to trigger event. }
begin
  if assigned(FOnChangeMediaMode) then
    FOnChangeMediaMode(Self);
end;  { TriggerChangeMediaModeEvent }

procedure TkkamTAPI.TriggerChangeBearerModeEvent;
{ Triggers the OnChangeBearerMode event. This is a virtual method (descendants of this
component can override it). }
{ CDK: Call as needed to trigger event. }
begin
  if assigned(FOnChangeBearerMode) then
    FOnChangeBearerMode(Self);
end;  { TriggerChangeBearerModeEvent }
procedure TkkamTAPI.TriggerCommThreadEvent(ThreadAction : TThreadAction);
begin
  if assigned(FOnCommThreadEvent) then
     FOnCommThreadEvent(Self, ThreadAction);
end;   { TriggerCommThread }

procedure TkkamTAPI.TriggerCommEvent(Sender : TObject;
              ACommEvent : TCommEvent; AStatus : integer);
begin
  if assigned(FOnTriggerCommEvent) then
    FOnTriggerCommEvent(Sender, ACommEvent, AStatus);
end;

destructor TkkamTAPI.Destroy;
begin
    InitResults.Free;
    DeviceList.Free;
    ShutdownResults.Free;;
    CreateManagerResults.Free;;
    DialResults.Free;
    CommStatusThread.Free;
    CommStatusThread := Nil;
   // TapiResults.Free;
  { CDK: Free allocated memory and created objects here. }
  inherited Destroy;
end;  { Destroy }

constructor TkkamTAPI.Create(AOwner: TComponent);
{ Creates an object of type TkkamTAPI, and initializes properties. }
var
  LineOpenResult : longint;
begin
  inherited Create(AOwner);
  { Initialize properties with default values: }
  FAutoSelectLine := true;
  FPhoneNumber := '';
  InitResults := TStringList.Create;
  DeviceList:= TStringList.Create;
  ShutdownResults:= TStringList.Create;
  CreateManagerResults := TStringList.Create;
  DialResults := TStringList.Create;
  TapiMessages := TStringList.Create;
  TAPI_Initialized := True;
  fMediaMode  := LINEMEDIAMODE_DATAMODEM;
  fBearerMode := LINEBEARERMODE_VOICE; // changed from speech
  fDev := 0; // default device
  if not TapiInitialize
     then TAPI_Initialized := False
  else
    begin
      TAPI_Initialized := true;
      with FLineCallParams do begin
        dwTotalSize := sizeof(FLineCallParams);
        dwBearerMode := fBearerMode;;
        dwMediaMode := fMediaMode;
      end;
    end;
    EnumerateDevices; // fill the combobox with the available devices
  // Open line to get valid Port Handle : June 27, 1998
  LineOpenResult := LineOpen(LineApp, FDev, @ALine, FVersion, 0, 0,
        LINECALLPRIVILEGE_NONE, fMediaMode, nil);
  if LineOpenResult=0  then
    begin
      LineIsOpen := true; // initial value
      ALineIsOpen := True;
     {   }
       // next line moved here to get valid FPort value
       FPort := GetPortHandle; // added 18 Jan 98
       // create thread suspended
       CommStatusThread := TCommStatus.Init(Self, true, FPort);
    end
  else
    begin
      LineIsOpen := false; // initial value
      ALineIsOpen := false;
    end;
    AKkamTAPI := Self;
    AkkamTAPI.LineIsOpen := True;
end;  { Create }

{ TCommStatus }

constructor TCommStatus.Init(Owner : TComponent;
                             Suspended : Boolean; PortRead : THandle);
begin
  inherited Create(Suspended);
  TheOwner := Owner;
  SetPort(PortRead);
end;

procedure TCommStatus.TriggerTapiCommEvent(Sender : TObject;
                          CommEvent : TCommEvent; Status : integer);
begin
  TkkamTAPI(TheOwner).TriggerCommEvent(Sender, CommEvent, Status);
end;

procedure TCommStatus.Execute;
var
  dwEvent: DWord;
  dwStatus: DWord;
begin
  dwEvent := 0;
  SetCommMask(ThePort, EV_DSR or EV_CTS or SETDTR);
  repeat
     WaitCommEvent(THandle(ThePort), dwEvent, nil);
     GetCommModemStatus(THandle(ThePort), dwStatus);
     case dwEvent of                            
        EV_DSR:  TriggerTapiCommEvent(Self, tceDSR, green);
          // TapiCallManager.SetBitmap(TapiCallManager.DSR, green);
        SETDTR:  TriggerTapiCommEvent(Self, tceDTR, green);
          //TapiCallManager.SetBitmap(TapiCallManager.DTR, green);
        EV_CTS:  TriggerTapiCommEvent(Self, tceCTS, green);
          //TapiCallManager.SetBitmap(TapiCallManager.CTS, green);
     end;
   until Terminated;
end;

procedure TCommStatus.SetPort(Value : THandle);
begin
  ThePort := Value;
end;

function TCommStatus.GetPort : THandle;
begin
  result := ThePort;
end;

procedure Register;
begin
  RegisterComponents('Tapi', [TkkamTAPI]);
  { CDK: If you want to register your non-visual component without it appearing on the palette,use
RegisterNoIcon in place of RegisterComponents:
  RegisterNoIcon([TkkamTAPI]); }
end;  { Register }

function TkkamTAPI.OpenPhone: Boolean;
var
  dwDeviceID: DWORD;
  phPhone: LPHPHONE;
  APIVersion: DWORD;
  ExtVersion: DWORD;
  CallbackInstance: DWORD;
  Privilege: DWORD;
begin
  phoneOpen(PhoneApp,
    dwDeviceID,
    phPhone,
    APIVersion,
    ExtVersion,
    CallbackInstance,
    Privilege);
end;

end.
