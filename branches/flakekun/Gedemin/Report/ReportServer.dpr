
{++

  Copyright (c) 2001 by Golden Software of Belarus

  Module

    ReportServer.dpr

  Abstract

    Gedemin project. REPORT SERVER.

  Author

    Andrey Shadevsky

  Revisions history

    1.00   ~01.05.01    JKL        Initial version.
    1.01    08.11.01    JKL        The system is more reliable.

--}

program ReportServer;

uses
  Forms,
  SysUtils,
  Windows,
  Classes,
  rp_MainForm_unit in 'rp_MainForm_unit.pas' {UnvisibleForm},
  ReportServer_TLB in 'ReportServer_TLB.pas',
  CheckServerLoad_unit in 'CheckServerLoad_unit.pas',
  rp_ExecuteThread_unit in 'rp_ExecuteThread_unit.pas',
  rp_report_const in 'rp_report_const.pas',
  thrd_Event,
  obj_WrapperIBXClasses in '..\Property\obj_WrapperIBXClasses.pas';

var
  Hndl: THandle;
  FThreadEvent: TServerEventThread;

{$R *.RES}

procedure WriteError(const AnError: String);
var
  FStr: TFileStream;
begin
  FStr := TFileStream.Create(ChangeFileExt(Application.EXEName, '.log'), fmOpenWrite);
  try
    FStr.Position := FStr.Size;
    FStr.Write(AnError[1], Length(AnError));
  finally
    FStr.Free;
  end;
end;

procedure AppThreadEvent(const AnEventCode: TServerEventCode);
begin
  try
    case AnEventCode of
      WM_USER_CLOSE_PROMT:
        if (UnvisibleForm.ServerReport.ActiveConnections = 0) or (MessageBox(0,
         PChar(Format('К серверу отчетов подключено %d клиент(ов). Выгрузить сервер?',
         [UnvisibleForm.ServerReport.ActiveConnections])), 'Вопрос', MB_YESNO + MB_ICONQUESTION) = IDYES) then
          UnvisibleForm.Close;
      WM_USER_CLOSE:
        UnvisibleForm.Close;
      WM_USER_PARAM:
        if UnvisibleForm.ServerReport <> nil then
          UnvisibleForm.ServerReport.ServerOptions;
      WM_USER_REFRESH:
        if UnvisibleForm.ServerReport <> nil then
          UnvisibleForm.ServerReport.Load;
      WM_USER_REBUILD:
        if UnvisibleForm.ServerReport <> nil then
          UnvisibleForm.ServerReport.RebuildReports;
      WM_USER_RESET:
        if UnvisibleForm.ServerReport <> nil then
          UnvisibleForm.ServerReport.DeleteResult;
    end;
  except
    on E: Exception do
      UnvisibleForm.ServerReport.SaveLog('Произошла ошибка при управлении сервером отчетов'#13#10
       + E.Message);
  end;
end;

begin
  Application.Initialize;

  if CheckReportServerActivate <> Long_False then
  begin
    WriteError('ПОПЫТКА ПОВТОРНОГО ЗАПУСКА СЕРВЕРА. Сервер отчетов уже загружен.'#13#10);
    Exit;
  end;

  SetLastError(0);
  Hndl := CreateMutex(nil, False, ReportServerMutexName);
  if Hndl = 0 then
  begin
    WriteError('Произошла ошибка при создании Mutex.'#13#10);
    Exit;
  end;
  try
    try
      Application.ShowMainForm := False;
      FThreadEvent := TServerEventThread.Create(ServerReportName);
      try
        Application.CreateForm(TUnvisibleForm, UnvisibleForm);
        FThreadEvent.OnEvent := UnvisibleForm.ThreadEvent;
        FThreadEvent.Resume;
        Application.Run;
      finally
        FThreadEvent.UserTerminate;
      end;
    except
      on E: Exception do
        WriteError('Произошла ошибка при запуске сервера.'#13#10 + E.Message);
    end;
  finally
    ReleaseMutex(Hndl);
  end; 
end.
