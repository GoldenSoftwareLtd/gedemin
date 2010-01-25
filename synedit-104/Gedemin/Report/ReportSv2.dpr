
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

program ReportSv2;

uses
  SvcMgr,
  SysUtils,
  Windows,
  Classes,
  rp_MainForm_unit in 'rp_MainForm_unit.pas' {UnvisibleForm},
  rp_ServerService2_unit in 'rp_ServerService2_unit.pas' {GedeminReportServer: TService},
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

procedure WriteError(AnError: String);
var
  FStr: TFileStream;
  S: String;
begin
  try
    AnError := AnError + #13#10;
//    S := ChangeFileExt(Application.EXEName, '.log');
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
  except
    on E: Exception do
      MessageBox(0, PChar(E.Message), 'SaveLog', MB_OK);
  end;
end;

procedure AppThreadEvent(const AnEventCode: TServerEventCode);
begin
  try
    case AnEventCode of
      WM_USER_CLOSE_PROMT:
        if (UnvisibleForm.ServerReport.ActiveConnections = 0) or (MessageBox(0,
         PChar(Format('� ������� ������� ���������� %d ������(��). ��������� ������?',
         [UnvisibleForm.ServerReport.ActiveConnections])), '������', MB_YESNO + MB_ICONQUESTION) = IDYES) then
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
      UnvisibleForm.ServerReport.SaveLog('��������� ������ ��� ���������� �������� �������'#13#10
       + E.Message);
  end;
end;

begin
  Application.Initialize;
  Application.CreateForm(TGedeminReportServer, GedeminReportServer);
  Application.Run;
end.
