{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  10327: IdSNMP.pas 
{
{   Rev 1.0    2002.11.12 10:51:42 PM  czhower
}
unit IdSNMP;

{
-2001.02.13 - Kudzu - Misc "Indy" Changes.
-Contributions also by: Hernan Sanchez (hernan.sanchez@iname.com)
-Original Author: Lukas Gebauer

The Synapse SNMP component was converted for use in INDY.

| The Original Code is Synapse Delphi Library.                                 |
|==============================================================================|
| The Initial Developer of the Original Code is Lukas Gebauer (Czech Republic).|
| Portions created by Lukas Gebauer are Copyright (c)2000.                     |
| All Rights Reserved.                                                         |
|==============================================================================|
| Contributor(s):                                                              |
|   Hernan Sanchez (hernan.sanchez@iname.com)  Original author                 |
|   Colin Wilson (colin@wilsonc.demon.co.uk)   Fixed some bugs & added support |
|                                              for Value types                 |
|==============================================================================|
| History: see HISTORY.HTM from distribution package                           |
|          (Found at URL: http://www.ararat.cz/synapse/)                       |
|==============================================================================}

interface

uses
  Classes,
  IdASN1Util,
  IdException,
  IdGlobal,
  IdUDPBase,
  IdUDPClient,
  IdSocketHandle;

const
  //PDU type
  PDUGetRequest=$a0;
  PDUGetNextRequest=$a1;
  PDUGetResponse=$a2;
  PDUSetRequest=$a3;
  PDUTrap=$a4;

  //errors
  ENoError=0;
  ETooBig=1;
  ENoSuchName=2;
  EBadValue=3;
  EReadOnly=4;
  EGenErr=5;

type
  TIdSNMP = class;

  TSNMPInfo = class(TObject)
  private
    fOwner : TIdSNMP;
    fCommunity: string;
    function GetValue (idx : Integer) : string;
    function GetValueCount: Integer;
    function GetValueType (idx : Integer) : Integer;
    function GetValueOID(idx: Integer): string;
    procedure SetCommunity(const Value: string);
  protected
    Buffer: string;
    procedure SyncMIB;
  public
    Host : string;
    Port : integer;
    Enterprise: string;
    GenTrap: integer;
    SpecTrap: integer;
    Version : integer;
    PDUType : integer;
    TimeTicks : integer;
    ID : integer;
    ErrorStatus : integer;
    ErrorIndex : integer;
    MIBOID : TStringList;
    MIBValue : TStringList;

    constructor Create (AOwner : TIdSNMP);
    destructor  Destroy; override;
    function    EncodeTrap: Boolean;
    function    DecodeTrap: Boolean;
    procedure   DecodeBuf(Buffer: string);
    function    EncodeBuf: string;
    procedure   Clear;
    procedure   MIBAdd(MIB, Value: string; ValueType: Integer = ASN1_OCTSTR);
    procedure   MIBDelete(Index: integer);
    function    MIBGet(MIB: string): string;

    property    Owner : TIdSNMP read fOwner;
    property    Community : string read fCommunity write SetCommunity;
    property    ValueCount : Integer read GetValueCount;
    property    Value [idx : Integer] : string read GetValue;
    property    ValueOID [idx : Integer] : string read GetValueOID;
    property    ValueType [idx : Integer] : Integer read GetValueType;
  end;

  TIdSNMP = class(TIdUDPClient)
  protected
    fCommunity: string;
    fTrapPort: Integer;
    fTrapRecvBinding: TIdSocketHandle;
    procedure SetCommunity(const Value: string);
    procedure SetTrapPort(const AValue: Integer);
    function GetBinding: TIdSocketHandle; override;
    procedure CloseBinding; override;
  public
    Query : TSNMPInfo;
    Reply : TSNMPInfo;
    Trap  : TSNMPInfo;

    constructor Create(aOwner : TComponent); override;
    destructor Destroy; override;
    function SendQuery : boolean;
    function QuickSend(const Mib, DestCommunity, DestHost:string; var Value:string):Boolean;
    function QuickSendTrap(const DestHost, Enterprise, DestCommunity: string;
                      DestPort, Generic, Specific: integer;
					  MIBName, MIBValue: TStringList): Boolean;
    function QuickReceiveTrap(var SrcHost, Enterprise, SrcCommunity: string;
                      var SrcPort, Generic, Specific, Seconds: integer;
					  MIBName, MIBValue: TStringList): Boolean;
    function SendTrap: Boolean;
    function ReceiveTrap: Boolean;
  published
    property Port default 161;
    property TrapPort : Integer read fTrapPort write SetTrapPort default 162;
    property Community : string read fCommunity write SetCommunity;
  end;

implementation

uses
  IdStack, IdStackConsts, SysUtils;

//Hernan Sanchez
function IPToID(Host: string): string;
var
  s, t: string;
  i, x: integer;
begin
  Result := '';    {Do not Localize}
  for x := 1 to 3 do
  begin
    t := '';    {Do not Localize}
    s := Copy(Host, IndyPos('.', Host), Length(Host));    {Do not Localize}
    t := Copy(Host, 1, (Length(Host) - Length(s)));
    Delete(Host, 1, (Length(Host) - Length(s) + 1));
    i := IndyStrToInt(t, 0);
    Result := Result + Chr(i);
  end;
  i := IndyStrToInt(Host, 0);
  Result := Result + Chr(i);
end;

function MibIntToASNObject(const OID: String; const Value: Integer; const ObjType: Integer = ASN1_INT): String;
  {$IFDEF USE_INLINE}inline;{$ENDIF}
begin
  Result := ASNObject(MibToID(OID), ASN1_OBJID) + ASNObject(ASNEncInt(Value), ObjType);
end;

function MibUIntToASNObject(const OID: String; const Value, ObjType: Integer): String;
  {$IFDEF USE_INLINE}inline;{$ENDIF}
begin
  Result := ASNObject(MibToID(OID), ASN1_OBJID) + ASNObject(ASNEncUInt(Value), ObjType);
end;

function MibObjIDToASNObject(const ObjID, Value: String): String;
  {$IFDEF USE_INLINE}inline;{$ENDIF}
begin
  Result := ASNObject(MibToID(ObjID), ASN1_OBJID) + ASNObject(MibToID(Value), ASN1_OBJID);
end;

function MibIPAddrToASNObject(const OID, Value: String): String;
  {$IFDEF USE_INLINE}inline;{$ENDIF}
begin
  Result := ASNObject(MibToID(OID), ASN1_OBJID) + ASNObject(IPToID(Value), ASN1_IPADDR);
end;

function MibNullToASNObject(const OID: String): String;
  {$IFDEF USE_INLINE}inline;{$ENDIF}
begin
  Result := ASNObject(MibToID(OID), ASN1_OBJID) + ASNObject('', ASN1_NULL); {Do not Localize}
end;

function MibStrToASNObject(const OID, Value: String; const ObjType: Integer = ASN1_OCTSTR): String;
  {$IFDEF USE_INLINE}inline;{$ENDIF}
begin
  Result := ASNObject(MibToID(OID), ASN1_OBJID) + ASNObject(Value, ObjType);
end;

{========================== SNMP INFO OBJECT ==================================}

{ TIdSNMPInfo }

(*----------------------------------------------------------------------------*
 | constructor TSNMPInfo.Create ()                                            |
 |                                                                            |
 | Constructor for TSNMPInfo                                                  |
 |                                                                            |
 | Parameters:                                                                |
 |   AOwner : TIdSNMP       The owning IdSNMP Component                       |
 |                                                                            |
 *----------------------------------------------------------------------------*)
constructor TSNMPInfo.Create(AOwner : TIdSNMP);
begin
  inherited Create;
  fOwner := AOwner;
  MIBOID := TStringList.Create;
  MIBValue := TStringList.Create;
  fCommunity := AOwner.Community;
  Port := AOwner.Port;
end;

(*----------------------------------------------------------------------------*
 | destructor TSNMPInfo.Destroy                                               |
 |                                                                            |
 | Destructor for TSNMPInfo                                                   |
 *----------------------------------------------------------------------------*)
destructor TSNMPInfo.Destroy;
begin
  FreeAndNil(MIBValue);
  FreeAndNil(MIBOID);
  inherited Destroy;
end;

(*----------------------------------------------------------------------------*
 | procedure TSNMPInfo.SyncMIB                                                |
 |                                                                            |
 | Ensure that there are as many 'values' as 'oids'                           |    {Do not Localize}
 *----------------------------------------------------------------------------*)
procedure TSNMPInfo.SyncMIB;
var
  n,x: integer;
begin
  x := MIBValue.Count;
  for n := x to MIBOID.Count-1 do begin
    MIBValue.Add('');    {Do not Localize}
  end;
end;

(*----------------------------------------------------------------------------*
 | procedure TSNMPInfo.DecodeBuf                                              |
 |                                                                            |
 | Decode an ASN buffer into version, community, MIB OID/Value pairs, etc.    |
 |                                                                            |
 | Parameters:                                                                |
 |   Buffer:string             The ASN buffer to decode                       |
 *----------------------------------------------------------------------------*)
procedure TSNMPInfo.DecodeBuf(Buffer: string);
var
  Pos: integer;
  endpos,vt: integer;
  sm,sv: string;
begin
  Pos := 2;
  Endpos := ASNDecLen(Pos, Buffer);
  Version := IndyStrToInt(ASNItem(Pos,Buffer,vt),0);
  Community := ASNItem(Pos,buffer,vt);
  PDUType := IndyStrToInt(ASNItem(Pos,Buffer,vt),0);
  ID := IndyStrToInt(ASNItem(Pos,Buffer,vt),0);
  ErrorStatus := IndyStrToInt(ASNItem(Pos,Buffer,vt),0);
  ErrorIndex := IndyStrToInt(ASNItem(Pos,Buffer,vt),0);
  ASNItem(Pos, Buffer, vt);
  while Pos < Endpos do           // Decode MIB/Value pairs
  begin
    ASNItem(Pos, Buffer, vt);
    Sm := ASNItem(Pos, Buffer, vt);
    Sv := ASNItem(Pos, Buffer, vt);
    MIBadd(sm, sv, vt);
  end;
end;

(*----------------------------------------------------------------------------*
 | function TSNMPInfo.EncodeBuf                                               |
 |                                                                            |
 | Encode the details into an ASN string                                      |
 |                                                                            |
 | The function returns the encoded ASN string                                |
 *----------------------------------------------------------------------------*)
function TSNMPInfo.EncodeBuf:string;
var
  data,s:string;
  n:integer;
  objType:Integer;
begin
  data:='';    {Do not Localize}
  SyncMIB;
  for n:=0 to MIBOID.Count-1 do
    begin
      objType := Integer (MIBValue.Objects[n]);
    if objType = 0 then begin
        objType := ASN1_OCTSTR;
    end;
    case objType of
      ASN1_INT:
        s := MibIntToASNObject(MIBOID[n], IndyStrToInt(MIBValue[n], 0));
      ASN1_COUNTER, ASN1_GAUGE, ASN1_TIMETICKS:
        s := MibUIntToASNObject(MIBOID[n], IndyStrToInt(MIBValue[n], 0), objType);
      ASN1_OBJID:
        s := MibObjIDToASNObject(MIBOID[n], MIBValue[n]);
      ASN1_IPADDR:
        s := MibIPAddrToASNObject(MIBOID[n], MIBValue[n]);
      ASN1_NULL:
        s := MibNullToASNObject(MIBOID[n]);
      else
        s := MibStrToASNObject(MIBOID[n], MIBValue[n], objType);
    end;
    data := data + ASNObject(s, ASN1_SEQ);
  end;
  data := ASNObject(char(ID), ASN1_INT)
         + ASNObject(char(ErrorStatus), ASN1_INT)
         + ASNObject(char(ErrorIndex), ASN1_INT)
         + ASNObject(data, ASN1_SEQ);
  data := ASNObject(char(Version), ASN1_INT)
         + ASNObject(Community, ASN1_OCTSTR)
         + ASNObject(data, PDUType);
  data := ASNObject(data, ASN1_SEQ);
  Result := data;
end;

(*----------------------------------------------------------------------------*
 | procedure TSNMPInfo.Clear                                                  |
 |                                                                            |
 | Clear the header info and  MIBOID/Value lists.                             |
 *----------------------------------------------------------------------------*)
procedure TSNMPInfo.Clear;
begin
  Version:=0;
  fCommunity := Owner.Community;
  if Self = fOwner.Trap then begin
    Port := Owner.TrapPort
  end else begin
    Port := Owner.Port;
  end;
  Host := Owner.Host;
  PDUType := 0;
  ID := 0;
  ErrorStatus := 0;
  ErrorIndex := 0;
  MIBOID.Clear;
  MIBValue.Clear;
end;

(*----------------------------------------------------------------------------*
 | procedure TSNMPInfo.MIBAdd                                                 |
 |                                                                            |
 | Add a MIBOID/Value pair                                                    |
 |                                                                            |
 | Parameters:                                                                |
 |  MIB  : string               The MIBOID to add                             |
 |  Value : string              The Value                                     |
 |  valueType : Integer         The Value's type.  Optional - defaults to     |    {Do not Localize}
 |                              ASN1_OCTSTR                                   |
 *----------------------------------------------------------------------------*)
procedure TSNMPInfo.MIBAdd(MIB, Value: string; ValueType: Integer);
var
  x: integer;
begin
  SyncMIB;
  MIBOID.Add(MIB);
  x := MIBOID.Count;
  if MIBValue.Count > x then
  begin
    MIBValue[x-1] := Value;
    MIBValue.Objects[x-1] := TObject(ValueType);
  end else 
  begin
    MIBValue.AddObject(Value, TObject(ValueType));
  end;  
end;

(*----------------------------------------------------------------------------*
 | procedure TSNMPInfo.MIBDelete                                              |
 |                                                                            |
 | Delete a MIBOID/Value pair                                                 |
 |                                                                            |
 | Parameters:                                                                |
 |   Index:integer                      The index of the pair to delete       |
 *----------------------------------------------------------------------------*)
procedure TSNMPInfo.MIBDelete(Index: integer);
begin
  SyncMIB;
  MIBOID.Delete(Index);
  if (MIBValue.Count-1) >= Index then begin
    MIBValue.Delete(Index);
  end;  
end;

(*----------------------------------------------------------------------------*
 | function TSNMPInfo.MIBGet                                                  |
 |                                                                            |
 | Get a string representation of tha value of the specified MIBOID           |
 |                                                                            |
 | Parameters:                                                                |
 |   MIB:string                         The MIBOID to query                   |
 |                                                                            |
 | The function returns the string representation of the value.               |
 *----------------------------------------------------------------------------*)
function TSNMPInfo.MIBGet(MIB: string): string;
var
  x: integer;
begin
  SyncMIB;
  x := MIBOID.IndexOf(MIB);
  if x < 0 then begin
    Result := '';    {Do not Localize}
  end else begin 
    Result := MIBValue[x];
  end;
end;

{======================= TRAPS =====================================}

(*----------------------------------------------------------------------------*
 | procedure TSNMPInfo.EncodeTrap                                             |
 |                                                                            |
 | Encode the trap details into an ASN string - the 'Buffer' member           |    {Do not Localize}
 |                                                                            |
 | The function returns 1 for historical reasons!                             |
 *----------------------------------------------------------------------------*)
function TSNMPInfo.EncodeTrap: Boolean;
var
  s: string;
  n: integer;
  objType: Integer;
begin
  Buffer := '';    {Do not Localize}
  for n := 0 to MIBOID.Count-1 do
  begin
    objType := Integer(MIBValue.Objects[n]);
    if objType = 0 then begin
      objType := ASN1_OCTSTR;
    end;
    case objType of
      ASN1_INT:
        s := MibIntToASNObject(MIBOID[n], IndyStrToInt(MIBValue[n], 0));
      ASN1_COUNTER, ASN1_GAUGE, ASN1_TIMETICKS:
        s := MibUIntToASNObject(MIBOID[n], IndyStrToInt(MIBValue[n], 0), objType);
      ASN1_OBJID:
        s := MibObjIDToASNObject(MIBOID[n], MIBValue[n]);
      ASN1_IPADDR:
        s := MibIPAddrToASNObject(MIBOID[n], MIBValue[n]);
      ASN1_NULL:
        s := MibNullToASNObject(MIBOID[n]);
      else
        s := MibStrToASNObject(MIBOID[n], MIBValue[n], objType);
    end;
    Buffer := Buffer + ASNObject(s, ASN1_SEQ);
  end;
  Buffer := ASNObject(MibToID(Enterprise), ASN1_OBJID)
    + ASNObject(IPToID(Host), ASN1_IPADDR)
    + ASNObject(ASNEncInt(GenTrap), ASN1_INT)
    + ASNObject(ASNEncInt(SpecTrap), ASN1_INT)
    + ASNObject(ASNEncInt(TimeTicks), ASN1_TIMETICKS)
    + ASNObject(Buffer, ASN1_SEQ);
  Buffer := ASNObject(Char(Version), ASN1_INT)
    + ASNObject(Community, ASN1_OCTSTR)
    + ASNObject(Buffer, PDUType);
  Buffer := ASNObject(Buffer, ASN1_SEQ);
  Result := True;
end;

(*----------------------------------------------------------------------------*
 | procedure TSNMPInfo.DecodeTrap                                             |
 |                                                                            |
 | Decode the 'Buffer' trap string to fil in our member variables.            |    {Do not Localize}
 |                                                                            |
 | The function returns 1.                                                    |
 *----------------------------------------------------------------------------*)
function TSNMPInfo.DecodeTrap: Boolean;
var
  Pos, EndPos, vt: integer;
  Sm, Sv: string;
begin
  Pos := 2;
  EndPos := ASNDecLen(Pos, Buffer);
  Version := IndyStrToInt(ASNItem(Pos, Buffer, vt), 0);
  Community := ASNItem(Pos, Buffer, vt);
  PDUType := IndyStrToInt(ASNItem(Pos, Buffer, vt), PDUTRAP);
  Enterprise := ASNItem(Pos, Buffer, vt);
  Host := ASNItem(Pos, Buffer, vt);
  GenTrap := IndyStrToInt(ASNItem(Pos, Buffer, vt), 0);
  Spectrap := IndyStrToInt(ASNItem(Pos, Buffer, vt), 0);
  TimeTicks := IndyStrToInt(ASNItem(Pos, Buffer, vt), 0);
  ASNItem(Pos, Buffer, vt);
  while Pos < EndPos do
  begin
    ASNItem(Pos, Buffer, vt);
    Sm := ASNItem(Pos, Buffer, vt);
    Sv := ASNItem(Pos, Buffer, vt);
    MIBAdd(Sm, Sv, vt);
  end;
  Result := True;
end;

(*----------------------------------------------------------------------------*
 | TSNMPInfo.SetCommunity                                                     |
 |                                                                            |
 | Set the community.                                                         |
 |                                                                            |
 | Parameters:                                                                |
 |   const Value: string        The new community value                       |
 *----------------------------------------------------------------------------*)
procedure TSNMPInfo.SetCommunity(const Value: string);
begin
  if fCommunity <> Value then
  begin
    Clear;
    fCommunity := Value;
  end;
end;

{ TIdSNMP }

{==============================  IdSNMP OBJECT ================================}


(*----------------------------------------------------------------------------*
 | constructor TIdSNMP.Create                                                 |
 |                                                                            |
 | Contructor for TIdSNMP component                                           |
 |                                                                            |
 | Parameters:                                                                |
 |   aOwner : TComponent                                                      |
 *----------------------------------------------------------------------------*)
constructor TIdSNMP.Create(aOwner : TComponent);
begin
  inherited;
  Port := 161;
  fTrapPort := 162;
  fCommunity := 'public';    {Do not Localize}
  Query:=TSNMPInfo.Create (Self);
  Reply:=TSNMPInfo.Create (Self);
  Trap :=TSNMPInfo.Create (Self);
  Query.Clear;
  Reply.Clear;
  Trap.Clear;
  FReceiveTimeout:=5000;
end;

(*----------------------------------------------------------------------------*
 |  destructor TIdSNMP.Destroy                                                |
 |                                                                            |
 |  Destructor for TIdSNMP component                                          |
 *----------------------------------------------------------------------------*)
destructor TIdSNMP.Destroy;
begin
  FreeAndNil(Reply);
  FreeAndNil(Query);
  FreeAndNil(Trap);
  inherited Destroy;
end;

(*----------------------------------------------------------------------------*
 | function TIdSNMP.GetBinding                                                |
 |                                                                            |
 | Prepare socket handles for use.                                            |
 *----------------------------------------------------------------------------*)
function TIdSNMP.GetBinding: TIdSocketHandle;
begin
  Result := inherited GetBinding;
  if fTrapRecvBinding = nil then begin
    fTrapRecvBinding := TIdSocketHandle.Create(nil);
  end;
  with fTrapRecvBinding do
  begin
    if (not HandleAllocated) and (fTrapPort <> 0) then begin
      {$IFDEF LINUX}
      AllocateSocket(LongInt(Id_SOCK_DGRAM));
      {$ELSE}
      AllocateSocket(Id_SOCK_DGRAM);
      {$ENDIF}
      IP := Self.Binding.IP;
      Port := fTrapPort;
      //IPVersion := Self.IPVersion;
      Bind;
    end;
  end;
end;

(*----------------------------------------------------------------------------*
 | procedure TIdSNMP.CloseBinding                                             |
 |                                                                            |
 | Clean up socket handles.                                                   |
 *----------------------------------------------------------------------------*)
procedure TIdSNMP.CloseBinding;
begin
  FreeAndNil(fTrapRecvBinding);
  inherited CloseBinding;
end;

(*----------------------------------------------------------------------------*
 | function TIdSNMP.SendQuery                                                 |
 |                                                                            |
 | Send an SNMP query and receive a reply.                                    |
 |                                                                            |
 | nb.  Before calling this, ensure that the following members are set:       |
 |                                                                            |
 |        Community         The SNMP community being queried - eg. 'public'   |    {Do not Localize}
 |        Host              The IP address being queried.  127.0.0.1 for the  |
 |                          local machine.                                    |
 |                                                                            |
 |      The call Query.Clear, then set:                                       |
 |                                                                            |
 |        Query.PDUType     PDUGetRequest to get a single set of MIBOID       |
 |                          value(s) or PDUGetNextRequest to start walking    |
 |                          the MIB                                           |
 |                                                                            |
 |      Next call Query.Clear, call MIBAdd to add the MIBOID(s) you require.  |
 |                                                                            |
 | The function returns True if a response was received.  IF a response was   |
 | received, it will be decoded into Reply.Value                              |
 *----------------------------------------------------------------------------*)
function TIdSNMP.SendQuery: Boolean;
begin
  Reply.Clear;
  Query.Buffer := Query.EncodeBuf;
  Send(Query.Host, Query.Port, Query.Buffer);
  try
    Reply.Buffer := ReceiveString(Query.Host, Query.Port, FReceiveTimeout );
  except
    on e : EIdSocketError do
    begin
      if e.LastError = 10054 then begin
        Reply.Buffer := '';    {Do not Localize}
      end else begin
        raise;
      end;
    end;
  end;

  if Reply.Buffer <> '' then begin
    Reply.DecodeBuf(Reply.Buffer);    {Do not Localize}
  end;
  Result := (Reply.Buffer <> '') and (Reply.ErrorStatus = 0);    {Do not Localize}
end;

(*----------------------------------------------------------------------------*
 | TIdSNMP.QuickSend                                                          |
 |                                                                            |
 | Query a single MIBOID value.                                               |
 |                                                                            |
 | Parameters:                                                                |
 |   Mib : string               The MIBOID to query                           |
 |   Community : string         The SNMP comunity                             |
 |   Host : string              The SNMP host                                 |
 |   var value : string         String representation of the returned value.  |
 |                                                                            |
 | The function returns true if a value was returned for the MIB OID          |
 *----------------------------------------------------------------------------*)
function TIdSNMP.QuickSend (const Mib, DestCommunity, DestHost: string; var Value: string): Boolean;
begin
  Community := DestCommunity;
  Host := DestHost;
  Query.Clear;
  Query.PDUType := PDUGetRequest;
  Query.MIBAdd(MIB, '');    {Do not Localize}
  Result := SendQuery;
  if Result then begin
    Value := Reply.MIBGet(MIB);
  end;
end;

(*----------------------------------------------------------------------------*
 | TIdSNMP.SendTrap                                                           |
 |                                                                            |
 | Send an SNMP trap.                                                         |
 |                                                                            |
 | The function returns 1                                                     |
 *----------------------------------------------------------------------------*)
function TIdSNMP.SendTrap: Boolean;
begin
  Trap.PDUType := PDUTrap;
  Trap.EncodeTrap;
  Send(Trap.Host, Trap.Port, Trap.Buffer);
  Result := True;
end;

function TIdSNMP.ReceiveTrap: Boolean;
var
  i, LMSec: Integer;
  LBuffer : string;   
begin
  Result := False;
  Trap.PDUType := PDUTrap;

  LMSec := ReceiveTimeOut;
  if (LMSec = IdTimeoutDefault) or (LMSec = 0) then begin
    LMSec := IdTimeoutInfinite;
  end;

  GetBinding; // make sure fTrapBinding is allocated
  SetLength(LBuffer, BufferSize);

  if not fTrapRecvBinding.Readable(LMSec) then begin
    Trap.Host := '';    {Do not Localize}
    Trap.Port := 0;
    Exit;
  end;
 
  i := fTrapRecvBinding.RecvFrom(LBuffer[1], BufferSize, 0, Trap.Host, Trap.Port);
  Trap.Buffer := Copy(LBuffer, 1, i);
  if Trap.Buffer <> '' then begin    {Do not Localize}
    Trap.DecodeTrap;
    Result := True;
  end;
end;

function TIdSNMP.QuickSendTrap(const DestHost, Enterprise, DestCommunity: string;
  DestPort, Generic, Specific: integer; MIBName, MIBValue: TStringList): Boolean;
var
  i: integer;
begin
  Trap.Host := DestHost;
  Trap.Port := DestPort;
  Trap.Community := DestCommunity;
  Trap.Enterprise := Enterprise;
  Trap.GenTrap := Generic;
  Trap.SpecTrap := Specific;
  for i := 0 to MIBName.Count-1 do
    Trap.MIBAdd(MIBName[i], MIBValue[i], Integer(MibValue.Objects [i]));
  Result := SendTrap;
end;

function TIdSNMP.QuickReceiveTrap(var SrcHost, Enterprise, SrcCommunity: string;
  var SrcPort, Generic, Specific, Seconds: integer;
  MIBName, MIBValue: TStringList): Boolean;
var
  i: integer;
begin
  Result := ReceiveTrap;
  if Result then
  begin
    SrcHost := Trap.Host;
    SrcPort := Trap.Port;
    Enterprise := Trap.Enterprise;
    SrcCommunity := Trap.Community;
    Generic := Trap.GenTrap;
    Specific := Trap.SpecTrap;
    Seconds := Trap.TimeTicks;
    MIBName.Clear;
    MIBValue.Clear;
    for i := 0 to Trap.MIBOID.Count-1 do
    begin
      MIBName.Add(Trap.MIBOID[i]);
      MIBValue.Add(Trap.MIBValue[i]);
    end;
  end;
end;

(*----------------------------------------------------------------------------*
 | TSNMPInfo.GetValue                                                         |
 |                                                                            |
 | Return string representation of value 'idx'                                |    {Do not Localize}
 |                                                                            |
 | Parameters:                                                                |
 |   idx : Integer              The value to get                              |
 |                                                                            |
 | The function returns the string representation of the value.               |
 *----------------------------------------------------------------------------*)
function TSNMPInfo.GetValue (idx : Integer) : string;
begin
  Result := MIBValue[idx];
end;

(*----------------------------------------------------------------------------*
 | TSNMPInfo.GetValueCount                                                    |
 |                                                                            |
 | Get the number of values.                                                  |
 |                                                                            |
 | The function returns the number of values.                                 |
 *----------------------------------------------------------------------------*)
function TSNMPInfo.GetValueCount: Integer;
begin
  Result := MIBValue.Count;
end;

(*----------------------------------------------------------------------------*
 | TSNMPInfo.GetValueType                                                     |
 |                                                                            |
 | Return the 'type' of value 'idx'                                           |    {Do not Localize}
 |                                                                            |
 | Parameters:                                                                |
 |   idx : Integer              The value type to get                         |
 |                                                                            |
 | The function returns the value type.                                       |
 *----------------------------------------------------------------------------*)
function TSNMPInfo.GetValueType (idx : Integer): Integer;
begin
  Result := Integer(MIBValue.Objects [idx]);
  if Result = 0 then begin
    Result := ASN1_OCTSTR;
  end;
end;

(*----------------------------------------------------------------------------*
 | TSNMPInfo.GetValueOID                                                      |
 |                                                                            |
 | Get the MIB OID for value 'idx'                                            |    {Do not Localize}
 |                                                                            |
 | Parameters:                                                                |
 |   idx: Integer               The MIB OID to gey                            |
 |                                                                            |
 | The function returns the specified MIB OID                                 |
 *----------------------------------------------------------------------------*)
function TSNMPInfo.GetValueOID(idx: Integer): string;
begin
  Result := MIBOID[idx];
end;

(*----------------------------------------------------------------------------*
 | TIdSNMP.SetCommunity                                                       |
 |                                                                            |
 | Setter for the Community property.                                         |
 |                                                                            |
 | Parameters:                                                                |
 |   const Value: string        The new community value                       |
 *----------------------------------------------------------------------------*)
procedure TIdSNMP.SetCommunity(const Value: string);
begin
  if fCommunity <> Value then
  begin
    fCommunity := Value;
    Query.Community := Value;
    Reply.Community := Value;
    Trap.Community := Value
  end
end;

(*----------------------------------------------------------------------------*
 | TIdSNMP.SetTrapPort                                                        |
 |                                                                            |
 | Setter for the TrapPort property.                                          |
 |                                                                            |
 | Parameters:                                                                |
 |   const Value: TIdPort       The new port value                            |
 *----------------------------------------------------------------------------*)
procedure TIdSNMP.SetTrapPort(const AValue: Integer);
begin
  if fTrapPort <> AValue then begin
    if Assigned(fTrapRecvBinding) then begin
      fTrapRecvBinding.CloseSocket;
    end;
    fTrapPort := AValue;
  end;
end;

end.
