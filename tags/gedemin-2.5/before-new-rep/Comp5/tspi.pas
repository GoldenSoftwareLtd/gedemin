unit Tspi;

{-----------------------------------------------------------------------------
  This unit has been brought to you by the volunteers of the JEDI project.
  To learn more about the JEDI project, please visit
     http://www.delphi-jedi.org/

              J E D I  (Joint Endeavor of Delphi Innovators)

  Unit:       tspi.pas
  Source:     tspi.h
  Location:   http://www.delphi-jedi.org/apilib/tapi.zip
  Team:       Team 1
  Released:   1997-11-11 (for testing)

  Note: Conversion notes may be located by searching for the keyword "JEDI".

  Translators
  -----------
    Brad Choate <choate@delphiexchange.com>

  Revision History
  ----------------
    1997-11-11 -BC  Initial translation.

  Notes
  -----
    - This unit is not fully compatible with Delphi 1.

-----------------------------------------------------------------------------}

(*++ BUILD Version: 0000    // Increment this if a change has global effects

The  Telephony  API  is jointly copyrighted by Intel and Microsoft.  You are
granted  a royalty free worldwide, unlimited license to make copies, and use
the   API/SPI  for  making  applications/drivers  that  interface  with  the
specification provided that this paragraph and the Intel/Microsoft copyright
statement is maintained as is in the text and source code files.

Copyright (c) 1992-1996  Microsoft Corporation
Portions copyright 1992, 1993 Intel/Microsoft, all rights reserved.

Module Name:

    tspi.h

Notes:

    Additions to the Telephony Service Provider Interface (TSPI) since
    version 1.0 are noted by version number (i.e. "TSPI v1.4").

--*)

{!! JEDI:bchoate:1997-11-11: The following define enables support for TAPI
 2.0 }
{$IFNDEF Tapi_Ver14}
{$DEFINE Tapi_Ver20_ORGREATER}
{$DEFINE Tapi_Ver20_GREATER}
{$ENDIF}

interface

uses
  Windows, tapi;

{!! JEDI:bchoate:1997-11-11: The following C compatibility types were added }
type
  INT = Longint;
  LONG = Longint;
  LPVOID = Pointer;

{$IFDEF Win32}
{$IFNDEF Tapi_Ver20_ORGREATER}
Error: Building a 32bit 1.3 or 1.4 service provider is not supported.
{$ENDIF}
{$ENDIF}

(*
// tspi.h  is  only  of  use  in  conjunction  with tapi.h.  Very few types are
// defined  in  tspi.h.   Most  types of procedure formal parameters are simply
// passed through from corresponding procedures in tapi.h.  A working knowledge
// of the TAPI interface is required for an understanding of this interface.
*)


{// DECLARE_OPAQUE32(HDRVCALL);}
type
  HDRVCALL__ = record
    unused: int;
    end;
  HDRVCALL = HDRVCALL__;
  LPHDRVCALL = ^HDRVCALL;

{// DECLARE_OPAQUE32(HDRVLINE);}
  HDRVLINE__ = record
    unused: int;
    end;
  HDRVLINE = HDRVLINE__;
  LPHDRVLINE = ^HDRVLINE;

{// DECLARE_OPAQUE32(HDRVPHONE);}
  HDRVPHONE__ = record
    unused: int;
    end;
  HDRVPHONE = HDRVPHONE__;
  LPHDRVPHONE = ^HDRVPHONE;

{// DECLARE_OPAQUE32(HDRVDIALOGINSTANCE);}
  HDRVDIALOGINSTANCE__ = record
    unused: int;
    end;
  HDRVDIALOGINSTANCE = HDRVDIALOGINSTANCE__;
  LPHDRVDIALOGINSTANCE = ^HDRVDIALOGINSTANCE;

{// DECLARE_OPAQUE32(HTAPICALL);}
  HTAPICALL__ = record
    unused: int;
    end;
  HTAPICALL = HTAPICALL__;
  LPHTAPICALL = ^HTAPICALL;

{// DECLARE_OPAQUE32(HTAPILINE);}
  HTAPILINE__ = record
    unused: int;
    end;
  HTAPILINE = HTAPILINE__;
  LPHTAPILINE = ^HTAPILINE;

{// DECLARE_OPAQUE32(HTAPIPHONE);}
  HTAPIPHONE__ = record
    unused: int;
    end;
  HTAPIPHONE = HTAPIPHONE__;
  LPHTAPIPHONE = ^HTAPIPHONE;

{// DECLARE_OPAQUE32(HTAPIDIALOGINSTANCE);}
  HTAPIDIALOGINSTANCE__ = record
    unused: int;
    end;
  HTAPIDIALOGINSTANCE = HTAPIDIALOGINSTANCE__;
  LPHTAPIDIALOGINSTANCE = ^HTAPIDIALOGINSTANCE;

{// DECLARE_OPAQUE32(HPROVIDER);}
  HPROVIDER__ = record
    unused: int;
    end;
  HPROVIDER = HPROVIDER__;
  LPHPROVIDER = ^HPROVIDER;

  DRV_REQUESTID = DWORD;

  TASYNC_COMPLETION = procedure(
    dwRequestID:   DRV_REQUESTID;
    lResult:       LONG
    );
    stdcall;

  TLINEEVENT = procedure(
    htLine:        HTAPILINE;
    htCall:        HTAPICALL;
    dwMsg:         DWORD;
    dwParam1:      DWORD;
    dwParam2:      DWORD;
    dwParam3:      DWORD
    );
    stdcall;

  TPHONEEVENT = procedure(
    htPhone:       HTAPIPHONE;
    dwMsg:         DWORD;
    dwParam1:      DWORD;
    dwParam2:      DWORD;
    dwParam3:      DWORD
    );
    stdcall;

  TUISPIDLLCALLBACK = function(
    dwObjectID:    DWORD;
    dwObjectType:  DWORD;
    lpParams:      LPVOID;
    dwSize:        DWORD
    ): LONG;
    stdcall;


{$IFDEF Tapi_Ver20_ORGREATER}
  type
    LPTUISPICREATEDIALOGINSTANCEPARAMS = ^TUISPICREATEDIALOGINSTANCEPARAMS;
    TUISPICREATEDIALOGINSTANCEPARAMS =
      record
        dwRequestID: DRV_REQUESTID;
        hdDlgInst: HDRVDIALOGINSTANCE;
        htDlgInst: HTAPIDIALOGINSTANCE;
        lpszUIDLLName: LPCWSTR;
        lpParams: LPVOID;
        dwSize: DWORD;
      end;
{$ENDIF}

  const
    TSPI_MESSAGE_BASE = 500;
      {// The lowest-numbered TSPI-specific message ID number}
    LINE_NEWCALL:                LONG = TSPI_MESSAGE_BASE + 0;
    LINE_CALLDEVSPECIFIC:        LONG = TSPI_MESSAGE_BASE + 1;
    LINE_CALLDEVSPECIFICFEATURE: LONG = TSPI_MESSAGE_BASE + 2;
{$IFDEF Tapi_Ver20_ORGREATER}
    LINE_CREATEDIALOGINSTANCE:   LONG = TSPI_MESSAGE_BASE + 3;
                                                           {// TSPI v2.0}
    LINE_SENDDIALOGINSTANCEDATA: LONG = TSPI_MESSAGE_BASE + 4;
                                                           {// TSPI v2.0}
{$ENDIF}

{$IFDEF Tapi_Ver20_ORGREATER}
  const
    LINETSPIOPTION_NONREENTRANT           = $00000001;     {// TSPI v2.0}
{$ENDIF}


{$IFDEF Tapi_Ver20_ORGREATER}
  const
    TUISPIDLL_OBJECT_LINEID               = 1;             {// TSPI v2.0}
    TUISPIDLL_OBJECT_PHONEID              = 2;             {// TSPI v2.0}
    TUISPIDLL_OBJECT_PROVIDERID           = 3;             {// TSPI v2.0}
    TUISPIDLL_OBJECT_DIALOGINSTANCE       = 4;             {// TSPI v2.0}
{$ENDIF}


(*
// The following function prototypes pertain
// to a service provider's core module
*)


function TSPI_lineAccept(
    dwRequestID:        DRV_REQUESTID;
    hdCall:             HDRVCALL;
    lpsUserUserInfo:    LPCSTR;
    dwSize:             DWORD
    ): LONG;
    stdcall;

function TSPI_lineAddToConference(
    dwRequestID:        DRV_REQUESTID;
    hdConfCall:         HDRVCALL;
    hdConsultCall:      HDRVCALL
    ): LONG;
    stdcall;

function TSPI_lineAnswer(
    dwRequestID:        DRV_REQUESTID;
    hdCall:             HDRVCALL;
    lpsUserUserInfo:    LPCSTR;
    dwSize:             DWORD
    ): LONG;
    stdcall;

{$IFDEF Tapi_Ver20_ORGREATER}
function TSPI_lineBlindTransfer(
    dwRequestID:        DRV_REQUESTID;
    hdCall:             HDRVCALL;
    lpszDestAddress:    LPCWSTR;
    dwCountryCode:      DWORD
    ): LONG;
    stdcall;
{$ELSE}
function TSPI_lineBlindTransfer(
    dwRequestID:        DRV_REQUESTID;
    hdCall:             HDRVCALL;
    lpszDestAddress:    LPCSTR;
    dwCountryCode:      DWORD
    ): LONG;
    stdcall;
{$ENDIF}

function TSPI_lineClose(
    hdLine:             HDRVLINE
    ): LONG;
    stdcall;

function TSPI_lineCloseCall(
    hdCall:             HDRVCALL
    ): LONG;
    stdcall;

function TSPI_lineCompleteCall(
    dwRequestID:        DRV_REQUESTID;
    hdCall:             HDRVCALL;
    lpdwCompletionID:   LPDWORD;
    dwCompletionMode:   DWORD;
    dwMessageID:        DWORD
    ): LONG;
    stdcall;

function TSPI_lineCompleteTransfer(
    dwRequestID:        DRV_REQUESTID;
    hdCall:             HDRVCALL;
    hdConsultCall:      HDRVCALL;
    htConfCall:         HTAPICALL;
    lphdConfCall:       LPHDRVCALL;
    dwTransferMode:     DWORD
    ): LONG;
    stdcall;

function TSPI_lineConditionalMediaDetection(
    hdLine:             HDRVLINE;
    dwMediaModes:       DWORD;
    const lpCallParams: LPLINECALLPARAMS
    ): LONG;
    stdcall;

function TSPI_lineDevSpecific(
    dwRequestID:        DRV_REQUESTID;
    hdLine:             HDRVLINE;
    dwAddressID:        DWORD;
    hdCall:             HDRVCALL;
    lpParams:           LPVOID;
    dwSize:             DWORD
    ): LONG;
    stdcall;

function TSPI_lineDevSpecificFeature(
    dwRequestID:        DRV_REQUESTID;
    hdLine:             HDRVLINE;
    dwFeature:          DWORD;
    lpParams:           LPVOID;
    dwSize:             DWORD
    ): LONG;
    stdcall;

{$IFDEF Tapi_Ver20_ORGREATER}
function TSPI_lineDial(
    dwRequestID:        DRV_REQUESTID;
    hdCall:             HDRVCALL;
    lpszDestAddress:    LPCWSTR;
    dwCountryCode:      DWORD
    ): LONG;
    stdcall;
{$ELSE}
function TSPI_lineDial(
    dwRequestID:        DRV_REQUESTID;
    hdCall:             HDRVCALL;
    lpszDestAddress:    LPCSTR;
    dwCountryCode:      DWORD
    ): LONG;
    stdcall;
{$ENDIF}

function TSPI_lineDrop(
    dwRequestID:        DRV_REQUESTID;
    hdCall:             HDRVCALL;
    lpsUserUserInfo:    LPCSTR;
    dwSize:             DWORD
    ): LONG;
    stdcall;

function TSPI_lineDropOnClose(                             {// TSPI v1.4}
    hdCall:             HDRVCALL
    ): LONG;
    stdcall;

function TSPI_lineDropNoOwner(                             {// TSPI v1.4}
    hdCall:             HDRVCALL
    ): LONG;
    stdcall;

function TSPI_lineForward(
    dwRequestID:        DRV_REQUESTID;
    hdLine:             HDRVLINE;
    bAllAddresses:      DWORD;
    dwAddressID:        DWORD;
    const lpForwardList: LPLINEFORWARDLIST;
    dwNumRingsNoAnswer: DWORD;
    htConsultCall:      HTAPICALL;
    lphdConsultCall:    LPHDRVCALL;
    const lpCallParams: LPLINECALLPARAMS
    ): LONG;
    stdcall;

{$IFDEF Tapi_Ver20_ORGREATER}
function TSPI_lineGatherDigits(
    hdCall:             HDRVCALL;
    dwEndToEndID:       DWORD;
    dwDigitModes:       DWORD;
    lpsDigits:          LPWSTR;
    dwNumDigits:        DWORD;
    lpszTerminationDigits: LPCWSTR;
    dwFirstDigitTimeout: DWORD;
    dwInterDigitTimeout: DWORD
    ): LONG;
    stdcall;
{$ELSE}
function TSPI_lineGatherDigits(
    hdCall:             HDRVCALL;
    dwEndToEndID:       DWORD;
    dwDigitModes:       DWORD;
    lpsDigits:          LPSTR;
    dwNumDigits:        DWORD;
    lpszTerminationDigits: LPCSTR;
    dwFirstDigitTimeout: DWORD;
    dwInterDigitTimeout: DWORD
    ): LONG;
    stdcall;
{$ENDIF}

{$IFDEF Tapi_Ver20_ORGREATER}
function TSPI_lineGenerateDigits(
    hdCall:             HDRVCALL;
    dwEndToEndID:       DWORD;
    dwDigitMode:        DWORD;
    lpszDigits:         LPCWSTR;
    dwDuration:         DWORD
    ): LONG;
    stdcall;
{$ELSE}
function TSPI_lineGenerateDigits(
    hdCall:             HDRVCALL;
    dwEndToEndID:       DWORD;
    dwDigitMode:        DWORD;
    lpszDigits:         LPCSTR;
    dwDuration:         DWORD
    ): LONG;
    stdcall;
{$ENDIF}

function TSPI_lineGenerateTone(
    hdCall:             HDRVCALL;
    dwEndToEndID:       DWORD;
    dwToneMode:         DWORD;
    dwDuration:         DWORD;
    dwNumTones:         DWORD;
    const lpTones:      LPLINEGENERATETONE
    ): LONG;
    stdcall;

function TSPI_lineGetAddressCaps(
    dwDeviceID:         DWORD;
    dwAddressID:        DWORD;
    dwTSPIVersion:      DWORD;
    dwExtVersion:       DWORD;
    lpAddressCaps:      LPLINEADDRESSCAPS
    ): LONG;
    stdcall;

{$IFDEF Tapi_Ver20_ORGREATER}
function TSPI_lineGetAddressID(
    hdLine:             HDRVLINE;
    lpdwAddressID:      LPDWORD;
    dwAddressMode:      DWORD;
    lpsAddress:         LPCWSTR;
    dwSize:             DWORD
    ): LONG;
    stdcall;
{$ELSE}
function TSPI_lineGetAddressID(
    hdLine:             HDRVLINE;
    lpdwAddressID:      LPDWORD;
    dwAddressMode:      DWORD;
    lpsAddress:         LPCSTR;
    dwSize:             DWORD
    ): LONG;
    stdcall;
{$ENDIF}

function TSPI_lineGetAddressStatus(
    hdLine:             HDRVLINE;
    dwAddressID:        DWORD;
    lpAddressStatus:    LPLINEADDRESSSTATUS
    ): LONG;
    stdcall;

function TSPI_lineGetCallAddressID(
    hdCall:             HDRVCALL;
    lpdwAddressID:      LPDWORD
    ): LONG;
    stdcall;

function TSPI_lineGetCallInfo(
    hdCall:             HDRVCALL;
    lpCallInfo:         LPLINECALLINFO
    ): LONG;
    stdcall;

function TSPI_lineGetCallStatus(
    hdCall:             HDRVCALL;
    lpCallStatus:       LPLINECALLSTATUS
    ): LONG;
    stdcall;

function TSPI_lineGetDevCaps(
    dwDeviceID:         DWORD;
    dwTSPIVersion:      DWORD;
    dwExtVersion:       DWORD;
    lpLineDevCaps:      LPLINEDEVCAPS
    ): LONG;
    stdcall;

{$IFDEF Tapi_Ver20_ORGREATER}
function TSPI_lineGetDevConfig(
    dwDeviceID:         DWORD;
    lpDeviceConfig:     LPVARSTRING;
    lpszDeviceClass:    LPCWSTR
    ): LONG;
    stdcall;
{$ELSE}
function TSPI_lineGetDevConfig(
    dwDeviceID:         DWORD;
    lpDeviceConfig:     LPVARSTRING;
    lpszDeviceClass:    LPCSTR
    ): LONG;
    stdcall;
{$ENDIF}

function TSPI_lineGetExtensionID(
    dwDeviceID:         DWORD;
    dwTSPIVersion:      DWORD;
    lpExtensionID:      LPLINEEXTENSIONID
    ): LONG;
    stdcall;

{$IFDEF Tapi_Ver20_ORGREATER}
function TSPI_lineGetIcon(
    dwDeviceID:         DWORD;
    lpszDeviceClass:    LPCWSTR;
    lphIcon:            LPHICON
    ): LONG;
    stdcall;
{$ELSE}
function TSPI_lineGetIcon(
    dwDeviceID:         DWORD;
    lpszDeviceClass:    LPCSTR;
    lphIcon:            LPHICON
    ): LONG;
    stdcall;
{$ENDIF}

{$IFDEF Tapi_Ver20_ORGREATER}
function TSPI_lineGetID(
    hdLine:             HDRVLINE;
    dwAddressID:        DWORD;
    hdCall:             HDRVCALL;
    dwSelect:           DWORD;
    lpDeviceID:         LPVARSTRING;
    lpszDeviceClass:    LPCWSTR;
    hTargetProcess:     THANDLE                            {// TSPI v2.0}
    ): LONG;
    stdcall;
{$ELSE}
function TSPI_lineGetID(
    hdLine:             HDRVLINE;
    dwAddressID:        DWORD;
    hdCall:             HDRVCALL;
    dwSelect:           DWORD;
    lpDeviceID:         LPVARSTRING;
    lpszDeviceClass:    LPCSTR
    ): LONG;
    stdcall;
{$ENDIF}


function TSPI_lineGetLineDevStatus(
    hdLine:             HDRVLINE;
    lpLineDevStatus:    LPLINEDEVSTATUS
    ): LONG;
    stdcall;

function TSPI_lineGetNumAddressIDs(
    hdLine:             HDRVLINE;
    lpdwNumAddressIDs:  LPDWORD
    ): LONG;
    stdcall;

function TSPI_lineHold(
    dwRequestID:        DRV_REQUESTID;
    hdCall:             HDRVCALL
    ): LONG;
    stdcall;

{$IFDEF Tapi_Ver20_ORGREATER}
function TSPI_lineMakeCall(
    dwRequestID:        DRV_REQUESTID;
    hdLine:             HDRVLINE;
    htCall:             HTAPICALL;
    lphdCall:           LPHDRVCALL;
    lpszDestAddress:    LPCWSTR;
    dwCountryCode:      DWORD;
    const lpCallParams: LPLINECALLPARAMS
    ): LONG;
    stdcall;
{$ELSE}
function TSPI_lineMakeCall(
    dwRequestID:        DRV_REQUESTID;
    hdLine:             HDRVLINE;
    htCall:             HTAPICALL;
    lphdCall:           LPHDRVCALL;
    lpszDestAddress:    LPCSTR;
    dwCountryCode:      DWORD;
    const lpCallParams: LPLINECALLPARAMS
    ): LONG;
    stdcall;
{$ENDIF}

function TSPI_lineMonitorDigits(
    hdCall:             HDRVCALL;
    dwDigitModes:       DWORD
    ): LONG;
    stdcall;

function TSPI_lineMonitorMedia(
    hdCall:             HDRVCALL;
    dwMediaModes:       DWORD
    ): LONG;
    stdcall;

function TSPI_lineMonitorTones(
    hdCall:             HDRVCALL;
    dwToneListID:       DWORD;
    const lpToneList:   LPLINEMONITORTONE;
    dwNumEntries:       DWORD
    ): LONG;
    stdcall;

function TSPI_lineNegotiateExtVersion(
    dwDeviceID:         DWORD;
    dwTSPIVersion:      DWORD;
    dwLowVersion:       DWORD;
    dwHighVersion:      DWORD;
    lpdwExtVersion:     LPDWORD
    ): LONG;
    stdcall;

function TSPI_lineNegotiateTSPIVersion(
    dwDeviceID:         DWORD;
    dwLowVersion:       DWORD;
    dwHighVersion:      DWORD;
    lpdwTSPIVersion:    LPDWORD
    ): LONG;
    stdcall;

function TSPI_lineOpen(
    dwDeviceID:         DWORD;
    htLine:             HTAPILINE;
    lphdLine:           LPHDRVLINE;
    dwTSPIVersion:      DWORD;
    lpfnEventProc:      TLINEEVENT
    ): LONG;
    stdcall;

{$IFDEF Tapi_Ver20_ORGREATER}
function TSPI_linePark(
    dwRequestID:        DRV_REQUESTID;
    hdCall:             HDRVCALL;
    dwParkMode:         DWORD;
    lpszDirAddress:     LPCWSTR;
    lpNonDirAddress:    LPVARSTRING
    ): LONG;
    stdcall;
{$ELSE}
function TSPI_linePark(
    dwRequestID:        DRV_REQUESTID;
    hdCall:             HDRVCALL;
    dwParkMode:         DWORD;
    lpszDirAddress:     LPCSTR;
    lpNonDirAddress:    LPVARSTRING
    ): LONG;
    stdcall;
{$ENDIF}

{$IFDEF Tapi_Ver20_ORGREATER}
function TSPI_linePickup(
    dwRequestID:        DRV_REQUESTID;
    hdLine:             HDRVLINE;
    dwAddressID:        DWORD;
    htCall:             HTAPICALL;
    lphdCall:           LPHDRVCALL;
    lpszDestAddress:    LPCWSTR;
    lpszGroupID:        LPCWSTR
    ): LONG;
    stdcall;
{$ELSE}
function TSPI_linePickup(
    dwRequestID:        DRV_REQUESTID;
    hdLine:             HDRVLINE;
    dwAddressID:        DWORD;
    htCall:             HTAPICALL;
    lphdCall:           LPHDRVCALL;
    lpszDestAddress:    LPCSTR;
    lpszGroupID:        LPCSTR              
    ): LONG;
    stdcall;
{$ENDIF}

function TSPI_linePrepareAddToConference(
    dwRequestID:        DRV_REQUESTID;
    hdConfCall:         HDRVCALL;
    htConsultCall:      HTAPICALL;
    lphdConsultCall:    LPHDRVCALL;
    const lpCallParams: LPLINECALLPARAMS
    ): LONG;
    stdcall;

{$IFDEF Tapi_Ver20_ORGREATER}
function TSPI_lineRedirect(
    dwRequestID:        DRV_REQUESTID;
    hdCall:             HDRVCALL;
    lpszDestAddress:    LPCWSTR;
    dwCountryCode:      DWORD               
    ): LONG;
    stdcall;
{$ELSE}
function TSPI_lineRedirect(
    dwRequestID:        DRV_REQUESTID;
    hdCall:             HDRVCALL;
    lpszDestAddress:    LPCSTR;
    dwCountryCode:      DWORD
    ): LONG;
    stdcall;
{$ENDIF}

function TSPI_lineReleaseUserUserInfo(                     {// TSPI v1.4}
    dwRequestID:        DRV_REQUESTID;
    hdCall:             HDRVCALL
    ): LONG;
    stdcall;

function TSPI_lineRemoveFromConference(
    dwRequestID:        DRV_REQUESTID;
    hdCall:             HDRVCALL
    ): LONG;
    stdcall;

function TSPI_lineSecureCall(
    dwRequestID:        DRV_REQUESTID;
    hdCall:             HDRVCALL
    ): LONG;
    stdcall;

function TSPI_lineSelectExtVersion(
    hdLine:             HDRVLINE;
    dwExtVersion:       DWORD
    ): LONG;
    stdcall;

function TSPI_lineSendUserUserInfo(
    dwRequestID:        DRV_REQUESTID;
    hdCall:             HDRVCALL;
    lpsUserUserInfo:    LPCSTR;
    dwSize:             DWORD
    ): LONG;
    stdcall;

function TSPI_lineSetAppSpecific(
    hdCall:             HDRVCALL;
    dwAppSpecific:      DWORD
    ): LONG;
    stdcall;

{$IFDEF Tapi_Ver20_ORGREATER}
function TSPI_lineSetCallData(                             {// TSPI v2.0}
    dwRequestID:        DRV_REQUESTID;
    hdCall:             HDRVCALL;
    lpCallData:         LPVOID;
    dwSize:             DWORD
    ): LONG;
    stdcall;
{$ENDIF}

function TSPI_lineSetCallParams(
    dwRequestID:        DRV_REQUESTID;
    hdCall:             HDRVCALL;
    dwBearerMode:       DWORD;
    dwMinRate:          DWORD;
    dwMaxRate:          DWORD;
    const lpDialParams: LPLINEDIALPARAMS
    ): LONG;
    stdcall;

{$IFDEF Tapi_Ver20_ORGREATER}
function TSPI_lineSetCallQualityOfService(                 {// TSPI v2.0}
    dwRequestID:        DRV_REQUESTID;
    hdCall:             HDRVCALL;
    lpSendingFlowspec:  LPVOID;
    dwSendingFlowspecSize: DWORD;
    lpReceivingFlowspec: LPVOID;
    dwReceivingFlowspecSize: DWORD               
    ): LONG;
    stdcall;

function TSPI_lineSetCallTreatment(                        {// TSPI v2.0}
    dwRequestID:        DRV_REQUESTID;
    hdCall:             HDRVCALL;
    dwTreatment:        DWORD
    ): LONG;
    stdcall;
{$ENDIF}

function TSPI_lineSetCurrentLocation(                      {// TSPI v1.4}
    dwLocation:         DWORD
    ): LONG;
    stdcall;

function TSPI_lineSetDefaultMediaDetection(
    hdLine:             HDRVLINE;
    dwMediaModes:       DWORD               
    ): LONG;
    stdcall;

{$IFDEF Tapi_Ver20_ORGREATER}
function TSPI_lineSetDevConfig(
    dwDeviceID:         DWORD;
    const lpDeviceConfig: LPVOID;
    dwSize:             DWORD;
    lpszDeviceClass:    LPCWSTR
    ): LONG;
    stdcall;
{$ELSE}
function TSPI_lineSetDevConfig(
    dwDeviceID:         DWORD;
    const lpDeviceConfig: LPVOID;
    dwSize:             DWORD;
    lpszDeviceClass:    LPCSTR
    ): LONG;
    stdcall;
{$ENDIF}

{$IFDEF Tapi_Ver20_ORGREATER}
function TSPI_lineSetLineDevStatus(                        {// TSPI v2.0}
    dwRequestID:        DRV_REQUESTID;
    hdLine:             HDRVLINE;
    dwStatusToChange:   DWORD;
    fStatus:            DWORD               
    ): LONG;
    stdcall;
{$ENDIF}

function TSPI_lineSetMediaControl(
    hdLine:                     HDRVLINE;
    dwAddressID:                DWORD;
    hdCall:                     HDRVCALL;
    dwSelect:                   DWORD;
    const lpDigitList:          LPLINEMEDIACONTROLDIGIT;
    dwDigitNumEntries:          DWORD;
    const lpMediaList:          LPLINEMEDIACONTROLMEDIA;
    dwMediaNumEntries:          DWORD;
    const lpToneList:           LPLINEMEDIACONTROLTONE;
    dwToneNumEntries:           DWORD;
    const lpCallStateList:      LPLINEMEDIACONTROLCALLSTATE;
    dwCallStateNumEntries:      DWORD                       
    ): LONG;
    stdcall;

function TSPI_lineSetMediaMode(
    hdCall:             HDRVCALL;
    dwMediaMode:        DWORD
    ): LONG;
    stdcall;

function TSPI_lineSetStatusMessages(
    hdLine:             HDRVLINE;
    dwLineStates:       DWORD;
    dwAddressStates:    DWORD
    ): LONG;
    stdcall;

function TSPI_lineSetTerminal(
    dwRequestID:        DRV_REQUESTID;
    hdLine:             HDRVLINE;
    dwAddressID:        DWORD;
    hdCall:             HDRVCALL;
    dwSelect:           DWORD;
    dwTerminalModes:    DWORD;
    dwTerminalID:       DWORD;
    bEnable:            DWORD
    ): LONG;
    stdcall;

function TSPI_lineSetupConference(
    dwRequestID:        DRV_REQUESTID;
    hdCall:             HDRVCALL;
    hdLine:             HDRVLINE;
    htConfCall:         HTAPICALL;
    lphdConfCall:       LPHDRVCALL;
    htConsultCall:      HTAPICALL;
    lphdConsultCall:    LPHDRVCALL;
    dwNumParties:       DWORD;
    const lpCallParams: LPLINECALLPARAMS    
    ): LONG;
    stdcall;

function TSPI_lineSetupTransfer(
    dwRequestID:        DRV_REQUESTID;
    hdCall:             HDRVCALL;
    htConsultCall:      HTAPICALL;
    lphdConsultCall:    LPHDRVCALL;
    const lpCallParams: LPLINECALLPARAMS
    ): LONG;
    stdcall;

function TSPI_lineSwapHold(
    dwRequestID:        DRV_REQUESTID;
    hdActiveCall:       HDRVCALL;
    hdHeldCall:         HDRVCALL
    ): LONG;
    stdcall;

function TSPI_lineUncompleteCall(
    dwRequestID:        DRV_REQUESTID;
    hdLine:             HDRVLINE;
    dwCompletionID:     DWORD
    ): LONG;
    stdcall;

function TSPI_lineUnhold(
    dwRequestID:        DRV_REQUESTID;
    hdCall:             HDRVCALL            
    ): LONG;
    stdcall;

{$IFDEF Tapi_Ver20_ORGREATER}
function TSPI_lineUnpark(
    dwRequestID:        DRV_REQUESTID;
    hdLine:             HDRVLINE;
    dwAddressID:        DWORD;
    htCall:             HTAPICALL;
    lphdCall:           LPHDRVCALL;
    lpszDestAddress:    LPCWSTR
    ): LONG;
    stdcall;
{$ELSE}
function TSPI_lineUnpark(
    dwRequestID:        DRV_REQUESTID;
    hdLine:             HDRVLINE;
    dwAddressID:        DWORD;
    htCall:             HTAPICALL;
    lphdCall:           LPHDRVCALL;
    lpszDestAddress:    LPCSTR
    ): LONG;
    stdcall;
{$ENDIF}



function TSPI_phoneClose(
    hdPhone:            HDRVPHONE
    ): LONG;
    stdcall;

function TSPI_phoneDevSpecific(
    dwRequestID:        DRV_REQUESTID;
    hdPhone:            HDRVPHONE;
    lpParams:           LPVOID;
    dwSize:             DWORD
    ): LONG;
    stdcall;

function TSPI_phoneGetButtonInfo(
    hdPhone:            HDRVPHONE;
    dwButtonLampID:     DWORD;
    lpButtonInfo:       LPPHONEBUTTONINFO
    ): LONG;
    stdcall;

function TSPI_phoneGetData(
    hdPhone:            HDRVPHONE;
    dwDataID:           DWORD;
    lpData:             LPVOID;
    dwSize:             DWORD
    ): LONG;
    stdcall;

function TSPI_phoneGetDevCaps(
    dwDeviceID:         DWORD;
    dwTSPIVersion:      DWORD;
    dwExtVersion:       DWORD;
    lpPhoneCaps:        LPPHONECAPS
    ): LONG;
    stdcall;

function TSPI_phoneGetDisplay(
    hdPhone:            HDRVPHONE;
    lpDisplay:          LPVARSTRING
    ): LONG;
    stdcall;

function TSPI_phoneGetExtensionID(
    dwDeviceID:         DWORD;
    dwTSPIVersion:      DWORD;
    lpExtensionID:      LPPHONEEXTENSIONID
    ): LONG;
    stdcall;

function TSPI_phoneGetGain(
    hdPhone:            HDRVPHONE;
    dwHookSwitchDev:    DWORD;
    lpdwGain:           LPDWORD
    ): LONG;
    stdcall;

function TSPI_phoneGetHookSwitch(
    hdPhone:            HDRVPHONE;
    lpdwHookSwitchDevs: LPDWORD
    ): LONG;
    stdcall;

{$IFDEF Tapi_Ver20_ORGREATER}
function TSPI_phoneGetIcon(
    dwDeviceID:         DWORD;
    lpszDeviceClass:    LPCWSTR;
    lphIcon:            LPHICON
    ): LONG;
    stdcall;
{$ELSE}
function TSPI_phoneGetIcon(
    dwDeviceID:         DWORD;
    lpszDeviceClass:    LPCSTR;
    lphIcon:            LPHICON
    ): LONG;
    stdcall;
{$ENDIF}

{$IFDEF Tapi_Ver20_ORGREATER}
function TSPI_phoneGetID(
    hdPhone:            HDRVPHONE;
    lpDeviceID:         LPVARSTRING;
    lpszDeviceClass:    LPCWSTR;
    hTargetProcess:     THANDLE                            {// TSPI v2.0}
    ): LONG;
    stdcall;
{$ELSE}
function TSPI_phoneGetID(
    hdPhone:            HDRVPHONE;
    lpDeviceID:         LPVARSTRING;
    lpszDeviceClass:    LPCSTR
    ): LONG;
    stdcall;
{$ENDIF}

function TSPI_phoneGetLamp(
    hdPhone:            HDRVPHONE;
    dwButtonLampID:     DWORD;
    lpdwLampMode:       LPDWORD
    ): LONG;
    stdcall;

function TSPI_phoneGetRing(
    hdPhone:            HDRVPHONE;
    lpdwRingMode:       LPDWORD;
    lpdwVolume:         LPDWORD
    ): LONG;
    stdcall;

function TSPI_phoneGetStatus(
    hdPhone:            HDRVPHONE;
    lpPhoneStatus:      LPPHONESTATUS
    ): LONG;
    stdcall;

function TSPI_phoneGetVolume(
    hdPhone:            HDRVPHONE;
    dwHookSwitchDev:    DWORD;
    lpdwVolume:         LPDWORD
    ): LONG;
    stdcall;

function TSPI_phoneNegotiateExtVersion(
    dwDeviceID:         DWORD;
    dwTSPIVersion:      DWORD;
    dwLowVersion:       DWORD;
    dwHighVersion:      DWORD;
    lpdwExtVersion:     LPDWORD
    ): LONG;
    stdcall;

function TSPI_phoneNegotiateTSPIVersion(
    dwDeviceID:         DWORD;
    dwLowVersion:       DWORD;
    dwHighVersion:      DWORD;
    lpdwTSPIVersion:    LPDWORD
    ): LONG;
    stdcall;

function TSPI_phoneOpen(
    dwDeviceID:         DWORD;
    htPhone:            HTAPIPHONE;
    lphdPhone:          LPHDRVPHONE;
    dwTSPIVersion:      DWORD;
    lpfnEventProc:      TPHONEEVENT
    ): LONG;
    stdcall;

function TSPI_phoneSelectExtVersion(
    hdPhone:            HDRVPHONE;
    dwExtVersion:       DWORD
    ): LONG;
    stdcall;

function TSPI_phoneSetButtonInfo(
    dwRequestID:        DRV_REQUESTID;
    hdPhone:            HDRVPHONE;
    dwButtonLampID:     DWORD;
    const lpButtonInfo: LPPHONEBUTTONINFO
    ): LONG;
    stdcall;

function TSPI_phoneSetData(
    dwRequestID:        DRV_REQUESTID;
    hdPhone:            HDRVPHONE;
    dwDataID:           DWORD;
    const lpData:       LPVOID;
    dwSize:             DWORD
    ): LONG;
    stdcall;

{$IFDEF Tapi_Ver20_ORGREATER}
function TSPI_phoneSetDisplay(
    dwRequestID:        DRV_REQUESTID;
    hdPhone:            HDRVPHONE;
    dwRow:              DWORD;
    dwColumn:           DWORD;
    lpsDisplay:         LPCWSTR;
    dwSize:             DWORD
    ): LONG;
    stdcall;
{$ELSE}
function TSPI_phoneSetDisplay(
    dwRequestID:        DRV_REQUESTID;
    hdPhone:            HDRVPHONE;
    dwRow:              DWORD;
    dwColumn:           DWORD;
    lpsDisplay:         LPCSTR;
    dwSize:             DWORD
    ): LONG;
    stdcall;
{$ENDIF}

function TSPI_phoneSetGain(
    dwRequestID:        DRV_REQUESTID;
    hdPhone:            HDRVPHONE;
    dwHookSwitchDev:    DWORD;
    dwGain:             DWORD
    ): LONG;
    stdcall;

function TSPI_phoneSetHookSwitch(
    dwRequestID:        DRV_REQUESTID;
    hdPhone:            HDRVPHONE;
    dwHookSwitchDevs:   DWORD;
    dwHookSwitchMode:   DWORD
    ): LONG;
    stdcall;

function TSPI_phoneSetLamp(
    dwRequestID:        DRV_REQUESTID;
    hdPhone:            HDRVPHONE;
    dwButtonLampID:     DWORD;
    dwLampMode:         DWORD               
    ): LONG;
    stdcall;

function TSPI_phoneSetRing(
    dwRequestID:        DRV_REQUESTID;
    hdPhone:            HDRVPHONE;
    dwRingMode:         DWORD;
    dwVolume:           DWORD
    ): LONG;
    stdcall;

function TSPI_phoneSetStatusMessages(
    hdPhone:            HDRVPHONE;
    dwPhoneStates:      DWORD;
    dwButtonModes:      DWORD;
    dwButtonStates:     DWORD
    ): LONG;
    stdcall;

function TSPI_phoneSetVolume(
    dwRequestID:        DRV_REQUESTID;
    hdPhone:            HDRVPHONE;
    dwHookSwitchDev:    DWORD;
    dwVolume:           DWORD               
    ): LONG;
    stdcall;



function TSPI_providerCreateLineDevice(                    {// TSPI v1.4}
    dwTempID:           DWORD;
    dwDeviceID:         DWORD
    ): LONG;
    stdcall;

function TSPI_providerCreatePhoneDevice(                   {// TSPI v1.4}
    dwTempID:           DWORD;
    dwDeviceID:         DWORD
    ): LONG;
    stdcall;

function TSPI_providerEnumDevices(                         {// TSPI v1.4}
    dwPermanentProviderID: DWORD;
    lpdwNumLines:       LPDWORD;
    lpdwNumPhones:      LPDWORD;
    hProvider:          HPROVIDER;
    lpfnLineCreateProc: TLINEEVENT;
    lpfnPhoneCreateProc: TPHONEEVENT
    ): LONG;
    stdcall;

{$IFDEF Tapi_Ver20_ORGREATER}
function TSPI_providerFreeDialogInstance(                  {// TSPI v2.0}
    hdDlgInst:          HDRVDIALOGINSTANCE
    ): LONG;
    stdcall;

function TSPI_providerGenericDialogData(                   {// TSPI v2.0}
    dwObjectID:         DWORD;
    dwObjectType:       DWORD;
    lpParams:           LPVOID;
    dwSize:             DWORD
    ): LONG;
    stdcall;
{$ENDIF}

function TSPI_providerInit(
    dwTSPIVersion:      DWORD;
    dwPermanentProviderID: DWORD;
    dwLineDeviceIDBase: DWORD;
    dwPhoneDeviceIDBase: DWORD;
    dwNumLines:         DWORD;
    dwNumPhones:        DWORD;
    lpfnCompletionProc: TASYNC_COMPLETION
{$IFDEF Tapi_Ver20_ORGREATER}
    ;
    lpdwTSPIOptions:    LPDWORD                            {// TSPI v2.0}
{$ENDIF}
    ): LONG;
    stdcall;

function TSPI_providerInstall(
    hwndOwner:          HWND;
    dwPermanentProviderID: DWORD
    ): LONG;
    stdcall;

function TSPI_providerRemove(
    hwndOwner:          HWND;
    dwPermanentProviderID: DWORD
    ): LONG;
    stdcall;

function TSPI_providerShutdown(
    dwTSPIVersion:      DWORD
{$IFDEF Tapi_Ver20_ORGREATER}
    ;
    dwPermanentProviderID: DWORD                           {// TSPI v2.0}
{$ENDIF}
    ): LONG;
    stdcall;

{$IFDEF Tapi_Ver20_ORGREATER}
function TSPI_providerUIIdentify(                          {// TSPI v2.0}
    lpszUIDLLName:         LPWSTR
    ): LONG;
    stdcall;
{$ENDIF}



{$IFDEF Tapi_Ver20_ORGREATER}
//
// The following function prototypes pertain
// to a service provider's UI module
//

function TUISPI_lineConfigDialog(                          {// TSPI v2.0}
    lpfnUIDLLCallback:  TUISPIDLLCALLBACK;
    dwDeviceID:         DWORD;
    hwndOwner:          HWND;
    lpszDeviceClass:    LPCWSTR
    ): LONG;
    stdcall;

function TUISPI_lineConfigDialogEdit(                      {// TSPI v2.0}
    lpfnUIDLLCallback:  TUISPIDLLCALLBACK;
    dwDeviceID:         DWORD;
    hwndOwner:          HWND;
    lpszDeviceClass:    LPCWSTR;
    const lpDeviceConfigIn: LPVOID;
    dwSize:             DWORD;
    lpDeviceConfigOut:  LPVARSTRING
    ): LONG;
    stdcall;

function TUISPI_phoneConfigDialog(                         {// TSPI v2.0}
    lpfnUIDLLCallback:  TUISPIDLLCALLBACK;
    dwDeviceID:         DWORD;
    hwndOwner:          HWND;
    lpszDeviceClass:    LPCWSTR             
    ): LONG;
    stdcall;

function TUISPI_providerConfig(                            {// TSPI v2.0}
    lpfnUIDLLCallback:  TUISPIDLLCALLBACK;
    hwndOwner:          HWND;
    dwPermanentProviderID: DWORD
    ): LONG;
    stdcall;

function TUISPI_providerGenericDialog(                     {// TSPI v2.0}
    lpfnUIDLLCallback:  TUISPIDLLCALLBACK;
    htDlgInst:          HTAPIDIALOGINSTANCE;
    lpParams:           LPVOID;
    dwSize:             DWORD;
    hEvent:             THANDLE
    ): LONG;
    stdcall;

function TUISPI_providerGenericDialogData(                 {// TSPI v2.0}
    htDlgInst:          HTAPIDIALOGINSTANCE;
    lpParams:           LPVOID;
    dwSize:             DWORD
    ): LONG;
    stdcall;

function TUISPI_providerInstall(                           {// TSPI v2.0}
    lpfnUIDLLCallback:  TUISPIDLLCALLBACK;
    hwndOwner:          HWND;
    dwPermanentProviderID: DWORD
    ): LONG;
    stdcall;

function TUISPI_providerRemove(                            {// TSPI v2.0}
    lpfnUIDLLCallback:  TUISPIDLLCALLBACK;
    hwndOwner:          HWND;
    dwPermanentProviderID: DWORD
    ): LONG;
    stdcall;

{$ELSE}

(*
// The following were obsoleted by the above (but are needed to build 1.4 SPs)
*)
function TSPI_lineConfigDialog(
    dwDeviceID:         DWORD;
    hwndOwner:          HWND;
    lpszDeviceClass:    LPCSTR): LONG;
    stdcall;

function TSPI_lineConfigDialogEdit(
    dwDeviceID:         DWORD;
    hwndOwner:          HWND;
    lpszDeviceClass:    LPCSTR;
    const lpDeviceConfigIn: LPVOID;
    dwSize:             DWORD;
    lpDeviceConfigOut:  LPVARSTRING): LONG;
    stdcall;

function TSPI_phoneConfigDialog(
    dwDeviceID:         DWORD;
    hwndOwner:          HWND;
    lpszDeviceClass:    LPCSTR): LONG;
    stdcall;

function TSPI_providerConfig(
    hwndOwner:          HWND;
    dwPermanentProviderID: DWORD): LONG;
    stdcall;


{$ENDIF}



{$ifndef Tapi_Ver20_ORGREATER}

(*
// The following macros are the ordinal numbers of the exported tspi functions
*)

(*
#define TSPI_PROC_BASE                      500

#define TSPI_LINEACCEPT                     (TSPI_PROC_BASE + 0)
#define TSPI_LINEADDTOCONFERENCE            (TSPI_PROC_BASE + 1)
#define TSPI_LINEANSWER                     (TSPI_PROC_BASE + 2)
#define TSPI_LINEBLINDTRANSFER              (TSPI_PROC_BASE + 3)
#define TSPI_LINECLOSE                      (TSPI_PROC_BASE + 4)
#define TSPI_LINECLOSECALL                  (TSPI_PROC_BASE + 5)
#define TSPI_LINECOMPLETECALL               (TSPI_PROC_BASE + 6)
#define TSPI_LINECOMPLETETRANSFER           (TSPI_PROC_BASE + 7)
#define TSPI_LINECONDITIONALMEDIADETECTION  (TSPI_PROC_BASE + 8)
#define TSPI_LINECONFIGDIALOG               (TSPI_PROC_BASE + 9)
#define TSPI_LINEDEVSPECIFIC                (TSPI_PROC_BASE + 10)
#define TSPI_LINEDEVSPECIFICFEATURE         (TSPI_PROC_BASE + 11)
#define TSPI_LINEDIAL                       (TSPI_PROC_BASE + 12)
#define TSPI_LINEDROP                       (TSPI_PROC_BASE + 13)
#define TSPI_LINEFORWARD                    (TSPI_PROC_BASE + 14)
#define TSPI_LINEGATHERDIGITS               (TSPI_PROC_BASE + 15)
#define TSPI_LINEGENERATEDIGITS             (TSPI_PROC_BASE + 16)
#define TSPI_LINEGENERATETONE               (TSPI_PROC_BASE + 17)
#define TSPI_LINEGETADDRESSCAPS             (TSPI_PROC_BASE + 18)
#define TSPI_LINEGETADDRESSID               (TSPI_PROC_BASE + 19)
#define TSPI_LINEGETADDRESSSTATUS           (TSPI_PROC_BASE + 20)
#define TSPI_LINEGETCALLADDRESSID           (TSPI_PROC_BASE + 21)
#define TSPI_LINEGETCALLINFO                (TSPI_PROC_BASE + 22)
#define TSPI_LINEGETCALLSTATUS              (TSPI_PROC_BASE + 23)
#define TSPI_LINEGETDEVCAPS                 (TSPI_PROC_BASE + 24)
#define TSPI_LINEGETDEVCONFIG               (TSPI_PROC_BASE + 25)
#define TSPI_LINEGETEXTENSIONID             (TSPI_PROC_BASE + 26)
#define TSPI_LINEGETICON                    (TSPI_PROC_BASE + 27)
#define TSPI_LINEGETID                      (TSPI_PROC_BASE + 28)
#define TSPI_LINEGETLINEDEVSTATUS           (TSPI_PROC_BASE + 29)
#define TSPI_LINEGETNUMADDRESSIDS           (TSPI_PROC_BASE + 30)
#define TSPI_LINEHOLD                       (TSPI_PROC_BASE + 31)
#define TSPI_LINEMAKECALL                   (TSPI_PROC_BASE + 32)
#define TSPI_LINEMONITORDIGITS              (TSPI_PROC_BASE + 33)
#define TSPI_LINEMONITORMEDIA               (TSPI_PROC_BASE + 34)
#define TSPI_LINEMONITORTONES               (TSPI_PROC_BASE + 35)
#define TSPI_LINENEGOTIATEEXTVERSION        (TSPI_PROC_BASE + 36)
#define TSPI_LINENEGOTIATETSPIVERSION       (TSPI_PROC_BASE + 37)
#define TSPI_LINEOPEN                       (TSPI_PROC_BASE + 38)
#define TSPI_LINEPARK                       (TSPI_PROC_BASE + 39)
#define TSPI_LINEPICKUP                     (TSPI_PROC_BASE + 40)
#define TSPI_LINEPREPAREADDTOCONFERENCE     (TSPI_PROC_BASE + 41)
#define TSPI_LINEREDIRECT                   (TSPI_PROC_BASE + 42)
#define TSPI_LINEREMOVEFROMCONFERENCE       (TSPI_PROC_BASE + 43)
#define TSPI_LINESECURECALL                 (TSPI_PROC_BASE + 44)
#define TSPI_LINESELECTEXTVERSION           (TSPI_PROC_BASE + 45)
#define TSPI_LINESENDUSERUSERINFO           (TSPI_PROC_BASE + 46)
#define TSPI_LINESETAPPSPECIFIC             (TSPI_PROC_BASE + 47)
#define TSPI_LINESETCALLPARAMS              (TSPI_PROC_BASE + 48)
#define TSPI_LINESETDEFAULTMEDIADETECTION   (TSPI_PROC_BASE + 49)
#define TSPI_LINESETDEVCONFIG               (TSPI_PROC_BASE + 50)
#define TSPI_LINESETMEDIACONTROL            (TSPI_PROC_BASE + 51)
#define TSPI_LINESETMEDIAMODE               (TSPI_PROC_BASE + 52)
#define TSPI_LINESETSTATUSMESSAGES          (TSPI_PROC_BASE + 53)
#define TSPI_LINESETTERMINAL                (TSPI_PROC_BASE + 54)
#define TSPI_LINESETUPCONFERENCE            (TSPI_PROC_BASE + 55)
#define TSPI_LINESETUPTRANSFER              (TSPI_PROC_BASE + 56)
#define TSPI_LINESWAPHOLD                   (TSPI_PROC_BASE + 57)
#define TSPI_LINEUNCOMPLETECALL             (TSPI_PROC_BASE + 58)
#define TSPI_LINEUNHOLD                     (TSPI_PROC_BASE + 59)
#define TSPI_LINEUNPARK                     (TSPI_PROC_BASE + 60)
#define TSPI_PHONECLOSE                     (TSPI_PROC_BASE + 61)
#define TSPI_PHONECONFIGDIALOG              (TSPI_PROC_BASE + 62)
#define TSPI_PHONEDEVSPECIFIC               (TSPI_PROC_BASE + 63)
#define TSPI_PHONEGETBUTTONINFO             (TSPI_PROC_BASE + 64)
#define TSPI_PHONEGETDATA                   (TSPI_PROC_BASE + 65)
#define TSPI_PHONEGETDEVCAPS                (TSPI_PROC_BASE + 66)
#define TSPI_PHONEGETDISPLAY                (TSPI_PROC_BASE + 67)
#define TSPI_PHONEGETEXTENSIONID            (TSPI_PROC_BASE + 68)
#define TSPI_PHONEGETGAIN                   (TSPI_PROC_BASE + 69)
#define TSPI_PHONEGETHOOKSWITCH             (TSPI_PROC_BASE + 70)
#define TSPI_PHONEGETICON                   (TSPI_PROC_BASE + 71)
#define TSPI_PHONEGETID                     (TSPI_PROC_BASE + 72)
#define TSPI_PHONEGETLAMP                   (TSPI_PROC_BASE + 73)
#define TSPI_PHONEGETRING                   (TSPI_PROC_BASE + 74)
#define TSPI_PHONEGETSTATUS                 (TSPI_PROC_BASE + 75)
#define TSPI_PHONEGETVOLUME                 (TSPI_PROC_BASE + 76)
#define TSPI_PHONENEGOTIATEEXTVERSION       (TSPI_PROC_BASE + 77)
#define TSPI_PHONENEGOTIATETSPIVERSION      (TSPI_PROC_BASE + 78)
#define TSPI_PHONEOPEN                      (TSPI_PROC_BASE + 79)
#define TSPI_PHONESELECTEXTVERSION          (TSPI_PROC_BASE + 80)
#define TSPI_PHONESETBUTTONINFO             (TSPI_PROC_BASE + 81)
#define TSPI_PHONESETDATA                   (TSPI_PROC_BASE + 82)
#define TSPI_PHONESETDISPLAY                (TSPI_PROC_BASE + 83)
#define TSPI_PHONESETGAIN                   (TSPI_PROC_BASE + 84)
#define TSPI_PHONESETHOOKSWITCH             (TSPI_PROC_BASE + 85)
#define TSPI_PHONESETLAMP                   (TSPI_PROC_BASE + 86)
#define TSPI_PHONESETRING                   (TSPI_PROC_BASE + 87)
#define TSPI_PHONESETSTATUSMESSAGES         (TSPI_PROC_BASE + 88)
#define TSPI_PHONESETVOLUME                 (TSPI_PROC_BASE + 89)
#define TSPI_PROVIDERCONFIG                 (TSPI_PROC_BASE + 90)
#define TSPI_PROVIDERINIT                   (TSPI_PROC_BASE + 91)
#define TSPI_PROVIDERINSTALL                (TSPI_PROC_BASE + 92)
#define TSPI_PROVIDERREMOVE                 (TSPI_PROC_BASE + 93)
#define TSPI_PROVIDERSHUTDOWN               (TSPI_PROC_BASE + 94)

#define TSPI_PROVIDERENUMDEVICES            (TSPI_PROC_BASE + 95)  // TSPI v1.4
#define TSPI_LINEDROPONCLOSE                (TSPI_PROC_BASE + 96)  // TSPI v1.4
#define TSPI_LINEDROPNOOWNER                (TSPI_PROC_BASE + 97)  // TSPI v1.4
#define TSPI_PROVIDERCREATELINEDEVICE       (TSPI_PROC_BASE + 98)  // TSPI v1.4
#define TSPI_PROVIDERCREATEPHONEDEVICE      (TSPI_PROC_BASE + 99)  // TSPI v1.4
#define TSPI_LINESETCURRENTLOCATION         (TSPI_PROC_BASE + 100) // TSPI v1.4
#define TSPI_LINECONFIGDIALOGEDIT           (TSPI_PROC_BASE + 101) // TSPI v1.4
#define TSPI_LINERELEASEUSERUSERINFO        (TSPI_PROC_BASE + 102) // TSPI v1.4
*)

{$endif}

implementation

const
  TspiDll = 'tspi.dll';

function TSPI_lineAccept; external TspiDll name 'TSPI_lineAccept';
function TSPI_lineAddToConference; external TspiDll name 'TSPI_lineAddToConference';
function TSPI_lineAnswer; external TspiDll name 'TSPI_lineAnswer';
function TSPI_lineBlindTransfer; external TspiDll name 'TSPI_lineBlindTransfer';
function TSPI_lineClose; external TspiDll name 'TSPI_lineClose';
function TSPI_lineCloseCall; external TspiDll name 'TSPI_lineCloseCall';
function TSPI_lineCompleteCall; external TspiDll name 'TSPI_lineCompleteCall';
function TSPI_lineCompleteTransfer; external TspiDll name 'TSPI_lineCompleteTransfer';
function TSPI_lineConditionalMediaDetection; external TspiDll name 'TSPI_lineConditionalMediaDetection';
function TSPI_lineDevSpecific; external TspiDll name 'TSPI_lineDevSpecific';
function TSPI_lineDevSpecificFeature; external TspiDll name 'TSPI_lineDevSpecificFeature';
function TSPI_lineDial; external TspiDll name 'TSPI_lineDial';
function TSPI_lineDrop; external TspiDll name 'TSPI_lineDrop';
function TSPI_lineDropOnClose; external TspiDll name 'TSPI_lineDropOnClose';
function TSPI_lineDropNoOwner; external TspiDll name 'TSPI_lineDropNoOwner';
function TSPI_lineForward; external TspiDll name 'TSPI_lineForward';
function TSPI_lineGatherDigits; external TspiDll name 'TSPI_lineGatherDigits';
function TSPI_lineGenerateDigits; external TspiDll name 'TSPI_lineGenerateDigits';
function TSPI_lineGenerateTone; external TspiDll name 'TSPI_lineGenerateTone';
function TSPI_lineGetAddressCaps; external TspiDll name 'TSPI_lineGetAddressCaps';
function TSPI_lineGetAddressID; external TspiDll name 'TSPI_lineGetAddressID';
function TSPI_lineGetAddressStatus; external TspiDll name 'TSPI_lineGetAddressStatus';
function TSPI_lineGetCallAddressID; external TspiDll name 'TSPI_lineGetCallAddressID';
function TSPI_lineGetCallInfo; external TspiDll name 'TSPI_lineGetCallInfo';
function TSPI_lineGetCallStatus; external TspiDll name 'TSPI_lineGetCallStatus';
function TSPI_lineGetDevCaps; external TspiDll name 'TSPI_lineGetDevCaps';
function TSPI_lineGetDevConfig; external TspiDll name 'TSPI_lineGetDevConfig';
function TSPI_lineGetExtensionID; external TspiDll name 'TSPI_lineGetExtensionID';
function TSPI_lineGetIcon; external TspiDll name 'TSPI_lineGetIcon';
function TSPI_lineGetID; external TspiDll name 'TSPI_lineGetID';
function TSPI_lineGetLineDevStatus; external TspiDll name 'TSPI_lineGetLineDevStatus';
function TSPI_lineGetNumAddressIDs; external TspiDll name 'TSPI_lineGetNumAddressIDs';
function TSPI_lineHold; external TspiDll name 'TSPI_lineHold';
function TSPI_lineMakeCall; external TspiDll name 'TSPI_lineMakeCall';
function TSPI_lineMonitorDigits; external TspiDll name 'TSPI_lineMonitorDigits';
function TSPI_lineMonitorMedia; external TspiDll name 'TSPI_lineMonitorMedia';
function TSPI_lineMonitorTones; external TspiDll name 'TSPI_lineMonitorTones';
function TSPI_lineNegotiateExtVersion; external TspiDll name 'TSPI_lineNegotiateExtVersion';
function TSPI_lineNegotiateTSPIVersion; external TspiDll name 'TSPI_lineNegotiateTSPIVersion';
function TSPI_lineOpen; external TspiDll name 'TSPI_lineOpen';
function TSPI_linePark; external TspiDll name 'TSPI_linePark';
function TSPI_linePickup; external TspiDll name 'TSPI_linePickup';
function TSPI_linePrepareAddToConference; external TspiDll name 'TSPI_linePrepareAddToConference';
function TSPI_lineRedirect; external TspiDll name 'TSPI_lineRedirect';
function TSPI_lineReleaseUserUserInfo; external TspiDll name 'TSPI_lineReleaseUserUserInfo';
function TSPI_lineRemoveFromConference; external TspiDll name 'TSPI_lineRemoveFromConference';
function TSPI_lineSecureCall; external TspiDll name 'TSPI_lineSecureCall';
function TSPI_lineSelectExtVersion; external TspiDll name 'TSPI_lineSelectExtVersion';
function TSPI_lineSendUserUserInfo; external TspiDll name 'TSPI_lineSendUserUserInfo';
function TSPI_lineSetAppSpecific; external TspiDll name 'TSPI_lineSetAppSpecific';
function TSPI_lineSetCallParams; external TspiDll name 'TSPI_lineSetCallParams';
function TSPI_lineSetCurrentLocation; external TspiDll name 'TSPI_lineSetCurrentLocation';
function TSPI_lineSetDefaultMediaDetection; external TspiDll name 'TSPI_lineSetDefaultMediaDetection';
function TSPI_lineSetDevConfig; external TspiDll name 'TSPI_lineSetDevConfig';
function TSPI_lineSetMediaControl; external TspiDll name 'TSPI_lineSetMediaControl';
function TSPI_lineSetMediaMode; external TspiDll name 'TSPI_lineSetMediaMode';
function TSPI_lineSetStatusMessages; external TspiDll name 'TSPI_lineSetStatusMessages';
function TSPI_lineSetTerminal; external TspiDll name 'TSPI_lineSetTerminal';
function TSPI_lineSetupConference; external TspiDll name 'TSPI_lineSetupConference';
function TSPI_lineSetupTransfer; external TspiDll name 'TSPI_lineSetupTransfer';
function TSPI_lineSwapHold; external TspiDll name 'TSPI_lineSwapHold';
function TSPI_lineUncompleteCall; external TspiDll name 'TSPI_lineUncompleteCall';
function TSPI_lineUnhold; external TspiDll name 'TSPI_lineUnhold';

{$IFDEF Tapi_Ver20_ORGREATER}
function TSPI_lineUnpark; external TspiDll name 'TSPI_lineUnpark';
{$ELSE}
function TSPI_lineUnpark; external TspiDll name 'TSPI_lineUnpark';
{$ENDIF}



function TSPI_phoneClose; external TspiDll name 'TSPI_phoneClose';
function TSPI_phoneDevSpecific; external TspiDll name 'TSPI_phoneDevSpecific';
function TSPI_phoneGetButtonInfo; external TspiDll name 'TSPI_phoneGetButtonInfo';
function TSPI_phoneGetData; external TspiDll name 'TSPI_phoneGetData';
function TSPI_phoneGetDevCaps; external TspiDll name 'TSPI_phoneGetDevCaps';
function TSPI_phoneGetDisplay; external TspiDll name 'TSPI_phoneGetDisplay';
function TSPI_phoneGetExtensionID; external TspiDll name 'TSPI_phoneGetExtensionID';
function TSPI_phoneGetGain; external TspiDll name 'TSPI_phoneGetGain';
function TSPI_phoneGetHookSwitch; external TspiDll name 'TSPI_phoneGetHookSwitch';

{$IFDEF Tapi_Ver20_ORGREATER}
function TSPI_phoneGetIcon; external TspiDll name 'TSPI_phoneGetIcon';
{$ELSE}
function TSPI_phoneGetIcon; external TspiDll name 'TSPI_phoneGetIcon';
{$ENDIF}

{$IFDEF Tapi_Ver20_ORGREATER}
function TSPI_phoneGetID; external TspiDll name 'TSPI_phoneGetID';
{$ELSE}
function TSPI_phoneGetID; external TspiDll name 'TSPI_phoneGetID';
{$ENDIF}

function TSPI_phoneGetLamp; external TspiDll name 'TSPI_phoneGetLamp';
function TSPI_phoneGetRing; external TspiDll name 'TSPI_phoneGetRing';
function TSPI_phoneGetStatus; external TspiDll name 'TSPI_phoneGetStatus';
function TSPI_phoneGetVolume; external TspiDll name 'TSPI_phoneGetVolume';
function TSPI_phoneNegotiateExtVersion; external TspiDll name 'TSPI_phoneNegotiateExtVersion';
function TSPI_phoneNegotiateTSPIVersion; external TspiDll name 'TSPI_phoneNegotiateTSPIVersion';
function TSPI_phoneOpen; external TspiDll name 'TSPI_phoneOpen';
function TSPI_phoneSelectExtVersion; external TspiDll name 'TSPI_phoneSelectExtVersion';
function TSPI_phoneSetButtonInfo; external TspiDll name 'TSPI_phoneSetButtonInfo';
function TSPI_phoneSetData; external TspiDll name 'TSPI_phoneSetData';

{$IFDEF Tapi_Ver20_ORGREATER}
function TSPI_phoneSetDisplay; external TspiDll name 'TSPI_phoneSetDisplay';
{$ELSE}
function TSPI_phoneSetDisplay; external TspiDll name 'TSPI_phoneSetDisplay';
{$ENDIF}

function TSPI_phoneSetGain; external TspiDll name 'TSPI_phoneSetGain';
function TSPI_phoneSetHookSwitch; external TspiDll name 'TSPI_phoneSetHookSwitch';
function TSPI_phoneSetLamp; external TspiDll name 'TSPI_phoneSetLamp';
function TSPI_phoneSetRing; external TspiDll name 'TSPI_phoneSetRing';
function TSPI_phoneSetStatusMessages; external TspiDll name 'TSPI_phoneSetStatusMessages';
function TSPI_phoneSetVolume; external TspiDll name 'TSPI_phoneSetVolume';
function TSPI_providerCreateLineDevice; external TspiDll name 'TSPI_providerCreateLineDevice';
function TSPI_providerCreatePhoneDevice; external TspiDll name 'TSPI_providerCreatePhoneDevice';
function TSPI_providerEnumDevices; external TspiDll name 'TSPI_providerEnumDevices';

function TSPI_providerInit; external TspiDll name 'TSPI_providerInit';
function TSPI_providerInstall; external TspiDll name 'TSPI_providerInstall';
function TSPI_providerRemove; external TspiDll name 'TSPI_providerRemove';
function TSPI_providerShutdown; external TspiDll name 'TSPI_providerShutdown';


{$IFDEF Tapi_Ver20_ORGREATER}
function TSPI_lineSetCallData; external TspiDll name 'TSPI_lineSetCallData';
function TSPI_lineSetCallQualityOfService; external TspiDll name 'TSPI_lineSetCallQualityOfService';
function TSPI_lineSetCallTreatment; external TspiDll name 'TSPI_lineSetCallTreatment';
function TSPI_lineSetLineDevStatus; external TspiDll name 'TSPI_lineSetLineDevStatus';
function TSPI_providerFreeDialogInstance; external TspiDll name 'TSPI_providerFreeDialogInstance';
function TSPI_providerGenericDialogData; external TspiDll name 'TSPI_providerGenericDialogData';
function TSPI_providerUIIdentify; external TspiDll name 'TSPI_providerUIIdentify';
{$ENDIF}


{$IFDEF Tapi_Ver20_ORGREATER}
(*
// The following function prototypes pertain
// to a service provider's UI module
*)
function TUISPI_lineConfigDialog; external TspiDll name 'TUISPI_lineConfigDialog';
function TUISPI_lineConfigDialogEdit; external TspiDll name 'TUISPI_lineConfigDialogEdit';
function TUISPI_phoneConfigDialog; external TspiDll name 'TUISPI_phoneConfigDialog';
function TUISPI_providerConfig; external TspiDll name 'TUISPI_providerConfig';
function TUISPI_providerGenericDialog; external TspiDll name 'TUISPI_providerGenericDialog';
function TUISPI_providerGenericDialogData; external TspiDll name 'TUISPI_providerGenericDialogData';
function TUISPI_providerInstall; external TspiDll name 'TUISPI_providerInstall';
function TUISPI_providerRemove; external TspiDll name 'TUISPI_providerRemove';
{$ELSE}
(*
// The following were obsoleted by the above (but are needed to build 1.4 SPs)
*)
function TSPI_lineConfigDialog; external TspiDll name 'TSPI_lineConfigDialog';
function TSPI_lineConfigDialogEdit; external TspiDll name 'TSPI_lineConfigDialogEdit';
function TSPI_phoneConfigDialog; external TspiDll name 'TSPI_phoneConfigDialog';
function TSPI_providerConfig; external TspiDll name 'TSPI_providerConfig';
{$ENDIF}


end.