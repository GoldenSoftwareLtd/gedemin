
{++

  Copyright (c) 2012-2016 by Golden Software of Belarus, Ltd

  Module

    gd_WebServerControl_unit.pas

  Abstract

    Gedemin web server engine.

  Author

  Revisions history

    1.00    01.01.12    flakekun        Initial version.

--}

unit gd_WebServerControl_unit;

interface

uses
  Classes, Windows, Contnrs, SyncObjs, evt_i_Base, gd_FileList_unit, IBDatabase,
  IdURI, IdHTTPServer, IdCustomHTTPServer, IdTCPServer, idThreadSafe, JclStrHashMap,
  gdMessagedThread, idHTTP, idComponent, IdHTTPHeaderInfo, IdHeaderList, gd_OData;

type
  TgdHiddenServer = class(TgdMessagedThread)
  private
    FHTTP: TidHTTP;
    FURI: TidURI;
    FRelayServer: String;
    FFakeRequestInfo: TIdHTTPRequestInfo;
    FFakeResponseInfo: TidHTTPResponseInfo;
    FProcessErrorCode: Integer;
    FProcessErrorMessage: String;
    FCompanyRUID: String;

    procedure DoOnWork(Sender: TObject; AWorkMode: TWorkMode; const AWorkCount: Integer);
    procedure ServerOnCommandGetSync;

  protected
    procedure Timeout; override;
    function ProcessMessage(var Msg: TMsg): Boolean; override;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Activate;
  end;

  TgdLockedList = class (TObjectList)
  private
    FCS: TCriticalSection;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Lock;
    procedure Unlock;
  end;

  TgdTableRelayRow = class(TObject)
  private
    FCompanyRuid, FAliases: String;

  public
    property Aliases: String read FAliases write FAliases;
    property CompanyRuid: String read FCompanyRuid write FCompanyRuid;
  end;

  TgdTableRelayRows = class(TgdLockedList)
  public
    procedure RefreshRows;
    function GetAliasesByRUID(const CompanyRuid: String): String;
    function GetRUIDByAlias(const Alias: String): String;
  end;

  TgdRelayServer = class(TObject)
  private
    FEvent, FResultReady: TEvent;
    FID: Integer;
    FAliases: TStringList;
    FState: Integer;
    FDataStream: TStream;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Cancel;
    function PrepareDataStream: TStream;

    property Event: TEvent read FEvent;
    property ResultReady: TEvent read FResultReady;
    property Aliases: TStringList read FAliases write FAliases;
    property ID: Integer read FID;
    property State: Integer read FState write FState;
    property DataStream: TStream read FDataStream write FDataStream;
  end;

  TgdRelayServers = class(TgdLockedList)
  public
    function AddAndLock: TgdRelayServer;
    function FindAndLock(const AnID: Integer): TgdRelayServer; overload;
    function FindAndLock(const AnAlias: String): TgdRelayServer; overload;
  end;

  TgdWebServerControl = class(TComponent)
  private
    FHttpServer: TIdHTTPServer;
    FHttpGetHandlerList: TObjectList;
    FVarParam: TVarParamEvent;
    FReturnVarParam: TVarParamEvent;
    FFileList: TObjectList;
    FRequestInfo: TIdHTTPRequestInfo;
    FResponseInfo: TIdHTTPResponseInfo;
    FLastToken: String;
    FInProcess: TidThreadSafeInteger;
    FUserSessions: TObjectList;
    FCS: TCriticalSection;
    FURI: TidURI;
    FRelayCS: TCriticalSection;
    FRelayServers: TgdRelayServers;
    FRelayServerActive: TidThreadSafeInteger;
    FgdHiddenServer: TgdHiddenServer;
    FTableRelayRows: TgdTableRelayRows;
    FgdoData: TgdOData;

    function GetVarInterface(const AnValue: Variant): OleVariant;
    function GetVarParam(const AnValue: Variant): OleVariant;

    procedure ServerOnCommandGet(AThread: TIdPeerThread;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure ServerOnCommandGetSync;
    procedure CreateHTTPServer;
    procedure ProcessQueryRequest;
    procedure ProcessFilesListRequest;
    procedure ProcessFileRequest;
    procedure ProcessBLOBRequest;
    procedure ProcessTestRequest;
    procedure ProcessLoginRequest;
    procedure ProcessLogoffRequest;
    procedure ProcessSendErrorRequest;
    procedure ProcessODataRoot;
    procedure ProcessODataMetadata;
    procedure ProcessODataEntitySet;
    procedure Log(const AnIPAddress: String; const AnOp: String;
      const Names: array of String; const Values: array of String); overload;
    procedure Log(const AnIPAddress: String; const AnOp: String;
      Params: TStrings); overload;
    function GetActive: Boolean;
    procedure SetActive(const Value: Boolean);
    function GetInProcess: Boolean;
    procedure DoneRelayServers;
    procedure ServerOnCreatePostStream(ASender: TIdPeerThread;
      var VPostStream: TStream);

    class procedure SaveHeaderInfoToStream(AHeader: TIdEntityHeaderInfo; S: TStream);
    class procedure ReadHeaderInfoFromStream(AHeader: TIdEntityHeaderInfo; S: TStream);
    class procedure SaveHeaderListToStream(AHeaderList: TIdHeaderList; S: TStream);
    class procedure ReadHeaderListFromStream(AHeaderList: TIdHeaderList; S: TStream);

  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    function GetFLCollection(const AnUpdateToken: String = ''): TFLCollection;

    class procedure SaveRequestInfoToStream(ARequest: TidHTTPRequestInfo; S: TStream);
    class procedure ReadRequestInfoFromStream(ARequest: TidHTTPRequestInfo; S: TStream);
    class procedure SaveResponseInfoToStream(AResponse: TidHTTPResponseInfo; S: TStream);
    class procedure ReadResponseInfoFromStream(AResponse: TidHTTPResponseInfo; S: TStream);

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure ActivateServer;
    procedure DeactivateServer;

    procedure RegisterOnGetEvent(const AComponent: TComponent;
      const AToken, AFunctionName: String);
    procedure UnRegisterOnGetEvent(const AComponent: TComponent);
    function GetBindings: String;
    function GetODataRoot: String;

    property Active: Boolean read GetActive write SetActive;
    property InProcess: Boolean read GetInProcess;
  end;

  TgdWebUserSession = class(TObject)
  private
    FTransaction: TIBTransaction;
    FID: String;
    FUserName: String;

  public
    constructor Create;
    destructor Destroy; override;

    function OpenSession(const AUserName, APassword: String): Boolean;

    property Transaction: TIBTransaction read FTransaction;
    property ID: String read FID;
    property UserName: String read FUserName;
  end;

var
  gdWebServerControl: TgdWebServerControl;

implementation

uses
  SysUtils, Forms, IBSQL, IdSocketHandle, gdcOLEClassList, gd_common_functions,
  gd_i_ScriptFactory, scr_i_FunctionList, rp_BaseReport_unit, gdcBaseInterface,
  prp_methods, Gedemin_TLB, Storages, WinSock, ComObj, JclSimpleXML, jclSysInfo,
  gd_directories_const, ActiveX, FileCtrl, gd_GlobalParams_unit, gdcJournal,
  gdNotifierThread_unit, gd_security, gd_messages_const, IdException;

type
  TgdHttpHandler = class(TObject)
  public
    Component: TComponent;
    Token: String;
    FunctionKey: Integer;
  end;

  TRelayServerResponseHeader = record
    Signature: Integer;
    Version: Integer;
    ID: Integer;
    Cmd: Integer;
    Size: Integer;
  end;

const
  PARAM_TOKEN                = 'token';

  RelayServerTimeout         = 20000;
  HiddenServerTimeout        = RelayServerTimeout + 10000;

  RelayServerStreamSignature = $56764696;
  RelayServerStreamVersion   = 1;

  rscmdQuery                 = 1;
  rscmdError                 = 2;
  rscmdResult                = 3;
  rscmdIdle                  = 4;
  rscmdReject                = 5;

  rssReady                   = 0;
  rssCanceled                = 1;
  rssResult                  = 2;
  rssData                    = 3;

var
  _RelayServersID: Integer;

{ TgdWebServerControl }

constructor TgdWebServerControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FHttpServer := nil;
  FHttpGetHandlerList := TObjectList.Create(True);
  FFileList := TObjectList.Create(True);
  FInProcess := TidThreadSafeInteger.Create;
  FUserSessions := TObjectList.Create(True);
  FCS := TCriticalSection.Create;
  FURI := TidURI.Create;
  FRelayCS := TCriticalSection.Create;
  FRelayServers := TgdRelayServers.Create;
  FRelayServerActive := TidThreadSafeInteger.Create;
  FTableRelayRows := TgdTableRelayRows.Create
end;

destructor TgdWebServerControl.Destroy;
begin
  FgdHiddenServer.Free;
  DoneRelayServers;
  inherited;
  FreeAndNil(FHttpServer);
  FreeAndNil(FHttpGetHandlerList);
  FreeAndNil(FFileList);
  FreeAndNil(FInProcess);
  FreeAndNil(FUserSessions);
  FCS.Free;
  FURI.Free;
  FRelayCS.Free;
  FRelayServers.Free;
  FRelayServerActive.Free;
  FTableRelayRows.Free;
  FgdOData.Free;
end;

procedure TgdWebServerControl.RegisterOnGetEvent(const AComponent: TComponent;
  const AToken, AFunctionName: String);

  function GetFunctionKey: Integer;
  var
    q: TIBSQL;
  begin
    Result := -1;

    q := TIBSQL.Create(nil);
    try
      q.Transaction := gdcBaseManager.ReadTransaction;

      if Assigned(AComponent) then
      begin
        q.SQL.Text :=
          ' SELECT f.id ' +
          ' FROM gd_function f ' +
          '   JOIN evt_object o ON o.id = f.modulecode AND o.name = :CN ' +
          ' WHERE f.name = :FN';
        q.ParamByName('CN').AsString := AComponent.Name;
        q.ParamByName('FN').AsString := AFunctionName;
        q.ExecQuery;
        if not q.Eof then
          Result := q.FieldByName('id').AsInteger;
      end;

      if Result = -1 then
      begin
        q.SQL.Text := 'SELECT id FROM gd_function WHERE name = :FN';
        q.ParamByName('FN').AsString := AFunctionName;
        q.ExecQuery;
        if not q.Eof then
          Result := q.FieldByName('id').AsInteger;
      end;

      if Result = -1 then
        raise Exception.Create('Фунция "' + AFunctionName + '" не найдена.');
    finally
      q.Free;
    end;
  end;

var
  HandlerCounter: Integer;
  Found: Boolean;
  Handler: TgdHttpHandler;
  FunctionKey: Integer;
begin
  Assert(FHTTPGetHandlerList <> nil);

  FunctionKey := GetFunctionKey;
  if FunctionKey > 0 then
  begin
    Found := False;

    for HandlerCounter := 0 to FHttpGetHandlerList.Count - 1 do
    begin
      Handler := FHttpGetHandlerList[HandlerCounter] as TgdHttpHandler;
      if AnsiCompareText(Handler.Token, AToken) = 0 then
      begin
        Handler.FunctionKey := FunctionKey;
        Found := True;
      end;
    end;

    if not Found then
    begin
      Handler := TgdHttpHandler.Create;
      Handler.Component := AComponent;
      Handler.Token := AToken;
      Handler.FunctionKey := FunctionKey;

      FHttpGetHandlerList.Add(Handler);

      if Assigned(AComponent) then
        AComponent.FreeNotification(Self);

      if gd_GlobalParams.GetWebServerActive then
        ActivateServer;
    end;
  end;
end;

procedure TgdWebServerControl.UnRegisterOnGetEvent(const AComponent: TComponent);
var
  I: Integer;
begin
  for I := FHttpGetHandlerList.Count - 1 downto 0 do
  begin
    if TgdHttpHandler(FHttpGetHandlerList[I]).Component = AComponent then
      FHttpGetHandlerList.Delete(I);
  end;

  if FHttpGetHandlerList.Count = 0 then
    DeactivateServer;
end;

procedure TgdWebServerControl.ServerOnCommandGet(AThread: TIdPeerThread;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);

  procedure SendResponse(const ACmd, AnID: Integer; AData: TStream);
  var
    HDR: TRelayServerResponseHeader;
    MS: TMemoryStream;
  begin
    HDR.Signature := RelayServerStreamSignature;
    HDR.Version := RelayServerStreamVersion;
    HDR.Cmd := ACmd;
    HDR.ID := AnID;
    if AData <> nil then
      HDR.Size := AData.Size
    else
      HDR.Size := 0;
    MS := TMemoryStream.Create;
    MS.WriteBuffer(Hdr, SizeOf(Hdr));
    if HDR.Size > 0 then
      MS.CopyFrom(AData, 0);
    AResponseInfo.ResponseNo := 200;
    AResponseInfo.ContentType := 'application/octet-stream;';
    AResponseInfo.ContentStream := MS;
  end;

var
  RelayAlias, CompanyRuid: String;
  RS: TgdRelayServer;
  Evt: TEvent;
  RSID: Integer;
  HDR: TRelayServerResponseHeader;
begin
  if ARequestInfo.Document = '/relay/ready' then
  begin
    CompanyRuid := ARequestInfo.Params.Values['company_ruid'];

    RelayAlias := FTableRelayRows.GetAliasesByRUID(CompanyRuid);

    if (FRelayServerActive.Value = 0) or (CompanyRuid = '') or (RelayAlias = '') then
    begin
      SendResponse(rscmdReject, 0, nil);
      exit;
    end;

    if gdNotifierThread <> nil then
      gdNotifierThread.Add('Hidden server ready "' + RelayAlias + '"', 0, 2000);

    RS := FRelayServers.AddAndLock;
    try
      RS.Aliases.CommaText := RelayAlias;
      Evt := RS.Event;
      RSID := RS.ID;
    finally
      FRelayServers.Unlock;
    end;

    Evt.WaitFor(RelayServerTimeout);

    RS := FRelayServers.FindAndLock(RSID);
    try
      if (RS = nil) or (RS.State = rssCanceled) then
      begin
        if gdNotifierThread <> nil then
          gdNotifierThread.Add('Reject response to hidden server "' + RelayAlias + '"', 0, 2000);

        SendResponse(rscmdReject, RSID, nil);
        FRelayServers.Remove(RS);
      end
      else if (RS.State = rssData) and (RS.DataStream <> nil) then
      begin
        if gdNotifierThread <> nil then
          gdNotifierThread.Add('Send request to hidden server "' + RelayAlias + '"', 0, 2000);

        SendResponse(rscmdQuery, RSID, RS.DataStream);
      end else
      begin
        if gdNotifierThread <> nil then
          gdNotifierThread.Add('Idle response to hidden server "' + RelayAlias + '"', 0, 2000);

        SendResponse(rscmdIdle, RSID, nil);
        FRelayServers.Remove(RS);
      end;
    finally
      FRelayServers.Unlock;
    end;
  end
  else if Pos('/relay/get', ARequestInfo.Document) = 1 then
  begin
    RelayAlias := ARequestInfo.Params.Values['alias'];

    if FRelayServerActive.Value = 0 then
    begin
      AResponseInfo.ContentText := '{"cl":"SyncHeader","params":{"error_code":"16"}}';
      exit;
    end;

    if RelayAlias = '' then
    begin
      AResponseInfo.ContentText := '{"cl":"SyncHeader","params":{"error_code":"17"}}';
      exit;
    end;

    CompanyRuid := FTableRelayRows.GetRUIDByAlias(RelayAlias);
    RS := FRelayServers.FindAndLock(RelayAlias);
    try
      if RS = nil then
      begin
        if CompanyRuid = '' then
          AResponseInfo.ContentText := '{"cl":"SyncHeader","params":{"error_code":"15"}}'
        else
          AResponseInfo.ContentText := '{"cl":"SyncHeader","params":{"error_code":"16"}}';
        exit;
      end;

      if gdNotifierThread <> nil then
        gdNotifierThread.Add('/relay/get "' + RelayAlias + '"', 0, 2000);

      RSID := RS.ID;
      ARequestInfo.Document := System.Copy(ARequestInfo.Document, Length('/relay/get') + 1, 8192);
      SaveRequestInfoToStream(ARequestInfo, RS.PrepareDataStream);
      RS.State := rssData;
      RS.Event.SetEvent;
      Evt := RS.ResultReady;
    finally
      FRelayServers.Unlock;
    end;

    Evt.WaitFor(RelayServerTimeout);

    RS := FRelayServers.FindAndLock(RSID);
    try
      if (RS = nil) or (RS.State <> rssResult) or (RS.DataStream = nil) then
        AResponseInfo.ContentText := '{"cl":"SyncHeader","params":{"error_code":"16"}}'
      else begin
        if gdNotifierThread <> nil then
          gdNotifierThread.Add('/relay/get result ready "' + RelayAlias + '"', 0, 2000);

        ReadResponseInfoFromStream(AResponseInfo, RS.DataStream);
      end;
      FRelayServers.Remove(RS);
    finally
      FRelayServers.Unlock;
    end;
  end
  else if ARequestInfo.Document = '/relay/result' then
  begin
    if ARequestInfo.PostStream <> nil then
    begin
      ARequestInfo.PostStream.Position := 0;
      ARequestInfo.PostStream.ReadBuffer(Hdr, SizeOf(Hdr));

      if (Hdr.Signature = RelayServerStreamSignature)
        and (Hdr.Version = RelayServerStreamVersion)
        and (Hdr.Cmd = rscmdResult)
        and (Hdr.Size > 0) then
      begin
        RS := FRelayServers.FindAndLock(Hdr.ID);
        try
          if (RS <> nil) and (RS.State = rssData) then
          begin
            if gdNotifierThread <> nil then
              gdNotifierThread.Add('Result received from hidden server "' + RS.Aliases.Text + '"', 0, 2000);

            RS.PrepareDataStream.CopyFrom(ARequestInfo.PostStream, Hdr.Size);
            RS.DataStream.Position := 0;
            RS.State := rssResult;
            RS.ResultReady.SetEvent;
          end else
            FRelayServers.Remove(RS);
        finally
          FRelayServers.Unlock;
        end;
        AResponseInfo.ContentText := 'ok';
      end else
        AResponseInfo.ContentText := 'invalid header';
    end else
      AResponseInfo.ContentText := 'no data stream';
    AResponseInfo.ContentType := 'text/plain; charset=Windows-1251';
  end else
  begin
    FInProcess.Value := 1;
    FCS.Enter;
    try
      FRequestInfo := ARequestInfo;
      FResponseInfo := AResponseInfo;
      AThread.Synchronize(ServerOnCommandGetSync);
    finally
      FInProcess.Value := 0;
      FCS.Leave;
    end;
  end;
end;

procedure TgdWebServerControl.ServerOnCommandGetSync;
var
  RequestToken, S, ConType: String;
  HandlerCounter: Integer;
  Handler: TgdHttpHandler;
  HandlerFunction: TrpCustomFunction;
  LParams, LResult: Variant;
  Processed: Boolean;
  I, P: Integer;
begin
  Assert(FHTTPGetHandlerList <> nil);

  try
    if Pos('/OData', FRequestInfo.Document) = 1 then
    begin
      if FgdOData = nil then
        FgdOData := TgdOData.Create;

      if (FRequestInfo.Document = ODataRoot) or (FRequestInfo.Document = ODataRoot + '/') then
        ProcessODataRoot
      else if FRequestInfo.Document = ODataRoot + '/$metadata' then
        ProcessODataMetadata
      else
        ProcessODataEntitySet;
    end else if AnsiCompareText(FRequestInfo.Document, '/query') = 0 then
      ProcessQueryRequest
    else if AnsiCompareText(FRequestInfo.Document, '/get_files_list') = 0 then
      ProcessFilesListRequest
    else if AnsiCompareText(FRequestInfo.Document, '/get_file') = 0 then
      ProcessFileRequest
    else if AnsiCompareText(FRequestInfo.Document, '/get_blob') = 0 then
      ProcessBLOBRequest
    else if AnsiCompareText(FRequestInfo.Document, '/test') = 0 then
      ProcessTestRequest
    else if AnsiCompareText(FRequestInfo.Document, '/login') = 0 then
      ProcessLoginRequest
    else if AnsiCompareText(FRequestInfo.Document, '/logoff') = 0 then
      ProcessLogoffRequest
    else if AnsiCompareText(FRequestInfo.Document, '/send_error') = 0 then
      ProcessSendErrorRequest
    else begin
      Processed := False;
      RequestToken := FRequestInfo.Params.Values[PARAM_TOKEN];
      for HandlerCounter := 0 to FHttpGetHandlerList.Count - 1 do
      begin
        Handler := FHttpGetHandlerList[HandlerCounter] as TgdHttpHandler;
        if (Handler.Token = '')
          or (AnsiCompareText(Handler.Token, RequestToken) = 0)
          or (AnsiCompareText(Handler.Token, FRequestInfo.Document) = 0) then
        begin
          HandlerFunction := glbFunctionList.FindFunction(Handler.FunctionKey);
          if Assigned(HandlerFunction) then
          begin
            if RequestToken > '' then
            begin
              Log(FRequestInfo.RemoteIP, 'TOKN', ['token'], [RequestToken]);
              if gdNotifierThread <> nil then
                gdNotifierThread.Add(FRequestInfo.RemoteIP + ' token=' + RequestToken, 0, 2000);
            end else
            begin
              Log(FRequestInfo.RemoteIP, 'DOCM', ['document'], [FRequestInfo.Document]);
              if gdNotifierThread <> nil then
                gdNotifierThread.Add(FRequestInfo.RemoteIP + ' ' + FRequestInfo.Document, 0, 2000);
            end;

            // Формирование списка параметров
            //  1 - компонент к которому привязан обработчик
            //  2 - параметры GET запроса
            //  3 - HTTP код ответа (byref)
            //  4 - текст ответа (byref)
            //  5 - данные POST запроса

            LParams := VarArrayOf([
              GetGdcOLEObject(Handler.Component) as IgsComponent,
              GetGdcOLEObject(FRequestInfo.Params) as IgsStrings,
              GetVarInterface(FResponseInfo.ResponseNo),
              GetVarInterface(FResponseInfo.ContentText),
              FRequestInfo.FormParams]);

            ScriptFactory.ExecuteFunction(HandlerFunction, LParams, LResult);
            FResponseInfo.ResponseNo := Integer(GetVarParam(LParams[2]));
            FResponseInfo.ContentText := String(GetVarParam(LParams[3]));

            ConType := Copy(FResponseInfo.ContentText, 1, 128);
            if Pos('<?xml', ConType) = 1 then
              FResponseInfo.ContentType := 'text/xml; charset=Windows-1251'
            else if Pos('<!DOCTYPE HTML', ConType) = 1 then
              FResponseInfo.ContentType := 'text/html; charset=Windows-1251'
            else if Pos('Content-Type:', ConType) = 1 then
            begin
              P := Pos(#13#10, ConType);
              if P > 0 then
              begin
                ConType := Trim(Copy(ConType, Length('Content-Type:') + 1, P - Length('Content-Type:') - 1));
                if Pos('charset=', ConType) = 0 then
                begin
                  if Copy(ConType, Length(ConType), 1) <> ';' then
                    ConType := ConType + ';';
                  FResponseInfo.ContentType := ConType + ' charset=Windows-1251';
                end else
                  FResponseInfo.ContentType := ConType;
                FResponseInfo.ContentText := Copy(FResponseInfo.ContentText, P + 2, MaxInt);
              end else
                FResponseInfo.ContentType := 'text/plain; charset=Windows-1251';
            end else
              FResponseInfo.ContentType := 'text/plain; charset=Windows-1251';
            Processed := True;
            Break;
          end;
        end
        else if (RequestToken > '') AND (HandlerCounter = FHttpGetHandlerList.Count - 1) then
        begin
          FResponseInfo.ResponseNo := 200;
          FResponseInfo.ContentType := 'text/html;';
          FResponseInfo.ContentText :=
            '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">'#13#10 +
            '<HTML><HEAD><TITLE>Gedemin Web Server</TITLE></HEAD><BODY>Unregistered token.</BODY></HTML>';
          Processed := True;
        end;
      end;

      if not Processed then
      begin
        {if FileExists(ExtractFilePath(Application.EXEName) + 'test.html') then
        begin
          SL := TStringList.Create;
          try
            SL.LoadFromFile(ExtractFilePath(Application.EXEName) + 'test.html');
            FResponseInfo.ResponseNo := 200;
            FResponseInfo.ContentType := 'text/html;';
            FResponseInfo.ContentText := SL.Text;
          finally
            SL.Free;
          end;
        end else}
        begin
          S := 'Gedemin Web Server.';
          S := S + '<br/>Copyright (c) 2016 by <a href="http://gsbelarus.com">Golden Software of Belarus, Ltd.</a>';
          S := S + '<br/>All rights reserved.';

          S := S + '<br/><br/>Now serving tokens:<ol>';
          for I := 0 to FFileList.Count - 1 do
          begin
            if (FFileList[I] as TFLCollection).FindItem('gedemin.exe') <> nil then
            begin
              S := S + '<li/>';
              if (FFileList[I] as TFLCollection).UpdateToken > '' then
                S := S + (FFileList[I] as TFLCollection).UpdateToken + ' - ';
              S := S + (FFileList[I] as TFLCollection).FindItem('gedemin.exe').Version;
            end;
          end;
          S := S + '</ol>';

          FResponseInfo.ResponseNo := 200;
          FResponseInfo.ContentType := 'text/html;';
          FResponseInfo.ContentText :=
            '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">'#13#10 +
            '<HTML><HEAD><TITLE>Gedemin Web Server</TITLE></HEAD><BODY>' + S + '</BODY></HTML>';
        end;
      end;
    end;
  except
    on E: Exception do
      TgdcJournal.AddEvent(E.Message, 'HTTPServer', -1, nil, True);
  end;
end;

function TgdWebServerControl.GetVarInterface(
  const AnValue: Variant): OleVariant;
begin
  if Assigned(FVarParam) then
    Result := FVarParam(AnValue)
  else
    Result := AnValue;
end;

function TgdWebServerControl.GetVarParam(
  const AnValue: Variant): OleVariant;
begin
  if Assigned(FReturnVarParam) then
    Result := FReturnVarParam(AnValue)
  else
    Result := AnValue;
end;

procedure TgdWebServerControl.Notification(AComponent: TComponent; Operation: TOperation);
var
  I: Integer;
begin
  Assert(FHTTPGetHandlerList <> nil);

  inherited;

  if Operation = Classes.opRemove then
  begin
    for I := FHttpGetHandlerList.Count - 1 downto 0 do
    begin
      if TgdHttpHandler(FHttpGetHandlerList[I]).Component = AComponent then
      begin
        AComponent.RemoveFreeNotification(Self);
        FHttpGetHandlerList.Delete(I);
      end;
    end;

    if FHttpGetHandlerList.Count = 0 then
      DeactivateServer;
  end;
end;

procedure TgdWebServerControl.ActivateServer;
begin
  if not Assigned(FHTTPServer) then
    CreateHTTPServer;

  if not FHTTPServer.Active then
    try
      if (FHTTPServer.Bindings.Count > 0) and
        ((FHTTPServer.Bindings[0] as TidSocketHandle).IP <> '0.0.0.0') then
      begin
        FHttpServer.Active := True;
      end;
    except
      on E: Exception do
        Application.MessageBox(
          PChar('При запуске HTTP сервера возникла ошибка:'#13#10 + E.Message),
          'Ошибка HTTP сервера',
          MB_OK + MB_TASKMODAL + MB_ICONEXCLAMATION);
    end;

  if FHTTPServer.Active then
  begin
    if (FgdHiddenServer = nil) and (gd_GlobalParams.GetRelayServer > '') then
    begin
      FgdHiddenServer := TgdHiddenServer.Create;
      FgdHiddenServer.Resume;
      FgdHiddenServer.Activate;
    end;

    FRelayServerActive.Value := 1;
    FTableRelayRows.RefreshRows;
  end;
end;

procedure TgdWebServerControl.DeactivateServer;
begin
  FreeAndNil(FgdHiddenServer);
  DoneRelayServers;
  if Assigned(FHTTPServer) then
    FHttpServer.Active := False;
end;

procedure TgdWebServerControl.CreateHTTPServer;
var
  Binding : TIdSocketHandle;
  PortNumber, I, P: Integer;
  SL: TStringList;
  BindingAddress: String;
begin
  Assert(FHTTPServer = nil);

  if Assigned(GlobalStorage) then
  begin
    PortNumber := GlobalStorage.ReadInteger('Options',
      STORAGE_WEB_SERVER_PORT_VALUE_NAME,
      DEFAULT_WEB_SERVER_PORT);

    if (PortNumber < 1024) or (PortNumber > 65535) then
      PortNumber := DEFAULT_WEB_SERVER_PORT;
  end else
    PortNumber := DEFAULT_WEB_SERVER_PORT;

  FHttpServer := TIdHTTPServer.Create(nil);
  FHttpServer.ServerSoftware := 'GedeminHttpServer';

  FHttpServer.Bindings.Clear;

  SL := TStringList.Create;
  try
    SL.CommaText := gd_GlobalParams.GetWebServerBindings;
    for I := 0 to SL.Count - 1 do
    begin
      if Length(SL[I]) > 0 then
      begin
        Binding := FHttpServer.Bindings.Add;

        P := Pos(':', SL[I]);
        if P > 0 then
        begin
          Binding.Port := StrToIntDef(System.Copy(SL[I], P + 1, 255), PortNumber);
          BindingAddress := System.Copy(SL[I], 1, P - 1);
        end else
        begin
          Binding.Port := PortNumber;
          BindingAddress := SL[I];
        end;

        if BindingAddress[1] in ['0'..'9'] then
          Binding.IP := BindingAddress
        else
          Binding.IP := GetIPAddress(BindingAddress);
      end;
    end;
  finally
    SL.Free;
  end;

  FHttpServer.OnCommandGet := ServerOnCommandGet;
  FHttpServer.OnCreatePostStream := ServerOnCreatePostStream;

  if Assigned(EventControl) then
  begin
    FVarParam := EventControl.OnVarParamEvent;
    FReturnVarParam := EventControl.OnReturnVarParam;
  end;
end;

procedure TgdWebServerControl.ProcessQueryRequest;
var
  UP: String;
  FI: TFLItem;
  FC: TFLCollection;
begin
  FResponseInfo.ResponseNo := 200;
  FResponseInfo.ContentType := 'text/plain;';
  FResponseInfo.ContentText := '';

  Log(FRequestInfo.RemoteIP, 'QERY', FRequestInfo.Params);

  if (AnsiCompareText(FRequestInfo.Params.Values['update_token'], 'POSITIVE_CASH') = 0)
    or (AnsiCompareText(FRequestInfo.Params.Values['update_token'], 'POSITIVE_CHECK') = 0) then
  begin
    exit;
  end;

  if DirectoryExists(gd_GlobalParams.GetWebServerUpdatePath) then
  begin
    FLastToken := '';

    if (FRequestInfo.Params.Values['update_token'] = '') or
      (AnsiCompareText(FRequestInfo.Params.Values['update_token'], 'STABLE') = 0) then
    begin
      UP := IncludeTrailingBackslash(gd_GlobalParams.GetWebServerUpdatePath) + 'Normal';
    end else
      UP := IncludeTrailingBackslash(gd_GlobalParams.GetWebServerUpdatePath) +
        FRequestInfo.Params.Values['update_token'];

    if not DirectoryExists(UP) then
      UP := IncludeTrailingBackslash(gd_GlobalParams.GetWebServerUpdatePath) + 'Normal';

    if DirectoryExists(UP) then
    begin
      FC := GetFLCollection(FRequestInfo.Params.Values['update_token']);

      if FC = nil then
      begin
        FC := TFLCollection.Create;
        FC.UpdateToken := FRequestInfo.Params.Values['update_token'];
        FC.RootPath := UP;
        FC.BuildEtalonFileSet;
        FFileList.Add(FC);
      end;

      FI := FC.FindItem('gedemin.exe');
      if FI <> nil then
      begin
        if TFLItem.CompareVersionStrings(FI.Version,
          FRequestInfo.Params.Values['exe_ver'], 4) > 0 then
        begin
          FResponseInfo.ContentText := 'UPDATE';
          FLastToken := FRequestInfo.Params.Values['update_token'];
        end;
      end;
    end;
  end;
end;

function TgdWebServerControl.GetActive: Boolean;
begin
  Result := Assigned(FHTTPServer) and FHTTPServer.Active;
end;

procedure TgdWebServerControl.SetActive(const Value: Boolean);
begin
  if Value then
    ActivateServer
  else
    DeactivateServer;
end;

function TgdWebServerControl.GetBindings: String;
var
  I: Integer;
begin
  Result := '';
  if Assigned(FHTTPServer) then
  begin
    for I := 0 to FHTTPServer.Bindings.Count - 1 do
    begin
      Result := Result + (FHTTPServer.Bindings[I] as TidSocketHandle).IP +
        ':' + IntToStr((FHTTPServer.Bindings[I] as TidSocketHandle).Port) + ',';
    end;
    if Result > '' then
      SetLength(Result, Length(Result) - 1);
  end;
end;

procedure TgdWebServerControl.ProcessFileRequest;
var
  FI: TFLItem;
  MS: TMemoryStream;
  FC: TFLCollection;
begin
  Log(FRequestInfo.RemoteIP, 'RQFL', FRequestInfo.Params);

  FResponseInfo.ResponseNo := 400;

  if FRequestInfo.Params.IndexOfName('update_token') > -1 then
    FC := GetFLCollection(FRequestInfo.Params.Values['update_token'])
  else
    FC := GetFLCollection(FLastToken);

  if FC <> nil then
  begin
    FI := FC.FindItem(FRequestInfo.Params.Values['fn']);
    if FI <> nil then
    begin
      MS := TMemoryStream.Create;
      try
        FI.ReadFromDisk(MS);
      except
        FreeAndNil(MS);
      end;

      if MS <> nil then
      begin
        FResponseInfo.ResponseNo := 200;
        FResponseInfo.ContentType := 'application/octet-stream;';
        FResponseInfo.ContentStream := MS;
      end;
    end;
  end;
end;

procedure TgdWebServerControl.Log(const AnIPAddress: String;
  const AnOp: String; const Names: array of String; const Values: array of String);
var
  Tr: TIBTransaction;
  q: TIBSQL;
  I, ID: Integer;
begin
  Assert(Low(Names) = Low(Values));
  Assert(High(Names) = High(Values));
  Assert(Length(AnIPAddress) <= 15);
  Assert(Length(AnOp) <= 4);

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := gdcBaseManager.Database;
    Tr.StartTransaction;
    q.Transaction := Tr;

    ID := gdcBaseManager.GetNextID;
    q.SQL.Text :=
      'INSERT INTO gd_weblog (id, ipaddress, op) ' +
      'VALUES (:id, :ipaddress, :op)';
    q.ParamByName('id').AsInteger := ID;
    if AnIPAddress = '' then
      q.ParamByName('ipaddress').AsString := '0.0.0.0'
    else
      q.ParamByName('ipaddress').AsString := AnIPAddress;
    q.ParamByName('op').AsString := AnOp;
    q.ExecQuery;

    q.SQL.Text :=
      'INSERT INTO gd_weblogdata (logkey, valuename, valuestr, valueblob) ' +
      'VALUES (:logkey, :vn, :vs, :vb)';
    q.ParamByName('logkey').AsInteger := ID;

    for I := Low(Names) to High(Names) do
    begin
      q.ParamByName('vn').AsString := Names[I];

      if Length(Values[I]) <= 254 then
      begin
        q.ParamByName('vs').AsString := Values[I];
        q.ParamByName('vb').Clear;
      end else
      begin
        q.ParamByName('vb').AsString := Values[I];
        q.ParamByName('vs').Clear;
      end;

      q.ExecQuery;

      if (AnOp = 'QERY') and (Names[I] = 'c_name') and (gdNotifierThread <> nil) then
        gdNotifierThread.Add('Подключение ' + Values[I] + '...', 0, 4000)
      else if (AnOp = 'RQFL') and (Names[I] = 'file_name') and (gdNotifierThread <> nil) then
        gdNotifierThread.Add('Передача файла ' + Values[I] + '...', 0, 2000);
    end;

    Tr.Commit;
  finally
    q.Free;
    Tr.Free;
  end;
end;

procedure TgdWebServerControl.ProcessFilesListRequest;
var
  FC: TFLCollection;
begin
  if FRequestInfo.Params.IndexOfName('update_token') > -1 then
    FC := GetFLCollection(FRequestInfo.Params.Values['update_token'])
  else
    FC := GetFLCollection(FLastToken);

  if FC = nil then
    FResponseInfo.ResponseNo := 400
  else begin
    FResponseInfo.ResponseNo := 200;
    FResponseInfo.ContentType := 'application/octet-stream;';
    FResponseInfo.ContentStream := TMemoryStream.Create;
    FC.GetYAML(FResponseInfo.ContentStream);
  end;
end;

procedure TgdWebServerControl.ProcessBLOBRequest;
var
  MS: TMemoryStream;
  q: TIBSQL;
begin
  Log(FRequestInfo.RemoteIP, 'RQBL', ['table_name', 'field_name', 'ruid'],
    [FRequestInfo.Params.Values['table'],
     FRequestInfo.Params.Values['field'],
     FRequestInfo.Params.Values['ruid']]);

  FResponseInfo.ResponseNo := 400;

  q := TIBSQL.Create(nil);
  try
    q.Transaction := gdcBaseManager.ReadTransaction;
    q.SQL.Text :=
      'SELECT ' + FRequestInfo.Params.Values['field'] +
      ' FROM ' + FRequestInfo.Params.Values['table'] +
      ' WHERE id=' +
      IntToStr(gdcBaseManager.GetIDByRUIDString(FRequestInfo.Params.Values['ruid']));
    q.ExecQuery;
    if not q.EOF then
    begin
      MS := TMemoryStream.Create;
      q.Fields[0].SaveToStream(MS);
      FResponseInfo.ResponseNo := 200;
      FResponseInfo.ContentType := 'application/octet-stream;';
      FResponseInfo.ContentStream := MS;
    end;
  finally
    q.Free;
  end;
end;

procedure TgdWebServerControl.Log(const AnIPAddress, AnOp: String;
  Params: TStrings);
var
  Names, Values: array of String;
  I: Integer;
begin
  Assert(Params <> nil);

  SetLength(Names, Params.Count);
  SetLength(Values, Params.Count);
  for I := 0 to Params.Count - 1 do
  begin
    Names[I] := Params.Names[I];
    Values[I] := FURI.URLDecode(Params.Values[Names[I]]);
  end;
  Log(AnIPAddress, AnOp, Names, Values);
end;

function TgdWebServerControl.GetFLCollection(
  const AnUpdateToken: String): TFLCollection;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FFileList.Count - 1 do
  begin
    if AnsiCompareText((FFileList[I] as TFLCollection).UpdateToken, AnUpdateToken) = 0 then
    begin
      Result := FFileList[I] as TFLCollection;
      break;
    end;
  end;
end;

function TgdWebServerControl.GetInProcess: Boolean;
begin
  Result := FInProcess.Value <> 0;
end;

procedure TgdWebServerControl.ProcessTestRequest;
var
  q: TIBSQL;
begin
  FResponseInfo.ResponseNo := 200;
  FResponseInfo.ContentType := 'text/plain; charset=Windows-1251';

  q := TIBSQL.Create(nil);
  try
    q.Transaction := gdcBaseManager.ReadTransaction;
    q.SQL.Text := 'SELECT * FROM gd_user WHERE name = :N AND passw = :P';
    q.ParamByName('N').AsString := FRequestInfo.Params.Values['user_name'];
    q.ParamByName('P').AsString := FRequestInfo.Params.Values['password'];
    q.ExecQuery;

    if q.EOF then
      FResponseInfo.ContentText := 'Invalid user name or password'
    else
      FResponseInfo.ContentText := 'Ok';
  finally
    q.Free;
  end;
end;

procedure TgdWebServerControl.ProcessLoginRequest;
var
  WS: TgdWebUserSession;
begin
  WS := TgdWebUserSession.Create;
  try
    if WS.OpenSession(FRequestInfo.Params.Values['user_name'],
      FRequestInfo.Params.Values['password']) then
    begin
      FResponseInfo.ResponseNo := 200;
      FResponseInfo.ContentType := 'text/plain; charset=Windows-1251';
      FResponseInfo.ContentText := WS.ID;
      FUserSessions.Add(WS);
      WS := nil;
    end else
      FResponseInfo.ResponseNo := 403;
  finally
    WS.Free;
  end;
end;

procedure TgdWebServerControl.ProcessLogoffRequest;
var
  I: Integer;
begin
  FResponseInfo.ResponseNo := 403;
  for I := 0 to FUserSessions.Count - 1 do
  begin
    if (FUserSessions[I] as TgdWebUserSession).ID =
      FRequestInfo.Params.Values['session_id'] then
    begin
      FUserSessions.Delete(I);
      FResponseInfo.ResponseNo := 200;
      break;
    end;
  end;
end;

procedure TgdWebServerControl.ProcessSendErrorRequest;
begin
  Log(FRequestInfo.RemoteIP, 'SNDE', FRequestInfo.Params);
  FResponseInfo.ResponseNo := 200;
  FResponseInfo.ContentType := 'text/plain; charset=Windows-1251';
  FResponseInfo.ContentText := 'Ok';
end;

procedure TgdWebServerControl.DoneRelayServers;
var
  I: Integer;
begin
  FRelayServerActive.Value := 0;

  FRelayServers.Lock;
  try
    if FRelayServers.Count = 0 then
      exit;
    for I := 0 to FRelayServers.Count - 1 do
      (FRelayServers[I] as TgdRelayServer).Cancel;
  finally
    FRelayServers.Unlock;
  end;

  Sleep(40);

  FRelayServers.Lock;
  try
    FRelayServers.Clear;
  finally
    FRelayServers.Unlock;
  end;
end;

class procedure TgdWebServerControl.SaveRequestInfoToStream(
  ARequest: TidHTTPRequestInfo; S: TStream);
begin
  Assert(ARequest.Params <> nil);

  SaveHeaderInfoToStream(ARequest, S);
  SaveHeaderListToStream(ARequest.CustomHeaders, S);
  SaveDateTimeToStream(ARequest.Date, S);
  SaveDateTimeToStream(ARequest.Expires, S);
  SaveDateTimeToStream(ARequest.LastModified, S);
  SaveStringToStream(ARequest.Pragma, S);
  SaveStringToStream(ARequest.Accept, S);
  SaveStringToStream(ARequest.AcceptCharSet, S);
  SaveStringToStream(ARequest.AcceptEncoding, S);
  SaveStringToStream(ARequest.AcceptLanguage, S);
  SaveStringToStream(ARequest.From, S);
  SaveStringToStream(ARequest.Password, S);
  SaveStringToStream(ARequest.Referer, S);
  SaveStringToStream(ARequest.UserAgent, S);
  SaveStringToStream(ARequest.UserName, S);
  SaveStringToStream(ARequest.Host, S);
  SaveStringToStream(ARequest.ProxyConnection, S);

  //  FAuthentication: TIdAuthentication;

  //  FCookies: TIdServerCookies;

  SaveStringToStream(ARequest.Params.CommaText, S);
  SaveStreamToStream(ARequest.PostStream, S);

  // FSession

  SaveStringToStream(ARequest.Document, S);
  SaveStringToStream(ARequest.UnparsedParams, S);
  SaveStringToStream(ARequest.QueryParams, S);
  SaveStringToStream(ARequest.FormParams, S);
end;

class procedure TgdWebServerControl.ReadRequestInfoFromStream(
  ARequest: TidHTTPRequestInfo; S: TStream);
begin
  Assert(ARequest.Params <> nil);

  ReadHeaderInfoFromStream(ARequest, S);
  ReadHeaderListFromStream(ARequest.CustomHeaders, S);
  ARequest.Date := ReadDateTimeFromStream(S);
  ARequest.Expires := ReadDateTimeFromStream(S);
  ARequest.LastModified := ReadDateTimeFromStream(S);
  ARequest.Pragma := ReadStringFromStream(S);
  ARequest.Accept := ReadStringFromStream(S);
  ARequest.AcceptCharSet := ReadStringFromStream(S);
  ARequest.AcceptEncoding := ReadStringFromStream(S);
  ARequest.AcceptLanguage := ReadStringFromStream(S);
  ARequest.From := ReadStringFromStream(S);
  ARequest.Password := ReadStringFromStream(S);
  ARequest.Referer := ReadStringFromStream(S);
  ARequest.UserAgent := ReadStringFromStream(S);
  ARequest.UserName := ReadStringFromStream(S);
  ARequest.Host := ReadStringFromStream(S);
  ARequest.ProxyConnection := ReadStringFromStream(S);

  //  FAuthentication: TIdAuthentication;

  //  FCookies: TIdServerCookies;

  ARequest.Params.CommaText := ReadStringFromStream(S);
  ReadStreamFromStream(ARequest.PostStream, S);

  // FSession

  ARequest.Document := ReadStringFromStream(S);
  ARequest.UnparsedParams := ReadStringFromStream(S);
  ARequest.QueryParams := ReadStringFromStream(S);
  ARequest.FormParams := ReadStringFromStream(S);
end;

class procedure TgdWebServerControl.ReadResponseInfoFromStream(
  AResponse: TidHTTPResponseInfo; S: TStream);
begin
  ReadHeaderInfoFromStream(AResponse, S);

  AResponse.Location := ReadStringFromStream(S);
  AResponse.Server := ReadStringFromStream(S);
  AResponse.ProxyConnection := ReadStringFromStream(S);
  ReadHeaderListFromStream(AResponse.ProxyAuthenticate, S);
  ReadHeaderListFromStream(AResponse.WWWAuthenticate, S);

  AResponse.AuthRealm := ReadStringFromStream(S);
  AResponse.ContentType := ReadStringFromStream(S);
  AResponse.ResponseNo := ReadIntegerFromStream(S);

  //  FCookies: TIdServerCookies;

  ReadStreamFromStream(AResponse.ContentStream, S);
  AResponse.ContentText := ReadStringFromStream(S);
  AResponse.CloseConnection := ReadBooleanFromStream(S);
  AResponse.FreeContentStream := ReadBooleanFromStream(S);
  AResponse.HeaderHasBeenWritten := ReadBooleanFromStream(S);
  AResponse.ResponseText := ReadStringFromStream(S);

  // FSession: TIdHTTPSession;
end;

class procedure TgdWebServerControl.SaveResponseInfoToStream(
  AResponse: TidHTTPResponseInfo; S: TStream);
begin
  SaveHeaderInfoToStream(AResponse, S);

  SaveStringToStream(AResponse.Location, S);
  SaveStringToStream(AResponse.Server, S);
  SaveStringToStream(AResponse.ProxyConnection, S);
  SaveHeaderListToStream(AResponse.ProxyAuthenticate, S);
  SaveHeaderListToStream(AResponse.WWWAuthenticate, S);

  SaveStringToStream(AResponse.AuthRealm, S);
  SaveStringToStream(AResponse.ContentType, S);
  SaveIntegerToStream(AResponse.ResponseNo, S);

  //  FCookies: TIdServerCookies;

  SaveStreamToStream(AResponse.ContentStream, S);
  SaveStringToStream(AResponse.ContentText, S);
  SaveBooleanToStream(AResponse.CloseConnection, S);
  SaveBooleanToStream(AResponse.FreeContentStream, S);
  SaveBooleanToStream(AResponse.HeaderHasBeenWritten, S);
  SaveStringToStream(AResponse.ResponseText, S);

  // FSession: TIdHTTPSession;
end;

class procedure TgdWebServerControl.ReadHeaderInfoFromStream(
  AHeader: TIdEntityHeaderInfo; S: TStream);
begin
  AHeader.CacheControl := ReadStringFromStream(S);
  ReadHeaderListFromStream(AHeader.RawHeaders, S);
  AHeader.Connection := ReadStringFromStream(S);
  AHeader.ContentEncoding := ReadStringFromStream(S);
  AHeader.ContentLanguage := ReadStringFromStream(S);
  AHeader.ContentLength := ReadIntegerFromStream(S);
  AHeader.ContentRangeEnd := ReadCardinalFromStream(S);
  AHeader.ContentRangeStart := ReadCardinalFromStream(S);
  AHeader.ContentType := ReadStringFromStream(S);
  AHeader.ContentVersion := ReadStringFromStream(S);
end;

class procedure TgdWebServerControl.SaveHeaderInfoToStream(
  AHeader: TIdEntityHeaderInfo; S: TStream);
begin
  SaveStringToStream(AHeader.CacheControl, S);
  SaveHeaderListToStream(AHeader.RawHeaders, S);
  SaveStringToStream(AHeader.Connection, S);
  SaveStringToStream(AHeader.ContentEncoding, S);
  SaveStringToStream(AHeader.ContentLanguage, S);
  SaveIntegerToStream(AHeader.ContentLength, S);
  SaveCardinalToStream(AHeader.ContentRangeEnd, S);
  SaveCardinalToStream(AHeader.ContentRangeStart, S);
  SaveStringToStream(AHeader.ContentType, S);
  SaveStringToStream(AHeader.ContentVersion, S);
end;

class procedure TgdWebServerControl.ReadHeaderListFromStream(
  AHeaderList: TIdHeaderList; S: TStream);
begin
  Assert(AHeaderList <> nil);
  AHeaderList.NameValueSeparator := ReadStringFromStream(S);
  AHeaderList.CaseSensitive := ReadBooleanFromStream(S);
  AHeaderList.UnfoldLines := ReadBooleanFromStream(S);
  AHeaderList.FoldLines := ReadBooleanFromStream(S);
  AHeaderList.FoldLength := ReadIntegerFromStream(S);
  AHeaderList.CommaText := ReadStringFromStream(S);
end;

class procedure TgdWebServerControl.SaveHeaderListToStream(
  AHeaderList: TIdHeaderList; S: TStream);
begin
  Assert(AHeaderList <> nil);
  SaveStringToStream(AHeaderList.NameValueSeparator, S);
  SaveBooleanToStream(AHeaderList.CaseSensitive, S);
  SaveBooleanToStream(AHeaderList.UnfoldLines, S);
  SaveBooleanToStream(AHeaderList.FoldLines, S);
  SaveIntegerToStream(AHeaderList.FoldLength, S);
  SaveStringToStream(AHeaderList.CommaText, S);
end;

procedure TgdWebServerControl.ServerOnCreatePostStream(
  ASender: TIdPeerThread; var VPostStream: TStream);
begin
  VPostStream := TStringStream.Create('');
end;

procedure TgdWebServerControl.ProcessODataRoot;
begin
  FResponseInfo.ResponseNo := 200;
  FResponseInfo.ContentType := 'application/json;odata.metadata=minimal;odata.streaming=true;IEEE754Compatible=false;charset=Windows-1251';
  FResponseInfo.CustomHeaders.Values['OData-Version'] := '4.0';
  FResponseInfo.ContentText := FgdOData.GetServiceRoot;
end;

procedure TgdWebServerControl.ProcessODataMetadata;
begin
  FResponseInfo.ResponseNo := 200;
  FResponseInfo.ContentType := 'application/xml;charset=Windows-1251';
  FResponseInfo.CustomHeaders.Values['OData-Version'] := '4.0';
  FResponseInfo.ContentText := FgdOData.GetServiceMetadata;
end;

procedure TgdWebServerControl.ProcessODataEntitySet;
begin
  FResponseInfo.ResponseNo := 200;
  FResponseInfo.ContentType := 'application/json;odata.metadata=minimal;odata.streaming=true;IEEE754Compatible=false;charset=Windows-1251';
  FResponseInfo.CustomHeaders.Values['OData-Version'] := '4.0';
  FResponseInfo.ContentText := FgdOData.GetEntitySet(FRequestInfo.Document);
end;

function TgdWebServerControl.GetODataRoot: String;
begin
  Result := 'http://' + gd_GlobalParams.GetWebServerBindings + ODataRoot;
end;

{ TgdWebUserSession }

constructor TgdWebUserSession.Create;
begin
  inherited;
end;

destructor TgdWebUserSession.Destroy;
begin
  FTransaction.Free;
  inherited;
end;

function TgdWebUserSession.OpenSession(const AUserName,
  APassword: String): Boolean;
var
  q: TIBSQL;
begin
  Assert(FTransaction = nil);
  Assert(IBLogin <> nil);

  q := TIBSQL.Create(nil);
  try
    q.Transaction := gdcBaseManager.ReadTransaction;
    q.SQL.Text := 'SELECT * FROM gd_user WHERE name = :N AND passw = :P';
    q.ParamByName('N').AsString := AUserName;
    q.ParamByName('P').AsString := APassword;
    q.ExecQuery;

    if q.EOF then
      Result := False
    else begin
      FTransaction := TIBTransaction.Create(nil);
      FTransaction.DefaultDatabase := gdcBaseManager.Database;
      FTransaction.Params.Text := 'read_committed'#13#10'rec_version'#13#10'nowait';
      FTransaction.StartTransaction;

      FUserName := AUserName;
      FID := RUIDToStr(RUID(gdcBaseManager.GetNextID, IBLogin.DBID));

      Result := True;
    end;
  finally
    q.Free;
  end;
end;

{ TgdRelayServer }

procedure TgdRelayServer.Cancel;
begin
  if FState <> rssCanceled then
  begin
    FState := rssCanceled;
    FEvent.SetEvent;
    FResultReady.SetEvent;
  end;  
end;

constructor TgdRelayServer.Create;
begin
  FAliases := TStringList.Create;
  FEvent := TEvent.Create(nil, False, False, '');
  FResultReady := TEvent.Create(nil, False, False, '');
  FID := _RelayServersID;
  if _RelayServersID = MAXINT then
    _RelayServersID := 1
  else
    Inc(_RelayServersID);
  FState := rssReady;  
end;

destructor TgdRelayServer.Destroy;
begin
  inherited;
  FAliases.Free;
  FEvent.SetEvent;
  FResultReady.SetEvent;
  FEvent.Free;
  FResultReady.Free;
  FDataStream.Free;
end;

function TgdRelayServer.PrepareDataStream: TStream;
begin
  FDataStream.Free;
  FDataStream := TMemoryStream.Create;
  Result := FDataStream;
end;

{ TgdHiddenServer }

procedure TgdHiddenServer.Activate;
begin
  Assert(FRelayServer > '');
  Assert(IBLogin <> nil);

  FCompanyRUID := gdcBaseManager.GetRUIDStringByID(IBLogin.CompanyKey);

  FURI.URLDecode(FRelayServer);
  if FURI.Protocol = '' then
    FRelayServer := 'http://' + FRelayServer;

  PostMsg(WM_GD_HS_POOL);
end;

constructor TgdHiddenServer.Create;
begin
  inherited Create(True);
  FreeOnTerminate := False;
  Priority := tpNormal;
  FHTTP := TidHTTP.Create(nil);
  FHTTP.HandleRedirects := True;
  FHTTP.ReadTimeout := HiddenServerTimeout;
  FHTTP.ConnectTimeout := HiddenServerTimeout;
  FHTTP.OnWork := DoOnWork;
  FURI := TidURI.Create;
  FRelayServer := gd_GlobalParams.GetRelayServer;
end;

destructor TgdHiddenServer.Destroy;
begin
  inherited;
  FHTTP.Free;
  FURI.Free;
  FFakeRequestInfo.Free;
  FFakeResponseInfo.Free;
end;

procedure TgdHiddenServer.DoOnWork(Sender: TObject; AWorkMode: TWorkMode;
  const AWorkCount: Integer);
begin
  //if Terminated then
  //  Abort;
end;

function TgdHiddenServer.ProcessMessage(var Msg: TMsg): Boolean;
var
  MS, FullS: TMemoryStream;
  ResponseS: TStringStream;
  //PostStream: TIdMultiPartFormDataStream;
  Hdr: TRelayServerResponseHeader;
  ResultReady: Boolean;
begin
  Result := True;

  case Msg.Message of
    WM_GD_HS_POOL:
    begin
      if (FRelayServer = '') then
      begin
        ErrorMessage := 'Relay server is not assigned.';
        exit;
      end;

      ResultReady := False;
      try
        FURI.URI := FRelayServer;
        if gdNotifierThread <> nil then
          gdNotifierThread.Add('Pooling relay server: ' + FURI.Host + '...', 0, 2000);

        MS := TMemoryStream.Create;
        try
          FHTTP.Get(TidURI.URLEncode(FRelayServer + '/relay/ready?' +
            'company_ruid=' + FCompanyRUID), MS);

          if Terminated then
            exit;  

          MS.Position := 0;

          if (MS.Read(Hdr, SizeOf(Hdr)) <> SizeOf(Hdr))
            or (Hdr.Signature <> RelayServerStreamSignature)
            or (Hdr.Version <> RelayServerStreamVersion) then
          begin
            if gdNotifierThread <> nil then
              gdNotifierThread.Add('Invalid response from relay server. Will try again in 10 min.', 0, 2000);
            SetTimeOut(600000);
            exit;
          end;

          if (Hdr.Cmd = rscmdQuery) and (Hdr.Size > 0)  then
          begin
            FFakeRequestInfo.Free;
            FFakeRequestInfo := TidHTTPRequestInfo.Create;
            TgdWebServerControl.ReadRequestInfoFromStream(
              FFakeRequestInfo, MS);

            FFakeResponseInfo.Free;
            FFakeResponseInfo := TidHTTPResponseInfo.Create(nil);

            try
              if gdNotifierThread <> nil then
                gdNotifierThread.Add('Hidden server serve ' + FFakeRequestInfo.Document +
                  '?' + FFakeRequestInfo.Params.CommaText, 0, 2000);
              FProcessErrorCode := 0;
              FProcessErrorMessage := '';
              ResultReady := True;
              Synchronize(ServerOnCommandGetSync);
            except
              on E: Exception do
              begin
                FProcessErrorCode := 1;
                FProcessErrorMessage := E.Message;
              end;
            end;
          end
          else if Hdr.Cmd = rscmdReject then
          begin
            SetTimeOut(600000);
            exit;
          end
          else if Hdr.Cmd <> rscmdIdle then
          begin
            if gdNotifierThread <> nil then
              gdNotifierThread.Add('Unknown command from relay server.', 0, 2000);
          end;
        finally
          MS.Free;
        end;
      except
        on EIdReadTimeout do ;

        on E: Exception do
        begin
          ErrorMessage := E.Message;
          if gdNotifierThread <> nil then
            gdNotifierThread.Add(ErrorMessage + ' Will try again in 10 min.', 0, 2000);
          SetTimeOut(600000);
          exit;
        end;
      end;

      if (not Terminated) and ResultReady then
      begin
        try
          MS := TMemoryStream.Create;
          FullS := TMemoryStream.Create;
          ResponseS := TStringStream.Create('');
          try
            if FProcessErrorCode <> 0 then
            begin
              if gdNotifierThread <> nil then
                gdNotifierThread.Add('Hidden server error: ' + FProcessErrorMessage, 0, 2000);
              SaveStringToStream(FProcessErrorMessage, MS);
              Hdr.Cmd := rscmdError;
              Hdr.Size := MS.Size;
            end else
            begin
              if gdNotifierThread <> nil then
                gdNotifierThread.Add('Hidden server response ready.', 0, 2000);
              TgdWebServerControl.SaveResponseInfoToStream(FFakeResponseInfo, MS);
              Hdr.Cmd := rscmdResult;
              Hdr.Size := MS.Size;
            end;

            FullS.WriteBuffer(Hdr, SizeOf(Hdr));
            FullS.CopyFrom(MS, 0);
            FullS.Position := 0;

            FHTTP.Request.ContentType := 'application/octet-stream';
            FHTTP.Post(TidURI.URLEncode(FRelayServer + '/relay/result'), FullS, ResponseS);

            if gdNotifierThread <> nil then
              gdNotifierThread.Add('Relay server answer: ' + ResponseS.DataString, 0, 2000);
          finally
            MS.Free;
            FullS.Free;
            ResponseS.Free;
          end;
        except
          on E: Exception do
            ErrorMessage := E.Message;
        end;
      end;

      PostMsg(WM_GD_HS_POOL);
    end;
  else
    Result := False;
  end;
end;

procedure TgdHiddenServer.ServerOnCommandGetSync;
begin
  if gdWebServerControl <> nil then
  begin
    gdWebServerControl.FRequestInfo := FFakeRequestInfo;
    gdWebServerControl.FResponseInfo := FFakeResponseInfo;
    gdWebServerControl.ServerOnCommandGetSync;
  end;
end;

procedure TgdHiddenServer.Timeout;
begin
  SetTimeout(INFINITE);
  PostMsg(WM_GD_HS_POOL);
end;

{ TgdTableRelayRows }

procedure TgdTableRelayRows.RefreshRows;
var
  q: TIBSQL;
  Row: TgdTableRelayRow;
begin
  Lock;
  Clear;
  q := TIBSQL.Create(nil);
  try
    q.Transaction := gdcBaseManager.ReadTransaction;
    q.SQL.Text :=
      'SELECT w.companyruid, LIST(w.alias, '','') AS aliases ' +
      'FROM web_relay w ' +
      'GROUP BY w.companyruid';
    q.ExecQuery;

    while not q.Eof do
    begin
      Row := TgdTableRelayRow.Create;
      Add(Row);
      Row.CompanyRuid := q.FieldByName('companyruid').AsString;
      Row.Aliases := q.FieldByName('aliases').AsString;
      q.Next;
    end;
  finally
    q.Free;
    Unlock;
  end;
end;

function TgdTableRelayRows.GetRUIDByAlias(const Alias: String): String;
var
  J: Integer;
  Aliases: TStringList;
begin
  Result := '';
  Lock;
  try
    Aliases := TStringList.Create;
    try
      for J := 0 to Count - 1 do
      begin
        Aliases.CommaText := (Items[J] as TgdTableRelayRow).Aliases;
        if Aliases.IndexOf(Alias) <> -1 then
        begin
          Result := (Items[J] as TgdTableRelayRow).CompanyRuid;
          break;
        end;
      end;
    finally
      Aliases.Free;
    end;
  finally
    Unlock;
  end;
end;

function TgdTableRelayRows.GetAliasesByRUID(const CompanyRuid: String): String;
var
  J: Integer;
begin
  Result := '';
  Lock;
  try
    for J := 0 to Count - 1 do
    begin
      if (Items[J] as TgdTableRelayRow).CompanyRuid = CompanyRuid then
      begin
        Result := (Items[J] as TgdTableRelayRow).Aliases;
        break;
      end;
    end;
  finally
    Unlock;
  end;
end;

{ TgdRelayServers }

function TgdRelayServers.AddAndLock: TgdRelayServer;
begin
  Lock;
  Result := TgdRelayServer.Create;
  Add(Result);
end;

function TgdRelayServers.FindAndLock(const AnID: Integer): TgdRelayServer;
var
  J: Integer;
begin
  Lock;
  Result := nil;
  for J := 0 to Count - 1 do
    if (Items[J] as TgdRelayServer).ID = AnID then
    begin
      Result := Items[J] as TgdRelayServer;
      break;
    end;
end;

function TgdRelayServers.FindAndLock(
  const AnAlias: String): TgdRelayServer;
var
  J: Integer;
begin
  Lock;
  Result := nil;
  for J := 0 to Count - 1 do
  begin
    if (Items[J] as TgdRelayServer).Aliases.IndexOf(AnAlias) <> -1 then
    begin
      if ((Items[J] as TgdRelayServer).State = rssReady) and
        ((Items[J] as TgdRelayServer).Event.WaitFor(0) = wrTimeOut) then
      begin
        Result := Items[J] as TgdRelayServer;
        break;
      end;
    end;
  end;
end;

{ TgdLockedList }

constructor TgdLockedList.Create;
begin
  inherited Create(True);
  FCS := TCriticalSection.Create;
end;

destructor TgdLockedList.Destroy;
begin
  FCS.Free;
  inherited;
end;

procedure TgdLockedList.Lock;
begin
  FCS.Enter;
end;

procedure TgdLockedList.Unlock;
begin
  FCS.Leave;
end;

initialization
  gdWebServerControl := TgdWebServerControl.Create(nil);
  _RelayServersID := 1;

finalization
  FreeAndNil(gdWebServerControl);
end.

