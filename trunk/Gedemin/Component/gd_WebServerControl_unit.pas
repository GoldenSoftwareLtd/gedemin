
{++

  Copyright (c) 2012 by Golden Software of Belarus

  Module

    gd_WebServerControl_unit.pas

  Abstract

    A file list for gedemin updater.

  Author

    Vitalik Borushko

  Revisions history

    1.00    01.01.12    flakekun        Initial version.

--}

unit gd_WebServerControl_unit;

interface

uses
  Classes, Contnrs, IdHTTPServer, IdCustomHTTPServer, IdTCPServer, evt_i_Base;

const
  DEFAULT_WEB_SERVER_PORT = 80;
  STORAGE_WEB_SERVER_PORT_VALUE_NAME = 'WebServerPort';

type
  TgdWebServerControl = class(TComponent)
  private
    FHttpServer: TIdHTTPServer;
    FHttpGetHandlerList: TObjectList;

    FRequest: TIdHTTPRequestInfo;
    FResponse: TIdHTTPResponseInfo;

    FVarParam: TVarParamEvent;
    FReturnVarParam: TVarParamEvent;

    function GetVarInterface(const AnValue: Variant): OleVariant;
    function GetVarParam(const AnValue: Variant): OleVariant;

    procedure ServerOnCommandGet(AThread: TIdPeerThread;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure ServerOnCommandGetSync;
    procedure CreateHTTPServer;
    procedure ProcessQueryRequest;

  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure ActivateServer;
    procedure DeactivateServer;

    procedure RegisterOnGetEvent(const AComponent: TComponent;
      const AToken, AFunctionName: String);
    procedure UnRegisterOnGetEvent(const AComponent: TComponent);
  end;

var
  gdWebServerControl: TgdWebServerControl;

implementation

uses
  SysUtils, ibsql, Forms, Windows, IdSocketHandle, gdcOLEClassList,
  gd_i_ScriptFactory, scr_i_FunctionList, rp_BaseReport_unit,
  gdcBaseInterface, prp_methods, Gedemin_TLB, Storages, WinSock,
  ComObj;

type
  TgdHttpHandler = class(TObject)
  public
    Component: TComponent;
    Token: String;
    FunctionKey: Integer;
  end;

const
  PARAM_TOKEN = 'token';

{ TgdWebServerControl }

constructor TgdWebServerControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FHttpServer := nil;
  FHttpGetHandlerList := TObjectList.Create(True);
end;

destructor TgdWebServerControl.Destroy;
begin
  FreeAndNil(FHttpGetHandlerList);
  FreeAndNil(FHttpServer);
  inherited;
end;

procedure TgdWebServerControl.RegisterOnGetEvent(const AComponent: TComponent; const AToken, AFunctionName: String);
var
  Handler: TgdHttpHandler;
  FunctionKey: Integer;

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

begin
  FunctionKey := GetFunctionKey;
  if FunctionKey > 0 then
  begin
    Handler := TgdHttpHandler.Create;
    Handler.Component := AComponent;
    Handler.Token := AToken;
    Handler.FunctionKey := FunctionKey;

    FHttpGetHandlerList.Add(Handler);

    if Assigned(AComponent) then
      AComponent.FreeNotification(Self);

    ActivateServer;
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
begin
  FRequest := ARequestInfo;
  FResponse := AResponseInfo;

  AThread.Synchronize(ServerOnCommandGetSync);
end;

procedure TgdWebServerControl.ServerOnCommandGetSync;
var
  RequestToken: String;
  HandlerCounter: Integer;
  Handler: TgdHttpHandler;
  HandlerFunction: TrpCustomFunction;
  LParams, LResult: Variant;
  Processed: Boolean;
begin
  if AnsiCompareText(FRequest.Document, '/query') = 0 then
  begin
    ProcessQueryRequest;
    exit;
  end;

  Processed := False;
  RequestToken := AnsiLowerCase(Trim(FRequest.Params.Values[PARAM_TOKEN]));
  for HandlerCounter := 0 to FHttpGetHandlerList.Count - 1 do
  begin
    Handler := FHttpGetHandlerList[HandlerCounter] as TgdHttpHandler;
    if (Handler.Token = '') or (AnsiCompareText(Handler.Token, RequestToken) = 0) then
    begin
      HandlerFunction := glbFunctionList.FindFunction(Handler.FunctionKey);
      if Assigned(HandlerFunction) then
      begin
        // Формирование списка параметров
        //  1 - компонент к которому привязан обработчик
        //  2 - параметры GET запроса
        //  3 - HTTP код ответа (byref)
        //  4 - текст ответа (byref)
        LParams := VarArrayOf([
          GetGdcOLEObject(Handler.Component) as IgsComponent,
          GetGdcOLEObject(FRequest.Params) as IgsStrings,
          GetVarInterface(FResponse.ResponseNo),
          GetVarInterface(FResponse.ContentText)]);

        ScriptFactory.ExecuteFunction(HandlerFunction, LParams, LResult);
        FResponse.ResponseNo := Integer(GetVarParam(LParams[2]));
        FResponse.ContentType := 'text/xml; charset=Windows-1251';
        FResponse.ContentText := String(GetVarParam(LParams[3]));

        Processed := True;
      end;
    end;
  end;

  if not Processed then
  begin
    FResponse.ResponseNo := 200;
    FResponse.ContentType := 'text/html;';
    FResponse.ContentText :=
      '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">'#13#10 +
      '<HTML><HEAD><TITLE>Gedemin Web Server</TITLE></HEAD><BODY>Hello World!</BODY></HTML>';
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
var
  PortNumber: Integer;
begin
  if not Assigned(FHTTPServer) then
    CreateHTTPServer;

  if not FHTTPServer.Active then
    try
      if Assigned(GlobalStorage) then
      begin
        PortNumber := GlobalStorage.ReadInteger('Options',
          STORAGE_WEB_SERVER_PORT_VALUE_NAME,
          DEFAULT_WEB_SERVER_PORT);

        if (PortNumber >= 1024) and (PortNumber <= 65535) then
          FHttpServer.Bindings[0].Port := PortNumber;
      end;

      FHttpServer.Active := True;
    except
      on E: Exception do
        Application.MessageBox(
          PChar('При запуске HTTP сервера возникла ошибка:'#13#10 + E.Message),
          'Ошибка HTTP сервера',
          MB_OK + MB_TASKMODAL + MB_ICONEXCLAMATION);
    end;
end;

procedure TgdWebServerControl.DeactivateServer;
begin
  if Assigned(FHTTPServer) then
    FHttpServer.Active := False;
end;

procedure TgdWebServerControl.CreateHTTPServer;

  function GetLocalIP: String;
  var
    wsaData: TWSAData;
    addr: TSockAddrIn;
    Phe: PHostEnt;
    szHostName: array[0..128] of Char;
  begin
    Result := '';
    if WSAStartup($101, WSAData) <> 0 then
      Exit;
    try
      if GetHostName(szHostName, 128) <> SOCKET_ERROR then
      begin
        Phe := GetHostByName(szHostName);
        if Assigned(Phe) then
        begin
          addr.sin_addr.S_addr := longint(plongint(Phe^.h_addr_list^)^);
          Result := inet_ntoa(addr.sin_addr);
        end;
      end;
    finally
      WSACleanup;
    end;
  end;

  function GetIP: String;
  var
    wsaData: TWSAData;
    addr: TSockAddrIn;
    Phe: PHostEnt;
    szHostName: array[0..128] of Char;
  begin
    Result := '';
    if WSAStartup($101, WSAData) <> 0 then
      Exit;
    try
      szHostName := 'gs.selfip.biz';
      Phe := GetHostByName(szHostName);
      if Assigned(Phe) then
      begin
        addr.sin_addr.S_addr := longint(plongint(Phe^.h_addr_list^)^);
        Result := inet_ntoa(addr.sin_addr);
      end;
    finally
      WSACleanup;
    end;
  end;

var
  Binding : TIdSocketHandle;
begin
  Assert(FHTTPServer = nil);

  FHttpServer := TIdHTTPServer.Create(nil);
  FHttpServer.ServerSoftware := 'GedeminHttpServer';

  FHttpServer.Bindings.Clear;
  Binding := FHttpServer.Bindings.Add;
  Binding.Port := DEFAULT_WEB_SERVER_PORT;
  Binding.IP := GetLocalIP;

  Binding := FHttpServer.Bindings.Add;
  Binding.Port := DEFAULT_WEB_SERVER_PORT;
  Binding.IP := '127.0.0.1';

  {Binding := FHttpServer.Bindings.Add;
  Binding.Port := DEFAULT_WEB_SERVER_PORT;
  Binding.IP := GetIP;}

  FHttpServer.OnCommandGet := ServerOnCommandGet;

  if Assigned(EventControl) then
  begin
    FVarParam := EventControl.OnVarParamEvent;
    FReturnVarParam := EventControl.OnReturnVarParam;
  end;
end;

procedure TgdWebServerControl.ProcessQueryRequest;
var
  LocalDoc, Sel: OleVariant;
  Params: Variant;
begin
  LocalDoc := CreateOleObject('MSXML.DOMDocument');
  LocalDoc.Async := False;
  LocalDoc.SetProperty('SelectionLanguage', 'XPath');

  if LocalDoc.LoadXML(FRequest.Params.Text) then
  begin
    Params := VarArrayCreate([0, 2], varVariant);

    Sel := LocalDoc.SelectSingleNode('/QUERY/VERSION_1/DBID');
    if not VarIsEmpty(Sel) then
      Params[0] := Sel.NodeTypedValue;
    Sel := LocalDoc.SelectSingleNode('/QUERY/VERSION_1/CUSTOMERNAME');
    if not VarIsEmpty(Sel) then
      Params[1] := Sel.NodeTypedValue;
    Params[2] := FRequest.RemoteIP;

    gdcBaseManager.ExecSingleQuery(
      'INSERT INTO gd_web_log (dbid, customername, ipaddress, op) ' +
      'VALUES (:dbid, :customername, :ipaddress, ''QURY'')', Params);
  end;
end;

initialization
  gdWebServerControl := TgdWebServerControl.Create(nil);

finalization
  FreeAndNil(gdWebServerControl);
end.

