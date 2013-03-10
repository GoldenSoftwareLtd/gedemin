
{++

  Copyright (c) 2012-2013 by Golden Software of Belarus

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
  Classes, Contnrs, SyncObjs, evt_i_Base, gd_FileList_unit,
  IdHTTPServer, IdCustomHTTPServer, IdTCPServer, idThreadSafe;

type
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
    procedure Log(const AnIPAddress: String; const AnOp: String;
      const Names: array of String; const Values: array of String); overload;
    procedure Log(const AnIPAddress: String; const AnOp: String;
      Params: TStrings); overload;
    function GetActive: Boolean;
    procedure SetActive(const Value: Boolean);
    function GetInProcess: Boolean;

  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    function GetFLCollection(const AnUpdateToken: String = ''): TFLCollection;

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
    property InProcess: Boolean read GetInProcess;
  end;

var
  gdWebServerControl: TgdWebServerControl;

implementation

uses
  SysUtils, Forms, Windows, IBSQL, IBDatabase, IdSocketHandle, gdcOLEClassList,
  gd_i_ScriptFactory, scr_i_FunctionList, rp_BaseReport_unit, gdcBaseInterface,
  prp_methods, Gedemin_TLB, Storages, WinSock, ComObj, JclSimpleXML, jclSysInfo,
  gd_directories_const, ActiveX, FileCtrl, gd_GlobalParams_unit, gdcJournal;

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
  FFileList := TObjectList.Create(True);
  FInProcess := TidThreadSafeInteger.Create;
end;

destructor TgdWebServerControl.Destroy;
begin
  inherited;
  FreeAndNil(FHttpServer);
  FreeAndNil(FHttpGetHandlerList);
  FreeAndNil(FFileList);
  FreeAndNil(FInProcess);
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
begin
  FInProcess.Value := 1;
  try
    FRequestInfo := ARequestInfo;
    FResponseInfo := AResponseInfo;
    AThread.Synchronize(ServerOnCommandGetSync);
  finally
    FInProcess.Value := 0;
  end;
end;

procedure TgdWebServerControl.ServerOnCommandGetSync;
var
  RequestToken, S: String;
  HandlerCounter: Integer;
  Handler: TgdHttpHandler;
  HandlerFunction: TrpCustomFunction;
  LParams, LResult: Variant;
  Processed: Boolean;
  I: Integer;
begin
  Assert(FHTTPGetHandlerList <> nil);

  try
    if AnsiCompareText(FRequestInfo.Document, '/query') = 0 then
      ProcessQueryRequest
    else if AnsiCompareText(FRequestInfo.Document, '/get_files_list') = 0 then
      ProcessFilesListRequest
    else if AnsiCompareText(FRequestInfo.Document, '/get_file') = 0 then
      ProcessFileRequest
    else if AnsiCompareText(FRequestInfo.Document, '/get_blob') = 0 then
      ProcessBLOBRequest
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
            Log(FRequestInfo.RemoteIP, 'TOKN', ['token'], [FRequestInfo.Params.Values[PARAM_TOKEN]]);
            
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
            FResponseInfo.ContentText := String(GetVarParam(LParams[3]));

            if Copy(FResponseInfo.ContentText, 1, 5) = '<?xml' then
              FResponseInfo.ContentType := 'text/xml; charset=Windows-1251'
            else if Copy(FResponseInfo.ContentText, 1, 14) = '<!DOCTYPE HTML' then
              FResponseInfo.ContentType := 'text/html; charset=Windows-1251'
            else
              FResponseInfo.ContentType := 'text/plain; charset=Windows-1251';

            Processed := True;
          end;
        end
        else if RequestToken > '' then
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
        S := 'Gedemin Web Server.';
        S := S + '<br/>Copyright (c) 2013 by <a href="http://gsbelarus.com">Golden Software of Belarus, Ltd.</a>';
        S := S + '<br/>All rights reserved.';

        S := S + '<br/><br/>Serve tokens:<ol>';
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
    SL.CommaText := gd_GlobalParams.GetWebServerBindings;
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
    Values[I] := Params.Values[Names[I]];
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

initialization
  gdWebServerControl := TgdWebServerControl.Create(nil);

finalization
  FreeAndNil(gdWebServerControl);
end.

