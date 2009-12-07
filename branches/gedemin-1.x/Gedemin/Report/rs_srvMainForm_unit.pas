unit rs_srvMainForm_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, SvcMgr, Dialogs,
  Db, IBDatabase, rp_ReportServer, rp_BaseReport_unit,
  rp_ReportScriptControl, ActiveX, ScktComp, StdCtrls;

type
  TsrvMainForm = class(TService)
    gsIBDatabase1: TIBDatabase;
    ServerReport1: TServerReport;
    IBTransaction1: TIBTransaction;
    procedure ServiceExecute(Sender: TService);
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
  private
    procedure WMUser(var Message: TMessage); message WM_USER;
    procedure ReadParams;
  public
    function GetServiceController: TServiceController; override;
    { Public declarations }
  end;

var
  srvMainForm: TsrvMainForm;

implementation

uses
  rp_server_connect_option, rp_report_const, obj_QueryList_unit, Registry,
  gd_directories_const;

{$R *.DFM}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  srvMainForm.Controller(CtrlCode);
end;

function TsrvMainForm.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TsrvMainForm.WMUser(var Message: TMessage);
begin
  case Message.WParam of
    WM_USER_CLOSE:
    begin
      if (ServerReport1.ActiveConnections = 0) or (MessageBox(0,
       PChar(Format('К серверу отчетов подключено %d клиент(ов). Выгрузить сервер?',
       [ServerReport1.ActiveConnections])), 'Вопрос',
       MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL) = IDYES) then
        AllowStop := True;
    end;
    WM_USER_PARAM:
      if ServerReport1 <> nil then
        ServerReport1.ServerOptions;
    WM_USER_REFRESH:
      if ServerReport1 <> nil then
        ServerReport1.Load;
    WM_USER_REBUILD:
      if ServerReport1 <> nil then
        ServerReport1.RebuildReports;
  end;
end;

procedure TsrvMainForm.ReadParams;
var
  Reg: TRegistry;
  UserName, UserPass, Param: String;
begin
  Reg := TRegistry.Create;

  gsIBDatabase1.Params.Clear;
  GetReportServerConnectParam(UserName, UserPass);
  gsIBDatabase1.Params.Add(User_NameValue + '=' + UserName);
  gsIBDatabase1.Params.Add(PasswordValue + '=' + UserPass);
  gsIBDatabase1.Params.Add(SQL_Role_NameValue + '=' + DefaultSQL_Role_Name);

  gsIBDatabase1.Params.Values[Lc_ctypeValue] := DefaultLc_ctype;

  try
    Reg.RootKey := ClientRootRegistryKey;

    if Reg.OpenKeyReadOnly(ClientRootRegistrySubKey) then
    begin
      //  Наименование сервера
      if Reg.ValueExists(ServerNameValue) then
        gsIBDatabase1.DatabaseName := Reg.ReadString(ServerNameValue)
      else
        gsIBDatabase1.DatabaseName := '';

      //  Кодировка
      if Reg.ValueExists(Lc_ctypeValue) then
      begin
        Param := Reg.ReadString(Lc_ctypeValue);
        
        if Param > '' then
          gsIBDatabase1.Params.Values[Lc_ctypeValue] := Param;
      end;

      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
end;

procedure TsrvMainForm.ServiceExecute(Sender: TService);
begin
  try
    OleInitialize(nil);
    ReadParams;
    ServerReport1.Load;
  except
    on E: Exception do
    begin
      MessageBox(0, PChar('Произошла ошибка при загрузке сервера'#13#10 + E.Message),
       'Ошибка', MB_OK or MB_ICONERROR or MB_TASKMODAL);
      AllowStop := True;
    end;
  end
end;

procedure TsrvMainForm.ServiceStart(Sender: TService;
  var Started: Boolean);
begin
//
end;

procedure TsrvMainForm.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
  Stopped := True;
  OleUninitialize;
end;

end.
