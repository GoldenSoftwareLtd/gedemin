unit inst_service_config2;

interface

uses
  Windows, WinSvc;

const
  SC_ACTION_NONE = 0;
  SC_ACTION_RESTART = 1;
  SC_ACTION_REBOOT = 2;
  SC_ACTION_RUN_COMMAND = 3;

  SERVICE_CONFIG_DESCRIPTION = 1;
  SERVICE_CONFIG_FAILURE_ACTIONS = 2;

  MAX_PROTOCOL_CHAIN = 100;
  WSAPROTOCOL_LEN = 255;

  WSANOTINITIALISED = 10093;

type
  SC_ACTION_TYPE = DWORD;

  PSCAction = ^TSCAction;
  {$EXTERNALSYM _SC_ACTION}
  _SC_ACTION = record
    _Type: SC_ACTION_TYPE;
    Delay: DWORD;
  end;
  SC_ACTION = _SC_ACTION;
  TSCAction = _SC_ACTION;

  TSCActionArray = array[0..2] of TSCAction;
  PSCActionArray = ^TSCActionArray;


  {$EXTERNALSYM _SERVICE_FAILURE_ACTIONS}
  _SERVICE_FAILURE_ACTIONS = record
    dwResetPeriod: DWORD;
    lpRebootMsg: PChar;
    lpCommand: PChar;
    cActions: DWORD;
    lpsaActions: PscAction;
  end;

  TSERVICE_FAILURE_ACTIONS = _SERVICE_FAILURE_ACTIONS;
  PSERVICE_FAILURE_ACTIONS = ^TSERVICE_FAILURE_ACTIONS;

  {$EXTERNALSYM _WSAPROTOCOLCHAIN}
  _WSAPROTOCOLCHAIN = record
    ChainLen: Integer;
    ChainEntries: array[1..MAX_PROTOCOL_CHAIN] of DWORD;
  end;

  {$EXTERNALSYM _WSAPROTOCOL_INFO}
  _WSAPROTOCOL_INFO = record
    dwServiceFlags1: DWORD;
    dwServiceFlags2: DWORD;
    dwServiceFlags3: DWORD;
    dwServiceFlags4: DWORD;
    dwProviderFlags: DWORD;
    ProviderId: TGUID;
    dwCatalogEntryId: DWORD;
    ProtocolChain: _WSAPROTOCOLCHAIN;
    iVersion: Integer;
    iAddressFamily: Integer;
    iMaxSockAddr: Integer;
    iMinSockAddr: Integer;
    iSocketType: Integer;
    iProtocol: Integer;
    iProtocolMaxOffset: Integer;
    iNetworkByteOrder: Integer;
    iSecurityScheme: Integer;
    dwMessageSize: DWORD;
    dwProviderReserved: DWORD;
    szProtocol: array[1..WSAPROTOCOL_LEN + 1] of CHAR;
  end;

  TWSAPROTOCOL_INFO = _WSAPROTOCOL_INFO;
  PWSAPROTOCOL_INFO = ^TWSAPROTOCOL_INFO;

(*{$EXTERNALSYM ChangeServiceConfig2A}
function ChangeServiceConfig2A(hService: SC_HANDLE; dwInfoLevel: DWORD;
  lpInfo: Pointer): BOOL; stdcall;
{$EXTERNALSYM ChangeServiceConfig2W}
function ChangeServiceConfig2W(hService: SC_HANDLE; dwInfoLevel: DWORD;
  lpInfo: Pointer): BOOL; stdcall;
{$EXTERNALSYM ChangeServiceConfig2}
function ChangeServiceConfig2(hService: SC_HANDLE; dwInfoLevel: DWORD;
  lpInfo: Pointer): BOOL; stdcall;

{$EXTERNALSYM QueryServiceConfig2}
function QueryServiceConfig2(hService: SC_HANDLE; dwInfoLevel: DWORD;
  lpBuffer: Pointer; cbBufSize: DWORD; pcbBytesNeeded: LPDWORD): BOOL; stdcall;
*)
implementation
(*
function ChangeServiceConfig2A;   external 'advapi32.dll' name 'ChangeServiceConfig2A';
function ChangeServiceConfig2W;   external 'advapi32.dll' name 'ChangeServiceConfig2W';
function ChangeServiceConfig2;   external 'advapi32.dll' name 'ChangeServiceConfig2A';
function QueryServiceConfig2;   external 'advapi32.dll' name 'QueryServiceConfig2A';*)

end.
