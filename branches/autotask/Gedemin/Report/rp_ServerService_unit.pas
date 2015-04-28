unit rp_ServerService_unit;

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
    FBaseQuery: IDispatch;
    procedure ReadParams;
  public
//    constructor Create(AOwner: TComponent); override;
    function GetServiceController: TServiceController; override;
    procedure ThreadEvent(const AnEventCode: TServerEventCode);
  end;

type
  TCrackerThread = class(TThread);

var
  GedeminReportServer: TGedeminReportServer;
  Hndl: THandle;
  FThreadEvent: TServerEventThread;

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
  try
    Result := ServiceController;
  except
    ServerReport.SaveLog('GetServiceController');
  end;
end;

procedure AppThreadEvent(const AnEventCode: TServerEventCode);
begin
  case AnEventCode of
{    WM_USER_CLOSE_PROMT:
      if (Service1.ServerReport.ActiveConnections = 0) or (MessageBox(0,
       PChar(Format('� ������� ������� ���������� %d ������(��). ��������� ������?',
       [Service1.ServerReport.ActiveConnections])), '������', MB_YESNO or MB_ICONQUESTION) = IDYES) then
        Service1.Close;
    WM_USER_CLOSE:
      Service1.Close;}
    WM_USER_PARAM:
      if GedeminReportServer.ServerReport <> nil then
        GedeminReportServer.ServerReport.ServerOptions;
    WM_USER_REFRESH:
      if GedeminReportServer.ServerReport <> nil then
        GedeminReportServer.ServerReport.Load;
    WM_USER_REBUILD:
      if GedeminReportServer.ServerReport <> nil then
        GedeminReportServer.ServerReport.RebuildReports;
    WM_USER_RESET:
      if GedeminReportServer.ServerReport <> nil then
        GedeminReportServer.ServerReport.DeleteResult;
  end;
end;

procedure TGedeminReportServer.ReadParams;
var
  Reg: TRegistry;
  UserName, UserPass, DBName, Param: String;
begin
  try
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
        //  ���������
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
  except
    ServerReport.SaveLog('ReadParams');
  end;
end;

procedure TGedeminReportServer.ThreadEvent(const AnEventCode: TServerEventCode);
begin
  try
    case AnEventCode of
      {WM_USER_CLOSE_PROMT:
        if (ServerReport.ActiveConnections = 0) or (MessageBox(0,
         PChar(Format('� ������� ������� ���������� %d ������(��). ��������� ������?',
         [ServerReport.ActiveConnections])), '������', MB_YESNO or MB_ICONQUESTION) = IDYES) then
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
end;

procedure TGedeminReportServer.ServerReportCreateObject(Sender: TObject);
begin
  try
    (Sender as TReportScript).AddObject(ReportObjectName, FBaseQuery, False);
    (Sender as TReportScript).AddObject('BaseQueryList', FBaseQuery, False);
  except
    ServerReport.SaveLog('ServerReportCreateObject');
  end;
end;

procedure TGedeminReportServer.IBEvents1EventAlert(Sender: TObject;
  EventName: String; EventCount: Integer; var CancelAlerts: Boolean);
begin
  try
    if EventName = 'CloseGedemin' then;
      ServerReport.CloseConnection;
  except
    ServerReport.SaveLog('IBEvents1EventAlert');
  end;
end;

procedure TGedeminReportServer.ServiceStart(Sender: TService;
  var Started: Boolean);
begin
  try
    Started := True;

  {  if IBEvents1.AutoRegister then
    begin
      ServerReport.SaveLog('������ ������� IBEvents1.AutoRegister = True!!!');
      Started := False;
      Exit;
    end;}

    if CheckReportServerActivate <> Long_False then
    begin
      ServerReport.SaveLog('������� ���������� ������� �������. ������ ������� ��� ��������.');
      Started := False;
      Exit;
    end;

    SetLastError(0);
    Hndl := CreateMutex(nil, False, ReportServerMutexName);
    if Hndl = 0 then
    begin
      ServerReport.SaveLog('��������� ������ ��� �������� Mutex.');
      Started := False;
      Exit;
    end;

    try
      FThreadEvent := TServerEventThread.Create(ServerReportName);
      FThreadEvent.OnEvent := GedeminReportServer.ThreadEvent;
      FThreadEvent.Resume;
    except
      on E: Exception do
      begin
        Started := False;
        ServerReport.SaveLog('��������� ������ ��� ������� �������.'#13#10 + E.Message);
      end;
    end;

    ServerReport.SaveLog('BeforeConnect');
    try
      OleInitialize(nil);
      if not Assigned(FBaseQuery) then
        FBaseQuery := TgsQueryList.Create(gsIBDatabase, IBTransaction) as IDispatch;
      ReadParams;
      ServerReport.Load;
      if ServerReport.ServerKey = 0 then
        raise Exception.Create('������ ���������� ����������� � ����: ' +
         ServerReport.Database.Name);
    except
      on E: Exception do
      begin
        Started := False;
        ServerReport.SaveLog('��������� ������ ��� �������� �������.'#13#10 + E.Message);
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
  try
    Stopped := True;

    ServerReport.SaveLog('������ ������� �������');

    try
      FThreadEvent.UserTerminate;
    except
      on E: Exception do
        ServerReport.SaveLog('��������� ������ ��� ������������ ���� �������'#13#10 + E.Message);
    end;

    try
      ReleaseMutex(Hndl);
    except
      on E: Exception do
        ServerReport.SaveLog('��������� ������ ��� ������������ MUTEX'#13#10 + E.Message);
    end;

    try
      FBaseQuery := nil;
      OleUninitialize;
    except
      on E: Exception do
        ServerReport.SaveLog('��������� ������ ��� ���������� OleUninitialize'#13#10 + E.Message);
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
    TempBool := MessageBox(0, '������ ������� ����� �� ����� ������ � Interbase ��������?',
     '������', MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL) = IDYES;

    if not TempBool then
      Dependencies.Delete(0);
  except
    on E: Exception do
      MessageBox(0, PChar('��������� ������ ��� ������� �����������.'#13#10 + E.Message),
       '������', MB_OK or MB_ICONERROR or MB_TASKMODAL);
  end;
end;

procedure TGedeminReportServer.gsIBDatabaseAfterConnect(Sender: TObject);
begin
// ������ ������ ������
(*  try
    TCrackerThread(ServiceThread).Synchronize(IBEvents1.RegisterEvents);
  except
    on E: Exception do
      ServerReport.SaveLog('��������� ������ ��� ����������� IB �������:'#13#10 + E.Message);
  end;*)
end;

{constructor TGedeminReportServer.Create(AOwner: TComponent);
begin
  try
    WriteError('�� �������');
    inherited;
    WriteError('����� �������');
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
    WriteError('�� ������� 2');
    inherited;
    WriteError('����� ������� 2');
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
    WriteError('�� ������� 3');
    inherited;
    WriteError('����� ������� 3');
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
  try
    ServerReport.SaveLog('���������� ������� ������� �������');
  except
    ServerReport.SaveLog('ServiceDestroy');
  end;
end;

procedure TGedeminReportServer.ServiceShutdown(Sender: TService);
begin
  try
    ServerReport.SaveLog('Shutdown �������');
  except
    ServerReport.SaveLog('ServiceShutdown');
  end;
end;

end.

