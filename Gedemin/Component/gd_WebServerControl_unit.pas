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

    // Асинхронный обработчик HTTP GET запроса
    procedure ServerOnCommandGet(AThread: TIdPeerThread;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);

    // Запускаемая на потоке приложения процедура обработки GET запроса
    procedure ServerOnCommandGetSync;

  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    class function GetInstance: TgdWebServerControl;

    procedure RegisterOnGetEvent(const AComponent: TComponent;
      const AToken, AFunctionName: String);
    procedure UnRegisterOnGetEvent(const AComponent: TComponent);
  end;

implementation

uses
  SysUtils, ibsql, Forms, Windows, IdSocketHandle, gdcOLEClassList,
  gd_i_ScriptFactory, scr_i_FunctionList, rp_BaseReport_unit,
  gdcBaseInterface, prp_methods, Gedemin_TLB, Storages, WinSock;

type
  TgdHttpHandler = class(TObject)
  public
    Component: TComponent;
    Token: String;
    FunctionKey: Integer;
  end;

const
  PARAM_TOKEN = 'token';

var
  _instance: TgdWebServerControl;

{ TgdWebServerControl }

class function TgdWebServerControl.GetInstance: TgdWebServerControl;
begin
  if not Assigned(_instance) then
    _instance := TgdWebServerControl.Create(Application);
  Result := _instance;
end;

constructor TgdWebServerControl.Create(AOwner: TComponent);

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
  inherited Create(AOwner);

  FHttpServer := TIdHTTPServer.Create(nil);
  FHttpServer.ServerSoftware := 'GedeminHttpServer';
  // Привязка к порту
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

  // Обработчик GET запроса
  FHttpServer.OnCommandGet := ServerOnCommandGet;

  // Список ключей функций-обработчиков GET запросов
  FHttpGetHandlerList := TObjectList.Create(True);

  // Функции обрабатывающие variant переменные в\из VBScript
  if Assigned(EventControl) then
  begin
    FVarParam := EventControl.OnVarParamEvent;
    FReturnVarParam := EventControl.OnReturnVarParam;
  end;
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
  FunctionKey, PortNumber: Integer;

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
  // Найдем ключ функци по имени
  FunctionKey := GetFunctionKey;
  if FunctionKey > 0 then
  begin
    // Обработчик GET запроса
    Handler := TgdHttpHandler.Create;
    Handler.Component := AComponent;
    Handler.Token := AToken;
    Handler.FunctionKey := FunctionKey;
    // Добавим обработчик в список
    FHttpGetHandlerList.Add(Handler);
    // Попросим компонент сообщить о своем уничтожении
    if Assigned(AComponent) then
      AComponent.FreeNotification(Self);

    // Запустим сервер, если он не запущен
    if not FHttpServer.Active then
      try
        // Считаем номер порта для прослушки из хранилища
        if Assigned(GlobalStorage) then
        begin
          PortNumber := GlobalStorage.ReadInteger('Options',
            STORAGE_WEB_SERVER_PORT_VALUE_NAME,
            DEFAULT_WEB_SERVER_PORT);

          // Если чтение успешно, и порт подходит, занесем его в биндинг по умолчанию
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
end;

procedure TgdWebServerControl.UnRegisterOnGetEvent(const AComponent: TComponent);
var
  I: Integer;
begin
  // Удалим обработчики привязанные к переданному компоненту
  I := 0;
  while I < FHttpGetHandlerList.Count do
  begin
    if TgdHttpHandler(FHttpGetHandlerList[I]).Component = AComponent then
      FHttpGetHandlerList.Delete(I)
    else
      Inc(I);  
  end;
  // Если нет обработчиков, то остановим сервер
  if FHttpGetHandlerList.Count = 0 then
    FHttpServer.Active := False;
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
begin
  // По умолчанию возвращаем код ошибки
  FResponse.ResponseNo := 404;
  // По токену запроса мы определяем какие обработчики выполнять
  RequestToken := AnsiLowerCase(Trim(FRequest.Params.Values[PARAM_TOKEN]));
  {if RequestToken <> '' then
  begin}
    FResponse.ContentType := 'text/xml; charset=Windows-1251';

    // Идем по списку обработчиков, определяем нужный по токену
    HandlerCounter := 0;
    while HandlerCounter < FHttpGetHandlerList.Count do
    begin
      Handler := TgdHttpHandler(FHttpGetHandlerList[HandlerCounter]);
      // Не уничтожен ли компонент к которому привязан обработчик
      {if Assigned(Handler.Component) and (Handler.FunctionKey > 0) then
      begin}
        // Если обработчик подходит по токену
        if (Handler.Token = '') or (AnsiCompareText(Handler.Token, RequestToken) = 0) then
        begin
            // Поиск и получение объекта функции
            HandlerFunction := glbFunctionList.FindFunction(Handler.FunctionKey);
            // Если есть такая функция
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
              FResponse.ContentText := String(GetVarParam(LParams[3]));
            end;
        end;
        // Перейдем к следующему обработчику
        Inc(HandlerCounter);
      {end else
      begin
        // Удалим такой обработчик
        FHttpGetHandlerList.Delete(HandlerCounter)
      end;}
    end;
  {end;}
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

  // Если объект сообщил о своем унитожении, то удалим его обработчики из списка
  //  (opRemove из Gedemin.tlb перекрывает Classes.opRemove !!!)
  if Operation = Classes.opRemove then
  begin
    I := 0;
    while I < FHttpGetHandlerList.Count do
    begin
      if TgdHttpHandler(FHttpGetHandlerList[I]).Component = AComponent then
      begin
        AComponent.RemoveFreeNotification(Self);
        FHttpGetHandlerList.Delete(I);
      end else
        Inc(I);
    end;

    // Если нет обработчиков, то остановим сервер
    if FHttpGetHandlerList.Count = 0 then
      FHttpServer.Active := False;
  end;
end;

initialization
  _instance := nil;

finalization
  _instance := nil;

end.

