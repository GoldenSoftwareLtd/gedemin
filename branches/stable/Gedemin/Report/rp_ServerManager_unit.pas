unit rp_ServerManager_unit;
                                       
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ActnList, rp_SvrMngTemplate_unit, ExtCtrls, thrd_Event, IPCThrd;

type
  TUpdateStateEvent = procedure(const AnNewState: Word) of object;

type
  TServerManager = class(TSvrMngTemplate)
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure btnPropertyClick(Sender: TObject);
    procedure btnDisconnectClick(Sender: TObject);
    procedure actCloseExecute(Sender: TObject);
    procedure actCloseUpdate(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure btnRebuildClick(Sender: TObject);
    procedure btnConnectParamClick(Sender: TObject);
    procedure btnRunClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    FUpdateEvent: TUpdateStateEvent;

  protected
    function GetServerHandle: THandle;
  public
    procedure SendMessage(const AnRemote: Integer; const AnCode: TServerEventCode);
    procedure RunServer;

    property OnUpdateEvent: TUpdateStateEvent read FUpdateEvent write FUpdateEvent;
  end;

var
  ServerManager: TServerManager;

implementation

uses
  CheckServerLoad_unit, rp_report_const, rp_dlgServerConnectOptions_unit,
  rp_server_connect_option, gd_directories_const, Registry, ShellApi, inst_const;

{$R *.DFM}

function TServerManager.GetServerHandle: THandle;
begin
  Result := GetServerWindow;
  if Result = 0 then
    MessageBox(Handle, 'Не удалось установить соединение с сервером отчетов.',
     'Менджер сервера отчетов', MB_OK or MB_ICONWARNING);
end;

procedure TServerManager.FormCreate(Sender: TObject);
begin
  actCloseUpdate(nil);
{  if not GetServerHandle then
  begin
    MessageBox(Handle, 'Не удалось установить соединение с сервером отчетов.',
     'Менджер сервера отчетов', MB_OK or MB_ICONWARNING);
    Application.Terminate;
  end;}
end;

procedure TServerManager.btnPropertyClick(Sender: TObject);
begin
  SendMessage(0, WM_USER_PARAM);
end;

procedure TServerManager.btnRefreshClick(Sender: TObject);
begin
  SendMessage(0, WM_USER_REFRESH);
end;

procedure TServerManager.btnRebuildClick(Sender: TObject);
begin
  SendMessage(0, WM_USER_REBUILD);
end;

procedure TServerManager.btnDisconnectClick(Sender: TObject);
begin
  if MessageBox(Handle, 'Вы действительно хотите выгрузить сервер отчетов?',
   'Вопрос', MB_YESNO or MB_ICONQUESTION) = IDYES then
    SendMessage(0, WM_USER_CLOSE_PROMT);
end;

procedure TServerManager.actCloseExecute(Sender: TObject);
begin
  Close;
end;

procedure TServerManager.actCloseUpdate(Sender: TObject);
var
  FRes: Word;
begin
  FRes := CheckReportServerActivate;
  btnProperty.Enabled := FRes = Long_True;
  btnDisconnect.Enabled := btnProperty.Enabled;
  btnRebuild.Enabled := btnProperty.Enabled;
  btnRefresh.Enabled := btnProperty.Enabled;
  btnClear.Enabled := btnProperty.Enabled;
  btnRun.Enabled := FRes < Long_True;
  if Assigned(FUpdateEvent) then
    FUpdateEvent(FRes);
end;

procedure TServerManager.btnConnectParamClick(Sender: TObject);
var
  LocUser, LocPassword, DBName: String;
begin
  with TdlgServerConnectOptions.Create(Self) do
  try
    GetReportServerConnectParam(LocUser, LocPassword, DBName);
    if SetServerParam(LocUser, LocPassword) then
      SetReportServerConnectParam(LocUser, LocPassword, DBName);
  finally
    Free;
  end;
end;

procedure TServerManager.SendMessage(const AnRemote: Integer; const AnCode: TServerEventCode);
var
  LocMemory: TSharedMem;
  FServerEvent: THandle;
begin
  SetLastError(0);
  try
    FServerEvent := OpenEvent(EVENT_ALL_ACCESS, False, ServerReportName);
    if FServerEvent <> 0 then
    try
      LocMemory := TSharedMem.Create(ServerReportName + EventPrefix, SizeOf(TServerEventCode));
      try
        TServerEventCode(LocMemory.Buffer^) := AnCode;
        SetEvent(FServerEvent);
      finally
        LocMemory.Free;
      end;
    finally
      CloseHandle(FServerEvent);
    end else
      if GetLastError = ERROR_ACCESS_DENIED then
        raise Exception.Create('Нет доступа к серверу отчетов.')
      else
        raise Exception.Create('Сервер отчетов не загружен.');
  except
    on E: Exception do
      if AnRemote = 0 then
        MessageBox(Handle, PChar(E.Message), 'Внимание', MB_OK or MB_ICONERROR);
  end;
end;

procedure TServerManager.RunServer;
var
  Reg: TRegistry;
  S: String;
  Directory: String;
begin
  if CheckReportServerActivate <> Long_False then
    Exit;

  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKeyReadOnly(cReportRegPath) then
    begin
      S := Reg.ReadString(cReportServerPath);
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;

  if Trim(S) > '' then
  begin
    Directory := ExtractFilePath(S) + #0;
    S := S + #0;
    if ShellExecute(Handle, 'open'#0, @S[1], '/A', @Directory[1], SW_SHOW) <= 32 then
    begin
      MessageBox(Handle,
        PChar(Format('Невозможно открыть файл %s.', [S])),
        'Внимание', MB_OK or MB_ICONEXCLAMATION);
    end;
  end;
end;

procedure TServerManager.btnRunClick(Sender: TObject);
begin
  RunServer;
end;

procedure TServerManager.btnClearClick(Sender: TObject);
begin
  SendMessage(0, WM_USER_RESET);
end;

procedure TServerManager.Timer1Timer(Sender: TObject);
begin
  actCloseUpdate(nil);
end;

end.
