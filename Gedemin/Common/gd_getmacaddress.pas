// sources from here http://www.prestwood.com/ASPSuite/KB/Document_View.asp?QID=100258

unit gd_getmacaddress;

interface

uses
  Classes, SysUtils;

function Get_EthernetAddresses(SL: TStringList): Integer;

implementation

uses
  Windows;

const
  MAX_INTERFACE_NAME_LEN = $100;
  ERROR_SUCCESS          = 0;
  MAXLEN_IFDESCR         = $100;
  MAXLEN_PHYSADDR        = 8;

  MIB_IF_OPER_STATUS_NON_OPERATIONAL = 0 ;
  MIB_IF_OPER_STATUS_UNREACHABLE     = 1;
  MIB_IF_OPER_STATUS_DISCONNECTED    = 2;
  MIB_IF_OPER_STATUS_CONNECTING = 3;
  MIB_IF_OPER_STATUS_CONNECTED = 4;
  MIB_IF_OPER_STATUS_OPERATIONAL = 5;

  MIB_IF_TYPE_OTHER = 1;
  MIB_IF_TYPE_ETHERNET = 6;
  MIB_IF_TYPE_TOKENRING = 9;
  MIB_IF_TYPE_FDDI = 15;
  MIB_IF_TYPE_PPP = 23;
  MIB_IF_TYPE_LOOPBACK = 24;
  MIB_IF_TYPE_SLIP = 28;

  MIB_IF_ADMIN_STATUS_UP = 1;
  MIB_IF_ADMIN_STATUS_DOWN = 2;
  MIB_IF_ADMIN_STATUS_TESTING = 3;

type
  MIB_IFROW = record
    wszName: array[0..(MAX_INTERFACE_NAME_LEN * 2 - 1)] of AnsiChar;
    dwIndex: LongInt;
    dwType: LongInt;
    dwMtu: LongInt;
    dwSpeed: LongInt;
    dwPhysAddrLen: LongInt;
    bPhysAddr: array[0..(MAXLEN_PHYSADDR - 1)] of Byte;
    dwAdminStatus: LongInt;
    dwOperStatus: LongInt;
    dwLastChange: LongInt;
    dwInOctets: LongInt;
    dwInUcastPkts: LongInt;
    dwInNUcastPkts: LongInt;
    dwInDiscards: LongInt;
    dwInErrors: LongInt;
    dwInUnknownProtos: LongInt;
    dwOutOctets: LongInt;
    dwOutUcastPkts: LongInt;
    dwOutNUcastPkts: LongInt;
    dwOutDiscards: LongInt;
    dwOutErrors: LongInt;
    dwOutQLen: LongInt;
    dwDescrLen: LongInt;
    bDescr: array[0..(MAXLEN_IFDESCR - 1)] of AnsiChar;
  end;

  TGetIfTableFunction = function(pIfTable: Pointer; var pdwSize: LongInt; bOrder: LongInt): LongInt; stdcall;

var
  FLibrary: THandle;
  GetIfTable: TGetIfTableFunction;

function Get_EthernetAddresses(SL: TStringList): Integer;
const
  _MAX_ROWS_ = 20;

type
  _IfTable = Record
    nRows: LongInt;
    ifRow: array[1.._MAX_ROWS_] of MIB_IFROW;
  end;

var
  pIfTable: ^_IfTable;
  TableSize: LongInt;
  tmp: String;
  i, j: Integer;
  ErrCode: LongInt;
begin
  Assert(SL <> nil);

  SL.Clear;
  Result := 0;

  if FLibrary = 0 then
  begin
    FLibrary := LoadLibrary('IPHLPAPI.DLL');

    if (FLibrary > HINSTANCE_ERROR) then
    begin
      GetIfTable := GetProcAddress(FLibrary, 'GetIfTable');
      if not Assigned(GetIfTable) then
        RaiseLastWin32Error;
    end else
    begin
      FLibrary := 0;
      exit;
    end;
  end;

  pIfTable := nil;
  try
    //-------------------------------------------------------
    // First: just get the buffer size.
    // TableSize returns the size needed.
    TableSize := 0; // Set to zero so the GetIfTabel function
    // won't try to fill the buffer yet,
    // but only return the actual size it needs.
    GetIfTable(pIfTable, TableSize, 1);

    if (TableSize < SizeOf(MIB_IFROW) + Sizeof(LongInt)) then
    begin
      exit; // less than 1 table entry?!
    end;

    // Second:
    // allocate memory for the buffer and retrieve the
    // entire table.
    GetMem(pIfTable, TableSize);
    ErrCode := GetIfTable(pIfTable, TableSize, 1);
    if ErrCode <> ERROR_SUCCESS then
    begin
      exit; // OK, that did not work. Not enough memory i guess.
    end;

    // Read the ETHERNET addresses.
    for I := 1 to pIfTable^.nRows do
    begin
      if pIfTable^.ifRow[I].dwType = MIB_IF_TYPE_ETHERNET then
      begin
        tmp := '';
        for J := 0 to pIfTable^.ifRow[I].dwPhysAddrLen - 1 do
        begin
          tmp := tmp + Format('%.2x-', [pIfTable^.ifRow[I].bPhysAddr[J]]);
        end;
        if tmp > '' then
        begin
          SetLength(tmp, Length(tmp) - 1);
          if (SL.IndexOf(tmp) = -1) and (tmp <> '00-00-00-00-00-00') then
            SL.Add(tmp);
        end;
      end;
    end;
  finally
    if pIfTable <> nil then
      FreeMem(pIfTable, TableSize);
  end;

  Result := SL.Count;
end;

initialization
  FLibrary := 0;

finalization
  if FLibrary <> 0 then
  begin
    FreeLibrary(FLibrary);
    FLibrary := 0;
    GetIfTable := nil;
  end;
end.