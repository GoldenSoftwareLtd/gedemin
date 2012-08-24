unit gd_WebServerControl_unit;

interface
                                        
uses
  Classes, Contnrs, IdHTTPServer, IdCustomHTTPServer, IdTCPServer, evt_i_Base;

const
  DEFAULT_WEB_SERVER_PORT = 50060;
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

    // ����������� ���������� HTTP GET �������
    procedure ServerOnCommandGet(AThread: TIdPeerThread; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    // ����������� �� ������ ���������� ��������� ��������� GET �������
    procedure ServerOnCommandGetSync;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    class function GetInstance: TgdWebServerControl;
    destructor Destroy; override;

    procedure RegisterOnGetEvent(const AComponent: TComponent; const AToken, AFunctionName: String);
    procedure UnRegisterOnGetEvent(const AComponent: TComponent);
  end;

implementation

uses
  SysUtils, ibsql, forms, windows, IdSocketHandle, gdcOLEClassList, gd_i_ScriptFactory, scr_i_FunctionList, rp_BaseReport_unit,
  gdcBaseInterface, prp_methods, Gedemin_TLB, Storages;

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
var
  Binding : TIdSocketHandle;
begin
  inherited Create(AOwner);

  FHttpServer := TIdHTTPServer.Create(nil);
  FHttpServer.ServerSoftware := 'GedeminHttpServer';
  // �������� � �����
  FHttpServer.Bindings.Clear;
  Binding := FHttpServer.Bindings.Add;
  Binding.Port := 50060;
  Binding.IP := '127.0.0.1';
  // ���������� GET �������
  FHttpServer.OnCommandGet := ServerOnCommandGet;

  // ������ ������ �������-������������ GET ��������
  FHttpGetHandlerList := TObjectList.Create(True);

  // ������� �������������� variant ���������� �\�� VBScript
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
  FunctionKey: Integer;
  PortNumber: Integer;

  function GetFunctionKey: Integer;
  var
    q: TIBSQL;
  begin
    Result := -1;

    q := TIBSQL.Create(nil);
    try
      q.Transaction := gdcBaseManager.ReadTransaction;

      if Assigned(AComponent) then
        q.SQL.Text :=
          ' SELECT f.id ' +
          ' FROM gd_function f ' +
          '   JOIN evt_object o ON o.id = f.modulecode AND o.name = ' + QuotedStr(AComponent.Name) +
          ' WHERE f.name = ' + QuotedStr(AFunctionName)
      else
        q.SQL.Text := 'SELECT id FROM gd_function WHERE name = ' + QuotedStr(AFunctionName);
      q.ExecQuery;

      if not q.Eof then
      begin
        Result := q.FieldByName('id').AsInteger;
      end
      else
      begin
        if Assigned(AComponent) then
        begin
          q.Close;
          q.SQL.Text:= 'SELECT id FROM gd_function WHERE name = ' + QuotedStr(AFunctionName);
          q.ExecQuery;
          if not q.Eof then
            Result := q.FieldByName('id').AsInteger
          else
            raise Exception.Create('������ "' + AFunctionName + '" �� �������.');
        end
        else
          raise Exception.Create('������ "' + AFunctionName + '" �� �������.');
      end;
    finally
      FreeAndNil(q);
    end;
  end;

begin
  // ������ ���� ������ �� �����
  FunctionKey := GetFunctionKey;
  if FunctionKey > 0 then
  begin
    // ���������� GET �������
    Handler := TgdHttpHandler.Create;
    Handler.Component := AComponent;
    Handler.Token := AToken;
    Handler.FunctionKey := FunctionKey;
    // ������� ���������� � ������
    FHttpGetHandlerList.Add(Handler);
    // �������� ��������� �������� � ����� �����������
    AComponent.FreeNotification(Self);
    
    // �������� ������, ���� �� �� �������
    if not FHttpServer.Active then
      try
        // ������� ����� ����� ��� ��������� �� ���������
        PortNumber := 0;
        if Assigned(GlobalStorage) then
          PortNumber := GlobalStorage.ReadInteger('Options', STORAGE_WEB_SERVER_PORT_VALUE_NAME, DEFAULT_WEB_SERVER_PORT);
        // ���� ������ �������, � ���� ��������, ������� ��� � ������� �� ���������
        if (PortNumber >= 1024) and (PortNumber <= 65535) then
          FHttpServer.Bindings[0].Port := PortNumber;

        FHttpServer.Active := True;
      except
        on E: Exception do
          Application.MessageBox(PChar('��� ������� HTTP ������� �������� ������:'#13#10 + E.Message), '������ HTTP �������', MB_OK + MB_APPLMODAL + MB_ICONEXCLAMATION);
      end;
  end;
end;

procedure TgdWebServerControl.UnRegisterOnGetEvent(const AComponent: TComponent);
var
  I: Integer;
begin
  // ������ ����������� ����������� � ����������� ����������
  I := 0;
  while I < FHttpGetHandlerList.Count do
  begin
    if TgdHttpHandler(FHttpGetHandlerList[I]).Component = AComponent then
      FHttpGetHandlerList.Delete(I)
    else
      Inc(I);  
  end;
  // ���� ��� ������������, �� ��������� ������
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
  // �� ��������� ���������� ��� ������ 
  FResponse.ResponseNo := 404;
  // �� ������ ������� �� ���������� ����� ����������� ���������
  RequestToken := AnsiLowerCase(Trim(FRequest.Params.Values[PARAM_TOKEN]));
  if RequestToken <> '' then
  begin
    FResponse.ContentType := 'text/xml; charset=Windows-1251';

    // ���� �� ������ ������������, ���������� ������ �� ������
    HandlerCounter := 0;
    while HandlerCounter < FHttpGetHandlerList.Count do
    begin
      Handler := TgdHttpHandler(FHttpGetHandlerList[HandlerCounter]);
      // �� ��������� �� ��������� � �������� �������� ����������
      if Assigned(Handler.Component) and (Handler.FunctionKey > 0) then
      begin
        // ���� ���������� �������� �� ������
        if AnsiCompareText(Handler.Token, RequestToken) = 0 then
        begin
            // ����� � ��������� ������� �������
            HandlerFunction := glbFunctionList.FindFunction(Handler.FunctionKey);
            // ���� ���� ����� �������
            if Assigned(HandlerFunction) then
            begin
              // ������������ ������ ����������
              //  1 - ��������� � �������� �������� ����������
              //  2 - ��������� GET �������
              //  3 - HTTP ��� ������ (byref)
              //  4 - ����� ������ (byref)
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
        // �������� � ���������� �����������
        Inc(HandlerCounter);
      end
      else
      begin
        // ������ ����� ����������
        FHttpGetHandlerList.Delete(HandlerCounter)
      end;
    end;
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

  // ���� ������ ������� � ����� ����������, �� ������ ��� ����������� �� ������
  //  (opRemove �� Gedemin.tlb ����������� Classes.opRemove !!!)
  if Operation = Classes.opRemove then
  begin
    I := 0;
    while I < FHttpGetHandlerList.Count do
    begin
      if TgdHttpHandler(FHttpGetHandlerList[I]).Component = AComponent then
      begin
        AComponent.RemoveFreeNotification(Self);
        FHttpGetHandlerList.Delete(I);
      end
      else
        Inc(I);
    end;

    // ���� ��� ������������, �� ��������� ������
    if FHttpGetHandlerList.Count = 0 then
      FHttpServer.Active := False;
  end;
end;

initialization
  _instance := nil;

finalization
  _instance := nil;

end.

