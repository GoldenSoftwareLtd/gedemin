unit Tapi;

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
    Alexander Staubo <alex@image.no>
    Brad Choate <choate@delphiexchange.com>

  Revision History
  ----------------
    1996-11-25 -AS  Initial translation.
    1997-11-11 -BC  Minor revisions for the JEDI release-- see "JEDI" comments.
    1997-11-12 -BC  Revised unit to match latest tapi.h (2.02)
    1997-11-16 -BC  Reintroduced UNICODE translations.

  Notes
  -----
    - Version define TAPI_CURRENT_VERSION has been converted to a constant
      and conditional code depending on this value changed to the conditional 
      define "Tapi_Ver20". - AS

    - Type aliases for UNICODE omitted. - AS

    - Output pointer arguments such as LPDWORD have not been converted to
      "var" parameters. It would require looking up every TAPI function in 
      the SDK help files and verifying each parameter, since a nil value may 
      be passed for some of these parameters. Anyone interested? - AS

    - The TapiCheck() function does not, for some reason, produce a valid 
      error message. Until this is fixed, access the error codes (LINEERR_, 
      PHONEERR_ etc.) directly. - AS

    - The TapiError() function assumes that TAPI error codes are always 
      negative; I am not sure if this rule is consistently implemented 
      throughout TAPI, although I think is. - AS

    - Constructs and text introduced by translator is prefixed with the
      characters "!!". - AS

    - Original time stamp of tapi.h: 09-aug-96 00:30 - AS

    - Changed $define from Tapi_Ver20 to Tapi_Ver20_ORGREATER and also
      added Tapi_Ver20_GREATER to support logic in 2.1 tapi.h. - BC

    - Note with regard to Delphi 1 support.  There are some IFDEF Win32 
      checks in this file, but currently, this will not compile for Delphi 1.  
      I have another version of this file which has better Delphi 1 
      compatibility, but it will still fail on compile due to the number of 
      symbols (compiler gives "Too many symbols" error).  My guess is the 
      only way around this is to change DLL references from named to index 
      references. - BC

    - UNICODE type aliases reintroduced. - BC

    - For compiling for TAPI 1.4 support, add Tapi_Ver14 to your project's
      conditional defines (Project Info Dialog), make tapi.pas part of your
      project, then build all.

-----------------------------------------------------------------------------}

{!! The following define enables support for TAPI 2.1 }
{$IFNDEF Tapi_Ver14}
{$DEFINE Tapi_Ver20_ORGREATER}
{$DEFINE Tapi_Ver20_GREATER}
{$ENDIF}

(*++ BUILD Version: 0000    // Increment this if a change has global effects

The  Telephony  API  is jointly copyrighted by Intel and Microsoft.  You are
granted  a royalty free worldwide, unlimited license to make copies, and use
the   API/SPI  for  making  applications/drivers  that  interface  with  the
specification provided that this paragraph and the Intel/Microsoft copyright
statement is maintained as is in the text and source code files.

Copyright 1995-96 Microsoft, all rights reserved.
Portions copyright 1992, 1993 Intel/Microsoft, all rights reserved.

Module Name:

    tapi.h

Notes:

    Additions to the Telephony Application Programming Interface (TAPI) since
    version 1.0 are noted by version number (e.g. "TAPI v1.4").

--*)

interface

uses
  Windows, Messages;

(*
//  -- TAPI VERSION INFO -- TAPI VERSION INFO -- TAPI VERSION INFO --
//  -- TAPI VERSION INFO -- TAPI VERSION INFO -- TAPI VERSION INFO --
//  -- TAPI VERSION INFO -- TAPI VERSION INFO -- TAPI VERSION INFO --
//
// To build  a TAPI 1.4 application define Tapi_Ver14 in your project's
// conditional defines.
//
*)

const
{$IFNDEF Tapi_Ver14}
  TAPI_CURRENT_VERSION = $00020002;
{$ELSE}
  TAPI_CURRENT_VERSION = $00010004;
{$ENDIF}

{$ALIGN OFF}       {!! Added; all records implicitly declared as "packed"}

{!! The above line should correspond to:

#pragma pack(1)
// Type definitions of the data types used in tapi
}

type
  {!! C compatibility types, added }
  INT = Longint;
  LONG = Longint;
  LPVOID = Pointer;
  {!!}

(*
// TAPI type definitions
*)

type
  HCALL__ =
    record
      unused: INT;
    end;
  HCALL = HCALL__;
  LPHCALL = ^HCALL;

  HLINE__ =
    record
      unused: INT;
    end;
  HLINE = HLINE__;
  LPHLINE = ^HLINE;

  HPHONE__ =
    record
      unused: INT;
    end;
  HPHONE = HPHONE__;
  LPHPHONE = ^HPHONE;

  HLINEAPP__ =
    record
      unused: INT;
    end;
  HLINEAPP = HLINEAPP__;
  LPHLINEAPP = ^HLINEAPP;

  HPHONEAPP__ =
    record
      unused: INT;
    end;
  HPHONEAPP = HPHONEAPP__;
  LPHPHONEAPP = ^HPHONEAPP;

  LPHICON = ^HICON;

  TLINECALLBACK = procedure(hDevice,
                            dwMessage,
                            dwInstance,
                            dwParam1,
                            dwParam2,
                            dwParam3: DWORD);
                            stdcall;

  TPHONECALLBACK = procedure(hDevice,
                             dwMessage,
                             dwInstance,
                             dwParam1,
                             dwParam2,
                             dwParam3: DWORD);
                             stdcall;


{// Messages for Phones and Lines}

const
  LINE_ADDRESSSTATE                       = 0;
  LINE_CALLINFO                           = 1;
  LINE_CALLSTATE                          = 2;
  LINE_CLOSE                              = 3;
  LINE_DEVSPECIFIC                        = 4;
  LINE_DEVSPECIFICFEATURE                 = 5;
  LINE_GATHERDIGITS                       = 6;
  LINE_GENERATE                           = 7;
  LINE_LINEDEVSTATE                       = 8;
  LINE_MONITORDIGITS                      = 9;
  LINE_MONITORMEDIA                       = 10;
  LINE_MONITORTONE                        = 11;
  LINE_REPLY                              = 12;
  LINE_REQUEST                            = 13;
  PHONE_BUTTON                            = 14;
  PHONE_CLOSE                             = 15;
  PHONE_DEVSPECIFIC                       = 16;
  PHONE_REPLY                             = 17;
  PHONE_STATE                             = 18;
  LINE_CREATE                             = 19;            {// TAPI v1.4}
  PHONE_CREATE                            = 20;            {// TAPI v1.4}

{$IFDEF Tapi_Ver20_ORGREATER}
  LINE_AGENTSPECIFIC                      = 21;            {// TAPI v2.0}
  LINE_AGENTSTATUS                        = 22;            {// TAPI v2.0}
  LINE_APPNEWCALL                         = 23;            {// TAPI v2.0}
  LINE_PROXYREQUEST                       = 24;            {// TAPI v2.0}
  LINE_REMOVE                             = 25;            {// TAPI v2.0}
  PHONE_REMOVE                            = 26;            {// TAPI v2.0}
{$ENDIF}


  INITIALIZE_NEGOTIATION                  = $FFFFFFFF;

  LINEADDRCAPFLAGS_FWDNUMRINGS            = $00000001;
  LINEADDRCAPFLAGS_PICKUPGROUPID          = $00000002;
  LINEADDRCAPFLAGS_SECURE                 = $00000004;
  LINEADDRCAPFLAGS_BLOCKIDDEFAULT         = $00000008;
  LINEADDRCAPFLAGS_BLOCKIDOVERRIDE        = $00000010;
  LINEADDRCAPFLAGS_DIALED                 = $00000020;
  LINEADDRCAPFLAGS_ORIGOFFHOOK            = $00000040;
  LINEADDRCAPFLAGS_DESTOFFHOOK            = $00000080;
  LINEADDRCAPFLAGS_FWDCONSULT             = $00000100;
  LINEADDRCAPFLAGS_SETUPCONFNULL          = $00000200;
  LINEADDRCAPFLAGS_AUTORECONNECT          = $00000400;
  LINEADDRCAPFLAGS_COMPLETIONID           = $00000800;
  LINEADDRCAPFLAGS_TRANSFERHELD           = $00001000;
  LINEADDRCAPFLAGS_TRANSFERMAKE           = $00002000;
  LINEADDRCAPFLAGS_CONFERENCEHELD         = $00004000;
  LINEADDRCAPFLAGS_CONFERENCEMAKE         = $00008000;
  LINEADDRCAPFLAGS_PARTIALDIAL            = $00010000;
  LINEADDRCAPFLAGS_FWDSTATUSVALID         = $00020000;
  LINEADDRCAPFLAGS_FWDINTEXTADDR          = $00040000;
  LINEADDRCAPFLAGS_FWDBUSYNAADDR          = $00080000;
  LINEADDRCAPFLAGS_ACCEPTTOALERT          = $00100000;
  LINEADDRCAPFLAGS_CONFDROP               = $00200000;
  LINEADDRCAPFLAGS_PICKUPCALLWAIT         = $00400000;
{$IFDEF Tapi_Ver20_ORGREATER}
  LINEADDRCAPFLAGS_PREDICTIVEDIALER       = $00800000;     {// TAPI v2.0}
  LINEADDRCAPFLAGS_QUEUE                  = $01000000;     {// TAPI v2.0}
  LINEADDRCAPFLAGS_ROUTEPOINT             = $02000000;     {// TAPI v2.0}
  LINEADDRCAPFLAGS_HOLDMAKESNEW           = $04000000;     {// TAPI v2.0}
  LINEADDRCAPFLAGS_NOINTERNALCALLS        = $08000000;     {// TAPI v2.0}
  LINEADDRCAPFLAGS_NOEXTERNALCALLS        = $10000000;     {// TAPI v2.0}
  LINEADDRCAPFLAGS_SETCALLINGID           = $20000000;     {// TAPI v2.0}
{$ENDIF}

  LINEADDRESSMODE_ADDRESSID               = $00000001;
  LINEADDRESSMODE_DIALABLEADDR            = $00000002;

  LINEADDRESSSHARING_PRIVATE              = $00000001;
  LINEADDRESSSHARING_BRIDGEDEXCL          = $00000002;
  LINEADDRESSSHARING_BRIDGEDNEW           = $00000004;
  LINEADDRESSSHARING_BRIDGEDSHARED        = $00000008;
  LINEADDRESSSHARING_MONITORED            = $00000010;

  LINEADDRESSSTATE_OTHER                  = $00000001;
  LINEADDRESSSTATE_DEVSPECIFIC            = $00000002;
  LINEADDRESSSTATE_INUSEZERO              = $00000004;
  LINEADDRESSSTATE_INUSEONE               = $00000008;
  LINEADDRESSSTATE_INUSEMANY              = $00000010;
  LINEADDRESSSTATE_NUMCALLS               = $00000020;
  LINEADDRESSSTATE_FORWARD                = $00000040;
  LINEADDRESSSTATE_TERMINALS              = $00000080;
  LINEADDRESSSTATE_CAPSCHANGE             = $00000100;     {// TAPI v1.4}

  LINEADDRFEATURE_FORWARD                 = $00000001;
  LINEADDRFEATURE_MAKECALL                = $00000002;
  LINEADDRFEATURE_PICKUP                  = $00000004;
  LINEADDRFEATURE_SETMEDIACONTROL         = $00000008;
  LINEADDRFEATURE_SETTERMINAL             = $00000010;
  LINEADDRFEATURE_SETUPCONF               = $00000020;
  LINEADDRFEATURE_UNCOMPLETECALL          = $00000040;
  LINEADDRFEATURE_UNPARK                  = $00000080;
{$IFDEF Tapi_Ver20_ORGREATER}
  LINEADDRFEATURE_PICKUPHELD              = $00000100;     {// TAPI v2.0}
  LINEADDRFEATURE_PICKUPGROUP             = $00000200;     {// TAPI v2.0}
  LINEADDRFEATURE_PICKUPDIRECT            = $00000400;     {// TAPI v2.0}
  LINEADDRFEATURE_PICKUPWAITING           = $00000800;     {// TAPI v2.0}
  LINEADDRFEATURE_FORWARDFWD              = $00001000;     {// TAPI v2.0}
  LINEADDRFEATURE_FORWARDDND              = $00002000;     {// TAPI v2.0}
{$ENDIF}

{$IFDEF Tapi_Ver20_ORGREATER}
  LINEAGENTFEATURE_SETAGENTGROUP          = $00000001;     {// TAPI v2.0}
  LINEAGENTFEATURE_SETAGENTSTATE          = $00000002;     {// TAPI v2.0}
  LINEAGENTFEATURE_SETAGENTACTIVITY       = $00000004;     {// TAPI v2.0}
  LINEAGENTFEATURE_AGENTSPECIFIC          = $00000008;     {// TAPI v2.0}
  LINEAGENTFEATURE_GETAGENTACTIVITYLIST   = $00000010;     {// TAPI v2.0}
  LINEAGENTFEATURE_GETAGENTGROUP          = $00000020;     {// TAPI v2.0}

  LINEAGENTSTATE_LOGGEDOFF                = $00000001;     {// TAPI v2.0}
  LINEAGENTSTATE_NOTREADY                 = $00000002;     {// TAPI v2.0}
  LINEAGENTSTATE_READY                    = $00000004;     {// TAPI v2.0}
  LINEAGENTSTATE_BUSYACD                  = $00000008;     {// TAPI v2.0}
  LINEAGENTSTATE_BUSYINCOMING             = $00000010;     {// TAPI v2.0}
  LINEAGENTSTATE_BUSYOUTBOUND             = $00000020;     {// TAPI v2.0}
  LINEAGENTSTATE_BUSYOTHER                = $00000040;     {// TAPI v2.0}
  LINEAGENTSTATE_WORKINGAFTERCALL         = $00000080;     {// TAPI v2.0}
  LINEAGENTSTATE_UNKNOWN                  = $00000100;     {// TAPI v2.0}
  LINEAGENTSTATE_UNAVAIL                  = $00000200;     {// TAPI v2.0}

  LINEAGENTSTATUS_GROUP                   = $00000001;     {// TAPI v2.0}
  LINEAGENTSTATUS_STATE                   = $00000002;     {// TAPI v2.0}
  LINEAGENTSTATUS_NEXTSTATE               = $00000004;     {// TAPI v2.0}
  LINEAGENTSTATUS_ACTIVITY                = $00000008;     {// TAPI v2.0}
  LINEAGENTSTATUS_ACTIVITYLIST            = $00000010;     {// TAPI v2.0}
  LINEAGENTSTATUS_GROUPLIST               = $00000020;     {// TAPI v2.0}
  LINEAGENTSTATUS_CAPSCHANGE              = $00000040;     {// TAPI v2.0}
  LINEAGENTSTATUS_VALIDSTATES             = $00000080;     {// TAPI v2.0}
  LINEAGENTSTATUS_VALIDNEXTSTATES         = $00000100;     {// TAPI v2.0}
{$ENDIF}


  LINEANSWERMODE_NONE                     = $00000001;
  LINEANSWERMODE_DROP                     = $00000002;
  LINEANSWERMODE_HOLD                     = $00000004;

  LINEBEARERMODE_VOICE                    = $00000001;
  LINEBEARERMODE_SPEECH                   = $00000002;
  LINEBEARERMODE_MULTIUSE                 = $00000004;
  LINEBEARERMODE_DATA                     = $00000008;
  LINEBEARERMODE_ALTSPEECHDATA            = $00000010;
  LINEBEARERMODE_NONCALLSIGNALING         = $00000020;
  LINEBEARERMODE_PASSTHROUGH              = $00000040;     {// TAPI v1.4}
{$IFDEF Tapi_Ver20_ORGREATER}
  LINEBEARERMODE_RESTRICTEDDATA           = $00000080;     {// TAPI v2.0}
{$ENDIF}

  LINEBUSYMODE_STATION                    = $00000001;
  LINEBUSYMODE_TRUNK                      = $00000002;
  LINEBUSYMODE_UNKNOWN                    = $00000004;
  LINEBUSYMODE_UNAVAIL                    = $00000008;

  LINECALLCOMPLCOND_BUSY                  = $00000001;
  LINECALLCOMPLCOND_NOANSWER              = $00000002;

  LINECALLCOMPLMODE_CAMPON                = $00000001;
  LINECALLCOMPLMODE_CALLBACK              = $00000002;
  LINECALLCOMPLMODE_INTRUDE               = $00000004;
  LINECALLCOMPLMODE_MESSAGE               = $00000008;

  LINECALLFEATURE_ACCEPT                  = $00000001;
  LINECALLFEATURE_ADDTOCONF               = $00000002;
  LINECALLFEATURE_ANSWER                  = $00000004;
  LINECALLFEATURE_BLINDTRANSFER           = $00000008;
  LINECALLFEATURE_COMPLETECALL            = $00000010;
  LINECALLFEATURE_COMPLETETRANSF          = $00000020;
  LINECALLFEATURE_DIAL                    = $00000040;
  LINECALLFEATURE_DROP                    = $00000080;
  LINECALLFEATURE_GATHERDIGITS            = $00000100;
  LINECALLFEATURE_GENERATEDIGITS          = $00000200;
  LINECALLFEATURE_GENERATETONE            = $00000400;
  LINECALLFEATURE_HOLD                    = $00000800;
  LINECALLFEATURE_MONITORDIGITS           = $00001000;
  LINECALLFEATURE_MONITORMEDIA            = $00002000;
  LINECALLFEATURE_MONITORTONES            = $00004000;
  LINECALLFEATURE_PARK                    = $00008000;
  LINECALLFEATURE_PREPAREADDCONF          = $00010000;
  LINECALLFEATURE_REDIRECT                = $00020000;
  LINECALLFEATURE_REMOVEFROMCONF          = $00040000;
  LINECALLFEATURE_SECURECALL              = $00080000;
  LINECALLFEATURE_SENDUSERUSER            = $00100000;
  LINECALLFEATURE_SETCALLPARAMS           = $00200000;
  LINECALLFEATURE_SETMEDIACONTROL         = $00400000;
  LINECALLFEATURE_SETTERMINAL             = $00800000;
  LINECALLFEATURE_SETUPCONF               = $01000000;
  LINECALLFEATURE_SETUPTRANSFER           = $02000000;
  LINECALLFEATURE_SWAPHOLD                = $04000000;
  LINECALLFEATURE_UNHOLD                  = $08000000;
  LINECALLFEATURE_RELEASEUSERUSERINFO     = $10000000;     {// TAPI v1.4}
{$IFDEF Tapi_Ver20_ORGREATER}
  LINECALLFEATURE_SETTREATMENT            = $20000000;     {// TAPI v2.0}
  LINECALLFEATURE_SETQOS                  = $40000000;     {// TAPI v2.0}
  LINECALLFEATURE_SETCALLDATA             = $80000000;     {// TAPI v2.0}
{$ENDIF}

{$IFDEF Tapi_Ver20_ORGREATER}
  LINECALLFEATURE2_NOHOLDCONFERENCE       = $00000001;     {// TAPI v2.0}
  LINECALLFEATURE2_ONESTEPTRANSFER        = $00000002;     {// TAPI v2.0}
  LINECALLFEATURE2_COMPLCAMPON            = $00000004;     {// TAPI v2.0}
  LINECALLFEATURE2_COMPLCALLBACK          = $00000008;     {// TAPI v2.0}
  LINECALLFEATURE2_COMPLINTRUDE           = $00000010;     {// TAPI v2.0}
  LINECALLFEATURE2_COMPLMESSAGE           = $00000020;     {// TAPI v2.0}
  LINECALLFEATURE2_TRANSFERNORM           = $00000040;     {// TAPI v2.0}
  LINECALLFEATURE2_TRANSFERCONF           = $00000080;     {// TAPI v2.0}
  LINECALLFEATURE2_PARKDIRECT             = $00000100;     {// TAPI v2.0}
  LINECALLFEATURE2_PARKNONDIRECT          = $00000200;     {// TAPI v2.0}
{$ENDIF}

  LINECALLINFOSTATE_OTHER                 = $00000001;
  LINECALLINFOSTATE_DEVSPECIFIC           = $00000002;
  LINECALLINFOSTATE_BEARERMODE            = $00000004;
  LINECALLINFOSTATE_RATE                  = $00000008;
  LINECALLINFOSTATE_MEDIAMODE             = $00000010;
  LINECALLINFOSTATE_APPSPECIFIC           = $00000020;
  LINECALLINFOSTATE_CALLID                = $00000040;
  LINECALLINFOSTATE_RELATEDCALLID         = $00000080;
  LINECALLINFOSTATE_ORIGIN                = $00000100;
  LINECALLINFOSTATE_REASON                = $00000200;
  LINECALLINFOSTATE_COMPLETIONID          = $00000400;
  LINECALLINFOSTATE_NUMOWNERINCR          = $00000800;
  LINECALLINFOSTATE_NUMOWNERDECR          = $00001000;
  LINECALLINFOSTATE_NUMMONITORS           = $00002000;
  LINECALLINFOSTATE_TRUNK                 = $00004000;
  LINECALLINFOSTATE_CALLERID              = $00008000;
  LINECALLINFOSTATE_CALLEDID              = $00010000;
  LINECALLINFOSTATE_CONNECTEDID           = $00020000;
  LINECALLINFOSTATE_REDIRECTIONID         = $00040000;
  LINECALLINFOSTATE_REDIRECTINGID         = $00080000;
  LINECALLINFOSTATE_DISPLAY               = $00100000;
  LINECALLINFOSTATE_USERUSERINFO          = $00200000;
  LINECALLINFOSTATE_HIGHLEVELCOMP         = $00400000;
  LINECALLINFOSTATE_LOWLEVELCOMP          = $00800000;
  LINECALLINFOSTATE_CHARGINGINFO          = $01000000;
  LINECALLINFOSTATE_TERMINAL              = $02000000;
  LINECALLINFOSTATE_DIALPARAMS            = $04000000;
  LINECALLINFOSTATE_MONITORMODES          = $08000000;
{$IFDEF Tapi_Ver20_ORGREATER}
  LINECALLINFOSTATE_TREATMENT             = $10000000;     {// TAPI v2.0}
  LINECALLINFOSTATE_QOS                   = $20000000;     {// TAPI v2.0}
  LINECALLINFOSTATE_CALLDATA              = $40000000;     {// TAPI v2.0}
{$ENDIF}

  LINECALLORIGIN_OUTBOUND                 = $00000001;
  LINECALLORIGIN_INTERNAL                 = $00000002;
  LINECALLORIGIN_EXTERNAL                 = $00000004;
  LINECALLORIGIN_UNKNOWN                  = $00000010;
  LINECALLORIGIN_UNAVAIL                  = $00000020;
  LINECALLORIGIN_CONFERENCE               = $00000040;
  LINECALLORIGIN_INBOUND                  = $00000080;     {// TAPI v1.4}

  LINECALLPARAMFLAGS_SECURE               = $00000001;
  LINECALLPARAMFLAGS_IDLE                 = $00000002;
  LINECALLPARAMFLAGS_BLOCKID              = $00000004;
  LINECALLPARAMFLAGS_ORIGOFFHOOK          = $00000008;
  LINECALLPARAMFLAGS_DESTOFFHOOK          = $00000010;
{$IFDEF Tapi_Ver20_ORGREATER}
  LINECALLPARAMFLAGS_NOHOLDCONFERENCE     = $00000020;     {// TAPI v2.0}
  LINECALLPARAMFLAGS_PREDICTIVEDIAL       = $00000040;     {// TAPI v2.0}
  LINECALLPARAMFLAGS_ONESTEPTRANSFER      = $00000080;     {// TAPI v2.0}
{$ENDIF}

  LINECALLPARTYID_BLOCKED                 = $00000001;
  LINECALLPARTYID_OUTOFAREA               = $00000002;
  LINECALLPARTYID_NAME                    = $00000004;
  LINECALLPARTYID_ADDRESS                 = $00000008;
  LINECALLPARTYID_PARTIAL                 = $00000010;
  LINECALLPARTYID_UNKNOWN                 = $00000020;
  LINECALLPARTYID_UNAVAIL                 = $00000040;

  LINECALLPRIVILEGE_NONE                  = $00000001;
  LINECALLPRIVILEGE_MONITOR               = $00000002;
  LINECALLPRIVILEGE_OWNER                 = $00000004;

  LINECALLREASON_DIRECT                   = $00000001;
  LINECALLREASON_FWDBUSY                  = $00000002;
  LINECALLREASON_FWDNOANSWER              = $00000004;
  LINECALLREASON_FWDUNCOND                = $00000008;
  LINECALLREASON_PICKUP                   = $00000010;
  LINECALLREASON_UNPARK                   = $00000020;
  LINECALLREASON_REDIRECT                 = $00000040;
  LINECALLREASON_CALLCOMPLETION           = $00000080;
  LINECALLREASON_TRANSFER                 = $00000100;
  LINECALLREASON_REMINDER                 = $00000200;
  LINECALLREASON_UNKNOWN                  = $00000400;
  LINECALLREASON_UNAVAIL                  = $00000800;
  LINECALLREASON_INTRUDE                  = $00001000;     {// TAPI v1.4}
  LINECALLREASON_PARKED                   = $00002000;     {// TAPI v1.4}
{$IFDEF Tapi_Ver20_ORGREATER}
  LINECALLREASON_CAMPEDON                 = $00004000;     {// TAPI v2.0}
  LINECALLREASON_ROUTEREQUEST             = $00008000;     {// TAPI v2.0}
{$ENDIF}

  LINECALLSELECT_LINE                     = $00000001;
  LINECALLSELECT_ADDRESS                  = $00000002;
  LINECALLSELECT_CALL                     = $00000004;
{$IFDEF Tapi_Ver20_GREATER}
  LINECALLSELECT_DEVICEID                 = $00000008;
{$ENDIF}

  LINECALLSTATE_IDLE                      = $00000001;
  LINECALLSTATE_OFFERING                  = $00000002;
  LINECALLSTATE_ACCEPTED                  = $00000004;
  LINECALLSTATE_DIALTONE                  = $00000008;
  LINECALLSTATE_DIALING                   = $00000010;
  LINECALLSTATE_RINGBACK                  = $00000020;
  LINECALLSTATE_BUSY                      = $00000040;
  LINECALLSTATE_SPECIALINFO               = $00000080;
  LINECALLSTATE_CONNECTED                 = $00000100;
  LINECALLSTATE_PROCEEDING                = $00000200;
  LINECALLSTATE_ONHOLD                    = $00000400;
  LINECALLSTATE_CONFERENCED               = $00000800;
  LINECALLSTATE_ONHOLDPENDCONF            = $00001000;
  LINECALLSTATE_ONHOLDPENDTRANSFER        = $00002000;
  LINECALLSTATE_DISCONNECTED              = $00004000;
  LINECALLSTATE_UNKNOWN                   = $00008000;

{$IFDEF Tapi_Ver20_ORGREATER}
  LINECALLTREATMENT_SILENCE               = $00000001;     {// TAPI v2.0}
  LINECALLTREATMENT_RINGBACK              = $00000002;     {// TAPI v2.0}
  LINECALLTREATMENT_BUSY                  = $00000003;     {// TAPI v2.0}
  LINECALLTREATMENT_MUSIC                 = $00000004;     {// TAPI v2.0}
{$ENDIF}

  LINECARDOPTION_PREDEFINED               = $00000001;     {// TAPI v1.4}
  LINECARDOPTION_HIDDEN                   = $00000002;     {// TAPI v1.4}

  LINECONNECTEDMODE_ACTIVE                = $00000001;     {// TAPI v1.4}
  LINECONNECTEDMODE_INACTIVE              = $00000002;     {// TAPI v1.4}
{$IFDEF Tapi_Ver20_ORGREATER}
  LINECONNECTEDMODE_ACTIVEHELD            = $00000004;     {// TAPI v2.0}
  LINECONNECTEDMODE_INACTIVEHELD          = $00000008;     {// TAPI v2.0}
  LINECONNECTEDMODE_CONFIRMED             = $00000010;     {// TAPI v2.0}
{$ENDIF}

  LINEDEVCAPFLAGS_CROSSADDRCONF           = $00000001;
  LINEDEVCAPFLAGS_HIGHLEVCOMP             = $00000002;
  LINEDEVCAPFLAGS_LOWLEVCOMP              = $00000004;
  LINEDEVCAPFLAGS_MEDIACONTROL            = $00000008;
  LINEDEVCAPFLAGS_MULTIPLEADDR            = $00000010;
  LINEDEVCAPFLAGS_CLOSEDROP               = $00000020;
  LINEDEVCAPFLAGS_DIALBILLING             = $00000040;
  LINEDEVCAPFLAGS_DIALQUIET               = $00000080;
  LINEDEVCAPFLAGS_DIALDIALTONE            = $00000100;

  LINEDEVSTATE_OTHER                      = $00000001;
  LINEDEVSTATE_RINGING                    = $00000002;
  LINEDEVSTATE_CONNECTED                  = $00000004;
  LINEDEVSTATE_DISCONNECTED               = $00000008;
  LINEDEVSTATE_MSGWAITON                  = $00000010;
  LINEDEVSTATE_MSGWAITOFF                 = $00000020;
  LINEDEVSTATE_INSERVICE                  = $00000040;
  LINEDEVSTATE_OUTOFSERVICE               = $00000080;
  LINEDEVSTATE_MAINTENANCE                = $00000100;
  LINEDEVSTATE_OPEN                       = $00000200;
  LINEDEVSTATE_CLOSE                      = $00000400;
  LINEDEVSTATE_NUMCALLS                   = $00000800;
  LINEDEVSTATE_NUMCOMPLETIONS             = $00001000;
  LINEDEVSTATE_TERMINALS                  = $00002000;
  LINEDEVSTATE_ROAMMODE                   = $00004000;
  LINEDEVSTATE_BATTERY                    = $00008000;
  LINEDEVSTATE_SIGNAL                     = $00010000;
  LINEDEVSTATE_DEVSPECIFIC                = $00020000;
  LINEDEVSTATE_REINIT                     = $00040000;
  LINEDEVSTATE_LOCK                       = $00080000;
  LINEDEVSTATE_CAPSCHANGE                 = $00100000;     {// TAPI v1.4}
  LINEDEVSTATE_CONFIGCHANGE               = $00200000;     {// TAPI v1.4}
  LINEDEVSTATE_TRANSLATECHANGE            = $00400000;     {// TAPI v1.4}
  LINEDEVSTATE_COMPLCANCEL                = $00800000;     {// TAPI v1.4}
  LINEDEVSTATE_REMOVED                    = $01000000;     {// TAPI v1.4}

  LINEDEVSTATUSFLAGS_CONNECTED            = $00000001;
  LINEDEVSTATUSFLAGS_MSGWAIT              = $00000002;
  LINEDEVSTATUSFLAGS_INSERVICE            = $00000004;
  LINEDEVSTATUSFLAGS_LOCKED               = $00000008;

  LINEDIALTONEMODE_NORMAL                 = $00000001;
  LINEDIALTONEMODE_SPECIAL                = $00000002;
  LINEDIALTONEMODE_INTERNAL               = $00000004;
  LINEDIALTONEMODE_EXTERNAL               = $00000008;
  LINEDIALTONEMODE_UNKNOWN                = $00000010;
  LINEDIALTONEMODE_UNAVAIL                = $00000020;

  LINEDIGITMODE_PULSE                     = $00000001;
  LINEDIGITMODE_DTMF                      = $00000002;
  LINEDIGITMODE_DTMFEND                   = $00000004;

  LINEDISCONNECTMODE_NORMAL               = $00000001;
  LINEDISCONNECTMODE_UNKNOWN              = $00000002;
  LINEDISCONNECTMODE_REJECT               = $00000004;
  LINEDISCONNECTMODE_PICKUP               = $00000008;
  LINEDISCONNECTMODE_FORWARDED            = $00000010;
  LINEDISCONNECTMODE_BUSY                 = $00000020;
  LINEDISCONNECTMODE_NOANSWER             = $00000040;
  LINEDISCONNECTMODE_BADADDRESS           = $00000080;
  LINEDISCONNECTMODE_UNREACHABLE          = $00000100;
  LINEDISCONNECTMODE_CONGESTION           = $00000200;
  LINEDISCONNECTMODE_INCOMPATIBLE         = $00000400;
  LINEDISCONNECTMODE_UNAVAIL              = $00000800;
  LINEDISCONNECTMODE_NODIALTONE           = $00001000;     {// TAPI v1.4}
{$IFDEF Tapi_Ver20_ORGREATER}
  LINEDISCONNECTMODE_NUMBERCHANGED        = $00002000;     {// TAPI v2.0}
  LINEDISCONNECTMODE_OUTOFORDER           = $00004000;     {// TAPI v2.0}
  LINEDISCONNECTMODE_TEMPFAILURE          = $00008000;     {// TAPI v2.0}
  LINEDISCONNECTMODE_QOSUNAVAIL           = $00010000;     {// TAPI v2.0}
  LINEDISCONNECTMODE_BLOCKED              = $00020000;     {// TAPI v2.0}
  LINEDISCONNECTMODE_DONOTDISTURB         = $00040000;     {// TAPI v2.0}
  LINEDISCONNECTMODE_CANCELLED            = $00080000;     {// TAPI v2.0}
{$ENDIF}

  LINEERR_ALLOCATED                       = $80000001;
  LINEERR_BADDEVICEID                     = $80000002;
  LINEERR_BEARERMODEUNAVAIL               = $80000003;
  LINEERR_CALLUNAVAIL                     = $80000005;
  LINEERR_COMPLETIONOVERRUN               = $80000006;
  LINEERR_CONFERENCEFULL                  = $80000007;
  LINEERR_DIALBILLING                     = $80000008;
  LINEERR_DIALDIALTONE                    = $80000009;
  LINEERR_DIALPROMPT                      = $8000000A;
  LINEERR_DIALQUIET                       = $8000000B;
  LINEERR_INCOMPATIBLEAPIVERSION          = $8000000C;
  LINEERR_INCOMPATIBLEEXTVERSION          = $8000000D;
  LINEERR_INIFILECORRUPT                  = $8000000E;
  LINEERR_INUSE                           = $8000000F;
  LINEERR_INVALADDRESS                    = $80000010;
  LINEERR_INVALADDRESSID                  = $80000011;
  LINEERR_INVALADDRESSMODE                = $80000012;
  LINEERR_INVALADDRESSSTATE               = $80000013;
  LINEERR_INVALAPPHANDLE                  = $80000014;
  LINEERR_INVALAPPNAME                    = $80000015;
  LINEERR_INVALBEARERMODE                 = $80000016;
  LINEERR_INVALCALLCOMPLMODE              = $80000017;
  LINEERR_INVALCALLHANDLE                 = $80000018;
  LINEERR_INVALCALLPARAMS                 = $80000019;
  LINEERR_INVALCALLPRIVILEGE              = $8000001A;
  LINEERR_INVALCALLSELECT                 = $8000001B;
  LINEERR_INVALCALLSTATE                  = $8000001C;
  LINEERR_INVALCALLSTATELIST              = $8000001D;
  LINEERR_INVALCARD                       = $8000001E;
  LINEERR_INVALCOMPLETIONID               = $8000001F;
  LINEERR_INVALCONFCALLHANDLE             = $80000020;
  LINEERR_INVALCONSULTCALLHANDLE          = $80000021;
  LINEERR_INVALCOUNTRYCODE                = $80000022;
  LINEERR_INVALDEVICECLASS                = $80000023;
  LINEERR_INVALDEVICEHANDLE               = $80000024;
  LINEERR_INVALDIALPARAMS                 = $80000025;
  LINEERR_INVALDIGITLIST                  = $80000026;
  LINEERR_INVALDIGITMODE                  = $80000027;
  LINEERR_INVALDIGITS                     = $80000028;
  LINEERR_INVALEXTVERSION                 = $80000029;
  LINEERR_INVALGROUPID                    = $8000002A;
  LINEERR_INVALLINEHANDLE                 = $8000002B;
  LINEERR_INVALLINESTATE                  = $8000002C;
  LINEERR_INVALLOCATION                   = $8000002D;
  LINEERR_INVALMEDIALIST                  = $8000002E;
  LINEERR_INVALMEDIAMODE                  = $8000002F;
  LINEERR_INVALMESSAGEID                  = $80000030;
  LINEERR_INVALPARAM                      = $80000032;
  LINEERR_INVALPARKID                     = $80000033;
  LINEERR_INVALPARKMODE                   = $80000034;
  LINEERR_INVALPOINTER                    = $80000035;
  LINEERR_INVALPRIVSELECT                 = $80000036;
  LINEERR_INVALRATE                       = $80000037;
  LINEERR_INVALREQUESTMODE                = $80000038;
  LINEERR_INVALTERMINALID                 = $80000039;
  LINEERR_INVALTERMINALMODE               = $8000003A;
  LINEERR_INVALTIMEOUT                    = $8000003B;
  LINEERR_INVALTONE                       = $8000003C;
  LINEERR_INVALTONELIST                   = $8000003D;
  LINEERR_INVALTONEMODE                   = $8000003E;
  LINEERR_INVALTRANSFERMODE               = $8000003F;
  LINEERR_LINEMAPPERFAILED                = $80000040;
  LINEERR_NOCONFERENCE                    = $80000041;
  LINEERR_NODEVICE                        = $80000042;
  LINEERR_NODRIVER                        = $80000043;
  LINEERR_NOMEM                           = $80000044;
  LINEERR_NOREQUEST                       = $80000045;
  LINEERR_NOTOWNER                        = $80000046;
  LINEERR_NOTREGISTERED                   = $80000047;
  LINEERR_OPERATIONFAILED                 = $80000048;
  LINEERR_OPERATIONUNAVAIL                = $80000049;
  LINEERR_RATEUNAVAIL                     = $8000004A;
  LINEERR_RESOURCEUNAVAIL                 = $8000004B;
  LINEERR_REQUESTOVERRUN                  = $8000004C;
  LINEERR_STRUCTURETOOSMALL               = $8000004D;
  LINEERR_TARGETNOTFOUND                  = $8000004E;
  LINEERR_TARGETSELF                      = $8000004F;
  LINEERR_UNINITIALIZED                   = $80000050;
  LINEERR_USERUSERINFOTOOBIG              = $80000051;
  LINEERR_REINIT                          = $80000052;
  LINEERR_ADDRESSBLOCKED                  = $80000053;
  LINEERR_BILLINGREJECTED                 = $80000054;
  LINEERR_INVALFEATURE                    = $80000055;
  LINEERR_NOMULTIPLEINSTANCE              = $80000056;
{$IFDEF Tapi_Ver20_ORGREATER}
  LINEERR_INVALAGENTID                    = $80000057;     {// TAPI v2.0}
  LINEERR_INVALAGENTGROUP                 = $80000058;     {// TAPI v2.0}
  LINEERR_INVALPASSWORD                   = $80000059;     {// TAPI v2.0}
  LINEERR_INVALAGENTSTATE                 = $8000005A;     {// TAPI v2.0}
  LINEERR_INVALAGENTACTIVITY              = $8000005B;     {// TAPI v2.0}
  LINEERR_DIALVOICEDETECT                 = $8000005C;     {// TAPI v2.0}
{$ENDIF}

  LINEFEATURE_DEVSPECIFIC                 = $00000001;
  LINEFEATURE_DEVSPECIFICFEAT             = $00000002;
  LINEFEATURE_FORWARD                     = $00000004;
  LINEFEATURE_MAKECALL                    = $00000008;
  LINEFEATURE_SETMEDIACONTROL             = $00000010;
  LINEFEATURE_SETTERMINAL                 = $00000020;
{$IFDEF Tapi_Ver20_ORGREATER}
  LINEFEATURE_SETDEVSTATUS                = $00000040;     {// TAPI v2.0}
  LINEFEATURE_FORWARDFWD                  = $00000080;     {// TAPI v2.0}
  LINEFEATURE_FORWARDDND                  = $00000100;     {// TAPI v2.0}
{$ENDIF}

  LINEFORWARDMODE_UNCOND                  = $00000001;
  LINEFORWARDMODE_UNCONDINTERNAL          = $00000002;
  LINEFORWARDMODE_UNCONDEXTERNAL          = $00000004;
  LINEFORWARDMODE_UNCONDSPECIFIC          = $00000008;
  LINEFORWARDMODE_BUSY                    = $00000010;
  LINEFORWARDMODE_BUSYINTERNAL            = $00000020;
  LINEFORWARDMODE_BUSYEXTERNAL            = $00000040;
  LINEFORWARDMODE_BUSYSPECIFIC            = $00000080;
  LINEFORWARDMODE_NOANSW                  = $00000100;
  LINEFORWARDMODE_NOANSWINTERNAL          = $00000200;
  LINEFORWARDMODE_NOANSWEXTERNAL          = $00000400;
  LINEFORWARDMODE_NOANSWSPECIFIC          = $00000800;
  LINEFORWARDMODE_BUSYNA                  = $00001000;
  LINEFORWARDMODE_BUSYNAINTERNAL          = $00002000;
  LINEFORWARDMODE_BUSYNAEXTERNAL          = $00004000;
  LINEFORWARDMODE_BUSYNASPECIFIC          = $00008000;
  LINEFORWARDMODE_UNKNOWN                 = $00010000;     {// TAPI v1.4}
  LINEFORWARDMODE_UNAVAIL                 = $00020000;     {// TAPI v1.4}

  LINEGATHERTERM_BUFFERFULL               = $00000001;
  LINEGATHERTERM_TERMDIGIT                = $00000002;
  LINEGATHERTERM_FIRSTTIMEOUT             = $00000004;
  LINEGATHERTERM_INTERTIMEOUT             = $00000008;
  LINEGATHERTERM_CANCEL                   = $00000010;

  LINEGENERATETERM_DONE                   = $00000001;
  LINEGENERATETERM_CANCEL                 = $00000002;

{$IFDEF Tapi_Ver20_ORGREATER}
(*
// These constants are mutually exclusive - there's no way to specify more
// than one at a time (and it doesn't make sense, either) so they're
// ordinal rather than bits.
*)
  LINEINITIALIZEEXOPTION_USEHIDDENWINDOW      = $00000001; {// TAPI v2.0}
  LINEINITIALIZEEXOPTION_USEEVENT             = $00000002; {// TAPI v2.0}
  LINEINITIALIZEEXOPTION_USECOMPLETIONPORT    = $00000003; {// TAPI v2.0}
{$ENDIF}

  LINELOCATIONOPTION_PULSEDIAL            = $00000001;     {// TAPI v1.4}

  LINEMAPPER                              = $FFFFFFFF;

  LINEMEDIACONTROL_NONE                   = $00000001;
  LINEMEDIACONTROL_START                  = $00000002;
  LINEMEDIACONTROL_RESET                  = $00000004;
  LINEMEDIACONTROL_PAUSE                  = $00000008;
  LINEMEDIACONTROL_RESUME                 = $00000010;
  LINEMEDIACONTROL_RATEUP                 = $00000020;
  LINEMEDIACONTROL_RATEDOWN               = $00000040;
  LINEMEDIACONTROL_RATENORMAL             = $00000080;
  LINEMEDIACONTROL_VOLUMEUP               = $00000100;
  LINEMEDIACONTROL_VOLUMEDOWN             = $00000200;
  LINEMEDIACONTROL_VOLUMENORMAL           = $00000400;

  LINEMEDIAMODE_UNKNOWN                   = $00000002;
  LINEMEDIAMODE_INTERACTIVEVOICE          = $00000004;
  LINEMEDIAMODE_AUTOMATEDVOICE            = $00000008;
  LINEMEDIAMODE_DATAMODEM                 = $00000010;
  LINEMEDIAMODE_G3FAX                     = $00000020;
  LINEMEDIAMODE_TDD                       = $00000040;
  LINEMEDIAMODE_G4FAX                     = $00000080;
  LINEMEDIAMODE_DIGITALDATA               = $00000100;
  LINEMEDIAMODE_TELETEX                   = $00000200;
  LINEMEDIAMODE_VIDEOTEX                  = $00000400;
  LINEMEDIAMODE_TELEX                     = $00000800;
  LINEMEDIAMODE_MIXED                     = $00001000;
  LINEMEDIAMODE_ADSI                      = $00002000;
  LINEMEDIAMODE_VOICEVIEW                 = $00004000;     {// TAPI v1.4}
{$IFDEF Tapi_Ver20_ORGREATER}
  LINEMEDIAMODE_VIDEO                     = $00008000;     {// TAPI v2.1}
{$ENDIF}
  LAST_LINEMEDIAMODE                      = $00008000;

  LINEOFFERINGMODE_ACTIVE                 = $00000001;     {// TAPI v1.4}
  LINEOFFERINGMODE_INACTIVE               = $00000002;     {// TAPI v1.4}

{$IFDEF Tapi_Ver20_ORGREATER}
  LINEOPENOPTION_SINGLEADDRESS            = $80000000;     {// TAPI v2.0}
  LINEOPENOPTION_PROXY                    = $40000000;     {// TAPI v2.0}
{$ENDIF}

  LINEPARKMODE_DIRECTED                   = $00000001;
  LINEPARKMODE_NONDIRECTED                = $00000002;

{$IFDEF Tapi_Ver20_ORGREATER}
  LINEPROXYREQUEST_SETAGENTGROUP          = $00000001;     {// TAPI v2.0}
  LINEPROXYREQUEST_SETAGENTSTATE          = $00000002;     {// TAPI v2.0}
  LINEPROXYREQUEST_SETAGENTACTIVITY       = $00000003;     {// TAPI v2.0}
  LINEPROXYREQUEST_GETAGENTCAPS           = $00000004;     {// TAPI v2.0}
  LINEPROXYREQUEST_GETAGENTSTATUS         = $00000005;     {// TAPI v2.0}
  LINEPROXYREQUEST_AGENTSPECIFIC          = $00000006;     {// TAPI v2.0}
  LINEPROXYREQUEST_GETAGENTACTIVITYLIST   = $00000007;     {// TAPI v2.0}
  LINEPROXYREQUEST_GETAGENTGROUPLIST      = $00000008;     {// TAPI v2.0}
{$ENDIF}

  LINEREMOVEFROMCONF_NONE                 = $00000001;
  LINEREMOVEFROMCONF_LAST                 = $00000002;
  LINEREMOVEFROMCONF_ANY                  = $00000003;

  LINEREQUESTMODE_MAKECALL                = $00000001;
  LINEREQUESTMODE_MEDIACALL               = $00000002;
  LINEREQUESTMODE_DROP                    = $00000004;
  LAST_LINEREQUESTMODE                    = LINEREQUESTMODE_MEDIACALL;

  LINEROAMMODE_UNKNOWN                    = $00000001;
  LINEROAMMODE_UNAVAIL                    = $00000002;
  LINEROAMMODE_HOME                       = $00000004;
  LINEROAMMODE_ROAMA                      = $00000008;
  LINEROAMMODE_ROAMB                      = $00000010;

  LINESPECIALINFO_NOCIRCUIT               = $00000001;
  LINESPECIALINFO_CUSTIRREG               = $00000002;
  LINESPECIALINFO_REORDER                 = $00000004;
  LINESPECIALINFO_UNKNOWN                 = $00000008;
  LINESPECIALINFO_UNAVAIL                 = $00000010;

  LINETERMDEV_PHONE                       = $00000001;
  LINETERMDEV_HEADSET                     = $00000002;
  LINETERMDEV_SPEAKER                     = $00000004;

  LINETERMMODE_BUTTONS                    = $00000001;
  LINETERMMODE_LAMPS                      = $00000002;
  LINETERMMODE_DISPLAY                    = $00000004;
  LINETERMMODE_RINGER                     = $00000008;
  LINETERMMODE_HOOKSWITCH                 = $00000010;
  LINETERMMODE_MEDIATOLINE                = $00000020;
  LINETERMMODE_MEDIAFROMLINE              = $00000040;
  LINETERMMODE_MEDIABIDIRECT              = $00000080;

  LINETERMSHARING_PRIVATE                 = $00000001;
  LINETERMSHARING_SHAREDEXCL              = $00000002;
  LINETERMSHARING_SHAREDCONF              = $00000004;

  LINETOLLLISTOPTION_ADD                  = $00000001;
  LINETOLLLISTOPTION_REMOVE               = $00000002;

  LINETONEMODE_CUSTOM                     = $00000001;
  LINETONEMODE_RINGBACK                   = $00000002;
  LINETONEMODE_BUSY                       = $00000004;
  LINETONEMODE_BEEP                       = $00000008;
  LINETONEMODE_BILLING                    = $00000010;

  LINETRANSFERMODE_TRANSFER               = $00000001;
  LINETRANSFERMODE_CONFERENCE             = $00000002;

  LINETRANSLATEOPTION_CARDOVERRIDE        = $00000001;
  LINETRANSLATEOPTION_CANCELCALLWAITING   = $00000002;     {// TAPI v1.4}
  LINETRANSLATEOPTION_FORCELOCAL          = $00000004;     {// TAPI v1.4}
  LINETRANSLATEOPTION_FORCELD             = $00000008;     {// TAPI v1.4}

  LINETRANSLATERESULT_CANONICAL           = $00000001;
  LINETRANSLATERESULT_INTERNATIONAL       = $00000002;
  LINETRANSLATERESULT_LONGDISTANCE        = $00000004;
  LINETRANSLATERESULT_LOCAL               = $00000008;
  LINETRANSLATERESULT_INTOLLLIST          = $00000010;
  LINETRANSLATERESULT_NOTINTOLLLIST       = $00000020;
  LINETRANSLATERESULT_DIALBILLING         = $00000040;
  LINETRANSLATERESULT_DIALQUIET           = $00000080;
  LINETRANSLATERESULT_DIALDIALTONE        = $00000100;
  LINETRANSLATERESULT_DIALPROMPT          = $00000200;
{$IFDEF Tapi_Ver20_ORGREATER}
  LINETRANSLATERESULT_VOICEDETECT         = $00000400;     {// TAPI v2.0}
{$ENDIF}

  PHONEBUTTONFUNCTION_UNKNOWN             = $00000000;
  PHONEBUTTONFUNCTION_CONFERENCE          = $00000001;
  PHONEBUTTONFUNCTION_TRANSFER            = $00000002;
  PHONEBUTTONFUNCTION_DROP                = $00000003;
  PHONEBUTTONFUNCTION_HOLD                = $00000004;
  PHONEBUTTONFUNCTION_RECALL              = $00000005;
  PHONEBUTTONFUNCTION_DISCONNECT          = $00000006;
  PHONEBUTTONFUNCTION_CONNECT             = $00000007;
  PHONEBUTTONFUNCTION_MSGWAITON           = $00000008;
  PHONEBUTTONFUNCTION_MSGWAITOFF          = $00000009;
  PHONEBUTTONFUNCTION_SELECTRING          = $0000000A;
  PHONEBUTTONFUNCTION_ABBREVDIAL          = $0000000B;
  PHONEBUTTONFUNCTION_FORWARD             = $0000000C;
  PHONEBUTTONFUNCTION_PICKUP              = $0000000D;
  PHONEBUTTONFUNCTION_RINGAGAIN           = $0000000E;
  PHONEBUTTONFUNCTION_PARK                = $0000000F;
  PHONEBUTTONFUNCTION_REJECT              = $00000010;
  PHONEBUTTONFUNCTION_REDIRECT            = $00000011;
  PHONEBUTTONFUNCTION_MUTE                = $00000012;
  PHONEBUTTONFUNCTION_VOLUMEUP            = $00000013;
  PHONEBUTTONFUNCTION_VOLUMEDOWN          = $00000014;
  PHONEBUTTONFUNCTION_SPEAKERON           = $00000015;
  PHONEBUTTONFUNCTION_SPEAKEROFF          = $00000016;
  PHONEBUTTONFUNCTION_FLASH               = $00000017;
  PHONEBUTTONFUNCTION_DATAON              = $00000018;
  PHONEBUTTONFUNCTION_DATAOFF             = $00000019;
  PHONEBUTTONFUNCTION_DONOTDISTURB        = $0000001A;
  PHONEBUTTONFUNCTION_INTERCOM            = $0000001B;
  PHONEBUTTONFUNCTION_BRIDGEDAPP          = $0000001C;
  PHONEBUTTONFUNCTION_BUSY                = $0000001D;
  PHONEBUTTONFUNCTION_CALLAPP             = $0000001E;
  PHONEBUTTONFUNCTION_DATETIME            = $0000001F;
  PHONEBUTTONFUNCTION_DIRECTORY           = $00000020;
  PHONEBUTTONFUNCTION_COVER               = $00000021;
  PHONEBUTTONFUNCTION_CALLID              = $00000022;
  PHONEBUTTONFUNCTION_LASTNUM             = $00000023;
  PHONEBUTTONFUNCTION_NIGHTSRV            = $00000024;
  PHONEBUTTONFUNCTION_SENDCALLS           = $00000025;
  PHONEBUTTONFUNCTION_MSGINDICATOR        = $00000026;
  PHONEBUTTONFUNCTION_REPDIAL             = $00000027;
  PHONEBUTTONFUNCTION_SETREPDIAL          = $00000028;
  PHONEBUTTONFUNCTION_SYSTEMSPEED         = $00000029;
  PHONEBUTTONFUNCTION_STATIONSPEED        = $0000002A;
  PHONEBUTTONFUNCTION_CAMPON              = $0000002B;
  PHONEBUTTONFUNCTION_SAVEREPEAT          = $0000002C;
  PHONEBUTTONFUNCTION_QUEUECALL           = $0000002D;
  PHONEBUTTONFUNCTION_NONE                = $0000002E;

  PHONEBUTTONMODE_DUMMY                   = $00000001;
  PHONEBUTTONMODE_CALL                    = $00000002;
  PHONEBUTTONMODE_FEATURE                 = $00000004;
  PHONEBUTTONMODE_KEYPAD                  = $00000008;
  PHONEBUTTONMODE_LOCAL                   = $00000010;
  PHONEBUTTONMODE_DISPLAY                 = $00000020;

  PHONEBUTTONSTATE_UP                     = $00000001;
  PHONEBUTTONSTATE_DOWN                   = $00000002;
  PHONEBUTTONSTATE_UNKNOWN                = $00000004;     {// TAPI v1.4}
  PHONEBUTTONSTATE_UNAVAIL                = $00000008;     {// TAPI v1.4}

  PHONEERR_ALLOCATED                      = $90000001;
  PHONEERR_BADDEVICEID                    = $90000002;
  PHONEERR_INCOMPATIBLEAPIVERSION         = $90000003;
  PHONEERR_INCOMPATIBLEEXTVERSION         = $90000004;
  PHONEERR_INIFILECORRUPT                 = $90000005;
  PHONEERR_INUSE                          = $90000006;
  PHONEERR_INVALAPPHANDLE                 = $90000007;
  PHONEERR_INVALAPPNAME                   = $90000008;
  PHONEERR_INVALBUTTONLAMPID              = $90000009;
  PHONEERR_INVALBUTTONMODE                = $9000000A;
  PHONEERR_INVALBUTTONSTATE               = $9000000B;
  PHONEERR_INVALDATAID                    = $9000000C;
  PHONEERR_INVALDEVICECLASS               = $9000000D;
  PHONEERR_INVALEXTVERSION                = $9000000E;
  PHONEERR_INVALHOOKSWITCHDEV             = $9000000F;
  PHONEERR_INVALHOOKSWITCHMODE            = $90000010;
  PHONEERR_INVALLAMPMODE                  = $90000011;
  PHONEERR_INVALPARAM                     = $90000012;
  PHONEERR_INVALPHONEHANDLE               = $90000013;
  PHONEERR_INVALPHONESTATE                = $90000014;
  PHONEERR_INVALPOINTER                   = $90000015;
  PHONEERR_INVALPRIVILEGE                 = $90000016;
  PHONEERR_INVALRINGMODE                  = $90000017;
  PHONEERR_NODEVICE                       = $90000018;
  PHONEERR_NODRIVER                       = $90000019;
  PHONEERR_NOMEM                          = $9000001A;
  PHONEERR_NOTOWNER                       = $9000001B;
  PHONEERR_OPERATIONFAILED                = $9000001C;
  PHONEERR_OPERATIONUNAVAIL               = $9000001D;
  PHONEERR_RESOURCEUNAVAIL                = $9000001F;
  PHONEERR_REQUESTOVERRUN                 = $90000020;
  PHONEERR_STRUCTURETOOSMALL              = $90000021;
  PHONEERR_UNINITIALIZED                  = $90000022;
  PHONEERR_REINIT                         = $90000023;


{$IFDEF Tapi_Ver20_ORGREATER}
  PHONEFEATURE_GETBUTTONINFO              = $00000001;     {// TAPI v2.0}
  PHONEFEATURE_GETDATA                    = $00000002;     {// TAPI v2.0}
  PHONEFEATURE_GETDISPLAY                 = $00000004;     {// TAPI v2.0}
  PHONEFEATURE_GETGAINHANDSET             = $00000008;     {// TAPI v2.0}
  PHONEFEATURE_GETGAINSPEAKER             = $00000010;     {// TAPI v2.0}
  PHONEFEATURE_GETGAINHEADSET             = $00000020;     {// TAPI v2.0}
  PHONEFEATURE_GETHOOKSWITCHHANDSET       = $00000040;     {// TAPI v2.0}
  PHONEFEATURE_GETHOOKSWITCHSPEAKER       = $00000080;     {// TAPI v2.0}
  PHONEFEATURE_GETHOOKSWITCHHEADSET       = $00000100;     {// TAPI v2.0}
  PHONEFEATURE_GETLAMP                    = $00000200;     {// TAPI v2.0}
  PHONEFEATURE_GETRING                    = $00000400;     {// TAPI v2.0}
  PHONEFEATURE_GETVOLUMEHANDSET           = $00000800;     {// TAPI v2.0}
  PHONEFEATURE_GETVOLUMESPEAKER           = $00001000;     {// TAPI v2.0}
  PHONEFEATURE_GETVOLUMEHEADSET           = $00002000;     {// TAPI v2.0}
  PHONEFEATURE_SETBUTTONINFO              = $00004000;     {// TAPI v2.0}
  PHONEFEATURE_SETDATA                    = $00008000;     {// TAPI v2.0}
  PHONEFEATURE_SETDISPLAY                 = $00010000;     {// TAPI v2.0}
  PHONEFEATURE_SETGAINHANDSET             = $00020000;     {// TAPI v2.0}
  PHONEFEATURE_SETGAINSPEAKER             = $00040000;     {// TAPI v2.0}
  PHONEFEATURE_SETGAINHEADSET             = $00080000;     {// TAPI v2.0}
  PHONEFEATURE_SETHOOKSWITCHHANDSET       = $00100000;     {// TAPI v2.0}
  PHONEFEATURE_SETHOOKSWITCHSPEAKER       = $00200000;     {// TAPI v2.0}
  PHONEFEATURE_SETHOOKSWITCHHEADSET       = $00400000;     {// TAPI v2.0}
  PHONEFEATURE_SETLAMP                    = $00800000;     {// TAPI v2.0}
  PHONEFEATURE_SETRING                    = $01000000;     {// TAPI v2.0}
  PHONEFEATURE_SETVOLUMEHANDSET           = $02000000;     {// TAPI v2.0}
  PHONEFEATURE_SETVOLUMESPEAKER           = $04000000;     {// TAPI v2.0}
  PHONEFEATURE_SETVOLUMEHEADSET           = $08000000;     {// TAPI v2.0}
{$ENDIF}

  PHONEHOOKSWITCHDEV_HANDSET              = $00000001;
  PHONEHOOKSWITCHDEV_SPEAKER              = $00000002;
  PHONEHOOKSWITCHDEV_HEADSET              = $00000004;

  PHONEHOOKSWITCHMODE_ONHOOK              = $00000001;
  PHONEHOOKSWITCHMODE_MIC                 = $00000002;
  PHONEHOOKSWITCHMODE_SPEAKER             = $00000004;
  PHONEHOOKSWITCHMODE_MICSPEAKER          = $00000008;
  PHONEHOOKSWITCHMODE_UNKNOWN             = $00000010;

{$IFDEF Tapi_Ver20_ORGREATER}
  PHONEINITIALIZEEXOPTION_USEHIDDENWINDOW     = $00000001;  {// TAPI v2.0}
  PHONEINITIALIZEEXOPTION_USEEVENT            = $00000002;  {// TAPI v2.0}
  PHONEINITIALIZEEXOPTION_USECOMPLETIONPORT   = $00000003;  {// TAPI v2.0}
{$ENDIF}

  PHONELAMPMODE_DUMMY                     = $00000001;
  PHONELAMPMODE_OFF                       = $00000002;
  PHONELAMPMODE_STEADY                    = $00000004;
  PHONELAMPMODE_WINK                      = $00000008;
  PHONELAMPMODE_FLASH                     = $00000010;
  PHONELAMPMODE_FLUTTER                   = $00000020;
  PHONELAMPMODE_BROKENFLUTTER             = $00000040;
  PHONELAMPMODE_UNKNOWN                   = $00000080;

  PHONEPRIVILEGE_MONITOR                  = $00000001;
  PHONEPRIVILEGE_OWNER                    = $00000002;

  PHONESTATE_OTHER                        = $00000001;
  PHONESTATE_CONNECTED                    = $00000002;
  PHONESTATE_DISCONNECTED                 = $00000004;
  PHONESTATE_OWNER                        = $00000008;
  PHONESTATE_MONITORS                     = $00000010;
  PHONESTATE_DISPLAY                      = $00000020;
  PHONESTATE_LAMP                         = $00000040;
  PHONESTATE_RINGMODE                     = $00000080;
  PHONESTATE_RINGVOLUME                   = $00000100;
  PHONESTATE_HANDSETHOOKSWITCH            = $00000200;
  PHONESTATE_HANDSETVOLUME                = $00000400;
  PHONESTATE_HANDSETGAIN                  = $00000800;
  PHONESTATE_SPEAKERHOOKSWITCH            = $00001000;
  PHONESTATE_SPEAKERVOLUME                = $00002000;
  PHONESTATE_SPEAKERGAIN                  = $00004000;
  PHONESTATE_HEADSETHOOKSWITCH            = $00008000;
  PHONESTATE_HEADSETVOLUME                = $00010000;
  PHONESTATE_HEADSETGAIN                  = $00020000;
  PHONESTATE_SUSPEND                      = $00040000;
  PHONESTATE_RESUME                       = $00080000;
  PHONESTATE_DEVSPECIFIC                  = $00100000;
  PHONESTATE_REINIT                       = $00200000;
  PHONESTATE_CAPSCHANGE                   = $00400000;     {// TAPI v1.4}
  PHONESTATE_REMOVED                      = $00800000;     {// TAPI v1.4}

  PHONESTATUSFLAGS_CONNECTED              = $00000001;
  PHONESTATUSFLAGS_SUSPENDED              = $00000002;

  STRINGFORMAT_ASCII                      = $00000001;
  STRINGFORMAT_DBCS                       = $00000002;
  STRINGFORMAT_UNICODE                    = $00000003;
  STRINGFORMAT_BINARY                     = $00000004;

  TAPI_REPLY                              = WM_USER + 99;

  TAPIERR_CONNECTED                       = 0;
  TAPIERR_DROPPED                         = -1;
  TAPIERR_NOREQUESTRECIPIENT              = -2;
  TAPIERR_REQUESTQUEUEFULL                = -3;
  TAPIERR_INVALDESTADDRESS                = -4;
  TAPIERR_INVALWINDOWHANDLE               = -5;
  TAPIERR_INVALDEVICECLASS                = -6;
  TAPIERR_INVALDEVICEID                   = -7;
  TAPIERR_DEVICECLASSUNAVAIL              = -8;
  TAPIERR_DEVICEIDUNAVAIL                 = -9;
  TAPIERR_DEVICEINUSE                     = -10;
  TAPIERR_DESTBUSY                        = -11;
  TAPIERR_DESTNOANSWER                    = -12;
  TAPIERR_DESTUNAVAIL                     = -13;
  TAPIERR_UNKNOWNWINHANDLE                = -14;
  TAPIERR_UNKNOWNREQUESTID                = -15;
  TAPIERR_REQUESTFAILED                   = -16;
  TAPIERR_REQUESTCANCELLED                = -17;
  TAPIERR_INVALPOINTER                    = -18;


  TAPIMAXDESTADDRESSSIZE                  = 80;
  TAPIMAXAPPNAMESIZE                      = 40;
  TAPIMAXCALLEDPARTYSIZE                  = 40;
  TAPIMAXCOMMENTSIZE                      = 80;
  TAPIMAXDEVICECLASSSIZE                  = 40;
  TAPIMAXDEVICEIDSIZE                     = 40;


type
  LPLINEADDRESSCAPS = ^TLINEADDRESSCAPS;
  PLINEADDRESSCAPS = ^TLINEADDRESSCAPS;
  TLINEADDRESSCAPS =
    record
      dwTotalSize,
      dwNeededSize,
      dwUsedSize,
      dwLineDeviceID,
      dwAddressSize,
      dwAddressOffset,
      dwDevSpecificSize,
      dwDevSpecificOffset,
      dwAddressSharing,
      dwAddressStates,
      dwCallInfoStates,
      dwCallerIDFlags,
      dwCalledIDFlags,
      dwConnectedIDFlags,
      dwRedirectionIDFlags,
      dwRedirectingIDFlags,
      dwCallStates,
      dwDialToneModes,
      dwBusyModes,
      dwSpecialInfo,
      dwDisconnectModes,
      dwMaxNumActiveCalls,
      dwMaxNumOnHoldCalls,
      dwMaxNumOnHoldPendingCalls,
      dwMaxNumConference,
      dwMaxNumTransConf,
      dwAddrCapFlags,
      dwCallFeatures,
      dwRemoveFromConfCaps,
      dwRemoveFromConfState,
      dwTransferModes,
      dwParkModes,
      dwForwardModes,
      dwMaxForwardEntries,
      dwMaxSpecificEntries,
      dwMinFwdNumRings,
      dwMaxFwdNumRings,
      dwMaxCallCompletions,
      dwCallCompletionConds,
      dwCallCompletionModes,
      dwNumCompletionMessages,
      dwCompletionMsgTextEntrySize,
      dwCompletionMsgTextSize,
      dwCompletionMsgTextOffset,

      dwAddressFeatures: DWORD;                            {// TAPI v1.4}

{$IFDEF Tapi_Ver20_ORGREATER}
      dwPredictiveAutoTransferStates,                      {// TAPI v2.0}
      dwNumCallTreatments,                                 {// TAPI v2.0}
      dwCallTreatmentListSize,                             {// TAPI v2.0}
      dwCallTreatmentListOffset,                           {// TAPI v2.0}
      dwDeviceClassesSize,                                 {// TAPI v2.0}
      dwDeviceClassesOffset,                               {// TAPI v2.0}
      dwMaxCallDataSize,                                   {// TAPI v2.0}
      dwCallFeatures2,                                     {// TAPI v2.0}
      dwMaxNoAnswerTimeout,                                {// TAPI v2.0}
      dwConnectedModes,                                    {// TAPI v2.0}
      dwOfferingModes,                                     {// TAPI v2.0}
      dwAvailableMediaModes: DWORD;                        {// TAPI v2.0}
{$ENDIF}
    end;

  LPLINEADDRESSSTATUS = ^TLINEADDRESSSTATUS;
  PLINEADDRESSSTATUS = ^TLINEADDRESSSTATUS;
  TLINEADDRESSSTATUS =
    record
      dwTotalSize,
      dwNeededSize,
      dwUsedSize,
      dwNumInUse,
      dwNumActiveCalls,
      dwNumOnHoldCalls,
      dwNumOnHoldPendCalls,
      dwAddressFeatures,
      dwNumRingsNoAnswer,
      dwForwardNumEntries,
      dwForwardSize,
      dwForwardOffset,
      dwTerminalModesSize,
      dwTerminalModesOffset,
      dwDevSpecificSize,
      dwDevSpecificOffset: DWORD;
    end;

{$IFDEF Tapi_Ver20_ORGREATER}
  LPLINEAGENTACTIVITYENTRY = ^TLINEAGENTACTIVITYENTRY;
  PLINEAGENTACTIVITYENTRY = ^TLINEAGENTACTIVITYENTRY;
  TLINEAGENTACTIVITYENTRY =
    record
      dwID,                                                {// TAPI v2.0}
      dwNameSize,                                          {// TAPI v2.0}
      dwNameOffset: DWORD;                                 {// TAPI v2.0}
    end;

  LPLINEAGENTACTIVITYLIST = ^TLINEAGENTACTIVITYLIST;
  PLINEAGENTACTIVITYLIST = ^TLINEAGENTACTIVITYLIST;
  TLINEAGENTACTIVITYLIST =
    record
      dwTotalSize,                                         {// TAPI v2.0}
      dwNeededSize,                                        {// TAPI v2.0}
      dwUsedSize,                                          {// TAPI v2.0}
      dwNumEntries,                                        {// TAPI v2.0}
      dwListSize,                                          {// TAPI v2.0}
      dwListOffset: DWORD;                                 {// TAPI v2.0}
    end;

  LPLINEAGENTCAPS = ^TLINEAGENTCAPS;
  PLINEAGENTCAPS = ^TLINEAGENTCAPS;
  TLINEAGENTCAPS =
    record
      dwTotalSize,                                         {// TAPI v2.0}
      dwNeededSize,                                        {// TAPI v2.0}
      dwUsedSize,                                          {// TAPI v2.0}
      dwAgentHandlerInfoSize,                              {// TAPI v2.0}
      dwAgentHandlerInfoOffset,                            {// TAPI v2.0}
      dwCapsVersion,                                       {// TAPI v2.0}
      dwFeatures,                                          {// TAPI v2.0}
      dwStates,                                            {// TAPI v2.0}
      dwNextStates,                                        {// TAPI v2.0}
      dwMaxNumGroupEntries,                                {// TAPI v2.0}
      dwAgentStatusMessages,                               {// TAPI v2.0}
      dwNumAgentExtensionIDs,                              {// TAPI v2.0}
      dwAgentExtensionIDListSize,                          {// TAPI v2.0}
      dwAgentExtensionIDListOffset: DWORD;                 {// TAPI v2.0}
    end;

  LPLINEAGENTGROUPENTRY = ^TLINEAGENTGROUPENTRY;
  PLINEAGENTGROUPENTRY = ^TLINEAGENTGROUPENTRY;
  TLINEAGENTGROUPENTRY =
    record
      GroupID :
        record
          dwGroupID1,                                      {// TAPI v2.0}
          dwGroupID2,                                      {// TAPI v2.0}
          dwGroupID3,                                      {// TAPI v2.0}
          dwGroupID4: DWORD;                               {// TAPI v2.0}
        end;
      dwNameSize,                                          {// TAPI v2.0}
      dwNameOffset: DWORD;                                 {// TAPI v2.0}
    end;

  LPLINEAGENTGROUPLIST = ^TLINEAGENTGROUPLIST;
  PLINEAGENTGROUPLIST = ^TLINEAGENTGROUPLIST;
  TLINEAGENTGROUPLIST =
    record
      dwTotalSize,                                         {// TAPI v2.0}
      dwNeededSize,                                        {// TAPI v2.0}
      dwUsedSize,                                          {// TAPI v2.0}
      dwNumEntries,                                        {// TAPI v2.0}
      dwListSize,                                          {// TAPI v2.0}
      dwListOffset: DWORD;                                 {// TAPI v2.0}
    end;

  LPLINEAGENTSTATUS = ^TLINEAGENTSTATUS;
  PLINEAGENTSTATUS = ^TLINEAGENTSTATUS;
  TLINEAGENTSTATUS =
    record
      dwTotalSize,                                         {// TAPI v2.0}
      dwNeededSize,                                        {// TAPI v2.0}
      dwUsedSize,                                          {// TAPI v2.0}
      dwNumEntries,                                        {// TAPI v2.0}
      dwGroupListSize,                                     {// TAPI v2.0}
      dwGroupListOffset,                                   {// TAPI v2.0}
      dwState,                                             {// TAPI v2.0}
      dwNextState,                                         {// TAPI v2.0}
      dwActivityID,                                        {// TAPI v2.0}
      dwActivitySize,                                      {// TAPI v2.0}
      dwActivityOffset,                                    {// TAPI v2.0}
      dwAgentFeatures,                                     {// TAPI v2.0}
      dwValidStates,                                       {// TAPI v2.0}
      dwValidNextStates: DWORD;                            {// TAPI v2.0}
    end;

  LPLINEAPPINFO = ^TLINEAPPINFO;
  PLINEAPPINFO = ^TLINEAPPINFO;
  TLINEAPPINFO =
    record
      dwMachineNameSize,                                   {// TAPI v2.0}
      dwMachineNameOffset,                                 {// TAPI v2.0}
      dwUserNameSize,                                      {// TAPI v2.0}
      dwUserNameOffset,                                    {// TAPI v2.0}
      dwModuleFilenameSize,                                {// TAPI v2.0}
      dwModuleFilenameOffset,                              {// TAPI v2.0}
      dwFriendlyNameSize,                                  {// TAPI v2.0}
      dwFriendlyNameOffset,                                {// TAPI v2.0}
      dwMediaModes,                                        {// TAPI v2.0}
      dwAddressID: DWORD;                                  {// TAPI v2.0}
    end;
{$ENDIF}

  LPLINEDIALPARAMS = ^TLINEDIALPARAMS;
  PLINEDIALPARAMS = ^TLINEDIALPARAMS;
  TLINEDIALPARAMS =
    record
      dwDialPause,
      dwDialSpeed,
      dwDigitDuration,
      dwWaitForDialtone: DWORD;
    end;

  LPLINECALLINFO = ^TLINECALLINFO;
  PLINECALLINFO = ^TLINECALLINFO;
  TLINECALLINFO =
    record
      dwTotalSize,
      dwNeededSize,
      dwUsedSize: DWORD;
      hLine: HLINE;
      dwLineDeviceID,
      dwAddressID,
      dwBearerMode,
      dwRate,
      dwMediaMode,
      dwAppSpecific,
      dwCallID,
      dwRelatedCallID,
      dwCallParamFlags,
      dwCallStates,
      dwMonitorDigitModes,
      dwMonitorMediaModes: DWORD;
      DialParams: TLINEDIALPARAMS;
      dwOrigin,
      dwReason,
      dwCompletionID,
      dwNumOwners,
      dwNumMonitors,
      dwCountryCode,
      dwTrunk,
      dwCallerIDFlags,
      dwCallerIDSize,
      dwCallerIDOffset,
      dwCallerIDNameSize,
      dwCallerIDNameOffset,
      dwCalledIDFlags,
      dwCalledIDSize,
      dwCalledIDOffset,
      dwCalledIDNameSize,
      dwCalledIDNameOffset,
      dwConnectedIDFlags,
      dwConnectedIDSize,
      dwConnectedIDOffset,
      dwConnectedIDNameSize,
      dwConnectedIDNameOffset,
      dwRedirectionIDFlags,
      dwRedirectionIDSize,
      dwRedirectionIDOffset,
      dwRedirectionIDNameSize,
      dwRedirectionIDNameOffset,
      dwRedirectingIDFlags,
      dwRedirectingIDSize,
      dwRedirectingIDOffset,
      dwRedirectingIDNameSize,
      dwRedirectingIDNameOffset,
      dwAppNameSize,
      dwAppNameOffset,
      dwDisplayableAddressSize,
      dwDisplayableAddressOffset,
      dwCalledPartySize,
      dwCalledPartyOffset,
      dwCommentSize,
      dwCommentOffset,
      dwDisplaySize,
      dwDisplayOffset,
      dwUserUserInfoSize,
      dwUserUserInfoOffset,
      dwHighLevelCompSize,
      dwHighLevelCompOffset,
      dwLowLevelCompSize,
      dwLowLevelCompOffset,
      dwChargingInfoSize,
      dwChargingInfoOffset,
      dwTerminalModesSize,
      dwTerminalModesOffset,
      dwDevSpecificSize,
      dwDevSpecificOffset: DWORD;

{$IFDEF Tapi_Ver20_ORGREATER}
      dwCallTreatment,                                     {// TAPI v2.0}
      dwCallDataSize,                                      {// TAPI v2.0}
      dwCallDataOffset,                                    {// TAPI v2.0}
      dwSendingFlowspecSize,                               {// TAPI v2.0}
      dwSendingFlowspecOffset,                             {// TAPI v2.0}
      dwReceivingFlowspecSize,                             {// TAPI v2.0}
      dwReceivingFlowspecOffset: DWORD;                    {// TAPI v2.0}
{$ENDIF}
    end;

  LPLINECALLLIST = ^TLINECALLLIST;
  PLINECALLLIST = ^TLINECALLLIST;
  TLINECALLLIST =
    record
      dwTotalSize,
      dwNeededSize,
      dwUsedSize,
      dwCallsNumEntries,
      dwCallsSize,
      dwCallsOffset: DWORD;
    end;

  LPLINECALLPARAMS = ^TLINECALLPARAMS;
  PLINECALLPARAMS = ^TLINECALLPARAMS;
  TLINECALLPARAMS =
    record                             {// Defaults:        }
      dwTotalSize,                     {// ---------        }
      dwBearerMode,                    {// voice            }
      dwMinRate,                       {// (3.1kHz)         }
      dwMaxRate,                       {// (3.1kHz)         }
      dwMediaMode,                     {// interactiveVoice }
      dwCallParamFlags,                {// 0                }
      dwAddressMode,                   {// addressID        }
      dwAddressID: DWORD;              {// (any available)  }
      DialParams: TLINEDIALPARAMS;     {// (0, 0, 0, 0)     }
      dwOrigAddressSize,               {// 0                }
      dwOrigAddressOffset,
      dwDisplayableAddressSize,
      dwDisplayableAddressOffset,
      dwCalledPartySize,               {// 0 }
      dwCalledPartyOffset,
      dwCommentSize,                   {// 0 }
      dwCommentOffset,
      dwUserUserInfoSize,              {// 0  }
      dwUserUserInfoOffset,
      dwHighLevelCompSize,             {// 0  }
      dwHighLevelCompOffset,
      dwLowLevelCompSize,              {// 0  }
      dwLowLevelCompOffset,
      dwDevSpecificSize,               {// 0  }
      dwDevSpecificOffset: DWORD;

{$IFDEF Tapi_Ver20_ORGREATER}
      dwPredictiveAutoTransferStates,                      {// TAPI v2.0}
      dwTargetAddressSize,                                 {// TAPI v2.0}
      dwTargetAddressOffset,                               {// TAPI v2.0}
      dwSendingFlowspecSize,                               {// TAPI v2.0}
      dwSendingFlowspecOffset,                             {// TAPI v2.0}
      dwReceivingFlowspecSize,                             {// TAPI v2.0}
      dwReceivingFlowspecOffset,                           {// TAPI v2.0}
      dwDeviceClassSize,                                   {// TAPI v2.0}
      dwDeviceClassOffset,                                 {// TAPI v2.0}
      dwDeviceConfigSize,                                  {// TAPI v2.0}
      dwDeviceConfigOffset,                                {// TAPI v2.0}
      dwCallDataSize,                                      {// TAPI v2.0}
      dwCallDataOffset,                                    {// TAPI v2.0}
      dwNoAnswerTimeout,                                   {// TAPI v2.0}
      dwCallingPartyIDSize,                                {// TAPI v2.0}
      dwCallingPartyIDOffset: DWORD;                       {// TAPI v2.0}
{$ENDIF}
    end;

  LPLINECALLSTATUS = ^TLINECALLSTATUS;
  PLINECALLSTATUS = ^TLINECALLSTATUS;
  TLINECALLSTATUS =
    record
      dwTotalSize,
      dwNeededSize,
      dwUsedSize,
      dwCallState,
      dwCallStateMode,
      dwCallPrivilege,
      dwCallFeatures,
      dwDevSpecificSize,
      dwDevSpecificOffset: DWORD;

{$IFDEF Tapi_Ver20_ORGREATER}
      dwCallFeatures2: DWORD;                              {// TAPI v2.0}
      {$IFDEF Win32}
      tStateEntryTime: TSystemTime;                        {// TAPI v2.0}
      {$ELSE}
      tStateEntryTime: array[0..7] of Word;                {// TAPI v2.0}
      {$ENDIF}
{$ENDIF}
    end;


{$IFDEF Tapi_Ver20_ORGREATER}
  LPLINECALLTREATMENTENTRY = ^TLINECALLTREATMENTENTRY;
  PLINECALLTREATMENTENTRY = ^TLINECALLTREATMENTENTRY;
  TLINECALLTREATMENTENTRY =
    record
      dwCallTreatmentID,                                   {// TAPI v2.0}
      dwCallTreatmentNameSize,                             {// TAPI v2.0}
      dwCallTreatmentNameOffset: DWORD;                    {// TAPI v2.0}
    end;
{$ENDIF}


  LPLINECARDENTRY = ^TLINECARDENTRY;
  PLINECARDENTRY = ^TLINECARDENTRY;
  TLINECARDENTRY =
    record
      dwPermanentCardID,
      dwCardNameSize,
      dwCardNameOffset,
      dwCardNumberDigits,                                  {// TAPI v1.4}
      dwSameAreaRuleSize,                                  {// TAPI v1.4}
      dwSameAreaRuleOffset,                                {// TAPI v1.4}
      dwLongDistanceRuleSize,                              {// TAPI v1.4}
      dwLongDistanceRuleOffset,                            {// TAPI v1.4}
      dwInternationalRuleSize,                             {// TAPI v1.4}
      dwInternationalRuleOffset,                           {// TAPI v1.4}
      dwOptions: DWORD;                                    {// TAPI v1.4}
    end;

  LPLINECOUNTRYENTRY = ^TLINECOUNTRYENTRY;
  PLINECOUNTRYENTRY = ^TLINECOUNTRYENTRY;
  TLINECOUNTRYENTRY =
    record
      dwCountryID,                                         {// TAPI v1.4}
      dwCountryCode,                                       {// TAPI v1.4}
      dwNextCountryID,                                     {// TAPI v1.4}
      dwCountryNameSize,                                   {// TAPI v1.4}
      dwCountryNameOffset,                                 {// TAPI v1.4}
      dwSameAreaRuleSize,                                  {// TAPI v1.4}
      dwSameAreaRuleOffset,                                {// TAPI v1.4}
      dwLongDistanceRuleSize,                              {// TAPI v1.4}
      dwLongDistanceRuleOffset,                            {// TAPI v1.4}
      dwInternationalRuleSize,                             {// TAPI v1.4}
      dwInternationalRuleOffset: DWORD;                    {// TAPI v1.4}
    end;

  LPLINECOUNTRYLIST = ^TLINECOUNTRYLIST;
  PLINECOUNTRYLIST = ^TLINECOUNTRYLIST;
  TLINECOUNTRYLIST =
    record
      dwTotalSize,                                         {// TAPI v1.4}
      dwNeededSize,                                        {// TAPI v1.4}
      dwUsedSize,                                          {// TAPI v1.4}
      dwNumCountries,                                      {// TAPI v1.4}
      dwCountryListSize,                                   {// TAPI v1.4}
      dwCountryListOffset: DWORD;                          {// TAPI v1.4}
    end;

  LPLINEDEVCAPS = ^TLINEDEVCAPS;
  PLINEDEVCAPS = ^TLINEDEVCAPS;
  TLINEDEVCAPS =
    record
      dwTotalSize,
      dwNeededSize,
      dwUsedSize,
      dwProviderInfoSize,
      dwProviderInfoOffset,
      dwSwitchInfoSize,
      dwSwitchInfoOffset,
      dwPermanentLineID,
      dwLineNameSize,
      dwLineNameOffset,
      dwStringFormat,
      dwAddressModes,
      dwNumAddresses,
      dwBearerModes,
      dwMaxRate,
      dwMediaModes,
      dwGenerateToneModes,
      dwGenerateToneMaxNumFreq,
      dwGenerateDigitModes,
      dwMonitorToneMaxNumFreq,
      dwMonitorToneMaxNumEntries,
      dwMonitorDigitModes,
      dwGatherDigitsMinTimeout,
      dwGatherDigitsMaxTimeout,
      dwMedCtlDigitMaxListSize,
      dwMedCtlMediaMaxListSize,
      dwMedCtlToneMaxListSize,
      dwMedCtlCallStateMaxListSize,
      dwDevCapFlags,
      dwMaxNumActiveCalls,
      dwAnswerMode,
      dwRingModes,
      dwLineStates,
      dwUUIAcceptSize,
      dwUUIAnswerSize,
      dwUUIMakeCallSize,
      dwUUIDropSize,
      dwUUISendUserUserInfoSize,
      dwUUICallInfoSize: DWORD;
      MinDialParams,
      MaxDialParams,
      DefaultDialParams: TLINEDIALPARAMS;
      dwNumTerminals,
      dwTerminalCapsSize,
      dwTerminalCapsOffset,
      dwTerminalTextEntrySize,
      dwTerminalTextSize,
      dwTerminalTextOffset,
      dwDevSpecificSize,
      dwDevSpecificOffset,

      dwLineFeatures: DWORD;                               {// TAPI v1.4}

{$IFDEF Tapi_Ver20_ORGREATER}
      dwSettableDevStatus,                                 {// TAPI v2.0}
      dwDeviceClassesSize,                                 {// TAPI v2.0}
      dwDeviceClassesOffset: DWORD;                        {// TAPI v2.0}
{$ENDIF}
    end;

  LPLINEDEVSTATUS = ^TLINEDEVSTATUS;
  PLINEDEVSTATUS = ^TLINEDEVSTATUS;
  TLINEDEVSTATUS =
    record
      dwTotalSize,
      dwNeededSize,
      dwUsedSize,
      dwNumOpens,
      dwOpenMediaModes,
      dwNumActiveCalls,
      dwNumOnHoldCalls,
      dwNumOnHoldPendCalls,
      dwLineFeatures,
      dwNumCallCompletions,
      dwRingMode,
      dwSignalLevel,
      dwBatteryLevel,
      dwRoamMode,
      dwDevStatusFlags,
      dwTerminalModesSize,
      dwTerminalModesOffset,
      dwDevSpecificSize,
      dwDevSpecificOffset: DWORD;

{$IFDEF Tapi_Ver20_ORGREATER}
      dwAvailableMediaModes,                               {// TAPI v2.0}
      dwAppInfoSize,                                       {// TAPI v2.0}
      dwAppInfoOffset: DWORD;                              {// TAPI v2.0}
{$ENDIF}
    end;

  LPLINEEXTENSIONID = ^TLINEEXTENSIONID;
  PLINEEXTENSIONID = ^TLINEEXTENSIONID;
  TLINEEXTENSIONID =
    record
      dwExtensionID0,
      dwExtensionID1,
      dwExtensionID2,
      dwExtensionID3: DWORD;
    end;

  LPLINEFORWARD = ^TLINEFORWARD;
  PLINEFORWARD = ^TLINEFORWARD;
  TLINEFORWARD =
    record
      dwForwardMode,
      dwCallerAddressSize,
      dwCallerAddressOffset,
      dwDestCountryCode,
      dwDestAddressSize,
      dwDestAddressOffset: DWORD;
    end;

  LPLINEFORWARDLIST = ^TLINEFORWARDLIST;
  PLINEFORWARDLIST = ^TLINEFORWARDLIST;
  TLINEFORWARDLIST =
    record
      dwTotalSize,
      dwNumEntries: DWORD;
      {!! JEDI:bchoate:1997-11-11: Added ForwardList field,
       missing from 1996-11-25 revision }
      ForwardList: array [0..0] of TLINEFORWARD;
    end;

  LPLINEGENERATETONE = ^TLINEGENERATETONE;
  PLINEGENERATETONE = ^TLINEGENERATETONE;
  TLINEGENERATETONE =
    record
      dwFrequency,
      dwCadenceOn,
      dwCadenceOff,
      dwVolume: DWORD;
    end;

{$IFDEF Tapi_Ver20_ORGREATER}
  THandleUnion =
    record
      case longint of
        0 :
          (hEvent: THandle);
        1 :
          (hCompletionPort: THandle);
    end;

  LPLINEINITIALIZEEXPARAMS = ^TLINEINITIALIZEEXPARAMS;
  PLINEINITIALIZEEXPARAMS = ^TLINEINITIALIZEEXPARAMS;
  TLINEINITIALIZEEXPARAMS =
    record
      dwTotalSize,                                         {// TAPI v2.0}
      dwNeededSize,                                        {// TAPI v2.0}
      dwUsedSize,                                          {// TAPI v2.0}
      dwOptions: DWORD;                                    {// TAPI v2.0}

      Handles: THandleUnion; {//!! Union converted to THandleUnion}

      dwCompletionKey: DWORD;                              {// TAPI v2.0}
    end;
{$ENDIF}

  LPLINELOCATIONENTRY = ^TLINELOCATIONENTRY;
  PLINELOCATIONENTRY = ^TLINELOCATIONENTRY;
  TLINELOCATIONENTRY =
    record
      dwPermanentLocationID,
      dwLocationNameSize,
      dwLocationNameOffset,
      dwCountryCode,
      dwCityCodeSize,
      dwCityCodeOffset,
      dwPreferredCardID,

      dwLocalAccessCodeSize,                               {// TAPI v1.4}
      dwLocalAccessCodeOffset,                             {// TAPI v1.4}
      dwLongDistanceAccessCodeSize,                        {// TAPI v1.4}
      dwLongDistanceAccessCodeOffset,                      {// TAPI v1.4}
      dwTollPrefixListSize,                                {// TAPI v1.4}
      dwTollPrefixListOffset,                              {// TAPI v1.4}
      dwCountryID,                                         {// TAPI v1.4}
      dwOptions,                                           {// TAPI v1.4}
      dwCancelCallWaitingSize,                             {// TAPI v1.4}
      dwCancelCallWaitingOffset: DWORD;                    {// TAPI v1.4}
    end;

  LPLINEMEDIACONTROLCALLSTATE = ^TLINEMEDIACONTROLCALLSTATE;
  PLINEMEDIACONTROLCALLSTATE = ^TLINEMEDIACONTROLCALLSTATE;
  TLINEMEDIACONTROLCALLSTATE =
    record
      dwCallStates,
      dwMediaControl: DWORD;
    end;

  LPLINEMEDIACONTROLDIGIT = ^TLINEMEDIACONTROLDIGIT;
  PLINEMEDIACONTROLDIGIT = ^TLINEMEDIACONTROLDIGIT;
  TLINEMEDIACONTROLDIGIT =
    record
      dwDigit,
      dwDigitModes,
      dwMediaControl: DWORD;
    end;

  LPLINEMEDIACONTROLMEDIA = ^TLINEMEDIACONTROLMEDIA;
  PLINEMEDIACONTROLMEDIA = ^TLINEMEDIACONTROLMEDIA;
  TLINEMEDIACONTROLMEDIA =
    record
      dwMediaModes,
      dwDuration,
      dwMediaControl: DWORD;
    end;

  LPLINEMEDIACONTROLTONE = ^TLINEMEDIACONTROLTONE;
  PLINEMEDIACONTROLTONE = ^TLINEMEDIACONTROLTONE;
  TLINEMEDIACONTROLTONE =
    record
      dwAppSpecific,
      dwDuration,
      dwFrequency1,
      dwFrequency2,
      dwFrequency3,
      dwMediaControl: DWORD;
    end;

{$IFDEF Tapi_Ver20_ORGREATER}
  LPLINEMESSAGE = ^TLINEMESSAGE;
  PLINEMESSAGE = ^TLINEMESSAGE;
  TLINEMESSAGE =
    record
      hDevice,                                             {// TAPI v2.0}
      dwMessageID,                                         {// TAPI v2.0}
      dwCallbackInstance,                                  {// TAPI v2.0}
      dwParam1,                                            {// TAPI v2.0}
      dwParam2,                                            {// TAPI v2.0}
      dwParam3: DWORD;                                     {// TAPI v2.0}
    end;
{$ENDIF}

  LPLINEMONITORTONE = ^TLINEMONITORTONE;
  PLINEMONITORTONE = ^TLINEMONITORTONE;
  TLINEMONITORTONE =
    record
      dwAppSpecific,
      dwDuration,
      dwFrequency1,
      dwFrequency2,
      dwFrequency3: DWORD;
    end;

  LPLINEPROVIDERENTRY = ^TLINEPROVIDERENTRY;
  PLINEPROVIDERENTRY = ^TLINEPROVIDERENTRY;
  TLINEPROVIDERENTRY =
    record
      dwPermanentProviderID,                               {// TAPI v1.4}
      dwProviderFilenameSize,                              {// TAPI v1.4}
      dwProviderFilenameOffset: DWORD;                     {// TAPI v1.4}
    end;

  LPLINEPROVIDERLIST = ^TLINEPROVIDERLIST;
  PLINEPROVIDERLIST = ^TLINEPROVIDERLIST;
  TLINEPROVIDERLIST =
    record
      dwTotalSize,                                         {// TAPI v1.4}
      dwNeededSize,                                        {// TAPI v1.4}
      dwUsedSize,                                          {// TAPI v1.4}
      dwNumProviders,                                      {// TAPI v1.4}
      dwProviderListSize,                                  {// TAPI v1.4}
      dwProviderListOffset: DWORD;                         {// TAPI v1.4}
    end;

{$IFDEF Tapi_Ver20_ORGREATER}
  LPLINEPROXYREQUEST = ^TLINEPROXYREQUEST;
  PLINEPROXYREQUEST = ^TLINEPROXYREQUEST;
  TLINEPROXYREQUEST =
    record
      dwSize,                                              {// TAPI v2.0}
      dwClientMachineNameSize,                             {// TAPI v2.0}
      dwClientMachineNameOffset,                           {// TAPI v2.0}
      dwClientUserNameSize,                                {// TAPI v2.0}
      dwClientUserNameOffset,                              {// TAPI v2.0}
      dwClientAppAPIVersion,                               {// TAPI v2.0}
      dwRequestType: DWORD;                                {// TAPI v2.0}

      case longint of
        0 :
          (
            SetAgentGroup :
              record
                dwAddressID: DWORD;                        {// TAPI v2.0}
                GroupList: TLINEAGENTGROUPLIST;            {// TAPI v2.0}
              end;
          );
        1 :
          (
            SetAgentState :
              record
                dwAddressID,                               {// TAPI v2.0}
                dwAgentState,                              {// TAPI v2.0}
                dwNextAgentState: DWORD;                   {// TAPI v2.0}
              end;
          );
        2 :
          (
            SetAgentActivity :
              record
                dwAddressID: DWORD;                        {// TAPI v2.0}
                dwActivityID: DWORD;                       {// TAPI v2.0}
              end;
          );
        3 :
          (
            GetAgentCaps :
              record
                dwAddressID: DWORD;                        {// TAPI v2.0}
                AgentCaps: TLINEAGENTCAPS;                 {// TAPI v2.0}
              end;
          );
        4 :
          (
            GetAgentStatus :
              record
                dwAddressID: DWORD;                        {// TAPI v2.0}
                AgentStatus: TLINEAGENTSTATUS;             {// TAPI v2.0}
              end;
          );
        5 :
          (
            AgentSpecific :
              record
                dwAddressID,                               {// TAPI v2.0}
                dwAgentExtensionIDIndex,                   {// TAPI v2.0}
                dwSize: DWORD;                             {// TAPI v2.0}
                Params: array[0..0] of Byte;               {// TAPI v2.0}
              end;
          );
        6 :
          (
            GetAgentActivityList :
              record
                dwAddressID: DWORD;                        {// TAPI v2.0}
                ActivityList: TLINEAGENTACTIVITYLIST;      {// TAPI v2.0}
              end;
          );
        7 :
          (
            GetAgentGroupList :
              record
                dwAddressID: DWORD;                        {// TAPI v2.0}
                GroupList: TLINEAGENTGROUPLIST;            {// TAPI v2.0}
              end;
          );
    end;
{$ENDIF}


  LPLINEREQMAKECALLA = ^TLINEREQMAKECALLA;
  PLINEREQMAKECALLA = ^TLINEREQMAKECALLA;
  TLINEREQMAKECALLA =
    record
      szDestAddress: array[0..TAPIMAXDESTADDRESSSIZE - 1] of Char;
      szAppName    : array[0..TAPIMAXAPPNAMESIZE - 1] of Char;
      szCalledParty: array[0..TAPIMAXCALLEDPARTYSIZE - 1] of Char;
      szComment    : array[0..TAPIMAXCOMMENTSIZE - 1] of Char;
    end;

{$IFDEF Tapi_Ver20_ORGREATER}
  LPLINEREQMAKECALLW = ^TLINEREQMAKECALLW;
  PLINEREQMAKECALLW = ^TLINEREQMAKECALLW;
  TLINEREQMAKECALLW =
    record
      szDestAddress: array[0..TAPIMAXDESTADDRESSSIZE - 1] of WideChar;
      szAppName    : array[0..TAPIMAXAPPNAMESIZE - 1] of WideChar;
      szCalledParty: array[0..TAPIMAXCALLEDPARTYSIZE - 1] of WideChar;
      szComment    : array[0..TAPIMAXCOMMENTSIZE - 1] of WideChar;
    end;
{$IFDEF UNICODE}
  LPLINEREQMAKECALL = ^TLINEREQMAKECALL;
  PLINEREQMAKECALL = ^TLINEREQMAKECALL;
  TLINEREQMAKECALL = TLINEREQMAKECALLW;
{$ELSE}
  LPLINEREQMAKECALL = ^TLINEREQMAKECALL;
  PLINEREQMAKECALL = ^TLINEREQMAKECALL;
  TLINEREQMAKECALL = TLINEREQMAKECALLA;
{$ENDIF}
{$ELSE}
  LPLINEREQMAKECALL = ^TLINEREQMAKECALL;
  PLINEREQMAKECALL = ^TLINEREQMAKECALL;
  TLINEREQMAKECALL = TLINEREQMAKECALLA;
{$ENDIF}

  LPLINEREQMEDIACALLA = ^TLINEREQMEDIACALLA;
  PLINEREQMEDIACALLA = ^TLINEREQMEDIACALLA;
  TLINEREQMEDIACALLA =
    record
      hWnd         : HWND;
      wRequestID   : WPARAM;
      szDeviceClass: array[0..TAPIMAXDEVICECLASSSIZE - 1] of Char;
      ucDeviceID   : array[0..TAPIMAXDEVICEIDSIZE - 1] of Byte;
      dwSize,
      dwSecure     : DWORD;
      {!! JEDI:bchoate:1997-11-11: Changed length of array to length - 1
       to be consistent (for the next 4 fields) }
      szDestAddress: array[0..TAPIMAXDESTADDRESSSIZE - 1] of Char;
      szAppName    : array[0..TAPIMAXAPPNAMESIZE - 1] of Char;
      szCalledParty: array[0..TAPIMAXCALLEDPARTYSIZE - 1] of Char;
      szComment    : array[0..TAPIMAXCOMMENTSIZE - 1] of Char;
    end;

{$IFDEF Tapi_Ver20_ORGREATER}
  LPLINEREQMEDIACALLW = ^TLINEREQMEDIACALLW;
  PLINEREQMEDIACALLW = ^TLINEREQMEDIACALLW;
  TLINEREQMEDIACALLW =
    record
      hWnd         : HWND;
      wRequestID   : WPARAM;
      szDeviceClass: array[0..TAPIMAXDEVICECLASSSIZE - 1] of WideChar;
      ucDeviceID   : array[0..TAPIMAXDEVICEIDSIZE - 1] of Byte;
      dwSize,
      dwSecure     : DWORD;
      {!! JEDI:bchoate:1997-11-11: Changed length of array to length - 1
       to be consistent (for the next 4 fields) }
      szDestAddress: array[0..TAPIMAXDESTADDRESSSIZE - 1] of WideChar;
      szAppName    : array[0..TAPIMAXAPPNAMESIZE - 1] of WideChar;
      szCalledParty: array[0..TAPIMAXCALLEDPARTYSIZE - 1] of WideChar;
      szComment    : array[0..TAPIMAXCOMMENTSIZE - 1] of WideChar;
    end;
{$IFDEF UNICODE}
  LPLINEREQMEDIACALL = ^TLINEREQMEDIACALL;
  PLINEREQMEDIACALL = ^TLINEREQMEDIACALL;
  TLINEREQMEDIACALL = TLINEREQMEDIACALLW;
{$ELSE}
  LPLINEREQMEDIACALL = ^TLINEREQMEDIACALL;
  PLINEREQMEDIACALL = ^TLINEREQMEDIACALL;
  TLINEREQMEDIACALL = TLINEREQMEDIACALLA;
{$ENDIF}
{$ELSE}
  LPLINEREQMEDIACALL = ^TLINEREQMEDIACALL;
  PLINEREQMEDIACALL = ^TLINEREQMEDIACALL;
  TLINEREQMEDIACALL = TLINEREQMEDIACALLA;
{$ENDIF}


  LPLINETERMCAPS = ^TLINETERMCAPS;
  PLINETERMCAPS = ^TLINETERMCAPS;
  TLINETERMCAPS =
    record
      dwTermDev,
      dwTermModes,
      dwTermSharing: DWORD;
    end;

  LPLINETRANSLATECAPS = ^TLINETRANSLATECAPS;
  PLINETRANSLATECAPS = ^TLINETRANSLATECAPS;
  TLINETRANSLATECAPS =
    record
      dwTotalSize,
      dwNeededSize,
      dwUsedSize,
      dwNumLocations,
      dwLocationListSize,
      dwLocationListOffset,
      dwCurrentLocationID,
      dwNumCards,
      dwCardListSize,
      dwCardListOffset,
      dwCurrentPreferredCardID: DWORD;
    end;

  LPLINETRANSLATEOUTPUT = ^TLINETRANSLATEOUTPUT;
  PLINETRANSLATEOUTPUT = ^TLINETRANSLATEOUTPUT;
  TLINETRANSLATEOUTPUT =
    record
      dwTotalSize,
      dwNeededSize,
      dwUsedSize,
      dwDialableStringSize,
      dwDialableStringOffset,
      dwDisplayableStringSize,
      dwDisplayableStringOffset,
      dwCurrentCountry,
      dwDestCountry,
      dwTranslateResults: DWORD;
    end;

  LPPHONEBUTTONINFO = ^TPHONEBUTTONINFO;
  PPHONEBUTTONINFO = ^TPHONEBUTTONINFO;
  TPHONEBUTTONINFO =
    record
      dwTotalSize,
      dwNeededSize,
      dwUsedSize,
      dwButtonMode,
      dwButtonFunction,
      dwButtonTextSize,
      dwButtonTextOffset,
      dwDevSpecificSize,
      dwDevSpecificOffset,

      dwButtonState: DWORD;                                {// TAPI v1.4}
    end;

  LPPHONECAPS = ^TPHONECAPS;
  PPHONECAPS = ^TPHONECAPS;
  TPHONECAPS =
    record
      dwTotalSize,
      dwNeededSize,
      dwUsedSize,
      dwProviderInfoSize,
      dwProviderInfoOffset,
      dwPhoneInfoSize,
      dwPhoneInfoOffset,
      dwPermanentPhoneID,
      dwPhoneNameSize,
      dwPhoneNameOffset,
      dwStringFormat,
      dwPhoneStates,
      dwHookSwitchDevs,
      dwHandsetHookSwitchModes,
      dwSpeakerHookSwitchModes,
      dwHeadsetHookSwitchModes,
      dwVolumeFlags,
      dwGainFlags,
      dwDisplayNumRows,
      dwDisplayNumColumns,
      dwNumRingModes,
      dwNumButtonLamps,
      dwButtonModesSize,
      dwButtonModesOffset,
      dwButtonFunctionsSize,
      dwButtonFunctionsOffset,
      dwLampModesSize,
      dwLampModesOffset,
      dwNumSetData,
      dwSetDataSize,
      dwSetDataOffset,
      dwNumGetData,
      dwGetDataSize,
      dwGetDataOffset,
      dwDevSpecificSize,
      dwDevSpecificOffset: DWORD;

{$IFDEF Tapi_Ver20_ORGREATER}
      dwDeviceClassesSize,                                 {// TAPI v2.0}
      dwDeviceClassesOffset,                               {// TAPI v2.0}
      dwPhoneFeatures,                                     {// TAPI v2.0}
      dwSettableHandsetHookSwitchModes,                    {// TAPI v2.0}
      dwSettableSpeakerHookSwitchModes,                    {// TAPI v2.0}
      dwSettableHeadsetHookSwitchModes,                    {// TAPI v2.0}
      dwMonitoredHandsetHookSwitchModes,                   {// TAPI v2.0}
      dwMonitoredSpeakerHookSwitchModes,                   {// TAPI v2.0}
      dwMonitoredHeadsetHookSwitchModes: DWORD;            {// TAPI v2.0}
{$ENDIF}
    end;

  LPPHONEEXTENSIONID = ^TPHONEEXTENSIONID;
  PPHONEEXTENSIONID = ^TPHONEEXTENSIONID;
  TPHONEEXTENSIONID =
    record
      dwExtensionID0,
      dwExtensionID1,
      dwExtensionID2,
      dwExtensionID3: DWORD;
    end;

{$IFDEF Tapi_Ver20_ORGREATER}
  LPPHONEINITIALIZEEXPARAMS = ^TPHONEINITIALIZEEXPARAMS;
  PPHONEINITIALIZEEXPARAMS = ^TPHONEINITIALIZEEXPARAMS;
  TPHONEINITIALIZEEXPARAMS =
    record
      dwTotalSize,                                         {// TAPI v2.0}
      dwNeededSize,                                        {// TAPI v2.0}
      dwUsedSize,                                          {// TAPI v2.0}
      dwOptions: DWORD;                                    {// TAPI v2.0}

      Handles: THandleUnion; {//!! Union converted to THandleUnion}

      dwCompletionKey: DWORD;                              {// TAPI v2.0}
    end;

  LPPHONEMESSAGE = ^TPHONEMESSAGE;
  PPHONEMESSAGE = ^TPHONEMESSAGE;
  TPHONEMESSAGE =
    record
      hDevice,                                             {// TAPI v2.0}
      dwMessageID,                                         {// TAPI v2.0}
      dwCallbackInstance,                                  {// TAPI v2.0}
      dwParam1,                                            {// TAPI v2.0}
      dwParam2,                                            {// TAPI v2.0}
      dwParam3: DWORD;                                     {// TAPI v2.0}
    end;
{$ENDIF}

  LPPHONESTATUS = ^TPHONESTATUS;
  PPHONESTATUS = ^TPHONESTATUS;
  TPHONESTATUS =
    record
      dwTotalSize,
      dwNeededSize,
      dwUsedSize,
      dwStatusFlags,
      dwNumOwners,
      dwNumMonitors,
      dwRingMode,
      dwRingVolume,
      dwHandsetHookSwitchMode,
      dwHandsetVolume,
      dwHandsetGain,
      dwSpeakerHookSwitchMode,
      dwSpeakerVolume,
      dwSpeakerGain,
      dwHeadsetHookSwitchMode,
      dwHeadsetVolume,
      dwHeadsetGain,
      dwDisplaySize,
      dwDisplayOffset,
      dwLampModesSize,
      dwLampModesOffset,
      dwOwnerNameSize,
      dwOwnerNameOffset,
      dwDevSpecificSize,
      dwDevSpecificOffset: DWORD;

{$IFDEF Tapi_Ver20_ORGREATER}
      dwPhoneFeatures: DWORD;                              {// TAPI v2.0}
{$ENDIF}
    end;

  LPVARSTRING = ^TVARSTRING;
  PVARSTRING = ^TVARSTRING;
  TVARSTRING =
    record
      dwTotalSize,
      dwNeededSize,
      dwUsedSize,
      dwStringFormat,
      dwStringSize,
      dwStringOffset: DWORD;
    end;


function lineAccept(
    hCall: HCALL;
    lpsUserUserInfo: LPCSTR;
    dwSize: DWORD): LONG;
    stdcall;

function lineAddProvider(                                  {// TAPI v1.4}
    lpszProviderFilename: LPCSTR;
    hwndOwner: HWND;
    lpdwPermanentProviderID: LPDWORD): LONG;
    stdcall;

{$IFDEF Win32}
function lineAddProviderA(                                 {// TAPI v1.4}
    lpszProviderFilename: LPCSTR;
    hwndOwner: HWND;
    lpdwPermanentProviderID: LPDWORD): LONG;
    stdcall;

function lineAddProviderW(
    lpszProviderFilename: LPCWSTR;
    hwndOwner: HWND;
    lpdwPermanentProviderID: LPDWORD): LONG;
    stdcall;
{$ENDIF}

function lineAddToConference(
    hConfCall: HCALL;
    hConsultCall: HCALL): LONG;
    stdcall;

{$IFDEF Tapi_Ver20_ORGREATER}
function lineAgentSpecific(                                {// TAPI v2.0}
    hLine: HLINE;
    dwAddressID: DWORD;
    dwAgentExtensionIDIndex: DWORD;
    lpParams: LPVOID;
    dwSize: DWORD): LONG;
    stdcall;
{$ENDIF}

function lineAnswer(
    hCall: HCALL;
    lpsUserUserInfo: LPCSTR;
    dwSize: DWORD): LONG;
    stdcall;

function lineBlindTransfer(
    hCall: HCALL;
    lpszDestAddress: LPCSTR;
    dwCountryCode: DWORD): LONG;
    stdcall;

{$IFDEF Win32}
function lineBlindTransferA(
    hCall: HCALL;
    lpszDestAddress: LPCSTR;
    dwCountryCode: DWORD): LONG;
    stdcall;

function lineBlindTransferW(
    hCall: HCALL;
    lpszDestAddressW: LPCWSTR;
    dwCountryCode: DWORD): LONG;
    stdcall;
{$ENDIF}

function lineClose(
    hLine: HLINE): LONG;
    stdcall;

function lineCompleteCall(
    hCall: HCALL;
    lpdwCompletionID: LPDWORD;
    dwCompletionMode: DWORD;
    dwMessageID: DWORD): LONG;
    stdcall;

function lineCompleteTransfer(
    hCall: HCALL;
    hConsultCall: HCALL;
    lphConfCall: LPHCALL;
    dwTransferMode: DWORD): LONG;
    stdcall;

function lineConfigDialog(
    dwDeviceID: DWORD;
    hwndOwner: HWND;
    lpszDeviceClass: LPCSTR): LONG;
    stdcall;

{$IFDEF Win32}
function lineConfigDialogA(
    dwDeviceID: DWORD;
    hwndOwner: HWND;
    lpszDeviceClass: LPCSTR): LONG;
    stdcall;

function lineConfigDialogW(
    dwDeviceID: DWORD;
    hwndOwner: HWND;
    lpszDeviceClass: LPCWSTR): LONG;
    stdcall;
{$ENDIF}

function lineConfigDialogEdit(                             {// TAPI v1.4}
    dwDeviceID: DWORD;
    hwndOwner: HWND;
    lpszDeviceClass: LPCSTR;
    const lpDeviceConfigIn: LPVOID;
    dwSize: DWORD;
    lpDeviceConfigOut: LPVARSTRING): LONG;
    stdcall;

{$IFDEF Win32}
function lineConfigDialogEditA(                            {// TAPI v1.4}
    dwDeviceID: DWORD;
    hwndOwner: HWND;
    lpszDeviceClass: LPCSTR;
    const lpDeviceConfigIn: LPVOID;
    dwSize: DWORD;
    lpDeviceConfigOut: LPVARSTRING): LONG;
    stdcall;

function lineConfigDialogEditW(
    dwDeviceID: DWORD;
    hwndOwner: HWND;
    lpszDeviceClass: LPCWSTR;
    const lpDeviceConfigIn: LPVOID;
    dwSize: DWORD;
    lpDeviceConfigOut: LPVARSTRING): LONG;
    stdcall;
{$ENDIF}

function lineConfigProvider(                               {// TAPI v1.4}
    hwndOwner: HWND;
    dwPermanentProviderID: DWORD): LONG;
    stdcall;

function lineDeallocateCall(
    hCall: HCALL): LONG;
    stdcall;

function lineDevSpecific(
    hLine: HLINE;
    dwAddressID: DWORD;
    hCall: HCALL;
    lpParams: LPVOID;
    dwSize: DWORD): LONG;
    stdcall;

function lineDevSpecificFeature(
    hLine: HLINE;
    dwFeature: DWORD;
    lpParams: LPVOID;
    dwSize: DWORD): LONG;
    stdcall;

function lineDial(
    hCall: HCALL;
    lpszDestAddress: LPCSTR;
    dwCountryCode: DWORD): LONG;
    stdcall;

{$IFDEF Win32}
function lineDialA(
    hCall: HCALL;
    lpszDestAddress: LPCSTR;
    dwCountryCode: DWORD): LONG;
    stdcall;

function lineDialW(
    hCall: HCALL;
    lpszDestAddress: LPCWSTR;
    dwCountryCode: DWORD): LONG;
    stdcall;
{$ENDIF}

function lineDrop(
    hCall: HCALL;
    lpsUserUserInfo: LPCSTR;
    dwSize: DWORD): LONG;
    stdcall;

function lineForward(
    hLine: HLINE;
    bAllAddresses: DWORD;
    dwAddressID: DWORD;
    const lpForwardList: LPLINEFORWARDLIST;
    dwNumRingsNoAnswer: DWORD;
    lphConsultCall: LPHCALL;
    const lpCallParams: LPLINECALLPARAMS): LONG;
    stdcall;

{$IFDEF Win32}
function lineForwardA(
    hLine: HLINE;
    bAllAddresses: DWORD;
    dwAddressID: DWORD;
    const lpForwardList: LPLINEFORWARDLIST;
    dwNumRingsNoAnswer: DWORD;
    lphConsultCall: LPHCALL;
    const lpCallParams: LPLINECALLPARAMS): LONG;
    stdcall;

function lineForwardW(
    hLine: HLINE;
    bAllAddresses: DWORD;
    dwAddressID: DWORD;
    const lpForwardList: LPLINEFORWARDLIST;
    dwNumRingsNoAnswer: DWORD;
    lphConsultCall: LPHCALL;
    const lpCallParams: LPLINECALLPARAMS): LONG;
    stdcall;
{$ENDIF}

function lineGatherDigits(
    hCall: HCALL;
    dwDigitModes: DWORD;
    lpsDigits: LPSTR;
    dwNumDigits: DWORD;
    lpszTerminationDigits: LPCSTR;
    dwFirstDigitTimeout: DWORD;
    dwInterDigitTimeout: DWORD): LONG;
    stdcall;

{$IFDEF Win32}
function lineGatherDigitsA(
    hCall: HCALL;
    dwDigitModes: DWORD;
    lpsDigits: LPSTR;
    dwNumDigits: DWORD;
    lpszTerminationDigits: LPCSTR;
    dwFirstDigitTimeout: DWORD;
    dwInterDigitTimeout: DWORD): LONG;
    stdcall;

function lineGatherDigitsW(
    hCall: HCALL;
    dwDigitModes: DWORD;
    lpsDigits: LPWSTR;
    dwNumDigits: DWORD;
    lpszTerminationDigits: LPCWSTR;
    dwFirstDigitTimeout: DWORD;
    dwInterDigitTimeout: DWORD): LONG;
    stdcall;
{$ENDIF}

function lineGenerateDigits(
    hCall: HCALL;
    dwDigitMode: DWORD;
    lpszDigits: LPCSTR;
    dwDuration: DWORD): LONG;
    stdcall;

{$IFDEF Win32}
function lineGenerateDigitsA(
    hCall: HCALL;
    dwDigitMode: DWORD;
    lpszDigits: LPCSTR;
    dwDuration: DWORD): LONG;
    stdcall;

function lineGenerateDigitsW(
    hCall: HCALL;
    dwDigitMode: DWORD;
    lpszDigits: LPCWSTR;
    dwDuration: DWORD): LONG;
    stdcall;
{$ENDIF}

function lineGenerateTone(
    hCall: HCALL;
    dwToneMode: DWORD;
    dwDuration: DWORD;
    dwNumTones: DWORD;
    const lpTones: LPLINEGENERATETONE): LONG;
    stdcall;

function lineGetAddressCaps(
    hLineApp: HLINEAPP;
    dwDeviceID: DWORD;
    dwAddressID: DWORD;
    dwAPIVersion: DWORD;
    dwExtVersion: DWORD;
    lpAddressCaps: LPLINEADDRESSCAPS): LONG;
    stdcall;

{$IFDEF Win32}
function lineGetAddressCapsA(
    hLineApp: HLINEAPP;
    dwDeviceID: DWORD;
    dwAddressID: DWORD;
    dwAPIVersion: DWORD;
    dwExtVersion: DWORD;
    lpAddressCaps: LPLINEADDRESSCAPS): LONG;
    stdcall;

function lineGetAddressCapsW(
    hLineApp: HLINEAPP;
    dwDeviceID: DWORD;
    dwAddressID: DWORD;
    dwAPIVersion: DWORD;
    dwExtVersion: DWORD;
    lpAddressCaps: LPLINEADDRESSCAPS): LONG;
    stdcall;
{$ENDIF}

function lineGetAddressID(
    hLine: HLINE;
    lpdwAddressID: LPDWORD;
    dwAddressMode: DWORD;
    lpsAddress: LPCSTR;
    dwSize: DWORD): LONG;
    stdcall;

{$IFDEF Win32}
function lineGetAddressIDA(
    hLine: HLINE;
    lpdwAddressID: LPDWORD;
    dwAddressMode: DWORD;
    lpsAddress: LPCSTR;
    dwSize: DWORD): LONG;
    stdcall;

function lineGetAddressIDW(
    hLine: HLINE;
    lpdwAddressID: LPDWORD;
    dwAddressMode: DWORD;
    lpsAddress: LPCWSTR;
    dwSize: DWORD): LONG;
    stdcall;
{$ENDIF}

function lineGetAddressStatus(
    hLine: HLINE;
    dwAddressID: DWORD;
    lpAddressStatus: LPLINEADDRESSSTATUS): LONG;
    stdcall;

{$IFDEF Win32}
function lineGetAddressStatusA(
    hLine: HLINE;
    dwAddressID: DWORD;
    lpAddressStatus: LPLINEADDRESSSTATUS): LONG;
    stdcall;

function lineGetAddressStatusW(
    hLine: HLINE;
    dwAddressID: DWORD;
    lpAddressStatus: LPLINEADDRESSSTATUS): LONG;
    stdcall;
{$ENDIF}


{!! JEDI:bchoate:1997-11-11: Reorganized the following section to
 match the original header file (the whole $IFDEF span). }

{$IFDEF Tapi_Ver20_ORGREATER}
function lineGetAgentActivityList(                         {// TAPI v2.0}
    hLine: HLINE;
    dwAddressID: DWORD;
    lpAgentActivityList: LPLINEAGENTACTIVITYLIST): LONG;
    stdcall;

{$IFDEF Win32}
function lineGetAgentActivityListA(                        {// TAPI v2.0}
    hLine: HLINE;
    dwAddressID: DWORD;
    lpAgentActivityList: LPLINEAGENTACTIVITYLIST): LONG;
    stdcall;

function lineGetAgentActivityListW(                        {// TAPI v2.0}
    hLine: HLINE;
    dwAddressID: DWORD;
    lpAgentActivityList: LPLINEAGENTACTIVITYLIST): LONG;
    stdcall;
{$ENDIF}

function lineGetAgentCaps(                                 {// TAPI v2.0}
    hLineApp: HLINEAPP;
    dwDeviceID: DWORD;
    dwAddressID: DWORD;
    dwAppAPIVersion: DWORD;
    lpAgentCaps: LPLINEAGENTCAPS): LONG;
    stdcall;

{$IFDEF Win32}
function lineGetAgentCapsA(                                {// TAPI v2.0}
    hLineApp: HLINEAPP;
    dwDeviceID: DWORD;
    dwAddressID: DWORD;
    dwAppAPIVersion: DWORD;
    lpAgentCaps: LPLINEAGENTCAPS): LONG;
    stdcall;

function lineGetAgentCapsW(                                {// TAPI v2.0}
    hLineApp: HLINEAPP;
    dwDeviceID: DWORD;
    dwAddressID: DWORD;
    dwAppAPIVersion: DWORD;
    lpAgentCaps: LPLINEAGENTCAPS): LONG;
    stdcall;
{$ENDIF}

function lineGetAgentGroupList(                            {// TAPI v2.0}
    hLine: HLINE;
    dwAddressID: DWORD;
    lpAgentGroupList: LPLINEAGENTGROUPLIST): LONG;
    stdcall;

{$IFDEF Win32}
function lineGetAgentGroupListA(                           {// TAPI v2.0}
    hLine: HLINE;
    dwAddressID: DWORD;
    lpAgentGroupList: LPLINEAGENTGROUPLIST): LONG;
    stdcall;

function lineGetAgentGroupListW(                           {// TAPI v2.0}
    hLine: HLINE;
    dwAddressID: DWORD;
    lpAgentGroupList: LPLINEAGENTGROUPLIST): LONG;
    stdcall;
{$ENDIF}

function lineGetAgentStatus(                               {// TAPI v2.0}
    hLine: HLINE;
    dwAddressID: DWORD;
    lpAgentStatus: LPLINEAGENTSTATUS): LONG;
    stdcall;

{$IFDEF Win32}
function lineGetAgentStatusA(                              {// TAPI v2.0}
    hLine: HLINE;
    dwAddressID: DWORD;
    lpAgentStatus: LPLINEAGENTSTATUS): LONG;
    stdcall;

function lineGetAgentStatusW(                              {// TAPI v2.0}
    hLine: HLINE;
    dwAddressID: DWORD;
    lpAgentStatus: LPLINEAGENTSTATUS): LONG;
    stdcall;
{$ENDIF}
{$ENDIF}

function lineGetAppPriority(                               {// TAPI v1.4 :}
    lpszAppFilename: LPCSTR;
    dwMediaMode: DWORD;
    lpExtensionID: LPLINEEXTENSIONID;
    dwRequestMode: DWORD;
    lpExtensionName: LPVARSTRING;
    lpdwPriority: LPDWORD): LONG;
    stdcall;

{$IFDEF Win32}
function lineGetAppPriorityA(                              {// TAPI v1.4}
    lpszAppFilename: LPCSTR;
    dwMediaMode: DWORD;
    lpExtensionID: LPLINEEXTENSIONID;
    dwRequestMode: DWORD;
    lpExtensionName: LPVARSTRING;
    lpdwPriority: LPDWORD): LONG;
    stdcall;

function lineGetAppPriorityW(                              {// TAPI v1.4}
    lpszAppFilename: LPCWSTR;
    dwMediaMode: DWORD;
    lpExtensionID: LPLINEEXTENSIONID;
    dwRequestMode: DWORD;
    lpExtensionName: LPVARSTRING;
    lpdwPriority: LPDWORD): LONG;
    stdcall;
{$ENDIF}

function lineGetCallInfo(
    hCall: HCALL;
    lpCallInfo: LPLINECALLINFO): LONG;
    stdcall;

{$IFDEF Win32}
function lineGetCallInfoA(
    hCall: HCALL;
    lpCallInfo: LPLINECALLINFO): LONG;
    stdcall;

function lineGetCallInfoW(
    hCall: HCALL;
    lpCallInfo: LPLINECALLINFO): LONG;
    stdcall;
{$ENDIF}

function lineGetCallStatus(
    hCall: HCALL;
    lpCallStatus: LPLINECALLSTATUS): LONG;
    stdcall;

function lineGetConfRelatedCalls(
    hCall: HCALL;
    lpCallList: LPLINECALLLIST): LONG;
    stdcall;

function lineGetCountry(                                   {// TAPI v1.4}
    dwCountryID: DWORD;
    dwAPIVersion: DWORD;
    lpLineCountryList: LPLINECOUNTRYLIST): LONG;
    stdcall;

{$IFDEF Win32}
function lineGetCountryA(                                  {// TAPI v1.4}
    dwCountryID: DWORD;
    dwAPIVersion: DWORD;
    lpLineCountryList: LPLINECOUNTRYLIST): LONG;
    stdcall;

function lineGetCountryW(                                  {// TAPI v1.4}
    dwCountryID: DWORD;
    dwAPIVersion: DWORD;
    lpLineCountryList: LPLINECOUNTRYLIST): LONG;
    stdcall;
{$ENDIF}

function lineGetDevCaps(
    hLineApp: HLINEAPP;
    dwDeviceID: DWORD;
    dwAPIVersion: DWORD;
    dwExtVersion: DWORD;
    lpLineDevCaps: LPLINEDEVCAPS): LONG;
    stdcall;

{$IFDEF Win32}
function lineGetDevCapsA(
    hLineApp: HLINEAPP;
    dwDeviceID: DWORD;
    dwAPIVersion: DWORD;
    dwExtVersion: DWORD;
    lpLineDevCaps: LPLINEDEVCAPS): LONG;
    stdcall;

function lineGetDevCapsW(
    hLineApp: HLINEAPP;
    dwDeviceID: DWORD;
    dwAPIVersion: DWORD;
    dwExtVersion: DWORD;
    lpLineDevCaps: LPLINEDEVCAPS): LONG;
    stdcall;
{$ENDIF}

function lineGetDevConfig(
    dwDeviceID: DWORD;
    lpDeviceConfig: LPVARSTRING;
    lpszDeviceClass: LPCSTR): LONG;
    stdcall;

{$IFDEF Win32}
function lineGetDevConfigA(
    dwDeviceID: DWORD;
    lpDeviceConfig: LPVARSTRING;
    lpszDeviceClass: LPCSTR): LONG;
    stdcall;

function lineGetDevConfigW(
    dwDeviceID: DWORD;
    lpDeviceConfig: LPVARSTRING;
    lpszDeviceClass: LPCWSTR): LONG;
    stdcall;
{$ENDIF}

function lineGetNewCalls(
    hLine: HLINE;
    dwAddressID: DWORD;
    dwSelect: DWORD;
    lpCallList: LPLINECALLLIST): LONG;
    stdcall;

function lineGetIcon(
    dwDeviceID: DWORD;
    lpszDeviceClass: LPCSTR;
    lphIcon: LPHICON): LONG;
    stdcall;

{$IFDEF Win32}
function lineGetIconA(
    dwDeviceID: DWORD;
    lpszDeviceClass: LPCSTR;
    lphIcon: LPHICON): LONG;
    stdcall;

function lineGetIconW(
    dwDeviceID: DWORD;
    lpszDeviceClass: LPCWSTR;
    lphIcon: LPHICON): LONG;
    stdcall;
{$ENDIF}

function lineGetID(
    hLine: HLINE;
    dwAddressID: DWORD;
    hCall: HCALL;
    dwSelect: DWORD;
    lpDeviceID: LPVARSTRING;
    lpszDeviceClass: LPCSTR): LONG;
    stdcall;

{$IFDEF Win32}
function lineGetIDA(
    hLine: HLINE;
    dwAddressID: DWORD;
    hCall: HCALL;
    dwSelect: DWORD;
    lpDeviceID: LPVARSTRING;
    lpszDeviceClass: LPCSTR): LONG;
    stdcall;

function lineGetIDW(
    hLine: HLINE;
    dwAddressID: DWORD;
    hCall: HCALL;
    dwSelect: DWORD;
    lpDeviceID: LPVARSTRING;
    lpszDeviceClass: LPCWSTR): LONG;
    stdcall;
{$ENDIF}

function lineGetLineDevStatus(
    hLine: HLINE;
    lpLineDevStatus: LPLINEDEVSTATUS): LONG;
    stdcall;

{$IFDEF Win32}
function lineGetLineDevStatusA(
    hLine: HLINE;
    lpLineDevStatus: LPLINEDEVSTATUS): LONG;
    stdcall;

function lineGetLineDevStatusW(
    hLine: HLINE;
    lpLineDevStatus: LPLINEDEVSTATUS): LONG;
    stdcall;
{$ENDIF}

{$IFDEF Tapi_Ver20_ORGREATER}
function lineGetMessage(                                   {// TAPI v2.0}
    hLineApp: HLINEAPP;
    lpMessage: LPLINEMESSAGE;
    dwTimeout: DWORD): LONG;
    stdcall;
{$ENDIF}

function lineGetNumRings(
    hLine: HLINE;
    dwAddressID: DWORD;
    lpdwNumRings: LPDWORD): LONG;
    stdcall;

function lineGetProviderList(                              {// TAPI v1.4}
    dwAPIVersion: DWORD;
    lpProviderList: LPLINEPROVIDERLIST): LONG;
    stdcall;

{$IFDEF Win32}
function lineGetProviderListA(
    dwAPIVersion: DWORD;
    lpProviderList: LPLINEPROVIDERLIST): LONG;
    stdcall;

function lineGetProviderListW(
    dwAPIVersion: DWORD;
    lpProviderList: LPLINEPROVIDERLIST): LONG;
    stdcall;
{$ENDIF}

function lineGetRequest(
    hLineApp: HLINEAPP;
    dwRequestMode: DWORD;
    lpRequestBuffer: LPVOID): LONG;
    stdcall;

{$IFDEF Win32}
function lineGetRequestA(
    hLineApp: HLINEAPP;
    dwRequestMode: DWORD;
    lpRequestBuffer: LPVOID): LONG;
    stdcall;

function lineGetRequestW(
    hLineApp: HLINEAPP;
    dwRequestMode: DWORD;
    lpRequestBuffer: LPVOID): LONG;
    stdcall;
{$ENDIF}

function lineGetStatusMessages(
    hLine: HLINE;
    lpdwLineStates: LPDWORD;
    lpdwAddressStates: LPDWORD): LONG;
    stdcall;

function lineGetTranslateCaps(
    hLineApp: HLINEAPP;
    dwAPIVersion: DWORD;
    lpTranslateCaps: LPLINETRANSLATECAPS): LONG;
    stdcall;

{$IFDEF Win32}
function lineGetTranslateCapsA(
    hLineApp: HLINEAPP;
    dwAPIVersion: DWORD;
    lpTranslateCaps: LPLINETRANSLATECAPS): LONG;
    stdcall;

function lineGetTranslateCapsW(
    hLineApp: HLINEAPP;
    dwAPIVersion: DWORD;
    lpTranslateCaps: LPLINETRANSLATECAPS): LONG;
    stdcall;
{$ENDIF}

function lineHandoff(
    hCall: HCALL;
    lpszFileName: LPCSTR;
    dwMediaMode: DWORD): LONG;
    stdcall;

{$IFDEF Win32}
function lineHandoffA(
    hCall: HCALL;
    lpszFileName: LPCSTR;
    dwMediaMode: DWORD): LONG;
    stdcall;

function lineHandoffW(
    hCall: HCALL;
    lpszFileName: LPCWSTR;
    dwMediaMode: DWORD): LONG;
    stdcall;
{$ENDIF}

function lineHold(
    hCall: HCALL): LONG;
    stdcall;

function lineInitialize(
    lphLineApp: LPHLINEAPP;
    hInstance: HINST;
    lpfnCallback: TLINECALLBACK;
    lpszAppName: LPCSTR;
    lpdwNumDevs: LPDWORD): LONG;
    stdcall;

{!! JEDI:bchoate:1997-11-11: Reorganized the following section to
 match the original header file (the whole $IFDEF span). }

{$IFDEF Tapi_Ver20_ORGREATER}
function lineInitializeEx(                                 {// TAPI v2.0}
    lphLineApp: LPHLINEAPP;
    hInstance: HINST;
    lpfnCallback: TLINECALLBACK;
    lpszFriendlyAppName: LPCSTR;
    lpdwNumDevs: LPDWORD;
    lpdwAPIVersion: LPDWORD;
    lpLineInitializeExParams: LPLINEINITIALIZEEXPARAMS): LONG;
    stdcall;

{$IFDEF Win32}
function lineInitializeExA(                                {// TAPI v2.0}
    lphLineApp: LPHLINEAPP;
    hInstance: HINST;
    lpfnCallback: TLINECALLBACK;
    lpszFriendlyAppName: LPCSTR;
    lpdwNumDevs: LPDWORD;
    lpdwAPIVersion: LPDWORD;
    lpLineInitializeExParams: LPLINEINITIALIZEEXPARAMS): LONG;
    stdcall;

function lineInitializeExW(                                {// TAPI v2.0}
    lphLineApp: LPHLINEAPP;
    hInstance: HINST;
    lpfnCallback: TLINECALLBACK;
    lpszFriendlyAppName: LPCWSTR;
    lpdwNumDevs: LPDWORD;
    lpdwAPIVersion: LPDWORD;
    lpLineInitializeExParams: LPLINEINITIALIZEEXPARAMS): LONG;
    stdcall;
{$ENDIF}
{$ENDIF}

function lineMakeCall(
    hLine: HLINE;
    lphCall: LPHCALL;
    lpszDestAddress: LPCSTR;
    dwCountryCode: DWORD;
    const lpCallParams: LPLINECALLPARAMS): LONG;
    stdcall;

{$IFDEF Win32}
function lineMakeCallA(
    hLine: HLINE;
    lphCall: LPHCALL;
    lpszDestAddress: LPCSTR;
    dwCountryCode: DWORD;
    const lpCallParams: LPLINECALLPARAMS): LONG;
    stdcall;

function lineMakeCallW(
    hLine: HLINE;
    lphCall: LPHCALL;
    lpszDestAddress: LPCWSTR;
    dwCountryCode: DWORD;
    const lpCallParams: LPLINECALLPARAMS): LONG;
    stdcall;
{$ENDIF}

function lineMonitorDigits(
    hCall: HCALL;
    dwDigitModes: DWORD): LONG;
    stdcall;

function lineMonitorMedia(
    hCall: HCALL;
    dwMediaModes: DWORD): LONG;
    stdcall;

function lineMonitorTones(
    hCall: HCALL;
    const lpToneList: LPLINEMONITORTONE;
    dwNumEntries: DWORD): LONG;
    stdcall;

function lineNegotiateAPIVersion(
    hLineApp: HLINEAPP;
    dwDeviceID: DWORD;
    dwAPILowVersion: DWORD;
    dwAPIHighVersion: DWORD;
    lpdwAPIVersion: LPDWORD;
    lpExtensionID: LPLINEEXTENSIONID): LONG;
    stdcall;

function lineNegotiateExtVersion(
    hLineApp: HLINEAPP;
    dwDeviceID: DWORD;
    dwAPIVersion: DWORD;
    dwExtLowVersion: DWORD;
    dwExtHighVersion: DWORD;
    lpdwExtVersion: LPDWORD): LONG;
    stdcall;

function lineOpen(
    hLineApp: HLINEAPP;
    dwDeviceID: DWORD;
    lphLine: LPHLINE;
    dwAPIVersion: DWORD;
    dwExtVersion: DWORD;
    dwCallbackInstance: DWORD;
    dwPrivileges: DWORD;
    dwMediaModes: DWORD;
    const lpCallParams: LPLINECALLPARAMS): LONG;
    stdcall;

{$IFDEF Win32}
function lineOpenA(
    hLineApp: HLINEAPP;
    dwDeviceID: DWORD;
    lphLine: LPHLINE;
    dwAPIVersion: DWORD;
    dwExtVersion: DWORD;
    dwCallbackInstance: DWORD;
    dwPrivileges: DWORD;
    dwMediaModes: DWORD;
    const lpCallParams: LPLINECALLPARAMS): LONG;
    stdcall;

function lineOpenW(
    hLineApp: HLINEAPP;
    dwDeviceID: DWORD;
    lphLine: LPHLINE;
    dwAPIVersion: DWORD;
    dwExtVersion: DWORD;
    dwCallbackInstance: DWORD;
    dwPrivileges: DWORD;
    dwMediaModes: DWORD;
    const lpCallParams: LPLINECALLPARAMS): LONG;
    stdcall;
{$ENDIF}

function linePark(
    hCall: HCALL;
    dwParkMode: DWORD;
    lpszDirAddress: LPCSTR;
    lpNonDirAddress: LPVARSTRING): LONG;
    stdcall;

{$IFDEF Win32}
function lineParkA(
    hCall: HCALL;
    dwParkMode: DWORD;
    lpszDirAddress: LPCSTR;
    lpNonDirAddress: LPVARSTRING): LONG;
    stdcall;

function lineParkW(
    hCall: HCALL;
    dwParkMode: DWORD;
    lpszDirAddress: LPCWSTR;
    lpNonDirAddress: LPVARSTRING): LONG;
    stdcall;
{$ENDIF}

function linePickup(
    hLine: HLINE;
    dwAddressID: DWORD;
    lphCall: LPHCALL;
    lpszDestAddress: LPCSTR;
    lpszGroupID: LPCSTR): LONG;
    stdcall;

{$IFDEF Win32}
function linePickupA(
    hLine: HLINE;
    dwAddressID: DWORD;
    lphCall: LPHCALL;
    lpszDestAddress: LPCSTR;
    lpszGroupID: LPCSTR): LONG;
    stdcall;

function linePickupW(
    hLine: HLINE;
    dwAddressID: DWORD;
    lphCall: LPHCALL;
    lpszDestAddress: LPCWSTR;
    lpszGroupID: LPCWSTR): LONG;
    stdcall;
{$ENDIF}

function linePrepareAddToConference(
    hConfCall: HCALL;
    lphConsultCall: LPHCALL;
    const lpCallParams: LPLINECALLPARAMS): LONG;
    stdcall;

{$IFDEF Win32}
function linePrepareAddToConferenceA(
    hConfCall: HCALL;
    lphConsultCall: LPHCALL;
    const lpCallParams: LPLINECALLPARAMS): LONG;
    stdcall;

function linePrepareAddToConferenceW(
    hConfCall: HCALL;
    lphConsultCall: LPHCALL;
    const lpCallParams: LPLINECALLPARAMS): LONG;
    stdcall;
{$ENDIF}

{$IFDEF Tapi_Ver20_ORGREATER}
function lineProxyMessage(                                 {// TAPI v2.0}
    hLine: HLINE;
    hCall: HCALL;
    dwMsg: DWORD;
    dwParam1: DWORD;
    dwParam2: DWORD;
    dwParam3: DWORD): LONG;
    stdcall;

function lineProxyResponse(                                {// TAPI v2.0}
    hLine: HLINE;
    lpProxyRequest: LPLINEPROXYREQUEST;
    dwResult: DWORD): LONG;
    stdcall;
{$ENDIF}

function lineRedirect(
    hCall: HCALL;
    lpszDestAddress: LPCSTR;
    dwCountryCode: DWORD): LONG;
    stdcall;

{$IFDEF Win32}
function lineRedirectA(
    hCall: HCALL;
    lpszDestAddress: LPCSTR;
    dwCountryCode: DWORD): LONG;
    stdcall;

function lineRedirectW(
    hCall: HCALL;
    lpszDestAddress: LPCWSTR;
    dwCountryCode: DWORD): LONG;
    stdcall;
{$ENDIF}

function lineRegisterRequestRecipient(
    hLineApp: HLINEAPP;
    dwRegistrationInstance: DWORD;
    dwRequestMode: DWORD;
    bEnable: DWORD): LONG;
    stdcall;

function lineReleaseUserUserInfo(                          {// TAPI v1.4}
    hCall: HCALL): LONG;
    stdcall;

function lineRemoveFromConference(
    hCall: HCALL): LONG;
    stdcall;

function lineRemoveProvider(                               {// TAPI v1.4}
    dwPermanentProviderID: DWORD;
    hwndOwner: HWND): LONG;
    stdcall;

function lineSecureCall(
    hCall: HCALL): LONG;
    stdcall;

function lineSendUserUserInfo(
    hCall: HCALL;
    lpsUserUserInfo: LPCSTR;
    dwSize: DWORD): LONG;
    stdcall;

{$IFDEF Tapi_Ver20_ORGREATER}
function lineSetAgentActivity(                             {// TAPI v2.0}
    hLine: HLINE;
    dwAddressID: DWORD;
    dwActivityID: DWORD): LONG;
    stdcall;

function lineSetAgentGroup(                                {// TAPI v2.0}
    hLine: HLINE;
    dwAddressID: DWORD;
    lpAgentGroupList: LPLINEAGENTGROUPLIST): LONG;
    stdcall;

function lineSetAgentState(                                {// TAPI v2.0}
    hLine: HLINE;
    dwAddressID: DWORD;
    dwAgentState: DWORD;
    dwNextAgentState: DWORD): LONG;
    stdcall;
{$ENDIF}

function lineSetAppPriority(                               {// TAPI v1.4}
    lpszAppFilename: LPCSTR;
    dwMediaMode: DWORD;
    lpExtensionID: LPLINEEXTENSIONID;
    dwRequestMode: DWORD;
    lpszExtensionName: LPCSTR;
    dwPriority: DWORD): LONG;
    stdcall;

{$IFDEF Win32}
function lineSetAppPriorityA(                              {// TAPI v1.4}
    lpszAppFilename: LPCSTR;
    dwMediaMode: DWORD;
    lpExtensionID: LPLINEEXTENSIONID;
    dwRequestMode: DWORD;
    lpszExtensionName: LPCSTR;
    dwPriority: DWORD): LONG;
    stdcall;

function lineSetAppPriorityW(                              {// TAPI v1.4}
    lpszAppFilename: LPCWSTR;
    dwMediaMode: DWORD;
    lpExtensionID: LPLINEEXTENSIONID;
    dwRequestMode: DWORD;
    lpszExtensionName: LPCWSTR;
    dwPriority: DWORD): LONG;
    stdcall;
{$ENDIF}

function lineSetAppSpecific(
    hCall: HCALL;
    dwAppSpecific: DWORD): LONG;
    stdcall;

{$IFDEF Tapi_Ver20_ORGREATER}
function lineSetCallData(                                  {// TAPI v2.0}
    hCall: HCALL;
    lpCallData: LPVOID;
    dwSize: DWORD): LONG;
    stdcall;
{$ENDIF}

function lineSetCallParams(
    hCall: HCALL;
    dwBearerMode: DWORD;
    dwMinRate: DWORD;
    dwMaxRate: DWORD;
    const lpDialParams: LPLINEDIALPARAMS): LONG;
    stdcall;

function lineSetCallPrivilege(
    hCall: HCALL;
    dwCallPrivilege: DWORD): LONG;
    stdcall;

{$IFDEF Tapi_Ver20_ORGREATER}
function lineSetCallQualityOfService(                      {// TAPI v2.0}
    hCall: HCALL;
    lpSendingFlowspec: LPVOID;
    dwSendingFlowspecSize: DWORD;
    lpReceivingFlowspec: LPVOID;
    dwReceivingFlowspecSize: DWORD): LONG;
    stdcall;

function lineSetCallTreatment(                             {// TAPI v2.0}
    hCall: HCALL;
    dwTreatment: DWORD): LONG;
    stdcall;
{$ENDIF}

function lineSetCurrentLocation(
    hLineApp: HLINEAPP;
    dwLocation: DWORD): LONG;
    stdcall;

function lineSetDevConfig(
    dwDeviceID: DWORD;
    const lpDeviceConfig: LPVOID;
    dwSize: DWORD;
    lpszDeviceClass: LPCSTR): LONG;
    stdcall;

{$IFDEF Win32}
function lineSetDevConfigA(
    dwDeviceID: DWORD;
    const lpDeviceConfig: LPVOID;
    dwSize: DWORD;
    lpszDeviceClass: LPCSTR): LONG;
    stdcall;

function lineSetDevConfigW(
    dwDeviceID: DWORD;
    const lpDeviceConfig: LPVOID;
    dwSize: DWORD;
    lpszDeviceClass: LPCWSTR): LONG;
    stdcall;
{$ENDIF}

{$IFDEF Tapi_Ver20_ORGREATER}
function lineSetLineDevStatus(                             {// TAPI v2.0}
    hLine: HLINE;
    dwStatusToChange: DWORD;
    fStatus: DWORD): LONG;
    stdcall;
{$ENDIF}

function lineSetMediaControl(
    hLine: HLINE;
    dwAddressID: DWORD;
    hCall: HCALL;
    dwSelect: DWORD;
    const lpDigitList: LPLINEMEDIACONTROLDIGIT;
    dwDigitNumEntries: DWORD;
    const lpMediaList: LPLINEMEDIACONTROLMEDIA;
    dwMediaNumEntries: DWORD;
    const lpToneList: LPLINEMEDIACONTROLTONE;
    dwToneNumEntries: DWORD;
    const lpCallStateList: LPLINEMEDIACONTROLCALLSTATE;
    dwCallStateNumEntries: DWORD): LONG;
    stdcall;

function lineSetMediaMode(
    hCall: HCALL;
    dwMediaModes: DWORD): LONG;
    stdcall;

function lineSetNumRings(
    hLine: HLINE;
    dwAddressID: DWORD;
    dwNumRings: DWORD): LONG;
    stdcall;

function lineSetStatusMessages(
    hLine: HLINE;
    dwLineStates: DWORD;
    dwAddressStates: DWORD): LONG;
    stdcall;

function lineSetTerminal(
    hLine: HLINE;
    dwAddressID: DWORD;
    hCall: HCALL;
    dwSelect: DWORD;
    dwTerminalModes: DWORD;
    dwTerminalID: DWORD;
    bEnable: DWORD): LONG;
    stdcall;

function lineSetTollList(
    hLineApp: HLINEAPP;
    dwDeviceID: DWORD;
    lpszAddressIn: LPCSTR;
    dwTollListOption: DWORD): LONG;
    stdcall;

{$IFDEF Win32}
function lineSetTollListA(
    hLineApp: HLINEAPP;
    dwDeviceID: DWORD;
    lpszAddressIn: LPCSTR;
    dwTollListOption: DWORD): LONG;
    stdcall;

function lineSetTollListW(
    hLineApp: HLINEAPP;
    dwDeviceID: DWORD;
    lpszAddressInW: LPCWSTR;
    dwTollListOption: DWORD): LONG;
    stdcall;
{$ENDIF}

function lineSetupConference(
    hCall: HCALL;
    hLine: HLINE;
    lphConfCall: LPHCALL;
    lphConsultCall: LPHCALL;
    dwNumParties: DWORD;
    const lpCallParams: LPLINECALLPARAMS): LONG;
    stdcall;

{$IFDEF Win32}
function lineSetupConferenceA(
    hCall: HCALL;
    hLine: HLINE;
    lphConfCall: LPHCALL;
    lphConsultCall: LPHCALL;
    dwNumParties: DWORD;
    const lpCallParams: LPLINECALLPARAMS): LONG;
    stdcall;

function lineSetupConferenceW(
    hCall: HCALL;
    hLine: HLINE;
    lphConfCall: LPHCALL;
    lphConsultCall: LPHCALL;
    dwNumParties: DWORD;
    const lpCallParams: LPLINECALLPARAMS): LONG;
    stdcall;
{$ENDIF}

function lineSetupTransfer(
    hCall: HCALL;
    lphConsultCall: LPHCALL;
    const lpCallParams: LPLINECALLPARAMS): LONG;
    stdcall;

{$IFDEF Win32}
function lineSetupTransferA(
    hCall: HCALL;
    lphConsultCall: LPHCALL;
    const lpCallParams: LPLINECALLPARAMS): LONG;
    stdcall;

function lineSetupTransferW(
    hCall: HCALL;
    lphConsultCall: LPHCALL;
    const lpCallParams: LPLINECALLPARAMS): LONG;
    stdcall;
{$ENDIF}

function lineShutdown(
    hLineApp: HLINEAPP): LONG;
    stdcall;

function lineSwapHold(
    hActiveCall: HCALL;
    hHeldCall: HCALL): LONG;
    stdcall;

function lineTranslateAddress(
    hLineApp: HLINEAPP;
    dwDeviceID: DWORD;
    dwAPIVersion: DWORD;
    lpszAddressIn: LPCSTR;
    dwCard: DWORD;
    dwTranslateOptions: DWORD;
    lpTranslateOutput: LPLINETRANSLATEOUTPUT): LONG;
    stdcall;

{$IFDEF Win32}
function lineTranslateAddressA(
    hLineApp: HLINEAPP;
    dwDeviceID: DWORD;
    dwAPIVersion: DWORD;
    lpszAddressIn: LPCSTR;
    dwCard: DWORD;
    dwTranslateOptions: DWORD;
    lpTranslateOutput: LPLINETRANSLATEOUTPUT): LONG;
    stdcall;

function lineTranslateAddressW(
    hLineApp: HLINEAPP;
    dwDeviceID: DWORD;
    dwAPIVersion: DWORD;
    lpszAddressIn: LPCWSTR;
    dwCard: DWORD;
    dwTranslateOptions: DWORD;
    lpTranslateOutput: LPLINETRANSLATEOUTPUT): LONG;
    stdcall;
{$ENDIF}

function lineTranslateDialog(                              {// TAPI v1.4}
    hLineApp: HLINEAPP;
    dwDeviceID: DWORD;
    dwAPIVersion: DWORD;
    hwndOwner: HWND;
    lpszAddressIn: LPCSTR): LONG;
    stdcall;

{$IFDEF Win32}
function lineTranslateDialogA(                             {// TAPI v1.4}
    hLineApp: HLINEAPP;
    dwDeviceID: DWORD;
    dwAPIVersion: DWORD;
    hwndOwner: HWND;
    lpszAddressIn: LPCSTR): LONG;
    stdcall;

function lineTranslateDialogW(
    hLineApp: HLINEAPP;
    dwDeviceID: DWORD;
    dwAPIVersion: DWORD;
    hwndOwner: HWND;
    lpszAddressIn: LPCWSTR): LONG;
    stdcall;
{$ENDIF}

function lineUncompleteCall(
    hLine: HLINE;
    dwCompletionID: DWORD): LONG;
    stdcall;

function lineUnhold(
    hCall: HCALL): LONG;
    stdcall;

function lineUnpark(
    hLine: HLINE;
    dwAddressID: DWORD;
    lphCall: LPHCALL;
    lpszDestAddress: LPCSTR): LONG;
    stdcall;

{$IFDEF Win32}
function lineUnparkA(
    hLine: HLINE;
    dwAddressID: DWORD;
    lphCall: LPHCALL;
    lpszDestAddress: LPCSTR): LONG;
    stdcall;

function lineUnparkW(
    hLine: HLINE;
    dwAddressID: DWORD;
    lphCall: LPHCALL;
    lpszDestAddress: LPCWSTR): LONG;
    stdcall;
{$ENDIF}

function phoneClose(
    hPhone: HPHONE): LONG;
    stdcall;

function phoneConfigDialog(
    dwDeviceID: DWORD;
    hwndOwner: HWND;
    lpszDeviceClass: LPCSTR): LONG;
    stdcall;

{$IFDEF Win32}
function phoneConfigDialogA(
    dwDeviceID: DWORD;
    hwndOwner: HWND;
    lpszDeviceClass: LPCSTR): LONG;
    stdcall;

function phoneConfigDialogW(
    dwDeviceID: DWORD;
    hwndOwner: HWND;
    lpszDeviceClass: LPCWSTR): LONG;
    stdcall;
{$ENDIF}

function phoneDevSpecific(
    hPhone: HPHONE;
    lpParams: LPVOID;
    dwSize: DWORD): LONG;
    stdcall;

function phoneGetButtonInfo(
    hPhone: HPHONE;
    dwButtonLampID: DWORD;
    lpButtonInfo: LPPHONEBUTTONINFO): LONG;
    stdcall;

{$IFDEF Win32}
function phoneGetButtonInfoA(
    hPhone: HPHONE;
    dwButtonLampID: DWORD;
    lpButtonInfo: LPPHONEBUTTONINFO): LONG;
    stdcall;

function phoneGetButtonInfoW(
    hPhone: HPHONE;
    dwButtonLampID: DWORD;
    lpButtonInfo: LPPHONEBUTTONINFO): LONG;
    stdcall;
{$ENDIF}

function phoneGetData(
    hPhone: HPHONE;
    dwDataID: DWORD;
    lpData: LPVOID;
    dwSize: DWORD): LONG;
    stdcall;

function phoneGetDevCaps(
    hPhoneApp: HPHONEAPP;
    dwDeviceID: DWORD;
    dwAPIVersion: DWORD;
    dwExtVersion: DWORD;
    lpPhoneCaps: LPPHONECAPS): LONG;
    stdcall;

{$IFDEF Win32}
function phoneGetDevCapsA(
    hPhoneApp: HPHONEAPP;
    dwDeviceID: DWORD;
    dwAPIVersion: DWORD;
    dwExtVersion: DWORD;
    lpPhoneCaps: LPPHONECAPS): LONG;
    stdcall;

function phoneGetDevCapsW(
    hPhoneApp: HPHONEAPP;
    dwDeviceID: DWORD;
    dwAPIVersion: DWORD;
    dwExtVersion: DWORD;
    lpPhoneCaps: LPPHONECAPS): LONG;
    stdcall;
{$ENDIF}

function phoneGetDisplay(
    hPhone: HPHONE;
    lpDisplay: LPVARSTRING): LONG;
    stdcall;

function phoneGetGain(
    hPhone: HPHONE;
    dwHookSwitchDev: DWORD;
    lpdwGain: LPDWORD): LONG;
    stdcall;

function phoneGetHookSwitch(
    hPhone: HPHONE;
    lpdwHookSwitchDevs: LPDWORD): LONG;
    stdcall;

function phoneGetIcon(
    dwDeviceID: DWORD;
    lpszDeviceClass: LPCSTR;
    lphIcon: LPHICON): LONG;
    stdcall;

{$IFDEF Win32}
function phoneGetIconA(
    dwDeviceID: DWORD;
    lpszDeviceClass: LPCSTR;
    lphIcon: LPHICON): LONG;
    stdcall;

function phoneGetIconW(
    dwDeviceID: DWORD;
    lpszDeviceClass: LPCWSTR;
    lphIcon: LPHICON): LONG;
    stdcall;
{$ENDIF}

function phoneGetID(
    hPhone: HPHONE;
    lpDeviceID: LPVARSTRING;
    lpszDeviceClass: LPCSTR): LONG;
    stdcall;

{$IFDEF Win32}
function phoneGetIDA(
    hPhone: HPHONE;
    lpDeviceID: LPVARSTRING;
    lpszDeviceClass: LPCSTR): LONG;
    stdcall;

function phoneGetIDW(
    hPhone: HPHONE;
    lpDeviceID: LPVARSTRING;
    lpszDeviceClass: LPCWSTR): LONG;
    stdcall;
{$ENDIF}

function phoneGetLamp(
    hPhone: HPHONE;
    dwButtonLampID: DWORD;
    lpdwLampMode: LPDWORD): LONG;
    stdcall;

{$IFDEF Tapi_Ver20_ORGREATER}
function phoneGetMessage(                                  {// TAPI v2.0}
    hPhoneApp: HPHONEAPP;
    lpMessage: LPPHONEMESSAGE;
    dwTimeout: DWORD): LONG;
    stdcall;
{$ENDIF}

function phoneGetRing(
    hPhone: HPHONE;
    lpdwRingMode: LPDWORD;
    lpdwVolume: LPDWORD): LONG;
    stdcall;

function phoneGetStatus(
    hPhone: HPHONE;
    lpPhoneStatus: LPPHONESTATUS): LONG;
    stdcall;

{$IFDEF Win32}
function phoneGetStatusA(
    hPhone: HPHONE;
    lpPhoneStatus: LPPHONESTATUS): LONG;
    stdcall;

function phoneGetStatusW(
    hPhone: HPHONE;
    lpPhoneStatus: LPPHONESTATUS): LONG;
    stdcall;
{$ENDIF}

function phoneGetStatusMessages(
    hPhone: HPHONE;
    lpdwPhoneStates: LPDWORD;
    lpdwButtonModes: LPDWORD;
    lpdwButtonStates: LPDWORD): LONG;
    stdcall;

function phoneGetVolume(
    hPhone: HPHONE;
    dwHookSwitchDev: DWORD;
    lpdwVolume: LPDWORD): LONG;
    stdcall;

function phoneInitialize(
    lphPhoneApp: LPHPHONEAPP;
    hInstance: HINST;
    lpfnCallback: TPHONECALLBACK;
    lpszAppName: LPCSTR;
    lpdwNumDevs: LPDWORD): LONG;
    stdcall;

{!! JEDI:bchoate:1997-11-11: Reorganized the following section to
 match the original header file (the whole $IFDEF span). }

{$IFDEF Tapi_Ver20_ORGREATER}
function phoneInitializeEx(                                {// TAPI v2.0}
    lphPhoneApp: LPHPHONEAPP;
    hInstance: HINST;
    lpfnCallback: TPHONECALLBACK;
    lpszFriendlyAppName: LPCSTR;
    lpdwNumDevs: LPDWORD;
    lpdwAPIVersion: LPDWORD;
    lpPhoneInitializeExParams: LPPHONEINITIALIZEEXPARAMS): LONG;
    stdcall;

{$IFDEF Win32}
function phoneInitializeExA(                               {// TAPI v2.0}
    lphPhoneApp: LPHPHONEAPP;
    hInstance: HINST;
    lpfnCallback: TPHONECALLBACK;
    lpszFriendlyAppName: LPCSTR;
    lpdwNumDevs: LPDWORD;
    lpdwAPIVersion: LPDWORD;
    lpPhoneInitializeExParams: LPPHONEINITIALIZEEXPARAMS): LONG;
    stdcall;

function phoneInitializeExW(                               {// TAPI v2.0}
    lphPhoneApp: LPHPHONEAPP;
    hInstance: HINST;
    lpfnCallback: TPHONECALLBACK;
    lpszFriendlyAppName: LPCWSTR;
    lpdwNumDevs: LPDWORD;
    lpdwAPIVersion: LPDWORD;
    lpPhoneInitializeExParams: LPPHONEINITIALIZEEXPARAMS): LONG;
    stdcall;
{$ENDIF}
{$ENDIF}

function phoneNegotiateAPIVersion(
    hPhoneApp: HPHONEAPP;
    dwDeviceID: DWORD;
    dwAPILowVersion: DWORD;
    dwAPIHighVersion: DWORD;
    lpdwAPIVersion: LPDWORD;
    lpExtensionID: LPPHONEEXTENSIONID): LONG;
    stdcall;

function phoneNegotiateExtVersion(
    hPhoneApp: HPHONEAPP;
    dwDeviceID: DWORD;
    dwAPIVersion: DWORD;
    dwExtLowVersion: DWORD;
    dwExtHighVersion: DWORD;
    lpdwExtVersion: LPDWORD): LONG;
    stdcall;

function phoneOpen(
    hPhoneApp: HPHONEAPP;
    dwDeviceID: DWORD;
    lphPhone: LPHPHONE;
    dwAPIVersion: DWORD;
    dwExtVersion: DWORD;
    dwCallbackInstance: DWORD;
    dwPrivilege: DWORD): LONG;
    stdcall;

function phoneSetButtonInfo(
    hPhone: HPHONE;
    dwButtonLampID: DWORD;
    const lpButtonInfo: LPPHONEBUTTONINFO): LONG;
    stdcall;

{$IFDEF Win32}
function phoneSetButtonInfoA(
    hPhone: HPHONE;
    dwButtonLampID: DWORD;
    const lpButtonInfo: LPPHONEBUTTONINFO): LONG;
    stdcall;

function phoneSetButtonInfoW(
    hPhone: HPHONE;
    dwButtonLampID: DWORD;
    const lpButtonInfo: LPPHONEBUTTONINFO): LONG;
    stdcall;
{$ENDIF}

function phoneSetData(
    hPhone: HPHONE;
    dwDataID: DWORD;
    const lpData: LPVOID;
    dwSize: DWORD): LONG;
    stdcall;

function phoneSetDisplay(
    hPhone: HPHONE;
    dwRow: DWORD;
    dwColumn: DWORD;
    lpsDisplay: LPCSTR;
    dwSize: DWORD): LONG;
    stdcall;

function phoneSetGain(
    hPhone: HPHONE;
    dwHookSwitchDev: DWORD;
    dwGain: DWORD): LONG;
    stdcall;

function phoneSetHookSwitch(
    hPhone: HPHONE;
    dwHookSwitchDevs: DWORD;
    dwHookSwitchMode: DWORD): LONG;
    stdcall;

function phoneSetLamp(
    hPhone: HPHONE;
    dwButtonLampID: DWORD;
    dwLampMode: DWORD): LONG;
    stdcall;

function phoneSetRing(
    hPhone: HPHONE;
    dwRingMode: DWORD;
    dwVolume: DWORD): LONG;
    stdcall;

function phoneSetStatusMessages(
    hPhone: HPHONE;
    dwPhoneStates: DWORD;
    dwButtonModes: DWORD;
    dwButtonStates: DWORD): LONG;
    stdcall;

function phoneSetVolume(
    hPhone: HPHONE;
    dwHookSwitchDev: DWORD;
    dwVolume: DWORD): LONG;
    stdcall;

function phoneShutdown(
    hPhoneApp: HPHONEAPP): LONG;
    stdcall;

function tapiGetLocationInfo(
    lpszCountryCode: LPSTR;
    lpszCityCode: LPSTR): LONG;
    stdcall;

{$IFDEF Win32}
function tapiGetLocationInfoA(
    lpszCountryCode: LPSTR;
    lpszCityCode: LPSTR): LONG;
    stdcall;

function tapiGetLocationInfoW(
    lpszCountryCodeW: LPWSTR;
    lpszCityCodeW: LPWSTR): LONG;
    stdcall;
{$ENDIF}

function tapiRequestDrop(
    hwnd: HWND;
    wRequestID: WPARAM): LONG;
    stdcall;

function tapiRequestMakeCall(
    lpszDestAddress: LPCSTR;
    lpszAppName: LPCSTR;
    lpszCalledParty: LPCSTR;
    lpszComment: LPCSTR): LONG;
    stdcall;

{$IFDEF Win32}
function tapiRequestMakeCallA(
    lpszDestAddress: LPCSTR;
    lpszAppName: LPCSTR;
    lpszCalledParty: LPCSTR;
    lpszComment: LPCSTR): LONG;
    stdcall;

function tapiRequestMakeCallW(
    lpszDestAddress: LPCWSTR;
    lpszAppName: LPCWSTR;
    lpszCalledParty: LPCWSTR;
    lpszComment: LPCWSTR): LONG;
    stdcall;
{$ENDIF}

function tapiRequestMediaCall(
    hwnd: HWND;
    wRequestID: WPARAM;
    lpszDeviceClass: LPCSTR;
    lpDeviceID: LPCSTR;
    dwSize: DWORD;
    dwSecure: DWORD;
    lpszDestAddress: LPCSTR;
    lpszAppName: LPCSTR;
    lpszCalledParty: LPCSTR;
    lpszComment: LPCSTR): LONG;
    stdcall;

{$IFDEF Win32}
function tapiRequestMediaCallA(
    hwnd: HWND;
    wRequestID: WPARAM;
    lpszDeviceClass: LPCSTR;
    lpDeviceID: LPCSTR;
    dwSize: DWORD;
    dwSecure: DWORD;
    lpszDestAddress: LPCSTR;
    lpszAppName: LPCSTR;
    lpszCalledParty: LPCSTR;
    lpszComment: LPCSTR): LONG;
    stdcall;

function tapiRequestMediaCallW(
    hwnd: HWND;
    wRequestID: WPARAM;
    lpszDeviceClass: LPCWSTR;
    lpDeviceID: LPCWSTR;
    dwSize: DWORD;
    dwSecure: DWORD;
    lpszDestAddress: LPCWSTR;
    lpszAppName: LPCWSTR;
    lpszCalledParty: LPCWSTR): LONG;
    stdcall;
{$ENDIF}

(*

TAPIERROR_FORMATMESSAGE - macro to convert a TAPI error constant
    into a constant that FormatMessage will accept

        TAPIERR: Negative numbers and 0
            Map to: strip off high WORD
            Example: 0xFFFFFFFF (-1) becomes 0x0000FFFF
        LINEERR: Start at 0x80000000
            Map to: strip off 0x80000000 and add 0xE000
            Example: 0x80000004 becomes 0x0000E004
        PHONEERR: Start at 0x90000000
            Map to: strip off 0x90000000 and add 0xF000
            Example: 0x9000000A becomes 0x0000F00A

        pseudocode:

        if (__ErrCode__ is a TAPIERR)
            strip off high word

            else if (__ErrCode__ is a PHONEERR)
                strip off 0x90000000
                add 0xE000

                else
                    strip off 0x80000000
                    add 0xF000

*)

function TAPIERROR_FORMATMESSAGE(ErrCode: INT): INT;

{!! Convenience functions added for Delphi: }

function TapiError(ResultCode: longint): Boolean;
  {-Returns True if ResultCode indicates an error; True if success }

procedure TapiCheck(ResultCode: longint);
  {-Raises an exception if ResultCode indicates an error }

{!!}

implementation

uses
  SysUtils;

const
{$IFDEF Win32}
  TapiDll = 'tapi32.dll';
{$ELSE}
  TapiDll = 'tapi.dll';
{$ENDIF}

function lineAccept; external TapiDll name 'lineAccept';

{$IFDEF UNICODE}
function lineAddProvider; external TapiDll name 'lineAddProviderW';
{$ELSE}
{$IFDEF Tapi_Ver20_ORGREATER}
function lineAddProvider; external TapiDll name 'lineAddProviderA';
{$ELSE}
function lineAddProvider; external TapiDll name 'lineAddProvider';
{$ENDIF}
{$ENDIF}

function lineAddToConference; external TapiDll name 'lineAddToConference';
{$IFDEF Tapi_Ver20_ORGREATER}
function lineAgentSpecific; external TapiDll name 'lineAgentSpecific';
{$ENDIF}
function lineAnswer; external TapiDll name 'lineAnswer';

{$IFDEF UNICODE}
function lineBlindTransfer; external TapiDll name 'lineBlindTransferW';
{$ELSE}
{$IFDEF Tapi_Ver20_ORGREATER}
function lineBlindTransfer; external TapiDll name 'lineBlindTransferA';
{$ELSE}
function lineBlindTransfer; external TapiDll name 'lineBlindTransfer';
{$ENDIF}
{$ENDIF}

function lineClose; external TapiDll name 'lineClose';
function lineCompleteCall; external TapiDll name 'lineCompleteCall';
function lineCompleteTransfer; external TapiDll name 'lineCompleteTransfer';

{$IFDEF UNICODE}
function lineConfigDialog; external TapiDll name 'lineConfigDialogW';
{$ELSE}
{$IFDEF Tapi_Ver20_ORGREATER}
function lineConfigDialog; external TapiDll name 'lineConfigDialogA';
{$ELSE}
function lineConfigDialog; external TapiDll name 'lineConfigDialog';
{$ENDIF}
{$ENDIF}

{$IFDEF UNICODE}
function lineConfigDialogEdit; external TapiDll name 'lineConfigDialogEditW';
{$ELSE}
{$IFDEF Tapi_Ver20_ORGREATER}
function lineConfigDialogEdit; external TapiDll name 'lineConfigDialogEditA';
{$ELSE}
function lineConfigDialogEdit; external TapiDll name 'lineConfigDialogEdit';
{$ENDIF}
{$ENDIF}

function lineConfigProvider; external TapiDll name 'lineConfigProvider';
function lineDeallocateCall; external TapiDll name 'lineDeallocateCall';
function lineDevSpecific; external TapiDll name 'lineDevSpecific';
function lineDevSpecificFeature; external TapiDll name 'lineDevSpecificFeature';

{$IFDEF UNICODE}
function lineDial; external TapiDll name 'lineDialW';
{$ELSE}
{$IFDEF Tapi_Ver20_ORGREATER}
function lineDial; external TapiDll name 'lineDialA';
{$ELSE}
function lineDial; external TapiDll name 'lineDial';
{$ENDIF}
{$ENDIF}
  
function lineDrop; external TapiDll name 'lineDrop';
  
{$IFDEF UNICODE}
function lineForward; external TapiDll name 'lineForwardW';
{$ELSE}
{$IFDEF Tapi_Ver20_ORGREATER}
function lineForward; external TapiDll name 'lineForwardA';
{$ELSE}
function lineForward; external TapiDll name 'lineForward';
{$ENDIF}
{$ENDIF}
  
{$IFDEF UNICODE}
function lineGatherDigits; external TapiDll name 'lineGatherDigitsW';
{$ELSE}
{$IFDEF Tapi_Ver20_ORGREATER}
function lineGatherDigits; external TapiDll name 'lineGatherDigitsA';
{$ELSE}
function lineGatherDigits; external TapiDll name 'lineGatherDigits';
{$ENDIF}
{$ENDIF}
  
{$IFDEF UNICODE}
function lineGenerateDigits; external TapiDll name 'lineGenerateDigitsW';
{$ELSE}
{$IFDEF Tapi_Ver20_ORGREATER}
function lineGenerateDigits; external TapiDll name 'lineGenerateDigitsA';
{$ELSE}
function lineGenerateDigits; external TapiDll name 'lineGenerateDigits';
{$ENDIF}
{$ENDIF}
  
function lineGenerateTone; external TapiDll name 'lineGenerateTone';
  
{$IFDEF UNICODE}
function lineGetAddressCaps; external TapiDll name 'lineGetAddressCapsW';
{$ELSE}
{$IFDEF Tapi_Ver20_ORGREATER}
function lineGetAddressCaps; external TapiDll name 'lineGetAddressCapsA';
{$ELSE}
function lineGetAddressCaps; external TapiDll name 'lineGetAddressCaps';
{$ENDIF}
{$ENDIF}
  
{$IFDEF UNICODE}
function lineGetAddressID; external TapiDll name 'lineGetAddressIDW';
{$ELSE}
{$IFDEF Tapi_Ver20_ORGREATER}
function lineGetAddressID; external TapiDll name 'lineGetAddressIDA';
{$ELSE}
function lineGetAddressID; external TapiDll name 'lineGetAddressID';
{$ENDIF}
{$ENDIF}
  
{$IFDEF UNICODE}
function lineGetAddressStatus; external TapiDll name 'lineGetAddressStatusW';
{$ELSE}
{$IFDEF Tapi_Ver20_ORGREATER}
function lineGetAddressStatus; external TapiDll name 'lineGetAddressStatusA';
{$ELSE}
function lineGetAddressStatus; external TapiDll name 'lineGetAddressStatus';
{$ENDIF}
{$ENDIF}
  
{$IFDEF Tapi_Ver20_ORGREATER}
{$IFDEF UNICODE}
function lineGetAgentStatus; external TapiDll name 'lineGetAgentStatusW';
{$ELSE}
function lineGetAgentStatus; external TapiDll name 'lineGetAgentStatusA';
{$ENDIF}

{$IFDEF UNICODE}
function lineGetAgentGroupList; external TapiDll name 'lineGetAgentGroupListW';
{$ELSE}
function lineGetAgentGroupList; external TapiDll name 'lineGetAgentGroupListA';
{$ENDIF}

{$IFDEF UNICODE}
function lineGetAgentCaps; external TapiDll name 'lineGetAgentCapsW';
{$ELSE}
function lineGetAgentCaps; external TapiDll name 'lineGetAgentCapsA';
{$ENDIF}
  
{$IFDEF UNICODE}
function lineGetAgentActivityList; external TapiDll name 'lineGetAgentActivityListW';
{$ELSE}
function lineGetAgentActivityList; external TapiDll name 'lineGetAgentActivityListA';
{$ENDIF}
{$ENDIF}

{$IFDEF UNICODE}
function lineGetAppPriority; external TapiDll name 'lineGetAppPriorityW';
{$ELSE}
{$IFDEF Tapi_Ver20_ORGREATER}
function lineGetAppPriority; external TapiDll name 'lineGetAppPriorityA';
{$ELSE}
function lineGetAppPriority; external TapiDll name 'lineGetAppPriority';
{$ENDIF}
{$ENDIF}
  
{$IFDEF UNICODE}
function lineGetCallInfo; external TapiDll name 'lineGetCallInfoW';
{$ELSE}
{$IFDEF Tapi_Ver20_ORGREATER}
function lineGetCallInfo; external TapiDll name 'lineGetCallInfoA';
{$ELSE}
function lineGetCallInfo; external TapiDll name 'lineGetCallInfo';
{$ENDIF}
{$ENDIF}
  
function lineGetCallStatus; external TapiDll name 'lineGetCallStatus';
function lineGetConfRelatedCalls; external TapiDll name 'lineGetConfRelatedCalls';

{$IFDEF UNICODE}
function lineGetCountry; external TapiDll name 'lineGetCountryW';
{$ELSE}
{$IFDEF Tapi_Ver20_ORGREATER}
function lineGetCountry; external TapiDll name 'lineGetCountryA';
{$ELSE}
function lineGetCountry; external TapiDll name 'lineGetCountry';
{$ENDIF}
{$ENDIF}
  
{$IFDEF UNICODE}
function lineGetDevCaps; external TapiDll name 'lineGetDevCapsW';
{$ELSE}
{$IFDEF Tapi_Ver20_ORGREATER}
function lineGetDevCaps; external TapiDll name 'lineGetDevCapsA';
{$ELSE}
function lineGetDevCaps; external TapiDll name 'lineGetDevCaps';
{$ENDIF}
{$ENDIF}
  
{$IFDEF UNICODE}
function lineGetDevConfig; external TapiDll name 'lineGetDevConfigW';
{$ELSE}
{$IFDEF Tapi_Ver20_ORGREATER}
function lineGetDevConfig; external TapiDll name 'lineGetDevConfigA';
{$ELSE}
function lineGetDevConfig; external TapiDll name 'lineGetDevConfig';
{$ENDIF}
{$ENDIF}
  
function lineGetNewCalls; external TapiDll name 'lineGetNewCalls';
  
{$IFDEF UNICODE}
function lineGetIcon; external TapiDll name 'lineGetIconW';
{$ELSE}
{$IFDEF Tapi_Ver20_ORGREATER}
function lineGetIcon; external TapiDll name 'lineGetIconA';
{$ELSE}
function lineGetIcon; external TapiDll name 'lineGetIcon';
{$ENDIF}
{$ENDIF}
  
{$IFDEF UNICODE}
function lineGetID; external TapiDll name 'lineGetIDW';
{$ELSE}
{$IFDEF Tapi_Ver20_ORGREATER}
function lineGetID; external TapiDll name 'lineGetIDA';
{$ELSE}
function lineGetID; external TapiDll name 'lineGetID';
{$ENDIF}
{$ENDIF}
  
{$IFDEF UNICODE}
function lineGetLineDevStatus; external TapiDll name 'lineGetLineDevStatusW';
{$ELSE}
{$IFDEF Tapi_Ver20_ORGREATER}
function lineGetLineDevStatus; external TapiDll name 'lineGetLineDevStatusA';
{$ELSE}
function lineGetLineDevStatus; external TapiDll name 'lineGetLineDevStatus';
{$ENDIF}
{$ENDIF}
  
{$IFDEF Tapi_Ver20_ORGREATER}
function lineGetMessage; external TapiDll name 'lineGetMessage';
{$ENDIF}
function lineGetNumRings; external TapiDll name 'lineGetNumRings';
  
{$IFDEF UNICODE}
function lineGetProviderList; external TapiDll name 'lineGetProviderListW';
{$ELSE}
{$IFDEF Tapi_Ver20_ORGREATER}
function lineGetProviderList; external TapiDll name 'lineGetProviderListA';
{$ELSE}
function lineGetProviderList; external TapiDll name 'lineGetProviderList';
{$ENDIF}
{$ENDIF}
  
{$IFDEF UNICODE}
function lineGetRequest; external TapiDll name 'lineGetRequestW';
{$ELSE}
{$IFDEF Tapi_Ver20_ORGREATER}
function lineGetRequest; external TapiDll name 'lineGetRequestA';
{$ELSE}
function lineGetRequest; external TapiDll name 'lineGetRequest';
{$ENDIF}
{$ENDIF}
  
function lineGetStatusMessages; external TapiDll name 'lineGetStatusMessages';
  
{$IFDEF UNICODE}
function lineGetTranslateCaps; external TapiDll name 'lineGetTranslateCapsW';
{$ELSE}
{$IFDEF Tapi_Ver20_ORGREATER}
function lineGetTranslateCaps; external TapiDll name 'lineGetTranslateCapsA';
{$ELSE}
function lineGetTranslateCaps; external TapiDll name 'lineGetTranslateCaps';
{$ENDIF}
{$ENDIF}
  
{$IFDEF UNICODE}
function lineHandoff; external TapiDll name 'lineHandoffW';
{$ELSE}
{$IFDEF Tapi_Ver20_ORGREATER}
function lineHandoff; external TapiDll name 'lineHandoffA';
{$ELSE}
function lineHandoff; external TapiDll name 'lineHandoff';
{$ENDIF}
{$ENDIF}
  
function lineHold; external TapiDll name 'lineHold';
function lineInitialize; external TapiDll name 'lineInitialize';
  
{$IFDEF Tapi_Ver20_ORGREATER}
{$IFDEF UNICODE}
function lineInitializeEx; external TapiDll name 'lineInitializeExW';
{$ELSE}
function lineInitializeEx; external TapiDll name 'lineInitializeExA';
{$ENDIF}
{$ENDIF}

{$IFDEF UNICODE}
function lineMakeCall; external TapiDll name 'lineMakeCallW';
{$ELSE}
{$IFDEF Tapi_Ver20_ORGREATER}
function lineMakeCall; external TapiDll name 'lineMakeCallA';
{$ELSE}
function lineMakeCall; external TapiDll name 'lineMakeCall';
{$ENDIF}
{$ENDIF}
  
function lineMonitorDigits; external TapiDll name 'lineMonitorDigits';
function lineMonitorMedia; external TapiDll name 'lineMonitorMedia';
function lineMonitorTones; external TapiDll name 'lineMonitorTones';
function lineNegotiateAPIVersion; external TapiDll name 'lineNegotiateAPIVersion';
function lineNegotiateExtVersion; external TapiDll name 'lineNegotiateExtVersion';
  
{$IFDEF UNICODE}
function lineOpen; external TapiDll name 'lineOpenW';
{$ELSE}
{$IFDEF Tapi_Ver20_ORGREATER}
function lineOpen; external TapiDll name 'lineOpenA';
{$ELSE}
function lineOpen; external TapiDll name 'lineOpen';
{$ENDIF}
{$ENDIF}
  
{$IFDEF UNICODE}
function linePark; external TapiDll name 'lineParkW';
{$ELSE}
{$IFDEF Tapi_Ver20_ORGREATER}
function linePark; external TapiDll name 'lineParkA';
{$ELSE}
function linePark; external TapiDll name 'linePark';
{$ENDIF}
{$ENDIF}
  
{$IFDEF UNICODE}
function linePickup; external TapiDll name 'linePickupW';
{$ELSE}
{$IFDEF Tapi_Ver20_ORGREATER}
function linePickup; external TapiDll name 'linePickupA';
{$ELSE}
function linePickup; external TapiDll name 'linePickup';
{$ENDIF}
{$ENDIF}
  
{$IFDEF UNICODE}
function linePrepareAddToConference; external TapiDll name 'linePrepareAddToConferenceW';
{$ELSE}
{$IFDEF Tapi_Ver20_ORGREATER}
function linePrepareAddToConference; external TapiDll name 'linePrepareAddToConferenceA';
{$ELSE}
function linePrepareAddToConference; external TapiDll name 'linePrepareAddToConference';
{$ENDIF}
{$ENDIF}

{$IFDEF Tapi_Ver20_ORGREATER}
function lineProxyMessage; external TapiDll name 'lineProxyMessage';
function lineProxyResponse; external TapiDll name 'lineProxyResponse';
{$ENDIF}

{$IFDEF UNICODE}
function lineRedirect; external TapiDll name 'lineRedirectW';
{$ELSE}
{$IFDEF Tapi_Ver20_ORGREATER}
function lineRedirect; external TapiDll name 'lineRedirectA';
{$ELSE}
function lineRedirect; external TapiDll name 'lineRedirect';
{$ENDIF}
{$ENDIF}
  
function lineRegisterRequestRecipient; external TapiDll name 'lineRegisterRequestRecipient';
function lineReleaseUserUserInfo; external TapiDll name 'lineReleaseUserUserInfo';
function lineRemoveFromConference; external TapiDll name 'lineRemoveFromConference';
function lineRemoveProvider; external TapiDll name 'lineRemoveProvider';
function lineSecureCall; external TapiDll name 'lineSecureCall';
function lineSendUserUserInfo; external TapiDll name 'lineSendUserUserInfo';
{$IFDEF Tapi_Ver20_ORGREATER}
function lineSetAgentActivity; external TapiDll name 'lineSetAgentActivity';
function lineSetAgentGroup; external TapiDll name 'lineSetAgentGroup';
function lineSetAgentState; external TapiDll name 'lineSetAgentState';
{$ENDIF}

{$IFDEF UNICODE}
function lineSetAppPriority; external TapiDll name 'lineSetAppPriorityW';
{$ELSE}
{$IFDEF Tapi_Ver20_ORGREATER}
function lineSetAppPriority; external TapiDll name 'lineSetAppPriorityA';
{$ELSE}
function lineSetAppPriority; external TapiDll name 'lineSetAppPriority';
{$ENDIF}
{$ENDIF}
  
function lineSetAppSpecific; external TapiDll name 'lineSetAppSpecific';
{$IFDEF Tapi_Ver20_ORGREATER}
function lineSetCallData; external TapiDll name 'lineSetCallData';
{$ENDIF}
function lineSetCallParams; external TapiDll name 'lineSetCallParams';
function lineSetCallPrivilege; external TapiDll name 'lineSetCallPrivilege';
{$IFDEF Tapi_Ver20_ORGREATER}
function lineSetCallQualityOfService; external TapiDll name 'lineSetCallQualityOfService';
function lineSetCallTreatment; external TapiDll name 'lineSetCallTreatment';
{$ENDIF}
function lineSetCurrentLocation; external TapiDll name 'lineSetCurrentLocation';
function lineSetDevConfig; external TapiDll name 'lineSetDevConfig';
{$IFDEF Tapi_Ver20_ORGREATER}
function lineSetLineDevStatus; external TapiDll name 'lineSetLineDevStatus';
{$ENDIF}
function lineSetMediaControl; external TapiDll name 'lineSetMediaControl';
function lineSetMediaMode; external TapiDll name 'lineSetMediaMode';
function lineSetNumRings; external TapiDll name 'lineSetNumRings';
function lineSetStatusMessages; external TapiDll name 'lineSetStatusMessages';
function lineSetTerminal; external TapiDll name 'lineSetTerminal';
function lineSetTollList; external TapiDll name 'lineSetTollList';
function lineSetupConference; external TapiDll name 'lineSetupConference';
function lineSetupTransfer; external TapiDll name 'lineSetupTransfer';
function lineShutdown; external TapiDll name 'lineShutdown';
function lineSwapHold; external TapiDll name 'lineSwapHold';
function lineTranslateAddress; external TapiDll name 'lineTranslateAddress';
function lineTranslateDialog; external TapiDll name 'lineTranslateDialog';
function lineUncompleteCall; external TapiDll name 'lineUncompleteCall';
function lineUnhold; external TapiDll name 'lineUnhold';
function lineUnpark; external TapiDll name 'lineUnpark';
function phoneClose; external TapiDll name 'phoneClose';
function phoneConfigDialog; external TapiDll name 'phoneConfigDialog';
function phoneDevSpecific; external TapiDll name 'phoneDevSpecific';
function phoneGetButtonInfo; external TapiDll name 'phoneGetButtonInfo';
function phoneGetData; external TapiDll name 'phoneGetData';
function phoneGetDevCaps; external TapiDll name 'phoneGetDevCaps';
function phoneGetDisplay; external TapiDll name 'phoneGetDisplay';
function phoneGetGain; external TapiDll name 'phoneGetGain';
function phoneGetHookSwitch; external TapiDll name 'phoneGetHookSwitch';
function phoneGetIcon; external TapiDll name 'phoneGetIcon';
function phoneGetID; external TapiDll name 'phoneGetID';
function phoneGetLamp; external TapiDll name 'phoneGetLamp';
{$IFDEF Tapi_Ver20_ORGREATER}
function phoneGetMessage; external TapiDll name 'phoneGetMessage';
{$ENDIF}
function phoneGetRing; external TapiDll name 'phoneGetRing';
function phoneGetStatus; external TapiDll name 'phoneGetStatus';
function phoneGetStatusMessages; external TapiDll name 'phoneGetStatusMessages';
function phoneGetVolume; external TapiDll name 'phoneGetVolume';
function phoneInitialize; external TapiDll name 'phoneInitialize';
{$IFDEF Tapi_Ver20_ORGREATER}
function phoneInitializeEx; external TapiDll name 'phoneInitializeEx';
{$ENDIF}
function phoneNegotiateAPIVersion; external TapiDll name 'phoneNegotiateAPIVersion';
function phoneNegotiateExtVersion; external TapiDll name 'phoneNegotiateExtVersion';
function phoneOpen; external TapiDll name 'phoneOpen';
function phoneSetButtonInfo; external TapiDll name 'phoneSetButtonInfo';
function phoneSetData; external TapiDll name 'phoneSetData';
function phoneSetDisplay; external TapiDll name 'phoneSetDisplay';
function phoneSetGain; external TapiDll name 'phoneSetGain';
function phoneSetHookSwitch; external TapiDll name 'phoneSetHookSwitch';
function phoneSetLamp; external TapiDll name 'phoneSetLamp';
function phoneSetRing; external TapiDll name 'phoneSetRing';
function phoneSetStatusMessages; external TapiDll name 'phoneSetStatusMessages';
function phoneSetVolume; external TapiDll name 'phoneSetVolume';
function phoneShutdown; external TapiDll name 'phoneShutdown';
function tapiGetLocationInfo; external TapiDll name 'tapiGetLocationInfo';
function tapiRequestDrop; external TapiDll name 'tapiRequestDrop';
function tapiRequestMakeCall; external TapiDll name 'tapiRequestMakeCall';
function tapiRequestMediaCall; external TapiDll name 'tapiRequestMediaCall';

{$IFDEF Win32}
function lineAddProviderA; external TapiDll name 'lineAddProvider';
function lineAddProviderW; external TapiDll name 'lineAddProviderW';
function lineBlindTransferA; external TapiDll name 'lineBlindTransfer';
function lineBlindTransferW; external TapiDll name 'lineBlindTransferW';
function lineConfigDialogA; external TapiDll name 'lineConfigDialog';
function lineConfigDialogW; external TapiDll name 'lineConfigDialogW';
function lineConfigDialogEditA; external TapiDll name 'lineConfigDialogEdit';
function lineConfigDialogEditW; external TapiDll name 'lineConfigDialogEditW';
function lineDialA; external TapiDll name 'lineDial';
function lineDialW; external TapiDll name 'lineDialW';
function lineForwardA; external TapiDll name 'lineForward';
function lineForwardW; external TapiDll name 'lineForwardW';
function lineGatherDigitsA; external TapiDll name 'lineGatherDigits';
function lineGatherDigitsW; external TapiDll name 'lineGatherDigitsW';
function lineGenerateDigitsA; external TapiDll name 'lineGenerateDigits';
function lineGenerateDigitsW; external TapiDll name 'lineGenerateDigitsW';
function lineGetAddressCapsA; external TapiDll name 'lineGetAddressCaps';
function lineGetAddressCapsW; external TapiDll name 'lineGetAddressCapsW';
function lineGetAddressIDA; external TapiDll name 'lineGetAddressID';
function lineGetAddressIDW; external TapiDll name 'lineGetAddressIDW';
function lineGetAddressStatusA; external TapiDll name 'lineGetAddressStatus';
function lineGetAddressStatusW; external TapiDll name 'lineGetAddressStatusW';
{$IFDEF Tapi_Ver20_ORGREATER}
function lineGetAgentActivityListA; external TapiDll name 'lineGetAgentActivityList';
function lineGetAgentActivityListW; external TapiDll name 'lineGetAgentActivityListW';
function lineGetAgentCapsA; external TapiDll name 'lineGetAgentCaps';
function lineGetAgentCapsW; external TapiDll name 'lineGetAgentCapsW';
function lineGetAgentGroupListA; external TapiDll name 'lineGetAgentGroupList';
function lineGetAgentGroupListW; external TapiDll name 'lineGetAgentGroupListW';
function lineGetAgentStatusA; external TapiDll name 'lineGetAgentStatus';
function lineGetAgentStatusW; external TapiDll name 'lineGetAgentStatusW';
{$ENDIF}
function lineGetAppPriorityA; external TapiDll name 'lineGetAppPriority';
function lineGetAppPriorityW; external TapiDll name 'lineGetAppPriorityW';
function lineGetCallInfoA; external TapiDll name 'lineGetCallInfo';
function lineGetCallInfoW; external TapiDll name 'lineGetCallInfoW';
function lineGetCountryA; external TapiDll name 'lineGetCountry';
function lineGetCountryW; external TapiDll name 'lineGetCountryW';
function lineGetDevCapsA; external TapiDll name 'lineGetDevCaps';
function lineGetDevCapsW; external TapiDll name 'lineGetDevCapsW';
function lineGetDevConfigA; external TapiDll name 'lineGetDevConfig';
function lineGetDevConfigW; external TapiDll name 'lineGetDevConfigW';
function lineGetIconA; external TapiDll name 'lineGetIcon';
function lineGetIconW; external TapiDll name 'lineGetIconW';
function lineGetIDA; external TapiDll name 'lineGetID';
function lineGetIDW; external TapiDll name 'lineGetIDW';
function lineGetLineDevStatusA; external TapiDll name 'lineGetLineDevStatus';
function lineGetLineDevStatusW; external TapiDll name 'lineGetLineDevStatusW';
function lineGetProviderListA; external TapiDll name 'lineGetProviderList';
function lineGetProviderListW; external TapiDll name 'lineGetProviderListW';
function lineGetRequestA; external TapiDll name 'lineGetRequest';
function lineGetRequestW; external TapiDll name 'lineGetRequestW';
function lineGetTranslateCapsA; external TapiDll name 'lineGetTranslateCaps';
function lineGetTranslateCapsW; external TapiDll name 'lineGetTranslateCapsW';
function lineHandoffA; external TapiDll name 'lineHandoff';
function lineHandoffW; external TapiDll name 'lineHandoffW';
{$IFDEF Tapi_Ver20_ORGREATER}
function lineInitializeExA; external TapiDll name 'lineInitializeEx';
function lineInitializeExW; external TapiDll name 'lineInitializeExW';
{$ENDIF}
function lineMakeCallA; external TapiDll name 'lineMakeCall';
function lineMakeCallW; external TapiDll name 'lineMakeCallW';
function lineOpenA; external TapiDll name 'lineOpen';
function lineOpenW; external TapiDll name 'lineOpenW';
function lineParkA; external TapiDll name 'linePark';
function lineParkW; external TapiDll name 'lineParkW';
function linePickupA; external TapiDll name 'linePickup';
function linePickupW; external TapiDll name 'linePickupW';
function linePrepareAddToConferenceA; external TapiDll name 'linePrepareAddToConference';
function linePrepareAddToConferenceW; external TapiDll name 'linePrepareAddToConferenceW';
function lineRedirectA; external TapiDll name 'lineRedirect';
function lineRedirectW; external TapiDll name 'lineRedirectW';
function lineSetAppPriorityA; external TapiDll name 'lineSetAppPriority';
function lineSetAppPriorityW; external TapiDll name 'lineSetAppPriorityW';
function lineSetDevConfigA; external TapiDll name 'lineSetDevConfig';
function lineSetDevConfigW; external TapiDll name 'lineSetDevConfigW';
function lineSetTollListA; external TapiDll name 'lineSetTollList';
function lineSetTollListW; external TapiDll name 'lineSetTollListW';
function lineSetupConferenceA; external TapiDll name 'lineSetupConference';
function lineSetupConferenceW; external TapiDll name 'lineSetupConferenceW';
function lineSetupTransferA; external TapiDll name 'lineSetupTransfer';
function lineSetupTransferW; external TapiDll name 'lineSetupTransferW';
function lineTranslateAddressA; external TapiDll name 'lineTranslateAddress';
function lineTranslateAddressW; external TapiDll name 'lineTranslateAddressW';
function lineTranslateDialogA; external TapiDll name 'lineTranslateDialog';
function lineTranslateDialogW; external TapiDll name 'lineTranslateDialogW';
function lineUnparkA; external TapiDll name 'lineUnpark';
function lineUnparkW; external TapiDll name 'lineUnparkW';
function phoneConfigDialogA; external TapiDll name 'phoneConfigDialog';
function phoneConfigDialogW; external TapiDll name 'phoneConfigDialogW';
function phoneGetButtonInfoA; external TapiDll name 'phoneGetButtonInfo';
function phoneGetButtonInfoW; external TapiDll name 'phoneGetButtonInfoW';
function phoneGetDevCapsA; external TapiDll name 'phoneGetDevCaps';
function phoneGetDevCapsW; external TapiDll name 'phoneGetDevCapsW';
function phoneGetIconA; external TapiDll name 'phoneGetIcon';
function phoneGetIconW; external TapiDll name 'phoneGetIconW';
function phoneGetIDA; external TapiDll name 'phoneGetID';
function phoneGetIDW; external TapiDll name 'phoneGetIDW';
function phoneGetStatusA; external TapiDll name 'phoneGetStatus';
function phoneGetStatusW; external TapiDll name 'phoneGetStatusW';
{$IFDEF Tapi_Ver20_ORGREATER}
function phoneInitializeExA; external TapiDll name 'phoneInitializeEx';
function phoneInitializeExW; external TapiDll name 'phoneInitializeExW';
{$ENDIF}
function phoneSetButtonInfoA; external TapiDll name 'phoneSetButtonInfo';
function phoneSetButtonInfoW; external TapiDll name 'phoneSetButtonInfoW';
function tapiGetLocationInfoA; external TapiDll name 'tapiGetLocationInfo';
function tapiGetLocationInfoW; external TapiDll name 'tapiGetLocationInfoW';
function tapiRequestMakeCallA; external TapiDll name 'tapiRequestMakeCall';
function tapiRequestMakeCallW; external TapiDll name 'tapiRequestMakeCallW';
function tapiRequestMediaCallA; external TapiDll name 'tapiRequestMediaCall';
function tapiRequestMediaCallW; external TapiDll name 'tapiRequestMediaCallW';
{$ENDIF}

function TAPIERROR_FORMATMESSAGE(ErrCode: INT): INT;
begin
  if ErrCode > $FFFF0000 then
    Result:=ErrCode and $FFFF
  else if ErrCode and $10000000 <> 0 then
    Result:=ErrCode - $90000000 + $F000
  else
    Result:=ErrCode - $80000000 + $F000
end;

function TapiError(ResultCode: longint): Boolean;
begin
  Result:=ResultCode < 0;
end;

procedure TapiCheck(ResultCode: longint);
var
  S: string;
begin
  if TapiError(ResultCode) then
    begin
      ResultCode:=TAPIERROR_FORMATMESSAGE(ResultCode);
      {$IFDEF Win32}
      S := SysErrorMessage(ResultCode);
      if ( S = '' ) then
        S := 'Error ' + IntToStr(ResultCode);
      {$ELSE}
      S := 'Error ' + IntToStr(ResultCode);
      {$ENDIF}
      raise Exception.Create('TAPI error: ' + S);
    end;
end;

end.