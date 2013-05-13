unit gsGdcBaseManager_unit;

interface

uses
  Comserv, ComObj, Gedemin_TLB;

type
  TgsGdcBaseManager = class(TAutoObject, IgsGdcBaseManager)
  protected
    function  Get_Database: IgsIBDatabase; safecall;
    function  Get_ReadTransaction: IgsIBTransaction; safecall;
    function  GetIDByRUID(XID: Integer; DBID: Integer): Integer; safecall;
    procedure GetRUIDByID(ID: Integer; var XID: OleVariant; var DBID: OleVariant); safecall;
    function  ProcessSQL(const S: WideString): WideString; safecall;
    function  AdjustMetaName(const S: WideString): WideString; safecall;
    procedure GetFullRUIDByID(ID: Integer; var XID: OleVariant; var DBID: OleVariant); safecall;
    function  GetNextID: Integer; safecall;
    function  GetIDByRUIDString(const RUIDStr: WideString): Integer; safecall;
    function  GetRUIDStringByID(ID: Integer): WideString; safecall;
    function  GetIDByRUIDTr(XID: Integer; DBID: Integer; const ibtr: IgsIBTransaction): Integer; safecall;
    procedure GetRUIDByIDTr(ID: Integer; var XID: OleVariant; var DBID: OleVariant;
                            const ibtr: IgsIBTransaction); safecall;
    function  GetIDByRUIDStringTr(const RUIDStr: WideString; const ibtr: IgsIBTransaction): Integer; safecall;
    function  GetRUIDStringByIDTr(ID: Integer; const ibtr: IgsIBTransaction): WideString; safecall;

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
  gdcBaseInterface, gdcOLEClassList, prp_methods, IBDatabase, classes, zlib;


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

procedure TgsGdcBaseManager.GetFullRUIDByID(ID: Integer; var XID,
  DBID: OleVariant);
var
  FXID, FDBID: TID;
begin
  if Assigned(gdcBaseManager) then
  begin
    gdcBaseManager.GetRUIDByID(ID, FXID, FDBID);
    XID := FXID;
    DBID := FDBID;
  end else
  begin
    XID := -1;
    DBID := -1;
  end;
end;

function TgsGdcBaseManager.GetIDByRUID(XID, DBID: Integer): Integer;
begin
  if Assigned(gdcBaseManager) then
    Result := gdcBaseManager.GetIDByRUID(XID, DBID)
  else
    Result := -1;
end;

function TgsGdcBaseManager.GetIDByRUIDString(
  const RUIDStr: WideString): Integer;
begin
  Result := gdcBaseManager.GetIDByRUIDString(RUIDStr);
end;

function TgsGdcBaseManager.GetIDByRUIDStringTr(const RUIDStr: WideString;
  const ibtr: IgsIBTransaction): Integer;
begin
  Result := gdcBaseManager.GetIDByRUIDString(RUIDStr, InterfaceToObject(ibtr) as TIBTransaction);
end;

function TgsGdcBaseManager.GetIDByRUIDTr(XID, DBID: Integer;
  const ibtr: IgsIBTransaction): Integer;
begin
  if Assigned(gdcBaseManager) then
    Result := gdcBaseManager.GetIDByRUID(XID, DBID, InterfaceToObject(ibtr) as TIBTransaction)
  else
    Result := -1;
end;

function TgsGdcBaseManager.GetNextID: Integer;
begin
  Result := gdcBaseManager.GetNextID;
end;

procedure TgsGdcBaseManager.GetRUIDByID(ID: Integer; var XID,
  DBID: OleVariant);
var
  FXID, FDBID: TID;
begin
  if Assigned(gdcBaseManager) then
  begin
    gdcBaseManager.GetRUIDByID(ID, FXID, FDBID);
    XID := FXID;
    DBID := FDBID;
  end else
  begin
    XID := -1;
    DBID := -1;
  end;
end;

procedure TgsGdcBaseManager.GetRUIDByIDTr(ID: Integer; var XID,
  DBID: OleVariant; const ibtr: IgsIBTransaction);
var
  FXID, FDBID: TID;
begin
  if Assigned(gdcBaseManager) then
  begin
    gdcBaseManager.GetRUIDByID(ID, FXID, FDBID, InterfaceToObject(ibtr) as TIBTransaction);
    XID := FXID;
    DBID := FDBID;
  end else
  begin
    XID := -1;
    DBID := -1;
  end;
end;

function TgsGdcBaseManager.GetRUIDStringByID(ID: Integer): WideString;
begin
  Result := gdcBaseManager.GetRUIDStringByID(ID);
end;

function TgsGdcBaseManager.GetRUIDStringByIDTr(ID: Integer;
  const ibtr: IgsIBTransaction): WideString;
begin
  Result := gdcBaseManager.GetRUIDStringByID(ID, InterfaceToObject(ibtr) as TIBTransaction);
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
