// ShlTanya, 26.02.2019

unit gsGdcBaseManager_unit;

interface

uses
  Comserv, ComObj, Gedemin_TLB, gdcBaseInterface;

type
  TgsGdcBaseManager = class(TAutoObject, IgsGdcBaseManager)
  protected
    function  Get_Database: IgsIBDatabase; safecall;
    function  Get_ReadTransaction: IgsIBTransaction; safecall;
    function  GetIDByRUID(XID: ATID; DBID: Integer): ATID; safecall;
    procedure GetRUIDByID(ID: ATID; var XID: OleVariant; var DBID: OleVariant); safecall;
    function  ProcessSQL(const S: WideString): WideString; safecall;
    function  AdjustMetaName(const S: WideString): WideString; safecall;
    procedure GetFullRUIDByID(Id: ATID; var XID: OleVariant; var DBID: OleVariant); safecall;
    function  GetNextID: ATID; safecall;
    function  GetIDByRUIDString(const RUIDStr: WideString): ATID; safecall;
    function  GetRUIDStringByID(ID: ATID): WideString; safecall;
    function  GetIDByRUIDTr(XID: ATID; DBID: Integer; const ibtr: IgsIBTransaction): ATID; safecall;
    procedure GetRUIDByIDTr(ID: ATID; var XID: OleVariant; var DBID: OleVariant;
                            const ibtr: IgsIBTransaction); safecall;
    function  GetIDByRUIDStringTr(const RUIDStr: WideString; const ibtr: IgsIBTransaction): ATID; safecall;
    function  GetRUIDStringByIDTr(ID: ATID; const ibtr: IgsIBTransaction): WideString; safecall;

    procedure PackStream(const SourceStream, DestStream: IgsStream; CompressionLevel: TgsZCompressionLevel); safecall;
    procedure UnPackStream(const SourceStream, DestStream: IgsStream); safecall;
    procedure ExecSingleQuery(const S: WideString; const Transaction: IgsIBTransaction); safecall;
    procedure ExecSingleQueryParam(const S: WideString; Param: OleVariant;
                                   const Transaction: IgsIBTransaction); safecall;
    procedure ExecSingleQueryResult(const S: WideString; Param: OleVariant; out Res: OleVariant;
                                    const Transaction: IgsIBTransaction); safecall;
    function ZCompressStr(const S: WideString): WideString; safecall;
    function ZDeCompressStr(const S: WideString): WideString; safecall;
  end;

implementation

uses
  gdcOLEClassList, prp_methods, IBDatabase, classes, zlib;


{ TgsGdcBaseManager }

function TgsGdcBaseManager.AdjustMetaName(const S: WideString): WideString;
begin
  if Assigned(gdcBaseManager) then
    Result := gdcBaseManager.AdjustMetaName(S)
  else
    Result := '';
end;

procedure TgsGdcBaseManager.ExecSingleQuery(const S: WideString;
  const Transaction: IgsIBTransaction);
begin
  if gdcBaseManager <> nil then
    gdcBaseManager.ExecSingleQuery(S, InterfaceToObject(Transaction) as TIBTransaction);
end;

procedure TgsGdcBaseManager.ExecSingleQueryParam(const S: WideString;
  Param: OleVariant; const Transaction: IgsIBTransaction);
begin
  if gdcBaseManager <> nil then
  begin
    gdcBaseManager.ExecSingleQuery(S, Param, InterfaceToObject(Transaction) as TIBTransaction);
  end;  
end;

procedure TgsGdcBaseManager.ExecSingleQueryResult(const S: WideString;
  Param: OleVariant; out Res: OleVariant;
  const Transaction: IgsIBTransaction);
begin
  if gdcBaseManager <> nil then
  begin
    gdcBaseManager.ExecSingleQueryResult(S, Param, Res,
      InterfaceToObject(Transaction) as TIBTransaction);
  end;    
end;

procedure TgsGdcBaseManager.GetFullRUIDByID(ID: ATID; var XID,
  DBID: OleVariant);
var
  FXID: TID;
  FDBID: Integer;
begin
  if Assigned(gdcBaseManager) then
  begin
    gdcBaseManager.GetRUIDByID(GetTID(ID), FXID, FDBID);
    XID := TID2V(FXID);
    DBID := FDBID;
  end else
  begin
    XID := -1;
    DBID := -1;
  end;
end;

function TgsGdcBaseManager.GetIDByRUID(XID: ATID; DBID: Integer): ATID;
begin
  if Assigned(gdcBaseManager) then
    Result := gdcBaseManager.GetIDByRUID(GetTID(XID), DBID)
  else
    Result := -1;
end;

function TgsGdcBaseManager.GetIDByRUIDString(
  const RUIDStr: WideString): ATID;
begin
  Result := gdcBaseManager.GetIDByRUIDString(RUIDStr);
end;

function TgsGdcBaseManager.GetIDByRUIDStringTr(const RUIDStr: WideString;
  const ibtr: IgsIBTransaction): ATID;
begin
  Result := gdcBaseManager.GetIDByRUIDString(RUIDStr, InterfaceToObject(ibtr) as TIBTransaction);
end;

function TgsGdcBaseManager.GetIDByRUIDTr(XID: ATID; DBID: Integer;
  const ibtr: IgsIBTransaction): ATID;
begin
  if Assigned(gdcBaseManager) then
    Result := gdcBaseManager.GetIDByRUID(GetTID(XID), DBID, InterfaceToObject(ibtr) as TIBTransaction)
  else
    Result := -1;
end;

function TgsGdcBaseManager.GetNextID: ATID;
begin
  Result := gdcBaseManager.GetNextID;
end;

procedure TgsGdcBaseManager.GetRUIDByID(ID: ATID; var XID,
  DBID: OleVariant);
var
  FXID: TID;
  FDBID: Integer;
begin
  if Assigned(gdcBaseManager) then
  begin
    gdcBaseManager.GetRUIDByID(GetTID(ID), FXID, FDBID);
    XID := TID2V(FXID);
    DBID := FDBID;
  end else
  begin
    XID := -1;
    DBID := -1;
  end;
end;

procedure TgsGdcBaseManager.GetRUIDByIDTr(ID: ATID; var XID,
  DBID: OleVariant; const ibtr: IgsIBTransaction);
var
  FXID: TID;
  FDBID: Integer;
begin
  if Assigned(gdcBaseManager) then
  begin
    gdcBaseManager.GetRUIDByID(GetTID(ID), FXID, FDBID, InterfaceToObject(ibtr) as TIBTransaction);
    XID := TID2V(FXID);
    DBID := FDBID;
  end else
  begin
    XID := -1;
    DBID := -1;
  end;
end;

function TgsGdcBaseManager.GetRUIDStringByID(ID: ATID): WideString;
begin
  Result := gdcBaseManager.GetRUIDStringByID(GetTID(ID));
end;

function TgsGdcBaseManager.GetRUIDStringByIDTr(ID: ATID;
  const ibtr: IgsIBTransaction): WideString;
begin
  Result := gdcBaseManager.GetRUIDStringByID(GetTID(ID), InterfaceToObject(ibtr) as TIBTransaction);
end;

function TgsGdcBaseManager.Get_Database: IgsIBDatabase;
begin
  Result := nil;
  if Assigned(gdcBaseManager) then
    Result := GetGdcOLEObject(gdcBaseManager.Database) as IgsIBDatabase;
end;

function TgsGdcBaseManager.Get_ReadTransaction: IgsIBTransaction;
begin
  Result := nil;
  if Assigned(gdcBaseManager) then
    Result := GetGdcOLEObject(gdcBaseManager.ReadTransaction) as IgsIBTransaction;
end;

procedure TgsGdcBaseManager.PackStream(const SourceStream, DestStream: IgsStream; CompressionLevel: TgsZCompressionLevel);
begin
  if Assigned(gdcBaseManager) then
    gdcBaseManager.PackStream(InterfaceToObject(SourceStream) as TStream,
           InterfaceToObject(DestStream) as TStream,
           TZCompressionLevel(CompressionLevel));
end;

function TgsGdcBaseManager.ProcessSQL(const S: WideString): WideString;
begin
  if Assigned(gdcBaseManager) then
    Result := gdcBaseManager.ProcessSQL(S)
  else
    Result := '';
end;

procedure TgsGdcBaseManager.UnPackStream(const SourceStream, DestStream: IgsStream);
begin
  if Assigned(gdcBaseManager) then
    gdcBaseManager.UnPackStream(InterfaceToObject(SourceStream) as TStream, InterfaceToObject(DestStream) as TStream);
end;

function TgsGdcBaseManager.ZCompressStr(const S: WideString): WideString;
begin
  Result := zlib.ZCompressStr(S, zcDefault);
end;

function TgsGdcBaseManager.ZDeCompressStr(const S: WideString): WideString;
begin
  Result := zlib.ZDecompressStr(S);
end;

initialization
  TAutoObjectFactory.Create(ComServer, TgsGdcBaseManager, CLASS_gs_GdcBaseManager,
    ciMultiInstance, tmApartment);
end.
