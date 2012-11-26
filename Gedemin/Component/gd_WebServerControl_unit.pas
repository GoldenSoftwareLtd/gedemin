
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
  Classes, Contnrs, SyncObjs, IdHTTPServer, IdCustomHTTPServer, IdTCPServer,
  evt_i_Base, gd_FileList_unit;

type
  TgdWebServerControl = class(TComponent)
  private
    FHttpServer: TIdHTTPServer;
    FHttpGetHandlerList: TObjectList;
    FVarParam: TVarParamEvent;
    FReturnVarParam: TVarParamEvent;
    FFileList: TFLCollection;
    FRequestInfo: TIdHTTPRequestInfo;
    FResponseInfo: TIdHTTPResponseInfo;

    function GetVarInterface(const AnValue: Variant): OleVariant;
    function GetVarParam(const AnValue: Variant): OleVariant;

    procedure ServerOnCommandGet(AThread: TIdPeerThread;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure ServerOnCommandGetSync;
    procedure CreateHTTPServer;
    procedure ProcessQueryRequest;
    procedure ProcessFilesListRequest;
    procedure ProcessFileRequest;
    procedure Log(const AnIPAddress: String; const AnOp: String;
      const Names: array of String; const Values: array of String);
    function GetActive: Boolean;
    procedure SetActive(const Value: Boolean);

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
    function GetBindings: String;

    property Active: Boolean read GetActive write SetActive;
  end;

var
  gdWebServerControl: TgdWebServerControl;

implementation

uses
  SysUtils, Forms, Windows, IBSQL, IBDatabase, IdSocketHandle, gdcOLEClassList,
  gd_i_ScriptFactory, scr_i_FunctionList, rp_BaseReport_unit, gdcBaseInterface,
  prp_methods, Gedemin_TLB, Storages, WinSock, ComObj, JclSimpleXML, jclSysInfo,
  gd_directories_const, ActiveX, FileCtrl, gd_GlobalParams_unit;

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
  inherited;
  FreeAndNil(FHttpServer);
  FreeAndNil(FHttpGetHandlerList);
  FreeAndNil(FFileList);
end;

procedure TgdWebServerControl.RegisterOnGetEvent(const AComponent: TComponent;
  const AToken, AFunctionName: String);
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
  Assert(FHTTPGetHandlerList <> nil);

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
  FRequestInfo := ARequestInfo;
  FResponseInfo := AResponseInfo;
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
  Assert(FHTTPGetHandlerList <> nil);

  if AnsiCompareText(FRequestInfo.Document, '/query') = 0 then
    ProcessQueryRequest
  else if AnsiCompareText(FRequestInfo.Document, '/get_files_list') = 0 then
    ProcessFilesListRequest
  else if AnsiCompareText(FRequestInfo.Document, '/get_file') = 0 then
    ProcessFileRequest
  else begin
    Processed := False;
    RequestToken := FRequestInfo.Params.Values[PARAM_TOKEN];
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
            GetGdcOLEObject(FRequestInfo.Params) as IgsStrings,
            GetVarInterface(FResponseInfo.ResponseNo),
            GetVarInterface(FResponseInfo.ContentText)]);

          ScriptFactory.ExecuteFunction(HandlerFunction, LParams, LResult);
          FResponseInfo.ResponseNo := Integer(GetVarParam(LParams[2]));
          FResponseInfo.ContentType := 'text/xml; charset=Windows-1251';
          FResponseInfo.ContentText := String(GetVarParam(LParams[3]));

          Processed := True;
        end;
      end;
    end;

    if not Processed then
    begin
      FResponseInfo.ResponseNo := 200;
      FResponseInfo.ContentType := 'text/html;';
      FResponseInfo.ContentText :=
        '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">'#13#10 +
        '<HTML><HEAD><TITLE>Gedemin Web Server</TITLE></HEAD><BODY>Hello World!</BODY></HTML>';
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
      if gd_GlobalParams.GetWebServerActive and (FHTTPServer.Bindings.Count > 0)
        and ((FHTTPServer.Bindings[0] as TidSocketHandle).IP <> '0.0.0.0') then
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
end;

procedure TgdWebServerControl.DeactivateServer;
begin
  if Assigned(FHTTPServer) then
    FHttpServer.Active := False;
end;

procedure TgdWebServerControl.CreateHTTPServer;
var
  Binding : TIdSocketHandle;
  PortNumber, I: Integer;
  SL: TStringList;
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
    SL.CommaText := gd_GlobalParams.GetServerBindings;
    for I := 0 to SL.Count - 1 do
    begin
      if Length(SL[I]) > 0 then
      begin
        Binding := FHttpServer.Bindings.Add;
        Binding.Port := PortNumber;
        if SL[I][1] in ['0'..'9'] then
          Binding.IP := SL[I]
        else
          Binding.IP := GetIPAddress(SL[I]);
      end;
    end;
  finally
    SL.Free;
  end;

  FHttpServer.OnCommandGet := ServerOnCommandGet;

  if Assigned(EventControl) then
  begin
    FVarParam := EventControl.OnVarParamEvent;
    FReturnVarParam := EventControl.OnReturnVarParam;
  end;
end;

procedure TgdWebServerControl.ProcessQueryRequest;
begin
  FResponseInfo.ResponseNo := 200;
  FResponseInfo.ContentType := 'text/plain;';
  FResponseInfo.ContentText := '';

  Log(FRequestInfo.RemoteIP, 'QERY',
    ['dbid', 'c_name', 'c_ruid', 'loc_ip', 'exe_ver', 'update_token'],
    [FRequestInfo.Params.Values['dbid'],
     FRequestInfo.Params.Values['c_name'],
     FRequestInfo.Params.Values['c_ruid'],
     FRequestInfo.Params.Values['loc_ip'],
     FRequestInfo.Params.Values['exe_ver'],
     FRequestInfo.Params.Values['update_token']]);

  if FFileList = nil then
  begin
    FFileList := TFLCollection.Create;
    //!!!
    if DirectoryExists(ExtractFileDrive(Application.EXEName) + ':\golden\gedemin_local_fb') then
      FFileList.RootPath := ExtractFileDrive(Application.EXEName) + ':\golden\gedemin_local_fb';
    //!!!
    FFileList.BuildEtalonFileSet;
  end;

  if (FFileList.FindItem('gedemin.exe') <> nil) and
    (TFLItem.CompareVersionStrings(FFileList.FindItem('gedemin.exe').Version,
      FRequestInfo.Params.Values['exe_ver'], 4) > 0) then
    begin
      FResponseInfo.ContentText := 'UPDATE';
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
        ':' + IntToStr((FHTTPServer.Bindings[I] as TidSocketHandle).Port) + ';';
    end;
    if Result > '' then
      SetLength(Result, Length(Result) - 1);
  end;
end;

procedure TgdWebServerControl.ProcessFileRequest;
var
  FI: TFLItem;
  MS: TMemoryStream;
begin
  Log(FRequestInfo.RemoteIP, 'RQFL', ['file_name'],
    [FRequestInfo.Params.Values['fn']]);

  FResponseInfo.ResponseNo := 400;

  if FFileList <> nil then
  begin
    FI := FFileList.FindItem(FRequestInfo.Params.Values['fn']);
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
    end;

    Tr.Commit;
  finally
    q.Free;
    Tr.Free;
  end;
end;

procedure TgdWebServerControl.ProcessFilesListRequest;
begin
  Assert(FFileList <> nil);
  FResponseInfo.ResponseNo := 200;
  FResponseInfo.ContentType := 'application/octet-stream;';
  FResponseInfo.ContentStream := TStringStream.Create(FFileList.GetXML);
end;

initialization
  gdWebServerControl := TgdWebServerControl.Create(nil);

finalization
  FreeAndNil(gdWebServerControl);
end.

