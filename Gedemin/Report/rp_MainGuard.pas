// ShlTanya, 27.02.2019

unit rp_MainGuard;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, SvcMgr, Dialogs,
  ExtCtrls;

type
  TReportGuard = class(TService)
    Timer1: TTimer;
    procedure Timer1Timer(Sender: TObject);
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
  private
    { Private declarations }
    procedure StopServer;
    function GetServerHandle: Integer;
  public
    function GetServiceController: TServiceController; override;
    { Public declarations }
  end;

var
  ReportGuard: TReportGuard;

implementation

uses
  ShellApi;

{$R *.DFM}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  ReportGuard.Controller(CtrlCode);
end;

function TReportGuard.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TReportGuard.Timer1Timer(Sender: TObject);
begin
  try
    Timer1.Enabled := False;

    if GetServerHandle = 0 then
      ShellExecute(0, 'open', PChar(ExtractFilePath(ParamStr(0)) + 'reportsv.exe'), '/A', '', 0);

    Timer1.Enabled := True;
  except
  end;
end;

procedure TReportGuard.ServiceStart(Sender: TService; var Started: Boolean);
begin
  Timer1Timer(nil);
  Timer1.Enabled := True;
end;

procedure TReportGuard.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
  Timer1.Enabled := False;
  StopServer;
end;

procedure TReportGuard.StopServer;
var
  IBHndl: HWND;
  PrHndl, ExitCode: Cardinal;
  PrID: Cardinal;
begin
  try
    { DONE -oJKL : Возможно надо сделать выгрузку всех окон }
    IBHndl := GetServerHandle;
    // Проверяем загружен ли сервер
    if IBHndl <> 0 then
    begin
      // Получаем ID процесса
      GetWindowThreadProcessId(IBHndl, @PrID);
      if PrID <> 0 then
      begin
        // Получаем handle процесса
        PrHndl := OpenProcess(PROCESS_TERMINATE + PROCESS_QUERY_INFORMATION, False, PrID);
        if PrHndl <> 0 then
        begin
          // Получаем код выхода
          if GetExitCodeProcess(PrHndl, ExitCode) then
            // Завершаем процесс
            TerminateProcess(PrHndl, ExitCode);
          // Закрываем handle
          CloseHandle(PrHndl);
        end;
      end;
    end;
  except
  end;
end;

function TReportGuard.GetServerHandle: Integer;
begin
  Result := FindWindow('TUnvisibleForm', nil);
end;

end.
