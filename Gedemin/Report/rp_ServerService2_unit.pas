unit rp_ServerService2_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, SvcMgr, Dialogs,
  IBDatabase, rp_ReportServer, Db, thrd_Event, rp_BaseReport_unit, ActiveX,
  IBEvents, ExtCtrls;

type
  TGedeminReportServer = class(TService)
    gsIBDatabase: TIBDatabase;
    ServerReport: TServerReport;
    IBTransaction: TIBTransaction;
    procedure ServerReportCreateObject(Sender: TObject);
    procedure IBEvents1EventAlert(Sender: TObject; EventName: String;
      EventCount: Integer; var CancelAlerts: Boolean);
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
    procedure ServiceBeforeInstall(Sender: TService);
    procedure gsIBDatabaseAfterConnect(Sender: TObject);
    procedure ServiceDestroy(Sender: TObject);
    procedure ServiceShutdown(Sender: TService);
{    procedure ServiceCreate(Sender: TObject);
    procedure ServiceExecute(Sender: TService);}
  private
    FHndl: THandle;
    FBaseQuery: IDispatch;
    procedure ReadParams;
  public
//    constructor Create(AOwner: TComponent); override;
    function GetServiceController: TServiceController; override;
//    procedure ThreadEvent(const AnEventCode: TServerEventCode);
  end;

//type
//  TCrackerThread = class(TThread);

var
  GedeminReportServer: TGedeminReportServer;
//  Hndl: THandle;
//  FThreadEvent: TServerEventThread;

implementation

uses
  rp_server_connect_option, rp_report_const, obj_QueryList, Registry,
  gd_directories_const, rp_ReportScriptControl, CheckServerLoad_unit, Forms;

{$R *.DFM}

procedure WriteError(AnError: String);
var
  FStr: TFileStream;
  S: String;
begin
  S := ChangeFileExt(Forms.Application.EXEName, '.log');
  AnError := AnError + #13#10;
  if FileExists(S) then
    FStr := TFileStream.Create(S, fmOpenWrite)
  else
    FStr := TFileStream.Create(S, fmCreate);
  try
    FStr.Position := FStr.Size;
    FStr.Write(AnError[1], Length(AnError));
  finally
    FStr.Free;
  end;
end;

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  GedeminReportServer.Controller(CtrlCode);
end;

function TGedeminReportServer.GetServiceController: TServiceController;
begin
  WriteError('TGedeminReportServer.GetServiceController');
  Result := ServiceController;
end;

procedure TGedeminReportServer.ReadParams;
var
  Reg: TRegistry;
  UserName, UserPass, DBName, Param: String;
begin
  WriteError('TGedeminReportServer.ReadParams');
  gsIBDatabase.Params.Clear;
  GetReportServerConnectParam(UserName, UserPass, DBName);
  gsIBDatabase.Params.Add(User_NameValue + '=' + UserName);
  gsIBDatabase.Params.Add(PasswordValue + '=' + UserPass);
  gsIBDatabase.Params.Add(SQL_Role_NameValue + '=' + DefaultSQL_Role_Name);

  gsIBDatabase.Params.Values[Lc_ctypeValue] := DefaultLc_ctype;
  gsIBDatabase.DatabaseName := DBName;

  Reg := TRegistry.Create;
  try
    Reg.RootKey := ClientRootRegistryKey;

    if Reg.OpenKeyReadOnly(ClientRootRegistrySubKey) then
    begin
      //  Кодировка
      if Reg.ValueExists(Lc_ctypeValue) then
      begin
        Param := Reg.ReadString(Lc_ctypeValue);

        if Param > '' then
          gsIBDatabase.Params.Values[Lc_ctypeValue] := Param;
      end;

      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
end;

(*procedure TGedeminReportServer.ThreadEvent(const AnEventCode: TServerEventCode);
begin
  try
    case AnEventCode of
      {WM_USER_CLOSE_PROMT:
        if (ServerReport.ActiveConnections = 0) or (MessageBox(0,
         PChar(Format('К серверу отчетов подключено %d клиент(ов). Выгрузить сервер?',
         [ServerReport.ActiveConnections])), 'Вопрос', MB_YESNO or MB_ICONQUESTION) = IDYES) then
          ;
      WM_USER_CLOSE:
        Close;}
      WM_USER_PARAM:
        if ServerReport <> nil then
          ServerReport.ServerOptions;
      WM_USER_REFRESH:
        if ServerReport <> nil then
          ServerReport.Load;
      WM_USER_REBUILD:
        if ServerReport <> nil then
          ServerReport.RebuildReports;
      WM_USER_RESET:
        if ServerReport <> nil then
          ServerReport.DeleteResult;
    end;
  except
    ServerReport.SaveLog('ThreadEvent');
  end;
end;           *)

procedure TGedeminReportServer.ServerReportCreateObject(Sender: TObject);
begin
  WriteError('TGedeminReportServer.ServerReportCreateObject');
  (Sender as TReportScript).AddObject(ReportObjectName, FBaseQuery, False);
  (Sender as TReportScript).AddObject('BaseQueryList', FBaseQuery, False);
end;

procedure TGedeminReportServer.IBEvents1EventAlert(Sender: TObject;
  EventName: String; EventCount: Integer; var CancelAlerts: Boolean);
begin
  WriteError('TGedeminReportServer.IBEvents1EventAlert');
  if EventName = 'CloseGedemin' then;
    ServerReport.CloseConnection;
end;

procedure TGedeminReportServer.ServiceStart(Sender: TService;
  var Started: Boolean);
begin
  WriteError('TGedeminReportServer.ServiceStart');
  try
    Started := True;

  {  if IBEvents1.AutoRegister then
    begin
      ServerReport.SaveLog('Нельзя ставить IBEvents1.AutoRegister = True!!!');
      Started := False;
      Exit;
    end;}

    if CheckReportServerActivate <> Long_False then
    begin
      ServerReport.SaveLog('ПОПЫТКА ПОВТОРНОГО ЗАПУСКА СЕРВЕРА. Сервер отчетов уже загружен.');
      Started := False;
      Exit;
    end;

    SetLastError(0);
    FHndl := CreateMutex(nil, False, ReportServerMutexName);
    if FHndl = 0 then
    begin
      ServerReport.SaveLog('Произошла ошибка при создании Mutex.');
      Started := False;
      Exit;
    end;

(*    try
      FThreadEvent := TServerEventThread.Create(ServerReportName);
      FThreadEvent.OnEvent := GedeminReportServer.ThreadEvent;
      FThreadEvent.Resume;
    except
      on E: Exception do
      begin
        Started := False;
        ServerReport.SaveLog('Произошла ошибка при запуске сервера.'#13#10 + E.Message);
      end;
    end;*)

    ServerReport.SaveLog('BeforeConnect');
    try
      OleInitialize(nil);
      if not Assigned(FBaseQuery) then
        FBaseQuery := TgsQueryList.Create(gsIBDatabase, IBTransaction) as IDispatch;
      ReadParams;
      ServerReport.Load;
      if ServerReport.ServerKey = 0 then
        raise Exception.Create('Нельзя установить подключение к базе: ' +
         ServerReport.Database.Name);
    except
      on E: Exception do
      begin
        Started := False;
        ServerReport.SaveLog('Произошла ошибка при загрузке сервера.'#13#10 + E.Message);
      end;
    end;
    ServerReport.SaveLog('AfterConnect');

  except
    ServerReport.SaveLog('ServiceStart');
  end;
end;

procedure TGedeminReportServer.ServiceStop(Sender: TService;
  var Stopped: Boolean);
begin
  WriteError('TGedeminReportServer.ServiceStop');
  try
    Stopped := True;

    ServerReport.SaveLog('Вызван останов сервиса');

(*    try
      FThreadEvent.UserTerminate;
    except
      on E: Exception do
        ServerReport.SaveLog('Произошла ошибка при освобождении нити событий'#13#10 + E.Message);
    end;*)

    try
      ReleaseMutex(FHndl);
    except
      on E: Exception do
        ServerReport.SaveLog('Произошла ошибка при освобождении MUTEX'#13#10 + E.Message);
    end;

    try
      FBaseQuery := nil;
      OleUninitialize;
    except
      on E: Exception do
        ServerReport.SaveLog('Произошла ошибка при выполнении OleUninitialize'#13#10 + E.Message);
    end;
  except
    ServerReport.SaveLog('ServiceStop');
  end;
end;

procedure TGedeminReportServer.ServiceBeforeInstall(Sender: TService);
var
  TempBool: Boolean;
begin
  try
    TempBool := MessageBox(0, 'Сервер отчетов стоит на одной машине с Interbase сервером?',
     'Вопрос', MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL) = IDYES;

    if not TempBool then
      Dependencies.Delete(0);
  except
    on E: Exception do
      MessageBox(0, PChar('Произошла ошибка при попытке регистрации.'#13#10 + E.Message),
       'Ошибка', MB_OK or MB_ICONERROR or MB_TASKMODAL);
  end;
end;

procedure TGedeminReportServer.gsIBDatabaseAfterConnect(Sender: TObject);
begin
// Виснет нахрен сервер
(*  try
    TCrackerThread(ServiceThread).Synchronize(IBEvents1.RegisterEvents);
  except
    on E: Exception do
      ServerReport.SaveLog('Произошла ошибка при регистрации IB событий:'#13#10 + E.Message);
  end;*)
end;

{constructor TGedeminReportServer.Create(AOwner: TComponent);
begin
  try
    WriteError('до запуска');
    inherited;
    WriteError('после запуска');
  except
    on E: Exception do
    begin
      WriteError(E.Message);
      raise;
    end;
  end;
end;

procedure TGedeminReportServer.ServiceCreate(Sender: TObject);
begin
  try
    WriteError('до запуска 2');
    inherited;
    WriteError('после запуска 2');
  except
    on E: Exception do
    begin
      WriteError(E.Message);
      raise;
    end;
  end;
end;

procedure TGedeminReportServer.ServiceExecute(Sender: TService);
begin
  try
    WriteError('до запуска 3');
    inherited;
    WriteError('после запуска 3');
  except
    on E: Exception do
    begin
      WriteError(E.Message);
      raise;
    end;
  end;
end;}

procedure TGedeminReportServer.ServiceDestroy(Sender: TObject);
begin
  WriteError('TGedeminReportServer.ServiceDestroy');
  ServerReport.SaveLog('Завершение сервиса сервера отчетов');
end;

procedure TGedeminReportServer.ServiceShutdown(Sender: TService);
begin
  WriteError('TGedeminReportServer.ServiceShutdown');
  ServerReport.SaveLog('Shutdown сервиса');
end;

end.

