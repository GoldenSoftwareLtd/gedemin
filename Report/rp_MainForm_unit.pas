unit rp_MainForm_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, IBDatabase, rp_ReportServer, rp_BaseReport_unit,
  rp_ReportScriptControl, ActiveX, ScktComp, StdCtrls, thrd_Event, IBEvents;

type
  TUnvisibleForm = class(TForm)
    gsIBDatabase: TIBDatabase;
    ServerReport: TServerReport;
    IBTransaction: TIBTransaction;
    Button1: TButton;
    IBEvents1: TIBEvents;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ServerReportCreateObject(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure IBEvents1EventAlert(Sender: TObject; EventName: String;
      EventCount: Integer; var CancelAlerts: Boolean);
    procedure gsIBDatabaseAfterConnect(Sender: TObject);
    procedure gsIBDatabaseBeforeDisconnect(Sender: TObject);
    procedure IBEvents1Error(Sender: TObject; ErrorCode: Integer);
  private
    FBaseQuery: IDispatch;
//    FThreadEvent: TServerEventThread;

    procedure WMUser(var Message: TMessage); message WM_USER;
    procedure ReadParams;
  public
    procedure ThreadEvent(const AnEventCode: TServerEventCode);
  end;

var
  UnvisibleForm: TUnvisibleForm;

implementation

uses
  rp_server_connect_option, rp_report_const, obj_QueryList, Registry,
  gd_directories_const, inst_const;

{$R *.DFM}

procedure TUnvisibleForm.ReadParams;
var
  Reg: TRegistry;
  UserName, UserPass, DBName, Param: String;
begin
  try
    GetReportServerConnectParam(UserName, UserPass, DBName);

    gsIBDatabase.Params.Clear;
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
  except
    on E: Exception do
      ServerReport.SaveLog(E.Message);
  end;
end;

procedure TUnvisibleForm.FormCreate(Sender: TObject);
var
  TempError: String;
begin
  try
    OleInitialize(nil);
//    FThreadEvent := TServerEventThread.Create(ServerReportName);
//    FThreadEvent.Resume;
//    FThreadEvent.OnEvent := ThreadEvent;
    FBaseQuery := TgsQueryList.Create(gsIBDatabase, IBTransaction) as IDispatch;
    ReadParams;
    ServerReport.Load;
  except
    on E: Exception do
    begin
      TempError := 'Произошла ошибка при загрузке сервера'#13#10 + E.Message;
//      MessageBox(0, PChar(TempError), 'Ошибка', MB_OK or MB_ICONERROR or MB_TASKMODAL);
      ServerReport.SaveLog(TempError);
      Application.Terminate;
    end;
  end;
end;

procedure TUnvisibleForm.FormDestroy(Sender: TObject);
var
  Reg: TRegistry;
begin
  FBaseQuery := nil;

  OleUninitialize;

//  FThreadEvent.UserTerminate;

  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey(cReportRegPath, True) then
    begin
      Reg.WriteString(cReportServerPath, Application.ExeName);
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;

  ServerReport.SaveLog('Завершение программы сервера отчетов');
end;

procedure TUnvisibleForm.WMUser(var Message: TMessage);
begin
  try
    case Message.WParam of
      WM_USER_CLOSE:
      begin
        if (Message.LParam <> 0) or (ServerReport.ActiveConnections = 0) or (MessageBox(0,
         PChar(Format('К серверу отчетов подключено %d клиент(ов). Выгрузить сервер?',
         [ServerReport.ActiveConnections])), 'Вопрос', MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL) = IDYES) then
          Application.Terminate;
      end;
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
    on E: Exception do
      ServerReport.SaveLog('Произошла ошибка при управлении сервером отчетов'#13#10
       + E.Message);
  end;
end;

procedure TUnvisibleForm.ServerReportCreateObject(Sender: TObject);
begin
  try
    (Sender as TReportScript).AddObject(ReportObjectName, FBaseQuery, False);
    (Sender as TReportScript).AddObject('BaseQueryList', FBaseQuery, False);
  except
    on E: Exception do
      ServerReport.SaveLog(E.Message);
  end;
end;

procedure TUnvisibleForm.Button1Click(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TUnvisibleForm.ThreadEvent(const AnEventCode: TServerEventCode);
begin
  try
    case AnEventCode of
      WM_USER_CLOSE_PROMT:
        if (ServerReport <> nil) and ((ServerReport.ActiveConnections = 0) or (MessageBox(0,
         PChar(Format('К серверу отчетов подключено %d клиент(ов). Выгрузить сервер?',
         [ServerReport.ActiveConnections])), 'Вопрос', MB_YESNO or MB_ICONQUESTION or MB_SYSTEMMODAL) = IDYES)) then
          Application.Terminate;
      WM_USER_CLOSE:
        Application.Terminate;
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
    on E: Exception do
      ServerReport.SaveLog('Произошла ошибка при управлении сервером отчетов'#13#10
       + E.Message);
  end;
end;

procedure TUnvisibleForm.IBEvents1EventAlert(Sender: TObject;
  EventName: String; EventCount: Integer; var CancelAlerts: Boolean);
begin
  try
    if EventName = 'CloseGedemin' then
      Application.Terminate;
  except
    on E: Exception do
      ServerReport.SaveLog(E.Message);
  end;
end;

procedure TUnvisibleForm.gsIBDatabaseAfterConnect(Sender: TObject);
begin
  try
    IBEvents1.Registered := True;
  except
    on E: Exception do
      ServerReport.SaveLog('IBEvents1.Registered := True; ' + E.Message);
  end;
end;

procedure TUnvisibleForm.gsIBDatabaseBeforeDisconnect(Sender: TObject);
begin
  try
    IBEvents1.Registered := False;
  except
    on E: Exception do
      ServerReport.SaveLog('IBEvents1.Registered := False; ' + E.Message);
  end;
end;

procedure TUnvisibleForm.IBEvents1Error(Sender: TObject;
  ErrorCode: Integer);
begin
  MessageBox(0, PChar(IntToStr(ErrorCode)), 'OnError', MB_OK or MB_TASKMODAL);
end;

end.

